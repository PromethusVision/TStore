# Backend Staff Revocation Model

**State:** PROPOSED

Revocation is a server-authoritative membership transition with immediate denial
for new privileged operations. Removing a UI menu, waiting for JWT expiry or
deleting a local session is insufficient.

## Contract

- record actor, membership, scope, reason, effective time and revision;
- invalidate/deny active merchant sessions or require a fresh membership lookup;
- stop Realtime/private subscriptions at the next authorization boundary;
- retries recheck authority before side effects;
- an already committed idempotent outcome may be returned but not re-executed;
- pending invites and delegated grants from the revoked member are reviewed;
- history retains the actor's membership snapshot.

Emergency revocation should be fast and reversible only through a new audited
grant. Exact token-revocation mechanism and grace period are implementation
decisions; recommendation is no grace for write capabilities.

