# Gamification Security Threat Model

**State:** PROPOSED — SECURITY REVIEW REQUIRED

| Threat | Impact | Required control | Priority |
|---|---|---|---|
| Forged verified purchase | Unfunded value/reputation | Server-authoritative merchant confirmation and immutable identity | P0 |
| QR replay/concurrency | Duplicate transaction/reward | Atomic single-use confirmation and downstream idempotency | P0 |
| Event replay/reorder | Duplicate or stale state | Unique event key, sequence/version and replay-safe reducers | P0 |
| Client balance tamper | False display/redemption | Server authority; signed/authenticated APIs | P0 |
| Merchant/customer collusion | Farming | Relationship/anomaly signals, caps, hold and human appeal | P0 |
| Privileged ledger edit | Hidden value theft | Append-only adjustment, dual control and audit | P0 |
| Cross-tenant access | Privacy/financial breach | RLS/authorization by stable identity and least privilege | P0 |
| Policy bypass | Illegal incentive | Versioned server policy fail closed | P0 |
| Paid reputation coupling | Deceptive trust | Separate data paths and invariant tests | P0 |
| Enumeration/privacy inference | Purchase disclosure | Minimized responses, public aggregation thresholds | P1 |
| Notification phishing | Account compromise | Trusted deep-link/auth contract and restrained content | P1 |
| Denial/event flood | Processing lag/cost | Rate limits, queues, monitoring and backpressure | P1 |

Automated fraud signals hold actions; they do not declare guilt or publicly punish without human review and appeal.
