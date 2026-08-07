import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/signup/verify_email_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  const email = 'musteri@example.com';

  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: const AuthEmailConfirmationRequired(email),
    );
    when(() => authCubit.resendConfirmation(any())).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authCubit.close();
  });

  Widget buildSubject({
    int cooldownSeconds = 60,
    TextScaler textScaler = TextScaler.noScaling,
  }) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: VerifyEmailView(
          email: email,
          resendCooldownSeconds: cooldownSeconds,
        ),
      ),
    );
  }

  Widget buildReturnSubject() {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  key: const Key('open-special-verification'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const VerifyEmailView(
                          email: email,
                          returnToCallerAfterCustomerLogin: true,
                        ),
                      ),
                    );
                  },
                  child: const Text('Önceki giriş ekranı'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('shows the real email and never claims verification succeeded', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    expect(
      find.byKey(const Key('customer-verify-email-content')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('customer-verify-email-header')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('verify-email-wordmark')), findsOneWidget);
    expect(find.byKey(const Key('customer-verify-email-card')), findsOneWidget);
    expect(find.byKey(const Key('verify-email-icon')), findsOneWidget);
    expect(find.byKey(const Key('verify-email-address-card')), findsOneWidget);
    expect(find.byKey(const Key('verify-email-spam-hint')), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    expect(find.text('E-posta adresinizi doğrulayın'), findsOneWidget);
    expect(find.textContaining('60 saniye sonra'), findsOneWidget);
    expect(find.textContaining('başarıyla oluşturuldu'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('enables resend only after the cooldown', (tester) async {
    await tester.pumpWidget(buildSubject(cooldownSeconds: 1));

    var resendButton = tester.widget<TextButton>(
      find.byKey(const Key('verify-email-resend')),
    );
    expect(resendButton.onPressed, isNull);

    await tester.pump(const Duration(seconds: 1));

    resendButton = tester.widget<TextButton>(
      find.byKey(const Key('verify-email-resend')),
    );
    expect(resendButton.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('resends once with the displayed email', (tester) async {
    await tester.pumpWidget(buildSubject(cooldownSeconds: 0));

    final resendFinder = find.byKey(const Key('verify-email-resend'));
    await tester.ensureVisible(resendFinder);
    await tester.pump();
    await tester.tap(resendFinder);
    await tester.pump();

    verify(() => authCubit.resendConfirmation(email)).called(1);
  });

  testWidgets('loading state disables resend and prevents double submit', (
    tester,
  ) async {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(cooldownSeconds: 0));

    final resendButton = tester.widget<TextButton>(
      find.byKey(const Key('verify-email-resend')),
    );
    expect(resendButton.onPressed, isNull);
    expect(find.text('Gönderiliyor...'), findsOneWidget);
  });

  testWidgets('shows success feedback and restarts the cooldown', (
    tester,
  ) async {
    whenListen(
      authCubit,
      Stream<AuthState>.value(const AuthConfirmationResent(email)),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(cooldownSeconds: 1));
    await tester.pump();

    expect(
      find.text('Doğrulama e-postası yeniden gönderildi.'),
      findsOneWidget,
    );
    expect(find.textContaining('1 saniye sonra'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows a safe error when resend fails', (tester) async {
    whenListen(
      authCubit,
      Stream<AuthState>.value(const AuthError('Çok fazla deneme yapıldı.')),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject(cooldownSeconds: 0));
    await tester.pump();

    expect(find.text('Çok fazla deneme yapıldı.'), findsOneWidget);
  });

  testWidgets('returns to a clean login screen', (tester) async {
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

    await tester.pumpWidget(buildSubject());

    final loginFinder = find.byKey(const Key('verify-email-back-to-login'));
    await tester.ensureVisible(loginFinder);
    await tester.pump();
    await tester.tap(loginFinder);
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(VerifyEmailView), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('special verification returns to the preserved login route', (
    tester,
  ) async {
    await tester.pumpWidget(buildReturnSubject());
    await tester.tap(find.byKey(const Key('open-special-verification')));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailView), findsOneWidget);
    await tester.ensureVisible(
      find.byKey(const Key('verify-email-back-to-login')),
    );
    await tester.tap(find.byKey(const Key('verify-email-back-to-login')));
    await tester.pumpAndSettle();

    expect(find.byType(VerifyEmailView), findsNothing);
    expect(find.text('Önceki giriş ekranı'), findsOneWidget);
    expect(find.byType(LoginView), findsNothing);
  });

  testWidgets('does not overflow on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(1.4)),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('customer-verify-email-scroll')),
      findsOneWidget,
    );
    expect(find.text(email), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('verify-email-resend')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('verify-email-resend')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
