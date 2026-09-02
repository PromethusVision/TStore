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

  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  for (final evidence in const [
    (name: 'w42a_before_product_details_390', visualPrototype: false),
    (name: 'w42a_product_details_visual_prototype_390', visualPrototype: true),
  ]) {
    testWidgets('${evidence.name} visual evidence', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final shopRepository = _MockShopRepository();
      final locationService = _MockCustomerLocationService();
      final cartV2Cubit = _MockCartV2Cubit();
      final wishlistCubit = _MockWishlistCubit();

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
      whenListen(
        wishlistCubit,
        const Stream<WishlistState>.empty(),
        initialState: WishlistLoaded(const []),
      );
      when(() => wishlistCubit.isInWishlist(any())).thenReturn(false);

      sl.registerLazySingleton<GetShopProductsByProductUsecase>(
        () => GetShopProductsByProductUsecase(shopRepository),
      );
      sl.registerLazySingleton<CustomerLocationService>(() => locationService);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<CartV2Cubit>.value(value: cartV2Cubit),
            BlocProvider<WishlistCubit>.value(value: wishlistCubit),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: EsnaftaVarTheme.light,
            home: RepaintBoundary(
              key: const Key('w42a-product-details-visual-evidence'),
              child: ProductDetailsView(
                product: _product,
                currentUserIdProvider: () => 'customer-1',
                visualPrototype: evidence.visualPrototype,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final imageContext = tester.element(
        find.byKey(const Key('w42a-product-details-visual-evidence')),
      );
      await tester.runAsync(() async {
        await precacheImage(const AssetImage(_productImage), imageContext);
      });
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('product-details-media')), findsOne);
      if (evidence.visualPrototype) {
        expect(find.text('3 esnafta var'), findsOne);
        expect(find.text('28.999,00 TL’den'), findsOne);
        expect(find.text('Esnafları karşılaştır'), findsOne);
      }

      await expectLater(
        find.byKey(const Key('w42a-product-details-visual-evidence')),
        matchesGoldenFile('goldens/${evidence.name}.png'),
      );
    });
  }
}

const _productImage = 'assets/images/products/samsung_s9_mobile_withback.png';

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
  images: [_productImage],
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
      name: 'Yıldız Mahallesi Teknoloji',
      address: 'Beşiktaş, İstanbul',
      rating: 4.7,
    ),
  ),
];
