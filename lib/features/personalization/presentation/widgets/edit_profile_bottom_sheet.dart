import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/utils/constants/iconsax_compat.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
  bool _isSubmitPending = false;
  bool _isClosing = false;

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
    if (_isSubmitPending ||
        context.read<ProfileCubit>().state is ProfileUpdating) {
      return;
    }
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() => _isSubmitPending = true);
    context.read<ProfileCubit>().updateProfile(
      fullName: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  void _close() {
    if (_isClosing ||
        _isSubmitPending ||
        context.read<ProfileCubit>().state is ProfileUpdating) {
      return;
    }

    _isClosing = true;
    Navigator.of(context).pop();
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
          _isClosing = true;
          Navigator.of(context).pop(state.user);
          return;
        }
        if (state is ProfileError && _isSubmitPending) {
          setState(() => _isSubmitPending = false);
        }
      },
      builder: (context, state) {
        final isUpdating = state is ProfileUpdating || _isSubmitPending;

        return ColoredBox(
          key: const Key('edit-profile-sheet'),
          color: CustomerHomeV1Tokens.cream,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  CustomerHomeV1Tokens.space16,
                  CustomerHomeV1Tokens.space12,
                  CustomerHomeV1Tokens.space16,
                  MediaQuery.viewInsetsOf(context).bottom +
                      CustomerHomeV1Tokens.space24,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SheetHandle(),
                      const SizedBox(height: CustomerHomeV1Tokens.space12),
                      _EditorHeader(onClose: isUpdating ? null : _close),
                      const SizedBox(height: CustomerHomeV1Tokens.space20),
                      TextFormField(
                        key: const Key('edit-profile-full-name-field'),
                        controller: _fullNameController,
                        enabled: !isUpdating,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        style: _fieldTextStyle,
                        decoration: _fieldDecoration(
                          icon: Iconsax.user,
                          label: 'Ad Soyad',
                        ),
                        validator: _validateFullName,
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space12),
                      TextFormField(
                        key: const Key('edit-profile-email-field'),
                        initialValue: widget.user.email,
                        enabled: false,
                        style: _fieldTextStyle,
                        decoration: _fieldDecoration(
                          icon: Iconsax.direct,
                          label: 'E-posta',
                          helperText:
                              'E-posta adresin hesap güvenliği için sabittir.',
                          disabled: true,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space12),
                      TextFormField(
                        key: const Key('edit-profile-phone-field'),
                        controller: _phoneController,
                        enabled: !isUpdating,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        style: _fieldTextStyle,
                        onFieldSubmitted: (_) {
                          if (!isUpdating && _hasChanges) _submit();
                        },
                        decoration: _fieldDecoration(
                          icon: Iconsax.call,
                          label: 'Telefon Numarası',
                          helperText: 'İsteğe bağlı',
                        ),
                        validator: _validatePhone,
                      ),
                      if (state is ProfileError) ...[
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        const _UpdateErrorCard(),
                      ],
                      const SizedBox(height: CustomerHomeV1Tokens.space20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          key: const Key('edit-profile-save-button'),
                          onPressed: isUpdating || !_hasChanges
                              ? null
                              : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: CustomerHomeV1Tokens.petrol,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: CustomerHomeV1Tokens.mint,
                            disabledForegroundColor: CustomerHomeV1Tokens.muted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CustomerHomeV1Tokens.radius16,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          icon: isUpdating
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Iconsax.tick_circle, size: 19),
                          label: Text(
                            isUpdating
                                ? 'Kaydediliyor...'
                                : 'Değişiklikleri Kaydet',
                          ),
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

  TextStyle get _fieldTextStyle => const TextStyle(
    color: CustomerHomeV1Tokens.navy,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  InputDecoration _fieldDecoration({
    required IconData icon,
    required String label,
    String? helperText,
    bool disabled = false,
  }) {
    final fillColor = disabled
        ? CustomerHomeV1Tokens.mint.withValues(alpha: 0.55)
        : CustomerHomeV1Tokens.surface;

    return InputDecoration(
      labelText: label,
      helperText: helperText,
      helperMaxLines: 2,
      prefixIcon: Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 20),
      filled: true,
      fillColor: fillColor,
      labelStyle: const TextStyle(
        color: CustomerHomeV1Tokens.muted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      helperStyle: const TextStyle(
        color: CustomerHomeV1Tokens.muted,
        fontSize: 9.5,
        height: 1.25,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: CustomerHomeV1Tokens.space16,
        vertical: CustomerHomeV1Tokens.space16,
      ),
      border: _fieldBorder(CustomerHomeV1Tokens.border),
      enabledBorder: _fieldBorder(CustomerHomeV1Tokens.border),
      disabledBorder: _fieldBorder(CustomerHomeV1Tokens.border),
      focusedBorder: _fieldBorder(CustomerHomeV1Tokens.petrol, width: 1.4),
      errorBorder: _fieldBorder(CustomerHomeV1Tokens.coral),
      focusedErrorBorder: _fieldBorder(CustomerHomeV1Tokens.coral, width: 1.4),
      errorStyle: const TextStyle(
        color: CustomerHomeV1Tokens.coral,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.border,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radiusPill),
        ),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('edit-profile-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.mint,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
          ),
          child: const Icon(
            Iconsax.edit_2,
            color: CustomerHomeV1Tokens.petrol,
            size: 21,
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bilgileri Düzenle',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                'Sana ulaşabilmemiz için bilgilerini güncel tut.',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 10.5,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space8),
        Material(
          color: CustomerHomeV1Tokens.surface,
          shape: const CircleBorder(
            side: BorderSide(color: CustomerHomeV1Tokens.border),
          ),
          child: IconButton(
            key: const Key('edit-profile-close-button'),
            tooltip: 'Kapat',
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: CustomerHomeV1Tokens.navy,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _UpdateErrorCard extends StatelessWidget {
  const _UpdateErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('edit-profile-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        border: Border.all(color: const Color(0xFFF0C8BE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.info_circle,
            color: CustomerHomeV1Tokens.coral,
            size: 19,
          ),
          SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              'Bilgiler kaydedilemedi. Lütfen tekrar deneyin.',
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
