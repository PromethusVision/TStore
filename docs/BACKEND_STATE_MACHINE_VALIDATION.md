# Backend State-Machine Validation

**State:** PROPOSED — INVALID TRANSITIONS FAIL CLOSED

Every lifecycle defines allowed transitions, actor/capability, preconditions,
expected revision, side effects and terminal behavior. A client cannot set a state
column directly to skip the transition contract.

## Critical examples

| Subject | Valid principle | Invalid example |
|---|---|---|
| QR session | active → used/expired/cancelled once | expired → active; used → used with new purchase |
| Cart | active mutations under one shop | checked-out/cancelled cart receives items |
| Membership | invite/active → suspended/revoked/expired | revoked user self-reactivates |
| Shop/listing/product | governed active/retired/suspended flow | retired row silently re-owned |
| Review | create/update/delete/recreate under evidence | merchant sets verified/author |
| Campaign | draft/review/active/paused/ended with revision | ended campaign spends/resumes blindly |
| Reward entry | append earn/reverse/redeem/expire | prior ledger row overwritten |
| Ops case | versioned triage/review/decision/appeal | closed history edited away |

Transition checks occur atomically with effects and audit/outbox where required.
Concurrent stale transitions return conflict; they are not coerced to the latest
state. Exact state names remain domain implementation choices unless already
canonical.

