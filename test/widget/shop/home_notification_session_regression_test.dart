import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/shop/presentation/widgets/home_app_bar.dart';

import '../../helpers/inbox_recovery_fixture.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  for (final replaceSession in [false, true]) {
    testWidgets(
      'Home badge recovers after ${replaceSession ? 'same-account session replacement' : 'ordinary renewal'} and inbox reopen',
      (tester) async {
        await sl.reset();
        final repo = FakeInboxRepository();
        final auth = MockAuthCubit();
        final instances = <NotificationsCubit>[];
        whenListen(
          auth,
          const Stream<AuthState>.empty(),
          initialState: const AuthAuthenticated(
            UserEntity(id: 'owner', email: 'fixture@example.invalid'),
          ),
        );
        sl.registerFactory<NotificationsCubit>(() {
          final cubit = NotificationsCubit(repository: repo);
          instances.add(cubit);
          return cubit;
        });
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          await repo.dispose();
          await auth.close();
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
        expect(
          find.byKey(const Key('home-notifications-badge')),
          findsOneWidget,
        );
        expect(instances, hasLength(1));
        repo.replace(replaceSession ? 'S2' : 'S1');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('home-notifications-button')));
        await tester.pumpAndSettle();
        expect(find.byType(CustomerNotificationsView), findsOneWidget);
        expect(find.text(inboxNotice.body), findsOneWidget);
        expect(instances.length, greaterThanOrEqualTo(2));
        // The current session can read the inbox. Returning must also recover
        // its badge and live arrivals; keeping a permanently expired Home
        // cubit renders an incorrect zero count indefinitely.
        await tester.tap(
          find.byKey(const Key('customer-notifications-back-button')),
        );
        await tester.pumpAndSettle();
        repo.live.add(inboxNotice.copyWith(id: 'new-arrival'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: find.byKey(const Key('home-notifications-badge')),
            matching: find.text('2'),
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
