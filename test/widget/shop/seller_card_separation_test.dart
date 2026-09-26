import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/presentation/widgets/seller_comparison_offer_card.dart';

void main() {
  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('seller surfaces and actions remain readable at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var opened = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: EsnaftaVarTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: ListView(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SellerComparisonOfferCard(
                        listingId: '$i',
                        surfaceIndex: i,
                        shopName: 'Mahallenin Uzun İsimli Esnaf Mağazası',
                        price: 125.5,
                        isAvailable: true,
                        isLowestPrice: i == 0,
                        canAddToCart: true,
                        onViewShop: () => opened++,
                        onAddToCart: () => null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      final colors = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .toSet();
      expect(colors, containsAll(EsnaftaVarDiscoveryColors.sellerSurfaces));
      await tester.tap(
        find.byKey(const ValueKey('product-seller-shop-profile-0')),
      );
      expect(opened, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
