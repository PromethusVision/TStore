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
  Future<Either<String, ShopEntity?>> getMyShop() async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Right(null);
      }

      final response = await supabaseService.client
          .from(SupabaseTables.shops)
          .select()
          .eq('owner_user_id', user.id)
          .order('created_at', ascending: true)
          .limit(1);

      final rows = response as List;
      if (rows.isEmpty) {
        return const Right(null);
      }

      return Right(ShopModel.fromJson(rows.first as Map<String, dynamic>));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ShopEntity>> createMyShop({
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('Magaza olusturmak icin oturum acmalisiniz.');
      }

      final payload = <String, dynamic>{
        'owner_user_id': user.id,
        'name': name.trim(),
        'description': _trimToNull(description),
        'phone': _trimToNull(phone),
        'address': _trimToNull(address),
        'opening_hours': Map<String, dynamic>.from(
          openingHours ?? const <String, dynamic>{},
        ),
      };

      final response = await supabaseService.client
          .from(SupabaseTables.shops)
          .insert(payload)
          .select()
          .single();

      return Right(ShopModel.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, ShopEntity>> updateMyShop({
    required String shopId,
    required String name,
    String? description,
    String? phone,
    String? address,
    Map<String, dynamic>? openingHours,
  }) async {
    try {
      final user = supabaseService.currentUser;
      if (user == null) {
        return const Left('Magaza guncellemek icin oturum acmalisiniz.');
      }

      final payload = <String, dynamic>{
        'name': name.trim(),
        'description': _trimToNull(description),
        'phone': _trimToNull(phone),
        'address': _trimToNull(address),
        'opening_hours': Map<String, dynamic>.from(
          openingHours ?? const <String, dynamic>{},
        ),
      };

      final response = await supabaseService.client
          .from(SupabaseTables.shops)
          .update(payload)
          .eq('id', shopId)
          .eq('owner_user_id', user.id)
          .select()
          .maybeSingle();

      if (response == null) {
        return const Left(
          'Guncellenecek magaza bulunamadi veya bu magaza icin yetkiniz yok.',
        );
      }

      return Right(ShopModel.fromJson(response));
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
          .map(
            (json) => ShopProductModel.fromJson(json as Map<String, dynamic>),
          )
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
          .map(
            (json) => ShopProductModel.fromJson(json as Map<String, dynamic>),
          )
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
          .map(
            (json) => ShopProductModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(shopProducts);
    } catch (e) {
      return Left(e.toString());
    }
  }

  static String? _trimToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
