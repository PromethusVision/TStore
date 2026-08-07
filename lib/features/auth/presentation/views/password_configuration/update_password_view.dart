import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key});

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

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().updatePassword(_passwordController.text);
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordUpdated) {
          setState(() => _passwordUpdated = true);
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
        final isLoading = state is AuthLoading || _returningToLogin;

        return Scaffold(
          backgroundColor: CustomerHomeV1Tokens.cream,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                key: const Key('customer-update-password-content'),
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  key: const Key('customer-update-password-scroll'),
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
                      _UpdatePasswordHeader(
                        isLoading: isLoading,
                        onClose: _returnToLogin,
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space24),
                      CustomerAuthFormCard(
                        key: const Key('customer-update-password-card'),
                        padding: const EdgeInsets.all(
                          CustomerHomeV1Tokens.space20,
                        ),
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
          const SizedBox(height: CustomerHomeV1Tokens.space20),
          Text(
            'Yeni şifrenizi belirleyin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: CustomerHomeV1Tokens.navy,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space12),
          Text(
            'Hesabınızı korumak için daha önce kullanmadığınız güçlü bir '
            'şifre seçin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CustomerHomeV1Tokens.muted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space24),
          TextFormField(
            key: const Key('update-password-new'),
            controller: _passwordController,
            obscureText: _hidePassword,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            validator: TValidator.validatePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Iconsax.password_check),
              labelText: 'Yeni şifre',
              suffixIcon: IconButton(
                key: const Key('update-password-toggle-new'),
                onPressed: () {
                  setState(() => _hidePassword = !_hidePassword);
                },
                icon: Icon(_hidePassword ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space16),
          TextFormField(
            key: const Key('update-password-confirm'),
            controller: _confirmPasswordController,
            obscureText: _hideConfirmation,
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
              labelText: 'Yeni şifreyi tekrar girin',
              suffixIcon: IconButton(
                key: const Key('update-password-toggle-confirm'),
                onPressed: () {
                  setState(() => _hideConfirmation = !_hideConfirmation);
                },
                icon: Icon(_hideConfirmation ? Iconsax.eye_slash : Iconsax.eye),
              ),
            ),
          ),
          const SizedBox(height: CustomerHomeV1Tokens.space24),
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
        const _PasswordUpdatedIllustration(),
        const SizedBox(height: CustomerHomeV1Tokens.space20),
        Text(
          'Şifreniz yenilendi',
          key: const Key('update-password-success'),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CustomerHomeV1Tokens.navy,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space12),
        Text(
          'Yeni şifrenizle güvenli şekilde giriş yapabilirsiniz.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: CustomerHomeV1Tokens.muted,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space24),
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
              key: Key('update-password-wordmark'),
              fontSize: 28,
            ),
          ),
          IconButton(
            key: const Key('update-password-close'),
            tooltip: 'İptal et ve girişe dön',
            onPressed: isLoading ? null : onClose,
            color: CustomerHomeV1Tokens.petrol,
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
          color: CustomerHomeV1Tokens.mint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_reset_rounded,
          color: CustomerHomeV1Tokens.petrol,
          size: 40,
        ),
      ),
    );
  }
}

class _PasswordUpdatedIllustration extends StatelessWidget {
  const _PasswordUpdatedIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('update-password-success-icon'),
        width: 76,
        height: 76,
        decoration: const BoxDecoration(
          color: CustomerHomeV1Tokens.mint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: CustomerHomeV1Tokens.green,
          size: 42,
        ),
      ),
    );
  }
}
