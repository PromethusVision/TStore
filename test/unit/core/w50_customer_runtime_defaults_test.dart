import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/dependency_injection/taxonomy_dependency_configuration.dart';
import 'package:t_store/core/supabase/supabase_config.dart';
import 'package:t_store/features/personalization/presentation/views/settings_view.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';
import 'package:t_store/features/shop/presentation/views/nearby_view.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/main_development.dart' as development;

void main() {
  test(
    'default Customer shell exposes only the five supported destinations',
    () async {
      final navigation = NavigationMenuCubit();
      try {
        expect(navigation.screensList, hasLength(5));
        expect(navigation.screensList[0], isA<HomeView>());
        expect(navigation.screensList[1], isA<NearbyView>());
        expect(navigation.screensList[2], isA<CartV2View>());
        expect(navigation.screensList[3], isA<WishlistView>());
        expect(navigation.screensList[4], isA<SettingsView>());
      } finally {
        await navigation.close();
      }
    },
  );

  test('Home experiment and Reward economics are disabled without inputs', () {
    final content = CustomerHomeV1Content(
      onSearchSubmitted: (_) {},
      onLocationTap: () {},
      onNearbyViewAll: () {},
    );
    expect(content.visualPrototype, isFalse);
    expect(content.rewardFeatureEnabled, isFalse);
    expect(content.rewardProgress, isNull);
    expect(content.onRewardTap, isNull);
  });

  test(
    'Product Details experiment stays disabled at a real product handoff',
    () {
      const product = ProductEntity(
        id: 'w50-product',
        name: 'Yerel ürün',
        price: 10,
        categoryId: 'w50-category',
        stock: 1,
        images: [],
      );
      const view = ProductDetailsView(product: product);
      expect(view.visualPrototype, isFalse);
      expect(view.product, same(product));
    },
  );

  test('legacy flag names keep the approved real-data Final UI enabled', () {
    // W45A promoted these presentations to Final UI. Their historical property
    // name is not an experiment/data switch. Turning it off regresses the UI.
    const shop = ShopEntity(id: 'w50-shop', name: 'Yerel mağaza');
    expect(const CartV2View().visualPrototype, isTrue);
    expect(const NearbyView().visualPrototype, isTrue);
    const view = ShopProfileView(shop: shop);
    expect(view.visualPrototype, isTrue);
    expect(view.shop, same(shop));
  });

  test(
    'Development default never invokes the opt-in canonical proof loader',
    () async {
      var proofRequests = 0;
      final configuration = await development
          .createDevelopmentTaxonomyConfiguration(
            proofLoader: () async {
              proofRequests++;
              throw StateError('No remote proof is authorized in this test');
            },
          );
      expect(proofRequests, 0);
      expect(configuration.environment, AppEnvironment.development);
      expect(configuration.runtimeRequest, TaxonomyRuntimeRequest.legacy);
    },
  );
}
