import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/domain/entities/password_recovery_verification.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/invalid_password_recovery_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key, required this.recoveryIdentity});

  final PasswordRecoveryIdentity recoveryIdentity;

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmation = true;
  bool _passwordUpdated = false;
  bool _returningToLogin = false;
  bool _openingInvalidRecovery = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().updatePassword(
      _passwordController.text,
      recoveryIdentity: widget.recoveryIdentity,
    );
  }

  Future<void> _returnToLogin() async {
    if (_returningToLogin) return;

    setState(() => _returningToLogin = true);
    await context.read<AuthCubit>().signOut();

    if (!mounted) return;
    if (context.read<AuthCubit>().state is AuthUnauthenticated) {
      _openLogin();
    } else {
      setState(() => _returningToLogin = false);
    }
  }

  void _openLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  void _openInvalidRecovery() {
    if (_openingInvalidRecovery) return;
    _openingInvalidRecovery = true;
    _passwordController.clear();
    _confirmPasswordController.clear();
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute<void>(
        builder: (_) => const InvalidPasswordRecoveryView(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdated) {
          _passwordController.clear();
          _confirmPasswordController.clear();
          setState(() => _passwordUpdated = true);
        } else if (state is AuthPasswordRecoveryFailed) {
          if (state.failure.reason !=
              PasswordRecoveryFailureReason.passwordUpdateRejected) {
            _openInvalidRecovery();
            return;
          }
          setState(() => _returningToLogin = false);
          THelperFunctions.showSnackBar(
            context: context,
            message: state.failure.message,
            type: SnackBarType.error,
          );
        } else if (state is AuthError) {
          setState(() => _returningToLogin = false);
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        } else if (state is AuthUnauthenticated && _returningToLogin) {
          _openLogin();
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading ||
            state is AuthPasswordRecoveryVerifying ||
            _returningToLogin;

        return EsnaftaVarScaffold(
          safeAreaTop: false,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                key: const Key('customer-update-password-content'),
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  key: const Key('customer-update-password-scroll'),
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
                      _UpdatePasswordHeader(
                        isLoading: isLoading,
                        onClose: _returnToLogin,
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.xl),
                      CustomerAuthFormCard(
                        key: const Key('customer-update-password-card'),
                        padding: const EdgeInsets.all(EsnaftaVarSpacing.lg),
                        child: _passwordUpdated
                            ? _buildSuccessContent(isLoading)
                            : _buildPasswordForm(isLoading),
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

  Widget _buildPasswordForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _UpdatePasswordIllustration(),
          const SizedBox(height: EsnaftaVarSpacing.lg),
          Text(
            'Yeni şifrenizi belirleyin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: EsnaftaVarColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EsnaftaVarSpacing.sm),
          Text(
            'Hesabınızı korumak için daha önce kullanmadığınız güçlü bir '
            'şifre seçin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EsnaftaVarColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EsnaftaVarSpacing.xl),
          TextFormField(
            key: const Key('update-password-new'),
            controller: _passwordController,
            readOnly: isLoading,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _hidePassword,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            validator: TValidator.validatePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.password_check),
              labelText: 'Yeni şifre',
              suffixIcon: IconButton(
                key: const Key('update-password-toggle-new'),
                tooltip: _hidePassword ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(_hidePassword ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.md),
          TextFormField(
            key: const Key('update-password-confirm'),
            controller: _confirmPasswordController,
            readOnly: isLoading,
            keyboardType: TextInputType.visiblePassword,
            obscureText: _hideConfirmation,
            autocorrect: false,
            enableSuggestions: false,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: isLoading ? null : (_) => _submit(),
            validator: (value) {
              final passwordError = TValidator.validatePassword(value);
              if (passwordError != null) return passwordError;
              return TValidator.validateConfirmPassword(
                value,
                _passwordController,
              );
            },
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.password_check),
              labelText: 'Şifre tekrarı',
              suffixIcon: IconButton(
                key: const Key('update-password-toggle-confirm'),
                tooltip: _hideConfirmation
                    ? 'Şifre tekrarını göster'
                    : 'Şifre tekrarını gizle',
                onPressed: () {
                  setState(() => _hideConfirmation = !_hideConfirmation);
                },
                icon: Icon(_hideConfirmation ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xl),
          ElevatedButton(
            key: const Key('update-password-submit'),
            onPressed: isLoading ? null : _submit,
            child: Text(isLoading ? 'Kaydediliyor...' : 'Şifreyi yenile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: const EsnaftaVarStateCard(
            key: Key('update-password-success'),
            icon: Icons.check_circle_outline_rounded,
            title: 'Şifreniz yenilendi',
            message: 'Yeni şifrenizle güvenli şekilde giriş yapabilirsiniz.',
          ),
        ),
        const SizedBox(height: EsnaftaVarSpacing.xl),
        ElevatedButton(
          key: const Key('update-password-back-to-login'),
          onPressed: isLoading ? null : _returnToLogin,
          child: Text(isLoading ? 'Çıkış yapılıyor...' : 'Giriş ekranına dön'),
        ),
      ],
    );
  }
}

class _UpdatePasswordHeader extends StatelessWidget {
  const _UpdatePasswordHeader({required this.isLoading, required this.onClose});

  final bool isLoading;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-update-password-header'),
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
              key: Key('update-password-wordmark'),
              fontSize: 28,
            ),
          ),
          IconButton(
            key: const Key('update-password-close'),
            tooltip: 'İptal et ve girişe dön',
            onPressed: isLoading ? null : onClose,
            color: EsnaftaVarColors.primary,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _UpdatePasswordIllustration extends StatelessWidget {
  const _UpdatePasswordIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('update-password-icon'),
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: EsnaftaVarColors.primarySoft,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          color: EsnaftaVarColors.primary,
          size: 40,
        ),
      ),
    );
  }
}
