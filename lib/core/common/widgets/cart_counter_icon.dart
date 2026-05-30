import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/cart_counter_icon_view_model.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_state.dart';

class CartCounterIcon extends StatelessWidget {
  const CartCounterIcon({
    super.key,
    required this.cartCounterIconModel,
  });
  final CartCounterIconModel cartCounterIconModel;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded
            ? state.itemCount
            : cartCounterIconModel.count ?? 0;

        return Stack(
          children: [
            IconButton(
              onPressed: cartCounterIconModel.onPressed,
              icon: Icon(
                Iconsax.shopping_bag,
                color: cartCounterIconModel.color,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: TColors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: TColors.white, fontSizeFactor: .8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
