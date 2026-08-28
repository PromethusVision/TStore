# Merchant Pilot Architecture Readiness

State: `DESIGN READY FOR OWNER REVIEW — IMPLEMENTATION NOT READY`

| Area | Assessment | Evidence | Remaining gate |
|---|---|---|---|
| Product contract | READY_FOR_OWNER_REVIEW | Minimum/MUST/DEFER defined | MPR-01/02 |
| Merchant auth | READY_FOR_OWNER_REVIEW | Session and wrong-role behavior defined | Dedicated app implementation |
| Authority | READY_FOR_OWNER_REVIEW | Exact-shop capability equation | Schema/RLS/RPC + tests |
| Shop verification | READY_FOR_OWNER_REVIEW | Identity/shop/sector/policy separated | MPR-06, ops runbook |
| Listing/catalog | READY_FOR_OWNER_REVIEW | Core fields, revision, candidate boundary | Freshness owner choice + backend |
| QR verifier | READY_FOR_OWNER_REVIEW | Atomic, replay, reconcile, physical matrix | Dev concurrency + two-device |
| Assisted onboarding | READY_FOR_OWNER_REVIEW | Allowed/forbidden/time-boxed | MPR-01/06/10 |
| Support/notifications | MINOR_GAP | Cases and critical signals defined | Coverage/channel decision |
| Reviews/evaluation | MINOR_GAP | Read/report boundary defined | MPR-07 |
| Analytics/audit | READY_FOR_OWNER_REVIEW | Action-first and audit minimum | Event contract implementation |
| Android | MAJOR_GAP | Device assumptions and matrix defined | Dedicated signed artifact |
| iOS | MAJOR_GAP | Explicitly deferable option | Owner choice, signing/device |
| Backend migration | MAJOR_GAP | Impact forecast only | DDL/RLS/RPC implementation |
| Compliance | MINOR_GAP | Ordinary allowlist/fail closed | Expert/owner cohort policy |
| Operations | MINOR_GAP | Case/audit/operator boundary | Named operator/backup/pause |
| Release | MAJOR_GAP | Gates defined | Exact artifact, go/no-go, Production authority |

## Blockers before runtime pilot

1. 12 root owner decisions remain open.
2. Merchant App runtime/identity/signing does not yet represent this minimum slice.
3. Membership/capability, listing freshness/revision and candidate backend changes are not implemented.
4. Development RLS/RPC/concurrency and migration acceptance are not run.
5. Exact signed merchant artifact and two-device physical QR acceptance are not run.
6. Cohort verification/allowlist, support coverage, monitoring and Production release authorization are absent.

`MERCHANT_PILOT_MINIMUM_FOUNDATION: PASS`
`MERCHANT_AUTHORITY_MINIMUM: PASS`
`MERCHANT_LISTING_MINIMUM: PASS`
`MERCHANT_QR_MINIMUM: PASS`
`OPERATOR_ASSISTED_MODEL: PASS`
`MERCHANT_PILOT_STRESS_TESTS: PASS`
`MERCHANT_PILOT_OWNER_PACK: PASS`
`READY_FOR_MERCHANT_PILOT_OWNER_REVIEW: YES`
`OWNER_FINALIZATION_PERFORMED: NO`
`RUNTIME_IMPLEMENTATION: NO`

