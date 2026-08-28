# Backend RPC Candidate Registry

**State:** CONCEPTUAL REGISTRY — NO SQL

| RPC concept | Purpose | Caller | Transaction | Idempotent | Authorization | Current/new | Scope |
|---|---|---|---|---|---|---|---|
| customer profile update | Allowlisted own fields | Customer | single row | optional | own profile + role guard | current direct/trigger | V1 |
| saved location mutations | Default/delete invariants | Customer | yes when default changes | recommended | own customer | current RPC | V1 |
| delete current account | Exact cascade/lifecycle | Customer | yes | terminal reconcile | current user + fresh auth | current RPC | V1 |
| create QR session | Validate cart/shop and issue opaque token | Customer | yes | required | own active cart | current RPC, harden | V1 |
| get QR verification view | Minimal authorized preview | Merchant verifier | read snapshot | n/a | exact shop capability | current RPC, extend | V1 |
| confirm QR | Consume and create purchase/items | Merchant verifier | yes | required | exact shop capability | current RPC, harden | V1 |
| submit shop rating | Verified participant rating | Customer | yes | required | purchase evidence | current RPC | V1 |
| review eligibility | Bounded evidence projection | Customer | read | n/a | current customer | current RPC | V1 |
| review create/update/delete | Enforce evidence/uniqueness/aggregate | Customer | yes | required | author + evidence | current RPC | V1 |
| list customer conversations | Bounded enriched projection | Customer | read | n/a | participant | current RPC | V1 |
| create/revise/retire listing | Catalog/listing validation | Merchant | yes | required | listing capability + shop | new | V1/FUTURE |
| submit product candidate | Provenance and dedup queue | Merchant | yes | required | listing capability | new | FUTURE |
| grant/revoke membership | Delegation and lifecycle | Merchant admin | yes | required | staff capability + scope | new | FUTURE |
| merge/split product | Governed lineage operation | Operator | yes | required | case + catalog capability | new | FUTURE |
| campaign mutations | Budget/target revision | Merchant | yes | required | campaign capability + listing | new | FUTURE |
| reward command | Earn/reverse/redeem ledger | Trusted server/customer where allowed | yes | required | reward policy | new | FUTURE |
| ops decision/action | Case-bound privileged mutation | Operator | yes | required | case + capability + policy | new | FUTURE |
| emit analytics event | Validate allowed event envelope | Trusted producer | bounded append | required | producer/type policy | new | FUTURE |

## Owner decisions

The V1 merchant RPC set, product candidate auto-routing, reward/customer caller
surface and event-outbox timing are `OWNER_DECISION_REQUIRED`. This registry is a
planning inventory, not execute permission.
