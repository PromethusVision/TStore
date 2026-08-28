# EsnaftaVar Event Ordering Model

**State:** `PROPOSED`

Global order is neither required nor promised. Ordering is defined only inside an
entity/aggregate stream when a producer can supply a monotonic revision or trusted
sequence. `occurred_at` alone is not an ordering key.

| Condition | Consumer behavior |
|---|---|
| Duplicate | Deduplicate by event ID/source outcome identity |
| Out of order | Apply revision/precondition rules; hold or recompute projection |
| Late event | Attribute to event-time window and mark projection freshness/restatement |
| Clock skew | Prefer trusted server time/sequence; retain client time as labelled observation |
| Missing predecessor | Quarantine/retry or rebuild from authoritative source; never invent state |
| Conflicting same revision | Reject and alert data-quality owner |

Listing, review, taxonomy and catalog changes carry entity revision/effective
version. Ledger outcomes use immutable entries rather than “latest timestamp wins.”
QR confirmation is governed by atomic server state, not event arrival order.

Dashboards document late-event windows and update historical aggregates when
needed. A later-arriving client view cannot precede or cause a verified purchase
merely because its device clock says so.

`GLOBAL_EVENT_ORDER: NOT_REQUIRED`

