import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/forget_password_view.dart';

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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                const Icon(Iconsax.link_21, color: Colors.orange, size: 88),
                const SizedBox(height: TSizes.spaceBtwSections),
                Text(
                  'Bağlantı kullanılamıyor',
                  key: const Key('invalid-password-recovery-title'),
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                Text(
                  'Bu şifre yenileme bağlantısının süresi dolmuş, daha önce '
                  'kullanılmış veya güvenli doğrulaması tamamlanamamış olabilir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    key: const Key('invalid-password-recovery-new-link'),
                    onPressed: () => _openForgotPassword(context),
                    child: const Text('Yeni bağlantı iste'),
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwItems),
                TextButton(
                  key: const Key('invalid-password-recovery-login'),
                  onPressed: () => _openLogin(context),
                  child: const Text('Giriş ekranına dön'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
