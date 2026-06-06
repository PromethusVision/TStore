import 'package:equatable/equatable.dart';
import 'package:t_store/features/cart/domain/entities/cart_v2_add_result.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_v2_entity.dart';

abstract class CartV2State extends Equatable {
  const CartV2State();

  @override
  List<Object?> get props => [];
}

class CartV2Initial extends CartV2State {}

class CartV2Loading extends CartV2State {}

class CartV2Loaded extends CartV2State {
  final List<CartItemV2Entity> items;

  const CartV2Loaded(this.items);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items];
}

class CartV2Error extends CartV2State {
  final String message;

  const CartV2Error(this.message);

  @override
  List<Object?> get props => [message];
}

class CartV2ItemAdded extends CartV2State {
  final String cartId;
  final String shopId;
  final String shopProductId;
  final int quantity;

  const CartV2ItemAdded({
    required this.cartId,
    required this.shopId,
    required this.shopProductId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [
        cartId,
        shopId,
        shopProductId,
        quantity,
      ];
}

class CartV2ShopConflictState extends CartV2State {
  final CartV2ShopConflict conflict;

  const CartV2ShopConflictState(this.conflict);

  @override
  List<Object?> get props => [conflict];
}
