# Backend Merchant App Contract

**State:** PROPOSED — NO MERCHANT APP/BACKEND IMPLEMENTATION

Merchant operations require an authenticated user, active organization membership,
explicit exact-shop scope, capability, resource lifecycle/policy and expected
revision. UI role or hidden navigation is not authority.

## Minimum server surfaces

- resolve current membership/shop/capabilities and safe suspension status;
- read/update allowed shop profile fields;
- list/create/revise/retire exact-shop listings and submit catalog candidates;
- verify/confirm QR atomically with idempotency and wrong-shop/replay protection;
- read exact-shop verified-purchase history and action-required summaries;
- participant/assignment-scoped customer chat and notifications;
- bounded dashboard metrics with authority/freshness definitions;
- invite/revoke staff only if V1 includes multi-staff.

Merchant cannot edit canonical product truth, customer reviews/ratings, reward
ledger, reputation projection or customer private history. Campaign/ads, complex
organization, bulk imports and advanced analytics are separately gated. Exact V1
surface is `OWNER_DECISION_REQUIRED`.
