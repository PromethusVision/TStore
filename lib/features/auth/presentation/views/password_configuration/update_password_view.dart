import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

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
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                key: const Key('update-password-close'),
                tooltip: 'İptal et ve girişe dön',
                onPressed: isLoading ? null : _returnToLogin,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: _passwordUpdated
                  ? _buildSuccessContent(isLoading)
                  : _buildPasswordForm(isLoading),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yeni şifrenizi belirleyin',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Hesabınızı korumak için daha önce kullanmadığınız güçlü bir '
            'şifre seçin.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
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
          const SizedBox(height: TSizes.spaceBtwInputFields),
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
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('update-password-submit'),
              onPressed: isLoading ? null : _submit,
              child: Text(isLoading ? 'Kaydediliyor...' : 'Şifreyi yenile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(bool isLoading) {
    return Column(
      children: [
        const SizedBox(height: TSizes.spaceBtwSections),
        const Icon(Icons.check_circle, color: Colors.green, size: 88),
        const SizedBox(height: TSizes.spaceBtwSections),
        Text(
          'Şifreniz yenilendi',
          key: const Key('update-password-success'),
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Text(
          'Yeni şifrenizle güvenli şekilde giriş yapabilirsiniz.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.spaceBtwSections),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            key: const Key('update-password-back-to-login'),
            onPressed: isLoading ? null : _returnToLogin,
            child: Text(
              isLoading ? 'Çıkış yapılıyor...' : 'Giriş ekranına dön',
            ),
          ),
        ),
      ],
    );
  }
}
