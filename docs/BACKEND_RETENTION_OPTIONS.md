# Backend Retention Options

**State:** OPTIONS ONLY — POLICY/LEGAL REVIEW REQUIRED

Retention is purpose- and class-specific; one global period is unsafe.

| Data family | Options/recommendation |
|---|---|
| Public catalog/shop/listing history | Retire with lineage while referenced; prune superseded presentation after dependency review |
| Customer profile/location/wishlist/cart | Delete/minimize promptly on account lifecycle, subject to active operation and consent evidence |
| Verified purchase/review | Preserve necessary immutable evidence/history; pseudonymize where policy allows |
| Chat/notification | Short bounded product-purpose retention plus user controls; legal hold only by explicit process |
| Audit/security | Longer restricted period based on risk/evidence purpose; never general analytics |
| Analytics/telemetry | Shortest useful event detail; aggregate then delete/minimize raw identifiers |
| Ads/reward/reputation | Ledger/economic/trust reconstruction period with separate policy review |
| Media/orphans | Referenced lifecycle; unreferenced object at least seven days before trusted cleanup |
| Idempotency/outbox | At least retry/replay/correction risk; irreversible uniqueness may require durable source constraint |

Options include fixed periods, event-driven deletion, tiered raw→aggregate and
legal/policy hold. Holds are scoped, approved and audited; they do not silently
retain everything. Exact periods, jurisdictional duties and user disclosures are
`OWNER_DECISION_REQUIRED` with qualified legal/privacy review.
