import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/widgets/login_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/login_header_section.dart';

class LoginView extends StatelessWidget {
  final bool isMerchantLogin;
  final bool returnToCallerAfterCustomerLogin;

  const LoginView({
    super.key,
    this.isMerchantLogin = false,
    this.returnToCallerAfterCustomerLogin = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: _LoginContent(
        isMerchantLogin: isMerchantLogin,
        returnToCallerAfterCustomerLogin: returnToCallerAfterCustomerLogin,
      ),
    );
  }
}

class _LoginContent extends StatelessWidget {
  const _LoginContent({
    required this.isMerchantLogin,
    required this.returnToCallerAfterCustomerLogin,
  });

  final bool isMerchantLogin;
  final bool returnToCallerAfterCustomerLogin;

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
                  LoginHeaderSection(isMerchantLogin: isMerchantLogin),
                  const SizedBox(height: CustomerHomeV1Tokens.space20),
                  _LoginFormCard(
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

class _LoginFormCard extends StatelessWidget {
  const _LoginFormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      borderSide: const BorderSide(color: CustomerHomeV1Tokens.border),
    );

    return Container(
      key: const Key('customer-login-form-card'),
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space16,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: CustomerHomeV1Tokens.cream,
            prefixIconColor: CustomerHomeV1Tokens.petrol,
            suffixIconColor: CustomerHomeV1Tokens.petrol,
            labelStyle: const TextStyle(color: CustomerHomeV1Tokens.muted),
            floatingLabelStyle: const TextStyle(
              color: CustomerHomeV1Tokens.petrol,
              fontWeight: FontWeight.w600,
            ),
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius16,
              ),
              borderSide: const BorderSide(
                color: CustomerHomeV1Tokens.petrol,
                width: 1.5,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.petrol,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CustomerHomeV1Tokens.mint,
              disabledForegroundColor: CustomerHomeV1Tokens.muted,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomerHomeV1Tokens.petrol,
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: CustomerHomeV1Tokens.petrol,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.space4),
            ),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return CustomerHomeV1Tokens.petrol;
              }
              return Colors.transparent;
            }),
          ),
        ),
        child: child,
      ),
    );
  }
}
