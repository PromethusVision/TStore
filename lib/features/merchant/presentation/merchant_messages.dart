import 'dart:async';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/chat/domain/entities/chat_thread_entity.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_conversations_cubit.dart';
import 'package:t_store/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:t_store/features/chat/presentation/views/chat_view.dart';
import 'package:t_store/features/chat/presentation/views/conversations_view.dart';
import 'package:t_store/features/merchant/data/merchant_chat_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';

MerchantChatRepository _scope(
  BuildContext context,
  MerchantServices services,
  MerchantAccess access,
) {
  final host = context.read<MerchantSessionCubit>();
  final revision = host.state.scopeRevision;
  final key = services.currentSessionKey?.call();
  return MerchantChatRepository(
    delegate: services.chatRepositoryFactory!(),
    ownerId: access.user.id,
    isCurrent: () =>
        !host.isClosed &&
        host.state.status == MerchantSessionStatus.ready &&
        host.state.scopeRevision == revision &&
        host.state.access?.shop?.id == access.shop?.id &&
        services.currentUserId() == access.user.id &&
        services.currentSessionKey?.call() == key,
  );
}

/// Explicit injection keeps the shared Customer locator out of Merchant routes.
class MerchantMessages extends StatefulWidget {
  const MerchantMessages({
    super.key,
    required this.services,
    required this.access,
    this.peerId,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final String? peerId;
  @override
  State<MerchantMessages> createState() => _MerchantMessagesState();
}

class _MerchantMessagesState extends State<MerchantMessages> {
  MerchantChatRepository? _repository;
  Future<Either<String, List<ChatThreadEntity>>>? _target;
  @override
  void initState() {
    super.initState();
    if (widget.services.chatRepositoryFactory != null) {
      _repository = _scope(context, widget.services, widget.access);
      if (widget.peerId != null) _target = _repository!.getConversations();
    }
  }

  @override
  void dispose() {
    _repository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    if (repository == null) {
      return const MerchantPage(
        title: 'Mesajlar',
        children: [MerchantNotice('Mesajlaşma bu sürümde kullanılamıyor.')],
      );
    }
    if (widget.peerId == null) {
      return ConversationsView(
        merchant: true,
        conversationsCubit: ChatConversationsCubit(repository: repository),
        destinationBuilder: (thread) => MerchantMessages(
          services: widget.services,
          access: widget.access,
          peerId: thread.otherUserId,
        ),
      );
    }
    // A notification only names a candidate. Existing participant-owned history
    // must confirm the peer before a composer or read mutation can be created.
    return FutureBuilder<Either<String, List<ChatThreadEntity>>>(
      future: _target,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MerchantPage(
            title: 'Mesajlar',
            children: [Center(child: CircularProgressIndicator())],
          );
        }
        return (snapshot.data ??
                const Left<String, List<ChatThreadEntity>>(
                  MerchantChatRepository.unavailable,
                ))
            .fold(
              (error) => MerchantPage(
                title: 'Mesajlar',
                children: [
                  MerchantNotice(
                    error,
                    error: true,
                    onRetry: () =>
                        setState(() => _target = repository.getConversations()),
                  ),
                ],
              ),
              (threads) {
                final matches = threads
                    .where((t) => t.otherUserId == widget.peerId)
                    .toList();
                if (!repository.current || matches.isEmpty) {
                  return const MerchantPage(
                    title: 'Mesajlar',
                    children: [
                      MerchantNotice(
                        'Bu görüşme artık kullanılamıyor. Mesaj listesinden güncel görüşmelerini açabilirsin.',
                      ),
                    ],
                  );
                }
                return ChatView(
                  receiverId: matches.first.otherUserId,
                  receiverName: matches.first.displayName,
                  merchant: true,
                  chatCubit: ChatCubit(repository: repository),
                  currentUserIdProvider: widget.services.currentUserId,
                );
              },
            );
      },
    );
  }
}

/// Visible entry plus actual unread count. No provider/OS delivery is implied.
class MerchantMessagesEntry extends StatefulWidget {
  const MerchantMessagesEntry({
    super.key,
    required this.services,
    required this.access,
    required this.onOpen,
    required this.notifications,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final VoidCallback onOpen;
  final NotificationsCubit notifications;
  @override
  State<MerchantMessagesEntry> createState() => _MerchantMessagesEntryState();
}

class _MerchantMessagesEntryState extends State<MerchantMessagesEntry>
    with WidgetsBindingObserver {
  MerchantChatRepository? _repository;
  Timer? _timer;
  StreamSubscription<NotificationsState>? _inbox;
  int? _unread;
  bool _reading = false, _visible = true, _refreshAgain = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = _scope(context, widget.services, widget.access);
    _inbox = widget.notifications.stream.listen((event) {
      if (_visible &&
          event is NewNotificationReceived &&
          event.notification.type == NotificationType.chat &&
          event.notification.userId == widget.access.user.id) {
        if (_reading) {
          _refreshAgain = true;
        } else {
          _refresh();
        }
      }
    });
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_visible) _refresh();
    });
  }

  Future<void> _refresh() async {
    if (_reading || !(_repository?.current ?? false)) return;
    _reading = true;
    final result = await _repository!.getUnreadCount();
    _reading = false;
    if (!mounted || !_repository!.current) return;
    setState(
      () => _unread = result.fold(
        (_) => null,
        (count) => count < 0 ? null : count,
      ),
    );
    if (_refreshAgain) {
      _refreshAgain = false;
      _refresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (_visible) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _inbox?.cancel();
    _repository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    key: const Key('merchant-messages-entry'),
    onPressed: widget.onOpen,
    icon: const Icon(Icons.chat_bubble_outline),
    label: Text(
      _unread == null
          ? 'Mesajlar'
          : _unread == 0
          ? 'Mesajlar'
          : 'Mesajlar · ${_unread! > 99 ? '99+' : _unread} okunmamış',
    ),
  );
}
