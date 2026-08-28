# Operator PII Access Matrix

**State:** PROPOSED — PRIVACY/LEGAL REVIEW REQUIRED

Legend: `M` minimized derived view; `E` elevated purpose/case access; `—` unavailable.

| Data | Support | Moderator | Verification | Catalog | Policy | Security/Privacy |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| Opaque account/merchant/shop ID | M | M | M | M | M | M |
| Email/phone masked | M | — | M | — | — | M |
| Full contact | E | — | E | — | — | E |
| Shop public address/contact | M | M | M | M | M | M |
| Precise saved/customer location | — | — | — | — | — | E |
| Identity/regulated documents | — | — | E | — | E | E |
| Review/listing public content | M | M | M | M | M | M |
| Private chat/support text | E exact case | — | — | — | — | E |
| QR transaction summary | M | M | M | — | M | M |
| Raw QR/token/password/OTP | — | — | — | — | — | — |
| Device/IP/security signals | — | — | — | — | — | E |
| Reporter identity | E when essential | — | — | — | — | E |
| Audit/export | limited case | limited case | limited case | limited case | E | E |

## Controls

Purpose/case binding, field redaction, just-in-time reveal, explicit reason, fresh re-auth for E, access audit, export caps/watermark/expiry, retention, no local download by default, and periodic review.

Public shop information remains personal/commercial data in operational context and is not automatically unrestricted. Aggregate views need cohort/re-identification controls.

`PII_MATRIX_FINAL: NO`

`FULL_RECORD_DEFAULT: NO`
