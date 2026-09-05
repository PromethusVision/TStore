import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/entities/category_entity.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/services/recent_product_searches_storage.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/customer_search_state.dart';
import 'package:t_store/features/shop/presentation/cubit/products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/products_state.dart';
import 'package:t_store/features/shop/presentation/views/all_products_view.dart';
import 'package:t_store/features/shop/presentation/widgets/home_search_bar.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class DiscoveryProductsCubit extends MockCubit<ProductsState>
    implements ProductsCubit {}

class DiscoverySearchCubit extends MockCubit<CustomerSearchState>
    implements CustomerSearchCubit {}

class DiscoveryWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

class DiscoveryHistory implements RecentProductSearchesStorage {
  DiscoveryHistory([List<String> seed = const []]) : queries = [...seed];
  final List<String> queries;
  @override
  Future<void> clear() async => queries.clear();
  @override
  Future<List<String>> getQueries() async => List.unmodifiable(queries);
  @override
  Future<void> recordQuery(String query) async {}
  @override
  Future<void> removeQuery(String query) async => queries.remove(query);
}

const discoveryQuery = 'kahve';
const discoveryLongText =
    'Öğütülmüş Türk kahvesi ve yöresel ürünler için çok uzun açıklama';
const discoveryProduct = ProductEntity(
  id: 'w45b-product',
  name: 'Geleneksel Türk Kahvesi 500 g',
  brandName: 'Mahalle Kahvecisi',
  categoryId: 'w45b-category',
  price: 987654,
  salePrice: 1,
  stock: 1,
  images: [],
);
const discoveryShop = ShopEntity(
  id: 'w45b-shop',
  name: 'Mahalle Kahvecisi',
  address: 'Çınar Mahallesi, Pazar Caddesi',
  rating: 4.7,
  ratingCount: 28,
);
const discoveryCategory = CategoryEntity(
  id: 'w45b-category',
  name: 'Kahve ve çay',
);
const discoveryWarning =
    'Bazı sonuçlar yüklenemedi. Diğer sonuçlar gösteriliyor.';

CustomerSearchLoaded discoveryResults({
  bool longContent = false,
  bool empty = false,
  bool partial = false,
}) => CustomerSearchLoaded(
  query: discoveryQuery,
  products: empty
      ? []
      : [
          longContent
              ? discoveryProduct.copyWith(
                  name: discoveryLongText,
                  brandName: discoveryLongText,
                )
              : discoveryProduct,
        ],
  categories: empty
      ? []
      : [
          longContent
              ? discoveryCategory.copyWith(name: discoveryLongText)
              : discoveryCategory,
        ],
  shops: empty
      ? []
      : [
          longContent
              ? discoveryShop.copyWith(
                  name: discoveryLongText,
                  address: discoveryLongText,
                )
              : discoveryShop,
        ],
  warningMessage: partial ? discoveryWarning : null,
);

class DiscoveryFixture {
  DiscoveryFixture({
    ProductsState? productsState,
    CustomerSearchState? searchState,
    List<String> history = const [],
  }) : history = DiscoveryHistory(history) {
    whenListen(
      products,
      const Stream<ProductsState>.empty(),
      initialState: productsState ?? loadedCatalog(),
    );
    whenListen(
      search,
      const Stream<CustomerSearchState>.empty(),
      initialState: searchState ?? discoveryResults(),
    );
    whenListen(
      wishlist,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => products.getProducts(refresh: true)).thenAnswer((_) async {});
    when(() => products.searchProducts(any())).thenAnswer((_) async {});
    when(() => products.loadMoreProducts()).thenAnswer((_) async {});
    when(() => products.close()).thenAnswer((_) async {});
    when(() => search.search(any())).thenAnswer((_) async {});
    when(() => search.reset()).thenReturn(null);
    when(() => search.close()).thenAnswer((_) async {});
    when(() => wishlist.isInWishlist(any())).thenReturn(false);
    when(() => wishlist.toggleWishlist(any())).thenAnswer((_) async {});
    sl.registerFactory<ProductsCubit>(() => products);
  }

  final products = DiscoveryProductsCubit();
  final search = DiscoverySearchCubit();
  final wishlist = DiscoveryWishlistCubit();
  final DiscoveryHistory history;
  final openedProducts = <ProductEntity>[];
  final openedShops = <ShopEntity>[];
  final openedCategories = <CategoryEntity>[];
  final submittedQueries = <String>[];

  static ProductsLoaded loadedCatalog({bool longContent = false}) =>
      ProductsLoaded(
        products: [
          if (longContent)
            discoveryProduct.copyWith(
              name: discoveryLongText,
              brandName: discoveryLongText,
            )
          else
            discoveryProduct,
          discoveryProduct.copyWith(
            id: 'w45b-product-2',
            name: 'Filtre Kahve 250 g',
            brandName: 'Yerel Kavurucu',
          ),
        ],
        hasReachedMax: true,
        currentPage: 1,
      );

  Future<Either<String, List<ShopProductEntity>>> loadPrices(
    List<String> ids,
  ) async => Right([
    for (final id in ids)
      ShopProductEntity(
        id: 'listing-$id',
        productId: id,
        shopId: discoveryShop.id,
        shop: discoveryShop,
        price: 245.5,
      ),
  ]);

  Widget view({
    bool searchMode = false,
    String query = '',
    bool signedIn = false,
  }) => AllProductsView(
    isSearchMode: searchMode,
    initialQuery: query,
    currentUserIdProvider: () => signedIn ? 'fixture-customer' : null,
    recentSearchesStorage: history,
    customerSearchCubit: search,
    shopProductsLoader: loadPrices,
    productDestinationBuilder: (product) {
      openedProducts.add(product);
      return const Scaffold(body: Text('Product destination'));
    },
    shopDestinationBuilder: (shop) {
      openedShops.add(shop);
      return const Scaffold(body: Text('Shop destination'));
    },
    categoryDestinationBuilder: (category) {
      openedCategories.add(category);
      return const Scaffold(body: Text('Category destination'));
    },
  );

  Widget inlineSearch({ValueChanged<String>? onQuerySubmitted}) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HomeSearchBar(
          visualPrototype: true,
          searchCubit: search,
          recentSearchesStorage: history,
          shopProductsLoader: loadPrices,
          onQuerySubmitted: onQuerySubmitted ?? submittedQueries.add,
          onProductSelected: openedProducts.add,
          onCategorySelected: openedCategories.add,
          onShopSelected: openedShops.add,
        ),
      ),
    ),
  );

  Widget app({required Widget child, double scale = 1, double keyboard = 0}) =>
      BlocProvider<WishlistCubit>.value(
        value: wishlist,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: EsnaftaVarTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: child!,
          ),
          home: RepaintBoundary(key: const Key('w45b-evidence'), child: child),
        ),
      );
}

Future<void> loadDiscoveryFonts() async {
  final poppins = FontLoader('Poppins')
    ..addFont(rootBundle.load('assets/fonts/Poppins-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Medium.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-SemiBold.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
  final iconsax = FontLoader('packages/iconsax_flutter/FlutterIconsax')
    ..addFont(
      rootBundle.load('packages/iconsax_flutter/fonts/FlutterIconsax.ttf'),
    );
  final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
  final material = FontLoader('MaterialIcons')
    ..addFont(
      File(
        '${artifacts.path}${Platform.pathSeparator}material_fonts'
        '${Platform.pathSeparator}MaterialIcons-Regular.otf',
      ).readAsBytes().then(ByteData.sublistView),
    );
  await Future.wait([poppins.load(), iconsax.load(), material.load()]);
}

void discoveryViewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
