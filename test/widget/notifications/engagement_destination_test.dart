import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/navigation/engagement_auth_gate.dart';
import 'package:t_store/core/navigation/engagement_destination.dart';
import 'package:t_store/core/navigation/engagement_target.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/presentation/views/customer_notifications_view.dart';
import 'package:t_store/features/purchases/presentation/views/purchases_view.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const target = EngagementTarget(EngagementTargetType.search, 'USB');
  testWidgets('destination waits, then opens the existing resolved screen', (
    tester,
  ) async {
    final ready = Completer<Widget?>();
    await tester.pumpWidget(
      MaterialApp(
        home: EngagementDestination(
          target: target,
          resolve: (_) => ready.future,
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    ready.complete(const Scaffold(body: Text('resolved search')));
    await tester.pumpAndSettle();
    expect(find.text('resolved search'), findsOneWidget);
  });
  testWidgets('missing or failed destination shows a recoverable safe state', (
    tester,
  ) async {
    for (final failed in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: EngagementDestination(
            key: ValueKey(failed),
            target: target,
            resolve: (_) async {
              if (failed) throw StateError('private-fixture-error');
              return null;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bu içerik şu anda kullanılamıyor.'), findsOneWidget);
      expect(find.textContaining('private-fixture-error'), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'auth gate rejects guests and wrong role; logout removes private content',
    (tester) async {
      final auth = _Auth();
      final states = StreamController<AuthState>();
      whenListen(auth, states.stream, initialState: AuthUnauthenticated());
      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: auth,
          child: MaterialApp(
            home: EngagementAuthGate(
              customerOnly: true,
              builder: (_) => const Text('private reward'),
            ),
          ),
        ),
      );
      expect(find.text('Devam etmek için giriş yap'), findsOneWidget);
      states.add(
        const AuthAuthenticated(
          UserEntity(
            id: 'fixture-merchant',
            email: 'merchant@example.com',
            role: 'merchant',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('private reward'), findsNothing);
      states.add(
        const AuthAuthenticated(
          UserEntity(id: 'fixture-customer', email: 'customer@example.com'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('private reward'), findsOneWidget);
      states.add(AuthUnauthenticated());
      await tester.pumpAndSettle();
      expect(find.text('private reward'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await states.close();
      await auth.close();
    },
  );
  test(
    'existing order routing remains customer-only; shared campaign uses allowlisted destination',
    () {
      const order = NotificationEntity(
        id: 'fixture',
        userId: 'fixture',
        title: 'Fixture',
        body: 'Fixture',
        type: NotificationType.order,
      );
      expect(buildCustomerNotificationDestination(order), isA<PurchasesView>());
      expect(
        buildNotificationDestination(
          order,
          appRole: NotificationAppRole.merchant,
        ),
        isNull,
      );
      final campaign = order.copyWith(
        type: NotificationType.promotion,
        data: {'target_type': 'search', 'target_value': 'USB'},
      );
      expect(
        buildNotificationDestination(campaign),
        isA<EngagementDestination>(),
      );
      expect(
        buildNotificationDestination(
          campaign,
          appRole: NotificationAppRole.merchant,
        ),
        isA<EngagementDestination>(),
      );
      expect(
        buildNotificationDestination(
          campaign.copyWith(
            data: {'app_role': 'merchant', 'target_type': 'reward'},
          ),
        ),
        isNull,
      );
    },
  );

  testWidgets('inbox deep link keeps the authenticated merchant role', (
    tester,
  ) async {
    final auth = _Auth();
    whenListen(
      auth,
      const Stream<AuthState>.empty(),
      initialState: const AuthAuthenticated(
        UserEntity(
          id: 'fixture-merchant',
          email: 'merchant@example.com',
          role: 'merchant',
        ),
      ),
    );
    final destination = await resolveEngagementDestination(
      const EngagementTarget(EngagementTargetType.notifications),
    );
    CustomerNotificationsView? inbox;
    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: auth,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              inbox =
                  (destination! as EngagementAuthGate).builder(context)
                      as CustomerNotificationsView;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    expect(inbox!.appRole, NotificationAppRole.merchant);
    await tester.pumpWidget(const SizedBox());
    await auth.close();
  });
}
