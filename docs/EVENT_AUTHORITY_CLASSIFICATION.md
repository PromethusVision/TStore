# EsnaftaVar Event Authority Classification

**State:** `PROPOSED`

| Level | Definition | Permitted use |
|---|---|---|
| `SERVER_AUTHORITATIVE` | Emitted after a trusted server commits a guarded business outcome | Ledger/state facts and authoritative metrics |
| `SERVER_DERIVED` | Reproducible server projection from authoritative sources | Aggregates, summaries and bounded detections |
| `CLIENT_REPORTED` | Client declares an intent/action; delivery is not independent proof | Product analytics with validation/filtering |
| `CLIENT_OBSERVED` | Client measures rendering, visibility, latency or failure | UI/ad telemetry under consent and quality rules |
| `SOFT_SIGNAL` | Non-authoritative engagement or heuristic | Directional analytics only |
| `AUDIT_ONLY` | Evidence of privileged/system action; access restricted | Audit/investigation, not product KPI by default |

Authority describes evidence quality, not importance. A server may relay a client
claim without making it authoritative. `SERVER_DERIVED` must retain lineage to
source event IDs and rule version.

## Hard gates

- `verified_purchase_created` can only be `SERVER_AUTHORITATIVE` after atomic QR
  validation and replay protection. Issuance, rendering, scanning and client
  confirmation are not substitutes.
- Reward ledger mutation, badge grant, ad billing and reputation materialization
  require their own authoritative/idempotent contracts. Generic analytics cannot
  produce them.
- Views, directions, wishlist, cart and search are soft/client signals even when
  a server receives them.
- Audit events are not customer analytics and do not silently enter dashboards.

Any metric declares the minimum accepted authority. Mixed-authority metrics
publish separate components rather than collapsing evidence grades.

`AUTHORITY_MODEL_FINALIZED: NO`

