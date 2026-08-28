# Merchant App First 10 Implementation Waves

Status: **PROPOSED — NO IMPLEMENTATION**
Wave: 17 / WP97

| Wave | Goal | Branch scope | Dependencies | Tests/integration gate |
|---|---|---|---|---|
| 1 | Owner decision closure | Decision docs only | None | P0 selections recorded |
| 2 | Backend contract/spec | API/schema/RLS/RPC design | Wave 1 | Threat/contract review |
| 3 | Project/config skeleton | Separate Flutter app, env/CI | Wave 1 | Dev/prod separation, secret scan, release build |
| 4 | Auth/merchant context | Session, membership, active shop | Waves 2–3 | Cross-shop/role negative tests |
| 5 | Onboarding/shop | Draft, policy, location, lifecycle | Wave 4 | Resume/idempotency/fail-closed |
| 6 | Catalog/listing core | Search, listing, price, availability | Waves 2,4 | Catalog/RLS/concurrency matrix |
| 7 | Candidate/barcode/custom | Missing product and exceptions | Wave 6 | Duplicate/policy/workload tests |
| 8 | QR operations | Camera, validation, confirm, reconcile | Waves 2,4 | Automated fraud + two physical devices |
| 9 | Reviews/notifications/dashboard | Approved SHOULD scope | Waves 5–8 | Privacy/semantic/deep-link tests |
| 10 | Pilot hardening/release | Full regression, support/runbooks, signed build | All | Commercialization gates PASS |

Each wave uses a task branch; Integration alone merges verified work to main.
