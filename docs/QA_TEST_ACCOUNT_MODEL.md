# Test Account Model

**State:** PROPOSED — SYNTHETIC PRINCIPALS ONLY

| Principal | Purpose | Required scope | Forbidden shortcut |
|---|---|---|---|
| Customer | Auth/profile/cart/QR/review/chat | own data only; disposable run identity | changing role client-side |
| Merchant | own shop/listing/QR confirmation | active verified membership/shop scope | service-role session in app |
| Staff | capability and multi-shop negative cases | explicit membership/grant/revision | sharing merchant owner account |
| Operator | case/permission/audit tests | individual operator profile and assigned capability | shared super-admin login |

## Identity rules

- Synthetic email/name values use controlled non-personal domains and unique run IDs.
- Passwords are generated at runtime through a secret-safe mechanism and never committed, printed or requested in chat.
- One logical actor has one independent client/session; actor-switch tests sign out/revoke and prove local-state clearing.
- Merchant/operator status is established only by the authorized server-side fixture method in a non-Production environment.
- Test principals and their derived shops/listings/transactions are marked so analytics excludes them.

## Lifecycle

Create → verify intended role/scope → run bounded cases → revoke/session cleanup → dependency-aware account cleanup → residual-zero report. When cleanup is unsafe or unavailable, stop creating additional accounts and escalate.

`REAL_CUSTOMER_ACCOUNT_USED_FOR_TEST: NO`

`OWNER_DECISION_REQUIRED: TEST_ACCOUNT_EMAIL_PROVIDER_AND_RETENTION`
