import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/widgets/divider_widget.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/login_header_section.dart';
import 'package:t_store/features/auth/presentation/widgets/sign_in_methods_section.dart';

class LoginView extends StatelessWidget {
  final bool isMerchantLogin;

  const LoginView({
    super.key,
    this.isMerchantLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthCubit>(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: TSizes.paddingWithAppBarHeight,
              child: Column(
                children: [
                  LoginHeaderSection(isMerchantLogin: isMerchantLogin),
                  LoginFormSection(isMerchantLogin: isMerchantLogin),
                  TextButton(
                    onPressed: () {
                      THelperFunctions.navigateReplacementToScreen(
                        context,
                        LoginView(isMerchantLogin: !isMerchantLogin),
                      );
                    },
                    child: Text(
                      isMerchantLogin ? 'Normal girişe dön' : 'Esnaf Girişi',
                    ),
                  ),
                  const DividerWidget(
                    text: TTexts.orSignInWith,
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                  const SignInMethodsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
