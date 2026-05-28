import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_state.dart';
import 'package:t_store/features/shop/presentation/widgets/cart_items_list.dart';

class CartView extends StatefulWidget {
  const CartView({
    super.key,
  });

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().getCartItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBarModel: AppBarModel(
          title:
              Text("Sepet", style: Theme.of(context).textTheme.headlineSmall),
          hasArrowBack: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return Center(child: Text(state.message));
            }

            if (state is CartLoaded) {
              if (state.items.isEmpty) {
                return Center(
                  child: Text(
                    'Sepetiniz boş',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }

              return CartItemsList(items: state.items);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
