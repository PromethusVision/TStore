import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_state.dart';

class CustomerBottomNavigation extends StatelessWidget {
  const CustomerBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.unreadMessageCount = 0,
    this.visualPrototype = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int unreadMessageCount;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final navigationRow = Row(
      children: [
        _NavigationItem(
          itemKey: const Key('customer-nav-home'),
          label: TTexts.homeView,
          icon: Iconsax.home,
          selectedIcon: Iconsax.home_15,
          selected: selectedIndex == 0,
          onTap: () => onSelected(0),
          visualPrototype: visualPrototype,
        ),
        _NavigationItem(
          itemKey: const Key('customer-nav-nearby'),
          label: TTexts.nearbyView,
          icon: Iconsax.location,
          selectedIcon: Iconsax.location5,
          selected: selectedIndex == 1,
          onTap: () => onSelected(1),
          visualPrototype: visualPrototype,
        ),
        _CartNavigationItem(
          selected: selectedIndex == 2,
          onTap: () => onSelected(2),
          visualPrototype: visualPrototype,
        ),
        _NavigationItem(
          itemKey: const Key('customer-nav-wishlist'),
          label: TTexts.wishlistView,
          icon: Iconsax.heart,
          selectedIcon: Iconsax.heart5,
          selected: selectedIndex == 3,
          onTap: () => onSelected(3),
          visualPrototype: visualPrototype,
        ),
        _NavigationItem(
          itemKey: const Key('customer-nav-profile'),
          label: TTexts.profileView,
          icon: Iconsax.user,
          selectedIcon: Iconsax.user5,
          selected: selectedIndex == 4,
          onTap: () => onSelected(4),
          badgeCount: unreadMessageCount,
          badgeKey: const Key('customer-nav-profile-badge'),
          visualPrototype: visualPrototype,
        ),
      ],
    );

    if (visualPrototype) {
      return Material(
        key: const Key('customer-bottom-navigation'),
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: EsnaftaVarColors.surface,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
              border: Border.all(color: EsnaftaVarColors.divider),
              boxShadow: CustomerHomeV1Tokens.softShadow,
            ),
            child: navigationRow,
          ),
        ),
      );
    }

    return Material(
      key: const Key('customer-bottom-navigation'),
      color: EsnaftaVarColors.surface,
      elevation: 14,
      shadowColor: EsnaftaVarColors.textPrimary.withValues(alpha: 0.14),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: Container(
          height: 72,
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: EsnaftaVarColors.divider)),
          ),
          child: navigationRow,
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
    this.badgeCount = 0,
    this.badgeKey,
    this.visualPrototype = false,
  });

  final Key itemKey;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;
  final Key? badgeKey;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    final color = selected && visualPrototype
        ? EsnaftaVarColors.textOnPrimary
        : selected
        ? CustomerHomeV1Tokens.petrol
        : EsnaftaVarColors.textMuted;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: badgeCount > 0 ? '$label, $badgeCount okunmamış mesaj' : label,
        child: InkResponse(
          key: itemKey,
          onTap: onTap,
          radius: 30,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: visualPrototype ? 34 : 38,
                    height: visualPrototype ? 34 : 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? visualPrototype
                                ? CustomerHomeV1Tokens.petrol
                                : EsnaftaVarColors.primarySoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
                    ),
                    child: Icon(
                      selected ? selectedIcon : icon,
                      color: color,
                      size: 22,
                    ),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      key: badgeKey,
                      top: -8,
                      right: -12,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: CustomerHomeV1Tokens.coral,
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radiusPill,
                          ),
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: EsnaftaVarColors.textOnPrimary,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: visualPrototype ? 9.5 : 10.5,
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
  const _CartNavigationItem({
    required this.selected,
    required this.onTap,
    this.visualPrototype = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final bool visualPrototype;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartV2Cubit, CartV2State>(
      builder: (context, state) {
        final count = state is CartV2Loaded ? state.itemCount : 0;
        if (visualPrototype) {
          return _NavigationItem(
            itemKey: const Key('customer-nav-cart'),
            label: TTexts.cartView,
            icon: Iconsax.shopping_bag,
            selectedIcon: Iconsax.shopping_bag,
            selected: selected,
            onTap: onTap,
            badgeCount: count,
            badgeKey: const Key('customer-nav-cart-badge'),
            visualPrototype: true,
          );
        }
        return Expanded(
          child: Semantics(
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
                            border: Border.all(
                              color: EsnaftaVarColors.textOnPrimary,
                              width: 3,
                            ),
                            boxShadow: CustomerHomeV1Tokens.softShadow,
                          ),
                          child: const Icon(
                            Iconsax.shopping_bag,
                            color: EsnaftaVarColors.textOnPrimary,
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
                            : CustomerHomeV1Tokens.muted,
                        fontSize: 10.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
