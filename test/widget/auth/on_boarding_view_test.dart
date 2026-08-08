import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

void main() {
  late MockAuthCubit authCubit;
  late OnBoardingCubit onBoardingCubit;

  setUp(() async {
    await sl.reset();
    authCubit = MockAuthCubit();
    onBoardingCubit = OnBoardingCubit();
    whenListen(
      authCubit,
      const Stream<AuthState>.empty(),
      initialState: AuthInitial(),
    );
    when(() => authCubit.close()).thenAnswer((_) async {});
    sl.registerFactory<AuthCubit>(() => authCubit);
  });

  tearDown(() async {
    await onBoardingCubit.close();
    await sl.reset();
  });

  Widget buildSubject({TextScaler textScaler = TextScaler.noScaling}) {
    return BlocProvider<OnBoardingCubit>.value(
      value: onBoardingCubit,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: textScaler),
          child: child!,
        ),
        home: const OnBoardingView(),
      ),
    );
  }

  testWidgets('musteri markasini ve ilk tanitim adimini gosterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(
      find.byKey(const Key('customer-onboarding-content')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('customer-onboarding-header')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-wordmark')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-page-view')), findsOneWidget);
    expect(find.byKey(const Key('customer-onboarding-footer')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-dot-navigation')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-next')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
    expect(find.text('EsnaftaVar'), findsOneWidget);
    expect(find.text(TTexts.onBoardingTitle1), findsOneWidget);
    expect(find.text('Geç'), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gec dogrudan giris ekranini acar', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(OnBoardingView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Devam adimlari ilerletir ve Basla giris ekranini acar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();

    expect(onBoardingCubit.currentIndex, 1);
    expect(find.text(TTexts.onBoardingTitle2), findsOneWidget);
    expect(find.text('Devam'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();

    expect(onBoardingCubit.currentIndex, 2);
    expect(find.text(TTexts.onBoardingTitle3), findsOneWidget);
    expect(find.text('Başla'), findsOneWidget);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();

    expect(find.byType(LoginView), findsOneWidget);
    expect(find.byType(OnBoardingView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dar ekranda ve buyuk yazida tasma olmaz', (tester) async {
    tester.view.physicalSize = const Size(320, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      buildSubject(textScaler: const TextScaler.linear(1.4)),
    );
    await tester.pump();

    expect(find.byKey(const Key('customer-onboarding-header')), findsOneWidget);
    expect(find.byKey(const Key('customer-onboarding-footer')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-next')), findsOneWidget);
    expect(find.byKey(const Key('onboarding-skip')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();

    expect(onBoardingCubit.currentIndex, 1);
    expect(tester.takeException(), isNull);
  });
}
