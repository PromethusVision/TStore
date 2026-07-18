import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
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

  late MockWishlistCubit wishlistCubit;
  late NavigationMenuCubit navigationCubit;

  setUp(() {
    wishlistCubit = MockWishlistCubit();
    navigationCubit = NavigationMenuCubit()..changeIndex(2);
    when(() => wishlistCubit.getWishlist()).thenAnswer((_) async {});
    when(
      () => wishlistCubit.removeFromWishlist(any()),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await navigationCubit.close();
  });

  Widget buildSubject(WishlistState initialState) {
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
      child: const MaterialApp(home: WishlistView()),
    );
  }

  testWidgets('açıldığında favorileri yükler ve bekleme durumunu gösterir', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject(WishlistLoading()));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
    expect(find.byKey(const Key('favorite-action-product-1')), findsOneWidget);
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

  testWidgets('aşağı çekerek favorileri yeniler', (tester) async {
    await tester.pumpWidget(buildSubject(WishlistLoaded(const [wishlistItem])));
    await tester.pumpAndSettle();

    unawaited(
      tester.state<RefreshIndicatorState>(find.byType(RefreshIndicator)).show(),
    );
    await tester.pumpAndSettle();

    verify(() => wishlistCubit.getWishlist()).called(2);
  });
}
