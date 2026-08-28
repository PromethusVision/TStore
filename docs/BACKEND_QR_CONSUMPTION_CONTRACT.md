# Backend QR Consumption Contract

**State:** ACTIVE INVARIANT — SINGLE USE

## Atomic boundary

Confirmation locks/serializes the exact QR session, revalidates authorization and
shop binding, transitions the session from active to used and inserts one verified
transaction plus all item snapshots in one database transaction.

## Success invariants

- exactly one `verified_transactions` row for the source session;
- transaction shop/customer equal issued context;
- every item has durable canonical `product_id` and listing/snapshot identity;
- quantity, unit price and line amount are server-validated snapshot values;
- session terminal timestamp and transaction creation agree;
- response is the committed authoritative outcome.

## Failure invariants

Any failure before commit leaves no persistent partial transaction/item and no
used-without-purchase session. Any failure after commit is reconciled by lookup;
retry must not repeat side effects. Cancellation/expiry cannot race into a second
valid purchase.

Consumption proves the platform physical confirmation flow, not payment settlement
or invoice issuance.
