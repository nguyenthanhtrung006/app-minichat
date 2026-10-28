import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/call_api_client.dart';
import '../../../../core/storage/token_storage.dart';

/// CallSignalingService - Quản lý kết nối SignalR CallHub và WebRTC P2P
/// Hỗ trợ đầy đủ các tính năng cuộc gọi 1-1 Thoại (Voice) và Video theo tài liệu backend:
/// - Kết nối SignalR CallHub với JWT Bearer Token qua Query Param
/// - Quản lý WebRTC RTCPeerConnection, LocalStream, RemoteStream
/// - Render Video thời gian thực qua RTCVideoRenderer
/// - Trao đổi SDP Offer / Answer & ICE Candidate
/// - Điều khiển Microphone, Loa ngoài (Speaker), Camera trước/sau
class CallSignalingService {
  static final CallSignalingService instance = CallSignalingService._internal();

  HubConnection? _hubConnection;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Renderers cho giao diện Video Call
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  bool _renderersInitialized = false;

  // Hàng đợi ICE Candidate khi chưa hoàn tất setRemoteDescription
  final List<RTCIceCandidate> _remoteCandidateQueue = [];
  bool _isRemoteDescriptionSet = false;

  // Cấu hình STUN/TURN ICE Servers (mặc định Google STUN miễn phí)
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
    ]
  };

  // Trạng thái cuộc gọi hiện tại
  String? currentCallSessionId;
  int? currentTargetUserId;
  bool isCaller = false;
  bool isVideoCall = false;

  // Callbacks sự kiện
  void Function(Map<String, dynamic> data)? onIncomingCall;
  void Function(Map<String, dynamic> data)? onCallRinging;
  void Function(Map<String, dynamic> data)? onCallAccepted;
  void Function(String reason)? onCallRejected;
  void Function(Map<String, dynamic> data)? onCallEnded;
  void Function(String message)? onUserBusy;
  void Function(String message)? onUserOffline;
  void Function(MediaStream stream)? onRemoteStreamUpdated;
  void Function(MediaStream stream)? onLocalStreamUpdated;

  CallSignalingService._internal();

  /// Khởi tạo các Video Renderers
  Future<void> initRenderers() async {
    if (!_renderersInitialized) {
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      _renderersInitialized = true;
    }
  }

  /// Khởi tạo kết nối SignalR CallHub
  Future<void> initSignalR({String? token}) async {
    final jwt = token ?? await TokenStorage.instance.getToken();
    if (jwt == null || jwt.isEmpty) {
      debugPrint('⚠️ [CallSignalingService]: Không tìm thấy Token, chưa thể kết nối CallHub.');
      return;
    }

    if (_hubConnection != null &&
        (_hubConnection!.state == HubConnectionState.Connected ||
         _hubConnection!.state == HubConnectionState.Connecting)) {
      debugPrint('ℹ️ [CallSignalingService]: Đã kết nối hoặc đang kết nối tới CallHub.');
      return;
    }

    await initRenderers();

    // Nạp thêm STUN Server từ REST API nếu có
    try {
      final dynamicIceServers = await CallApiClient().getIceServers();
      if (dynamicIceServers.isNotEmpty) {
        final list = _iceServers['iceServers'] as List<dynamic>;
        list.addAll(dynamicIceServers);
      }
    } catch (_) {}

    final hubUrl = ApiConstants.callHubUrl;
    debugPrint('\n📞 ==================== [CALL HUB CONNECTING] ====================');
    debugPrint('➡️ Hub URL : $hubUrl');
    debugPrint('================================================================');

    final options = HttpConnectionOptions(
      accessTokenFactory: () async {
        final currentToken = token ?? await TokenStorage.instance.getToken();
        return currentToken ?? '';
      },
    );

    _hubConnection = HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect()
        .build();

    _registerHubListeners();

    // Bắt đầu kết nối
    try {
      await _hubConnection?.start();
      debugPrint('🎉 [CallHub]: Kết nối CallHub thành công!');
    } catch (e) {
      debugPrint('⚠️ [CallHub]: Lỗi kết nối CallHub: $e');
    }
  }

  void _registerHubListeners() {
    if (_hubConnection == null) return;

    // 1. Nhận cuộc gọi đến (IncomingCall)
    _hubConnection?.on('IncomingCall', (arguments) {
      debugPrint('📞 [CallHub Event IncomingCall]: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = Map<String, dynamic>.from(arguments[0] as Map);
        currentCallSessionId = data['callSessionId']?.toString();
        isCaller = false;
        isVideoCall = data['callType']?.toString().toLowerCase() == 'video';
        onIncomingCall?.call(data);
      }
    });

    // 2. Cuộc gọi đang đổ chuông (CallRinging)
    _hubConnection?.on('CallRinging', (arguments) {
      debugPrint('🔔 [CallHub Event CallRinging]: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = Map<String, dynamic>.from(arguments[0] as Map);
        onCallRinging?.call(data);
      }
    });

    // 3. Đối phương chấp nhận cuộc gọi (CallAccepted)
    _hubConnection?.on('CallAccepted', (arguments) async {
      debugPrint('🤝 [CallHub Event CallAccepted]: $arguments');
      if (arguments != null && arguments.isNotEmpty) {
        final data = Map<String, dynamic>.from(arguments[0] as Map);
        final sessionId = data['callSessionId']?.toString() ?? currentCallSessionId;
        currentCallSessionId = sessionId;
        onCallAccepted?.call(data);

        // QUAN TRỌNG: Chỉ có Người gọi (Caller) mới tạo và gửi WebRTC Offer!
        // Người nhận (Callee) chỉ lắng nghe ReceiveOffer và gửi Answer trả lại.
        if (isCaller && sessionId != null && sessionId.isNotEmpty) {
          await _createAndSendOffer(sessionId);
        }
      }
    });

    // 4. Đối phương từ chối cuộc gọi (CallRejected)
    _hubConnection?.on('CallRejected', (arguments) {
      debugPrint('🚫 [CallHub Event CallRejected]: $arguments');
      String reason = 'Cuộc gọi bị từ chối';
      if (arguments != null && arguments.isNotEmpty) {
        final arg0 = arguments[0];
        if (arg0 is Map) {
          reason = arg0['reason']?.toString() ?? reason;
        }
      }
      onCallRejected?.call(reason);
      cleanUp();
    });

    // 5. Kết thúc cuộc gọi (CallEnded)
    _hubConnection?.on('CallEnded', (arguments) {
      debugPrint('📴 [CallHub Event CallEnded]: $arguments');
      Map<String, dynamic> data = {};
      if (arguments != null && arguments.isNotEmpty) {
        final arg0 = arguments[0];
        if (arg0 is Map) {
          data = Map<String, dynamic>.from(arg0);
        }
      }
      onCallEnded?.call(data);
      cleanUp();
    });

    // 6. Đối phương đang bận (UserBusy)
    _hubConnection?.on('UserBusy', (arguments) {
      debugPrint('⏳ [CallHub Event UserBusy]: $arguments');
      String msg = 'Đối phương đang bận';
      if (arguments != null && arguments.isNotEmpty) {
        final arg0 = arguments[0];
        if (arg0 is Map) {
          msg = arg0['message']?.toString() ?? msg;
        }
      }
      onUserBusy?.call(msg);
      cleanUp();
    });

    // 7. Đối phương offline (UserOffline)
    _hubConnection?.on('UserOffline', (arguments) {
      debugPrint('📴 [CallHub Event UserOffline]: $arguments');
      String msg = 'Đối phương hiện không trực tuyến';
      if (arguments != null && arguments.isNotEmpty) {
        final arg0 = arguments[0];
        if (arg0 is Map) {
          msg = arg0['message']?.toString() ?? msg;
        }
      }
      onUserOffline?.call(msg);
      cleanUp();
    });

    // 8. Nhận WebRTC Offer (ReceiveOffer)
    _hubConnection?.on('ReceiveOffer', (arguments) async {
      debugPrint('📥 [CallHub Event ReceiveOffer]: $arguments');
      if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
        final offer = Map<String, dynamic>.from(arguments[0] as Map);
        await _handleReceiveOffer(offer);
      }
    });

    // 9. Nhận WebRTC Answer (ReceiveAnswer)
    _hubConnection?.on('ReceiveAnswer', (arguments) async {
      debugPrint('📥 [CallHub Event ReceiveAnswer]: $arguments');
      try {
        if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
          final answer = Map<String, dynamic>.from(arguments[0] as Map);
          final sdp = answer['sdp']?.toString();
          final type = answer['type']?.toString() ?? 'answer';
          if (sdp != null && _peerConnection != null) {
            await _peerConnection?.setRemoteDescription(
              RTCSessionDescription(sdp, type),
            );
            await _drainCandidateQueue();
            debugPrint('✅ [WebRTC]: Đã đặt Remote Description từ Answer, P2P hoàn tất!');
          }
        }
      } catch (e) {
        debugPrint('❌ [WebRTC]: Lỗi xử lý Answer: $e');
      }
    });

    // 10. Nhận ICE Candidate (ReceiveIceCandidate)
    _hubConnection?.on('ReceiveIceCandidate', (arguments) async {
      try {
        if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
          final candidateMap = Map<String, dynamic>.from(arguments[0] as Map);
          final candStr = candidateMap['candidate']?.toString();
          final sdpMid = candidateMap['sdpMid']?.toString();
          final sdpMLineIndex = candidateMap['sdpMLineIndex'] is int
              ? candidateMap['sdpMLineIndex'] as int
              : int.tryParse(candidateMap['sdpMLineIndex']?.toString() ?? '0') ?? 0;

          if (candStr != null && candStr.isNotEmpty) {
            final candidate = RTCIceCandidate(candStr, sdpMid, sdpMLineIndex);
            if (_peerConnection != null && _isRemoteDescriptionSet) {
              await _peerConnection?.addCandidate(candidate);
            } else {
              _remoteCandidateQueue.add(candidate);
              debugPrint('⏳ [WebRTC]: Đã xếp hàng ICE Candidate chờ Remote Description');
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ [WebRTC]: Lỗi thêm ICE Candidate: $e');
      }
    });
  }

  Future<void> _drainCandidateQueue() async {
    _isRemoteDescriptionSet = true;
    if (_peerConnection == null) return;
    for (final candidate in _remoteCandidateQueue) {
      try {
        await _peerConnection?.addCandidate(candidate);
      } catch (e) {
        debugPrint('⚠️ [WebRTC]: Lỗi áp dụng Candidate từ hàng đợi: $e');
      }
    }
    _remoteCandidateQueue.clear();
  }

  /// Khởi tạo luồng Microphone / Camera với quyền hệ thống
  Future<void> initLocalStream({bool isVideo = false}) async {
    if (_localStream != null) {
      if (isVideo && _localStream!.getVideoTracks().isEmpty) {
        for (final t in _localStream!.getTracks()) {
          t.stop();
        }
        _localStream?.dispose();
        _localStream = null;
      } else {
        localRenderer.srcObject = _localStream;
        onLocalStreamUpdated?.call(_localStream!);
        return;
      }
    }

    // 1. Xin quyền Microphone
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted && !kIsWeb) {
      debugPrint('⚠️ [Permission]: Quyền microphone chưa được cấp');
    }

    // 2. Xin quyền Camera nếu là cuộc gọi Video
    if (isVideo) {
      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted && !kIsWeb) {
        debugPrint('⚠️ [Permission]: Quyền camera chưa được cấp');
      }
    }

    final mediaConstraints = {
      'audio': true,
      'video': isVideo
          ? {
              'mandatory': {
                'minWidth': '640',
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
          : false,
    };

    try {
      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      localRenderer.srcObject = _localStream;
      onLocalStreamUpdated?.call(_localStream!);
      debugPrint('🎙️ [WebRTC]: Đã tạo LocalStream thành công (Video: $isVideo)');
    } catch (e) {
      debugPrint('❌ [WebRTC]: Lỗi tạo LocalStream: $e');
    }
  }

  /// Khởi tạo Peer Connection
  Future<void> _createPeerConnection(String callSessionId) async {
    if (_peerConnection != null) {
      return;
    }

    final config = Map<String, dynamic>.from(_iceServers);
    config['sdpSemantics'] = 'unified-plan';

    _peerConnection = await createPeerConnection(config);

    // Gửi luồng âm thanh/video vào PeerConnection
    if (_localStream != null) {
      for (final track in _localStream!.getTracks()) {
        await _peerConnection?.addTrack(track, _localStream!);
      }
    }

    // Gửi ICE Candidates tới Server qua SignalR
    _peerConnection?.onIceCandidate = (candidate) {
      if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
        try {
          _hubConnection?.invoke('SendIceCandidate', args: [
            {
              'callSessionId': callSessionId,
              'candidate': candidate.candidate,
              'sdpMid': candidate.sdpMid,
              'sdpMLineIndex': candidate.sdpMLineIndex ?? 0,
            }
          ]).catchError((e) {
            debugPrint('⚠️ [WebRTC]: Lỗi gửi ICE Candidate: $e');
          });
        } catch (e) {
          debugPrint('⚠️ [WebRTC]: Ngoại lệ SendIceCandidate: $e');
        }
      }
    };

    // Khi nhận được luồng từ đối phương
    _peerConnection?.onTrack = (event) {
      debugPrint('🎥 [WebRTC onTrack]: Nhận track từ đối phương (track: ${event.track.kind})');
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        remoteRenderer.srcObject = _remoteStream;
        onRemoteStreamUpdated?.call(_remoteStream!);
      }
    };

    _peerConnection?.onConnectionState = (state) {
      debugPrint('🌐 [WebRTC ConnectionState]: $state');
    };
  }

  /// Tạo và gửi WebRTC Offer (Dành cho Người gọi)
  Future<void> _createAndSendOffer(String callSessionId) async {
    try {
      await _createPeerConnection(callSessionId);
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideoCall,
      });
      await _peerConnection!.setLocalDescription(offer);

      await _hubConnection?.invoke('SendOffer', args: [
        {
          'callSessionId': callSessionId,
          'sdp': offer.sdp,
          'type': offer.type,
        }
      ]);
      debugPrint('📤 [WebRTC]: Đã gửi WebRTC Offer cho phiên: $callSessionId');
    } catch (e) {
      debugPrint('❌ [WebRTC]: Lỗi tạo/gửi Offer: $e');
    }
  }

  /// Xử lý khi nhận Offer và gửi Answer (Dành cho Người nhận)
  Future<void> _handleReceiveOffer(Map<String, dynamic> offerData) async {
    try {
      final sessionId = offerData['callSessionId']?.toString() ?? currentCallSessionId ?? '';
      final sdp = offerData['sdp']?.toString() ?? '';
      final type = offerData['type']?.toString() ?? 'offer';

      await _createPeerConnection(sessionId);
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(sdp, type),
      );
      await _drainCandidateQueue();

      final answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': isVideoCall,
      });
      await _peerConnection!.setLocalDescription(answer);

      await _hubConnection?.invoke('SendAnswer', args: [
        {
          'callSessionId': sessionId,
          'sdp': answer.sdp,
          'type': answer.type,
        }
      ]);
      debugPrint('📤 [WebRTC]: Đã gửi WebRTC Answer cho phiên: $sessionId');
    } catch (e) {
      debugPrint('❌ [WebRTC]: Lỗi xử lý Offer và gửi Answer: $e');
    }
  }

  /// 1. Bắt đầu cuộc gọi (CallUser)
  Future<void> startCall(int targetUserId, {String callType = 'Voice'}) async {
    currentTargetUserId = targetUserId;
    isCaller = true;
    isVideoCall = callType.toLowerCase() == 'video';

    await initSignalR();
    await initLocalStream(isVideo: isVideoCall);

    try {
      await _hubConnection?.invoke('CallUser', args: [
        {'targetUserId': targetUserId, 'callType': callType}
      ]);
      debugPrint('📞 [CallHub]: Đã gọi CallUser(targetUserId: $targetUserId, type: $callType)');
    } catch (e) {
      debugPrint('⚠️ [CallHub]: Lỗi gọi CallUser: $e');
    }
  }

  /// 2. Chấp nhận cuộc gọi (AcceptCall)
  Future<void> acceptCall(String callSessionId, {bool isVideo = false}) async {
    currentCallSessionId = callSessionId;
    isCaller = false;
    isVideoCall = isVideo;

    await initSignalR();
    await initLocalStream(isVideo: isVideo);

    try {
      await _hubConnection?.invoke('AcceptCall', args: [callSessionId]);
      debugPrint('🤝 [CallHub]: Đã chấp nhận cuộc gọi (callSessionId: $callSessionId)');
    } catch (e) {
      debugPrint('⚠️ [CallHub]: Lỗi gọi AcceptCall: $e');
    }
  }

  /// 3. Từ chối cuộc gọi (RejectCall)
  Future<void> rejectCall(String callSessionId, {String reason = 'Bận'}) async {
    try {
      await _hubConnection?.invoke('RejectCall', args: [
        {'callSessionId': callSessionId, 'reason': reason}
      ]);
      debugPrint('🚫 [CallHub]: Đã từ chối cuộc gọi: $reason');
    } catch (e) {
      debugPrint('⚠️ [CallHub]: Lỗi gọi RejectCall: $e');
    }
    cleanUp();
  }

  /// 4. Cúp máy / Kết thúc cuộc gọi (EndCall)
  Future<void> endCall(String callSessionId) async {
    try {
      await _hubConnection?.invoke('EndCall', args: [callSessionId]);
      debugPrint('📴 [CallHub]: Đã gửi EndCall cho phiên $callSessionId');
    } catch (e) {
      debugPrint('⚠️ [CallHub]: Lỗi gửi EndCall qua SignalR, gọi REST dự phòng: $e');
      // Gọi REST API dự phòng theo mục 5 trong tài liệu
      await CallApiClient().endCall(callSessionId);
    }
    cleanUp();
  }

  /// Bật/Tắt Microphone
  void setMicrophoneMute(bool mute) {
    if (_localStream != null) {
      for (final track in _localStream!.getAudioTracks()) {
        track.enabled = !mute;
      }
    }
  }

  /// Bật/Tắt Loa ngoài (Speaker)
  Future<void> setSpeakerphoneOn(bool enable) async {
    try {
      await Helper.setSpeakerphoneOn(enable);
    } catch (e) {
      debugPrint('⚠️ [WebRTC]: Không thể đổi trạng thái loa: $e');
    }
  }

  /// Bật/Tắt Camera
  void setCameraEnabled(bool enable) {
    if (_localStream != null) {
      for (final track in _localStream!.getVideoTracks()) {
        track.enabled = enable;
      }
    }
  }

  /// Chuyển đổi Camera trước / sau
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTracks = _localStream!.getVideoTracks();
      if (videoTracks.isNotEmpty) {
        try {
          await Helper.switchCamera(videoTracks[0]);
        } catch (e) {
          debugPrint('⚠️ [WebRTC]: Không thể đổi camera: $e');
        }
      }
    }
  }

  /// Giải phóng tài nguyên WebRTC khi kết thúc cuộc gọi
  void cleanUp() {
    try {
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      _localStream?.dispose();
      _localStream = null;

      _remoteStream?.getTracks().forEach((track) {
        track.stop();
      });
      _remoteStream?.dispose();
      _remoteStream = null;

      _peerConnection?.close();
      _peerConnection?.dispose();
      _peerConnection = null;

      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    } catch (e) {
      debugPrint('⚠️ [WebRTC]: Lỗi khi giải phóng tài nguyên: $e');
    }

    currentCallSessionId = null;
    currentTargetUserId = null;
    _isRemoteDescriptionSet = false;
    _remoteCandidateQueue.clear();
  }

  /// Ngắt hoàn toàn kết nối SignalR và giải phóng toàn bộ Renderers
  Future<void> dispose() async {
    cleanUp();
    if (_hubConnection != null) {
      try {
        await _hubConnection?.stop();
      } catch (_) {}
      _hubConnection = null;
    }
    if (_renderersInitialized) {
      await localRenderer.dispose();
      await remoteRenderer.dispose();
      _renderersInitialized = false;
    }
  }
}
