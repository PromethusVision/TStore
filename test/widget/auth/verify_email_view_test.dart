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

  Widget buildSubject({int cooldownSeconds = 60}) {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp(
        home: VerifyEmailView(
          email: email,
          resendCooldownSeconds: cooldownSeconds,
        ),
      ),
    );
  }

  testWidgets('shows the real email and never claims verification succeeded', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

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

  testWidgets('does not overflow on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());

    expect(tester.takeException(), isNull);
    expect(find.text(email), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
