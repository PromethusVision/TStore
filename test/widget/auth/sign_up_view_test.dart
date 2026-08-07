import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/signup/sign_up_view.dart';

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
      home: const SignUpView(),
    );
  }

  testWidgets('müşteri markasını ve hesap oluşturma alanlarını gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.byKey(const Key('customer-signup-content')), findsOneWidget);
    expect(find.byKey(const Key('customer-signup-header')), findsOneWidget);
    expect(find.byKey(const Key('signup-wordmark')), findsOneWidget);
    expect(find.byKey(const Key('customer-signup-form-card')), findsOneWidget);
    expect(find.text('EsnaftaVar'), findsOneWidget);
    expect(find.text('Hesabınızı oluşturalım'), findsOneWidget);
    expect(
      find.text('Yakındaki ürünleri ve esnafı keşfetmeye başlayın.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('signup-first-name')), findsOneWidget);
    expect(find.byKey(const Key('signup-last-name')), findsOneWidget);
    expect(find.byKey(const Key('signup-email')), findsOneWidget);
    expect(find.byKey(const Key('signup-phone')), findsOneWidget);
    expect(find.byKey(const Key('signup-password')), findsOneWidget);
    expect(find.byKey(const Key('signup-confirm-password')), findsOneWidget);
  });

  testWidgets('geri düğmesi önceki ekrana döner', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              key: const Key('open-signup'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SignUpView()),
              ),
              child: const Text('Aç'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-signup')));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpView), findsOneWidget);

    await tester.tap(find.byKey(const Key('customer-signup-back')));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpView), findsNothing);
    expect(find.byKey(const Key('open-signup')), findsOneWidget);
  });

  testWidgets('dar ekranda ve büyük yazıda form kaydırılabilir', (
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

    expect(find.byKey(const Key('customer-signup-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.byKey(const Key('signup-submit')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('signup-submit')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
