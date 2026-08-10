import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';

typedef ConversationDestinationBuilder =
    Widget Function(ChatThreadEntity thread);

class ConversationsView extends StatelessWidget {
  const ConversationsView({
    super.key,
    this.conversationsCubit,
    this.autoRefreshInterval = const Duration(seconds: 15),
    this.destinationBuilder,
  });

  final ChatConversationsCubit? conversationsCubit;
  final Duration autoRefreshInterval;
  final ConversationDestinationBuilder? destinationBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (conversationsCubit ?? sl<ChatConversationsCubit>())
            ..loadConversations(),
      child: _ConversationsViewBody(
        autoRefreshInterval: autoRefreshInterval,
        destinationBuilder: destinationBuilder,
      ),
    );
  }
}

class _ConversationsViewBody extends StatefulWidget {
  const _ConversationsViewBody({
    required this.autoRefreshInterval,
    required this.destinationBuilder,
  });

  final Duration autoRefreshInterval;
  final ConversationDestinationBuilder? destinationBuilder;

  @override
  State<_ConversationsViewBody> createState() => _ConversationsViewBodyState();
}

class _ConversationsViewBodyState extends State<_ConversationsViewBody>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  bool _isOpeningConversation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    WidgetsBinding.instance.removeObserver(this);
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
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-conversations-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _ConversationsHeader(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
                  child:
                      BlocBuilder<
                        ChatConversationsCubit,
                        ChatConversationsState
                      >(
                        builder: (context, state) {
                          if (state is ChatConversationsInitial ||
                              state is ChatConversationsLoading) {
                            return const _ConversationsLoadingState();
                          }

                          if (state is ChatConversationsError) {
                            return _ConversationStatus(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Mesajların yüklenemedi',
                              description: state.message,
                              actionLabel: 'Tekrar Dene',
                              onRefresh: () => context
                                  .read<ChatConversationsCubit>()
                                  .refreshConversations(),
                            );
                          }

                          if (state is ChatConversationsLoaded) {
                            if (state.threads.isEmpty) {
                              return _ConversationStatus(
                                icon: Icons.forum_outlined,
                                title: 'Henüz mesajınız yok.',
                                description:
                                    'Esnafa gönderdiğin mesajlar ve yanıtları burada görünecek.',
                                actionLabel: 'Yenile',
                                onRefresh: () => context
                                    .read<ChatConversationsCubit>()
                                    .refreshConversations(),
                              );
                            }

                            return RefreshIndicator(
                              color: CustomerHomeV1Tokens.petrol,
                              onRefresh: () => context
                                  .read<ChatConversationsCubit>()
                                  .refreshConversations(),
                              child: ListView.separated(
                                key: const Key('customer-conversations-list'),
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  CustomerHomeV1Tokens.space16,
                                  CustomerHomeV1Tokens.space4,
                                  CustomerHomeV1Tokens.space16,
                                  CustomerHomeV1Tokens.space24,
                                ),
                                itemCount: state.threads.length,
                                separatorBuilder: (_, _) => const SizedBox(
                                  height: CustomerHomeV1Tokens.space12,
                                ),
                                itemBuilder: (context, index) {
                                  final thread = state.threads[index];
                                  return _ConversationCard(
                                    thread: thread,
                                    onTap: () => _openConversation(thread),
                                  );
                                },
                              ),
                            );
                          }

                          return const _ConversationsLoadingState();
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

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
      if (!mounted) return;
      unawaited(
        context.read<ChatConversationsCubit>().refreshConversationsSilently(),
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

    await context.read<ChatConversationsCubit>().refreshConversationsSilently();
    if (!mounted) return;

    _startAutoRefresh();
  }

  Future<void> _openConversation(ChatThreadEntity thread) async {
    if (_isOpeningConversation) return;

    _isOpeningConversation = true;
    _stopAutoRefresh();

    try {
      final destination =
          widget.destinationBuilder?.call(thread) ??
          ChatView(
            receiverId: thread.otherUserId,
            receiverName: thread.displayName,
          );
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: (_) => destination));
    } finally {
      try {
        if (mounted) {
          await _refreshAndRestart();
        }
      } finally {
        _isOpeningConversation = false;
      }
    }
  }
}

