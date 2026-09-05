// Deterministic contact sheets arrange real Flutter screenshots; no UI is
// generated or repainted inside the source screenshots.
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'sweep_test_support.dart';

const _proofs = [
  (
    '01',
    'Alışverişler · C1',
    'test/widget/purchases/goldens/w47_purchases_390.png',
  ),
  (
    '02',
    'Ürün değerlendirmeleri',
    'test/widget/shop/goldens/w47_reviews_390.png',
  ),
  ('03', 'Esnafla sohbet · C1', 'test/widget/chat/goldens/w47_chat_390.png'),
  (
    '04',
    'Mesaj kutusu',
    'test/prototypes/astra_sweep_3b/goldens/04_inbox_390.png',
  ),
  (
    '05',
    'Esnaf değerlendirmelerim',
    'test/prototypes/astra_sweep_3b/goldens/05_shop_ratings_390.png',
  ),
  (
    '06',
    'Esnafa puan ver',
    'test/prototypes/astra_sweep_3b/goldens/06_shop_rating_editor_390.png',
  ),
  (
    '07',
    'Yorum düzenleme',
    'test/prototypes/astra_sweep_3b/goldens/07_review_editor_390.png',
  ),
  (
    '08',
    'Yorum silme onayı',
    'test/prototypes/astra_sweep_3b/goldens/08_review_delete_390.png',
  ),
  (
    '09',
    'Favorilerim',
    'test/prototypes/astra_sweep_3b/goldens/09_wishlist_390.png',
  ),
  (
    '10',
    'Son görüntülediklerim',
    'test/prototypes/astra_sweep_3b/goldens/10_recently_viewed_390.png',
  ),
  (
    '11',
    'Bildirimlerim',
    'test/prototypes/astra_sweep_3b/goldens/11_notifications_390.png',
  ),
  (
    '12',
    'Kuponlarım',
    'test/prototypes/astra_sweep_3b/goldens/12_coupons_390.png',
  ),
];

void main() {
  setUpAll(loadW47Fonts);
  for (var sheet = 0; sheet < 2; sheet++) {
    final entries = _proofs.skip(sheet * 6).take(6).toList();
    final range = '${entries.first.$1}_${entries.last.$1}';
    testWidgets('contact sheet $range uses six numbered 390 px proofs', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(806, 1240);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final images = entries
          .map((entry) => MemoryImage(File(entry.$3).readAsBytesSync()))
          .toList();
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('contact-evidence'),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: EsnaftaVarTheme.light,
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ASTRA · VISUAL SWEEP 3B',
                      style: EsnaftaVarTheme.light.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entries.first.$1}–${entries.last.$1} / 12   ·   Product Owner görsel incelemesi   ·   Her ekran 390 × 844 px',
                      style: EsnaftaVarTheme.light.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var index = 0; index < entries.length; index++)
                          Container(
                            width: 250,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: EsnaftaVarColors.borderDefault,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 38,
                                  child: Text(
                                    '${entries[index].$1}  ${entries[index].$2}',
                                    style: EsnaftaVarTheme
                                        .light
                                        .textTheme
                                        .labelMedium,
                                    maxLines: 2,
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image(
                                    image: images[index],
                                    width: 234,
                                    height: 506.4,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(
        () => Future.wait(
          images.map(
            (provider) => precacheImage(
              provider,
              tester.element(find.byKey(const Key('contact-evidence'))),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final entry in entries) {
        expect(find.text('${entry.$1}  ${entry.$2}'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('contact-evidence')),
        matchesGoldenFile('../../../docs/visual_sweep_3b/contact_$range.png'),
      );
    });
  }
}
