# RLS Test Strategy

**State:** PROPOSED — NO SQL EXECUTION

## Actor matrix

| Actor | Positive scope | Mandatory negative scope |
|---|---|---|
| Anon | explicitly public active catalog/shop/media reads | profiles, carts, QR state, reviews mutation, chat, notifications |
| Customer | own profile/cart/wishlist/location/chat/review operations | another customer, merchant/admin role, merchant writes |
| Merchant | future own organization/shop/listing/QR capabilities | other merchant/shop, canonical product authority, customer private data |
| Staff | explicitly granted shop capability | unassigned shop, expired/revoked membership, role grant |
| Operator | case/purpose/capability-scoped server command | direct broad table access, unrelated PII, root policy without authority |

## Method

- Test table grants and RLS policies separately for `SELECT/INSERT/UPDATE/DELETE`.
- Use independent authenticated clients; never simulate another actor by changing a client-side role field.
- Assert allowed row set and denied side effects, not only error presence.
- Cover absent JWT, expired session, wrong tenant, inactive shop, deleted membership and policy transition.
- Test Storage object access and Realtime visibility as separate policy surfaces.
- Confirm security-definer functions have fixed search paths and perform their own authorization.
- Record policy name/version and migration revision with the result.

## Environment order

Static SQL checks → disposable local Supabase/Postgres actor matrix → isolated Development regression. Production remains read-only unless an explicit controlled acceptance authorizes synthetic principals.

## Failure rule

Any unexpected cross-subject or cross-shop success is P0. An unexpected denial is a release blocker for the affected critical journey but never justification to broaden policy without review.

`RLS_TEST_AUTOMATION_IMPLEMENTED: NO`
