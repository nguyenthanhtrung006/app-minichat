import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/Feature/common/widgets/app_section_header.dart';
import 'package:minichatapp/Feature/friend/data/datasources/friend_remote_datasource.dart';
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

/// Clean Architecture & BLoC Calls Screen với Pull-to-Refresh & Load More (Phân trang).
class CallPage extends StatelessWidget {
  final CallRemoteDataSource? remoteDataSource;

  const CallPage({super.key, this.remoteDataSource});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = remoteDataSource ?? CallRemoteDataSourceImpl();
        final repository = CallRepositoryImpl(remoteDataSource: dataSource);
        final getHistory = GetCallHistoryUseCase(repository: repository);

        return CallBloc(getCallHistoryUseCase: getHistory)
          ..add(const CallStarted());
      },
      child: const _CallView(),
    );
  }
}

class _CallView extends StatefulWidget {
  const _CallView();

  @override
  State<_CallView> createState() => _CallViewState();
}

class _CallViewState extends State<_CallView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 50) {
      context.read<CallBloc>().add(const CallLoadMore());
    }
  }

  Future<void> _showFriendPicker(BuildContext context, {required bool isVideo}) async {
    final friends = await FriendRemoteDataSourceImpl.instance.getFriends();
    if (!mounted) return;

    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa có bạn bè trong danh bạ để thực hiện cuộc gọi.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: const Color(0xFF007DFE),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isVideo ? 'Chọn bạn để gọi video' : 'Chọn bạn để gọi thoại',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                  itemBuilder: (_, index) {
                    final friend = friends[index];
                    final targetId = int.tryParse(friend.id);
                    return ListTile(
                      leading: AppAvatar(
                        name: friend.name,
                        imageUrl: friend.avatarUrl,
                        size: 44,
                      ),
                      title: Text(
                        friend.name,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      subtitle: Text(
                        friend.isOnline ? 'Đang hoạt động' : 'Offline',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: friend.isOnline
                              ? const Color(0xFF10B981)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      trailing: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        color: const Color(0xFF007DFE),
                      ),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CallingPage.outgoing(
                              name: friend.name,
                              avatarUrl: friend.avatarUrl,
                              type: isVideo ? CallType.video : CallType.audio,
                              targetUserId: targetId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

            // 2. Body List with RefreshIndicator & Load More
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF007DFE),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<CallBloc>().add(const CallRefreshed());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
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
                            onTap: () => _showFriendPicker(context, isVideo: false),
                          ),
                          const SizedBox(width: 14),
                          CallActionCard(
                            icon: Icons.videocam_rounded,
                            title: lang.videoCall,
                            subtitle: lang.freeVideoCall,
                            onTap: () => _showFriendPicker(context, isVideo: true),
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
                          if (state.calls.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 40.0,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF007DFE).withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.phone_in_talk_rounded,
                                        size: 40,
                                        color: Color(0xFF007DFE),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Chưa có lịch sử cuộc gọi',
                                      style: GoogleFonts.nunito(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Các cuộc gọi thoại và video sẽ xuất hiện tại đây',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              ...state.calls.map(
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
                                          targetUserId: call.targetUserId,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Load More Spinner at the bottom
                              if (state.isLoadingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF007DFE),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
