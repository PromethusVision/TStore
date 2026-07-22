import 'package:flutter/material.dart';

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
    if (_isSubmitting || !_isConfirmationValid) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final errorMessage = await widget.onConfirm();
    if (!mounted) return;

    if (errorMessage == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        key: const Key('account-deletion-dialog'),
        icon: Icon(Icons.warning_amber_rounded, color: colorScheme.error),
        title: const Text('Hesabını kalıcı olarak sil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profilin, kayıtlı konumların, favorilerin, sepetlerin ve '
                'mesajların kalıcı olarak silinecek. Bu işlem geri alınamaz.',
              ),
              const SizedBox(height: 12),
              Text(
                'Doğrulanmış alışveriş ve mağaza puanı kayıtları, kişisel '
                'bilgilerinle bağlantısı kalmadan ticari kanıt olarak '
                'korunabilir.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                key: const Key('account-deletion-confirmation-field'),
                controller: _confirmationController,
                enabled: !_isSubmitting,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Onaylamak için SİL yaz',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {
                  _errorMessage = null;
                }),
                onSubmitted: (_) => _submit(),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  key: const Key('account-deletion-error'),
                  style: TextStyle(color: colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('account-deletion-cancel-button'),
            onPressed: _isSubmitting
                ? null
                : () => Navigator.of(context).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            key: const Key('account-deletion-confirm-button'),
            onPressed: _isSubmitting || !_isConfirmationValid ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: _isSubmitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      key: const Key('account-deletion-progress'),
                      strokeWidth: 2,
                      color: colorScheme.onError,
                    ),
                  )
                : const Text('Hesabımı Sil'),
          ),
        ],
      ),
    );
  }
}
