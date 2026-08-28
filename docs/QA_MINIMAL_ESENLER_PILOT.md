# Minimal Esenler Pilot QA

**State:** PROPOSED — NOT EXECUTED

## AUTOMATED_MUST_PASS

- format/diff/analyzer and full existing Flutter regression;
- Auth/profile/user-switch, discovery/search/location-state, product/shop, wishlist/cart/address;
- verified review eligibility and one-active invariant;
- QR RPC/RLS, replay/wrong-shop/expiry/concurrency/idempotency and price snapshot;
- canonical migration manifest, pre/dry/post/invariants and supported-client contracts;
- secret/security/privacy/static release identity checks;
- clean deterministic fixtures and no skipped critical gate.

## PHYSICAL_MUST_PASS

- exact signed Android clean and upgrade install;
- customer + merchant two-device QR;
- real GPS/location permissions, camera, background/resume and network switching;
- real confirmation/recovery email and cold/warm callback;
- representative small/large text/accessibility and Turkish visual check.

## PRODUCTION_MANUAL

- exact environment/artifact/signing verification;
- authorized migration/change record if needed;
- minimal non-destructive smoke, staged rollout, monitoring/support and pause path.

## OWNER_DECISION

Pilot platform, cohort/merchant operation, support/legal readiness, authorities, device access, rollout and accepted P2 risk.

## DEFERABLE

Full Merchant App, ads/rewards, broad goldens/mutation/fuzz, nightly/sharding, wide device lab, comprehensive observability and iOS if Android-only is selected.
