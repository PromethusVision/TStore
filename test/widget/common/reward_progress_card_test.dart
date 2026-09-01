import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/components/reward_progress_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';

void main() {
  Widget buildSubject({
    required bool enabled,
    RewardProgressData? data,
    VoidCallback? onTap,
    bool compact = true,
    double textScale = 1,
  }) {
    return MaterialApp(
      theme: EsnaftaVarTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 358,
            child: RewardProgressSlot(
              enabled: enabled,
              data: data,
              onTap: onTap,
              compact: compact,
            ),
          ),
        ),
      ),
    );
  }

  const fixture = RewardProgressData(
    completedTasks: 3,
    rewardAmountText: '100 TL',
  );

  testWidgets('runtime varsayılanı feature gate kapalıyken içerik göstermez', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(enabled: false, data: fixture));

    expect(find.byKey(const Key('reward-progress-slot-off')), findsOneWidget);
    expect(find.byKey(const Key('reward-progress-card')), findsNothing);
    expect(find.text('100 TL'), findsNothing);
  });

  testWidgets('0/5 durumunda beş kalan görevi ve ödül değerini gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(
          completedTasks: 0,
          rewardAmountText: '100 TL',
        ),
      ),
    );

    expect(find.text('Görev yap, kazan'), findsOneWidget);
    expect(find.text('0/5 görev tamamlandı'), findsOneWidget);
    expect(find.text('Ödüle 5 görev kaldı'), findsOneWidget);
    expect(find.text('100 TL'), findsOneWidget);
    _expectFiveSegments();
    expect(tester.takeException(), isNull);
  });

  testWidgets('3/5 durumunda iki kalan görevi hesaplatmadan açıklar', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(enabled: true, data: fixture));

    expect(find.text('3/5 görev tamamlandı'), findsOneWidget);
    expect(find.text('Ödüle 2 görev kaldı'), findsOneWidget);
    expect(find.byKey(const Key('reward-amount')), findsOneWidget);
    _expectFiveSegments();
    expect(tester.takeException(), isNull);
  });

  for (final completedTasks in [1, 2, 4]) {
    testWidgets(
      '$completedTasks/5 ara durumunda kalan görev sayısını açık gösterir',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            enabled: true,
            data: RewardProgressData(
              completedTasks: completedTasks,
              rewardAmountText: '100 TL',
            ),
          ),
        );

        expect(find.text('$completedTasks/5 görev tamamlandı'), findsOneWidget);
        expect(
          find.text('Ödüle ${5 - completedTasks} görev kaldı'),
          findsOneWidget,
        );
        _expectFiveSegments();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('5/5 durumunda tamamlanmış görsel davranışı gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(
          completedTasks: 5,
          rewardAmountText: '100 TL',
        ),
      ),
    );

    expect(find.text('5/5 görev tamamlandı'), findsOneWidget);
    expect(find.text('Ödülü kazandın'), findsOneWidget);
    expect(find.text('Ödüle 0 görev kaldı'), findsNothing);
    _expectFiveSegments();
    expect(tester.takeException(), isNull);
  });

  testWidgets('güvensiz görev değerlerini 0 ile 5 arasında sınırlar', (
    tester,
  ) async {
    const below = RewardProgressData(
      completedTasks: -3,
      rewardAmountText: '100 TL',
    );
    const above = RewardProgressData(
      completedTasks: 8,
      rewardAmountText: '100 TL',
    );

    expect(below.safeCompletedTasks, 0);
    expect(below.remainingTasks, 5);
    expect(above.safeCompletedTasks, 5);
    expect(above.remainingTasks, 0);
    expect(above.isComplete, isTrue);
  });

  testWidgets('uzun sunum metni mobil genişlikte taşma üretmez', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        textScale: 1.3,
        data: const RewardProgressData(
          completedTasks: 4,
          rewardAmountText: '999.999.999,90 TL örnek ödül',
          title: 'ÇĞİÖŞÜ görev yap, kazan yolculuğu',
          subtitle: 'Mahallendeki ödül yolculuğu',
          message:
              'Tutar yalnız sunum fixture verisidir; ödeme davranışı değildir.',
        ),
      ),
    );

    expect(find.byKey(const Key('reward-progress-card')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opsiyonel subtitle yokken message bağımsız gösterilir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(
          completedTasks: 2,
          rewardAmountText: '100 TL',
          message: 'Görev yolculuğun devam ediyor.',
        ),
      ),
    );

    expect(find.text('Görev yolculuğun devam ediyor.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opsiyonel message yokken subtitle bağımsız gösterilir', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(
          completedTasks: 2,
          rewardAmountText: '100 TL',
          subtitle: 'Beş görevlik ödül döngüsü',
        ),
      ),
    );

    expect(find.text('Beş görevlik ödül döngüsü'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opsiyonel aksiyon yalnız açık fixture modunda çalışır', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      buildSubject(enabled: true, data: fixture, onTap: () => tapCount++),
    );

    await tester.tap(find.byKey(const Key('reward-progress-card')));
    await tester.pump();
    expect(tapCount, 1);
  });
}

void _expectFiveSegments() {
  for (var index = 0; index < RewardProgressData.taskCycleTotal; index++) {
    expect(find.byKey(Key('reward-task-segment-$index')), findsOneWidget);
  }
  expect(find.byKey(const Key('reward-task-segment-5')), findsNothing);
}
