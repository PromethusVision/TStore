# Backend Migration Blast-Radius Review

**Result:** READY FOR OWNER REVIEW — EXECUTION NOT AUTHORIZED

| Change family | Principal blast radius | Safer shape | Stop signal |
|---|---|---|---|
| merchant membership | Auth/profile/shop ownership, RLS, QR | additive bridge + shadow reconciliation | any customer role/RLS regression |
| listing revision/freshness | discovery, seller comparison, Merchant writes | nullable additive fields, default old reads | old client loses listing or price meaning changes |
| selected variants | product/listing/cart/QR/review identity | domain-gated child identity and old product projection | ambiguous historical reference |
| catalog merge/split | every product consumer | append-only lineage and unresolved state | automatic reassignment changes rights |
| QR hardening | cart, two clients, verified purchase/reviews | compatible RPC response extension | replay/wrong-shop or old client break |
| retention/deletion | Auth, profile, chat, evidence, audit | purpose-specific lifecycle with exact counts | unexplained residual or over-delete |
| Realtime/media | publication, Storage, client lifecycle | explicit table/bucket policy additions | cross-user subscription/object access |
| event/outbox | transactions, retries, observability | defer; add only with consumer and reconciliation | event failure blocks domain commit |
| Ads/Reward/reputation | economic/trust/legal surfaces | separate future migrations/evaluators | analytics/paid signal becomes authority |

## Controls

- one migration author and immutable artifact;
- actual ledger/schema/data preflight, backup and single-writer window;
- clean-room + representative upgrade snapshot + backfill reconciliation;
- RLS/RPC/concurrency and Customer N/N-1 matrix;
- canary/read-first postflight, explicit abort owner and forward-repair plan;
- destructive retirement only in a later separately authorized wave.

