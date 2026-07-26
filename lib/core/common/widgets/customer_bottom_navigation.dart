import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CustomerBottomNavigation extends StatelessWidget {
  const CustomerBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        const NavigationDestination(
          key: Key('customer-nav-home'),
          icon: Icon(Iconsax.home),
          selectedIcon: Icon(Iconsax.home_15),
          label: TTexts.homeView,
        ),
        const NavigationDestination(
          key: Key('customer-nav-nearby'),
          icon: Icon(Iconsax.location),
          selectedIcon: Icon(Iconsax.location5),
          label: TTexts.nearbyView,
        ),
        NavigationDestination(
          key: const Key('customer-nav-cart'),
          icon: const _CartNavigationIcon(),
          selectedIcon: const _CartNavigationIcon(selected: true),
          label: TTexts.cartView,
        ),
        const NavigationDestination(
          key: Key('customer-nav-wishlist'),
          icon: Icon(Iconsax.heart),
          selectedIcon: Icon(Iconsax.heart5),
          label: TTexts.wishlistView,
        ),
        const NavigationDestination(
          key: Key('customer-nav-profile'),
          icon: Icon(Iconsax.user),
          selectedIcon: Icon(Iconsax.user5),
          label: TTexts.profileView,
        ),
      ],
    );
  }
}

class _CartNavigationIcon extends StatelessWidget {
  const _CartNavigationIcon({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartV2Cubit, CartV2State>(
      builder: (context, state) {
        final count = state is CartV2Loaded ? state.itemCount : 0;
        final icon = Icon(
          selected ? Iconsax.shopping_cart5 : Iconsax.shopping_cart,
        );

        if (count <= 0) return icon;

        return Badge(
          key: const Key('customer-nav-cart-badge'),
          label: Text(count > 99 ? '99+' : count.toString()),
          child: icon,
        );
      },
    );
  }
}
