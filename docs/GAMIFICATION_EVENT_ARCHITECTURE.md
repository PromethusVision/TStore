# Gamification Event Architecture

Status: **PROPOSED CONCEPT — NO EVENT BUS/SCHEMA**
Wave: 18 / Workstream AN

## Authoritative events

| Event | Source | Candidate use |
|---|---|---|
| verified_purchase_created/corrected | QR/verified purchase backend | Reward/badge/reputation evaluator |
| review_created/updated/deleted | Canonical review RPC | Contribution badge/rating projection |
| merchant_verification_changed | Merchant policy system | Factual reputation badge |
| listing_accuracy_confirmed/corrected | Governed catalog process | Reputation candidate |
| shop_lifecycle_changed | Shop authority | Badge/reward program eligibility |
| account_merged/deleted | Account authority | Identity/history correction |

## Soft events

`shop_discovered`, `directions_requested`, `wishlist_changed`, views and notification opens. These may support privacy-safe analytics or low-stakes progress only; they are not purchase, quality or loyalty proof.

## Envelope

Event ID/type/version/source, subject and stable entity IDs, server timestamp, integrity/policy state, privacy class, predecessor/correction and safe metadata. Ads attribution remains a reference, not event authority.
