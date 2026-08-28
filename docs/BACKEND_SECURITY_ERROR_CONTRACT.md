# Backend Security Error Contract

**State:** PROPOSED CLIENT-SAFE CONTRACT

Security failures return stable bounded categories, an optional safe field/action
hint and correlation ID. They never expose SQL, policy names, stack traces, token
validity internals, another subject's existence or abuse thresholds.

| Category | Client behavior | Internal behavior |
|---|---|---|
| `AUTHENTICATION_REQUIRED` | offer login/session recovery | record bounded auth reason |
| `NOT_AUTHORIZED` | generic permission message | capability/scope denial audit where needed |
| `RESOURCE_NOT_AVAILABLE` | safe absent/unavailable state | distinguish missing vs hidden internally |
| `CONFLICT_STALE_STATE` | refresh/review changes | revision/idempotency details internally |
| `INVALID_REQUEST` | correct allowed field | validation reason without raw payload |
| `RATE_LIMITED` | bounded retry guidance | protected limiter/anomaly context |
| `TERMINAL_STATE` | show expired/used/cancelled-safe outcome | exact transition evidence restricted |
| `TEMPORARILY_UNAVAILABLE` | retry/reconcile | observability correlation |

Wrong-shop/QR replay may use product-safe specific wording only for an already
authorized verifier; unauthenticated probing receives a non-enumerating result.
Fraud suspicion, watchlists and internal policy logic are never sent to clients.
