import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_state.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';

class ConversationsView extends StatelessWidget {
  const ConversationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatConversationsCubit>()..loadConversations(),
      child: const _ConversationsViewBody(),
    );
  }
}

class _ConversationsViewBody extends StatelessWidget {
  const _ConversationsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesajlarım'),
      ),
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
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _ConversationTile(thread: state.threads[index]);
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
}

class _ConversationTile extends StatelessWidget {
  final ChatThreadEntity thread;

  const _ConversationTile({required this.thread});

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
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatView(
              receiverId: thread.otherUserId,
              receiverName: thread.displayName,
            ),
          ),
        );
        if (!context.mounted) return;

        await context.read<ChatConversationsCubit>().refreshConversations();
      },
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

  const _RefreshableMessage({
    required this.message,
    required this.onRefresh,
  });

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
