import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_section_header.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../calling/domain/entities/call_session.dart';
import '../../../calling/presentation/pages/calling_page.dart';
import '../../data/datasources/call_remote_datasource.dart';
import '../../data/repositories/call_repository_impl.dart';
import '../../domain/usecases/get_call_history_usecase.dart';
import '../bloc/call_bloc.dart';
import '../bloc/call_event.dart';
import '../bloc/call_state.dart';
import '../widgets/call_action_card.dart';
import '../widgets/call_history_tile.dart';

/// Clean Architecture & BLoC Calls Screen.
class CallPage extends StatelessWidget {
  const CallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = CallRemoteDataSourceImpl();
        final repository = CallRepositoryImpl(remoteDataSource: dataSource);
        final getHistory = GetCallHistoryUseCase(repository: repository);

        return CallBloc(getCallHistoryUseCase: getHistory)
          ..add(const CallStarted());
      },
      child: const _CallView(),
    );
  }
}

class _CallView extends StatelessWidget {
  const _CallView();

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.callTitle,
                    style: GoogleFonts.nunito(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: 0.2,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF007DFE),
                          size: 26,
                        ),
                        splashRadius: 22,
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: Color(0xFF007DFE),
                          size: 24,
                        ),
                        splashRadius: 22,
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CallingPage.incoming(
                                name: 'Phương Thảo',
                                type: CallType.audio,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.ring_volume_rounded,
                          color: Color(0xFF007DFE),
                          size: 24,
                        ),
                        tooltip: '${lang.incomingCallFrom} (Phương Thảo)',
                        splashRadius: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Body List with BlocBuilder
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // Quick Action Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 6.0,
                    ),
                    child: Row(
                      children: [
                        CallActionCard(
                          icon: Icons.call_rounded,
                          title: lang.voiceCall,
                          subtitle: lang.callFriends,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CallingPage.outgoing(
                                  name: 'Lan Anh',
                                  type: CallType.audio,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 14),
                        CallActionCard(
                          icon: Icons.videocam_rounded,
                          title: lang.videoCall,
                          subtitle: lang.freeVideoCall,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CallingPage.outgoing(
                                  name: 'Minh Hoàng',
                                  type: CallType.video,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Section Title: "Gần đây"
                  AppSectionHeader(
                    title: lang.recentCalls,
                  ),

                  // Call logs from Bloc
                  BlocBuilder<CallBloc, CallState>(
                    builder: (context, state) {
                      if (state is CallLoading || state is CallInitial) {
                        return const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF007DFE),
                            ),
                          ),
                        );
                      }

                      if (state is CallError) {
                        return Center(
                          child: Text(
                            state.message,
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }

                      if (state is CallLoaded) {
                        return Column(
                          children: state.calls
                              .map(
                                (call) => CallHistoryTile(
                                  call: call,
                                  onCall: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CallingPage.outgoing(
                                          name: call.name,
                                          avatarUrl: call.avatarUrl,
                                          type: call.isVideo
                                              ? CallType.video
                                              : CallType.audio,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
