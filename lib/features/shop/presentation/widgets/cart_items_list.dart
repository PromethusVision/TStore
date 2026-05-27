import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:t_store/features/shop/presentation/widgets/cart_item.dart';

class CartItemsList extends StatelessWidget {
  const CartItemsList({
    super.key,
    this.items = const [],
    this.showAddRemoveButtons = true,
  });

  final List<CartItemEntity> items;
  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return CartItem(item: items[index]);
        },
        separatorBuilder: (context, index) => const SizedBox(
              height: TSizes.spaceBtwSections,
            ),
        itemCount: items.length);
  }
}
