import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart';
import 'package:t_store/features/shop/presentation/views/taxonomy_browse_view.dart';
import 'package:t_store/features/shop/presentation/widgets/seller_comparison_offer_card.dart';
import '../../helpers/customer_contrast_test_support.dart';

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets(
      'W53A tinted breadcrumb and unavailable seller labels $brightness',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        tester.binding.platformDispatcher.platformBrightnessTestValue =
            brightness;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(
          tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: EsnaftaVarTheme.light,
            themeMode: ThemeMode.light,
            home: Scaffold(
              body: Column(
                children: [
                  TaxonomyBreadcrumbBar(
                    breadcrumb: TaxonomyBreadcrumb(const [
                      TaxonomyBreadcrumbItem(
                        categoryId: 'fixture-1',
                        label: 'Elektronik',
                        level: TaxonomyCategoryLevel.l1,
                      ),
                      TaxonomyBreadcrumbItem(
                        categoryId: 'fixture-2',
                        label: 'Telefon',
                        level: TaxonomyCategoryLevel.l2,
                      ),
                      TaxonomyBreadcrumbItem(
                        categoryId: 'fixture-3',
                        label: 'Akıllı telefon',
                        level: TaxonomyCategoryLevel.l3,
                      ),
                    ]),
                  ),
                  SellerComparisonOfferCard(
                    listingId: 'fixture-listing',
                    shopName: 'Örnek Mağaza',
                    price: 100,
                    isAvailable: false,
                    isLowestPrice: false,
                    canAddToCart: false,
                    onViewShop: () {},
                    onAddToCart: () => null,
                  ),
                ],
              ),
            ),
          ),
        );
        expect(find.text('…'), findsOneWidget);
        expect(find.text('Rafta yok'), findsOneWidget);
        expectCustomerTextContrast(tester);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
