import 'package:flutter_test/flutter_test.dart';
import 'package:minichatapp/Feature/calling/data/datasources/calling_remote_datasource.dart';
import 'package:minichatapp/Feature/calling/data/repositories/calling_repository_impl.dart';
import 'package:minichatapp/Feature/calling/data/services/call_audio_service.dart';
import 'package:minichatapp/Feature/calling/domain/entities/call_session.dart';
import 'package:minichatapp/Feature/calling/domain/usecases/calling_usecases.dart';
import 'package:minichatapp/Feature/calling/presentation/bloc/calling_bloc.dart';
import 'package:minichatapp/Feature/calling/presentation/bloc/calling_event.dart';
import 'package:minichatapp/Feature/common/constants/audio_assets.dart';

/// Mock triển khai [CallAudioService] để kiểm thử mà không cần phần cứng âm thanh
class MockCallAudioService implements CallAudioService {
  bool playedIncoming = false;
  bool playedOutgoing = false;
  bool playedNoAnswer = false;
  bool playedDeclined = false;
  bool playedWeakNetwork = false;
  bool stopped = false;
  bool disposed = false;

  @override
  Future<void> playIncoming() async {
    playedIncoming = true;
  }

  @override
  Future<void> playOutgoing() async {
    playedOutgoing = true;
  }

  @override
  Future<void> playNoAnswer() async {
    playedNoAnswer = true;
  }

  @override
  Future<void> playDeclined() async {
    playedDeclined = true;
  }

  @override
  Future<void> playWeakNetwork() async {
    playedWeakNetwork = true;
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CallingRepositoryImpl repository;
  late MockCallAudioService mockAudio;

  setUp(() {
    final remoteDataSource = CallingRemoteDataSourceImpl();
    repository = CallingRepositoryImpl(remoteDataSource: remoteDataSource);
    mockAudio = MockCallAudioService();
  });

  group('CallingBloc & Audio Tests', () {
    test('Kiểm tra hằng số đường dẫn âm thanh AudioAssets', () {
      expect(AudioAssets.nhacChuongDen, equals('audio/nhacchuongden.mp3'));
      expect(AudioAssets.nhacChuongDi, equals('audio/nhacchuongdi.mp3'));
      expect(AudioAssets.khongNgheMay, equals('audio/khongnghemay.mp3'));
      expect(AudioAssets.amThanhKhongTraLoiDienThoai,
          equals('audio/amthanhkhongtraloidienthoai.mp3'));
      expect(AudioAssets.mangYeu, equals('audio/mangyeu.mp3'));
    });

    test('Cuộc gọi đến tự động phát nhacchuongden', () async {
      final session = const CallSession(
        callerName: 'Phương Thảo',
        callStatus: CallStatus.incoming,
      );

      final bloc = CallingBloc(
        initialSession: session,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
        audioService: mockAudio,
      );

      expect(mockAudio.playedIncoming, isTrue);
      await bloc.close();
      expect(mockAudio.stopped, isTrue);
    });

    test('Cuộc gọi đi tự động phát nhacchuongdi', () async {
      final session = const CallSession(
        callerName: 'Lan Anh',
        callStatus: CallStatus.outgoing,
      );

      final bloc = CallingBloc(
        initialSession: session,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
        audioService: mockAudio,
      );

      expect(mockAudio.playedOutgoing, isTrue);
      await bloc.close();
    });

    test('Từ chối cuộc gọi phát amthanhkhongtraloidienthoai', () async {
      final session = const CallSession(
        callerName: 'Phương Thảo',
        callStatus: CallStatus.incoming,
      );

      final bloc = CallingBloc(
        initialSession: session,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
        audioService: mockAudio,
      );

      bloc.add(const CallDeclinePressed());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.session.callStatus, equals(CallStatus.declined));
      expect(mockAudio.playedDeclined, isTrue);
      await bloc.close();
    });

    test('Không nghe máy phát khongnghemay', () async {
      final session = const CallSession(
        callerName: 'Lan Anh',
        callStatus: CallStatus.outgoing,
      );

      final bloc = CallingBloc(
        initialSession: session,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
        audioService: mockAudio,
      );

      bloc.add(const CallNoAnswerPressed());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.session.callStatus, equals(CallStatus.noAnswer));
      expect(mockAudio.playedNoAnswer, isTrue);
      await bloc.close();
    });

    test('Kích hoạt mạng yếu phát mangyeu', () async {
      final session = const CallSession(
        callerName: 'Lan Anh',
        callStatus: CallStatus.active,
      );

      final bloc = CallingBloc(
        initialSession: session,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
        audioService: mockAudio,
      );

      expect(bloc.state.session.isWeakNetwork, isFalse);

      bloc.add(const CallWeakNetworkToggled());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(bloc.state.session.isWeakNetwork, isTrue);
      expect(mockAudio.playedWeakNetwork, isTrue);
      await bloc.close();
    });
  });
}
