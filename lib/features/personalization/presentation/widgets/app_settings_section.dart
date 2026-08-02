import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';
import 'package:t_store/features/wishlist/presentation/cubit/wishlist_cubit.dart';

class AppSettingsSection extends StatefulWidget {
  const AppSettingsSection({super.key});

  @override
  State<AppSettingsSection> createState() => _AppSettingsSectionState();
}

class _AppSettingsSectionState extends State<AppSettingsSection> {
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        key: const Key('customer-sign-out'),
        onPressed: _isSigningOut ? null : _signOut,
        style: OutlinedButton.styleFrom(
          backgroundColor: CustomerHomeV1Tokens.surface,
          foregroundColor: CustomerHomeV1Tokens.coral,
          disabledForegroundColor: CustomerHomeV1Tokens.coral.withValues(
            alpha: 0.55,
          ),
          side: const BorderSide(color: Color(0xFFF0C8BE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        icon: _isSigningOut
            ? const SizedBox(
                key: Key('customer-sign-out-progress'),
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CustomerHomeV1Tokens.coral,
                ),
              )
            : const Icon(Icons.logout_rounded, size: 20),
        label: Text(_isSigningOut ? 'Çıkış yapılıyor' : 'Çıkış Yap'),
      ),
    );
  }

  Future<void> _signOut() async {
    if (_isSigningOut) return;

    setState(() => _isSigningOut = true);
    final authCubit = context.read<AuthCubit>();

    try {
      await authCubit.signOut();
      if (!mounted) return;
      if (authCubit.state is! AuthUnauthenticated) return;

      context.read<CartV2Cubit>().clearLocalCart();
      context.read<WishlistCubit>().clearLocalWishlist();
      context.read<NavigationMenuCubit>().changeIndex(0);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const NavigationMenu()),
        (route) => false,
      );
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }
}
