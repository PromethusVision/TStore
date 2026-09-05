import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/chat/domain/chat_message_rules.dart';
import 'package:t_store/features/chat/domain/entities/chat_message_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_state.dart';

part 'chat_final_ui.dart';

typedef ChatCurrentUserIdProvider = String? Function();

class ChatView extends StatelessWidget {
  const ChatView({
    super.key,
    required this.receiverId,
    required this.receiverName,
    this.initialDraft,
    this.chatCubit,
    this.currentUserIdProvider,
    this.autoRefreshInterval = const Duration(seconds: 15),
  });

  final String receiverId;
  final String receiverName;
  final String? initialDraft;
  final ChatCubit? chatCubit;
  final ChatCurrentUserIdProvider? currentUserIdProvider;
  final Duration autoRefreshInterval;

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
        autoRefreshInterval: autoRefreshInterval,
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
    required this.autoRefreshInterval,
  });

  final String receiverId;
  final String receiverName;
  final String? initialDraft;
  final ChatCurrentUserIdProvider? currentUserIdProvider;
  final Duration autoRefreshInterval;

  @override
  State<_ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<_ChatViewBody>
    with WidgetsBindingObserver {
  late final TextEditingController _messageController;
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageEntity> _messages = [];
  Timer? _autoRefreshTimer;
  bool _didJumpToInitialMessages = false;
  bool _hasCompletedInitialLoad = false;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _messageController = TextEditingController(
      text: ChatMessageRules.limitText(widget.initialDraft?.trim() ?? ''),
    );
    _scrollController.addListener(_handleScroll);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    WidgetsBinding.instance.removeObserver(this);
    _messageController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshAndRestart());
      return;
    }

    _stopAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdProvider = widget.currentUserIdProvider;
    final currentUserId = currentUserIdProvider != null
        ? currentUserIdProvider()
        : SupabaseService.instance.currentUser?.id;

    return Scaffold(
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-chat-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xs,
                    EsnaftaVarSpacing.md,
                    0,
                  ),
                  child: _ChatFinalHeader(receiverName: widget.receiverName),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xs),
                Expanded(
                  child: BlocConsumer<ChatCubit, ChatState>(
                    listener: (context, state) {
                      if (state is ChatLoaded) {
                        _replaceMessages(state.messages);
                        _hasCompletedInitialLoad = true;
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
                        final isInitialLoadError =
                            !_hasCompletedInitialLoad && _messages.isEmpty;
                        if (!isInitialLoadError) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is ChatLoaded) {
                        _hasCompletedInitialLoad = true;
                      }

                      final isInitialLoading =
                          state is ChatLoading && _messages.isEmpty;
                      final isInitialLoadError =
                          state is ChatError &&
                          !_hasCompletedInitialLoad &&
                          _messages.isEmpty;
                      final isSending =
                          state is MessageSending ||
                          (state is ChatLoaded && state.isSending);

                      return Column(
                        children: [
                          Expanded(
                            child: isInitialLoading
                                ? const _ChatLoadingState()
                                : isInitialLoadError
                                ? _ChatLoadErrorState(
                                    message: state.message,
                                    onRetry: () => unawaited(
                                      context.read<ChatCubit>().getMessages(
                                        widget.receiverId,
                                        refresh: true,
                                      ),
                                    ),
                                  )
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
                            isEnabled: !isInitialLoading && !isInitialLoadError,
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

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      if (!mounted) return;
      unawaited(
        context.read<ChatCubit>().refreshMessagesSilently(widget.receiverId),
      );
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  Future<void> _refreshAndRestart() async {
    _stopAutoRefresh();
    if (!mounted) return;

    await context.read<ChatCubit>().refreshMessagesSilently(widget.receiverId);
    if (!mounted) return;

    _startAutoRefresh();
  }
}

class _ChatLoadingState extends StatelessWidget {
  const _ChatLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-chat-loading-state'),
        margin: const EdgeInsets.all(EsnaftaVarSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: EsnaftaVarSpacing.xl,
          vertical: EsnaftaVarSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
          boxShadow: EsnaftaVarElevation.xs,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: EsnaftaVarColors.primary,
              ),
            ),
            SizedBox(width: EsnaftaVarSpacing.sm),
            Flexible(
              child: Text(
                'Mesajlar yükleniyor',
                style: TextStyle(
                  color: EsnaftaVarColors.textPrimary,
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

class _ChatLoadErrorState extends StatelessWidget {
  const _ChatLoadErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EsnaftaVarStateCard(
            key: const Key('customer-chat-load-error-state'),
            icon: Icons.cloud_off_rounded,
            title: 'Mesajlar yüklenemedi',
            message: message,
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          FilledButton.icon(
            key: const Key('customer-chat-load-retry-action'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tekrar dene'),
          ),
        ],
      ),
    ),
  );
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
        Align(
          alignment: Alignment.topCenter,
          child: ListView.builder(
            shrinkWrap: true,
            key: const Key('customer-chat-message-list'),
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.fromLTRB(
              EsnaftaVarSpacing.md,
              EsnaftaVarSpacing.xs,
              EsnaftaVarSpacing.md,
              EsnaftaVarSpacing.md,
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
                    _ChatFinalDate(date: message.createdAt!),
                  _MessageBubble(message: message, isMine: isMine),
                ],
              );
            },
          ),
        ),
        if (isLoadingMore)
          const Positioned(
            top: EsnaftaVarSpacing.xs,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: EsnaftaVarColors.surface,
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
                    padding: EdgeInsets.all(EsnaftaVarSpacing.xs),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: EsnaftaVarColors.primary,
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
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: const EsnaftaVarStateCard(
        key: Key('customer-chat-empty-state'),
        icon: Icons.chat_bubble_outline_rounded,
        title: 'Henüz mesaj yok.',
        message: 'Mağazaya ilk mesajını aşağıdaki alandan gönderebilirsin.',
      ),
    ),
  );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessageEntity message;
  final bool isMine;

  @override
  Widget build(BuildContext context) => _buildChatFinalBubble(this, context);
}

class _MessageInput extends StatelessWidget {
  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.isEnabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isEnabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-chat-input-area'),
      padding: const EdgeInsets.fromLTRB(
        EsnaftaVarSpacing.sm,
        EsnaftaVarSpacing.xs,
        EsnaftaVarSpacing.sm,
        EsnaftaVarSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: EsnaftaVarColors.surface,
        border: Border(top: BorderSide(color: EsnaftaVarColors.borderDefault)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => TextField(
                key: const Key('chat-message-input'),
                controller: controller,
                readOnly: isSending || !isEnabled,
                inputFormatters: const [_ChatMessageLengthFormatter()],
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Mesaj yaz',
                  counterText:
                      '${ChatMessageRules.characterCount(value.text)} / '
                      '${ChatMessageRules.maxTextLength}',
                  hintStyle: const TextStyle(
                    color: EsnaftaVarColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  filled: true,
                  fillColor: EsnaftaVarColors.surfaceAlt,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: EsnaftaVarSpacing.md,
                    vertical: EsnaftaVarSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                    borderSide: const BorderSide(
                      color: EsnaftaVarColors.borderDefault,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                    borderSide: const BorderSide(
                      color: EsnaftaVarColors.borderDefault,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
                    borderSide: const BorderSide(
                      color: EsnaftaVarColors.primary,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final canSend =
                  isEnabled &&
                  !isSending &&
                  ChatMessageRules.validationError(value.text) == null;

              return SizedBox.square(
                dimension: EsnaftaVarTouchTargets.preferred,
                child: IconButton.filled(
                  key: const Key('chat-message-send-action'),
                  tooltip: 'Gönder',
                  onPressed: canSend ? onSend : null,
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        EsnaftaVarRadii.medium,
                      ),
                    ),
                    backgroundColor: EsnaftaVarColors.primary,
                    disabledBackgroundColor: EsnaftaVarColors.primarySoft,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: EsnaftaVarColors.textSecondary,
                  ),
                  icon: isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: EsnaftaVarColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: canSend
                              ? EsnaftaVarColors.textOnPrimary
                              : EsnaftaVarColors.textMuted,
                        ),
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
