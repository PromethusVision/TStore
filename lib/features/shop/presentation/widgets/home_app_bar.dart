import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/view_models/cart_counter_icon_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/common/widgets/cart_counter_icon.dart';
import 'package:t_store/core/supabase/supabase_service.dart';
import 'package:t_store/core/utils/constants/colors.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/shop/presentation/views/cart_v2_view.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.sessionFullName});

  final String? sessionFullName;

  String _currentSessionFullName() {
    if (sessionFullName != null) return sessionFullName!.trim();

    try {
      final fullName =
          SupabaseService.instance.currentUser?.userMetadata?['full_name'];
      return fullName is String ? fullName.trim() : '';
    } catch (_) {
      return '';
    }
  }

  String _customerDisplayName(AuthState state) {
    if (state is AuthAuthenticated) {
      final authenticatedFullName = state.user.fullName?.trim() ?? '';
      if (authenticatedFullName.isNotEmpty) return authenticatedFullName;
    }

    final currentSessionFullName = _currentSessionFullName();
    return currentSessionFullName.isEmpty
        ? TTexts.homeAppbarSubTitle
        : currentSessionFullName;
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      appBarModel: AppBarModel(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TTexts.homeAppbarTitle,
              style: Theme.of(
                context,
              ).textTheme.labelMedium!.apply(color: TColors.grey),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) => Text(
                _customerDisplayName(state),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall!.apply(color: TColors.white),
              ),
            ),
          ],
        ),
        actions: [
          CartCounterIcon(
            cartCounterIconModel: CartCounterIconModel(
              color: TColors.white,
              onPressed: () {
                final user = SupabaseService.instance.currentUser;
                if (user == null) {
                  THelperFunctions.navigateToScreen(context, const LoginView());
                } else {
                  THelperFunctions.navigateToScreen(
                    context,
                    const CartV2View(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
