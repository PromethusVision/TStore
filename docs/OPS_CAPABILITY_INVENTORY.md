# Operations Capability Inventory

**State:** PROPOSED FOR OWNER REVIEW

## Classification

- `MUST_HAVE_PILOT`: required before a controlled commercial pilot creates the relevant case type.
- `SHOULD_HAVE`: may begin manually at tiny scale but needs a governed path before expansion.
- `DEFER`: planned integration point; no current operational object or owner-final rules.
- `FUTURE`: scale optimization, not a launch dependency.

| Domain | Capability | Class | Pilot boundary |
|---|---|---|---|
| SUPPORT | Case intake, triage, safe reasons, ownership verification | MUST_HAVE_PILOT | No password/token request; no arbitrary history edit |
| MODERATION | Listing/review/report decision with evidence and appeal | MUST_HAVE_PILOT | Disagreement alone is not removal |
| MERCHANT_VERIFICATION | Identity, shop existence, evidence status | MUST_HAVE_PILOT | Sector selection grants nothing |
| CATALOG_REVIEW | Candidate approve/merge/correct/reject/policy route | MUST_HAVE_PILOT | Canonical mutations require governed authority |
| POLICY_REVIEW | Versioned allow/restrict/exclude decisions | MUST_HAVE_PILOT | Unknown sensitive scope fails closed |
| QR_FRAUD_REVIEW | Replay, wrong shop, collusion, staff abuse | MUST_HAVE_PILOT | Verified history is append-only/superseded |
| SECURITY_INCIDENT | Detect, contain, investigate, recover, learn | MUST_HAVE_PILOT | Separate from ordinary support |
| SYSTEM_MONITORING | Auth/RPC/QR/catalog/crash/latency health and kill switches | MUST_HAVE_PILOT | Alerts must be actionable |
| AUDIT | Privileged action and evidence history | MUST_HAVE_PILOT | No silent overwrite/deletion |
| ADS_REVIEW | Campaign/listing/creative/traffic review | DEFER | Ads runtime and owner decisions absent |
| REWARD_ABUSE | Progress/claim/collusion review | DEFER | Reward branch/rules unavailable |
| PRIVACY_REQUESTS | Account access/export/correction/deletion routing | SHOULD_HAVE | Exact legal process requires review |
| APPEALS | Independent reconsideration of material decisions | SHOULD_HAVE | High-impact enforcement needs it from pilot |
| QUEUE/ASSIGNMENT | Role-scoped queues and workload visibility | SHOULD_HAVE | Manual assignment acceptable at tiny scale |
| QA/SAMPLING | Consistency and false-positive review | SHOULD_HAVE | No productivity surveillance |
| AUTOMATED ROUTING | Deterministic low-risk routing/dedup | FUTURE | No opaque auto-enforcement |
| ML MODERATION | Assistive signals only | FUTURE | Human explainability and appeal required |
| EXTERNAL TICKETING | Email/form channel integration | FUTURE | Tool choice depends on volume/cost/security |

## Launch rule

A feature must not launch merely because its operator console is absent; either the required operational capability exists or the feature remains disabled/fail-closed. Support access never substitutes for a missing server contract.

`MUST_HAVE_PILOT_DOMAINS: 9`

`OWNER_FINALIZATION_PERFORMED: NO`
