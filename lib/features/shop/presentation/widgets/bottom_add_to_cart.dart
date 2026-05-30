import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/view_models/circular_icon_view_model.dart';
import 'package:t_store/core/common/widgets/circular_icon.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_state.dart';
import 'package:t_store/features/shop/domain/entities/product_entity.dart';

class BottomAddToCart extends StatefulWidget {
  const BottomAddToCart({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  State<BottomAddToCart> createState() => _BottomAddToCartState();
}

class _BottomAddToCartState extends State<BottomAddToCart> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is CartItemAdded) {
          THelperFunctions.showSnackBar(
            context: context,
            message: 'Sepete eklendi',
            type: SnackBarType.success,
          );
        } else if (state is CartError) {
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        decoration: BoxDecoration(
          color: dark ? TColors.darkGrey : TColors.light,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(TSizes.cardRadiusLg),
            topRight: Radius.circular(TSizes.cardRadiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircularIcon(
                  circularIconModel: CircularIconModel(
                      icon: Iconsax.minus,
                      height: 40,
                      width: 40,
                      color: TColors.white,
                      backgroundColor: TColors.darkerGrey,
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() => quantity--);
                        }
                      }),
                ),
                const SizedBox(
                  width: TSizes.spaceBtwItems,
                ),
                Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(
                  width: TSizes.spaceBtwItems,
                ),
                CircularIcon(
                  circularIconModel: CircularIconModel(
                      icon: Iconsax.add,
                      height: 40,
                      width: 40,
                      color: TColors.white,
                      backgroundColor: TColors.black,
                      onPressed: () {
                        setState(() => quantity++);
                      }),
                ),
                const SizedBox(
                  width: TSizes.spaceBtwItems,
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: TColors.black,
                side: const BorderSide(color: TColors.black),
              ),
              onPressed: () {
                final user = SupabaseService.instance.currentUser;

                if (user == null) {
                  THelperFunctions.navigateToScreen(
                    context,
                    const LoginView(),
                  );
                  return;
                }

                context.read<CartCubit>().addToCart(
                      productId: widget.product.id,
                      quantity: quantity,
                    );
              },
              child: const Text("Sepete Ekle"),
            ),
          ],
        ),
      ),
    );
  }
}
