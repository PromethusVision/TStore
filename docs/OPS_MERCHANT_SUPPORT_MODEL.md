# Merchant Support Model

**State:** PROPOSED FOR OWNER REVIEW

## Case families

| Family | Typical issues | Authoritative owner |
|---|---|---|
| ONBOARDING | account, organization, primary shop, sector choice | Merchant identity/onboarding service |
| SHOP_VERIFICATION | existence, address, evidence status | Verification workflow |
| CATALOG | search/link/candidate/correction/dedup conflict | Catalog review |
| PRICE/LISTING | price, availability, SKU, lifecycle, stale state | Merchant listing service with policy guard |
| QR | scanner, wrong shop, expired/replayed token, staff scope | QR service/fraud review |
| REVIEWS | reply/report, eligibility explanation | Review/moderation service |
| ADS_LATER | campaign eligibility, review, invalid traffic | Ads/policy workflow; deferred |
| STAFF/ROLES | invitation, shop scope, capability denial | Merchant authorization service |

## Support capabilities

Support can explain state, verify the caller through secure account controls, request bounded evidence, reproduce safe client behavior, link related cases, and escalate to the authoritative queue. It cannot grant owner/staff roles, bypass RLS/RPC, approve regulated status, create canonical product truth, change verified transactions, delete critical history, or promise ad/reward outcomes.

## Merchant-safe communication

Give stable reason class, affected object, current state, allowed correction/evidence, next review step, and appeal route. Do not reveal fraud thresholds, reporter identity, competitor information, internal notes, or security signals.

## Multi-shop and staff safety

Every case binds organization and shop scope. Staff authority is rechecked server-side. A caller who can describe a shop is not thereby authenticated. Ownership transfer, lost device, or staff misuse escalates to higher assurance and may temporarily restrict risk-bearing actions.

`MERCHANT_SUPPORT_BYPASS_AUTHORIZATION: NO`

`MERCHANT_SUPPORT_MODEL_FINAL: NO`
