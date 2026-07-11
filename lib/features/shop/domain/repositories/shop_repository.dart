import 'package:dartz/dartz.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';

abstract class ShopRepository {
  Future<Either<String, List<ShopEntity>>> getShops();

  Future<Either<String, ShopEntity?>> getMyShop();

  Future<Either<String, ShopEntity>> createMyShop({
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  });

  Future<Either<String, ShopEntity>> updateMyShop({
    required String shopId,
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  });

  Future<Either<String, List<ShopProductEntity>>> getShopProducts();

  Future<Either<String, List<ShopProductEntity>>> getShopProductsByProduct(
    String productId,
  );

  Future<Either<String, List<ShopProductEntity>>> getShopProductsByShop(
    String shopId,
  );
}
