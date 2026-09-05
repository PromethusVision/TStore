import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/update_password_view.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/customer_launch_gate.dart';
import 'package:t_store/features/auth/presentation/widgets/password_recovery_listener.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const recoveryIdentity = PasswordRecoveryIdentity(
    userId: 'customer-1',
    email: 'customer@example.com',
  );

  testWidgets('password recovery link opens the new password screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    final authEvents = StreamController<supabase.AuthState>();
    final navigatorKey = GlobalKey<NavigatorState>();

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    addTearDown(() async {
      await authEvents.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: PasswordRecoveryListener(
          authStateChanges: authEvents.stream,
          navigatorKey: navigatorKey,
          initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.none,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Ana sayfa')),
          ),
        ),
      ),
    );

    authEvents.add(
      supabase.AuthState(
        supabase.AuthChangeEvent.passwordRecovery,
        _sessionFor(recoveryIdentity),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(UpdatePasswordView), findsOneWidget);
    expect(
      tester
          .widget<UpdatePasswordView>(find.byType(UpdatePasswordView))
          .recoveryIdentity,
      recoveryIdentity,
    );
    expect(find.text('Yeni şifrenizi belirleyin'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);
  });

  testWidgets('app opened from a recovery link shows the new password screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    final authEvents = StreamController<supabase.AuthState>();
    final navigatorKey = GlobalKey<NavigatorState>();

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    addTearDown(() async {
      await authEvents.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: PasswordRecoveryListener(
          authStateChanges: authEvents.stream,
          navigatorKey: navigatorKey,
          initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.verified,
          initialRecoveryIdentity: recoveryIdentity,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Ana sayfa')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(UpdatePasswordView), findsOneWidget);
    expect(
      tester
          .widget<UpdatePasswordView>(find.byType(UpdatePasswordView))
          .recoveryIdentity,
      recoveryIdentity,
    );
    expect(find.text('Ana sayfa'), findsNothing);
  });

  testWidgets(
    'verified recovery link takes priority while onboarding decision waits',
    (tester) async {
      final authCubit = MockAuthCubit();
      final authEvents = StreamController<supabase.AuthState>();
      final navigatorKey = GlobalKey<NavigatorState>();
      final launchStatus = Completer<bool>();

      whenListen(
        authCubit,
        const Stream<AuthState>.empty(),
        initialState: AuthInitial(),
      );

      addTearDown(() async {
        await authEvents.close();
        await authCubit.close();
      });

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: PasswordRecoveryListener(
            authStateChanges: authEvents.stream,
            navigatorKey: navigatorKey,
            initialPasswordRecoveryStatus:
                PasswordRecoveryLaunchStatus.verified,
            initialRecoveryIdentity: recoveryIdentity,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: CustomerLaunchGate(
                statusProvider: () => launchStatus.future,
                onboardingBuilder: (_) =>
                    const Scaffold(key: Key('onboarding-destination')),
                homeBuilder: (_) =>
                    const Scaffold(key: Key('customer-home-destination')),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(UpdatePasswordView), findsOneWidget);
      expect(find.text('Yeni şifrenizi belirleyin'), findsOneWidget);
      expect(find.byKey(const Key('customer-launch-loading')), findsNothing);
      expect(find.byKey(const Key('onboarding-destination')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid startup recovery shows a safe error screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    final authEvents = StreamController<supabase.AuthState>();
    final navigatorKey = GlobalKey<NavigatorState>();

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    addTearDown(() async {
      await authEvents.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: PasswordRecoveryListener(
          authStateChanges: authEvents.stream,
          navigatorKey: navigatorKey,
          initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.invalid,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Ana sayfa')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(InvalidPasswordRecoveryView), findsOneWidget);
    expect(
      find.byKey(const Key('customer-invalid-password-recovery-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-invalid-password-recovery-header')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('invalid-password-recovery-wordmark')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-invalid-password-recovery-card')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('invalid-password-recovery-title')),
        matching: find.byIcon(Icons.link_off_rounded),
      ),
      findsOneWidget,
    );
    expect(find.text('Bağlantı kullanılamıyor'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);

    await tester.tap(
      find.byKey(const Key('invalid-password-recovery-new-link')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ForgetPasswordView), findsOneWidget);
  });

  testWidgets(
    'invalid recovery link takes priority while onboarding decision waits',
    (tester) async {
      final authCubit = MockAuthCubit();
      final authEvents = StreamController<supabase.AuthState>();
      final navigatorKey = GlobalKey<NavigatorState>();
      final launchStatus = Completer<bool>();

      whenListen(
        authCubit,
        const Stream<AuthState>.empty(),
        initialState: AuthInitial(),
      );

      addTearDown(() async {
        await authEvents.close();
        await authCubit.close();
      });

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: PasswordRecoveryListener(
            authStateChanges: authEvents.stream,
            navigatorKey: navigatorKey,
            initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.invalid,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: CustomerLaunchGate(
                statusProvider: () => launchStatus.future,
                onboardingBuilder: (_) =>
                    const Scaffold(key: Key('onboarding-destination')),
                homeBuilder: (_) =>
                    const Scaffold(key: Key('customer-home-destination')),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.byType(InvalidPasswordRecoveryView), findsOneWidget);
      expect(find.text('Bağlantı kullanılamıyor'), findsOneWidget);
      expect(find.byKey(const Key('customer-launch-loading')), findsNothing);
      expect(find.byKey(const Key('onboarding-destination')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('invalid recovery can return to a clean login screen', (
    tester,
  ) async {
    final authCubit = MockAuthCubit();
    final loginAuthCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    whenListen(
      loginAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    if (sl.isRegistered<AuthCubit>()) {
      await sl.unregister<AuthCubit>();
    }
    sl.registerFactory<AuthCubit>(() => loginAuthCubit);
    addTearDown(() async {
      if (sl.isRegistered<AuthCubit>()) {
        await sl.unregister<AuthCubit>();
      }
      await authCubit.close();
      await loginAuthCubit.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(home: InvalidPasswordRecoveryView()),
      ),
    );

    await tester.tap(find.byKey(const Key('invalid-password-recovery-login')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(InvalidPasswordRecoveryView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('invalid recovery supports narrow screens and larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.4)),
          child: child!,
        ),
        home: const InvalidPasswordRecoveryView(),
      ),
    );

    expect(
      find.byKey(const Key('customer-invalid-password-recovery-scroll')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('invalid-password-recovery-login')),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const Key('invalid-password-recovery-login')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordinary auth events do not open recovery', (tester) async {
    final authCubit = MockAuthCubit();
    final authEvents = StreamController<supabase.AuthState>();
    final navigatorKey = GlobalKey<NavigatorState>();

    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );

    addTearDown(() async {
      await authEvents.close();
      await authCubit.close();
    });

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: PasswordRecoveryListener(
          authStateChanges: authEvents.stream,
          navigatorKey: navigatorKey,
          initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.none,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Ana sayfa')),
          ),
        ),
      ),
    );

    authEvents.add(
      const supabase.AuthState(supabase.AuthChangeEvent.signedIn, null),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana sayfa'), findsOneWidget);
    expect(find.byType(UpdatePasswordView), findsNothing);
  });

  testWidgets(
    'recovery event without a session opens only the invalid screen',
    (tester) async {
      final authCubit = MockAuthCubit();
      final authEvents = StreamController<supabase.AuthState>();
      final navigatorKey = GlobalKey<NavigatorState>();
      whenListen(
        authCubit,
        const Stream<AuthState>.empty(),
        initialState: AuthInitial(),
      );
      addTearDown(() async {
        await authEvents.close();
        await authCubit.close();
      });

      await tester.pumpWidget(
        BlocProvider<AuthCubit>.value(
          value: authCubit,
          child: PasswordRecoveryListener(
            authStateChanges: authEvents.stream,
            navigatorKey: navigatorKey,
            initialPasswordRecoveryStatus: PasswordRecoveryLaunchStatus.none,
            child: MaterialApp(
              navigatorKey: navigatorKey,
              home: const Scaffold(body: Text('Ana sayfa')),
            ),
          ),
        ),
      );

      authEvents.add(
        const supabase.AuthState(
          supabase.AuthChangeEvent.passwordRecovery,
          null,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(InvalidPasswordRecoveryView), findsOneWidget);
      expect(find.byType(UpdatePasswordView), findsNothing);
    },
  );
}

supabase.Session _sessionFor(PasswordRecoveryIdentity identity) {
  return supabase.Session(
    accessToken: 'test-recovery-access-token',
    tokenType: 'bearer',
    user: supabase.User(
      id: identity.userId,
      email: identity.email,
      appMetadata: const {},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-01-01T00:00:00.000Z',
    ),
  );
}
