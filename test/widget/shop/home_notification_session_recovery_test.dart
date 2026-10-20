import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';

import '../../helpers/inbox_recovery_fixture.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

class _Inbox extends FakeInboxRepository {
  final channels = <StreamController<NotificationEntity>>[];
  int activeChannels = 0;

  @override
  Stream<NotificationEntity> get notificationsStream {
    final channel = StreamController<NotificationEntity>.broadcast(
      sync: true,
      onListen: () => activeChannels++,
      onCancel: () => activeChannels--,
    );
    channels.add(channel);
    return channel.stream;
  }

  @override
  Future<void> dispose() async {
    for (final channel in channels) {
      await channel.close();
    }
    await super.dispose();
  }
}

class _Home {
  final repo = _Inbox();
  final auth = _Auth();
  final authStates = StreamController<AuthState>.broadcast(sync: true);
  final instances = <NotificationsCubit>[];

  static AuthAuthenticated signedIn(String id) =>
      AuthAuthenticated(UserEntity(id: id, email: 'fixture@example.invalid'));

  Future<void> mount(WidgetTester tester) async {
    await sl.reset();
    whenListen(auth, authStates.stream, initialState: signedIn('owner'));
    sl.registerFactory<NotificationsCubit>(() {
      final cubit = NotificationsCubit(repository: repo);
      instances.add(cubit);
      return cubit;
    });
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await authStates.close();
      await auth.close();
      await repo.dispose();
      await sl.reset();
    });
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: const MaterialApp(
          home: Scaffold(body: HomeAppBar(sessionFullName: 'Fixture')),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

void _badge(int count) {
  final badge = find.byKey(const Key('home-notifications-badge'));
  if (count == 0) {
    expect(badge, findsNothing);
  } else {
    expect(
      find.descendant(of: badge, matching: find.text('$count')),
      findsOneWidget,
    );
  }
}

void main() {
  testWidgets(
    'new same-user session restores badge and live tracking without navigation',
    (tester) async {
      final home = _Home();
      await home.mount(tester);
      _badge(1);
      final retired = home.instances.single;
      final oldChannel = home.repo.channels.single;
      home.repo.replace('S2');
      await tester.pumpAndSettle();
      expect(retired.isClosed, isTrue);
      expect(retired.sessionCurrent, isFalse);
      expect(home.instances, hasLength(2));
      expect(home.repo.activeChannels, 1);
      _badge(1);
      oldChannel.add(inboxNotice.copyWith(id: 'stale'));
      home.repo.channels.last.add(inboxNotice.copyWith(id: 'fresh'));
      await tester.pumpAndSettle();
      _badge(2);
      expect(
        (home.instances.last.state as NotificationsLoaded).notifications.map(
          (n) => n.id,
        ),
        ['fresh', 'notice'],
      );
    },
  );

  testWidgets(
    'ordinary renewal retains pending reads and the existing live listener',
    (tester) async {
      final home = _Home();
      await home.mount(tester);
      final cubit = home.instances.single;
      final pending = Completer<Either<String, List<NotificationEntity>>>();
      home.repo.read = () => pending.future;
      final request = cubit.getNotifications();
      home.repo.replace('S1');
      await tester.pump();
      expect(home.instances, hasLength(1));
      expect(cubit.sessionCurrent, isTrue);
      expect(home.repo.activeChannels, 1);
      pending.complete(Right([inboxNotice.copyWith(id: 'page-two')]));
      await request;
      await tester.pumpAndSettle();
      _badge(2);
      expect(home.repo.channels, hasLength(1));
    },
  );

  for (final delayed in ['page', 'count']) {
    testWidgets(
      'retired $delayed response cannot overwrite the replacement badge',
      (tester) async {
        final home = _Home();
        final page = Completer<Either<String, List<NotificationEntity>>>();
        final count = Completer<Either<String, int>>();
        if (delayed == 'page') {
          home.repo.read = () => page.future;
        } else {
          home.repo.count = () => count.future;
        }
        await home.mount(tester);
        final retired = home.instances.single;
        home.repo.read = null;
        home.repo.count = null;
        home.repo.replace('S2');
        await tester.pumpAndSettle();
        _badge(1);
        if (delayed == 'page') {
          page.complete(Right([inboxNotice.copyWith(id: 'retired-row')]));
        } else {
          count.complete(const Right(99));
        }
        await tester.pumpAndSettle();
        _badge(1);
        expect(retired.isClosed, isTrue);
        expect(home.repo.activeChannels, 1);
        expect(
          (home.instances.last.state as NotificationsLoaded).notifications,
          [inboxNotice],
        );
      },
    );
  }

  testWidgets(
    'account replacement waits for matching Customer identity before reading',
    (tester) async {
      final home = _Home();
      await home.mount(tester);
      final pageReads = home.repo.pages.length;
      home.repo.items = [
        inboxNotice.copyWith(userId: 'other', id: 'other-row'),
      ];
      home.repo.replace('OTHER', actor: 'other');
      await tester.pumpAndSettle();
      _badge(0);
      expect(home.repo.pages, hasLength(pageReads));
      expect(home.repo.activeChannels, 0);
      home.authStates.add(_Home.signedIn('other'));
      await tester.pumpAndSettle();
      _badge(1);
      expect(home.repo.activeChannels, 1);
      expect(
        (home.instances.last.state as NotificationsLoaded)
            .notifications
            .single
            .userId,
        'other',
      );
    },
  );

  testWidgets('logout removes badge and a later sign-in binds a fresh owner', (
    tester,
  ) async {
    final home = _Home();
    await home.mount(tester);
    home.repo.replace(null, actor: null);
    home.authStates.add(AuthUnauthenticated());
    await tester.pumpAndSettle();
    _badge(0);
    expect(home.repo.activeChannels, 0);
    home.repo.replace('S2');
    await tester.pumpAndSettle();
    expect(home.instances, hasLength(1));
    home.authStates.add(_Home.signedIn('owner'));
    await tester.pumpAndSettle();
    _badge(1);
    expect(home.instances, hasLength(2));
    expect(home.repo.activeChannels, 1);
  });

  testWidgets(
    'queued S1-S2-S1 events retire old work and bind only the final live session',
    (tester) async {
      final home = _Home();
      await home.mount(tester);
      final retired = home.instances.single;
      // Captured intermediate event arrives after live Auth has returned to S1.
      home.repo.sessions.add('S2');
      home.repo.sessions.add('S1');
      await tester.pumpAndSettle();
      expect(retired.isClosed, isTrue);
      expect(retired.sessionCurrent, isFalse);
      expect(home.instances, hasLength(2));
      expect(home.repo.activeChannels, 1);
      home.repo.channels.last.add(inboxNotice.copyWith(id: 'new-session'));
      await tester.pumpAndSettle();
      _badge(2);
    },
  );

  for (final ended in [false, true]) {
    testWidgets(
      'Auth observation ${ended ? 'closure' : 'failure'} removes private count and tracking',
      (tester) async {
        final home = _Home();
        await home.mount(tester);
        if (ended) {
          // Stream cancellation completion can run outside widget fake time.
          await tester.runAsync(home.repo.sessions.close);
        } else {
          home.repo.sessions.addError(StateError('synthetic observer failure'));
        }
        await tester.pumpAndSettle();
        _badge(0);
        expect(home.repo.activeChannels, 0);
        expect(home.instances.single.isClosed, isTrue);
        if (!ended) {
          home.repo.replace('S2');
          await tester.pumpAndSettle();
          _badge(0);
          expect(home.instances, hasLength(1));
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('disposing home releases its Auth and Realtime listeners', (
    tester,
  ) async {
    final home = _Home();
    await home.mount(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(home.repo.activeChannels, 0);
    expect(home.repo.sessions.hasListener, isFalse);
    home.repo.replace('S2');
    await tester.pumpAndSettle();
    expect(home.instances, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
