import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/update_password_view.dart';
import 'package:t_store/features/auth/presentation/widgets/password_recovery_listener.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
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
      const supabase.AuthState(supabase.AuthChangeEvent.passwordRecovery, null),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(UpdatePasswordView), findsOneWidget);
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
          child: MaterialApp(
            navigatorKey: navigatorKey,
            home: const Scaffold(body: Text('Ana sayfa')),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(UpdatePasswordView), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);
  });

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
    expect(find.text('Bağlantı kullanılamıyor'), findsOneWidget);
    expect(find.text('Ana sayfa'), findsNothing);

    await tester.tap(
      find.byKey(const Key('invalid-password-recovery-new-link')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ForgetPasswordView), findsOneWidget);
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
}
