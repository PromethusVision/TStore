import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';
import 'package:t_store/features/shop/domain/usecases/get_shop_products_by_shop_usecase.dart';
import 'package:t_store/features/shop/presentation/views/shop_profile_view.dart';

class _Repository extends Mock implements ShopRepository {}

const _shop = ShopEntity(
  id: 'fixture-shop',
  ownerUserId: 'fixture-owner',
  name: 'Çınar Teknoloji',
  description:
      'Telefon, kulaklık ve günlük teknoloji ihtiyaçların için mahalledeki adresin.',
  address: 'Caferağa Mahallesi, Moda Caddesi\nKadıköy, İstanbul',
  openingHours: {'Hafta içi': '09:00 – 19:00'},
  rating: 4.8,
  ratingCount: 36,
);
const _image = 'assets/images/products/samsung_s9_mobile_withback.png';
const _product = ProductEntity(
  id: 'fixture-phone',
  name: 'Samsung Galaxy S9 256 GB',
  price: 29999,
  categoryId: 'fixture-category',
  stock: 3,
  images: [_image],
);
const _listing = ShopProductEntity(
  id: 'fixture-listing',
  shopId: 'fixture-shop',
  productId: 'fixture-phone',
  price: 28999,
  shop: _shop,
  product: _product,
);

void main() {
  late _Repository repository;
  setUpAll(() async {
    final poppins = FontLoader('Poppins');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      poppins.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    final artifacts = File(Platform.resolvedExecutable).parent.parent.parent;
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        File(
          '${artifacts.path}/material_fonts/MaterialIcons-Regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await Future.wait([poppins.load(), icons.load()]);
  });
  setUp(() async {
    await sl.reset();
    repository = _Repository();
    when(() => repository.getShopProductsByShop(any())).thenAnswer(
      (_) async => const Right([
        _listing,
        ShopProductEntity(
          id: 'fixture-headphones-listing',
          shopId: 'fixture-shop',
          productId: 'fixture-headphones',
          price: 1499.90,
          product: ProductEntity(
            id: 'fixture-headphones',
            name: 'Kablosuz kulaklık',
            price: 1599,
            categoryId: 'fixture-category',
            stock: 2,
            images: [],
          ),
        ),
      ]),
    );
    sl.registerSingleton(GetShopProductsByShopUsecase(repository));
  });
  tearDown(() async => sl.reset());

  Future<void> pump(
    WidgetTester tester, {
    ShopEntity shop = _shop,
    bool prototype = true,
    ShopProfileUrlLauncher? launcher,
    ShopProfileProductDestinationBuilder? destination,
    ShopProfileChatDestinationBuilder? chat,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        home: RepaintBoundary(
          key: const Key('evidence'),
          child: ShopProfileView(
            shop: shop,
            visualPrototype: prototype,
            currentUserIdProvider: () => 'fixture-customer',
            urlLauncher: launcher,
            productDestinationBuilder: destination,
            chatDestinationBuilder: chat,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (prototype) {
      final context = tester.element(find.byKey(const Key('evidence')));
      await tester.runAsync(
        () => precacheImage(const AssetImage(_image), context),
      );
      await tester.pumpAndSettle();
    }
  }

  testWidgets('390 px visit-first owner evidence', (tester) async {
    await pump(tester);
    expect(find.text('Yol tarifi al'), findsOneWidget);
    expect(find.text('Mağazadaki ürünler'), findsOneWidget);
    expect(find.text('Şu an açık'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Yol tarifi al')).dy,
      lessThan(tester.getTopLeft(find.text('Esnafa yaz')).dy),
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('evidence')),
      matchesGoldenFile('goldens/w45a_shop_details_390.png'),
    );
  });
  testWidgets('directions and product handoff keep actual targets', (
    tester,
  ) async {
    Uri? launched;
    ProductEntity? opened;
    await pump(
      tester,
      launcher: (uri, _) async {
        launched = uri;
        return true;
      },
      destination: (product) {
        opened = product;
        return const Scaffold(body: Text('Ürün hedefi'));
      },
    );
    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pump();
    expect(launched?.queryParameters['query'], _shop.address);
    await tester.tap(
      find.byKey(const Key('shop-profile-product-link-fixture-listing')),
    );
    await tester.pumpAndSettle();
    expect(opened?.id, _product.id);
    expect(find.text('Ürün hedefi'), findsOneWidget);
  });
  testWidgets('secondary chat preserves shop receiver', (tester) async {
    String? receiver;
    await pump(
      tester,
      chat: (id, name) {
        receiver = id;
        return const Scaffold(body: Text('Sohbet'));
      },
    );
    await tester.tap(find.byKey(const Key('shop-profile-message-action')));
    await tester.pumpAndSettle();
    expect(receiver, _shop.ownerUserId);
    expect(find.text('Sohbet'), findsOneWidget);
  });
  testWidgets('missing location never creates a directions action', (
    tester,
  ) async {
    await pump(
      tester,
      shop: const ShopEntity(id: 'fixture-empty', name: 'Mağaza'),
    );
    expect(
      find.byKey(const Key('shop-profile-directions-action')),
      findsNothing,
    );
    expect(find.byKey(const Key('shop-profile-message-action')), findsNothing);
    expect(tester.takeException(), isNull);
  });
  test('presentation is default off', () {
    expect(const ShopProfileView(shop: _shop).visualPrototype, isFalse);
  });
}
