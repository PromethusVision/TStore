# QA Master Blueprint

**State:** PROPOSED EXECUTIVE ENTRY POINT

## Architecture

- many deterministic unit/widget/Cubit tests, focused repository/contract coverage;
- isolated RLS/RPC/migration/invariant/concurrency/idempotency evidence;
- critical app integration only where layers interact;
- exact signed physical acceptance for camera/GPS/callback/lifecycle/network;
- minimal non-destructive Production smoke;
- one evidence bundle per immutable release candidate.

## Pilot priority

Customer Auth, discovery/search/location, product/shop, cart/wishlist/address, reviews and two-device QR are MUST. Future Merchant App, ads/rewards, broad goldens/mutation/nightly and wide device fleet are DEFER unless owner enables them.

Use synthetic deterministic fixtures, never Production data mutation. A mock does not prove backend policy; a static build does not prove signing; documentation does not prove physical acceptance.

Entry points: [test inventory](QA_CURRENT_TEST_INVENTORY.md), [pyramid](QA_TEST_PYRAMID.md), [minimal pilot](QA_MINIMAL_ESENLER_PILOT.md), [failure registry](QA_FAILURE_REGISTRY.md), [first ten waves](QA_FIRST_10_WAVES.md).
