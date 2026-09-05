import 'dart:async';
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
    ShopProfileUrlLauncher? launcher,
    ShopProfileProductDestinationBuilder? destination,
    ShopProfileChatDestinationBuilder? chat,
    double width = 390,
    double textScale = 1,
    bool settle = true,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: EsnaftaVarTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: const Key('evidence'),
          child: ShopProfileView(
            shop: shop,
            currentUserIdProvider: () => 'fixture-customer',
            urlLauncher: launcher,
            productDestinationBuilder: destination,
            chatDestinationBuilder: chat,
          ),
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
    final context = tester.element(find.byKey(const Key('evidence')));
    await tester.runAsync(
      () => precacheImage(const AssetImage(_image), context),
    );
    await tester.pumpAndSettle();
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
  test(
    'Final UI is default and explicit legacy comparison remains available',
    () {
      expect(const ShopProfileView(shop: _shop).visualPrototype, isTrue);
      expect(
        const ShopProfileView(
          shop: _shop,
          visualPrototype: false,
        ).visualPrototype,
        isFalse,
      );
    },
  );

  for (final width in [320.0, 390.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('closeout loaded ${width.toInt()} scale $scale', (
        tester,
      ) async {
        await pump(tester, width: width, textScale: scale);
        final directions = find.byKey(
          const Key('shop-profile-directions-action'),
        );
        expect(tester.widget<FilledButton>(directions).onPressed, isNotNull);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.text('Yol tarifi al'), findsOneWidget);
        await tester.ensureVisible(find.text('Mağazadaki ürünler'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, 1800));
        await tester.pumpAndSettle();
        await expectLater(
          find.byKey(const Key('evidence')),
          matchesGoldenFile(
            'goldens/w45a_r2_shop_loaded_${width.toInt()}_scale_${(scale * 100).round()}.png',
          ),
        );
      });
      testWidgets('long shop content ${width.toInt()} scale $scale', (
        tester,
      ) async {
        final longShop = _shop.copyWith(
          name:
              'Çınar Teknoloji ve Elektronik Aksesuar Mağazası Kadıköy Şubesi',
          address:
              'Örnek Mahallesi, Uzun Çarşı Caddesi, Deneme İş Merkezi '
              'zemin kat arka giriş, Kadıköy / İstanbul',
          description: List.filled(
            4,
            'Mahallendeki teknoloji ihtiyaçlarını '
            'mağazada inceleyebilir, ürünler hakkında esnaftan bilgi alabilirsin.',
          ).join(' '),
          phone: '000',
          openingHours: {
            'Pazartesi – Cumartesi': '09:00 – 19:00',
            'Pazar': 'Kapalı',
          },
        );
        await pump(tester, shop: longShop, width: width, textScale: scale);
        expect(find.text(longShop.name), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.scrollUntilVisible(
          find.byKey(const Key('shop-profile-directions-action')),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(find.textContaining('Pazar: Kapalı'), findsOneWidget);
        expect(tester.takeException(), isNull);
        if (width == 320 && scale == 1.3) {
          await expectLater(
            find.byKey(const Key('evidence')),
            matchesGoldenFile(
              'goldens/w45a_r2_shop_long_content_320_scale_130.png',
            ),
          );
        }
        await tester.scrollUntilVisible(
          find.byKey(const Key('shop-profile-product-link-fixture-listing')),
          180,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final scenario in ['loading', 'empty', 'error', 'exception']) {
    testWidgets('supported product state $scenario', (tester) async {
      final pending = Completer<Either<String, List<ShopProductEntity>>>();
      when(() => repository.getShopProductsByShop(any())).thenAnswer((_) {
        if (scenario == 'loading') return pending.future;
        if (scenario == 'exception') {
          return Future.error(StateError('fixture failure'));
        }
        return Future.value(
          scenario == 'empty' ? const Right([]) : const Left('fixture error'),
        );
      });
      await pump(tester, settle: scenario != 'loading');
      final key = scenario == 'exception' ? 'error' : scenario;
      expect(find.byKey(Key('shop-profile-products-$key')), findsOneWidget);
      expect(
        find.byKey(const Key('shop-profile-directions-action')),
        findsOneWidget,
      );
      expect(find.text('fixture error'), findsNothing);
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('evidence')),
        matchesGoldenFile('goldens/w45a_r2_shop_$scenario.png'),
      );
      if (scenario == 'loading') {
        pending.complete(const Right([_listing]));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const Key('shop-profile-products-loading')),
          findsNothing,
        );
        expect(find.text(_product.name), findsOneWidget);
      }
    });
  }

  testWidgets('missing rating, address and hours stay truthful', (
    tester,
  ) async {
    await pump(
      tester,
      shop: const ShopEntity(id: 'fixture-missing', name: 'Mağaza'),
    );
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    expect(find.text('Adres bilgisi eklenmemiş.'), findsOneWidget);
    expect(find.text('Çalışma saatleri eklenmemiş.'), findsOneWidget);
    expect(find.text('Şu an açık'), findsNothing);
    expect(find.text('Kapalı'), findsNothing);
    await expectLater(
      find.byKey(const Key('evidence')),
      matchesGoldenFile('goldens/w45a_r2_shop_missing_info.png'),
    );
  });

  testWidgets('many products retain availability and final product handoff', (
    tester,
  ) async {
    final products = List.generate(
      24,
      (index) => ShopProductEntity(
        id: 'fixture-listing-$index',
        shopId: _shop.id,
        productId: 'fixture-product-$index',
        price: 9999999.99,
        isAvailable: index != 0,
        product: ProductEntity(
          id: 'fixture-product-$index',
          name:
              'Uzun ürün adı: kablosuz kulaklık ve taşınabilir şarj aksesuar seti $index',
          price: 9999999.99,
          categoryId: 'fixture-category',
          stock: 2,
          images: const [],
        ),
      ),
    );
    when(
      () => repository.getShopProductsByShop(any()),
    ).thenAnswer((_) async => Right(products));
    ProductEntity? opened;
    await pump(
      tester,
      width: 320,
      textScale: 1.3,
      destination: (product) {
        opened = product;
        return const Scaffold(body: Text('Son ürün'));
      },
    );
    await tester.scrollUntilVisible(
      find.text('Şu an mevcut değil'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const Key('evidence')),
      matchesGoldenFile(
        'goldens/w45a_r2_shop_product_stress_320_scale_130.png',
      ),
    );
    final last = find.byKey(
      const Key('shop-profile-product-link-fixture-listing-23'),
    );
    await tester.scrollUntilVisible(
      last.hitTestable(),
      400,
      maxScrolls: 40,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(opened?.id, 'fixture-product-23');
    expect(find.text('Son ürün'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('accessible labels and touch targets', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester);
    expect(
      tester.getSemantics(find.text('Mağazayı keşfet')),
      matchesSemantics(
        isHeader: true,
        label: 'Mağazayı keşfet',
        textDirection: TextDirection.ltr,
      ),
    );
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('back action returns to previous route', (tester) async {
    await pump(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ShopProfileView(
          shop: _shop,
          visualPrototype: true,
          currentUserIdProvider: () => 'fixture-customer',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isTrue);
    await tester.tap(find.byKey(const Key('shop-profile-back')).last);
    await tester.pumpAndSettle();
    expect(navigator.canPop(), isFalse);
    expect(find.text('Mağazayı keşfet'), findsOneWidget);
  });

  testWidgets('phone handoff and directions failure keep existing behavior', (
    tester,
  ) async {
    Uri? target;
    await pump(
      tester,
      shop: _shop.copyWith(phone: '000'),
      launcher: (uri, _) async {
        target = uri;
        return uri.scheme == 'tel';
      },
    );
    await tester.tap(find.byKey(const Key('shop-profile-call-action')));
    await tester.pumpAndSettle();
    expect(target, Uri(scheme: 'tel', path: '000'));
    await tester.tap(find.byKey(const Key('shop-profile-directions-action')));
    await tester.pumpAndSettle();
    expect(find.text('Yol tarifi açılamadı'), findsOneWidget);
  });
}
