import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/features/auth/presentation/widgets/forget_password_form_section.dart';
import 'package:t_store/features/auth/presentation/widgets/forget_password_header_section.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-forgot-password-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-forgot-password-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xs,
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ForgetPasswordHeader(
                    onBack: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.xl),
                  const ForgetPasswordHeaderSection(),
                  const SizedBox(height: EsnaftaVarSpacing.lg),
                  const CustomerAuthFormCard(
                    key: Key('customer-forgot-password-form-card'),
                    padding: EdgeInsets.all(EsnaftaVarSpacing.md),
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
        horizontal: EsnaftaVarSpacing.xs,
        vertical: EsnaftaVarSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.sm,
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('customer-forgot-password-back'),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            color: EsnaftaVarColors.primary,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: EsnaftaVarSpacing.xs),
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
