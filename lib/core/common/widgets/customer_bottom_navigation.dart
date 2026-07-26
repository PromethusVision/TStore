import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
    return Material(
      key: const Key('customer-bottom-navigation'),
      color: Colors.white,
      elevation: 14,
      shadowColor: CustomerHomeV1Tokens.navy.withValues(alpha: 0.18),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              _NavigationItem(
                itemKey: const Key('customer-nav-home'),
                label: TTexts.homeView,
                icon: Iconsax.home,
                selectedIcon: Iconsax.home_15,
                selected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavigationItem(
                itemKey: const Key('customer-nav-nearby'),
                label: TTexts.nearbyView,
                icon: Iconsax.location,
                selectedIcon: Iconsax.location5,
                selected: selectedIndex == 1,
                onTap: () => onSelected(1),
              ),
              _CartNavigationItem(
                selected: selectedIndex == 2,
                onTap: () => onSelected(2),
              ),
              _NavigationItem(
                itemKey: const Key('customer-nav-wishlist'),
                label: TTexts.wishlistView,
                icon: Iconsax.heart,
                selectedIcon: Iconsax.heart5,
                selected: selectedIndex == 3,
                onTap: () => onSelected(3),
              ),
              _NavigationItem(
                itemKey: const Key('customer-nav-profile'),
                label: TTexts.profileView,
                icon: Iconsax.user,
                selectedIcon: Iconsax.user5,
                selected: selectedIndex == 4,
                onTap: () => onSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.itemKey,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final Key itemKey;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? CustomerHomeV1Tokens.petrol
        : const Color(0xFF697384);
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkResponse(
          key: itemKey,
          onTap: onTap,
          radius: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 8.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartNavigationItem extends StatelessWidget {
  const _CartNavigationItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CartV2Cubit, CartV2State>(
        builder: (context, state) {
          final count = state is CartV2Loaded ? state.itemCount : 0;
          return Semantics(
            selected: selected,
            button: true,
            label: count > 0
                ? '${TTexts.cartView}, $count ürün'
                : TTexts.cartView,
            child: InkResponse(
              key: const Key('customer-nav-cart'),
              onTap: onTap,
              radius: 34,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -3),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: CustomerHomeV1Tokens.petrol,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: CustomerHomeV1Tokens.softShadow,
                          ),
                          child: const Icon(
                            Iconsax.shopping_bag,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            key: const Key('customer-nav-cart-badge'),
                            right: -1,
                            top: -2,
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: CustomerHomeV1Tokens.yellow,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count > 99 ? '99+' : count.toString(),
                                style: const TextStyle(
                                  color: CustomerHomeV1Tokens.navy,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: Text(
                      TTexts.cartView,
                      maxLines: 1,
                      style: TextStyle(
                        color: selected
                            ? CustomerHomeV1Tokens.petrol
                            : const Color(0xFF697384),
                        fontSize: 8.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
