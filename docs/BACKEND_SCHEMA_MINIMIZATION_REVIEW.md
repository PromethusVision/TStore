# Backend Schema Minimization Review

**Result:** PASS — EXTEND BEFORE DUPLICATING

| Concept | Minimum representation | Avoid now |
|---|---|---|
| merchant | organization + membership seam only when Merchant App starts | enterprise tenant hierarchy |
| branch | current shop as operational branch for V1 | duplicate shop/branch rows without behavior |
| capability | small stable capability registry/claims | dozens of roles and per-screen permissions |
| variant | selected-domain child identity | synthetic variant for every current product |
| listing | evolve `shop_products` | parallel listing table with dual-write by default |
| verified purchase/review | extend current canonical evidence | replacement ledger that changes rights |
| audit | focused append-only facts for sensitive commands | universal event sourcing |
| analytics | derived/read projections | analytics tables as domain authority |
| outbox | add only when durable async consumers require it | infrastructure without consumers |
| moderation | case/evidence seam if Ops needs it | generalized workflow engine in pilot |

New tables are justified only by a stable identity, lifecycle, authorization or
transaction boundary that current rows cannot express safely. Derived state should
be recomputable and not duplicate canonical truth without reconciliation.

