import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minichatapp/Feature/common/widgets/app_avatar.dart';
import 'package:minichatapp/l10n/app_localizations.dart';
import '../../../../core/network/signalr_service.dart';
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
  final int? conversationId;
  final String? targetUserId;

  const SendTheDetailsPage({
    super.key,
    this.contactName = 'Người dùng',
    this.isOnline = true,
    this.avatarUrl,
    this.conversationId,
    this.targetUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dataSource = ChatDetailRemoteDataSourceImpl.instance;
        final repository =
            ChatDetailRepositoryImpl(remoteDataSource: dataSource);
        final getMessages = GetMessagesUseCase(repository: repository);
        final sendMessage = SendMessageUseCase(repository: repository);

        return ChatDetailBloc(
          getMessagesUseCase: getMessages,
          sendMessageUseCase: sendMessage,
        )..add(ChatDetailStarted(
            contactName,
            conversationId: conversationId,
            targetUserId: targetUserId,
          ));
      },
      child: _SendTheDetailsView(
        contactName: contactName,
        isOnline: isOnline,
        avatarUrl: avatarUrl,
        conversationId: conversationId,
        targetUserId: targetUserId,
      ),
    );
  }
}

class _SendTheDetailsView extends StatefulWidget {
  final String contactName;
  final bool isOnline;
  final String? avatarUrl;
  final int? conversationId;
  final String? targetUserId;

  const _SendTheDetailsView({
    required this.contactName,
    required this.isOnline,
    this.avatarUrl,
    this.conversationId,
    this.targetUserId,
  });

  @override
  State<_SendTheDetailsView> createState() => _SendTheDetailsViewState();
}

class _SendTheDetailsViewState extends State<_SendTheDetailsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isAttachmentOpen = false;

  int get _convId =>
      widget.conversationId ??
      ((widget.contactName.hashCode & 0x7FFFFFFF) % 100000 + 1);

  @override
  void initState() {
    super.initState();
    // Đảm bảo SignalR đã khởi tạo khi mở màn hình chat
    if (!SignalRService.instance.isConnected) {
      SignalRService.instance.initSignalR();
    }
  }

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
              final targetId = int.tryParse(widget.targetUserId ?? '') ?? widget.conversationId;
              if (targetId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không tìm thấy thông tin định danh người nhận cuộc gọi.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CallingPage.outgoing(
                    name: widget.contactName,
                    avatarUrl: widget.avatarUrl,
                    type: CallType.audio,
                    targetUserId: targetId,
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
              final targetId = int.tryParse(widget.targetUserId ?? '') ?? widget.conversationId;
              if (targetId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không tìm thấy thông tin định danh người nhận cuộc gọi.'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CallingPage.outgoing(
                    name: widget.contactName,
                    avatarUrl: widget.avatarUrl,
                    type: CallType.video,
                    targetUserId: targetId,
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
            child: RefreshIndicator(
              color: const Color(0xFF007DFE),
              backgroundColor: Colors.white,
              onRefresh: () async {
                context.read<ChatDetailBloc>().add(
                      ChatDetailStarted(
                        widget.contactName,
                        conversationId: widget.conversationId,
                        targetUserId: widget.targetUserId,
                      ),
                    );
                await Future.delayed(const Duration(milliseconds: 500));
              },
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
                    // Nếu chưa có tin nhắn nào: hiển thị trạng thái bắt đầu cuộc trò chuyện
                    if (state.messages.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text('👋', style: TextStyle(fontSize: 40)),
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Bắt đầu cuộc trò chuyện',
                                    style: GoogleFonts.nunito(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Gửi tin nhắn đầu tiên cho ${widget.contactName} để bắt đầu trò chuyện realtime!',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
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
                              lang.today,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),

                        // Real Dynamic Messages
                        ...state.messages.map((m) => ChatBubble(message: m)),

                        // Typing indicator: Chỉ hiển thị KHI đối phương đang gõ thật qua SignalR
                        if (state.isContactTyping)
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
          ),

          // 2. Expandable Attachment Panel
          if (_isAttachmentOpen)
            MediaAttachmentPanel(
              onPickImage: () {},
              onPickCamera: () {},
              onPickFile: () {},
              onPickEmoji: () {},
            ),

          // 3. Bottom Input Bar với sự kiện gõ tin nhắn realtime
          ChatInputBar(
            onSend: (text) {
              context.read<ChatDetailBloc>().add(
                    ChatDetailMessageSent(
                      contactName: widget.contactName,
                      text: text,
                      conversationId: widget.conversationId,
                      targetUserId: widget.targetUserId,
                    ),
                  );
              // Báo ngừng soạn tin nhắn khi đã gửi
              SignalRService.instance.sendTyping(_convId, false);
            },
            onTyping: (isTyping) {
              // Báo đang soạn tin nhắn realtime qua SignalR
              SignalRService.instance.sendTyping(_convId, isTyping);
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
