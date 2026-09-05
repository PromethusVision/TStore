import 'dart:async';

import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';

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

        return EsnaftaVarScaffold(
          safeAreaTop: false,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                key: const Key('customer-reset-email-content'),
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  key: const Key('customer-reset-email-scroll'),
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
                      _ResetEmailHeader(onClose: _goToLogin),
                      const SizedBox(height: EsnaftaVarSpacing.xl),
                      CustomerAuthFormCard(
                        key: const Key('customer-reset-email-card'),
                        padding: const EdgeInsets.all(EsnaftaVarSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _ResetEmailIllustration(),
                            const SizedBox(height: EsnaftaVarSpacing.lg),
                            Text(
                              'E-postanızı kontrol edin',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: EsnaftaVarColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: EsnaftaVarSpacing.sm),
                            Container(
                              key: const Key('reset-email-address-card'),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: EsnaftaVarSpacing.md,
                                vertical: EsnaftaVarSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: EsnaftaVarColors.primarySoft,
                                borderRadius: BorderRadius.circular(
                                  EsnaftaVarRadii.large,
                                ),
                                border: Border.all(
                                  color: EsnaftaVarColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                              ),
                              child: Text(
                                widget.email,
                                key: const Key('reset-email-address'),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: EsnaftaVarColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: EsnaftaVarSpacing.md),
                            Text(
                              'Bu adres sistemde kayıtlıysa şifre yenileme bağlantısı '
                              'gönderildi. Bağlantıyı açarak yeni şifrenizi '
                              'belirleyebilirsiniz.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: EsnaftaVarColors.textSecondary,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: EsnaftaVarSpacing.md),
                            const _ResetSpamFolderHint(),
                            const SizedBox(height: EsnaftaVarSpacing.xl),
                            ElevatedButton(
                              key: const Key('reset-email-back-to-login'),
                              onPressed: _goToLogin,
                              child: const Text('Giriş ekranına dön'),
                            ),
                            const SizedBox(height: EsnaftaVarSpacing.xs),
                            TextButton(
                              key: const Key('reset-email-resend'),
                              onPressed: canResend ? _resend : null,
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

class _ResetEmailHeader extends StatelessWidget {
  const _ResetEmailHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-reset-email-header'),
      padding: const EdgeInsets.symmetric(
        horizontal: EsnaftaVarSpacing.sm,
        vertical: EsnaftaVarSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surfaceElevated,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.xLarge),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
        boxShadow: EsnaftaVarElevation.sm,
      ),
      child: Row(
        children: [
          const Expanded(
            child: CustomerBrandWordmark(
              key: Key('reset-email-wordmark'),
              fontSize: 28,
            ),
          ),
          IconButton(
            key: const Key('reset-email-close'),
            tooltip: 'Giriş ekranına dön',
            onPressed: onClose,
            color: EsnaftaVarColors.primary,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _ResetEmailIllustration extends StatelessWidget {
  const _ResetEmailIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('reset-email-icon'),
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: EsnaftaVarColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.mark_email_read_outlined,
          color: EsnaftaVarColors.primary,
          size: 38,
        ),
      ),
    );
  }
}

class _ResetSpamFolderHint extends StatelessWidget {
  const _ResetSpamFolderHint();
  @override
  Widget build(BuildContext context) {
    return const EsnaftaVarStateCard(
      key: Key('reset-email-spam-hint'),
      icon: Icons.info_outline_rounded,
      title: 'E-posta ulaşmadı mı?',
      message:
          'E-postayı göremiyorsanız spam veya gereksiz klasörünü kontrol edin.',
    );
  }
}
