# Customer App Review Closeout Audit

Status: PASS — canonical backend contract preserved

## Frozen rules

- Only a QR merchant-confirmed verified purchase creates review evidence.
- One active review per customer/product lifetime.
- Repeat purchases and quantity do not create additional review rights.
- Edit/delete/recreate operate against immutable verified evidence.
- Legacy unverified orders/reviews are excluded from customer aggregates and eligibility.
- Client writes use canonical review RPCs; no direct table mutation path is authorized.

## Client regression results

| Flow | Result |
| --- | --- |
| Aggregate and paginated list | Loading/error/retry/append states covered; stale refresh cannot overwrite newer state. |
| Guest | Login path then eligibility refresh. |
| Authenticated but unverified | Form hidden; explicit verified-purchase requirement. |
| Verified create | Rating/title/comment validated and sent through RPC. |
| Duplicate submit | Second action suppressed; idempotent `created=false` refreshes current review without false error. |
| Update | Own review fields populate and update through RPC. |
| Delete | Explicit confirmation; canonical RPC; eligibility refresh supports recreate. |
| Backend rejection | Wrong product, invalid rating, unverified state, and unsafe exceptions map to safe messages. |
| Review image | Storage/UI contract is deferred and not presented as active. |

Architecture tests prevent direct review-table writes and enforce the canonical RPC/function names. No backend/schema/policy change was made.

`REVIEW_CLOSEOUT_AUDIT: PASS`
`VERIFIED_PURCHASE_CONTRACT_PRESERVED: YES`
`BACKEND_CHANGED: NO`
