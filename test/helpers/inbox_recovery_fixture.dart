import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';

const inboxNotice = NotificationEntity(
  id: 'notice',
  userId: 'owner',
  title: 'Yerel bildirim',
  body: 'Yalnız sentetik test içeriği',
  type: NotificationType.system,
);

class FakeInboxRepository
    implements NotificationRepository, NotificationSessionSource {
  @override
  String? currentUserId = 'owner';
  @override
  String? currentSessionKey = 'S1';
  final sessions = StreamController<String?>.broadcast(sync: true);
  final live = StreamController<NotificationEntity>.broadcast(sync: true);
  @override
  Stream<String?> get sessionKeyChanges => sessions.stream;
  @override
  Stream<NotificationEntity> get notificationsStream => live.stream;
  final writes = <String>[];
  final pages = <int>[];
  int counts = 0;
  List<NotificationEntity> items = [inboxNotice];
  Future<Either<String, List<NotificationEntity>>> Function()? read;
  Future<Either<String, int>> Function()? count;
  Future<Either<String, void>> Function()? write;
  void replace(String? key, {String? actor = 'owner'}) {
    currentUserId = actor;
    currentSessionKey = key;
    sessions.add(key);
  }

  @override
  Future<Either<String, List<NotificationEntity>>> getNotifications({
    int page = 0,
    int limit = 20,
  }) async {
    pages.add(page);
    return read == null ? Right(items) : read!();
  }

  @override
  Future<Either<String, int>> getUnreadCount() async {
    counts++;
    return count == null
        ? Right(items.where((n) => !n.isRead).length)
        : count!();
  }

  Future<Either<String, void>> _write(String operation) async {
    writes.add(operation);
    return write == null ? const Right(null) : write!();
  }

  @override
  Future<Either<String, void>> markAsRead(String id) => _write('read:$id');
  @override
  Future<Either<String, void>> markAllAsRead() => _write('read-all');
  @override
  Future<Either<String, void>> deleteNotification(String id) =>
      _write('delete:$id');
  @override
  Future<Either<String, void>> deleteAllNotifications() => _write('delete-all');
  Future<void> dispose() async {
    await sessions.close();
    await live.close();
  }
}
