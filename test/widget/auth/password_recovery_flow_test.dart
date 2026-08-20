import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/reset_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/update_password_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const email = 'musteri@example.com';
  const newPassword = 'NewStrong1!';

  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.resetPassword(any())).thenAnswer((_) async {});
    when(() => authCubit.updatePassword(any())).thenAnswer((_) async {});
    when(() => authCubit.signOut()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authCubit.close();
  });

  Widget buildSubject(
    Widget child, {
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        builder: (context, routeChild) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: routeChild!,
        ),
        home: child,
      ),
    );
  }

  testWidgets('shows the customer brand and reset request form', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const ForgetPasswordView()));

    expect(
      find.byKey(const Key('customer-forgot-password-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-forgot-password-header')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('forgot-password-wordmark')), findsOneWidget);
    expect(
      find.byKey(const Key('customer-forgot-password-form-card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('forgot-password-email')), findsOneWidget);
    expect(find.byKey(const Key('forgot-password-submit')), findsOneWidget);
    expect(find.text('Şifremi unuttum'), findsOneWidget);
  });

  testWidgets('custom back button returns to the previous screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const Key('open-forgot-password'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ForgetPasswordView(),
                ),
              ),
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-forgot-password')));
    await tester.pumpAndSettle();
    expect(find.byType(ForgetPasswordView), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer-forgot-password-back')));
    await tester.pumpAndSettle();

    expect(find.byType(ForgetPasswordView), findsNothing);
    expect(find.byKey(const Key('open-forgot-password')), findsOneWidget);
  });

  testWidgets('reset request form supports narrow screens and larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        const ForgetPasswordView(),
        textScaler: const TextScaler.linear(1.4),
      ),
    );

    expect(
      find.byKey(const Key('customer-forgot-password-scroll')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('forgot-password-submit')),
      250,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('forgot-password-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('validates the email before requesting a reset link', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const ForgetPasswordView()));

    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pump();
    expect(find.text('E-posta alanı zorunludur.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot-password-email')),
      'gecersiz',
    );
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pump();
    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);

    verifyNever(() => authCubit.resetPassword(any()));
  });

  testWidgets('requests one reset email with a normalized address', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const ForgetPasswordView()));

    await tester.enterText(
      find.byKey(const Key('forgot-password-email')),
      '  MUSTERI@EXAMPLE.COM  ',
    );
    await tester.ensureVisible(find.byKey(const Key('forgot-password-submit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('forgot-password-submit')));
    await tester.pump();

    verify(() => authCubit.resetPassword(email)).called(1);
  });

  testWidgets('loading disables the reset request button', (tester) async {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(const ForgetPasswordView()));

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('forgot-password-submit')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Gönderiliyor...'), findsOneWidget);
  });

  testWidgets('successful request opens the waiting screen with real email', (
    tester,
  ) async {
    final stateController = StreamController<AuthState>();
    whenListen(authCubit, stateController.stream, initialState: AuthInitial());
    addTearDown(stateController.close);

    await tester.pumpWidget(buildSubject(const ForgetPasswordView()));
    stateController.add(const AuthPasswordResetSent(email));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ResetPasswordView), findsOneWidget);
    expect(
      find.byKey(const Key('customer-reset-email-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-reset-email-header')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('reset-email-wordmark')), findsOneWidget);
    expect(find.byKey(const Key('customer-reset-email-card')), findsOneWidget);
    expect(find.byKey(const Key('reset-email-icon')), findsOneWidget);
    expect(find.byKey(const Key('reset-email-address-card')), findsOneWidget);
    expect(find.byKey(const Key('reset-email-spam-hint')), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    expect(find.textContaining('sistemde kayıtlıysa'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('waiting screen supports narrow screens and larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        const ResetPasswordView(email: email),
        textScaler: const TextScaler.linear(1.4),
      ),
    );

    expect(
      find.byKey(const Key('customer-reset-email-scroll')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('reset-email-resend')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('reset-email-resend')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('waiting screen enables resend only after the cooldown', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        const ResetPasswordView(email: email, resendCooldownSeconds: 1),
      ),
    );

    var resendButton = tester.widget<TextButton>(
      find.byKey(const Key('reset-email-resend')),
    );
    expect(resendButton.onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));

    resendButton = tester.widget<TextButton>(
      find.byKey(const Key('reset-email-resend')),
    );
    expect(resendButton.onPressed, isNotNull);

    await tester.ensureVisible(find.byKey(const Key('reset-email-resend')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('reset-email-resend')));
    await tester.pump();

    verify(() => authCubit.resetPassword(email)).called(1);
    resendButton = tester.widget<TextButton>(
      find.byKey(const Key('reset-email-resend')),
    );
    expect(resendButton.onPressed, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('waiting screen returns to a clean login screen', (tester) async {
    final loginAuthCubit = MockAuthCubit();
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
      await loginAuthCubit.close();
    });

    await tester.pumpWidget(
      buildSubject(const ResetPasswordView(email: email)),
    );
    await tester.ensureVisible(
      find.byKey(const Key('reset-email-back-to-login')),
    );
    await tester.tap(find.byKey(const Key('reset-email-back-to-login')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(ResetPasswordView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('new password form validates strength and confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));

    expect(
      find.byKey(const Key('customer-update-password-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-update-password-header')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('update-password-wordmark')), findsOneWidget);
    expect(
      find.byKey(const Key('customer-update-password-card')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('update-password-icon')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('update-password-new')),
      newPassword,
    );
    await tester.enterText(
      find.byKey(const Key('update-password-confirm')),
      'Different1!',
    );
    await tester.ensureVisible(find.byKey(const Key('update-password-submit')));
    await tester.tap(find.byKey(const Key('update-password-submit')));
    await tester.pump();

    expect(find.text('Şifreler eşleşmiyor.'), findsOneWidget);
    verifyNever(() => authCubit.updatePassword(any()));
  });

  testWidgets('new password visibility controls work independently', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));

    bool isObscured(Key fieldKey) {
      return tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(fieldKey),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;
    }

    expect(isObscured(const Key('update-password-new')), isTrue);
    expect(isObscured(const Key('update-password-confirm')), isTrue);

    await tester.tap(find.byKey(const Key('update-password-toggle-new')));
    await tester.pump();

    expect(isObscured(const Key('update-password-new')), isFalse);
    expect(isObscured(const Key('update-password-confirm')), isTrue);

    await tester.tap(find.byKey(const Key('update-password-toggle-confirm')));
    await tester.pump();

    expect(isObscured(const Key('update-password-confirm')), isFalse);
  });

  testWidgets('new password inputs disable keyboard rewriting', (tester) async {
    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));

    for (final fieldKey in const [
      Key('update-password-new'),
      Key('update-password-confirm'),
    ]) {
      final field = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(fieldKey),
          matching: find.byType(EditableText),
        ),
      );
      expect(field.keyboardType, TextInputType.visiblePassword);
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
    }
  });

  testWidgets('submits a valid new password only once', (tester) async {
    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));

    await tester.enterText(
      find.byKey(const Key('update-password-new')),
      newPassword,
    );
    await tester.enterText(
      find.byKey(const Key('update-password-confirm')),
      newPassword,
    );
    await tester.ensureVisible(find.byKey(const Key('update-password-submit')));
    await tester.tap(find.byKey(const Key('update-password-submit')));
    await tester.pump();

    verify(() => authCubit.updatePassword(newPassword)).called(1);
  });

  testWidgets('loading prevents a second password update', (tester) async {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('update-password-submit')),
    );
    final closeButton = tester.widget<IconButton>(
      find.byKey(const Key('update-password-close')),
    );
    expect(button.onPressed, isNull);
    expect(closeButton.onPressed, isNull);
    expect(find.text('Kaydediliyor...'), findsOneWidget);
  });

  testWidgets('shows success only after the password is updated', (
    tester,
  ) async {
    whenListen(
      authCubit,
      Stream<AuthState>.value(AuthPasswordUpdated()),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));
    expect(find.text('Şifreniz yenilendi'), findsNothing);

    await tester.pump();

    expect(find.byKey(const Key('update-password-success')), findsOneWidget);
    expect(
      find.byKey(const Key('update-password-success-icon')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('update-password-new')), findsNothing);
  });

  testWidgets('signs out before returning to the login screen', (tester) async {
    final stateController = StreamController<AuthState>();
    whenListen(authCubit, stateController.stream, initialState: AuthLoading());
    when(() => authCubit.signOut()).thenAnswer((_) async {
      stateController.add(AuthUnauthenticated());
      await Future<void>.delayed(Duration.zero);
    });

    final loginAuthCubit = MockAuthCubit();
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
      await stateController.close();
      if (sl.isRegistered<AuthCubit>()) {
        await sl.unregister<AuthCubit>();
      }
      await loginAuthCubit.close();
    });

    await tester.pumpWidget(buildSubject(const UpdatePasswordView()));
    stateController.add(AuthPasswordUpdated());
    await tester.pump();
    await tester.tap(find.byKey(const Key('update-password-back-to-login')));
    await tester.pumpAndSettle();

    verify(() => authCubit.signOut()).called(1);
    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(UpdatePasswordView), findsNothing);
  });

  testWidgets('password recovery screens do not overflow when narrow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        const UpdatePasswordView(),
        textScaler: const TextScaler.linear(1.4),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('customer-update-password-scroll')),
      findsOneWidget,
    );
    expect(find.text('Yeni şifrenizi belirleyin'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('update-password-submit')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('update-password-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