class _ConversationsHeader extends StatelessWidget {
  const _ConversationsHeader();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatConversationsCubit, ChatConversationsState>(
      builder: (context, state) {
        final unreadCount = state is ChatConversationsLoaded
            ? state.threads.fold<int>(
                0,
                (total, thread) => total + thread.unreadCount,
              )
            : 0;

        return Container(
          key: const Key('customer-conversations-header'),
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
                  key: const Key('customer-conversations-back-button'),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mesajlarım',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      unreadCount > 0
                          ? '$unreadCount okunmamış mesaj'
                          : 'Esnafla görüşmelerini takip et',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: unreadCount > 0
                      ? const Color(0xFFFFE4DE)
                      : CustomerHomeV1Tokens.mint,
                  borderRadius: BorderRadius.circular(
                    CustomerHomeV1Tokens.radius12,
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: unreadCount > 0
                            ? CustomerHomeV1Tokens.coral
                            : CustomerHomeV1Tokens.petrol,
                        size: 21,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: const BoxDecoration(
                            color: CustomerHomeV1Tokens.coral,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConversationsLoadingState extends StatelessWidget {
  const _ConversationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-conversations-loading-state'),
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
                'Mesajların yükleniyor',
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

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.thread, required this.onTap});

  final ChatThreadEntity thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUnreadMessages = thread.unreadCount > 0;

    return Semantics(
      button: true,
      label:
          '${thread.displayName} konuşması${hasUnreadMessages ? ', ${thread.unreadCount} okunmamış mesaj' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('conversation-card-${thread.otherUserId}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          child: Ink(
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.surface,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius20,
              ),
              border: Border.all(
                color: hasUnreadMessages
                    ? CustomerHomeV1Tokens.petrol.withValues(alpha: 0.3)
                    : CustomerHomeV1Tokens.border,
              ),
              boxShadow: CustomerHomeV1Tokens.softShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: hasUnreadMessages
                        ? CustomerHomeV1Tokens.mint
                        : CustomerHomeV1Tokens.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: CustomerHomeV1Tokens.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _initialFor(thread.displayName),
                    style: const TextStyle(
                      color: CustomerHomeV1Tokens.petrol,
                      fontSize: 18,
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
                        thread.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 14,
                          fontWeight: hasUnreadMessages
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space4),
                      Text(
                        thread.lastMessageIsMine
                            ? 'Siz: ${thread.lastMessage}'
                            : thread.lastMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasUnreadMessages
                              ? CustomerHomeV1Tokens.navy
                              : CustomerHomeV1Tokens.muted,
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: hasUnreadMessages
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(thread.lastMessageAt),
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasUnreadMessages) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 22,
                          minHeight: 22,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: CustomerHomeV1Tokens.coral,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          thread.unreadCount > 99
                              ? '99+'
                              : thread.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initialFor(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'M';
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '';

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');

    return '$day.$month.$year';
  }
}

class _ConversationStatus extends StatelessWidget {
  const _ConversationStatus({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CustomerHomeV1Tokens.petrol,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space4,
              CustomerHomeV1Tokens.space16,
              CustomerHomeV1Tokens.space24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    (constraints.maxHeight - CustomerHomeV1Tokens.space32)
                        .clamp(0, double.infinity)
                        .toDouble(),
              ),
              child: Center(
                child: Container(
                  key: const Key('customer-conversations-status'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
                  decoration: BoxDecoration(
                    color: CustomerHomeV1Tokens.surface,
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius20,
                    ),
                    border: Border.all(color: CustomerHomeV1Tokens.border),
                    boxShadow: CustomerHomeV1Tokens.softShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: CustomerHomeV1Tokens.mint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 29,
                          color: CustomerHomeV1Tokens.petrol,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space16),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      Text(
                        description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 12.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onRefresh,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomerHomeV1Tokens.petrol,
                            side: const BorderSide(
                              color: CustomerHomeV1Tokens.petrol,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: CustomerHomeV1Tokens.space12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CustomerHomeV1Tokens.radius12,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 19),
                          label: Text(actionLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
