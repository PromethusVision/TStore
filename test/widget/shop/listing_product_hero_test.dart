import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_state.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/presentation/widgets/listing_product_hero.dart';
import '../../unit/shop/listing_hero_test.dart' show seller;
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class WishlistMock extends MockCubit<WishlistState> implements WishlistCubit {}

void main() {
  const photos = [
    ListingHeroPhoto(listingId: 'a', shopName: 'Esnaf A', source: 'a-primary'),
    ListingHeroPhoto(listingId: 'a', shopName: 'Esnaf A', source: 'a-other'),
    ListingHeroPhoto(listingId: 'b', shopName: 'Esnaf B', source: 'b-primary'),
  ];
  Future<void> host(
    WidgetTester tester, {
    required List<String> failures,
    List<ListingHeroPhoto> items = photos,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 340,
            width: 390,
            child: ListingHeroPhotoChain(
              photos: items,
              imageBuilder: (source, success, fail) =>
                  failures.contains(source) ? fail() : success(Text(source)),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('primary attribution and same listing fallback', (tester) async {
    await host(tester, failures: []);
    expect(find.text('a-primary'), findsOneWidget);
    expect(find.text('Fotoğraf: Esnaf A'), findsOneWidget);
    await host(tester, failures: ['a-primary']);
    expect(find.text('a-other'), findsOneWidget);
    expect(find.text('Fotoğraf: Esnaf A'), findsOneWidget);
  });
  testWidgets(
    'load failure advances to next ranked seller with correct source label',
    (tester) async {
      await host(tester, failures: ['a-primary', 'a-other']);
      expect(find.text('b-primary'), findsOneWidget);
      expect(find.text('Fotoğraf: Esnaf B'), findsOneWidget);
      expect(find.text('Fotoğraf: Esnaf A'), findsNothing);
    },
  );
  testWidgets(
    'zero eligible photos and failed entire chain use existing placeholder',
    (tester) async {
      await host(tester, failures: [], items: []);
      expect(find.byKey(const Key('listing-hero-placeholder')), findsOneWidget);
      await host(tester, failures: photos.map((p) => p.source).toList());
      expect(find.byKey(const Key('listing-hero-placeholder')), findsOneWidget);
    },
  );
  testWidgets(
    'hero changes with shared sorted result and does not read central images',
    (tester) async {
      const product = ProductEntity(
        id: 'p',
        name: 'P',
        price: 99,
        categoryId: 'c',
        stock: 0,
        images: ['assets/central.png'],
      );
      final rows = [
        seller('a', 20, images: ['https://example.invalid/a.png']),
        seller('b', 10, images: ['https://example.invalid/b.png']),
      ];
      Future<void> render(SellerSortOption sort) async {
        final wishlist = WishlistMock();
        when(() => wishlist.isInWishlist(any())).thenReturn(false);
        whenListen(
          wishlist,
          const Stream<WishlistState>.empty(),
          initialState: WishlistLoaded(const []),
        );
        await tester.pumpWidget(
          BlocProvider<WishlistCubit>.value(
            value: wishlist,
            child: MaterialApp(
              home: Scaffold(
                body: ListingProductHero(
                  product: product,
                  ranking: SellerRanking.rank(rows, null, sort),
                  repository: const LegacyListingHeroMediaRepository(),
                  currentUserIdProvider: () => null,
                  imageBuilder: (source, success, fail) =>
                      success(Text(source)),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await render(SellerSortOption.cheapest);
      expect(find.text('Fotoğraf: Esnaf b'), findsOneWidget);
      await render(SellerSortOption.mostExpensive);
      expect(find.text('Fotoğraf: Esnaf a'), findsOneWidget);
      expect(find.text('assets/central.png'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
