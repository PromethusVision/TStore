# Backend Rollback Strategy

**State:** PROPOSED — PREFER FORWARD-COMPATIBLE RECOVERY

Rollback is defined per deployment layer:

- **app/server:** redeploy previous compatible version while additive schema stays;
- **read cutover:** switch compatibility facade/read flag to old projection;
- **write cutover:** stop writer, reconcile, then select one authority—never let two
  versions continue diverging;
- **data backfill:** stop future batches; correct by idempotent forward operation;
- **constraint/index:** remove only when exact lock/dependency safety is proven;
- **domain fact/ledger:** append correction/reversal; never delete history;
- **destructive schema:** cannot rely on rollback; requires backup restore/forward
  fix plan before authorization.

Rollback must not re-enable a security vulnerability, accept weaker authorization
or make new-client writes unreadable. Define trigger, decision owner, maximum time,
data-loss expectation, client compatibility, audit and post-rollback reconciliation.
Production rollback remains a separately authorized operational action.

