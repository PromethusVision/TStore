import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/auth/domain/entities/user_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/profile_state.dart';

class EditProfileBottomSheet extends StatefulWidget {
  const EditProfileBottomSheet({super.key, required this.user});

  final UserEntity user;

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final String _initialFullName;
  late final String _initialPhone;

  @override
  void initState() {
    super.initState();
    _initialFullName = widget.user.fullName?.trim() ?? '';
    _initialPhone = widget.user.phone?.trim() ?? '';
    _fullNameController = TextEditingController(text: _initialFullName)
      ..addListener(_onFieldChanged);
    _phoneController = TextEditingController(text: _initialPhone)
      ..addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _fullNameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _phoneController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _hasChanges =>
      _fullNameController.text.trim() != _initialFullName ||
      _phoneController.text.trim() != _initialPhone;

  void _submit() {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    context.read<ProfileCubit>().updateProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  String? _validateFullName(String? value) {
    final fullName = value?.trim() ?? '';
    if (fullName.isEmpty) return 'Ad soyad boş bırakılamaz';
    if (fullName.length < 2) return 'Ad soyad en az 2 karakter olmalı';
    if (fullName.length > 80) return 'Ad soyad en fazla 80 karakter olabilir';
    return null;
  }

  String? _validatePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;

    if (!RegExp(r'^[0-9+()\s-]+$').hasMatch(phone)) {
      return 'Geçerli bir telefon numarası girin';
    }

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final isLocal = digits.length == 10 && digits.startsWith('5');
    final isLocalWithZero = digits.length == 11 && digits.startsWith('05');
    final isInternational = digits.length == 12 && digits.startsWith('905');

    if (!isLocal && !isLocalWithZero && !isInternational) {
      return 'Telefonu 05xx xxx xx xx biçiminde girin';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          Navigator.of(context).pop(state.user);
        }
      },
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating;

        return Padding(
          padding: EdgeInsets.only(
            left: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
            bottom:
                MediaQuery.viewInsetsOf(context).bottom + TSizes.defaultSpace,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bilgileri Düzenle',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  TextFormField(
                    key: const Key('edit-profile-full-name-field'),
                    controller: _fullNameController,
                    enabled: !isUpdating,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.user),
                      labelText: 'Ad Soyad',
                    ),
                    validator: _validateFullName,
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    key: const Key('edit-profile-email-field'),
                    initialValue: widget.user.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.direct),
                      labelText: 'E-posta',
                      helperText: 'E-posta bu ekrandan değiştirilemez',
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    key: const Key('edit-profile-phone-field'),
                    controller: _phoneController,
                    enabled: !isUpdating,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!isUpdating && _hasChanges) _submit();
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Iconsax.call),
                      labelText: 'Telefon Numarası',
                      helperText: 'İsteğe bağlı',
                    ),
                    validator: _validatePhone,
                  ),
                  if (state is ProfileError) ...[
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      'Bilgiler kaydedilemedi. Lütfen tekrar deneyin.',
                      key: const Key('edit-profile-error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('edit-profile-save-button'),
                      onPressed: isUpdating || !_hasChanges ? null : _submit,
                      child: isUpdating
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Kaydet'),
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
