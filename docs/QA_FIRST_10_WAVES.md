# First 10 QA Implementation Waves

**State:** PROPOSED — NO IMPLEMENTATION

| Wave | Goal | Scope | Dependencies / owner gate | Tests | Physical gate | CI/release effect | Integration gate | Complexity |
|---|---|---|---|---|---|---|---|---|
| 1 | Baseline lock | Re-run analyzer/full suite, skip/fixture inventory | clean main | existing + inventory reconciliation | none | trusted starting evidence | zero unexpected changes | S |
| 2 | Minimal PR gate | format/diff/analyze/fast tests/secret scan | R03 provider decision | workflow contract tests | none | fast deterministic CI | untrusted PR isolation | M |
| 3 | Backend contract harness | local ephemeral migrations, RLS/RPC/invariants | local tooling | role matrix, QR/review | none | migration PR gate | exact 0001–0009 replay | L |
| 4 | Auth release acceptance | confirmation/recovery/callback/env | SMTP/callback owner gates | unit/widget/live Development | real email + device callback | Auth RC gate | no enumeration/role regression | M |
| 5 | QR acceptance pack | concurrency/idempotency/price/replay | synthetic Development fixture authority | RPC/live negative matrix | two-device camera | QR RC gate | Customer+merchant sessions | L |
| 6 | Physical Android matrix | signed install, GPS/camera/lifecycle/network/text | R01/R02, signing material | automated matrix support | representative Android set | exact artifact evidence | hash/signature match | L |
| 7 | Migration release rehearsal | pre/dry/post/backfill/recovery | migration authority, backup plan | invariants/old-new client | none | protected migration evidence | no remote Production apply | L |
| 8 | Release health/incident | critical signals, staged pause, support | R08/R09/R10 | signal contract/failure simulation | exact-artifact smoke | go/no-go dashboard | redaction/baseline | M |
| 9 | Release candidate rehearsal | freeze, internal track, clean/upgrade/hotfix | R05/R12 | full RC suite | full physical pack | end-to-end manual gate | evidence bundle | L |
| 10 | Esenler pilot go/no-go | reconcile all evidence and open risks | all P0 owner decisions | no new claims; rerun stale gates | final signed artifact | authorized staged launch | Integration independent review | M |

S/M/L are relative engineering complexity, not calendar promises.
