import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-invalid-password-recovery-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              key: const Key('customer-invalid-password-recovery-scroll'),
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
                  const _InvalidRecoveryHeader(),
                  const SizedBox(height: CustomerHomeV1Tokens.space24),
                  CustomerAuthFormCard(
                    key: const Key('customer-invalid-password-recovery-card'),
                    padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _InvalidLinkIllustration(),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        Text(
                          'Bağlantı kullanılamıyor',
                          key: const Key('invalid-password-recovery-title'),
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: CustomerHomeV1Tokens.navy,
                                fontWeight: FontWeight.w700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        Text(
                          'Bu şifre yenileme bağlantısının süresi dolmuş, daha önce '
                          'kullanılmış veya güvenli doğrulaması tamamlanamamış olabilir.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: CustomerHomeV1Tokens.muted,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space24),
                        ElevatedButton(
                          key: const Key('invalid-password-recovery-new-link'),
                          onPressed: () => _openForgotPassword(context),
                          child: const Text('Yeni bağlantı iste'),
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space8),
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
        horizontal: CustomerHomeV1Tokens.space16,
        vertical: CustomerHomeV1Tokens.space20,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: const CustomerBrandWordmark(
        key: Key('invalid-password-recovery-wordmark'),
        fontSize: 28,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _InvalidLinkIllustration extends StatelessWidget {
  const _InvalidLinkIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('invalid-password-recovery-icon'),
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.yellow.withValues(alpha: 0.22),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.link_off_rounded,
          color: CustomerHomeV1Tokens.coral,
          size: 40,
        ),
      ),
    );
  }
}
