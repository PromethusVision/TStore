import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/customer_bottom_navigation.dart';
import 'package:t_store/core/ui/components/reward_progress_card.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/theme/theme.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/entities/banner_entity.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/banners_state.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/categories_state.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/nearby_shops_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/home_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class _MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class _MockBannersCubit extends MockCubit<BannersState>
    implements BannersCubit {}

class _MockCategoriesCubit extends MockCubit<CategoriesState>
    implements CategoriesCubit {}

class _MockProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class _MockSearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class _MockLocationsCubit extends MockCubit<CustomerSavedLocationsState>
    implements CustomerSavedLocationsCubit {}

class _MockNearbyCubit extends MockCubit<NearbyShopsState>
    implements NearbyShopsCubit {}

class _MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

class _MockCartCubit extends MockCubit<CartV2State> implements CartV2Cubit {}

void main() {
  setUpAll(() async {
    final poppins = FontLoader('Poppins')
      ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
      ..addFont(
        rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
      );
    final flutterArtifacts = File(
      Platform.resolvedExecutable,
    ).parent.parent.parent;
    final materialIcons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${flutterArtifacts.path}${Platform.pathSeparator}material_fonts'
          '${Platform.pathSeparator}MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), iconsax.load(), materialIcons.load()]);
  });

  for (final scenario in _HomeVisualScenario.values) {
    testWidgets('W39A ${scenario.name} 390px visual evidence', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildScenario(scenario));
      await tester.pump(const Duration(milliseconds: 180));

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('w39a-home-visual-evidence')),
        matchesGoldenFile('goldens/w39a_home_${scenario.name}_390.png'),
      );
    });
  }
}

