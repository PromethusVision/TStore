# EsnaftaVar Review Event Model

**State:** `PROPOSED EVENT CONTRACT — NO NEW REVIEW RIGHTS`

| Event | Authority | Required references | Meaning |
|---|---|---|---|
| `review_created` | Server authoritative | review, author subject, product/shop, verified-purchase eligibility evidence | One allowed active review was persisted |
| `review_updated` | Server authoritative | review, prior revision, new revision | Existing review content/rating changed under current rights |
| `review_deleted` | Server authoritative | review, deletion mode/reason class | Review became unavailable; history/audit policy applies |
| `review_eligibility_changed` | Server derived, only if an explicit durable eligibility projection exists | subject/product and source evidence | Eligibility projection changed; not a new entitlement |

The current product boundary remains: only QR merchant-confirmed verified purchase
evidence can establish review eligibility, with one active review per
customer/product. Repeat purchase/quantity does not create extra review rights.

Analytics receives IDs, rating band where approved, lifecycle action and trusted
timestamps—not review text, customer identity or moderation evidence. Rating
aggregates are versioned projections and must reverse/recompute on update/delete.
Late delivery deduplicates by review revision event ID.

Reports/moderation/operator actions use separate operations/audit events. An ad,
click, directions request, cart entry or reward cannot create review eligibility.

`REVIEW_RIGHTS_CHANGED: NO`

