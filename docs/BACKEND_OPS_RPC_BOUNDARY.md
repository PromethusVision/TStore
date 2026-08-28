# Backend Operations RPC Boundary

**State:** PROPOSED FROM OPS FOUNDATION — NO OPS IMPLEMENTATION

Operations uses dedicated case-bound actions, never generic admin SQL/table CRUD.
Each privileged call validates active operator capability, case/subject scope,
policy version, evidence, expected revision, reason, fresh assurance and required
approval/compensating control.

Candidate actions include case transition/assignment, merchant containment,
listing/review moderation, product candidate approval, merge/split, verified
purchase correction, appeal and break-glass activation. The action records an
append-only audit envelope and invokes the domain's own mutation contract.

Operators cannot directly edit review ratings, reward balances, reputation scores,
purchase snapshots or erase audit. Break-glass is time-bound, alerted and audited.
Exact pilot roles/two-person gates remain `OWNER_DECISION_REQUIRED`.

