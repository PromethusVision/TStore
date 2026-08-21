import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/signup/sign_up_view.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;

  setUp(() {
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(
      () => authCubit.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await authCubit.close();
    if (sl.isRegistered<AuthCubit>()) {
      await sl.unregister<AuthCubit>();
    }
  });

  Widget buildSubject() {
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: LoginFormSection())),
      ),
    );
  }

  testWidgets('validates email and password before signing in', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('E-posta alanı zorunludur.'), findsOneWidget);
    expect(find.text('Şifrenizi girin.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('login-email')), 'gecersiz');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    expect(find.text('Geçerli bir e-posta adresi girin.'), findsOneWidget);
    verifyNever(
      () => authCubit.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('normalizes the email before signing in', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
      find.byKey(const Key('login-email')),
      '  MUSTERI@EXAMPLE.COM  ',
    );
    await tester.enterText(find.byKey(const Key('login-password')), 'Strong1!');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    verify(
      () =>
          authCubit.signIn(email: 'musteri@example.com', password: 'Strong1!'),
    ).called(1);
  });

  testWidgets('preserves the password exactly when signing in', (tester) async {
    await tester.pumpWidget(buildSubject());

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'musteri@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      ' Strong1! ',
    );
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pump();

    verify(
      () => authCubit.signIn(
        email: 'musteri@example.com',
        password: ' Strong1! ',
      ),
    ).called(1);
  });

  testWidgets('password input disables keyboard rewriting', (tester) async {
    await tester.pumpWidget(buildSubject());

    final passwordField = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('login-password')),
        matching: find.byType(EditableText),
      ),
    );

    expect(passwordField.keyboardType, TextInputType.visiblePassword);
    expect(passwordField.autocorrect, isFalse);
    expect(passwordField.enableSuggestions, isFalse);
  });

  testWidgets('loading disables sign in and communicates progress', (
    tester,
  ) async {
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildSubject());

    final button = tester.widget<ElevatedButton>(
      find.byKey(const Key('login-submit')),
    );
    expect(button.onPressed, isNull);
    expect(find.text('İşleniyor...'), findsOneWidget);
  });

  testWidgets('shows a safe connection message', (tester) async {
    whenListen(
      authCubit,
      Stream<AuthState>.value(
        const AuthError('İnternet bağlantınızı kontrol edip tekrar deneyin.'),
      ),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(
      find.text('İnternet bağlantınızı kontrol edip tekrar deneyin.'),
      findsOneWidget,
    );
  });

  testWidgets('message intent is carried to the create account screen', (
    tester,
  ) async {
    final signUpAuthCubit = MockAuthCubit();
    whenListen(
      signUpAuthCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => signUpAuthCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => signUpAuthCubit);

    await tester.pumpWidget(
      BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LoginFormSection(returnToCallerAfterCustomerLogin: true),
            ),
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('Hesap Oluştur'));
    await tester.tap(find.text('Hesap Oluştur'));
    await tester.pumpAndSettle();

    final signUpView = tester.widget<SignUpView>(find.byType(SignUpView));
    expect(signUpView.returnToCallerAfterCustomerLogin, isTrue);
  });
}
