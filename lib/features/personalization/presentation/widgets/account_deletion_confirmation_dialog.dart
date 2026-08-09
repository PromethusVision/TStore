import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

typedef AccountDeletionSubmitter = Future<String?> Function();

class AccountDeletionConfirmationDialog extends StatefulWidget {
  const AccountDeletionConfirmationDialog({super.key, required this.onConfirm});

  final AccountDeletionSubmitter onConfirm;

  @override
  State<AccountDeletionConfirmationDialog> createState() =>
      _AccountDeletionConfirmationDialogState();
}

class _AccountDeletionConfirmationDialogState
    extends State<AccountDeletionConfirmationDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _isSubmitting = false;
  bool _isClosing = false;
  String? _errorMessage;

  bool get _isConfirmationValid {
    final normalized = _confirmationController.text
        .trim()
        .toUpperCase()
        .replaceAll('I', 'İ');
    return normalized == 'SİL';
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || _isClosing || !_isConfirmationValid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onConfirm();
    if (!mounted) return;

    if (errorMessage == null) {
      _isClosing = true;
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = errorMessage;
    });
  }

  void _close() {
    if (_isSubmitting || _isClosing) return;

    _isClosing = true;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSubmitting,
      child: Dialog(
        key: const Key('account-deletion-dialog'),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space16,
          vertical: CustomerHomeV1Tokens.space24,
        ),
        backgroundColor: CustomerHomeV1Tokens.cream,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DeletionHeader(isSubmitting: _isSubmitting, onClose: _close),
                const SizedBox(height: CustomerHomeV1Tokens.space16),
                const _DeletionWarningCard(),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                const _RetentionNote(),
                const SizedBox(height: CustomerHomeV1Tokens.space20),
                const Text(
                  'Devam etmek için aşağıdaki alana SİL yaz.',
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space8),
                TextField(
                  key: const Key('account-deletion-confirmation-field'),
                  controller: _confirmationController,
                  enabled: !_isSubmitting,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    hintText: 'SİL',
                    prefixIcon: const Icon(
                      Iconsax.edit_2,
                      color: CustomerHomeV1Tokens.coral,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: CustomerHomeV1Tokens.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: CustomerHomeV1Tokens.space16,
                      vertical: CustomerHomeV1Tokens.space16,
                    ),
                    border: _confirmationBorder(CustomerHomeV1Tokens.border),
                    enabledBorder: _confirmationBorder(
                      CustomerHomeV1Tokens.border,
                    ),
                    disabledBorder: _confirmationBorder(
                      CustomerHomeV1Tokens.border,
                    ),
                    focusedBorder: _confirmationBorder(
                      CustomerHomeV1Tokens.coral,
                      width: 1.4,
                    ),
                  ),
                  onChanged: (_) => setState(() {
                    _errorMessage = null;
                  }),
                  onSubmitted: (_) => _submit(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
                  _DeletionErrorCard(message: _errorMessage!),
                ],
                const SizedBox(height: CustomerHomeV1Tokens.space20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          key: const Key('account-deletion-cancel-button'),
                          onPressed: _isSubmitting ? null : _close,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: CustomerHomeV1Tokens.navy,
                            side: const BorderSide(
                              color: CustomerHomeV1Tokens.border,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CustomerHomeV1Tokens.radius16,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: const Text('Vazgeç'),
                        ),
                      ),
                    ),
                    const SizedBox(width: CustomerHomeV1Tokens.space8),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          key: const Key('account-deletion-confirm-button'),
                          onPressed: _isSubmitting || !_isConfirmationValid
                              ? null
                              : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: CustomerHomeV1Tokens.coral,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFFF4D8D1),
                            disabledForegroundColor: CustomerHomeV1Tokens.muted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                CustomerHomeV1Tokens.radius16,
                              ),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          child: _isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox.square(
                                      dimension: 17,
                                      child: CircularProgressIndicator(
                                        key: Key('account-deletion-progress'),
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: CustomerHomeV1Tokens.space8,
                                    ),
                                    Flexible(child: Text('Siliniyor...')),
                                  ],
                                )
                              : const Text('Hesabımı Sil'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _confirmationBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _DeletionHeader extends StatelessWidget {
  const _DeletionHeader({required this.isSubmitting, required this.onClose});

  final bool isSubmitting;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('account-deletion-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFE9E3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Iconsax.warning_2,
            color: CustomerHomeV1Tokens.coral,
            size: 24,
          ),
        ),
        const SizedBox(width: CustomerHomeV1Tokens.space12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesabını kalıcı olarak sil',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.25,
                ),
              ),
              SizedBox(height: CustomerHomeV1Tokens.space4),
              Text(
                'Bu karar hesabındaki tüm kişisel verileri etkiler.',
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
        const SizedBox(width: CustomerHomeV1Tokens.space4),
        Material(
          color: CustomerHomeV1Tokens.surface,
          shape: const CircleBorder(
            side: BorderSide(color: CustomerHomeV1Tokens.border),
          ),
          child: IconButton(
            key: const Key('account-deletion-close-button'),
            tooltip: 'Kapat',
            onPressed: isSubmitting ? null : onClose,
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

class _DeletionWarningCard extends StatelessWidget {
  const _DeletionWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('account-deletion-warning-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: const Color(0xFFF0C8BE)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu işlem geri alınamaz.',
            style: TextStyle(
              color: CustomerHomeV1Tokens.coral,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: CustomerHomeV1Tokens.space4),
          Text(
            'Profilin, kayıtlı konumların, favorilerin, sepetlerin ve '
            'mesajların kalıcı olarak silinir.',
            style: TextStyle(
              color: CustomerHomeV1Tokens.navy,
              fontSize: 10.5,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RetentionNote extends StatelessWidget {
  const _RetentionNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('account-deletion-retention-note'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Iconsax.info_circle,
            color: CustomerHomeV1Tokens.petrol,
            size: 18,
          ),
          SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              'Tamamlanan alışverişlerin anonim kayıtları yasal '
              'gereklilikler için saklanabilir.',
              style: TextStyle(
                color: CustomerHomeV1Tokens.navy,
                fontSize: 9.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeletionErrorCard extends StatelessWidget {
  const _DeletionErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('account-deletion-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F1),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        border: Border.all(color: const Color(0xFFF0C8BE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Iconsax.info_circle,
            color: CustomerHomeV1Tokens.coral,
            size: 19,
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
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
