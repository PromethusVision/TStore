import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/shop/data/models/shop_model.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/domain/entities/shop_product_entity.dart';
import 'package:t_store/features/shop/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final SupabaseService supabaseService;

  ShopRepositoryImpl({required this.supabaseService});

  static const String _shopProductSelect =
      '*, products(*, categories(name), brands(name)), shops(*)';

  @override
  Future<Either<String, List<ShopEntity>>> getShops() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.shops)
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      final shops = (response as List)
          .map((json) => ShopModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(shops);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProducts() async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.shopProducts)
          .select(_shopProductSelect)
          .eq('is_active', true)
          .eq('is_available', true)
          .order('created_at', ascending: false);

      final shopProducts = (response as List)
          .map((json) =>
              ShopProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(shopProducts);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProductsByProduct(
    String productId,
  ) async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.shopProducts)
          .select(_shopProductSelect)
          .eq('is_active', true)
          .eq('is_available', true)
          .eq('product_id', productId)
          .order('created_at', ascending: false);

      final shopProducts = (response as List)
          .map((json) =>
              ShopProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(shopProducts);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<ShopProductEntity>>> getShopProductsByShop(
    String shopId,
  ) async {
    try {
      final response = await supabaseService.client
          .from(SupabaseTables.shopProducts)
          .select(_shopProductSelect)
          .eq('is_active', true)
          .eq('is_available', true)
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      final shopProducts = (response as List)
          .map((json) =>
              ShopProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(shopProducts);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
