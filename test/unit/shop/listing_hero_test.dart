import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/seller_ranking.dart';
import 'package:t_store/features/shop/presentation/cubit/listing_hero_cubit.dart';

ShopProductEntity seller(
  String id,
  double price, {
  double longitude = 0,
  List<String> images = const [],
  bool available = true,
}) => ShopProductEntity(
  id: id,
  shopId: 'shop-$id',
  productId: 'product',
  price: price,
  images: images,
  isAvailable: available,
  shop: ShopEntity(
    id: 'shop-$id',
    name: 'Esnaf $id',
    latitude: 0,
    longitude: longitude,
  ),
);

class DelayedHeroRepository implements ListingHeroMediaRepository {
  final requests = <Completer<List<ListingHeroPhoto>>>[];
  @override
  Future<List<ListingHeroPhoto>> photos(List<ShopProductEntity> rows) {
    final c = Completer<List<ListingHeroPhoto>>();
    requests.add(c);
    return c.future;
  }
}

void main() {
  test(
    'price order and original ties are preserved; display and organic ranks agree',
    () {
      final rows = [seller('a', 20), seller('b', 10), seller('c', 10)];
      final ranking = SellerRanking.rank(rows, null, SellerSortOption.cheapest);
      expect(ranking.map((s) => s.shopProduct.id), ['b', 'c', 'a']);
      expect(ranking.map((s) => s.displayRank), [1, 2, 3]);
      expect(ranking.map((s) => s.organicRank), [1, 2, 3]);
      expect(
        SellerRanking.rank(
          rows,
          null,
          SellerSortOption.mostExpensive,
        ).first.shopProduct.id,
        'a',
      );
      expect(SellerRanking.rank(rows, null, null).first.shopProduct.id, 'a');
    },
  );
  test('distance and changed location change #1', () {
    final rows = [seller('a', 20, longitude: 0), seller('b', 10, longitude: 1)];
    expect(
      SellerRanking.rank(
        rows,
        const CustomerCoordinates(latitude: 0, longitude: 0),
        SellerSortOption.nearest,
      ).first.shopProduct.id,
      'a',
    );
    expect(
      SellerRanking.rank(
        rows,
        const CustomerCoordinates(latitude: 0, longitude: 1),
        SellerSortOption.nearest,
      ).first.shopProduct.id,
      'b',
    );
  });
  test(
    'unavailable, inactive shop, explicit filter and radius exclude from shared result',
    () {
      final a = seller('a', 1, available: false),
          b = seller('b', 2, longitude: 1),
          c = seller('c', 3);
      final d = seller('d', 0).copyWith(
        shop: const ShopEntity(id: 'd', name: 'Closed', isActive: false),
      );
      final all = [a, b, c, d];
      expect(
        SellerRanking.rank(
          all,
          null,
          SellerSortOption.cheapest,
        ).map((s) => s.shopProduct.id),
        ['b', 'c'],
      );
      expect(
        SellerRanking.rank(
          all,
          null,
          null,
          filter: (s) => s.id == 'c',
        ).single.shopProduct.id,
        'c',
      );
      expect(
        SellerRanking.rank(
          all,
          const CustomerCoordinates(latitude: 0, longitude: 0),
          SellerSortOption.nearest,
          radiusMeters: 1000,
        ).single.shopProduct.id,
        'c',
      );
    },
  );
  test('unknown distances are last and tie ordering remains stable', () {
    final rows = [
      seller('a', 1).copyWith(
        shop: const ShopEntity(id: 'a', name: 'unknown'),
      ),
      seller('b', 2),
    ];
    expect(
      SellerRanking.rank(
        rows,
        const CustomerCoordinates(latitude: 0, longitude: 0),
        SellerSortOption.nearest,
      ).first.shopProduct.id,
      'b',
    );
  });
  test(
    'no photo on #1 falls through to next eligible seller; unsafe images ignored',
    () async {
      final photos = await const LegacyListingHeroMediaRepository().photos([
        seller('a', 1),
        seller(
          'b',
          2,
          images: ['javascript:bad', 'https://example.invalid/b.png'],
        ),
        seller(
          'c',
          3,
          available: false,
          images: ['https://example.invalid/c.png'],
        ),
      ]);
      expect(photos.single.listingId, 'b');
      expect(photos.single.shopName, 'Esnaf b');
    },
  );
  test('old async media response cannot replace the new ranking', () async {
    final repo = DelayedHeroRepository();
    final hero = ListingHeroCubit(repo);
    final first = hero.load(SellerRanking.rank([seller('a', 1)], null, null));
    final second = hero.load(SellerRanking.rank([seller('b', 1)], null, null));
    repo.requests[1].complete([
      const ListingHeroPhoto(listingId: 'b', shopName: 'B', source: 'b'),
    ]);
    await second;
    repo.requests[0].complete([
      const ListingHeroPhoto(listingId: 'a', shopName: 'A', source: 'a'),
    ]);
    await first;
    expect(hero.state.single.listingId, 'b');
    await hero.close();
  });
  test(
    'loading a new result clears previous photo; zero sellers stays placeholder',
    () async {
      final hero = ListingHeroCubit(const LegacyListingHeroMediaRepository());
      await hero.load(
        SellerRanking.rank(
          [
            seller('a', 1, images: ['https://example.invalid/a.png']),
          ],
          null,
          null,
        ),
      );
      expect(hero.state.length, 1);
      final loading = hero.load(const []);
      expect(hero.state, isEmpty);
      await loading;
      expect(hero.state, isEmpty);
      await hero.close();
    },
  );
}
