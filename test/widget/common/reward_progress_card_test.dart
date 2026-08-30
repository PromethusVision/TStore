import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/components/reward_progress_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';

void main() {
  Widget buildSubject({
    required bool enabled,
    RewardProgressData? data,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      theme: EsnaftaVarTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 358,
            child: RewardProgressSlot(
              enabled: enabled,
              data: data,
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('runtime varsayılanı feature gate kapalıyken içerik göstermez', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(
        enabled: false,
        data: const RewardProgressData(
          progress: 0.5,
          title: 'Yalnız test fixture verisi',
        ),
      ),
    );

    expect(find.byKey(const Key('reward-progress-slot-off')), findsOneWidget);
    expect(find.byKey(const Key('reward-progress-card')), findsNothing);
    expect(find.text('Yalnız test fixture verisi'), findsNothing);
  });

  for (final entry in <double, double>{
    0: 0,
    0.1: 0.1,
    0.5: 0.5,
    0.95: 0.95,
    1: 1,
  }.entries) {
    testWidgets('${entry.key} ilerlemeyi güvenli biçimde gösterir', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          enabled: true,
          data: RewardProgressData(
            progress: entry.key,
            title: 'Mahalle ödül yolculuğu',
            currentMilestone: 'Mevcut adım',
            nextMilestone: 'Sıradaki adım',
          ),
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('reward-progress-indicator')),
      );
      expect(indicator.value, entry.value);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('geçersiz ve aralık dışı ilerlemeyi NaN üretmeden sınırlar', (
    tester,
  ) async {
    for (final expectation in <double, double>{
      double.nan: 0,
      double.infinity: 0,
      -0.4: 0,
      1.7: 1,
    }.entries) {
      await tester.pumpWidget(
        buildSubject(
          enabled: true,
          data: RewardProgressData(
            progress: expectation.key,
            title: 'Güvenli ilerleme',
          ),
        ),
      );
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('reward-progress-indicator')),
      );
      expect(indicator.value, expectation.value);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('uzun başlık ve eksik opsiyonel sonraki adım taşma üretmez', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const longTitle =
        'ÇĞİÖŞÜ ile mahallendeki alışveriş yolculuğunu anlatan oldukça uzun ödül başlığı';
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(
          progress: 0.5,
          title: longTitle,
          currentMilestone: 'Başlangıç adımı',
          contextualMessage:
              'Bu içerik yalnız görsel test fixture verisidir; gerçek bakiye değildir.',
        ),
      ),
    );

    expect(find.text(longTitle), findsOneWidget);
    expect(find.text('Başlangıç adımı'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opsiyonel aksiyon yalnız açık fixture modunda çalışır', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.pumpWidget(
      buildSubject(
        enabled: true,
        data: const RewardProgressData(progress: 0.25, title: 'Ödül yolculuğu'),
        onTap: () => tapCount++,
      ),
    );

    await tester.tap(find.byKey(const Key('reward-progress-card')));
    await tester.pump();
    expect(tapCount, 1);
  });
}
