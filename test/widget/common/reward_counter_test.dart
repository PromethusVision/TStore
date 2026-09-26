import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/rewards/domain/reward_progress.dart';
import 'package:t_store/features/rewards/presentation/reward_center.dart';
import 'package:t_store/features/rewards/presentation/reward_counter_card.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  Widget card(
    int steps, {
    bool reduce = false,
    List<RewardEligibleMerchant> merchants = const [],
  }) => MaterialApp(
    theme: EsnaftaVarTheme.light,
    home: MediaQuery(
      data: MediaQueryData(
        disableAnimations: reduce,
        textScaler: TextScaler.linear(1.3),
      ),
      child: Scaffold(
        body: RewardCounterCard(
          progress: RewardProgress(steps: steps, merchants: merchants),
        ),
      ),
    ),
  );
  testWidgets(
    'progress animates once; completion is brief; regressions do not celebrate',
    (tester) async {
      await tester.pumpWidget(card(0));
      await tester.pumpWidget(card(1));
      await tester.pump(const Duration(milliseconds: 400));
      final value = tester
          .widget<LinearProgressIndicator>(
            find.byKey(const Key('reward-counter-bar')),
          )
          .value!;
      expect(value, greaterThan(0));
      expect(value, lessThan(0.2));
      expect(find.text('+1'), findsOneWidget);
      expect(find.byKey(const Key('reward-celebration')), findsNothing);
      await tester.pumpAndSettle();
      await tester.pumpWidget(card(5));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('reward-celebration')), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('reward-celebration')), findsNothing);
      await tester.pumpWidget(card(5));
      expect(find.byKey(const Key('reward-celebration')), findsNothing);
      await tester.pumpWidget(card(0));
      await tester.pumpAndSettle();
      expect(find.text('+1'), findsNothing);
    },
  );
  testWidgets(
    'initial completed snapshot and reduced motion never replay celebration',
    (tester) async {
      await tester.pumpWidget(card(5));
      expect(find.byKey(const Key('reward-celebration')), findsNothing);
      await tester.pumpWidget(card(0, reduce: true));
      await tester.pumpWidget(card(5, reduce: true));
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byKey(const Key('reward-counter-bar')),
            )
            .value,
        1,
      );
      expect(find.byKey(const Key('reward-celebration')), findsNothing);
      expect(find.byKey(const Key('reward-increment')), findsNothing);
    },
  );
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('counter and three logo bubbles fit $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        card(
          0,
          merchants: List.generate(
            5,
            (i) => RewardEligibleMerchant(id: 'merchant-$i', name: 'Esnaf $i'),
          ),
        ),
      );
      expect(find.text('0 / 5'), findsOneWidget);
      expect(find.text('+2'), findsOneWidget);
      expect(find.byType(Tooltip), findsNWidgets(3));
      expect(tester.takeException(), isNull);
    });
  }
  test('pending repository cannot invent earning or merchants', () async {
    for (final id in [null, 'customer']) {
      final progress = await const PendingRewardRepository()
          .watchProgress(id)
          .first;
      expect(progress.completed, 0);
      expect(progress.merchants, isEmpty);
      expect(progress.available, isFalse);
    }
  });
  for (final guest in [true, false]) {
    testWidgets(
      guest
          ? 'guest uses existing login'
          : 'authenticated customer opens reward center',
      (tester) async {
        await sl.reset();
        addTearDown(sl.reset);
        final auth = _Auth();
        whenListen(
          auth,
          const Stream<AuthState>.empty(),
          initialState: guest
              ? AuthUnauthenticated()
              : const AuthAuthenticated(
                  UserEntity(id: 'customer', email: 'fixture@example.test'),
                ),
        );
        sl.registerFactory<AuthCubit>(() => auth);
        await tester.pumpWidget(
          MaterialApp(
            theme: EsnaftaVarTheme.light,
            home: BlocProvider<AuthCubit>.value(
              value: auth,
              child: Scaffold(
                body: HomeRewardCounter(
                  currentUserIdProvider: () => guest ? null : 'customer',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('reward-progress-card')));
        await tester.pumpAndSettle();
        if (guest) {
          expect(find.byType(LoginView), findsOneWidget);
          expect(
            tester
                .widget<LoginView>(find.byType(LoginView))
                .returnToCallerAfterCustomerLogin,
            isTrue,
          );
        } else {
          expect(find.byType(RewardCenter), findsOneWidget);
          expect(find.textContaining('henüz açıklanmadı'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
