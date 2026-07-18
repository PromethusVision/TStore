import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/password_configuration/reset_password_view.dart';

class ForgetPasswordFormSection extends StatefulWidget {
  const ForgetPasswordFormSection({super.key});

  @override
  State<ForgetPasswordFormSection> createState() =>
      _ForgetPasswordFormSectionState();
}

class _ForgetPasswordFormSectionState extends State<ForgetPasswordFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().resetPassword(
      _emailController.text.trim().toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => ResetPasswordView(email: state.email),
            ),
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
        final isLoading = state is AuthLoading;

        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                key: const Key('forgot-password-email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: isLoading ? null : (_) => _submit(),
                validator: (value) => TValidator.validateEmail(value?.trim()),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Iconsax.direct_right),
                  labelText: TTexts.email,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: const Key('forgot-password-submit'),
                  onPressed: isLoading ? null : _submit,
                  child: Text(
                    isLoading ? 'Gönderiliyor...' : 'Bağlantıyı gönder',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
