import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/enums/status.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';
import 'package:t_store/core/utils/validators/validation.dart';
import 'package:t_store/features/auth/domain/legal/legal_document_versions.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:t_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:t_store/features/auth/presentation/views/legal/legal_document_views.dart';
import 'package:t_store/features/auth/presentation/views/login/login_view.dart';

import 'terms_and_privacy_agreement.dart';

class SignUpFormSection extends StatefulWidget {
  const SignUpFormSection({super.key});

  @override
  State<SignUpFormSection> createState() => _SignUpFormSectionState();
}

class _SignUpFormSectionState extends State<SignUpFormSection> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _privacyNoticeAcknowledged = false;
  bool _termsAccepted = false;
  bool _hasAttemptedSubmit = false;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegistration() {
    final formIsValid = _formKey.currentState?.validate() ?? false;
    setState(() => _hasAttemptedSubmit = true);

    if (formIsValid && _privacyNoticeAcknowledged && _termsAccepted) {
      context.read<AuthCubit>().signUp(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
        fullName:
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        phone: _phoneController.text.trim(),
        privacyNoticeVersion: LegalDocumentVersions.privacyNotice,
        termsOfUseVersion: LegalDocumentVersions.termsOfUse,
      );
    }
  }

  void _openPrivacyNotice() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const KvkkInformationView()));
  }

  void _openTermsOfUse() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const TermsOfUseView()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailConfirmationRequired) {
          THelperFunctions.showSnackBar(
            context: context,
            message: 'Doğrulama bağlantısı ${state.email} adresine gönderildi.',
            type: SnackBarType.success,
          );

          THelperFunctions.navigateReplacementToScreen(
            context,
            const LoginView(),
          );
        } else if (state is AuthError) {
          THelperFunctions.showSnackBar(
            context: context,
            message: state.message,
            type: SnackBarType.error,
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('signup-first-name'),
                    controller: _firstNameController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Ad alanı zorunludur.' : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: TTexts.firstName,
                    ),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    key: const Key('signup-last-name'),
                    controller: _lastNameController,
                    validator: (value) => value?.isEmpty ?? true
                        ? 'Soyad alanı zorunludur.'
                        : null,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: TTexts.lastName,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              key: const Key('signup-email'),
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              validator: (value) {
                return TValidator.validateEmail(value);
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.direct),
                labelText: TTexts.email,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              key: const Key('signup-phone'),
              keyboardType: TextInputType.phone,
              controller: _phoneController,
              validator: (value) => TValidator.validatePhoneNumber(value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.call),
                labelText: TTexts.phoneNo,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              key: const Key('signup-password'),
              keyboardType: TextInputType.visiblePassword,
              controller: _passwordController,
              validator: (value) => TValidator.validatePassword(value),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Iconsax.eye_slash : Iconsax.eye,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                labelText: TTexts.password,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              key: const Key('signup-confirm-password'),
              keyboardType: TextInputType.visiblePassword,
              controller: _confirmPasswordController,
              validator: (value) => TValidator.validateConfirmPassword(
                value,
                _passwordController,
              ),
              obscureText: _obscurePassword,
              decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                labelText: 'Şifre Tekrarı',
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TermsAndPrivacyAgreement(
              privacyNoticeAcknowledged: _privacyNoticeAcknowledged,
              termsAccepted: _termsAccepted,
              onPrivacyNoticeChanged: (value) {
                setState(() => _privacyNoticeAcknowledged = value);
              },
              onTermsChanged: (value) {
                setState(() => _termsAccepted = value);
              },
              onOpenPrivacyNotice: _openPrivacyNotice,
              onOpenTerms: _openTermsOfUse,
              showPrivacyError:
                  _hasAttemptedSubmit && !_privacyNoticeAcknowledged,
              showTermsError: _hasAttemptedSubmit && !_termsAccepted,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  return ElevatedButton(
                    key: const Key('signup-submit'),
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                            THelperFunctions.hideKeyboard();
                            _handleRegistration();
                          },
                    child: state is AuthLoading
                        ? const Text(TTexts.loading)
                        : const Text(TTexts.createAccount),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
