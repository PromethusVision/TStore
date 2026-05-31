import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/cart/data/models/cart_item_v2_model.dart';
import 'package:t_store/features/cart/data/models/cart_v2_model.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_entity.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';

class CartV2RepositoryImpl implements CartV2Repository {
  final SupabaseService supabaseService;

  CartV2RepositoryImpl({required this.supabaseService});

  String get _userId => supabaseService.currentUser?.id ?? '';

  static const String _cartItemSelect =
      '*, shop_products(*, products(*, categories(name), brands(name)), shops(*))';

  @override
  Future<Either<String, CartV2Entity?>> getActiveCart() async {
    try {
      if (_userId.isEmpty) {
        return const Left('Lutfen once giris yapin');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.carts)
          .select()
          .eq('user_id', _userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) {
        return const Right(null);
      }

      return Right(CartV2Model.fromJson(response));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CartItemV2Entity>>> getCartItems(
    String cartId,
  ) async {
    try {
      if (_userId.isEmpty) {
        return const Left('Lutfen once giris yapin');
      }

      final response = await supabaseService.client
          .from(SupabaseTables.cartItemsV2)
          .select(_cartItemSelect)
          .eq('cart_id', cartId)
          .order('created_at', ascending: false);

      final items = (response as List)
          .map(
            (json) => CartItemV2Model.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Right(items);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<CartItemV2Entity>>> getActiveCartItems() async {
    final cartResult = await getActiveCart();

    return cartResult.fold<Future<Either<String, List<CartItemV2Entity>>>>(
      (error) async => Left(error),
      (cart) async {
        if (cart == null) {
          return const Right(<CartItemV2Entity>[]);
        }
        return getCartItems(cart.id);
      },
    );
  }
}
