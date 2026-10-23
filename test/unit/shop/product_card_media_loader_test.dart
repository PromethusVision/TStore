import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/listing_hero_media_repository.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';
import 'package:t_store/features/shop/presentation/helpers/product_card_media_loader.dart';

class _Location extends Mock implements CustomerLocationService {}

class _Media implements ListingHeroMediaRepository {
  final calls = <List<ShopProductEntity>>[];
  Future<List<ListingHeroPhoto>> Function(List<ShopProductEntity>)? answer;
  @override
  Future<List<ListingHeroPhoto>> photos(
    List<ShopProductEntity> listings,
  ) async {
    calls.add(listings);
    return answer == null
        ? [for (final s in listings) photo(s.id)]
        : answer!(listings);
  }
}

ListingHeroPhoto photo(String id, {String? source}) => ListingHeroPhoto(
  listingId: id,
  shopName: id,
  source: source ?? 'https://example.invalid/$id.png',
);
ShopProductEntity listing(
  String id, {
  String product = 'p',
  bool active = true,
  bool available = true,
  bool shopActive = true,
  double lat = 41,
}) => ShopProductEntity(
  id: id,
  shopId: 'shop-$id',
  productId: product,
  price: 10,
  isActive: active,
  isAvailable: available,
  images: ['https://example.invalid/obsolete.png'],
  shop: ShopEntity(
    id: 'shop-$id',
    name: id,
    isActive: shopActive,
    latitude: lat,
    longitude: 29,
  ),
);

void main() {
  test(
    'cards coalesce listing and media reads without mixing product identity',
    () async {
      final media = _Media();
      final reads = <List<String>>[];
      final loader = ProductCardMediaLoader(
        media: media,
        loadListings: (ids) async {
          reads.add(ids);
          return Right([
            listing('a'),
            listing('b', product: 'q'),
            listing('foreign', product: 'other'),
          ]);
        },
      );
      final result = await Future.wait([
        loader.load('p'),
        loader.load('q'),
        loader.load('p'),
      ]);
      expect(reads, [
        ['p', 'q'],
      ]);
      expect(media.calls, hasLength(1));
      expect(result.map((r) => r.map((p) => p.listingId).toList()), [
        ['a'],
        ['b'],
        ['a'],
      ]);
    },
  );
  test(
    'explicit shop card cannot borrow another seller, including same batch',
    () async {
      final media = _Media();
      final loader = ProductCardMediaLoader(
        media: media,
        loadListings: (_) async => Right([listing('other'), listing('own')]),
      );
      final result = await Future.wait([
        loader.load('p'),
        loader.load('p', listings: [listing('own')]),
      ]);
      expect(result[0].map((p) => p.listingId), ['other', 'own']);
      expect(result[1].map((p) => p.listingId), ['own']);
    },
  );
  test(
    'inactive unavailable and inactive-shop listings never reach media port',
    () async {
      final media = _Media();
      final result = await ProductCardMediaLoader(media: media).load(
        'p',
        listings: [
          listing('inactive', active: false),
          listing('unavailable', available: false),
          listing('closed', shopActive: false),
        ],
      );
      expect(result, isEmpty);
      expect(media.calls, isEmpty);
    },
  );
  test(
    'authoritative empty/error cannot revive legacy listing images',
    () async {
      final media = _Media()..answer = (_) async => [];
      final loader = ProductCardMediaLoader(media: media);
      expect(await loader.load('p', listings: [listing('a')]), isEmpty);
      media.answer = (_) async => throw StateError('network');
      expect(await loader.load('p', listings: [listing('a')]), isEmpty);
    },
  );
  test(
    'server media order and seller order survive batch replies; unrelated paths rejected',
    () async {
      final media = _Media()
        ..answer = (_) async => [
          photo('b'),
          photo('a', source: 'https://example.invalid/primary.png'),
          photo('a', source: 'https://example.invalid/second.png'),
          photo('foreign'),
          photo('a', source: 'file:///secret'),
        ];
      final result = await ProductCardMediaLoader(
        media: media,
      ).load('p', listings: [listing('a'), listing('b')]);
      expect(result.map((p) => p.source), [
        'https://example.invalid/primary.png',
        'https://example.invalid/second.png',
        'https://example.invalid/b.png',
      ]);
    },
  );
  test(
    'new lookup after removal is fresh, no sticky signed URL cache',
    () async {
      final media = _Media();
      final loader = ProductCardMediaLoader(media: media);
      expect(await loader.load('p', listings: [listing('a')]), hasLength(1));
      media.answer = (_) async => [];
      expect(await loader.load('p', listings: [listing('a')]), isEmpty);
      expect(media.calls, hasLength(2));
    },
  );
  test(
    'known preferred location uses existing nearest ranking without GPS prompt',
    () async {
      final location = _Location();
      when(
        () => location.cachedCoordinates,
      ).thenReturn(const CustomerCoordinates(latitude: 45, longitude: 29));
      when(() => location.getPreferredLocation()).thenAnswer(
        (_) async => const CustomerPreferredLocation(
          name: 'Preferred',
          coordinates: CustomerCoordinates(latitude: 41, longitude: 29),
        ),
      );
      final result = await ProductCardMediaLoader(
        media: _Media(),
        location: location,
      ).load('p', listings: [listing('far', lat: 42), listing('near')]);
      expect(result.map((p) => p.listingId), ['near', 'far']);
      verifyNever(() => location.getCurrentLocation());
    },
  );
  test(
    'missing listing read fails closed; explicit empty never triggers global lookup',
    () async {
      var reads = 0;
      final media = _Media();
      final loader = ProductCardMediaLoader(
        media: media,
        loadListings: (_) async {
          reads++;
          return const Left('offline');
        },
      );
      expect(await loader.load('p', listings: []), isEmpty);
      expect(reads, 0);
      expect(await loader.load('p'), isEmpty);
      expect(reads, 1);
      expect(media.calls, isEmpty);
    },
  );
  test(
    'large visible batch bounds existing listing read at 100 identifiers',
    () async {
      final sizes = <int>[];
      final loader = ProductCardMediaLoader(
        media: _Media(),
        loadListings: (ids) async {
          sizes.add(ids.length);
          return const Right([]);
        },
      );
      await Future.wait([for (var i = 0; i < 205; i++) loader.load('p$i')]);
      expect(sizes, [100, 100, 5]);
    },
  );
}
