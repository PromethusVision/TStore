import 'package:dartz/dartz.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/supabase/supabase_tables.dart';
import 'package:t_store/features/cart/data/models/cart_item_v2_model.dart';
import 'package:t_store/features/cart/data/models/cart_v2_model.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_entity.dart';
import 'package:t_store/features/cart/domain/repositories/cart_v2_repository.dart';
import 'package:t_store/features/shop/data/models/shop_product_model.dart';

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

  @override
  Future<Either<String, CartV2AddResult>> addShopProductToCart({
    required String shopProductId,
    required int quantity,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left('Lutfen once giris yapin');
      }

      if (quantity <= 0) {
        return const Left('Adet 1 veya daha buyuk olmali');
      }

      final shopProductResponse = await supabaseService.client
          .from(SupabaseTables.shopProducts)
          .select()
          .eq('id', shopProductId)
          .eq('is_active', true)
          .eq('is_available', true)
          .maybeSingle();

      if (shopProductResponse == null) {
        return const Left('Urun bu esnafta satista degil');
      }

      final shopProduct = ShopProductModel.fromJson(shopProductResponse);
      final activeCartResult = await getActiveCart();

      return activeCartResult.fold<Future<Either<String, CartV2AddResult>>>(
        (error) async => Left(error),
        (activeCart) async {
          if (activeCart == null) {
            final cartResponse = await supabaseService.client
                .from(SupabaseTables.carts)
                .insert({
                  'user_id': _userId,
                  'shop_id': shopProduct.shopId,
                  'status': 'active',
                })
                .select()
                .single();

            final cart = CartV2Model.fromJson(cartResponse);

            await supabaseService.client
                .from(SupabaseTables.cartItemsV2)
                .insert({
                  'cart_id': cart.id,
                  'shop_product_id': shopProductId,
                  'quantity': quantity,
                })
                .select()
                .single();

            return Right(
              CartV2AddSuccess(
                cartId: cart.id,
                shopId: shopProduct.shopId,
                shopProductId: shopProductId,
                quantity: quantity,
              ),
            );
          }

          if (activeCart.shopId != shopProduct.shopId) {
            return Right(
              CartV2ShopConflict(
                existingCartId: activeCart.id,
                existingShopId: activeCart.shopId,
                newShopId: shopProduct.shopId,
                shopProductId: shopProductId,
                quantity: quantity,
              ),
            );
          }

          final existingItem = await supabaseService.client
              .from(SupabaseTables.cartItemsV2)
              .select()
              .eq('cart_id', activeCart.id)
              .eq('shop_product_id', shopProductId)
              .maybeSingle();

          if (existingItem != null) {
            final existingQuantity = existingItem['quantity'] as int? ?? 0;
            final newQuantity = existingQuantity + quantity;

            await supabaseService.client
                .from(SupabaseTables.cartItemsV2)
                .update({'quantity': newQuantity})
                .eq('id', existingItem['id'])
                .select()
                .single();

            return Right(
              CartV2AddSuccess(
                cartId: activeCart.id,
                shopId: shopProduct.shopId,
                shopProductId: shopProductId,
                quantity: newQuantity,
              ),
            );
          }

          await supabaseService.client
              .from(SupabaseTables.cartItemsV2)
              .insert({
                'cart_id': activeCart.id,
                'shop_product_id': shopProductId,
                'quantity': quantity,
              })
              .select()
              .single();

          return Right(
            CartV2AddSuccess(
              cartId: activeCart.id,
              shopId: shopProduct.shopId,
              shopProductId: shopProductId,
              quantity: quantity,
            ),
          );
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, CartV2AddResult>> replaceActiveCartWithShopProduct({
    required String shopProductId,
    required int quantity,
  }) async {
    try {
      if (_userId.isEmpty) {
        return const Left('Lutfen once giris yapin');
      }

      if (quantity <= 0) {
        return const Left('Adet 1 veya daha buyuk olmali');
      }

      final shopProductResponse = await supabaseService.client
          .from(SupabaseTables.shopProducts)
          .select()
          .eq('id', shopProductId)
          .eq('is_active', true)
          .eq('is_available', true)
          .maybeSingle();

      if (shopProductResponse == null) {
        return const Left('Urun bu esnafta satista degil');
      }

      final shopProduct = ShopProductModel.fromJson(shopProductResponse);
      final activeCartResult = await getActiveCart();

      return activeCartResult.fold<Future<Either<String, CartV2AddResult>>>(
        (error) async => Left(error),
        (activeCart) async {
          if (activeCart != null) {
            await supabaseService.client
                .from(SupabaseTables.carts)
                .update({'status': 'cancelled'})
                .eq('id', activeCart.id)
                .eq('user_id', _userId)
                .eq('status', 'active');
          }

          final cartResponse = await supabaseService.client
              .from(SupabaseTables.carts)
              .insert({
                'user_id': _userId,
                'shop_id': shopProduct.shopId,
                'status': 'active',
              })
              .select()
              .single();

          final cart = CartV2Model.fromJson(cartResponse);

          await supabaseService.client.from(SupabaseTables.cartItemsV2).insert({
            'cart_id': cart.id,
            'shop_product_id': shopProductId,
            'quantity': quantity,
          }).select().single();

          return Right(
            CartV2AddSuccess(
              cartId: cart.id,
              shopId: shopProduct.shopId,
              shopProductId: shopProductId,
              quantity: quantity,
            ),
          );
        },
      );
    } catch (e) {
      return Left(e.toString());
    }
  }
}
