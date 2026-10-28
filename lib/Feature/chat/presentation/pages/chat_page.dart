import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_search_bar.dart';
import 'package:minichatapp/Feature/qr/presentation/pages/qr_scanner_page.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../sendthedetails/presentation/pages/send_the_details_page.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_tile.dart';

/// Clean Architecture & BLoC Chat Screen với Pull-to-Refresh & Load More.
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = ChatRemoteDataSourceImpl();
        final repository = ChatRepositoryImpl(remoteDataSource: dataSource);
        final getChats = GetChatsUseCase(repository: repository);
        final searchChats = SearchChatsUseCase(repository: repository);

        return ChatBloc(
          getChatsUseCase: getChats,
          searchChatsUseCase: searchChats,
        )..add(const ChatStarted());
      },
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
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
      context.read<ChatBloc>().add(const ChatLoadMore());
    }
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
            // 1. Top Header with Title and Action Icons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang.chatsTitle,
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QrScannerPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit_square,
                          color: Color(0xFF007DFE),
                          size: 24,
                        ),
                        splashRadius: 22,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Reusable Capsule Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppSearchBar(
                hintText: lang.searchChats,
                onChanged: (val) {
                  context.read<ChatBloc>().add(ChatSearchChanged(val));
                },
              ),
            ),
            const SizedBox(height: 10),

            // 3. Chat Conversations List with RefreshIndicator & Load More
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF007DFE),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  context.read<ChatBloc>().add(const ChatRefreshed());
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoading || state is ChatInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF007DFE),
                        ),
                      );
                    }

                    if (state is ChatError) {
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

                    if (state is ChatLoaded) {
                      final chats = state.filteredChats;
                      if (chats.isEmpty) {
                        if (state.searchQuery.isNotEmpty) {
                          return ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                              Center(
                                child: Text(
                                  lang.noChatsFound,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.12),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 76,
                                      height: 76,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFEFF6FF),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Color(0xFF007DFE),
                                        size: 38,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      'Chưa có cuộc trò chuyện nào',
                                      style: GoogleFonts.nunito(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kết bạn hoặc quét mã QR để bắt đầu gửi tin nhắn trực tiếp realtime!',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => const QrScannerPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                      label: Text(
                                        'Quét mã QR kết bạn',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF007DFE),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: chats.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) {
                          if (index >= chats.length) return const SizedBox.shrink();
                          return const Padding(
                            padding: EdgeInsets.only(left: 82.0, right: 16.0),
                            child: Divider(
                              height: 1,
                              thickness: 0.7,
                              color: Color(0xFFF1F5F9),
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          if (index == chats.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF007DFE),
                                  ),
                                ),
                              ),
                            );
                          }

                          final chat = chats[index];
                          return ChatTile(
                            chat: chat,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SendTheDetailsPage(
                                    contactName: chat.name,
                                    isOnline: chat.isOnline,
                                    avatarUrl: chat.avatarUrl,
                                    targetUserId: chat.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
