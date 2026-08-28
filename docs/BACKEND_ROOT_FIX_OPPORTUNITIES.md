# Backend Root Fix Opportunities

**State:** ARCHITECTURE LEVER MAP

| ROOT_FIX | Rule | Failures reduced | Stress families |
|---|---|---|---|
| RF-01 | Subject/resource-derived RLS plus exact shop capability | BF-P0-01/02/03 and BF-P1-03/04 | RLS authorization security mixed |
| RF-02 | Narrow versioned RPC with input/revision/idempotency contract | BF-P0-04/05/07 and BF-P1-01/02 | RPC concurrency idempotency QR review |
| RF-03 | Immutable IDs/snapshots/lineage/correction events | BF-P0-05/06 and BF-P1-08 | lifecycle catalog correction review migration |
| RF-04 | Additive expand/backfill/shadow/cutover/contract | BF-P0-08 and BF-P1-01/06/08 | migration client compatibility recovery |
| RF-05 | Authority-classified events and selective outbox | BF-P0-04/05 and BF-P1-02/06 | global mixed failure recovery analytics |
| RF-06 | Data classification field projection/redaction/retention | BF-P1-03/05/08 and BF-P2-03 | authorization lifecycle security privacy |
| RF-07 | Stable keyset cursor and measured index/read model | BF-P1-07 and BF-P2-01/02 | query merchant journey client migration |
| RF-08 | Demo/environment provenance and fail-closed trust exclusion | BF-P1-06 | global mixed migration lifecycle |
| RF-09 | Case-scoped trusted writer plus append-only audit | BF-P0-06/07 and BF-P1-08 | authorization catalog correction lifecycle |
| RF-10 | Reconciliation-first failure recovery | BF-P0-04/08 and BF-P1-02/04/08 | concurrency idempotency failure migration |

Highest leverage for Merchant V1 is RF-01 + RF-02 + RF-10. Highest leverage for
safe catalog evolution is RF-03 + RF-04 + RF-09. These are architectural rules,
not a proposal to implement every future subsystem before the pilot.
