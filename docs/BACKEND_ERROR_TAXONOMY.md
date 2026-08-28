# Backend Error Taxonomy

**State:** PROPOSED STABLE CLIENT CONCEPTS

| Error concept | Retry? | Expected client action |
|---|---|---|
| `AUTHENTICATION_REQUIRED` | after login/refresh | authenticate safely |
| `SESSION_EXPIRED` | after refresh/relogin | clear private state and re-authenticate |
| `NOT_AUTHORIZED` | no | show bounded permission message |
| `RESOURCE_NOT_AVAILABLE` | no/refresh | safe absent or unavailable state |
| `INVALID_REQUEST` | after correction | highlight allowed field |
| `POLICY_BLOCKED` | no, appeal if offered | show safe policy reason class |
| `CONFLICT_STALE_STATE` | refresh/intentional retry | reload current revision |
| `IDEMPOTENCY_CONFLICT` | no with same key | create new logical request after review |
| `TERMINAL_EXPIRED/CANCELLED/USED` | no | terminal QR/cart/campaign state |
| `RATE_LIMITED` | bounded delay | respect retry guidance |
| `TEMPORARILY_UNAVAILABLE` | yes | bounded retry/reconcile |
| `UNSUPPORTED_CLIENT/CONTRACT` | after upgrade | update or capability fallback |

Each response includes stable code, safe localized message key/details, optional
field/retry/correlation and contract version. It excludes raw SQL, stack, policy
internals, another subject's existence and abuse signals. Domain success-with-
original-result is not mislabeled as duplicate failure.
