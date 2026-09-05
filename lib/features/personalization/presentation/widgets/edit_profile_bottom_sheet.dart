import 'package:flutter/material.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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

        return Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: CustomerAuthFormCard(
                key: const Key('edit-profile-sheet'),
                padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
                child: SafeArea(
                  top: false,
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SheetHandle(),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        _EditorHeader(onClose: isUpdating ? null : _close),
                        const SizedBox(height: EsnaftaVarSpacing.xl),
                        TextFormField(
                          key: const Key('edit-profile-full-name-field'),
                          controller: _fullNameController,
                          enabled: !isUpdating,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                          validator: _validateFullName,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        TextFormField(
                          key: const Key('edit-profile-email-field'),
                          initialValue: widget.user.email,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'E-posta',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                            helperText:
                                'E-posta adresin hesap güvenliği için sabittir.',
                            helperMaxLines: 3,
                          ),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
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
                            labelText: 'Telefon Numarası',
                            helperText: 'İsteğe bağlı',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: _validatePhone,
                        ),
                        if (state is ProfileError) ...[
                          const SizedBox(height: EsnaftaVarSpacing.md),
                          Semantics(
                            liveRegion: true,
                            child: const EsnaftaVarStateCard(
                              key: Key('edit-profile-error'),
                              icon: Icons.error_outline_rounded,
                              title: 'Kaydedilemedi',
                              message:
                                  'Bilgiler kaydedilemedi. Lütfen tekrar deneyin.',
                            ),
                          ),
                        ],
                        const SizedBox(height: EsnaftaVarSpacing.xl),
                        FilledButton.icon(
                          key: const Key('edit-profile-save-button'),
                          onPressed: isUpdating || !_hasChanges
                              ? null
                              : _submit,
                          icon: isUpdating
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    semanticsLabel: 'Kaydediliyor',
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(
                            isUpdating
                                ? 'Kaydediliyor...'
                                : 'Değişiklikleri Kaydet',
                          ),
                        ),
                      ],
                    ),
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

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: EsnaftaVarColors.borderDefault,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.pill),
        ),
      ),
    );
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({required this.onClose});
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) => Row(
    key: const Key('edit-profile-header'),
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bilgileri Düzenle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: EsnaftaVarSpacing.xxs),
            Text(
              'Sana ulaşabilmemiz için bilgilerini güncel tut.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      const SizedBox(width: EsnaftaVarSpacing.xs),
      IconButton(
        key: const Key('edit-profile-close-button'),
        tooltip: 'Kapat',
        onPressed: onClose,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );
}
