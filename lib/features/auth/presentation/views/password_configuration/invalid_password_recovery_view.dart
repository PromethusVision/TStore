import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';

class InvalidPasswordRecoveryView extends StatelessWidget {
  const InvalidPasswordRecoveryView({super.key});

  void _openForgotPassword(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const ForgetPasswordView()),
      (_) => false,
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-invalid-password-recovery-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-invalid-password-recovery-scroll'),
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
                  const _InvalidRecoveryHeader(),
                  const SizedBox(height: EsnaftaVarSpacing.xl),
                  CustomerAuthFormCard(
                    key: const Key('customer-invalid-password-recovery-card'),
                    padding: const EdgeInsets.all(EsnaftaVarSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const EsnaftaVarStateCard(
                          key: Key('invalid-password-recovery-title'),
                          icon: Icons.link_off_rounded,
                          title: 'Bağlantı kullanılamıyor',
                          message:
                              'Bu şifre yenileme bağlantısının süresi dolmuş, daha önce '
                              'kullanılmış veya güvenli doğrulaması tamamlanamamış olabilir.',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xl),
                        ElevatedButton(
                          key: const Key('invalid-password-recovery-new-link'),
                          onPressed: () => _openForgotPassword(context),
                          child: const Text('Yeni bağlantı iste'),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xs),
                        TextButton(
                          key: const Key('invalid-password-recovery-login'),
                          onPressed: () => _openLogin(context),
                          style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Giriş ekranına dön'),
                        ),
                      ],
                    ),
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

class _InvalidRecoveryHeader extends StatelessWidget {
  const _InvalidRecoveryHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-invalid-password-recovery-header'),
      padding: const EdgeInsets.symmetric(
        horizontal: EsnaftaVarSpacing.md,
        vertical: EsnaftaVarSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.sm,
      ),
      child: const CustomerBrandWordmark(
        key: Key('invalid-password-recovery-wordmark'),
        fontSize: 28,
        textAlign: TextAlign.center,
      ),
    );
  }
}
