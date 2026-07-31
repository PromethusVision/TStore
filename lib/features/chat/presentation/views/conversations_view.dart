import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
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
      appBar: AppBar(title: const Text('Mesajlarım')),
      body: SafeArea(
        child: BlocBuilder<ChatConversationsCubit, ChatConversationsState>(
          builder: (context, state) {
            if (state is ChatConversationsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ChatConversationsError) {
              return _RefreshableMessage(
                message: state.message,
                onRefresh: () => context
                    .read<ChatConversationsCubit>()
                    .refreshConversations(),
              );
            }

            if (state is ChatConversationsLoaded) {
              if (state.threads.isEmpty) {
                return _RefreshableMessage(
                  message: 'Henüz mesajınız yok.',
                  onRefresh: () => context
                      .read<ChatConversationsCubit>()
                      .refreshConversations(),
                );
              }

              return RefreshIndicator(
                onRefresh: () => context
                    .read<ChatConversationsCubit>()
                    .refreshConversations(),
                child: ListView.separated(
                  itemCount: state.threads.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final thread = state.threads[index];
                    return _ConversationTile(
                      thread: thread,
                      onTap: () => _openConversation(thread),
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
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
      if (mounted) {
        await _refreshAndRestart();
      }
    }
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatThreadEntity thread;
  final VoidCallback onTap;

  const _ConversationTile({required this.thread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(thread.displayName),
      subtitle: Text(
        thread.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDate(thread.lastMessageAt),
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (thread.unreadCount > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                thread.unreadCount.toString(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
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

class _RefreshableMessage extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;

  const _RefreshableMessage({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Center(child: Text(message)),
          ),
        ],
      ),
    );
  }
}
