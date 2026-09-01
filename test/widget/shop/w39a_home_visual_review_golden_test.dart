import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart' hide State;
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
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
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

  const evidenceCases = [
    _HomeGoldenCase(
      name: 'w39a_r3_home_authenticated_390',
      scenario: _HomeVisualScenario.authenticated,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_guest_390',
      scenario: _HomeVisualScenario.guest,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_reward_0_of_5_390',
      scenario: _HomeVisualScenario.reward0,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_reward_3_of_5_390',
      scenario: _HomeVisualScenario.reward3,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_reward_5_of_5_390',
      scenario: _HomeVisualScenario.reward5,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_long_text_390',
      scenario: _HomeVisualScenario.longText,
      width: 390,
      textScale: 1.3,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_loading_390',
      scenario: _HomeVisualScenario.loading,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_empty_390',
      scenario: _HomeVisualScenario.empty,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_error_390',
      scenario: _HomeVisualScenario.error,
      width: 390,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_authenticated_320',
      scenario: _HomeVisualScenario.reward3,
      width: 320,
    ),
    _HomeGoldenCase(
      name: 'w39a_r3_home_authenticated_430',
      scenario: _HomeVisualScenario.reward3,
      width: 430,
    ),
    _HomeGoldenCase(
      name: 'w39a_r31_home_category_mapping_390',
      scenario: _HomeVisualScenario.reward3,
      width: 390,
    ),
  ];

  for (final evidence in evidenceCases) {
    testWidgets('${evidence.name} final visual evidence', (tester) async {
      tester.view.physicalSize = Size(evidence.width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildScenario(evidence.scenario, textScale: evidence.textScale),
      );
      await tester.pump(const Duration(milliseconds: 180));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('home-wordmark')), findsOneWidget);
      expect(find.byKey(const Key('home-search-input')), findsOneWidget);
      expect(
        find.byKey(const Key('customer-bottom-navigation')),
        findsOneWidget,
      );
      await expectLater(
        find.byKey(const Key('w39a-home-visual-evidence')),
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

class _HomeGoldenCase {
  const _HomeGoldenCase({
    required this.name,
    required this.scenario,
    required this.width,
    this.textScale = 1,
  });

  final String name;
  final _HomeVisualScenario scenario;
  final double width;
  final double textScale;
}

Widget _buildScenario(_HomeVisualScenario scenario, {double textScale = 1}) {
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
  final isLongText = scenario == _HomeVisualScenario.longText;
  final user = UserEntity(
    id: 'visual-customer',
    email: 'visual@example.com',
    fullName: isLongText
        ? 'ÇĞİÖŞÜuzunisim Mahalle Dayanışma Kullanıcısı'
        : 'Ayşe Yılmaz',
  );
  whenListen(
    authCubit,
    const Stream<AuthState>.empty(),
    initialState: isAuthenticated
        ? AuthAuthenticated(user)
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

  whenListen(
    categoriesCubit,
    const Stream<CategoriesState>.empty(),
    initialState: switch (scenario) {
      _HomeVisualScenario.loading => CategoriesLoading(),
      _HomeVisualScenario.empty => const CategoriesLoaded([]),
      _HomeVisualScenario.error => const CategoriesError(
        'Kategoriler yüklenemedi',
      ),
      _ => CategoriesLoaded(
        isLongText ? _longCategories : _prototypeCategories,
      ),
    },
  );
  when(() => categoriesCubit.getCategories()).thenAnswer((_) async {});

  whenListen(
    productsCubit,
    const Stream<ProductsState>.empty(),
    initialState: switch (scenario) {
      _HomeVisualScenario.loading => ProductsLoading(),
      _HomeVisualScenario.empty => const ProductsLoaded(products: []),
      _HomeVisualScenario.error => const ProductsError('Ürünler yüklenemedi'),
      _ => ProductsLoaded(
        products: isLongText ? _longProducts : _prototypeProducts,
      ),
    },
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
        ? CustomerSavedLocationsLoaded(
            locations: [isLongText ? _longLocation : _location],
          )
        : const CustomerSavedLocationsLoaded(locations: []),
  );
  whenListen(
    nearbyCubit,
    const Stream<NearbyShopsState>.empty(),
    initialState: switch (scenario) {
      _HomeVisualScenario.loading => const NearbyShopsLoading(),
      _HomeVisualScenario.empty => const NearbyShopsEmpty(),
      _HomeVisualScenario.error => const NearbyShopsError(
        'Mağazalar yüklenemedi',
      ),
      _ => NearbyShopsLoaded(
        isLongText ? _longShops : _shops,
        locationStatus: NearbyLocationStatus.ready,
        locationSource: NearbyLocationSource.savedLocation,
        locationLabel: 'Ev',
        distanceMetersByShopId: const {'shop-1': 240, 'shop-2': 620},
      ),
    },
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

  final rewardProgress = switch (scenario) {
    _HomeVisualScenario.reward0 => _reward0Fixture,
    _HomeVisualScenario.reward3 => _reward3Fixture,
    _HomeVisualScenario.reward5 => _reward5Fixture,
    _HomeVisualScenario.longText => _longRewardFixture,
    _ => null,
  };
  final rewardEnabled = rewardProgress != null;
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
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: RepaintBoundary(
        key: const Key('w39a-home-visual-evidence'),
        child: Scaffold(
          bottomNavigationBar: CustomerBottomNavigation(
            selectedIndex: 0,
            onSelected: (_) {},
            visualPrototype: true,
          ),
          body: SafeArea(
            bottom: false,
            child: CustomerHomeV1Content(
              searchCubit: searchCubit,
              isAuthenticatedOverride: isAuthenticated,
              rewardFeatureEnabled: rewardEnabled,
              rewardProgress: rewardProgress,
              productShopProductsLoader: isLongText
                  ? _longShopProductsLoader
                  : _prototypeShopProductsLoader,
              visualPrototype: true,
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

enum _HomeVisualScenario {
  guest,
  authenticated,
  reward0,
  reward3,
  reward5,
  longText,
  loading,
  empty,
  error,
}

const _reward0Fixture = RewardProgressData(
  completedTasks: 0,
  rewardAmountText: '100 TL',
);

const _reward3Fixture = RewardProgressData(
  completedTasks: 3,
  rewardAmountText: '100 TL',
);

const _reward5Fixture = RewardProgressData(
  completedTasks: 5,
  rewardAmountText: '100 TL',
);

const _longRewardFixture = RewardProgressData(
  completedTasks: 4,
  rewardAmountText: '999.999.999,90 TL',
  title: 'ÇĞİÖŞÜ görev yap, kazan yolculuğu',
  subtitle: 'Mahallendeki ödül yolculuğu',
  message: 'Ödüle yalnızca bir görev kaldı; ayrıntılar daha sonra açıklanacak.',
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

const _longLocation = CustomerSavedLocationEntity(
  id: 'location-long',
  userId: 'visual-customer',
  name: 'ÇĞİÖŞÜ Çok Uzun Ev Konumu',
  addressText:
      'Çifte Havuzlar Mahallesi, Eski Londra Asfaltı Caddesi, Esenler, İstanbul',
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

const _prototypeCategories = [
  CategoryEntity(
    id: 'market',
    name: 'Market',
    imageUrl: 'assets/icons/categories/groceries.png',
  ),
  CategoryEntity(
    id: 'ev-yasam',
    name: 'Ev & Yaşam',
    imageUrl: 'assets/icons/categories/home-decoration.png',
  ),
  CategoryEntity(
    id: 'kozmetik',
    name: 'Kozmetik',
    imageUrl: 'assets/icons/categories/beauty.png',
  ),
  CategoryEntity(
    id: 'giyim',
    name: 'Giyim',
    imageUrl: 'assets/icons/categories/tops.png',
  ),
  CategoryEntity(
    id: 'elektronik',
    name: 'Elektronik',
    imageUrl: 'assets/icons/categories/smartphones.png',
  ),
  CategoryEntity(
    id: 'ayakkabi',
    name: 'Ayakkabı',
    imageUrl: 'assets/icons/categories/mens-shoes.png',
  ),
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

const _prototypeProducts = [
  ProductEntity(
    id: 'prototype-product-1',
    name: 'Günlük Pamuklu Tişört',
    price: 429.90,
    categoryId: 'giyim',
    stock: 18,
    images: [TImages.productImage5],
    brandName: 'Mahalle Giyim',
  ),
  ProductEntity(
    id: 'prototype-product-2',
    name: 'Rahat Ev Terliği',
    price: 249.90,
    categoryId: 'ev-yasam',
    stock: 9,
    images: [TImages.productImage6],
    brandName: 'Esenler Ayakkabı',
  ),
  ProductEntity(
    id: 'prototype-product-3',
    name: 'Samsung Galaxy S9',
    price: 6499.90,
    categoryId: 'elektronik',
    stock: 3,
    images: [TImages.productImage11],
    brandName: 'Komşu Teknoloji',
  ),
];

Future<Either<String, List<ShopProductEntity>>> _prototypeShopProductsLoader(
  List<String> _,
) async {
  return const Right([
    ShopProductEntity(
      id: 'prototype-listing-1',
      shopId: 'shop-1',
      productId: 'prototype-product-1',
      price: 399.90,
      shop: ShopEntity(id: 'shop-1', name: 'Mahalle Giyim'),
    ),
    ShopProductEntity(
      id: 'prototype-listing-2',
      shopId: 'shop-2',
      productId: 'prototype-product-2',
      price: 219.90,
      shop: ShopEntity(id: 'shop-2', name: 'Esenler Ayakkabı'),
    ),
    ShopProductEntity(
      id: 'prototype-listing-3',
      shopId: 'shop-3',
      productId: 'prototype-product-3',
      price: 6299.90,
      shop: ShopEntity(id: 'shop-3', name: 'Komşu Teknoloji'),
    ),
  ]);
}

Future<Either<String, List<ShopProductEntity>>> _longShopProductsLoader(
  List<String> _,
) async {
  return const Right([
    ShopProductEntity(
      id: 'long-listing',
      shopId: 'long-shop',
      productId: 'long-product',
      price: 99999999.90,
      shop: ShopEntity(
        id: 'long-shop',
        name: 'ÇĞİÖŞÜ Esenler Mahalle Dayanışma Mağazası',
      ),
    ),
  ]);
}

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
