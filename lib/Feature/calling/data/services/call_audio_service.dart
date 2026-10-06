import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:minichatapp/Feature/common/constants/audio_assets.dart';

/// Service quản lý phát âm thanh cho tính năng cuộc gọi
abstract class CallAudioService {
  /// Phát nhạc chuông cuộc gọi đến (lặp lại)
  Future<void> playIncoming();

  /// Phát nhạc chờ cuộc gọi đi (lặp lại)
  Future<void> playOutgoing();

  /// Phát âm thanh thông báo người nhận không nghe máy (phát một lần)
  Future<void> playNoAnswer();

  /// Phát âm thanh khi cuộc gọi bị từ chối / không trả lời (phát một lần)
  Future<void> playDeclined();

  /// Phát âm thanh cảnh báo tín hiệu mạng yếu / chập chờn (phát một lần)
  Future<void> playWeakNetwork();

  /// Dừng mọi âm thanh đang phát
  Future<void> stop();

  /// Giải phóng tài nguyên AudioPlayer
  Future<void> dispose();
}

/// Triển khai thực tế của [CallAudioService] sử dụng thư viện [audioplayers]
class CallAudioServiceImpl implements CallAudioService {
  AudioPlayer? _player;
  bool _isDisposed = false;

  AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  @override
  Future<void> playIncoming() async {
    if (_isDisposed) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(AudioAssets.nhacChuongDen));
    } catch (e) {
      debugPrint('[CallAudioService] Error playing incoming ringtone: $e');
    }
  }

  @override
  Future<void> playOutgoing() async {
    if (_isDisposed) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(AssetSource(AudioAssets.nhacChuongDi));
    } catch (e) {
      debugPrint('[CallAudioService] Error playing outgoing ringtone: $e');
    }
  }

  @override
  Future<void> playNoAnswer() async {
    if (_isDisposed) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(AudioAssets.khongNgheMay));
    } catch (e) {
      debugPrint('[CallAudioService] Error playing no-answer audio: $e');
    }
  }

  @override
  Future<void> playDeclined() async {
    if (_isDisposed) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(AudioAssets.amThanhKhongTraLoiDienThoai));
    } catch (e) {
      debugPrint('[CallAudioService] Error playing declined audio: $e');
    }
  }

  @override
  Future<void> playWeakNetwork() async {
    if (_isDisposed) return;
    try {
      final player = _audioPlayer;
      await player.stop();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(AssetSource(AudioAssets.mangYeu));
    } catch (e) {
      debugPrint('[CallAudioService] Error playing weak network audio: $e');
    }
  }

  @override
  Future<void> stop() async {
    if (_isDisposed) return;
    try {
      if (_player != null) {
        await _player!.stop();
      }
    } catch (e) {
      debugPrint('[CallAudioService] Error stopping audio: $e');
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    try {
      if (_player != null) {
        await _player!.stop();
        await _player!.dispose();
        _player = null;
      }
    } catch (e) {
      debugPrint('[CallAudioService] Error disposing audio: $e');
    }
  }
}
