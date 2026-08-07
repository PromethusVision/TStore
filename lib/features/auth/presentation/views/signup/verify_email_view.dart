import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({
    super.key,
    required this.email,
    this.resendCooldownSeconds = 60,
    this.returnToCallerAfterCustomerLogin = false,
  });

  final String email;
  final int resendCooldownSeconds;
  final bool returnToCallerAfterCustomerLogin;

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
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
    if (widget.returnToCallerAfterCustomerLogin &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthConfirmationResent) {
          _restartCooldown();
          THelperFunctions.showSnackBar(
            context: context,
            message: 'Doğrulama e-postası yeniden gönderildi.',
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
          backgroundColor: CustomerHomeV1Tokens.cream,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                key: const Key('customer-verify-email-content'),
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  key: const Key('customer-verify-email-scroll'),
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
                      _VerifyEmailHeader(onClose: _goToLogin),
                      const SizedBox(height: CustomerHomeV1Tokens.space24),
                      CustomerAuthFormCard(
                        key: const Key('customer-verify-email-card'),
                        padding: const EdgeInsets.all(
                          CustomerHomeV1Tokens.space20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _EmailIllustration(),
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space20,
                            ),
                            Text(
                              'E-posta adresinizi doğrulayın',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: CustomerHomeV1Tokens.navy,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space12,
                            ),
                            Container(
                              key: const Key('verify-email-address-card'),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: CustomerHomeV1Tokens.space16,
                                vertical: CustomerHomeV1Tokens.space12,
                              ),
                              decoration: BoxDecoration(
                                color: CustomerHomeV1Tokens.mint,
                                borderRadius: BorderRadius.circular(
                                  CustomerHomeV1Tokens.radius16,
                                ),
                                border: Border.all(
                                  color: CustomerHomeV1Tokens.petrol.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                              child: Text(
                                widget.email,
                                key: const Key('verify-email-address'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: CustomerHomeV1Tokens.petrol,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space16,
                            ),
                            Text(
                              'Gönderdiğimiz bağlantıya dokunarak hesabınızı '
                              'doğrulayın. Ardından giriş ekranına dönüp hesabınıza '
                              'giriş yapabilirsiniz.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: CustomerHomeV1Tokens.muted,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space16,
                            ),
                            const _SpamFolderHint(),
                            const SizedBox(
                              height: CustomerHomeV1Tokens.space24,
                            ),
                            ElevatedButton(
                              key: const Key('verify-email-back-to-login'),
                              onPressed: _goToLogin,
                              child: const Text('Giriş ekranına dön'),
                            ),
                            const SizedBox(height: CustomerHomeV1Tokens.space8),
                            TextButton(
                              key: const Key('verify-email-resend'),
                              onPressed: canResend
                                  ? () => context
                                        .read<AuthCubit>()
                                        .resendConfirmation(widget.email)
                                  : null,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                              ),
                              child: Text(
                                isSending
                                    ? 'Gönderiliyor...'
                                    : _remainingSeconds > 0
                                    ? '$_remainingSeconds saniye sonra yeniden gönder'
                                    : 'E-postayı yeniden gönder',
                                textAlign: TextAlign.center,
                              ),
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
      },
    );
  }
}

class _VerifyEmailHeader extends StatelessWidget {
  const _VerifyEmailHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-verify-email-header'),
      padding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space12,
        vertical: CustomerHomeV1Tokens.space8,
      ),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          const Expanded(
            child: CustomerBrandWordmark(
              key: Key('verify-email-wordmark'),
              fontSize: 28,
            ),
          ),
          IconButton(
            key: const Key('verify-email-close'),
            tooltip: 'Giriş ekranına dön',
            onPressed: onClose,
            color: CustomerHomeV1Tokens.petrol,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _EmailIllustration extends StatelessWidget {
  const _EmailIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('verify-email-icon'),
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: CustomerHomeV1Tokens.mint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mark_email_unread_outlined,
          color: CustomerHomeV1Tokens.petrol,
          size: 38,
        ),
      ),
    );
  }
}

class _SpamFolderHint extends StatelessWidget {
  const _SpamFolderHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('verify-email-spam-hint'),
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.yellow.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: CustomerHomeV1Tokens.petrol,
            size: 20,
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              'E-postayı göremiyorsanız spam veya gereksiz klasörünü kontrol edin.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: CustomerHomeV1Tokens.navy,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
