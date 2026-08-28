# First 10 Future Implementation Waves

**State:** PROPOSED PLAN — NO IMPLEMENTATION AUTHORIZED

| WAVE | GOAL | SCOPE | DEPENDENCIES | OWNER GATE | BACKEND IMPACT | CUSTOMER APP IMPACT | MERCHANT APP IMPACT | TESTS | INTEGRATION GATE | COMPLEXITY |
|---:|---|---|---|---|---|---|---|---|---|---|
| 1 | Canonical decisions | Resolve roots, policy/liability/privacy reviews | Current foundation | RGR-01–RGR-16 | None | None | None | Decision consistency | Canonical pack approved | M |
| 2 | Event/identity contract | Freeze authoritative events, corrections, stable IDs | Wave 1; catalog/QR/review | Event authority approved | Contract docs only | Contract docs | Contract docs | Lineage/idempotency specs | No review/ads leakage | M |
| 3 | Development ledger foundation | Immutable ledger/outbox/projections, no value | Waves 1–2 | Schema/runbook approval | Development migration/RLS/RPC | None | None | RLS, concurrency, replay | Local + Development only | XL |
| 4 | Policy/fraud engine | Fail-closed policy, holds, anomaly/audit | Wave 3 | Policy registry owner | Development services/workers | Pending state only | Hold/dispute state | 500+ abuse/policy cases | Zero unsafe issuance | L |
| 5 | Reward shadow calculation | Approved unit/scope/funding model, no public promise | Waves 3–4 | Reward options selected | Derived shadow state | Internal/dev inspection | Internal/dev inspection | Reconciliation/load | Shadow has no economic effect | L |
| 6 | Customer badge shadow | Approved families/evidence/lifecycle | Waves 2–4 | Badge roots selected | Badge derivation | Private internal surface | None | Privacy/revocation/idempotency | No public badge | L |
| 7 | Merchant reputation shadow | Shop-first signals/fairness | Waves 2–4 | Reputation roots selected | Signal projections | Internal shop facts | Evidence dashboard | Fairness/sector/rating separation | Sparse data handled | XL |
| 8 | Development surfaces | Explainable accessible customer/merchant views | Waves 5–7 | UX copy/surface approval | Read APIs | Reward/badge/reputation states | Program/dispute views | Widget/e2e/offline/error | Feature flags + no runtime leakage | XL |
| 9 | Controlled shadow pilot | Measure correctness, fraud and workload | Wave 8 | Participant/runbook approval | Monitored Development/pilot environment | Limited internal | Limited internal | Load/security/trust/support drills | Kill switch and reconciliation | L |
| 10 | Production decision | Explicitly authorize selected capability only | Wave 9 evidence | Destructive/economic release approval | Reviewed migration/deploy | Signed release | Signed merchant release | Full regression/live acceptance | Rollback, monitoring, owner signoff | XL |

No wave implies `origin/main`, Development or Production write authority. Those require their own assigned integration/release tasks.

