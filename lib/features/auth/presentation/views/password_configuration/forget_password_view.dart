import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/forget_password_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/forget_password_header_section.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-forgot-password-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-forgot-password-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space8,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ForgetPasswordHeader(
                    onBack: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: CustomerHomeV1Tokens.space24),
                  const ForgetPasswordHeaderSection(),
                  const SizedBox(height: CustomerHomeV1Tokens.space20),
                  const CustomerAuthFormCard(
                    key: Key('customer-forgot-password-form-card'),
                    padding: EdgeInsets.all(CustomerHomeV1Tokens.space16),
                    child: ForgetPasswordFormSection(),
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

class _ForgetPasswordHeader extends StatelessWidget {
  const _ForgetPasswordHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-forgot-password-header'),
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space8,
        vertical: CustomerHomeV1Tokens.space12,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('customer-forgot-password-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            color: CustomerHomeV1Tokens.petrol,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          const Expanded(
            child: CustomerBrandWordmark(
              key: Key('forgot-password-wordmark'),
              fontSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
