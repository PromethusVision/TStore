import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/merchant/presentation/merchant_notifications.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import '../../helpers/inbox_recovery_fixture.dart';

void main() {
  late FakeInboxRepository repository;
  late NotificationsCubit cubit;
  void initialize() {
    repository = FakeInboxRepository();
    cubit = NotificationsCubit(repository: repository);
  }

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
    await repository.dispose();
  });
  Widget subject(bool merchant) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1.3)),
      child: child!,
    ),
    home: merchant
        ? MerchantNotifications(
            repository: repository,
            cubit: cubit,
            identity: const PushIdentity('owner', NotificationAppRole.merchant),
            currentUserId: () => repository.currentUserId,
          )
        : CustomerNotificationsView(
            notificationsCubit: cubit,
            notificationDestinationBuilder: (_) =>
                const Scaffold(body: Text('PRIVATE DESTINATION')),
          ),
  );
  for (final merchant in [false, true]) {
    testWidgets(
      '${merchant ? 'merchant' : 'customer'} narrow inbox clears replacement session content',
      (tester) async {
        initialize();
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await cubit.getNotifications();
        await tester.pumpWidget(subject(merchant));
        await tester.pumpAndSettle();
        expect(find.text(inboxNotice.body), findsOneWidget);
        repository.replace('S1');
        await tester.pump();
        expect(find.text(inboxNotice.body), findsOneWidget);
        repository.replace('S2');
        expect(cubit.sessionCurrent, false);
        expect(cubit.state, isA<NotificationsError>());
        await tester.pumpAndSettle();
        expect(find.text(inboxNotice.body), findsNothing);
        expect(find.textContaining('Oturumunuz değişti'), findsOneWidget);
        expect(tester.takeException(), null);
      },
    );
    testWidgets(
      '${merchant ? 'merchant' : 'customer'} exposes connection error and explicit refresh',
      (tester) async {
        initialize();
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await cubit.getNotifications();
        await tester.pumpWidget(subject(merchant));
        await tester.pumpAndSettle();
        repository.live.addError(StateError('private transport detail'));
        await tester.pump();
        await tester.pump();
        expect(
          find.textContaining('Canlı bildirim bağlantısı kesildi'),
          findsOneWidget,
        );
        expect(find.text(inboxNotice.body), findsOneWidget);
        final before = repository.pages.length;
        final retry = find.text(merchant ? 'Tekrar dene' : 'Tekrar Dene');
        await tester.ensureVisible(retry);
        await tester.tap(retry);
        await tester.pumpAndSettle();
        expect(repository.pages.length, before + 1);
        expect(
          find.textContaining('Canlı bildirim bağlantısı kesildi'),
          findsNothing,
        );
        expect(tester.takeException(), null);
      },
    );
  }
  testWidgets(
    'merchant duplicate tap stays pending and uncertain response remains unread',
    (tester) async {
      initialize();
      final pending = Completer<Either<String, void>>();
      repository.write = () => pending.future;
      await cubit.getNotifications();
      await tester.pumpWidget(subject(true));
      await tester.pumpAndSettle();
      await tester.tap(find.text(inboxNotice.title));
      await tester.tap(find.text(inboxNotice.title));
      await tester.pump();
      expect(repository.writes, ['read:notice']);
      pending.complete(const Left('transport unknown'));
      await tester.pumpAndSettle();
      expect(cubit.unreadCount, 1);
      expect(find.textContaining('Bildirim güncellenemedi'), findsOneWidget);
      expect(tester.takeException(), null);
    },
  );
  testWidgets(
    'customer stale rendered card cannot navigate after missed session event',
    (tester) async {
      initialize();
      await tester.pumpWidget(subject(false));
      await tester.pumpAndSettle();
      repository.currentSessionKey = 'S2';
      await tester.tap(find.text(inboxNotice.title));
      await tester.pumpAndSettle();
      expect(find.text('PRIVATE DESTINATION'), findsNothing);
      expect(repository.writes, isEmpty);
    },
  );
  testWidgets('merchant hides records addressed to the other app role', (
    tester,
  ) async {
    initialize();
    repository.items = [
      inboxNotice.copyWith(data: {'app_role': 'customer'}),
      inboxNotice.copyWith(
        id: 'merchant',
        title: 'Esnaf bildirimi',
        data: {'app_role': 'merchant'},
      ),
    ];
    await cubit.getNotifications();
    await tester.pumpWidget(subject(true));
    await tester.pumpAndSettle();
    expect(find.text(inboxNotice.title), findsNothing);
    expect(find.text('Esnaf bildirimi'), findsOneWidget);
  });
}
