import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/device/device_utility.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    super.key,
    required this.email,
    this.resendCooldownSeconds = 60,
  });

  final String email;
  final int resendCooldownSeconds;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  Timer? _cooldownTimer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.resendCooldownSeconds;
    _startTimerIfNeeded();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    _cooldownTimer?.cancel();
    if (_remainingSeconds <= 0) return;

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) timer.cancel();
      });
    });
  }

  void _restartCooldown() {
    setState(() => _remainingSeconds = widget.resendCooldownSeconds);
    _startTimerIfNeeded();
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _resend() {
    _restartCooldown();
    context.read<AuthCubit>().resetPassword(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          THelperFunctions.showSnackBar(
            context: context,
            message: 'Şifre yenileme e-postası yeniden gönderildi.',
            type: SnackBarType.success,
          );
        } else if (state is AuthError) {
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      builder: (context, state) {
        final isSending = state is AuthLoading;
        final canResend = !isSending && _remainingSeconds <= 0;

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                key: const Key('reset-email-close'),
                tooltip: 'Giriş ekranına dön',
                onPressed: _goToLogin,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: TSizes.paddingWithAppBarHeight,
              child: Column(
                children: [
                  Image(
                    width: TDeviceUtils.getScreenWidth(context) * .6,
                    image: const AssetImage(TImages.deliveredEmailIllustration),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  Text(
                    'E-postanızı kontrol edin',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    widget.email,
                    key: const Key('reset-email-address'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  Text(
                    'Bu adres sistemde kayıtlıysa şifre yenileme bağlantısı '
                    'gönderildi. Bağlantıyı açarak yeni şifrenizi '
                    'belirleyebilirsiniz.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    'E-postayı göremiyorsanız spam veya gereksiz klasörünü '
                    'kontrol edin.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      key: const Key('reset-email-back-to-login'),
                      onPressed: _goToLogin,
                      child: const Text('Giriş ekranına dön'),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      key: const Key('reset-email-resend'),
                      onPressed: canResend ? _resend : null,
                      child: Text(
                        isSending
                            ? 'Gönderiliyor...'
                            : _remainingSeconds > 0
                            ? '$_remainingSeconds saniye sonra yeniden gönder'
                            : 'E-postayı yeniden gönder',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
