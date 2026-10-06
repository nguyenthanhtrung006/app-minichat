import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../calling/domain/entities/call_session.dart';
import '../../../calling/presentation/pages/calling_page.dart';
import '../../data/datasources/chat_detail_remote_datasource.dart';
import '../../data/repositories/chat_detail_repository_impl.dart';
import '../../domain/usecases/chat_detail_usecases.dart';
import '../bloc/chat_detail_bloc.dart';
import '../bloc/chat_detail_event.dart';
import '../bloc/chat_detail_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/media_attachment_panel.dart';

/// Clean Architecture & BLoC Chat Detail Screen ("sendthedetails").
class SendTheDetailsPage extends StatelessWidget {
  final String contactName;
  final bool isOnline;
  final String? avatarUrl;

  const SendTheDetailsPage({
    super.key,
    this.contactName = 'Nguyễn Văn Nam',
    this.isOnline = true,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = ChatDetailRemoteDataSourceImpl();
        final repository =
            ChatDetailRepositoryImpl(remoteDataSource: dataSource);
        final getMessages = GetMessagesUseCase(repository: repository);
        final sendMessage = SendMessageUseCase(repository: repository);

        return ChatDetailBloc(
          getMessagesUseCase: getMessages,
          sendMessageUseCase: sendMessage,
        )..add(ChatDetailStarted(contactName));
      },
      child: _SendTheDetailsView(
        contactName: contactName,
        isOnline: isOnline,
        avatarUrl: avatarUrl,
      ),
    );
  }
}

class _SendTheDetailsView extends StatefulWidget {
  final String contactName;
  final bool isOnline;
  final String? avatarUrl;

  const _SendTheDetailsView({
    required this.contactName,
    required this.isOnline,
    this.avatarUrl,
  });

  @override
  State<_SendTheDetailsView> createState() => _SendTheDetailsViewState();
}

class _SendTheDetailsViewState extends State<_SendTheDetailsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isAttachmentOpen = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF007DFE),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            AppAvatar(
              name: widget.contactName,
              size: 40,
              isOnline: widget.isOnline,
              imageUrl: widget.avatarUrl,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contactName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    widget.isOnline ? lang.online : lang.offline,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: widget.isOnline
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CallingPage.outgoing(
                    name: widget.contactName,
                    avatarUrl: widget.avatarUrl,
                    type: CallType.audio,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.call_rounded,
              color: Color(0xFF007DFE),
              size: 22,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CallingPage.outgoing(
                    name: widget.contactName,
                    avatarUrl: widget.avatarUrl,
                    type: CallType.video,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.videocam_rounded,
              color: Color(0xFF007DFE),
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF007DFE),
              size: 22,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Chat Messages List with BlocConsumer
          Expanded(
            child: BlocConsumer<ChatDetailBloc, ChatDetailState>(
              listener: (context, state) {
                if (state is ChatDetailLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatDetailLoading || state is ChatDetailInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF007DFE),
                    ),
                  );
                }

                if (state is ChatDetailError) {
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

                if (state is ChatDetailLoaded) {
                  return ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      // Date separator chip
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${lang.today} 09:15',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),

                      // Messages
                      ...state.messages.map((m) => ChatBubble(message: m)),

                      // Typing indicator
                      TypingIndicatorBubble(
                        senderName: widget.contactName,
                        avatarUrl: widget.avatarUrl,
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // 2. Expandable Attachment Panel
          if (_isAttachmentOpen)
            MediaAttachmentPanel(
              onPickImage: () {},
              onPickCamera: () {},
              onPickFile: () {},
              onPickEmoji: () {},
            ),

          // 3. Bottom Input Bar
          ChatInputBar(
            onSend: (text) {
              context.read<ChatDetailBloc>().add(
                    ChatDetailMessageSent(
                      contactName: widget.contactName,
                      text: text,
                    ),
                  );
            },
            isAttachmentOpen: _isAttachmentOpen,
            onToggleAttachment: () {
              setState(() => _isAttachmentOpen = !_isAttachmentOpen);
            },
          ),
        ],
      ),
    );
  }
}
