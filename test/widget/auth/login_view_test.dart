import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_in_methods_section.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;

  setUp(() async {
    await sl.reset();
    authCubit = MockAuthCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({TextScaler textScaler = TextScaler.noScaling}) {
    return MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: textScaler),
        child: child!,
      ),
      home: const LoginView(),
    );
  }

  testWidgets('müşteri markasını ve yeni karşılama metnini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byKey(const Key('customer-login-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-login-header')), findsOneWidget);
    expect(find.byKey(const Key('login-wordmark')), findsOneWidget);
    expect(find.byKey(const Key('customer-login-form-card')), findsOneWidget);
    expect(find.text('EsnaftaVar'), findsOneWidget);
    expect(find.text('Hoş geldiniz,'), findsOneWidget);
    expect(
      find.text('İhtiyacınız olan ürünler, hemen yakınınızda.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('login-email')), findsOneWidget);
    expect(find.byKey(const Key('login-password')), findsOneWidget);
  });

  testWidgets(
    'sosyal girişleri ve müşteri ekranındaki esnaf girişini göstermez',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(SignInMethodsSection), findsNothing);
      expect(find.text('veya şununla giriş yap'), findsNothing);
      expect(find.text('Esnaf Girişi'), findsNothing);
      expect(find.text('Esnaf kaydı'), findsOneWidget);
    },
  );

  testWidgets('Esnaf kaydı güvenli mağaza bilgilendirmesini açar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const Key('merchant-registration-link')),
    );
    await tester.tap(find.byKey(const Key('merchant-registration-link')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('merchant-registration-dialog')),
      findsOneWidget,
    );
    expect(find.text('Esnafta Var İşletme'), findsOneWidget);
    expect(
      find.textContaining('yakında uygulama mağazalarında açılacak'),
      findsOneWidget,
    );
    expect(find.byType(LoginView), findsOneWidget);

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('merchant-registration-dialog')), findsNothing);
  });

  testWidgets('dar ekranda ve büyük yazıda aşağı kaydırılabilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(1.4)),
    );
    await tester.pump();

    expect(find.byKey(const Key('customer-login-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('merchant-registration-link')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('merchant-registration-link')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
