# Reward Purchase Correction Model

**State:** PROPOSED — OWNER DECISION REQUIRED FOR ECONOMIC EFFECT

## Principles

- Never edit or delete the verified purchase or original reward ledger entry in place.
- Append a reasoned, authorized correction linked to the source event and affected entries.
- Recompute derived progress idempotently; do not duplicate review rights.
- Notify a customer when economic value changes and provide a dispute path.

| Correction | Reward action | Historical integrity |
|---|---|---|
| Duplicate confirmation | Suppress duplicate evaluation | Keep duplicate-attempt audit. |
| Full reversal/refund | Linked `REVERSE` or `ADJUST` | Original earn remains visible. |
| Partial correction | Proportional/ruled `ADJUST` only if unit model supports it | Snapshot before/after reason. |
| Product merge | Repoint derived canonical identity; do not re-earn | Preserve original product snapshot/lineage. |
| Product split | No automatic fan-out | Hold ambiguous mapping for review. |
| Merchant suspension | Freeze unsettled issuance; do not erase lawful history | Record status and appeal outcome. |

Correction authority, reason codes and economic policy remain implementation prerequisites; no SQL/schema is defined here.
