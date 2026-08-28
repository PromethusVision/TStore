# Backend Service-Role Boundary

**State:** NON-NEGOTIABLE SECURITY CONTRACT

Service-role or equivalent server/admin credentials bypass ordinary client RLS and
therefore never belong in Flutter source, assets, `dart-define`, public CI logs,
browser storage, QR payload, analytics, crash reports or downloadable bundles.

## Permitted environment

- trusted server/operations runtime with managed secret injection;
- minimum project/environment scope and separate Development/Production values;
- no interactive sharing or repository persistence;
- access logged, rotated and revocable;
- purpose-specific server action still validates application authorization.

Possessing a service credential does not authorize generic business mutation. A
trusted worker/admin API uses narrow commands, exact subject, policy/version,
idempotency and audit. Prefer database functions/RLS-compatible server principals
when they can express the task without broad bypass.

## Incident posture

Suspected client/log exposure is P0: stop affected automation, revoke/rotate through
authorized secret management, inspect access/audit and notify security owner. Do
not print the value while diagnosing. Secret scanners test patterns and forbidden
client initialization without reading unrelated `.env` values.
