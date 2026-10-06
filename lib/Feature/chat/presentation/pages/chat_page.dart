import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_search_bar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../sendthedetails/presentation/pages/send_the_details_page.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/usecases/chat_usecases.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_tile.dart';

/// Clean Architecture & BLoC Chat Screen.
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

class _ChatView extends StatelessWidget {
  const _ChatView();

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
                        onPressed: () {},
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

            // 3. Chat Conversations List with BlocBuilder
            Expanded(
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
                      return Center(
                        child: Text(
                          lang.noChatsFound,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: chats.length,
                      separatorBuilder: (context, index) => const Padding(
                        padding: EdgeInsets.only(left: 82.0, right: 16.0),
                        child: Divider(
                          height: 1,
                          thickness: 0.7,
                          color: Color(0xFFF1F5F9),
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return ChatTile(
                          chat: chat,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SendTheDetailsPage(
                                  contactName: chat.name,
                                  isOnline: chat.isOnline,
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
          ],
        ),
      ),
    );
  }
}
