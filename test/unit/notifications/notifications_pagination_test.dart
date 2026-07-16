import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/repositories/notification_repository.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late NotificationsCubit cubit;

  List<NotificationEntity> firstPage() {
    return List.generate(
      20,
      (index) => NotificationEntity(
        id: 'notification-$index',
        userId: 'customer-1',
        title: 'Bildirim $index',
        body: 'Bildirim açıklaması',
        type: NotificationType.system,
        isRead: true,
      ),
    );
  }

  setUp(() {
    repository = MockNotificationRepository();
    cubit = NotificationsCubit(repository: repository);
    when(
      () => repository.getUnreadCount(),
    ).thenAnswer((_) async => const Right(0));
  });

  tearDown(() async {
    await cubit.close();
  });

  test('eski bildirimleri eklerken aynı kaydı iki kez göstermez', () async {
    final initialNotifications = firstPage();
    final secondPage = [
      initialNotifications.first.copyWith(title: 'Güncel bildirim'),
      const NotificationEntity(
        id: 'notification-20',
        userId: 'customer-1',
        title: 'Daha eski bildirim',
        body: 'Bildirim açıklaması',
        type: NotificationType.system,
        isRead: true,
      ),
    ];
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => Right(initialNotifications));
    when(
      () => repository.getNotifications(page: 1, limit: 20),
    ).thenAnswer((_) async => Right(secondPage));

    await cubit.getNotifications();
    await cubit.loadMoreNotifications();

    final state = cubit.state as NotificationsLoaded;
    expect(state.notifications, hasLength(21));
    expect(
      state.notifications.map((notification) => notification.id).toSet(),
      hasLength(21),
    );
    expect(state.notifications.first.title, 'Güncel bildirim');
    expect(state.hasReachedMax, isTrue);
    verify(() => repository.getNotifications(page: 0, limit: 20)).called(1);
    verify(() => repository.getNotifications(page: 1, limit: 20)).called(1);
  });

  test('eski bildirimler yüklenemezse görünen listeyi korur', () async {
    final initialNotifications = firstPage();
    when(
      () => repository.getNotifications(page: 0, limit: 20),
    ).thenAnswer((_) async => Right(initialNotifications));
    when(
      () => repository.getNotifications(page: 1, limit: 20),
    ).thenAnswer((_) async => const Left('Bağlantı hatası'));

    await cubit.getNotifications();
    await cubit.loadMoreNotifications();

    final state = cubit.state as NotificationsLoaded;
    expect(state.notifications, initialNotifications);
    expect(state.isLoadingMore, isFalse);
    expect(state.loadMoreError, 'Diğer bildirimler yüklenemedi.');
  });
}
