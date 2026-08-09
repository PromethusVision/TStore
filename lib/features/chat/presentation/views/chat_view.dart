import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/chat/domain/chat_message_rules.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';

typedef ChatCurrentUserIdProvider = String? Function();

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.initialDraft,
    this.chatCubit,
    this.currentUserIdProvider,
  });

  final String receiverId;
  final String receiverName;
  final String? initialDraft;
  final ChatCubit? chatCubit;
  final ChatCurrentUserIdProvider? currentUserIdProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => (chatCubit ?? sl<ChatCubit>())
        ..startListening()
        ..markAllAsRead(receiverId)
        ..getMessages(receiverId, refresh: true),
      child: _ChatViewBody(
        receiverId: receiverId,
        receiverName: receiverName,
        initialDraft: initialDraft,
        currentUserIdProvider: currentUserIdProvider,
      ),
    );
  }
}

class _ChatViewBody extends StatefulWidget {
  const _ChatViewBody({
    required this.receiverId,
    required this.receiverName,
    required this.initialDraft,
    required this.currentUserIdProvider,
  });

  final String receiverId;
  final String receiverName;
  final String? initialDraft;
  final ChatCurrentUserIdProvider? currentUserIdProvider;

  @override
  State<_ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<_ChatViewBody> {
  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageEntity> _messages = [];
  bool _didJumpToInitialMessages = false;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text: ChatMessageRules.limitText(widget.initialDraft?.trim() ?? ''),
    );
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdProvider = widget.currentUserIdProvider;
    final currentUserId = currentUserIdProvider != null
        ? currentUserIdProvider()
        : SupabaseService.instance.currentUser?.id;

    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-chat-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _ChatHeader(receiverName: widget.receiverName),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space8),
                Expanded(
                  child: BlocConsumer<ChatCubit, ChatState>(
                    listener: (context, state) {
                      if (state is ChatLoaded) {
                        _replaceMessages(state.messages);
                        _hasReachedMax = state.hasReachedMax;
                        if (!_didJumpToInitialMessages) {
                          _didJumpToInitialMessages = true;
                          _jumpToBottom();
                        }
                      }

                      if (state is MessageSent) {
                        _messageController.clear();
                        _scrollToBottom();
                      }

                      if (state is NewMessageReceived) {
                        if (state.message.senderId == widget.receiverId) {
                          context.read<ChatCubit>().markAllAsRead(
                            widget.receiverId,
                          );
                        }
                        _scrollToBottom();
                      }

                      if (state is ChatError) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text(state.message)),
                          );
                      }
                    },
                    builder: (context, state) {
                      final isInitialLoading =
                          state is ChatLoading && _messages.isEmpty;
                      final isSending = state is MessageSending;

                      return Column(
                        children: [
                          Expanded(
                            child: isInitialLoading
                                ? const _ChatLoadingState()
                                : _MessageList(
                                    messages: _messages,
                                    currentUserId: currentUserId,
                                    scrollController: _scrollController,
                                    isLoadingMore: _isLoadingMore,
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
              ],
            ),
          ),
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

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.jumpTo(0);
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

  void _handleScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || _hasReachedMax) {
      return;
    }

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0 ||
        position.pixels < position.maxScrollExtent - 160) {
      return;
    }

    unawaited(_loadMoreMessages());
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || _hasReachedMax || !mounted) return;

    setState(() => _isLoadingMore = true);
    try {
      await context.read<ChatCubit>().loadMoreMessages(widget.receiverId);
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.receiverName});

  final String receiverName;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-chat-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('customer-chat-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initialFor(receiverName),
              style: const TextStyle(
                color: CustomerHomeV1Tokens.petrol,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                const Text(
                  'Mağaza ile görüşme',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.cream,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: CustomerHomeV1Tokens.petrol,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-chat-loading-state'),
        margin: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space24,
          vertical: CustomerHomeV1Tokens.space20,
        ),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            ),
            SizedBox(width: CustomerHomeV1Tokens.space12),
            Flexible(
              child: Text(
                'Mesajlar yükleniyor',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.isLoadingMore,
  });

  final List<ChatMessageEntity> messages;
  final String? currentUserId;
  final ScrollController scrollController;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const _EmptyConversationState();
    }

    return Stack(
      children: [
        ListView.builder(
          key: const Key('customer-chat-message-list'),
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.fromLTRB(
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space8,
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space16,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine =
                currentUserId != null && message.senderId == currentUserId;
            final showDateHeader = _shouldShowDateHeader(index);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showDateHeader && message.createdAt != null)
                  _DateHeader(date: message.createdAt!),
                _MessageBubble(message: message, isMine: isMine),
              ],
            );
          },
        ),
        if (isLoadingMore)
          const Positioned(
            top: CustomerHomeV1Tokens.space8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: CustomerHomeV1Tokens.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    key: Key('chat-load-more-progress'),
                    padding: EdgeInsets.all(CustomerHomeV1Tokens.space8),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: CustomerHomeV1Tokens.petrol,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _shouldShowDateHeader(int index) {
    final date = messages[index].createdAt;
    if (date == null) return false;

    if (index == messages.length - 1) return true;

    final previousVisibleDate = messages[index + 1].createdAt;
    if (previousVisibleDate == null) return true;

    return !_isSameDay(date, previousVisibleDate);
  }
}

