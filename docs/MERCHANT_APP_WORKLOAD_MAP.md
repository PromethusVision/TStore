# Merchant App Workload Map

Status: **PROPOSED — COMPLEXITY, NOT CALENDAR PROMISES**
Wave: 17 / WP98

| Area/wave | Complexity | Parallelizability | Main reason |
|---|---|---|---|
| Owner decisions | M | Low | Root semantics gate all contracts |
| Backend contract/spec | XL | Medium | Identity/catalog/QR cross-cut |
| App/config skeleton | M | High after decisions | Mostly isolated project work |
| Auth/merchant context | L | Low | Global security/navigation state |
| Onboarding/shop | L | Medium | Policy/location lifecycle |
| Catalog/listing core | XL | Medium | Canonical/variant/listing and moderation |
| Candidate/barcode/custom | L | High after catalog core | Isolated flows, shared contracts |
| QR operations | XL | Medium | Backend atomicity + physical devices |
| Reviews/notifications/dashboard | L | High after roots | Separate feature surfaces |
| Pilot hardening/release | XL | Low | Integrated devices/backend/operations |

XS/S tasks are expected inside waves (copy, empty states, isolated validators), but splitting a security/business outcome into micro-tasks is discouraged.
