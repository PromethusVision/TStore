import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/auth/presentation/logic/on_boarding/on_boarding_cubit.dart';
import 'package:t_store/features/auth/presentation/views/on_boarding/on_boarding_view.dart';

void main() {
  late OnBoardingCubit onBoardingCubit;
  late int completionWriteCount;

  setUp(() {
    completionWriteCount = 0;
    onBoardingCubit = OnBoardingCubit(
      completionWriter: () async {
        completionWriteCount++;
      },
      destinationBuilder: (_) => const Scaffold(
        key: Key('customer-home-destination'),
        body: Text('Müşteri ana sayfası'),
      ),
    );
  });

  tearDown(() async {
    await onBoardingCubit.close();
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

  testWidgets('Gec tercihi kaydeder ve misafir ana sayfasini acar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(completionWriteCount, 1);
    expect(find.byKey(const Key('customer-home-destination')), findsOneWidget);
    expect(find.byType(OnBoardingView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Devam adimlari ilerletir ve Basla misafir ana sayfasini acar', (
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

    expect(completionWriteCount, 1);
    expect(find.byKey(const Key('customer-home-destination')), findsOneWidget);
    expect(find.byType(OnBoardingView), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hizli cift dokunus tamamlanma kaydini tekrarlamaz', (
    tester,
  ) async {
    final completion = Completer<void>();
    await onBoardingCubit.close();
    onBoardingCubit = OnBoardingCubit(
      completionWriter: () {
        completionWriteCount++;
        return completion.future;
      },
      destinationBuilder: (_) =>
          const Scaffold(key: Key('customer-home-destination')),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.tap(find.byKey(const Key('onboarding-skip')));
    await tester.pump();

    expect(completionWriteCount, 1);

    completion.complete();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-home-destination')), findsOneWidget);
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

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('W45C onboarding accessible steps at $width / 130%', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        buildSubject(textScaler: const TextScaler.linear(1.3)),
      );
      await tester.pump();
      for (var index = 0; index < 3; index++) {
        final target = find.byKey(ValueKey('onboarding-step-$index'));
        final size = tester.getSize(target);
        expect(size.width, greaterThanOrEqualTo(44));
        expect(size.height, greaterThanOrEqualTo(44));
        expect(
          find.byTooltip('${index + 1}. tanıtım adımı, toplam 3'),
          findsOneWidget,
        );
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(onBoardingCubit.currentIndex, index);
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Başla'), findsOneWidget);
      expect(completionWriteCount, 0);
      semantics.dispose();
    });
  }
}
