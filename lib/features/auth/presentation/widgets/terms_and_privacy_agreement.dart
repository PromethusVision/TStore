import 'package:flutter/material.dart';

import '../../../../core/utils/constants/customer_home_v1_tokens.dart';

class TermsAndPrivacyAgreement extends StatelessWidget {
  const TermsAndPrivacyAgreement({
    super.key,
    required this.privacyNoticeAcknowledged,
    required this.termsAccepted,
    required this.onPrivacyNoticeChanged,
    required this.onTermsChanged,
    required this.onOpenPrivacyNotice,
    required this.onOpenTerms,
    this.showPrivacyError = false,
    this.showTermsError = false,
  });

  final bool privacyNoticeAcknowledged;
  final bool termsAccepted;
  final ValueChanged<bool> onPrivacyNoticeChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onOpenPrivacyNotice;
  final VoidCallback onOpenTerms;
  final bool showPrivacyError;
  final bool showTermsError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LegalAgreementTile(
          key: const Key('privacy-notice-agreement'),
          value: privacyNoticeAcknowledged,
          label: 'KVKK Aydınlatma Metni’ni okudum ve bilgilendirildim.',
          linkLabel: 'Aydınlatma Metnini Görüntüle',
          linkKey: const Key('open-privacy-notice'),
          onChanged: onPrivacyNoticeChanged,
          onOpenDocument: onOpenPrivacyNotice,
          errorText: showPrivacyError
              ? 'Devam etmek için aydınlatma metnini okuduğunuzu belirtin.'
              : null,
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space12),
        _LegalAgreementTile(
          key: const Key('terms-of-use-agreement'),
          value: termsAccepted,
          label: 'Kullanım Koşulları’nı kabul ediyorum.',
          linkLabel: 'Kullanım Koşullarını Görüntüle',
          linkKey: const Key('open-terms-of-use'),
          onChanged: onTermsChanged,
          onOpenDocument: onOpenTerms,
          errorText: showTermsError
              ? 'Hesap oluşturmak için kullanım koşullarını kabul edin.'
              : null,
        ),
      ],
    );
  }
}

class _LegalAgreementTile extends StatelessWidget {
  const _LegalAgreementTile({
    super.key,
    required this.value,
    required this.label,
    required this.linkLabel,
    required this.linkKey,
    required this.onChanged,
    required this.onOpenDocument,
    required this.errorText,
  });

  final bool value;
  final String label;
  final String linkLabel;
  final Key linkKey;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenDocument;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.cream,
        border: Border.all(
          color: errorText == null
              ? CustomerHomeV1Tokens.border
              : colorScheme.error,
        ),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CustomerHomeV1Tokens.space4,
          CustomerHomeV1Tokens.space4,
          CustomerHomeV1Tokens.space16,
          CustomerHomeV1Tokens.space8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              onChanged: (nextValue) => onChanged(nextValue ?? false),
            ),
            const SizedBox(width: CustomerHomeV1Tokens.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CustomerHomeV1Tokens.navy,
                        height: 1.35,
                      ),
                    ),
                  ),
                  TextButton(
                    key: linkKey,
                    onPressed: onOpenDocument,
                    style: TextButton.styleFrom(
                      foregroundColor: CustomerHomeV1Tokens.petrol,
                      padding: const EdgeInsets.symmetric(
                        vertical: CustomerHomeV1Tokens.space4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      linkLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
