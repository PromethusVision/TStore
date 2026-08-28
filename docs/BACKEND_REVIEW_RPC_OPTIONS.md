# Backend Review RPC Options

**State:** PRESERVE CURRENT VERIFIED-EVIDENCE RPCS

Current read/list, eligibility, submit, update and delete RPCs form the recommended
security facade. Direct review mutation stays revoked.

## Evolution options

- add explicit request idempotency and expected review revision;
- return committed review plus aggregate revision/freshness;
- keep customer-visible validation reasons bounded;
- separate customer delete from operator moderation/reporting;
- add cursor/version compatibility without replacing existing callers abruptly;
- reconcile product lineage only through governed mapping.

A generic upsert is not recommended because create, update and recreate have
different evidence/concurrency semantics. Review image/media is a separate future
contract and must not broaden review mutation grants.

Delete/restore retention and merge-collision responses remain
`OWNER_DECISION_REQUIRED`.

