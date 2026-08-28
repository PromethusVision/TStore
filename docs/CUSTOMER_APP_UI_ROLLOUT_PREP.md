# Customer App UI Rollout Preparation Audit

Status: **AUDITED — NO COSMETIC CODE CHANGED**

## Findings

- Current customer screens mix global theme values, `CustomerHomeV1Tokens`,
  direct `Colors.*`, numeric spacing/radius and feature-local styles.
- Cards, retry/empty panels, buttons, badges, dialogs, form fields and image
  fallbacks have multiple feature-specific implementations.
- Several active views are large composition files (roughly 900–1879 lines),
  increasing rollout and regression risk if redesigned in one broad commit.
- Functional semantics/tooltips and text-scale tests already provide a useful
  safety floor; the audit counted 58 semantics/tooltip declarations.

## Preparation sequence

| Layer | Candidates | Preparation needed |
|---|---|---|
| Foundations | Theme, Home tokens, typography/color/spacing/radius | Resolve one canonical token source and light/dark policy |
| Inputs/actions | Auth fields, search fields, quantity buttons, dialogs | Define focus/error/disabled/loading/destructive variants |
| Content cards | Product/category/shop/seller/review/notification/chat | Specify shared anatomy without erasing domain differences |
| State surfaces | Loading, skeleton, empty, error, retry, offline | Standardize semantics and copy ownership |
| Navigation | Bottom bar, headers, back actions, AuthGuard return | Define selected/badge/safe-area/deep-link states |
| Transaction UI | Cart conflict, QR sheet/status, review eligibility | Preserve canonical state machines while restyling |

## Rollout rule

Migrate screen groups in small branches with widget/golden/text-scale tests; do
not combine final UI rollout with taxonomy, repository or business-rule changes.
The exact file inventory is already mapped in the screen audits and feature
inventory; no final visual decision was inferred in Wave 16.
