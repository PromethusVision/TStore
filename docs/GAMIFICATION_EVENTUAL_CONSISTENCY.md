# Gamification Eventual Consistency

**State:** PROPOSED

Verified purchase confirmation is authoritative and must succeed/fail independently. Reward, badges and reputation may update later through idempotent derived processing.

## UX states

- `PENDING` → event accepted, evaluation incomplete.
- `ACTIVE/EARNED` → projection reached current policy version.
- `HELD` → fraud/policy/manual review; not customer guilt.
- `ADJUSTED/REVERSED/EXPIRED` → linked immutable lifecycle event.
- `STALE` → cached projection freshness disclosed.

The client must not guess success after a timeout. Retry uses the same idempotency identity. Reordering is handled from source version/occurred-at semantics, not arrival order alone. Reconciliation compares ledger/event/projection versions and repairs derived state without rewriting history.
