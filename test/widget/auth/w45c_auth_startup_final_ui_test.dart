import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';
import 'package:t_store/features/auth/presentation/views/legal/legal_document_views.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/customer_launch_gate.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/reset_password_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/update_password_view.dart';
import 'package:t_store/features/auth/presentation/views/signup/sign_up_view.dart';
import 'package:t_store/features/auth/presentation/views/signup/verify_email_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/email_confirmation_listener.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';

class _Auth extends MockCubit<AuthState> implements AuthCubit {}

const _email = 'uzun.adresli.ornek.musteri@example.com';
const _identity = PasswordRecoveryIdentity(
  userId: 'fixture-customer',
  email: _email,
);
const _surfaces = [
  'launch',
  'onboarding',
  'login',
  'signup',
  'verify',
  'forgot',
  'reset',
  'update',
  'invalid',
  'kvkk',
  'terms',
];
const _submits = {
  'login': 'login-submit',
  'signup': 'signup-submit',
  'forgot': 'forgot-password-submit',
  'update': 'update-password-submit',
};
const _bottoms = {
  'login': 'merchant-registration-link',
  'signup': 'signup-submit',
  'verify': 'verify-email-resend',
  'forgot': 'forgot-password-submit',
  'reset': 'reset-email-resend',
  'update': 'update-password-submit',
  'invalid': 'invalid-password-recovery-login',
  'kvkk': 'customer-legal-section-6',
  'terms': 'customer-legal-section-6',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Auth auth;
  late StreamController<AuthState> states;
  late OnBoardingCubit onboarding;

  setUpAll(() async {
    final font = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
      ..addFont(
        rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
      );
    await Future.wait([font.load(), icons.load(), iconsax.load()]);
  });

  setUp(() async {
    await sl.reset();
    auth = _Auth();
    states = StreamController<AuthState>.broadcast();
    whenListen(auth, states.stream, initialState: AuthInitial());
    when(() => auth.close()).thenAnswer((_) async {});
    when(() => auth.checkAuthStatus()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => auth);
    onboarding = OnBoardingCubit(
      completionWriter: () async {},
      destinationBuilder: (_) => const Scaffold(body: Text('Keşfet')),
    );
  });

  tearDown(() async {
    await states.close();
    await onboarding.close();
    await sl.reset();
  });

  Widget page(String name) => switch (name) {
    'launch' => CustomerLaunchGate(
      statusProvider: () => Completer<bool>().future,
    ),
    'onboarding' => const OnBoardingView(),
    'login' => const LoginView(),
    'signup' => const SignUpView(),
    'verify' => const VerifyEmailView(email: _email),
    'forgot' => const ForgetPasswordView(),
    'reset' => const ResetPasswordView(email: _email),
    'update' => const UpdatePasswordView(recoveryIdentity: _identity),
    'invalid' => const InvalidPasswordRecoveryView(),
    'kvkk' => const KvkkInformationView(),
    'terms' => const TermsOfUseView(),
    _ => throw ArgumentError(name),
  };

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double width = 390,
    double scale = 1,
    double keyboard = 0,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: auth),
          BlocProvider<OnBoardingCubit>.value(value: onboarding),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: RepaintBoundary(key: const Key('w45c-capture'), child: child),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> visible(WidgetTester tester, String key) async {
    final target = find.byKey(Key(key));
    await tester.scrollUntilVisible(
      target,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(target);
    await tester.pump();
    expect(target, findsOneWidget);
  }

  for (final surface in _surfaces) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('W45C $surface $width 130% reaches all content', (
        tester,
      ) async {
        await mount(tester, page(surface), width: width, scale: 1.3);
        expect(tester.takeException(), isNull);
        if (width == 320) {
          await expectLater(
            find.byKey(const Key('w45c-capture')),
            matchesGoldenFile('goldens/w45c_${surface}_320_130.png'),
          );
        }
        if (_bottoms[surface] case final String bottom) {
          await visible(tester, bottom);
          expect(tester.takeException(), isNull);
        }
        if (_submits[surface] case final String submit) {
          await visible(tester, submit);
          await tester.tap(find.byKey(Key(submit)));
          await tester.pump();
          expect(find.textContaining('zorunludur.'), findsWidgets);
          expect(tester.takeException(), isNull);
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
    testWidgets('W45C $surface 390 visual evidence', (tester) async {
      await mount(tester, page(surface));
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w45c-capture')),
        matchesGoldenFile('goldens/w45c_${surface}_390.png'),
      );
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (final surface in _submits.keys) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('W45C $surface keyboard + loading at $width 130%', (
        tester,
      ) async {
        await mount(
          tester,
          page(surface),
          width: width,
          scale: 1.3,
          keyboard: 300,
        );
        final submit = _submits[surface]!;
        await visible(tester, submit);
        final rect = tester.getRect(find.byKey(Key(submit)));
        expect(rect.bottom, lessThanOrEqualTo(544));
        expect(rect.height, greaterThanOrEqualTo(44));
        states.add(AuthLoading());
        await tester.pumpAndSettle();
        for (final field in tester.widgetList<TextField>(
          find.byType(TextField),
        )) {
          expect(field.readOnly, isTrue);
        }
        expect(
          tester.widget<ElevatedButton>(find.byKey(Key(submit))).onPressed,
          isNull,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('W45C signup autofill, legal semantics and touch targets', (
    tester,
  ) async {
    await mount(tester, page('signup'), width: 320, scale: 1.3);
    final semantics = tester.ensureSemantics();
    try {
      for (final entry in const {
        'signup-first-name': AutofillHints.givenName,
        'signup-last-name': AutofillHints.familyName,
        'signup-email': AutofillHints.email,
        'signup-phone': AutofillHints.telephoneNumber,
        'signup-password': AutofillHints.newPassword,
        'signup-confirm-password': AutofillHints.newPassword,
      }.entries) {
        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byKey(Key(entry.key)),
            matching: find.byType(TextField),
          ),
        );
        expect(field.autofillHints, contains(entry.value));
      }
      for (final key in ['open-privacy-notice', 'open-terms-of-use']) {
        await visible(tester, key);
        expect(
          tester.getSize(find.byKey(Key(key))).height,
          greaterThanOrEqualTo(44),
        );
      }
      for (final checkbox in tester.widgetList<Checkbox>(
        find.byType(Checkbox),
      )) {
        expect(checkbox.semanticLabel, isNotEmpty);
        expect(checkbox.value, isFalse);
      }
      await visible(tester, 'signup-password');
      final toggle = find.byTooltip('Şifreyi göster');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const Key('signup-password')),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isFalse,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const Key('signup-confirm-password')),
                matching: find.byType(TextField),
              ),
            )
            .obscureText,
        isFalse,
      );
      expect(find.byTooltip('Şifreyi gizle'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('W45C update success state and large text visual evidence', (
    tester,
  ) async {
    await mount(tester, page('update'), width: 320, scale: 1.3);
    states.add(AuthPasswordUpdated());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('update-password-new')), findsNothing);
    expect(find.text('Şifreniz yenilendi'), findsOneWidget);
    await expectLater(
      find.byKey(const Key('w45c-capture')),
      matchesGoldenFile('goldens/w45c_update_success_320_130.png'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('W45C long form errors stay visible with keyboard', (
    tester,
  ) async {
    await mount(tester, page('signup'), width: 320, scale: 1.3, keyboard: 300);
    await visible(tester, 'signup-submit');
    await tester.tap(find.byKey(const Key('signup-submit')));
    await tester.pump();
    await visible(tester, 'privacy-notice-agreement');
    expect(
      find.textContaining('aydınlatma metnini okuduğunuzu'),
      findsOneWidget,
    );
    await expectLater(
      find.byKey(const Key('w45c-capture')),
      matchesGoldenFile('goldens/w45c_signup_errors_keyboard_320_130.png'),
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('W45C merchant information dialog $width 130%', (tester) async {
      await mount(tester, page('login'), width: width, scale: 1.3);
      await visible(tester, 'merchant-registration-link');
      await tester.tap(find.byKey(const Key('merchant-registration-link')));
      await tester.pumpAndSettle();
      expect(find.text('Esnafta Var İşletme'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (width == 390) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/w45c_merchant_info_390_130.png'),
        );
      }
      await tester.tap(find.text('Tamam'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('merchant-registration-dialog')),
        findsNothing,
      );
    });

    testWidgets('W45C wrong merchant role dialog $width 130%', (tester) async {
      await mount(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: CustomerAuthFormCard(
              child: LoginFormSection(isMerchantLogin: true),
            ),
          ),
        ),
        width: width,
        scale: 1.3,
      );
      states.add(
        const AuthAuthenticated(
          UserEntity(id: 'fixture-customer', email: _email),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Esnaf hesabı değil'), findsOneWidget);
      expect(find.text('Müşteri olarak devam et'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (width == 390) {
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('goldens/w45c_wrong_role_390_130.png'),
        );
      }
      await tester.tap(find.text('Çıkış yap'));
      await tester.pumpAndSettle();
      verify(() => auth.signOut()).called(1);
    });

    testWidgets(
      'W45C confirmation overlay $width 130% dismisses without navigation',
      (tester) async {
        final callbacks =
            StreamController<EmailConfirmationCallbackResult>.broadcast();
        final navigator = GlobalKey<NavigatorState>();
        final messenger = GlobalKey<ScaffoldMessengerState>();
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          BlocProvider<AuthCubit>.value(
            value: auth,
            child: EmailConfirmationListener(
              callbacks: callbacks.stream,
              navigatorKey: navigator,
              scaffoldMessengerKey: messenger,
              authenticatedDestinationBuilder: (_) =>
                  const Scaffold(body: Text('Keşfet')),
              unauthenticatedDestinationBuilder: (_) => const LoginView(),
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: EsnaftaVarTheme.light,
                navigatorKey: navigator,
                scaffoldMessengerKey: messenger,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: const TextScaler.linear(1.3)),
                  child: child!,
                ),
                home: const Scaffold(),
              ),
            ),
          ),
        );
        callbacks.add(
          const EmailConfirmationCallbackResult(
            sequence: 1,
            status: EmailConfirmationCallbackStatus.confirmedWithoutSession,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(LoginView), findsOneWidget);
        expect(
          find.text('E-posta adresiniz başarıyla doğrulandı.'),
          findsOneWidget,
        );
        final dismiss = find.byKey(
          const Key('email-confirmation-success-notice-dismiss'),
        );
        expect(tester.getSize(dismiss).height, greaterThanOrEqualTo(44));
        expect(tester.takeException(), isNull);
        if (width == 390) {
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('goldens/w45c_confirmation_notice_390_130.png'),
          );
        }
        await tester.tap(dismiss);
        await tester.pump();
        expect(
          find.byKey(const Key('email-confirmation-success-notice')),
          findsNothing,
        );
        expect(find.byType(LoginView), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await callbacks.close();
      },
    );
  }
}
