# Backend User Switch Safety

**State:** REQUIRED CLIENT/SERVER CONTRACT — NO RUNTIME CHANGE

When sign-out, account deletion or account switch occurs, private state from the
prior principal must not appear, mutate or subscribe under the next principal.

## Server rules

- every request resolves the current authenticated subject server-side;
- owner IDs in payload/query never substitute for the subject;
- Realtime authorization is re-evaluated; old channels cannot retain access;
- idempotency keys are subject-scoped and cannot replay across users;
- signed media/session links have bounded scope and lifetime;
- account deletion/revocation blocks new mutations immediately.

## Client obligations

Cancel subscriptions/in-flight requests, clear private repositories/caches and
discard late responses using session generation/revision. Then establish the new
session and reload. Shared public catalog cache may remain only if it contains no
personalization or private joins.

Automated tests should cover A→logout→B, A late response after B login, refresh
token failure, deleted account and background/resume. No fallback to the previous
user's cached identity is allowed.

