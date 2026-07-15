import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/cart/presentation/cubit/cart_v2_cubit.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          await context.read<AuthCubit>().signOut();
          if (!context.mounted) return;
          context.read<CartV2Cubit>().clearLocalCart();
          // reset menu to Home
          context.read<NavigationMenuCubit>().changeIndex(0);
          // clear navigation stack and open NavigationMenu as root
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const NavigationMenu()),
            (route) => false,
          );
        },
        child: const Text("Çıkış Yap"),
      ),
    );
  }
}
