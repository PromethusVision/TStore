import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_bottom_navigation.dart';
import 'package:t_store/core/cubits/navigation_menu_cubit/navigation_menu_cubit.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

// lib/features/home/presentation/views/navigation_menu.dart
class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationMenuCubit, NavigationMenuState>(
      builder: (context, state) {
        final selectedIndex = context.read<NavigationMenuCubit>().selectedIndex;
        return Scaffold(
          bottomNavigationBar: CustomerBottomNavigation(
            selectedIndex: selectedIndex,
            onSelected: (int index) {
              if (index >= 2) {
                final user = SupabaseService.instance.currentUser;
                if (user == null) {
                  THelperFunctions.navigateToScreen(context, const LoginView());
                  return;
                }
              }
              context.read<NavigationMenuCubit>().changeIndex(index);
            },
          ),
          body: context.read<NavigationMenuCubit>().getScreen(),
        );
      },
    );
  }
}
