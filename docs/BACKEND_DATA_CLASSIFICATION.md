# Backend Data Classification

**State:** PROPOSED CLASSIFICATION — RETENTION/LEGAL REVIEW OPEN

| Class | Examples | Default access/handling |
|---|---|---|
| `PUBLIC` | active catalog/shop/listing projection, visible reviews, public media | anonymous read; no public write |
| `ACCOUNT` | profile basics, consent/account lifecycle | own account; restricted support purpose |
| `MERCHANT_PRIVATE` | membership, private shop operations, listing drafts, dashboard | exact organization/shop capability |
| `CUSTOMER_PRIVATE` | addresses, saved locations, wishlist, cart, purchases, notifications | exact customer/required participant |
| `SECURITY` | denial/anomaly, session assurance, abuse signals | security/need-to-know; never client detail |
| `AUDIT` | privileged action, evidence/decision lineage | append-only restricted purpose |
| `POLICY` | product/merchant eligibility, moderation reason/evidence | scoped reviewer; public safe outcome only |
| `ANALYTICS` | minimized event/aggregate with authority/privacy version | approved metric purpose and threshold |

Classification attaches to fields/events/media/evidence, not only whole tables.
Mixed records expose purpose-specific projections. Public source data does not make
derived customer behavior public. Pseudonymous IDs remain personal when linkable.

Every class defines collection purpose, owner, authorized roles, encryption/logging
posture, export, retention/deletion and incident handling before implementation.
Unknown fields fail to the more restrictive class.
