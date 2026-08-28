# Merchant Pilot Implementation Sequence

State: `PLAN ONLY — NO IMPLEMENTATION`

## First ten implementation waves

| Wave | Goal | Dependencies | Main outputs | Gate |
|---|---|---|---|---|
| 1 | Owner decisions and scope freeze | This foundation | Model/cohort/single-owner/policy decisions | Owner review |
| 2 | Backend authority contract | Wave 1, Backend | membership/capability predicate, RLS tests | Dev security |
| 3 | Listing truth backend | Catalog + Wave 2 | revisioned price/availability/freshness command | Contract tests |
| 4 | Candidate/assisted workflow | Ops + Catalog | provenance, attestation, review state | Ops acceptance |
| 5 | Merchant app shell/auth | Signing/release | dedicated identity, auth, shop projection | Device smoke |
| 6 | Listing self-service | Waves 3/5 | list/edit/conflict/offline-safe UI | Widget + Dev |
| 7 | QR verifier extraction/hardening | QR backend + Wave 5 | scan/preview/confirm/reconcile/history | Concurrency |
| 8 | Support/notifications/audit | Ops/Analytics | case/correlation, critical status | Privacy review |
| 9 | Review read/report + pilot polish | Review contract | read-only projection/report | Policy tests |
| 10 | Exact artifact pilot certification | QA/Release | signed build, two-device matrix, go/no-go | Human release |

## Ordering invariants

UI merchant buttons do not precede server authority. QR physical test does not precede exact-shop concurrency contract. Production migration does not precede Development dry-run/postcheck. Candidate UI does not precede review/provenance. Dashboard work does not block core pilot.

## Integration gates

Each wave owns targeted tests and task branch. Integration verifies source compatibility, combined diff, migrations, analyzer/tests and release artifacts. Production apply/release is an explicit human authorization separate from merge.