Widget _buildScenario(_HomeVisualScenario scenario) {
  final authCubit = _MockAuthCubit();
  final bannersCubit = _MockBannersCubit();
  final categoriesCubit = _MockCategoriesCubit();
  final productsCubit = _MockProductsCubit();
  final searchCubit = _MockSearchCubit();
  final locationsCubit = _MockLocationsCubit();
  final nearbyCubit = _MockNearbyCubit();
  final wishlistCubit = _MockWishlistCubit();
  final cartCubit = _MockCartCubit();

  final isAuthenticated = scenario != _HomeVisualScenario.guest;
  const user = UserEntity(
    id: 'visual-customer',
    email: 'visual@example.com',
    fullName: 'Ayşe Yılmaz',
  );
  whenListen(
    authCubit,
    const Stream<AuthState>.empty(),
    initialState: isAuthenticated
        ? const AuthAuthenticated(user)
        : AuthUnauthenticated(),
  );
  whenListen(
    bannersCubit,
    const Stream<BannersState>.empty(),
    initialState: const BannersLoaded([
      BannerEntity(id: 'fixture-banner', imageUrl: TImages.promoBanner1),
    ]),
  );
  when(() => bannersCubit.getBanners()).thenAnswer((_) async {});

  final isLongText = scenario == _HomeVisualScenario.longText;
  whenListen(
    categoriesCubit,
    const Stream<CategoriesState>.empty(),
    initialState: CategoriesLoaded(isLongText ? _longCategories : _categories),
  );
  when(() => categoriesCubit.getCategories()).thenAnswer((_) async {});

  whenListen(
    productsCubit,
    const Stream<ProductsState>.empty(),
    initialState: ProductsLoaded(
      products: isLongText ? _longProducts : _products,
    ),
  );
  whenListen(
    searchCubit,
    const Stream<CustomerSearchState>.empty(),
    initialState: CustomerSearchInitial(),
  );
  when(() => searchCubit.search(any())).thenAnswer((_) async {});
  when(() => searchCubit.reset()).thenReturn(null);

  whenListen(
    locationsCubit,
    const Stream<CustomerSavedLocationsState>.empty(),
    initialState: isAuthenticated
        ? const CustomerSavedLocationsLoaded(locations: [_location])
        : const CustomerSavedLocationsLoaded(locations: []),
  );
  whenListen(
    nearbyCubit,
    const Stream<NearbyShopsState>.empty(),
    initialState: NearbyShopsLoaded(
      isLongText ? _longShops : _shops,
      locationStatus: NearbyLocationStatus.ready,
      locationSource: NearbyLocationSource.savedLocation,
      locationLabel: 'Ev',
      distanceMetersByShopId: const {'shop-1': 240, 'shop-2': 620},
    ),
  );
  whenListen(
    wishlistCubit,
    const Stream<WishlistState>.empty(),
    initialState: WishlistLoaded(const []),
  );
  when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
  whenListen(
    cartCubit,
    const Stream<CartV2State>.empty(),
    initialState: const CartV2Loaded([]),
  );

  final rewardEnabled = scenario == _HomeVisualScenario.rewardFixture;
  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<BannersCubit>.value(value: bannersCubit),
      BlocProvider<CategoriesCubit>.value(value: categoriesCubit),
      BlocProvider<ProductsCubit>.value(value: productsCubit),
      BlocProvider<CustomerSavedLocationsCubit>.value(value: locationsCubit),
      BlocProvider<NearbyShopsCubit>.value(value: nearbyCubit),
      BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      BlocProvider<CartV2Cubit>.value(value: cartCubit),
    ],
    child: MaterialApp(
      theme: TAppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: const Key('w39a-home-visual-evidence'),
        child: Scaffold(
          bottomNavigationBar: CustomerBottomNavigation(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
          body: SafeArea(
            bottom: false,
            child: CustomerHomeV1Content(
              searchCubit: searchCubit,
              isAuthenticatedOverride: isAuthenticated,
              rewardFeatureEnabled: rewardEnabled,
              rewardProgress: rewardEnabled ? _rewardFixture : null,
              productFavoriteCurrentUserIdProvider: () =>
                  isAuthenticated ? 'visual-customer' : null,
              onSearchSubmitted: (_) {},
              onLocationTap: () {},
              onNearbyViewAll: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

enum _HomeVisualScenario { guest, authenticated, rewardFixture, longText }

const _rewardFixture = RewardProgressData(
  progress: 0.62,
  title: 'Mahalle ödül yolculuğun',
  currentMilestone: 'Başlangıç adımı',
  nextMilestone: 'Sıradaki adım',
  contextualMessage: 'İlerleme yalnız görsel inceleme fixture verisidir.',
);

const _location = CustomerSavedLocationEntity(
  id: 'location-1',
  userId: 'visual-customer',
  name: 'Ev',
  addressText: 'Turgut Reis Mahallesi, Esenler',
  latitude: 41.04,
  longitude: 28.87,
  isDefault: true,
);

const _categories = [
  CategoryEntity(id: 'market', name: 'Market'),
  CategoryEntity(id: 'manav', name: 'Manav'),
  CategoryEntity(id: 'firin', name: 'Fırın'),
  CategoryEntity(id: 'kasap', name: 'Kasap'),
  CategoryEntity(id: 'kozmetik', name: 'Kozmetik'),
  CategoryEntity(id: 'ev-yasam', name: 'Ev & Yaşam'),
];

const _longCategories = [
  CategoryEntity(
    id: 'long-category',
    name: 'Çocuk Giyim, Ayakkabı ve Günlük Kullanım Ürünleri',
  ),
  ..._categories,
];

const _products = [
  ProductEntity(
    id: 'product-1',
    name: 'Taze Çeri Domates',
    price: 49.90,
    categoryId: 'manav',
    stock: 18,
    images: [],
    brandName: 'Mahalle Manavı',
  ),
  ProductEntity(
    id: 'product-2',
    name: 'Günlük Köy Ekmeği',
    price: 24.90,
    categoryId: 'firin',
    stock: 9,
    images: [],
    brandName: 'Esenler Fırını',
  ),
];

const _longProducts = [
  ProductEntity(
    id: 'long-product',
    name: 'ÇĞİÖŞÜ Dayanıklı Çok Amaçlı Mutfak Hazırlama ve Saklama Seti',
    price: 149.90,
    categoryId: 'ev-yasam',
    stock: 4,
    images: [],
    brandName: 'Esenler Yerel Ürünler Dayanışma Mağazası',
  ),
  ..._products,
];

const _shops = [
  ShopEntity(
    id: 'shop-1',
    name: 'Nihat Manav',
    address: 'Esenler, İstanbul',
    rating: 4.8,
    ratingCount: 120,
  ),
  ShopEntity(
    id: 'shop-2',
    name: 'Mahalle Fırını',
    address: 'Esenler, İstanbul',
    rating: 4.7,
    ratingCount: 86,
  ),
];

const _longShops = [
  ShopEntity(
    id: 'long-shop',
    name: 'ÇĞİÖŞÜ Esenler Mahalle Dayanışma ve Yerel Ürünler Mağazası',
    address: 'Esenler, İstanbul',
    rating: 4.7,
    ratingCount: 82,
  ),
  ..._shops,
];
