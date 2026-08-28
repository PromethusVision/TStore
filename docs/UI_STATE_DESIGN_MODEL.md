# UI State Design Model

## State families

| Family | Required variants | Core rule |
|---|---|---|
| Data load | initial, loading, refresh, pagination | Keep context on refresh; avoid full-screen reset |
| Result | success, empty, partial | Empty explains next useful action |
| Failure | retryable, offline, permission, auth, terminal | Copy and action match actual recovery |
| Action | idle, submitting, success, error, disabled | Prevent duplicate action and preserve input |
| Commerce | available, low stock, unavailable, price changed | Never infer payment/order semantics |
| Trust | verified, unverified/absent, reported/moderated where supported | Only authoritative state receives badge |
| Identity | guest, authenticating, authenticated, expired | AuthGuard continuation stays explicit |
| Media | loading, loaded, absent, invalid | Stable aspect ratio and safe fallback |
| Realtime | connecting, live, reconnecting, stale/offline | Do not duplicate messages/notifications |

## Shared state-shell anatomy

1. Optional icon/illustration with decorative semantics.
2. Concise Turkish title.
3. Supporting explanation proportional to risk.
4. One primary recovery/next action.
5. Optional secondary action only if materially distinct.
6. Stable layout that does not jump between loading and result unnecessarily.

## Loading and skeleton policy

- Skeleton shape should approximate real content and preserve layout rhythm.
- Do not shimmer large full-screen areas indefinitely.
- Respect reduced motion; static neutral placeholders are acceptable.
- Pull-to-refresh keeps existing data visible when safe.
- Pagination loading belongs at list end and must not obscure existing results.
- Button loading retains width, disables duplicate submission and announces state.

## Empty-state policy

Empty is not an error. Examples:

- no search results: refine query/category and preserve entered query;
- no nearby result: explain location/radius/data availability without blaming user;
- empty wishlist/cart/recent: return to discovery;
- no chat/notification/purchase: explain when records will appear;
- no shop products: preserve shop identity and physical actions.

## Error-state policy

- Network/retry errors preserve prior data where possible.
- Permission denial links to the correct setting or alternate path.
- Auth-required state explains why login is needed and supports cancel.
- QR/review errors do not imply a verified purchase was created.
- Destructive errors preserve user data and provide a safe retry/contact path.
- Raw exception, RPC, table or developer text is never customer-visible.

## Dialog, bottom-sheet and snackbar usage

| Surface | Use for | Avoid |
|---|---|---|
| Dialog | irreversible/high-consequence confirmation, concise blocking decision | Long forms, routine info |
| Bottom sheet | contextual choice, filter, Cart/QR session with mobile-friendly steps | Critical content with hidden dismiss behavior |
| Snackbar | transient confirmation or recoverable non-blocking error | Legal, auth, purchase or destructive explanation |
| Inline state | field/list/section-specific feedback | Global app failures |

## Functional invariants

Visual states cannot change state-machine ownership. Cubits/repositories/auth/QR
remain authoritative. A component may emit a callback once; it may not synthesize
success, verified purchase, availability, unread or review eligibility.
