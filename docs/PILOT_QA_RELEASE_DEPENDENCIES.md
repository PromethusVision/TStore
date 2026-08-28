# EsnaftaVar Esenler Pilot — QA and Release Dependencies

**State:** `RELEASE INPUT — NO BUILD OR DEPLOYMENT`

## Automated gate

Clean source/base, dependency integrity, analyzer/lints, unit/widget/integration,
environment/config fail-closed checks, migration contract, RLS/RPC/storage/realtime,
QR/review idempotency, security/privacy scans and build evidence must pass for the
exact release commit.

## Physical/manual gate

- clean install and upgrade on supported Android matrix;
- two-device customer/merchant QR including replay, timeout and wrong-shop;
- camera, GPS/location denial/manual fallback and directions handoff;
- auth email/callback and session recovery;
- offline/slow/lifecycle/background-resume behavior;
- catalog media, search, accessibility and customer promise comprehension;
- supported merchant path and operator incident/pause drill;
- store listing, data-safety/privacy and support links.

## Production-safe smoke

Authorized, minimal, reversible/non-destructive checks for startup, guest discovery,
auth, categories/search/product/shop, storage media, merchant authority, listing
truth, QR/review and account lifecycle. Test data is clearly marked and cleaned only
under an approved policy. No Production action is authorized by this document.

## Evidence rule

Passing Development, a synthetic config or a different binary does not certify the
pilot artifact. Every exception has owner, reason, impact and expiry; P0 invariants
have no waiver.

`PILOT_QA_ACCEPTANCE_COMPLETE: NO`
