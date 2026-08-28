# Gamification Privacy Model

Status: **PROPOSED — PRIVACY REVIEW REQUIRED**
Wave: 18 / Workstream AE

## Sensitive inferences

Purchase-derived badges/progress can reveal location, merchant, product category, health/religion/lifestyle, spending frequency or financial capacity. Public display therefore cannot be the default.

## Data classes

| Class | Examples | Default |
|---|---|---|
| Authoritative restricted evidence | Purchase/item, fraud hold, policy correction | Server/restricted only |
| Customer-private derived state | Reward balance, progress, badge evidence | Private |
| Customer-controlled public marker | Approved badge with clear meaning | Opt-in/TBD |
| Merchant-public factual state | Approved verification/badge | Public only under rule |
| Soft behavioral event | View, wishlist, directions | Minimized/aggregated/retention-limited |

## Requirements

- Do not expose exact merchant/product/purchase history through badge explanation.
- Public profile/review badge display requires separate owner/privacy decision and user control.
- No customer leaderboard, social-credit score or merchant access to individual behavior.
- Minimize event precision/retention and audit privileged access.
- Account deletion, immutable evidence and legal/security retention are handled explicitly, not broad deletion assumptions.
