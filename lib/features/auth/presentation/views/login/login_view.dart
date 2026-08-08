import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/navigation_menu.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/login_header_section.dart';

typedef CustomerLoginGuestDestinationBuilder =
    Widget Function(BuildContext context);

Widget _defaultCustomerLoginGuestDestinationBuilder(BuildContext context) {
  return const NavigationMenu();
}

class LoginView extends StatelessWidget {
  final bool isMerchantLogin;
  final bool returnToCallerAfterCustomerLogin;
  final CustomerLoginGuestDestinationBuilder guestDestinationBuilder;

  const LoginView({
    super.key,
    this.isMerchantLogin = false,
    this.returnToCallerAfterCustomerLogin = false,
    this.guestDestinationBuilder = _defaultCustomerLoginGuestDestinationBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: _LoginContent(
        isMerchantLogin: isMerchantLogin,
        returnToCallerAfterCustomerLogin: returnToCallerAfterCustomerLogin,
        guestDestinationBuilder: guestDestinationBuilder,
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.isMerchantLogin,
    required this.returnToCallerAfterCustomerLogin,
    required this.guestDestinationBuilder,
  });

  final bool isMerchantLogin;
  final bool returnToCallerAfterCustomerLogin;
  final CustomerLoginGuestDestinationBuilder guestDestinationBuilder;

  void _continueAsGuest(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(false);
      return;
    }

    THelperFunctions.navigateReplacementToScreen(
      context,
      guestDestinationBuilder(context),
    );
  }

  Future<void> _showMerchantRegistrationInfo(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          key: const Key('merchant-registration-dialog'),
          icon: const Icon(
            Icons.storefront_outlined,
            color: CustomerHomeV1Tokens.petrol,
          ),
          title: const Text('Esnafta Var İşletme'),
          content: const Text(
            'Esnaf kaydı yakında uygulama mağazalarında açılacak. '
            'Yayına alındığında bu bağlantıdan mağaza sayfasına '
            'ulaşabileceksiniz.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: CustomerHomeV1Tokens.petrol,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-login-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-login-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space24,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMerchantLogin) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        key: const Key('customer-login-continue-shopping'),
                        onPressed: () => _continueAsGuest(context),
                        style: TextButton.styleFrom(
                          foregroundColor: CustomerHomeV1Tokens.petrol,
                          minimumSize: const Size(44, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: CustomerHomeV1Tokens.space8,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        label: const Text(
                          'Keşfetmeye devam et',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                  ],
                  LoginHeaderSection(isMerchantLogin: isMerchantLogin),
                  const SizedBox(height: CustomerHomeV1Tokens.space20),
                  CustomerAuthFormCard(
                    key: const Key('customer-login-form-card'),
                    child: LoginFormSection(
                      isMerchantLogin: isMerchantLogin,
                      returnToCallerAfterCustomerLogin:
                          returnToCallerAfterCustomerLogin,
                    ),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  if (!isMerchantLogin)
                    TextButton.icon(
                      key: const Key('merchant-registration-link'),
                      onPressed: () => _showMerchantRegistrationInfo(context),
                      style: TextButton.styleFrom(
                        foregroundColor: CustomerHomeV1Tokens.petrol,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      icon: const Icon(Icons.storefront_outlined, size: 20),
                      label: const Text('Esnaf kaydı'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
