# Merchant Pilot Cross-Document Audit

State: `PASS`

## Reconciliation checks

- Model naming is consistent: A full, B minimum safe, C assisted verifier.
- Every document labels the Model B recommendation non-final.
- MUST/SHOULD/DEFER assignments agree across contract, matrix, V1/defer and blueprint.
- Auth role is never treated as sufficient server authority.
- Single-owner UI simplification does not erase exact-shop backend scope.
- Assisted onboarding never permits password/OTP, impersonation, direct SQL, QR confirm or verified-history edit.
- Canonical product, variant, listing and candidate are not conflated.
- Price/availability/freshness remain merchant listing truth; `UNKNOWN` is distinct.
- QR preview/confirm/reconciliation, one-winner atomicity, exact shop and immutable snapshot agree everywhere.
- Product review, structured shop evaluation and merchant feed projection remain separate; no second merchant free-text review is introduced.
- Ads/rewards/reputation do not influence authority, review or QR evidence.
- Analytics never labels QR/view/direction counts as payment/revenue.
- Physical, Development and Production gates are not marked PASS.
- Future Merchant App is not claimed as implemented.
- Raw decisions 24 map exactly once into 12 roots; choice boxes are empty.
- Stress matrices reconcile to 3,200 unique `NOT_RUN` rows.

## Terminology

`shop` is the exact physical/store scope; `merchant organization` is future. `owner` is a pilot preset, not a global bypass. `verified purchase` means merchant-confirmed QR evidence, not financial receipt. `operator-assisted` means audited workflow support, not authority substitution.

## Known intentional gaps

Thresholds for listing freshness, cohort size, support hours, history depth and rollout dates remain owner/implementation decisions. Exact migration files, API names, app packaging and UI screens remain future engineering work.
