import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/widgets/email_confirmation_listener.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;
  late StreamController<EmailConfirmationCallbackResult> callbacks;
  late GlobalKey<NavigatorState> navigatorKey;
  late GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const user = UserEntity(id: 'customer-1', email: 'customer@example.com');

  setUp(() {
    authCubit = MockAuthCubit();
    callbacks = StreamController<EmailConfirmationCallbackResult>.broadcast();
    navigatorKey = GlobalKey<NavigatorState>();
    scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.checkAuthStatus()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await callbacks.close();
  });

  Widget buildSubject({EmailConfirmationCallbackResult? initialCallback}) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: EmailConfirmationListener(
        callbacks: callbacks.stream,
        initialCallback: initialCallback,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        authenticatedDestinationBuilder: (_) =>
            const Scaffold(body: Text('Müşteri ana sayfası')),
        unauthenticatedDestinationBuilder: (_) =>
            const Scaffold(body: Text('Giriş ekranı')),
        child: MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: scaffoldMessengerKey,
          home: const Scaffold(body: Text('Doğrulama bekleniyor')),
        ),
      ),
    );
  }

  testWidgets('authenticated callback refreshes profile and opens home once', (
    tester,
  ) async {
    when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));
    await tester.pumpWidget(buildSubject());

    const result = EmailConfirmationCallbackResult(
      sequence: 1,
      status: EmailConfirmationCallbackStatus.authenticated,
    );
    callbacks
      ..add(result)
      ..add(result);
    await tester.pumpAndSettle();

    expect(find.text('Doğrulama bekleniyor'), findsNothing);
    expect(find.text('Müşteri ana sayfası'), findsOneWidget);
    expect(
      find.text('E-posta adresiniz başarıyla doğrulandı.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('email-confirmation-success-notice')),
      findsOneWidget,
    );
    verify(() => authCubit.checkAuthStatus()).called(1);
  });

  testWidgets('confirmed callback without a session opens login with success', (
    tester,
  ) async {
    when(() => authCubit.state).thenReturn(AuthUnauthenticated());
    await tester.pumpWidget(buildSubject());

    callbacks.add(
      const EmailConfirmationCallbackResult(
        sequence: 2,
        status: EmailConfirmationCallbackStatus.confirmedWithoutSession,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Doğrulama bekleniyor'), findsNothing);
    expect(find.text('Giriş ekranı'), findsOneWidget);
    expect(
      find.text('E-posta adresiniz başarıyla doğrulandı.'),
      findsOneWidget,
    );
    verify(() => authCubit.checkAuthStatus()).called(1);
  });

  testWidgets(
    'success notice skips the first navigation frame and remains until dismissed',
    (tester) async {
      when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));
      await tester.pumpWidget(buildSubject());

      const result = EmailConfirmationCallbackResult(
        sequence: 20,
        status: EmailConfirmationCallbackStatus.authenticated,
      );
      callbacks.add(result);
      await tester.pump();

      expect(
        find.byKey(const Key('email-confirmation-success-notice')),
        findsNothing,
      );

      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('email-confirmation-success-notice')),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 10));
      expect(
        find.byKey(const Key('email-confirmation-success-notice')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('email-confirmation-success-notice-dismiss')),
      );
      await tester.pump();
      callbacks.add(result);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('email-confirmation-success-notice')),
        findsNothing,
      );
      verify(() => authCubit.checkAuthStatus()).called(1);
    },
  );

  testWidgets('an initial callback is handled after the navigator is ready', (
    tester,
  ) async {
    when(() => authCubit.state).thenReturn(const AuthAuthenticated(user));

    await tester.pumpWidget(
      buildSubject(
        initialCallback: const EmailConfirmationCallbackResult(
          sequence: 3,
          status: EmailConfirmationCallbackStatus.authenticated,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Müşteri ana sayfası'), findsOneWidget);
    verify(() => authCubit.checkAuthStatus()).called(1);
  });

  testWidgets('invalid callback stays safe and never refreshes or navigates', (
    tester,
  ) async {
    when(() => authCubit.state).thenReturn(AuthInitial());
    await tester.pumpWidget(buildSubject());

    callbacks.add(
      const EmailConfirmationCallbackResult(
        sequence: 4,
        status: EmailConfirmationCallbackStatus.invalid,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Doğrulama bekleniyor'), findsOneWidget);
    expect(
      find.textContaining('Doğrulama bağlantısı geçersiz'),
      findsOneWidget,
    );
    verifyNever(() => authCubit.checkAuthStatus());
  });
}
