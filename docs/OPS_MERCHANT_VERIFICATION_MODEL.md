# Merchant Verification Model

**State:** PROPOSED — NOT LEGAL ADVICE OR IMPLEMENTATION

## Separate assertions

| Assertion | Question | Evidence examples |
|---|---|---|
| MERCHANT_IDENTITY | Who controls the merchant account/entity? | secure account/business identity evidence |
| SHOP_EXISTENCE | Does this physical shop exist at the claimed place? | address/premises/public registry/controlled verification |
| SHOP_CONTROL | May this merchant manage this shop? | ownership/authorization evidence |
| SECTOR_DECLARATION | What recognizable business activities are claimed? | primary/secondary sector declaration |
| SECTOR_EVIDENCE | Does a sensitive sector require extra proof? | activity/registration/authorization evidence |
| PRODUCT_ELIGIBILITY | May an exact product/listing be offered? | separate catalog/policy evidence |

One assertion never silently proves another. Merchant sector selection does not grant Auth role, shop control, licence, product permission, badge, QR, ads, or reputation.

## Ordinary versus regulated posture

- `ORDINARY_REVIEW`: identity/shop/control checks plus ordinary business evidence.
- `VERIFICATION_MAY_BE_REQUIRED`: sector/activity-specific evidence and expiry rules.
- `LEGAL_REVIEW_REQUIRED`: fail closed until owner/policy defines exact allow scope.
- `EXCLUDED/UNSUPPORTED`: no activation under current rules.

## Decision envelope

Merchant/shop/sector stable IDs, evidence references, scope, reviewer, policy version, status, effective/expiry time, limitations, reason, and appeal. Public badge wording must describe only the verified assertion.

## Safety

Documents are redacted/minimized, access-controlled, and not copied into notes. Verification can expire or be revoked. The operator cannot invent legal scope, self-approve a beneficial merchant, or use verification to override product/listing policy.

Current merchant taxonomy remains mostly proposal-only: 31 ordinary, 26 verification-signalled, and 10 legal-review-signalled assignable leaves. These are review signals, not final rules.

`VERIFICATION_MODEL_FINAL: NO`

`SECTOR_EQUALS_PERMISSION: NO`
