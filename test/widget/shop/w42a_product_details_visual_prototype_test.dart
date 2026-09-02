import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
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

class _MockShopRepository extends Mock implements ShopRepository {}

class _MockCustomerLocationService extends Mock
    implements CustomerLocationService {}

class _MockCartV2Cubit extends MockCubit<CartV2State> implements CartV2Cubit {}

class _MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  late _MockShopRepository shopRepository;
  late _MockCustomerLocationService locationService;
  late _MockCartV2Cubit cartV2Cubit;
  late _MockWishlistCubit wishlistCubit;

  setUp(() async {
    await sl.reset();
    shopRepository = _MockShopRepository();
    locationService = _MockCustomerLocationService();
    cartV2Cubit = _MockCartV2Cubit();
    wishlistCubit = _MockWishlistCubit();

    when(
      () => shopRepository.getShopProductsByProduct(_product.id),
    ).thenAnswer((_) async => const Right(_shopProducts));
    when(() => locationService.cachedCoordinates).thenReturn(null);
    when(
      () => locationService.getPreferredLocation(),
    ).thenAnswer((_) async => null);
    whenListen(
      cartV2Cubit,
      const Stream<CartV2State>.empty(),
      initialState: CartV2Initial(),
    );
    when(
      () => cartV2Cubit.addShopProductToCart(
        shopProductId: any(named: 'shopProductId'),
        quantity: any(named: 'quantity'),
      ),
    ).thenAnswer((_) async {});
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: WishlistLoaded(const []),
    );
    when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);
    when(() => wishlistCubit.toggleWishlist(any())).thenAnswer((_) async {});

    sl.registerLazySingleton<GetShopProductsByProductUsecase>(
      () => GetShopProductsByProductUsecase(shopRepository),
    );
    sl.registerLazySingleton<CustomerLocationService>(() => locationService);
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
        theme: EsnaftaVarTheme.light,
        home: ProductDetailsView(
          product: _product,
          currentUserIdProvider: () => 'customer-1',
          reviewsDestinationBuilder: reviewsDestinationBuilder,
          visualPrototype: true,
        ),
      ),
    );
  }

  testWidgets('W42A prototipi ürün ve gerçek yerel fiyat hiyerarşisini kurar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-details-final-header')), findsOne);
    expect(find.byKey(const Key('product-details-media')), findsOne);
    expect(find.text(_product.name), findsOne);
    expect(find.text('Samsung'), findsWidgets);
    expect(find.text('3 esnafta var'), findsOne);
    expect(find.text('28.999,00 TL’den'), findsOne);
    expect(find.text('Esnafları karşılaştır'), findsOne);
    expect(find.textContaining('kargo'), findsNothing);
    expect(find.textContaining('teslimat'), findsNothing);
    expect(find.textContaining('ödeme'), findsNothing);
    expect(find.textContaining('hemen al'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'satıcı karşılaştırma mevcut listeye iner ve Cart V2 eylemi kalır',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('product-details-compare-sellers')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('product-details-sellers-card')), findsOne);
      expect(find.text('Bu ürünü satan esnaflar'), findsOne);

      final addButton = find.byKey(
        const ValueKey('product-seller-add-listing-1'),
      );
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pump();

      verify(
        () => cartV2Cubit.addShopProductToCart(
          shopProductId: 'listing-1',
          quantity: 1,
        ),
      ).called(1);
    },
  );

  testWidgets('wishlist ve değerlendirme geçişleri korunur', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        reviewsDestinationBuilder: (_) => const Scaffold(
          body: SizedBox(key: Key('product-reviews-test-destination')),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('product-details-favorite-action')));
    await tester.pumpAndSettle();
    verify(() => wishlistCubit.toggleWishlist(_product.id)).called(1);

    final reviewAction = find.byKey(const Key('product-reviews-action'));
    await tester.ensureVisible(reviewAction);
    await tester.tap(reviewAction);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('product-reviews-test-destination')), findsOne);
  });

  testWidgets('kompakt başlık geri davranışını korur', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
          BlocProvider<WishlistCubit>.value(value: wishlistCubit),
        ],
        child: MaterialApp(
          theme: EsnaftaVarTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  key: const Key('open-product-details'),
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => ProductDetailsView(
                        product: _product,
                        currentUserIdProvider: () => 'customer-1',
                        visualPrototype: true,
                      ),
                    ),
                  ),
                  child: const Text('Ürünü aç'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-product-details')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('product-details-final-header')), findsOne);

    await tester.tap(find.byKey(const Key('product-details-back-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('open-product-details')), findsOne);
  });
}

const _product = ProductEntity(
  id: 'phone-1',
  name: 'Samsung Galaxy S9 256 GB Çift SIM Türkiye Garantili Gece Siyahı',
  description:
      'Canlı ekranı, kompakt yapısı ve güçlü kamerasıyla günlük kullanım için dengeli bir akıllı telefon.',
  price: 31999,
  categoryId: 'smartphones',
  categoryName: 'Akıllı Telefonlar',
  brandName: 'Samsung',
  stock: 8,
  images: ['assets/images/products/samsung_s9_mobile_withback.png'],
  rating: 4.8,
  reviewsCount: 128,
);

const _shopProducts = <ShopProductEntity>[
  ShopProductEntity(
    id: 'listing-1',
    shopId: 'shop-1',
    productId: 'phone-1',
    price: 28999,
    shop: ShopEntity(
      id: 'shop-1',
      ownerUserId: 'owner-1',
      name: 'Çınar Teknoloji',
      address: 'Kadıköy, İstanbul',
      rating: 4.8,
    ),
  ),
  ShopProductEntity(
    id: 'listing-2',
    shopId: 'shop-2',
    productId: 'phone-1',
    price: 29949,
    shop: ShopEntity(
      id: 'shop-2',
      ownerUserId: 'owner-2',
      name: 'Mahalle İletişim',
      address: 'Üsküdar, İstanbul',
      rating: 4.6,
    ),
  ),
  ShopProductEntity(
    id: 'listing-3',
    shopId: 'shop-3',
    productId: 'phone-1',
    price: 30490,
    shop: ShopEntity(
      id: 'shop-3',
      ownerUserId: 'owner-3',
      name: 'Yıldız Mahallesi Teknoloji',
      address: 'Beşiktaş, İstanbul',
      rating: 4.7,
    ),
  ),
];
