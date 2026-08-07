import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_product_usecase.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockShopRepository extends Mock implements ShopRepository {}

class MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late MockShopRepository shopRepository;
  late MockCustomerLocationService customerLocationService;
  late MockCartV2Cubit cartV2Cubit;
  late MockWishlistCubit wishlistCubit;

  const product = ProductEntity(
    id: 'product-1',
    name: 'Mahalle Kahvesi',
    description: 'Günlük kavrulmuş taze kahve.',
    price: 125,
    categoryId: 'category-1',
    categoryName: 'Market',
    brandName: 'Yerel Marka',
    stock: 5,
    images: [],
    rating: 4.8,
    reviewsCount: 24,
  );

  setUp(() async {
    await sl.reset();
    shopRepository = MockShopRepository();
    customerLocationService = MockCustomerLocationService();
    cartV2Cubit = MockCartV2Cubit();
    wishlistCubit = MockWishlistCubit();

    when(() => shopRepository.getShopProductsByProduct(product.id)).thenAnswer(
      (_) async => const Right([
        ShopProductEntity(
          id: 'listing-1',
          shopId: 'shop-1',
          productId: 'product-1',
          price: 99,
          shop: ShopEntity(
            id: 'shop-1',
            ownerUserId: 'owner-1',
            name: 'Mahalle Marketi',
            address: 'Esenler, İstanbul',
            rating: 4.7,
          ),
        ),
      ]),
    );
    when(() => customerLocationService.cachedCoordinates).thenReturn(null);
    when(
      () => customerLocationService.getPreferredLocation(),
    ).thenAnswer((_) async => null);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(
      () => customerLocationService,
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  Widget buildSubject({
    ProductReviewsDestinationBuilder? reviewsDestinationBuilder,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
      ],
      child: MaterialApp(
        home: ProductDetailsView(
          product: product,
          currentUserIdProvider: _customerId,
          reviewsDestinationBuilder: reviewsDestinationBuilder,
        ),
      ),
    );
  }

  testWidgets(
    'ürün detayının ana görsel yüzeylerini ve gerçek fiyatı gösterir',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product-details-media')), findsOneWidget);
      expect(
        find.byKey(const Key('product-details-info-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('product-details-facts-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('product-details-sellers-card')),
        findsOneWidget,
      );
      expect(find.text('Mahalle Kahvesi'), findsOneWidget);
      expect(find.text('₺99,00'), findsOneWidget);
      expect(find.text('Bu ürünü satan esnaflar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('dar mobil genişlikte ürün detayı taşma üretmez', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-details-scroll')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('puan alanı gerçek değerlendirme hedefini açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        reviewsDestinationBuilder: (_) => const Scaffold(
          body: SizedBox(key: Key('product-reviews-test-destination')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-reviews-action')), findsOneWidget);
    expect(find.text('Değerlendirmeleri gör'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('product-reviews-action')));
    await tester.tap(find.byKey(const Key('product-reviews-action')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('product-reviews-test-destination')),
      findsOneWidget,
    );
  });
}

String? _customerId() => 'customer-1';
