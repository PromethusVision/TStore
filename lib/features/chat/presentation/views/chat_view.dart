import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';

class ChatView extends StatelessWidget {
  final String receiverId;
  final String receiverName;

  const ChatView({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>()
        ..startListening()
        ..markAllAsRead(receiverId)
        ..getMessages(receiverId, refresh: true),
      child: _ChatViewBody(
        receiverId: receiverId,
        receiverName: receiverName,
      ),
    );
  }
}

class _ChatViewBody extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const _ChatViewBody({
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<_ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<_ChatViewBody> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageEntity> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.instance.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: SafeArea(
        child: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is ChatLoaded) {
              _replaceMessages(state.messages);
              _scrollToBottom();
            }

            if (state is MessageSent) {
              _messageController.clear();
              _scrollToBottom();
            }

            if (state is NewMessageReceived) {
              _scrollToBottom();
            }

            if (state is ChatError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            final isInitialLoading = state is ChatLoading && _messages.isEmpty;
            final isSending = state is MessageSending;

            return Column(
              children: [
                Expanded(
                  child: isInitialLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _MessageList(
                          messages: _messages,
                          currentUserId: currentUserId,
                          scrollController: _scrollController,
                        ),
                ),
                _MessageInput(
                  controller: _messageController,
                  isSending: isSending,
                  onSend: () => _sendMessage(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _replaceMessages(List<ChatMessageEntity> messages) {
    _messages
      ..clear()
      ..addAll(messages);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage(BuildContext context) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatCubit>().sendMessage(
          receiverId: widget.receiverId,
          content: content,
        );
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessageEntity> messages;
  final String? currentUserId;
  final ScrollController scrollController;

  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Text('Henüz mesaj yok.'),
      );
    }

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMine =
            currentUserId != null && message.senderId == currentUserId;

        return _MessageBubble(
          message: message,
          isMine: isMine,
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMine;

  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMine
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;
    final textColor = isMine
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(color: textColor),
            ),
            if (message.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatMessageTime(message.createdAt!),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withOpacity(0.72),
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText: 'Mesaj yaz',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
