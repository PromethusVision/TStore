import 'package:flutter/material.dart';
import '../domain/merchant_account_recovery.dart';
import 'merchant_widgets.dart';

class MerchantAccountRecoveryView extends StatefulWidget {
  const MerchantAccountRecoveryView({super.key, required this.recovery});
  final MerchantAccountRecovery recovery;
  @override
  State<MerchantAccountRecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends State<MerchantAccountRecoveryView> {
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _repeat = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _obscure = true;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recovery = widget.recovery;
    final stage = recovery.stage;
    final password = stage == MerchantRecoveryStage.password;
    final request = stage == MerchantRecoveryStage.request;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && recovery.canDismiss) recovery.dismiss();
      },
      child: MerchantPage(
        title: 'Şifre yenileme',
        children: [
          const Icon(Icons.lock_reset_outlined, size: 48),
          if (recovery.busy) ...[
            const Center(child: CircularProgressIndicator()),
            const Text('İşlemin sonucu bekleniyor…'),
          ],
          if (recovery.message != null)
            MerchantNotice(
              recovery.message!,
              error: [
                MerchantRecoveryStage.invalid,
                MerchantRecoveryStage.cleanupFailed,
              ].contains(stage),
            ),
          if (request || password)
            Form(
              key: _form,
              child: Column(
                children: [
                  if (request)
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'E-posta'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (value) =>
                          RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch((value ?? '').trim())
                          ? null
                          : 'Geçerli e-posta girin.',
                    ),
                  if (password) ...[
                    const Text(
                      'Yeni şifrenizi belirleyin. Ardından yeniden giriş yapacaksınız.',
                    ),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      enableSuggestions: false,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.newPassword],
                      decoration: InputDecoration(
                        labelText: 'Yeni şifre',
                        suffixIcon: IconButton(
                          tooltip: _obscure
                              ? 'Şifreyi göster'
                              : 'Şifreyi gizle',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) => (v ?? '').length < 8
                          ? 'En az 8 karakter kullanın.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _repeat,
                      obscureText: _obscure,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'Yeni şifre tekrar',
                      ),
                      validator: (v) =>
                          v != _password.text ? 'Şifreler eşleşmiyor.' : null,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      if (!merchantValidateForm(_form)) return;
                      if (request) {
                        recovery.send(_email.text);
                      } else {
                        final value = _password.text;
                        _password.clear();
                        _repeat.clear();
                        recovery.update(value);
                      }
                    },
                    child: Text(request ? 'Bağlantı gönder' : 'Şifreyi yenile'),
                  ),
                ],
              ),
            ),
          if (recovery.canDismiss)
            TextButton(
              onPressed: recovery.dismiss,
              child: Text(
                stage == MerchantRecoveryStage.cleanupFailed
                    ? 'Yeniden dene'
                    : 'Girişe dön',
              ),
            ),
        ],
      ),
    );
  }
}