class _EmptyConversationState extends StatelessWidget {
  const _EmptyConversationState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-chat-empty-state'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: CustomerHomeV1Tokens.mint,
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: CustomerHomeV1Tokens.petrol,
                  size: 28,
                ),
              ),
              SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                'Henüz mesaj yok.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                'Mağazaya ilk mesajını aşağıdaki alandan gönderebilirsin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: CustomerHomeV1Tokens.space12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space12,
          vertical: CustomerHomeV1Tokens.space4,
        ),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.mint,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
        ),
        child: Text(
          _formatFullDate(date),
          style: const TextStyle(
            color: CustomerHomeV1Tokens.petrol,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final maxWidth =
        MediaQuery.sizeOf(context).width.clamp(0, 430).toDouble() * 0.76;
    final backgroundColor = isMine
        ? CustomerHomeV1Tokens.petrol
        : CustomerHomeV1Tokens.surface;
    final textColor = isMine ? Colors.white : CustomerHomeV1Tokens.navy;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: Key('chat-message-${message.id}'),
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: CustomerHomeV1Tokens.space8),
        padding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space12,
          vertical: CustomerHomeV1Tokens.space8,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(CustomerHomeV1Tokens.radius16),
            topRight: const Radius.circular(CustomerHomeV1Tokens.radius16),
            bottomLeft: Radius.circular(
              isMine
                  ? CustomerHomeV1Tokens.radius16
                  : CustomerHomeV1Tokens.space4,
            ),
            bottomRight: Radius.circular(
              isMine
                  ? CustomerHomeV1Tokens.space4
                  : CustomerHomeV1Tokens.radius16,
            ),
          ),
          border: isMine
              ? null
              : Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.content,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (message.createdAt != null) ...[
              const SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                _formatTime(message.createdAt!),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-chat-input-area'),
      padding: const EdgeInsets.fromLTRB(
        CustomerHomeV1Tokens.space12,
        CustomerHomeV1Tokens.space8,
        CustomerHomeV1Tokens.space12,
        CustomerHomeV1Tokens.space12,
      ),
      decoration: const BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        border: Border(top: BorderSide(color: CustomerHomeV1Tokens.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => TextField(
                key: const Key('chat-message-input'),
                controller: controller,
                readOnly: isSending,
                inputFormatters: const [_ChatMessageLengthFormatter()],
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Mesaj yaz',
                  counterText:
                      '${ChatMessageRules.characterCount(value.text)} / '
                      '${ChatMessageRules.maxTextLength}',
                  hintStyle: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 12.5,
                  ),
                  filled: true,
                  fillColor: CustomerHomeV1Tokens.cream,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: CustomerHomeV1Tokens.space16,
                    vertical: CustomerHomeV1Tokens.space12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius20,
                    ),
                    borderSide: const BorderSide(
                      color: CustomerHomeV1Tokens.border,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius20,
                    ),
                    borderSide: const BorderSide(
                      color: CustomerHomeV1Tokens.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius20,
                    ),
                    borderSide: const BorderSide(
                      color: CustomerHomeV1Tokens.petrol,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend =
                  !isSending &&
                  ChatMessageRules.validationError(value.text) == null;

              return SizedBox.square(
                dimension: 46,
                child: IconButton.filled(
                  key: const Key('chat-message-send-action'),
                  tooltip: 'Gönder',
                  onPressed: canSend ? onSend : null,
                  style: IconButton.styleFrom(
                    backgroundColor: CustomerHomeV1Tokens.petrol,
                    disabledBackgroundColor: CustomerHomeV1Tokens.mint,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: CustomerHomeV1Tokens.muted,
                  ),
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: CustomerHomeV1Tokens.petrol,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChatMessageLengthFormatter extends TextInputFormatter {
  const _ChatMessageLengthFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (ChatMessageRules.characterCount(newValue.text) <=
        ChatMessageRules.maxTextLength) {
      return newValue;
    }

    final limitedText = ChatMessageRules.limitText(newValue.text);
    return TextEditingValue(
      text: limitedText,
      selection: TextSelection.collapsed(offset: limitedText.length),
    );
  }
}

String _initialFor(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return 'M';
  return trimmed.substring(0, 1).toUpperCase();
}

String _formatFullDate(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString().padLeft(4, '0');

  return '$day.$month.$year';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

bool _isSameDay(DateTime a, DateTime b) {
  final localA = a.toLocal();
  final localB = b.toLocal();

  return localA.year == localB.year &&
      localA.month == localB.month &&
      localA.day == localB.day;
}
