# Backend Realtime Channel Model

**State:** PROPOSED

Channels are named/scoped by stable subject and purpose, not mutable display name.

| Channel family | Subject | Proposed payload |
|---|---|---|
| Customer notification | authenticated customer | notification ID/revision and safe fields |
| Direct chat | participant/thread | message revision and bounded content under chat policy |
| Merchant shop operations | exact shop + capability | listing/QR/work-item IDs and state revisions |
| Ops case | assigned case/queue | minimized case transition; restricted evidence fetched separately |
| Reward/reputation | exact customer or shop | derived projection revision, not raw ledger/evidence |

One organization-wide wildcard subscription is denied unless an explicit aggregate
capability and scale plan exists. Shop A cannot subscribe to Shop B. Channel join
and every event delivery follow server authorization; public channel names do not
contain secrets or grant access.

At-least-once/out-of-order behavior is assumed. Clients deduplicate by row/event
ID and revision, perform gap refresh and discard late data from prior sessions.
Exact merchant V1 channels are `OWNER_DECISION_REQUIRED`.
