import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/components/esnaftavar_surface_icon_button.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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
    this.nowProvider,
  });

  final ChatConversationsCubit? conversationsCubit;
  final Duration autoRefreshInterval;
  final ConversationDestinationBuilder? destinationBuilder;
  final DateTime Function()? nowProvider;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (conversationsCubit ?? sl<ChatConversationsCubit>())
            ..loadConversations(),
      child: _ConversationsViewBody(
        autoRefreshInterval: autoRefreshInterval,
        destinationBuilder: destinationBuilder,
        nowProvider: nowProvider ?? DateTime.now,
      ),
    );
  }
}

class _ConversationsViewBody extends StatefulWidget {
  const _ConversationsViewBody({
    required this.autoRefreshInterval,
    required this.destinationBuilder,
    required this.nowProvider,
  });

  final Duration autoRefreshInterval;
  final ConversationDestinationBuilder? destinationBuilder;
  final DateTime Function() nowProvider;

  @override
  State<_ConversationsViewBody> createState() => _ConversationsViewBodyState();
}

class _ConversationsViewBodyState extends State<_ConversationsViewBody>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  bool _isOpeningConversation = false;
  bool _isOpeningProductDiscovery = false;

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
      backgroundColor: EsnaftaVarColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-conversations-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xs,
                    EsnaftaVarSpacing.md,
                    0,
                  ),
                  child: _ConversationsHeader(),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
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
                              actionIcon: Icons.refresh_rounded,
                              onAction: () => context
                                  .read<ChatConversationsCubit>()
                                  .refreshConversations(),
                              onRefresh: () => context
                                  .read<ChatConversationsCubit>()
                                  .refreshConversations(),
                            );
                          }

                          if (state is ChatConversationsLoaded) {
                            if (state.threads.isEmpty) {
                              return _ConversationStatus(
                                icon: Icons.forum_outlined,
                                title: 'Henüz mesajın yok',
                                description:
                                    'Bir ürün hakkında mağazaya yazdığında konuşmaların burada görünecek.',
                                actionLabel: 'Ürünleri Keşfet',
                                actionIcon: Icons.search_rounded,
                                onAction: _openProductDiscovery,
                                onRefresh: () => context
                                    .read<ChatConversationsCubit>()
                                    .refreshConversations(),
                              );
                            }

                            return RefreshIndicator(
                              color: EsnaftaVarColors.primary,
                              onRefresh: () => context
                                  .read<ChatConversationsCubit>()
                                  .refreshConversations(),
                              child: ListView.separated(
                                key: const Key('customer-conversations-list'),
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  EsnaftaVarSpacing.md,
                                  EsnaftaVarSpacing.xxs,
                                  EsnaftaVarSpacing.md,
                                  EsnaftaVarSpacing.xl,
                                ),
                                itemCount: state.threads.length,
                                separatorBuilder: (_, _) => const SizedBox(
                                  height: EsnaftaVarSpacing.sm,
                                ),
                                itemBuilder: (context, index) {
                                  final thread = state.threads[index];
                                  return _ConversationCard(
                                    thread: thread,
                                    now: widget.nowProvider(),
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

  Future<void> _openProductDiscovery() async {
    if (_isOpeningProductDiscovery) return;

    _isOpeningProductDiscovery = true;
    try {
      context.read<NavigationMenuCubit>().changeIndex(0);
      await Navigator.of(context).maybePop<void>();
    } finally {
      _isOpeningProductDiscovery = false;
    }
  }
}

class _ConversationsHeader extends StatelessWidget {
  const _ConversationsHeader();
  @override
  Widget build(BuildContext context) => Row(
    key: const Key('customer-conversations-header'),
    children: [
      EsnaftaVarSurfaceIconButton(
        buttonKey: const Key('customer-conversations-back-button'),
        icon: Icons.arrow_back_rounded,
        tooltip: 'Geri',
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mesajlarım', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Mağazalarla görüşmelerin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: EsnaftaVarColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ConversationsLoadingState extends StatelessWidget {
  const _ConversationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-conversations-loading-state'),
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
                'Mesajların yükleniyor',
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

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.thread,
    required this.now,
    required this.onTap,
  });

  final ChatThreadEntity thread;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = thread.unreadCount > 0;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label:
          '${thread.displayName} konuşması${unread ? ', ${thread.unreadCount} okunmamış mesaj' : ''}',
      child: Material(
        color: EsnaftaVarColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          side: const BorderSide(color: EsnaftaVarColors.borderDefault),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: Key('conversation-card-${thread.otherUserId}'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.primarySoft,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.medium,
                        ),
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: EsnaftaVarColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        thread.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleSmall,
                      ),
                    ),
                    if (unread) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: EsnaftaVarColors.primary,
                          borderRadius: BorderRadius.circular(
                            EsnaftaVarRadii.pill,
                          ),
                        ),
                        child: Text(
                          thread.unreadCount > 99
                              ? '99+'
                              : thread.unreadCount.toString(),
                          style: text.labelSmall?.copyWith(
                            color: EsnaftaVarColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  thread.lastMessageIsMine
                      ? 'Siz: ${thread.lastMessage}'
                      : thread.lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    color: unread
                        ? EsnaftaVarColors.textPrimary
                        : EsnaftaVarColors.textSecondary,
                    fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatDate(thread.lastMessageAt, now),
                        style: text.labelSmall?.copyWith(
                          color: EsnaftaVarColors.textMuted,
                        ),
                      ),
                    ),
                    if (thread.lastMessageIsMine)
                      Flexible(
                        child: Row(
                          key: Key(
                            'conversation-delivery-status-${thread.otherUserId}',
                          ),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                thread.lastMessageIsRead
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                size: 16,
                                color: EsnaftaVarColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                thread.lastMessageIsRead
                                    ? 'Okundu'
                                    : 'Gönderildi',
                                style: text.labelSmall?.copyWith(
                                  color: EsnaftaVarColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value, DateTime now) {
    if (value == null) return '';

    final local = value.toLocal();
    final localNow = now.toLocal();

    if (_isSameDay(local, localNow)) {
      final hour = local.hour.toString().padLeft(2, '0');
      final minute = local.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    final yesterday = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    ).subtract(const Duration(days: 1));
    if (_isSameDay(local, yesterday)) return 'Dün';

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString().padLeft(4, '0');

    return '$day.$month.$year';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _ConversationStatus extends StatelessWidget {
  const _ConversationStatus({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.onRefresh,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final IconData actionIcon;
  final Future<void> Function() onAction;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        EsnaftaVarStateCard(
          key: const Key('customer-conversations-status'),
          icon: icon,
          title: title,
          message: description,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAction,
          icon: Icon(actionIcon),
          label: Text(actionLabel),
        ),
      ],
    ),
  );
}
