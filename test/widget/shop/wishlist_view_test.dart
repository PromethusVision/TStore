import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/views/product_details_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class MockWishlistCubit extends MockCubit<WishlistState>
    implements WishlistCubit {}

void main() {
  const product = ProductEntity(
    id: 'product-1',
    name: 'Mahalle Kahvesi',
    price: 125,
    salePrice: 100,
    categoryId: 'category-1',
    stock: 5,
    images: [],
    brandName: 'Semt Kavurucusu',
  );
  const wishlistItem = WishlistItemEntity(
    id: 'wishlist-1',
    userId: 'customer-1',
    productId: 'product-1',
    product: product,
  );
  const missingProductItem = WishlistItemEntity(
    id: 'wishlist-2',
    userId: 'customer-1',
    productId: 'deleted-product',
  );
  const invalidProduct = ProductEntity(
    id: '',
    name: 'Kimliksiz Ürün',
    price: 50,
    categoryId: 'category-1',
    stock: 1,
    images: [],
  );
  const invalidProductItem = WishlistItemEntity(
    id: 'wishlist-invalid',
    userId: 'customer-1',
    productId: 'invalid-product',
    product: invalidProduct,
  );

  late MockWishlistCubit wishlistCubit;
  late NavigationMenuCubit navigationCubit;

  setUp(() {
    wishlistCubit = MockWishlistCubit();
    navigationCubit = NavigationMenuCubit()..changeIndex(3);
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {});
    when(
      () => wishlistCubit.removeFromWishlist(any()),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await navigationCubit.close();
  });

  Widget buildSubject(
    WishlistState initialState, {
    WishlistProductDestinationBuilder? destinationBuilder,
  }) {
    whenListen(
      wishlistCubit,
      const Stream<WishlistState>.empty(),
      initialState: initialState,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<WishlistCubit>.value(value: wishlistCubit),
        BlocProvider<NavigationMenuCubit>.value(value: navigationCubit),
      ],
      child: MaterialApp(
        home: WishlistView(destinationBuilder: destinationBuilder),
      ),
    );
  }

  testWidgets('açıldığında favorileri yükler ve bekleme durumunu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(WishlistLoading()));
    await tester.pump();

    expect(find.byKey(const Key('wishlist-loading')), findsOneWidget);
    expect(find.byKey(const Key('wishlist-header')), findsOneWidget);
    verify(() => wishlistCubit.getWishlist()).called(1);
  });

  testWidgets('boş durumda ürün keşfine yönlendirir', (tester) async {
    await tester.pumpWidget(buildSubject(WishlistLoaded(const [])));
    await tester.pumpAndSettle();

    expect(find.text('Henüz favorin yok'), findsOneWidget);
    expect(find.text('Ürünleri Keşfet'), findsOneWidget);

    await tester.tap(find.text('Ürünleri Keşfet'));
    await tester.pump();

    expect(navigationCubit.selectedIndex, 0);
  });

  testWidgets('hata durumunda güvenli mesaj ve yeniden deneme sunar', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildSubject(const WishlistError('PostgrestException: gizli ayrıntı')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorilerin yüklenemedi'), findsOneWidget);
    expect(find.textContaining('PostgrestException'), findsNothing);

    await tester.tap(find.text('Tekrar Dene'));
    await tester.pump();

    verify(() => wishlistCubit.getWishlist()).called(2);
  });

  testWidgets('yalnızca mevcut gerçek ürünleri gösterir', (tester) async {
    await tester.pumpWidget(
      buildSubject(WishlistLoaded(const [wishlistItem, missingProductItem])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mahalle Kahvesi'), findsOneWidget);
    expect(find.text('Semt Kavurucusu'), findsOneWidget);
    expect(find.text('%20'), findsOneWidget);
    expect(find.text('%0'), findsNothing);
    expect(find.textContaining('Product '), findsNothing);
    expect(find.byKey(const Key('wishlist-customer-content')), findsOneWidget);
    expect(find.byKey(const Key('wishlist-products-grid')), findsOneWidget);
    expect(find.byKey(const Key('wishlist-product-product-1')), findsOneWidget);
    expect(find.byKey(const Key('favorite-action-product-1')), findsOneWidget);
  });

  testWidgets('ürün kartı ürün detayını açar', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        WishlistLoaded(const [wishlistItem]),
        destinationBuilder: (_) =>
            const Scaffold(body: Text('Ürün detay hedefi')),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('wishlist-product-product-1')));
    await tester.pumpAndSettle();

    expect(find.text('Ürün detay hedefi'), findsOneWidget);
  });

  testWidgets('ürün kaydı bulunmayan favoriyi güvenle gizler', (tester) async {
    await tester.pumpWidget(
      buildSubject(WishlistLoaded(const [missingProductItem])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Henüz favorin yok'), findsOneWidget);
  });

  testWidgets('art arda dokunmada ürünü yalnızca bir kez kaldırır', (
    tester,
  ) async {
    final removal = Completer<void>();
    when(
      () => wishlistCubit.removeFromWishlist(product.id),
    ).thenAnswer((_) => removal.future);

    await tester.pumpWidget(buildSubject(WishlistLoaded(const [wishlistItem])));
    await tester.pumpAndSettle();

    final favoriteAction = find.byKey(const Key('favorite-action-product-1'));
    await tester.tap(favoriteAction);
    await tester.tap(favoriteAction);
    await tester.pump();

    verify(() => wishlistCubit.removeFromWishlist(product.id)).called(1);
    expect(
      find.byKey(const Key('favorite-action-loading-product-1')),
      findsOneWidget,
    );

    removal.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('kaldırma beklerken ikinci dokunma ürün kartını açmaz', (
    tester,
  ) async {
    final removal = Completer<void>();
    when(
      () => wishlistCubit.removeFromWishlist(product.id),
    ).thenAnswer((_) => removal.future);

    await tester.pumpWidget(buildSubject(WishlistLoaded(const [wishlistItem])));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favorite-action-product-1')));
    await tester.pump();

    final loading = find.byKey(const Key('favorite-action-loading-product-1'));
    expect(loading, findsOneWidget);

    await tester.tap(loading);
    await tester.pump();

    verify(() => wishlistCubit.removeFromWishlist(product.id)).called(1);
    expect(find.byType(ProductDetailsView), findsNothing);

    removal.complete();
    await tester.pumpAndSettle();
  });

  testWidgets('aşağı çekerek favorileri yeniler', (tester) async {
    await tester.pumpWidget(buildSubject(WishlistLoaded(const [wishlistItem])));
    await tester.pumpAndSettle();

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.getWishlist()).called(2);
  });

  testWidgets('kimliği eksik favori ürünü bozuk detay sayfası açmaz', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    await tester.pumpWidget(
      buildSubject(
        WishlistLoaded(const [invalidProductItem]),
        destinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Açılmamalı'));
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('wishlist-product-link-')),
    );

    expect(productLink.onTap, isNull);
    expect(destinationBuildCount, 0);
    expect(find.text('Açılmamalı'), findsNothing);
  });

  testWidgets('favori ürüne hızlı çift dokunma yalnız bir detay açar', (
    tester,
  ) async {
    var destinationBuildCount = 0;
    await tester.pumpWidget(
      buildSubject(
        WishlistLoaded(const [wishlistItem]),
        destinationBuilder: (_) {
          destinationBuildCount++;
          return const Scaffold(body: Text('Tek favori detay hedefi'));
        },
      ),
    );
    await tester.pumpAndSettle();

    final productLink = tester.widget<InkWell>(
      find.byKey(const Key('wishlist-product-link-product-1')),
    );
    productLink.onTap!();
    productLink.onTap!();
    await tester.pumpAndSettle();

    expect(destinationBuildCount, 1);
    expect(find.text('Tek favori detay hedefi'), findsOneWidget);

    Navigator.of(tester.element(find.text('Tek favori detay hedefi'))).pop();
    await tester.pumpAndSettle();

    expect(find.text('Mahalle Kahvesi'), findsOneWidget);
  });
}
