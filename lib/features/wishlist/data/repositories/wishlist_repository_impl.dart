import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/public_media_source_resolver.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/core/utils/helpers/customer_error_message.dart';
import 'package:t_store/features/wishlist/data/models/wishlist_item_model.dart';
import 'package:t_store/features/wishlist/domain/entities/wishlist_item_entity.dart';
import 'package:t_store/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  final SupabaseService supabaseService;
  final PublicMediaSourceResolver mediaResolver;

  WishlistRepositoryImpl({
    required this.supabaseService,
    PublicMediaSourceResolver? mediaResolver,
  }) : mediaResolver =
           mediaResolver ??
           PublicMediaSourceResolver.fromSupabaseClient(supabaseService.client);

  String get _userId => supabaseService.currentUser?.id ?? '';

  @override
  Future<Either<String, List<WishlistItemEntity>>> getWishlist() async {
    try {
      if (_userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select('*, products(*, categories(name), brands(name))')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map(
            (json) => WishlistItemModel.fromJson(
              json as Map<String, dynamic>,
              mediaResolver: mediaResolver,
            ),
          )
          .toList();

      return Right(items);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Favorileriniz yüklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, WishlistItemEntity>> addToWishlist(
    String productId,
  ) async {
    try {
      if (_userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      // Check if already in wishlist
      final existing = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select()
          .eq('user_id', _userId)
          .eq('product_id', productId)
          .maybeSingle();

      if (existing != null) {
        return const Left('Bu ürün zaten favorilerinizde.');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .insert({'user_id': _userId, 'product_id': productId})
          .select('*, products(*, categories(name), brands(name))')
          .single();

      return Right(
        WishlistItemModel.fromJson(response, mediaResolver: mediaResolver),
      );
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Ürün favorilere eklenemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> removeFromWishlist(String productId) async {
    try {
      if (_userId.isEmpty) {
        return const Left(CustomerErrorMessage.signInRequired);
      }

      await supabaseService.client
          .from(SupabaseTables.wishlist)
          .delete()
          .eq('user_id', _userId)
          .eq('product_id', productId);

      return const Right(null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Ürün favorilerden kaldırılamadı. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, bool>> isInWishlist(String productId) async {
    try {
      if (_userId.isEmpty) {
        return const Right(false);
      }

      final response = await supabaseService.client
          .from(SupabaseTables.wishlist)
          .select('id')
          .eq('user_id', _userId)
          .eq('product_id', productId)
          .maybeSingle();

      return Right(response != null);
    } catch (e) {
      return Left(
        CustomerErrorMessage.from(
          e,
          fallback: 'Favori durumu kontrol edilemedi. Lütfen tekrar deneyin.',
        ),
      );
    }
  }

  @override
  Future<Either<String, void>> toggleWishlist(String productId) async {
    final isInResult = await isInWishlist(productId);

    return isInResult.fold((error) => Left(error), (isIn) async {
      if (isIn) {
        return await removeFromWishlist(productId);
      } else {
        final result = await addToWishlist(productId);
        return result.fold((error) => Left(error), (_) => const Right(null));
      }
    });
  }
}
