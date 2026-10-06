import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minichatapp/Feature/calling/data/datasources/calling_remote_datasource.dart';
import 'package:minichatapp/Feature/calling/data/repositories/calling_repository_impl.dart';
import 'package:minichatapp/Feature/calling/domain/entities/call_session.dart';
import 'package:minichatapp/Feature/calling/domain/usecases/calling_usecases.dart';
import 'package:minichatapp/Feature/calling/presentation/bloc/calling_bloc.dart';
import 'package:minichatapp/Feature/calling/presentation/bloc/calling_event.dart';
import 'package:minichatapp/Feature/calling/presentation/bloc/calling_state.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/active_call_view.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/call_declined_view.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/call_no_answer_view.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/incoming_call_view.dart';
import 'package:minichatapp/Feature/calling/presentation/widgets/outgoing_call_view.dart';

/// Calling Screen hosting [CallingBloc] and rendering full-screen call UI
/// for Incoming, Outgoing, Active, and Declined call states.
class CallingPage extends StatelessWidget {
  final CallSession initialSession;

  const CallingPage({
    super.key,
    required this.initialSession,
  });

  /// Factory constructor for incoming call ("Nhận cuộc gọi")
  factory CallingPage.incoming({
    String name = 'Phương Thảo',
    String? avatarUrl,
    CallType type = CallType.audio,
  }) {
    return CallingPage(
      initialSession: CallSession(
        callerName: name,
        callerAvatarUrl: avatarUrl,
        callType: type,
        callStatus: CallStatus.incoming,
      ),
    );
  }

  /// Factory constructor for outgoing call ("Gọi thoại mới" / "Gọi video")
  factory CallingPage.outgoing({
    String name = 'Lan Anh',
    String? avatarUrl,
    CallType type = CallType.audio,
  }) {
    return CallingPage(
      initialSession: CallSession(
        callerName: name,
        callerAvatarUrl: avatarUrl,
        callType: type,
        callStatus: CallStatus.outgoing,
      ),
    );
  }

  /// Factory constructor for active in-progress call ("Kết thúc cuộc gọi")
  factory CallingPage.active({
    String name = 'Lan Anh',
    String? avatarUrl,
    CallType type = CallType.audio,
    int durationSeconds = 52,
  }) {
    return CallingPage(
      initialSession: CallSession(
        callerName: name,
        callerAvatarUrl: avatarUrl,
        callType: type,
        callStatus: CallStatus.active,
        durationSeconds: durationSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteDataSource = CallingRemoteDataSourceImpl();
    final repository = CallingRepositoryImpl(remoteDataSource: remoteDataSource);

    return BlocProvider<CallingBloc>(
      create: (_) => CallingBloc(
        initialSession: initialSession,
        acceptCallUseCase: AcceptCallUseCase(repository: repository),
        declineCallUseCase: DeclineCallUseCase(repository: repository),
        endCallUseCase: EndCallUseCase(repository: repository),
        toggleMuteUseCase: ToggleMuteUseCase(repository: repository),
        toggleSpeakerUseCase: ToggleSpeakerUseCase(repository: repository),
        toggleVideoUseCase: ToggleVideoUseCase(repository: repository),
        switchCameraUseCase: SwitchCameraUseCase(repository: repository),
      ),
      child: const _CallingPageContent(),
    );
  }
}

class _CallingPageContent extends StatelessWidget {
  const _CallingPageContent();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A), // Dark slate
                Color(0xFF1E293B),
                Color(0xFF090D16),
              ],
            ),
          ),
          child: SafeArea(
            child: BlocConsumer<CallingBloc, CallingState>(
              listener: (context, state) {
                if (state.session.callStatus == CallStatus.ended) {
                  Navigator.of(context).maybePop();
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    // Top Minimize / Back button
                    Positioned(
                      top: 12,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),

                    // Main view depending on call status
                    Center(
                      child: _buildBodyForStatus(context, state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyForStatus(BuildContext context, CallingState state) {
    final bloc = context.read<CallingBloc>();
    final session = state.session;

    switch (session.callStatus) {
      case CallStatus.incoming:
        return IncomingCallView(
          session: session,
          onAccept: () => bloc.add(const CallAcceptPressed()),
          onDecline: () => bloc.add(const CallDeclinePressed()),
          onNoAnswer: () => bloc.add(const CallNoAnswerPressed()),
        );

      case CallStatus.outgoing:
        return OutgoingCallView(
          session: session,
          onCancel: () => bloc.add(const CallEndPressed()),
          onSwitchCamera: () => bloc.add(const CallCameraSwitchPressed()),
          onToggleVideo: () => bloc.add(const CallVideoTogglePressed()),
          onAccept: () => bloc.add(const CallAcceptPressed()),
          onNoAnswer: () => bloc.add(const CallNoAnswerPressed()),
          onDecline: () => bloc.add(const CallDeclinePressed()),
        );

      case CallStatus.active:
        return ActiveCallView(
          session: session,
          onToggleMute: () => bloc.add(const CallMuteTogglePressed()),
          onToggleSpeaker: () => bloc.add(const CallSpeakerTogglePressed()),
          onToggleVideo: () => bloc.add(const CallVideoTogglePressed()),
          onEndCall: () => bloc.add(const CallEndPressed()),
          onToggleWeakNetwork: () => bloc.add(const CallWeakNetworkToggled()),
        );

      case CallStatus.declined:
        return CallDeclinedView(
          onDismiss: () => Navigator.of(context).maybePop(),
        );

      case CallStatus.noAnswer:
        return CallNoAnswerView(
          onDismiss: () => Navigator.of(context).maybePop(),
        );

      case CallStatus.ended:
        return const SizedBox.shrink();
    }
  }
}
