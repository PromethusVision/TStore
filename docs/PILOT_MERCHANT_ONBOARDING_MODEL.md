# EsnaftaVar Esenler Pilot — Merchant Onboarding Model

**State:** `PROPOSED OPERATING MODEL — NO MERCHANT ONBOARDED`

## Two safe lanes

### Lane S — self-onboarding

1. explain pilot scope and non-promises;
2. establish authenticated operator identity;
3. select the physical shop and prove relationship/authority;
4. choose a proposed merchant sector without treating it as product permission;
5. collect minimum shop facts and policy declarations;
6. search canonical products first;
7. create bounded shop listings with price, availability and timestamp;
8. submit unmatched products as candidates, never auto-publish;
9. complete verifier/QR training if enabled;
10. pass launch-readiness review.

### Lane A — assisted onboarding

A trained operator screen-shares or works alongside the merchant, records source
evidence, performs the same gates and leaves the merchant with a clear maintenance
task. Assistance cannot use shared credentials, edit authoritative data outside
the merchant's permission, or silently certify unknown facts.

## When assistance is appropriate

- first merchants in a launch cell;
- repeated product matching/candidate difficulty;
- accessibility or device-literacy need;
- bulk initial truth capture within the approved listing cap;
- verifier education requiring observation.

## When assistance must stop

- merchant identity/shop authority is unresolved;
- the requested sector/product is outside the allowlist;
- merchant will not attest or maintain listing truth;
- credentials or verification evidence would be shared insecurely;
- queue load would make already-live data stale.

## Minimal completion definition

A merchant is `LAUNCH_READY` only when identity/shop authority, allowlist,
operating device, customer-visible shop facts, minimum useful catalog, listing
freshness, QR acceptance (if enabled), support channel and pause/exit acknowledgement
all pass. `SIGNED_UP`, `VERIFIED` and `CATALOG_READY` remain distinct states.

## Lean burden controls

- cap listings per assisted session;
- prioritize reusable canonical products;
- publish no unresolved candidate;
- use checklists and exception codes instead of prose-only notes;
- sample accepted listings for truth;
- schedule a near-term first refresh;
- graduate repeatable tasks to self-service only after observed success.

`SELF_ONBOARDING_ONLY: NOT_RECOMMENDED`

`ASSISTED_PATH_BYPASSES_AUTHORITY: NO`
