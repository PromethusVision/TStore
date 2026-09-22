import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/data/services/production_public_taxonomy_adapter.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

/// Customer reads always use the public policy-scoped facade. Owner management
/// retains its existing authenticated repository and is never a read fallback.
class ProductionPublicShopRepository implements ShopRepository {
  const ProductionPublicShopRepository({
    required this.adapter,
    required this.ownerRepository,
    this.mediaResolver,
  });
  final ProductionPublicTaxonomyAdapter adapter;
  final ShopRepository ownerRepository;
  final PublicMediaSourceResolver? mediaResolver;
  static const unavailable =
      'Mağaza bilgileri şu anda doğrulanamıyor. Lütfen tekrar deneyin.';

  Future<List<Map<String, dynamic>>> _pages(
    Future<dynamic> Function(Map<String, dynamic>) read,
    Map<String, dynamic> args,
  ) async {
    final all = <Map<String, dynamic>>[];
    for (var page = 0; page < 1000; page++) {
      final raw = await read({...args, 'p_limit': 100, 'p_offset': page * 100});
      if (raw is! List || raw.length > 100) {
        throw const FormatException('Public shop page invalid.');
      }
      all.addAll(raw.map((r) => Map<String, dynamic>.from(r as Map)));
      if (raw.length < 100) return all;
    }
    throw StateError('Public shop pagination exceeded.');
  }

  Future<Either<String, List<ShopEntity>>> _shops(
    Map<String, dynamic> args,
  ) async {
    try {
      final rows = await _pages(adapter.readShops, args);
      final ids = <String>{};
      final shops = rows
          .map((r) {
            final shop = ShopModel.fromJson(r);
            if (!shop.isActive || !ids.add(shop.id)) {
              throw const FormatException('Public shop mismatch.');
            }
            return shop;
          })
          .toList(growable: false);
      return Right(shops);
    } on Object {
      return const Left(unavailable);
    }
  }

  Future<Either<String, List<ShopProductEntity>>> _listings(
    Map<String, dynamic> args,
  ) async {
    try {
      final rows = await _pages(adapter.readListings, args), ids = <String>{};
      final listings = rows
          .map((r) {
            final data = Map<String, dynamic>.from(r['shop_product'] as Map);
            final product = Map<String, dynamic>.from(data['products'] as Map);
            final shop = Map<String, dynamic>.from(data['shops'] as Map);
            if (r['shop_product_id'] != data['id'] ||
                r['product_id'] != data['product_id'] ||
                r['product_id'] != product['id'] ||
                r['canonical_category_id'] != product['category_id'] ||
                product['legacy_category_id'] is! String ||
                r['canonical_path'] is! String ||
                data['shop_id'] != shop['id'] ||
                data['is_active'] != true ||
                data['is_available'] != true ||
                product['is_active'] != true ||
                shop['is_active'] != true ||
                !ids.add(data['id'] as String)) {
              throw const FormatException(
                'Canonical seller projection mismatch.',
              );
            }
            return ShopProductModel.fromJson(
              data,
              mediaResolver: mediaResolver,
            );
          })
          .toList(growable: false);
      return Right(listings);
    } on Object {
      return const Left(unavailable);
    }
  }

  @override
  Future<Either<String, List<ShopEntity>>> getShops() => _shops({});
  @override
  Future<Either<String, List<ShopEntity>>> getShopsByOwnerUserIds(
    List<String> ownerUserIds,
  ) async {
    final ids = ownerUserIds.toSet().toList(), result = <ShopEntity>[];
    for (var i = 0; i < ids.length; i += 100) {
      final batch = await _shops({
        'p_owner_ids': ids.skip(i).take(100).toList(),
      });
      if (batch.isLeft()) return const Left(unavailable);
      batch.fold((_) {}, result.addAll);
    }
    return Right(result);
  }

  @override
  Future<Either<String, ShopEntity?>> getShopById(String shopId) async =>
      (await _shops({'p_shop_id': shopId})).bind(
        (rows) => rows.isEmpty
            ? const Right(null)
            : rows.length == 1 && rows.single.id == shopId
            ? Right(rows.single)
            : const Left(unavailable),
      );
  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProducts() =>
      _listings({});
  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProductsByProduct(
    String productId,
  ) => _listings({'p_product_id': productId});
  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProductsByShop(
    String shopId,
  ) => _listings({'p_shop_id': shopId});
  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProductsByProductIds(
    List<String> productIds,
  ) async {
    final ids = productIds.toSet().toList(), result = <ShopProductEntity>[];
    for (var i = 0; i < ids.length; i += 100) {
      final batch = await _listings({
        'p_product_ids': ids.skip(i).take(100).toList(),
      });
      if (batch.isLeft()) return const Left(unavailable);
      batch.fold((_) {}, result.addAll);
    }
    return Right(result);
  }

  @override
  Future<Either<String, ShopEntity?>> getMyShop() =>
      ownerRepository.getMyShop();
  @override
  Future<Either<String, ShopEntity>> createMyShop({
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) => ownerRepository.createMyShop(
    name: name,
    description: description,
    phone: phone,
    address: address,
    openingHours: openingHours,
  );
  @override
  Future<Either<String, ShopEntity>> updateMyShop({
    required String shopId,
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) => ownerRepository.updateMyShop(
    shopId: shopId,
    name: name,
    description: description,
    phone: phone,
    address: address,
    openingHours: openingHours,
  );
}
