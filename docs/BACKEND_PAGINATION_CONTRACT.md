# Backend Pagination Contract

**State:** PROPOSED

Growing feeds and histories require keyset/cursor pagination: notifications, chat,
reviews, purchases, merchant listings, product candidates, audit/cases, reward
ledger and event delivery history. Small bounded reference data may remain one
read with an explicit cap.

## Cursor rules

- order is deterministic and total, normally `(trusted_time DESC, immutable_id DESC)`
  or `(sort_key ASC, immutable_id ASC)`;
- cursor is opaque/versioned and bound to filter, sort, tenant/subject and access
  context;
- page size has a server maximum and safe default;
- next cursor derives from the final returned row after authorization/filtering;
- changing filters/revision invalidates or restarts the cursor;
- late inserts may appear on refresh, not be duplicated into an older page;
- deletion/retirement does not cause offset drift;
- clients deduplicate stable IDs and discard prior-session pages.

Offset pagination is acceptable only for small, immutable/admin-bounded sets or
diagnostics with documented limits. Cursor contents must not expose PII, raw query
text or authorization secrets. Counts are separately costed and may be estimated
only when labelled.
