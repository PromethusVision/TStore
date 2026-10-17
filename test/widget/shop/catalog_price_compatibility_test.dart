import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/core/common/widgets/horizontal_product_card.dart';
import 'package:t_store/core/common/widgets/vertical_product_card.dart';
import 'package:t_store/core/common/widgets/sale_tag.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/shop/data/models/product_model.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/recently_viewed_products_state.dart';
import 'package:t_store/features/shop/presentation/views/recently_viewed_products_view.dart';
import 'package:t_store/features/shop/presentation/views/wishlist_view.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';

class _Wishlist extends MockCubit<WishlistState> implements WishlistCubit {}

class _Recent extends MockCubit<RecentlyViewedProductsState>
    implements RecentlyViewedProductsCubit {}

void main() {
  const legacy = ProductEntity(
    id: 'p1',
    name: 'Kalem',
    price: 50,
    salePrice: 25,
    categoryId: 'c1',
    stock: 0,
    images: [],
  );
  final tagged = legacy.copyWith(
    price: 0,
    attributes: const {'_catalog_price_contract': 'listing_only_v1'},
  );

  test(
    'tag survives DTO/cache roundtrip and unknown contracts fail closed',
    () {
      for (final value in ['listing_only_v1', 'future_contract', null]) {
        final p = ProductModel.fromJson(
          ProductModel.fromEntity(
            legacy.copyWith(attributes: {'_catalog_price_contract': value}),
          ).toJson(),
        );
        expect(p.hasLegacyCatalogPrice, isFalse);
        expect(p.copyWith(name: 'Renamed').hasLegacyCatalogPrice, isFalse);
        expect(p.hasDiscount, isFalse);
        expect(p.discountPercentage, 0);
      }
      expect(legacy.hasLegacyCatalogPrice, isTrue);
      expect(legacy.hasDiscount, isTrue);
      expect(legacy.copyWith(price: 0).hasLegacyCatalogPrice, isTrue);
    },
  );

  for (final horizontal in [true, false]) {
    for (final label in <String?>[null, '125,00 TL', 'Fiyat yüklenemedi']) {
      testWidgets(
        '${horizontal ? 'horizontal' : 'vertical'} uses listing label or prompt, never catalog zero',
        (tester) async {
          final wishlist = _Wishlist();
          whenListen(
            wishlist,
            const Stream<WishlistState>.empty(),
            initialState: WishlistLoaded(const []),
          );
          when(() => wishlist.isInWishlist(any())).thenReturn(false);
          await tester.pumpWidget(
            BlocProvider<WishlistCubit>.value(
              value: wishlist,
              child: MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: SizedBox(
                      width: horizontal ? 310 : 180,
                      height: horizontal ? 130 : 288,
                      child: horizontal
                          ? HorizontalProductCard(
                              product: tagged,
                              priceLabel: label,
                              currentUserIdProvider: () => null,
                            )
                          : VerticalProductCard(
                              product: tagged,
                              priceLabel: label,
                            ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            find.text(label ?? ProductEntity.listingPricePrompt),
            findsOneWidget,
          );
          expect(find.text('0.00'), findsNothing);
          expect(find.byType(SaleTag), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final recent in [true, false]) {
    testWidgets(
      '${recent ? 'recent' : 'wishlist'} keeps prompt and navigation at narrow large-text layout',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final wishlist = _Wishlist();
        whenListen(
          wishlist,
          const Stream<WishlistState>.empty(),
          initialState: WishlistLoaded([
            WishlistItemEntity(
              id: 'w1',
              userId: 'u1',
              productId: tagged.id,
              product: tagged,
            ),
          ]),
        );
        when(() => wishlist.getWishlist()).thenAnswer((_) async {});
        when(() => wishlist.isInWishlist(any())).thenReturn(true);
        final history = _Recent();
        whenListen(
          history,
          const Stream<RecentlyViewedProductsState>.empty(),
          initialState: RecentlyViewedProductsLoaded([tagged]),
        );
        when(() => history.load(any())).thenAnswer((_) async {});
        when(() => history.close()).thenAnswer((_) async {});
        final navigation = NavigationMenuCubit();
        addTearDown(navigation.close);
        Widget destination(ProductEntity p) =>
            Scaffold(body: Text('identity:${p.id}'));
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<WishlistCubit>.value(value: wishlist),
              BlocProvider<NavigationMenuCubit>.value(value: navigation),
            ],
            child: MaterialApp(
              theme: ThemeData.dark(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.3)),
                child: child!,
              ),
              home: recent
                  ? RecentlyViewedProductsView(
                      customerId: 'u1',
                      recentlyViewedProductsCubit: history,
                      productDestinationBuilder: destination,
                    )
                  : WishlistView(destinationBuilder: destination),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(ProductEntity.listingPricePrompt), findsOneWidget);
        expect(find.textContaining('0,00'), findsNothing);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Kalem'));
        await tester.pumpAndSettle();
        expect(find.text('identity:p1'), findsOneWidget);
      },
    );
  }
}
