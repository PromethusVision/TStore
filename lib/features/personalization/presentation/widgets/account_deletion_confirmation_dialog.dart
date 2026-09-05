import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

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
    return Theme(
      data: EsnaftaVarTheme.light,
      child: PopScope(
        canPop: !_isSubmitting,
        child: Dialog(
          key: const Key('account-deletion-dialog'),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: EsnaftaVarSpacing.md,
            vertical: EsnaftaVarSpacing.xl,
          ),
          backgroundColor: EsnaftaVarColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.xxLarge),
          ),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(EsnaftaVarSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DeletionHeader(
                          isSubmitting: _isSubmitting,
                          onClose: _close,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        const _DeletionWarningCard(),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        const _RetentionNote(),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const Text(
                          'Devam etmek için aşağıdaki alana SİL yaz.',
                          style: TextStyle(
                            color: EsnaftaVarColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xs),
                        TextField(
                          key: const Key('account-deletion-confirmation-field'),
                          controller: _confirmationController,
                          enabled: !_isSubmitting,
                          autofocus: true,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            color: EsnaftaVarColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                          ),
                          decoration: InputDecoration(
                            hintText: 'SİL',
                            prefixIcon: const Icon(
                              Icons.edit_outlined,
                              color: EsnaftaVarColors.accent,
                              size: 20,
                            ),
                            filled: true,
                            fillColor: EsnaftaVarColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: EsnaftaVarSpacing.md,
                              vertical: EsnaftaVarSpacing.md,
                            ),
                            border: _confirmationBorder(
                              EsnaftaVarColors.borderDefault,
                            ),
                            enabledBorder: _confirmationBorder(
                              EsnaftaVarColors.borderDefault,
                            ),
                            disabledBorder: _confirmationBorder(
                              EsnaftaVarColors.borderDefault,
                            ),
                            focusedBorder: _confirmationBorder(
                              EsnaftaVarColors.accent,
                              width: 1.4,
                            ),
                          ),
                          onChanged: (_) => setState(() {
                            _errorMessage = null;
                          }),
                          onSubmitted: (_) => _submit(),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: EsnaftaVarSpacing.sm),
                          _DeletionErrorCard(message: _errorMessage!),
                        ],
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton(
                        key: const Key('account-deletion-cancel-button'),
                        onPressed: _isSubmitting ? null : _close,
                        child: const Text('Vazgeç'),
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.xs),
                      FilledButton(
                        key: const Key('account-deletion-confirm-button'),
                        onPressed: _isSubmitting || !_isConfirmationValid
                            ? null
                            : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: EsnaftaVarColors.error,
                        ),
                        child: _isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      key: Key('account-deletion-progress'),
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: EsnaftaVarSpacing.xs),
                                  Flexible(child: Text('Siliniyor...')),
                                ],
                              )
                            : const Text('Hesabımı Sil'),
                      ),
                    ],
                  ),
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
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
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
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hesabını kalıcı olarak sil',
                style: TextStyle(
                  color: EsnaftaVarColors.textPrimary,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                ),
              ),
              SizedBox(height: EsnaftaVarSpacing.xxs),
              Text(
                'Bu karar hesabındaki tüm kişisel verileri etkiler.',
                style: TextStyle(
                  color: EsnaftaVarColors.textSecondary,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: EsnaftaVarSpacing.xxs),
        Material(
          color: EsnaftaVarColors.surface,
          shape: const CircleBorder(
            side: BorderSide(color: EsnaftaVarColors.borderDefault),
          ),
          child: IconButton(
            key: const Key('account-deletion-close-button'),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            tooltip: 'Kapat',
            onPressed: isSubmitting ? null : onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: EsnaftaVarColors.textPrimary,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.errorSoft,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bu işlem geri alınamaz.',
            style: TextStyle(
              color: EsnaftaVarColors.accent,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: EsnaftaVarSpacing.xxs),
          Text(
            'Profilin, kayıtlı konumların, favorilerin, sepetlerin ve '
            'mesajların kalıcı olarak silinir.',
            style: TextStyle(
              color: EsnaftaVarColors.textPrimary,
              fontSize: 12,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: EsnaftaVarColors.primary,
            size: 18,
          ),
          SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Text(
              'Tamamlanan alışverişlerin anonim kayıtları yasal '
              'gereklilikler için saklanabilir.',
              style: TextStyle(
                color: EsnaftaVarColors.textPrimary,
                fontSize: 12,
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
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: EsnaftaVarStateCard(
      key: const Key('account-deletion-error'),
      icon: Icons.error_outline_rounded,
      title: 'Hesap silinemedi',
      message: message,
    ),
  );
}
