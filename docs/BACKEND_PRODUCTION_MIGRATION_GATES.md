# Backend Production Migration Gates

**State:** PROPOSED — PRODUCTION APPLY REQUIRES SEPARATE EXPLICIT AUTHORIZATION

## Mandatory gates

- exact Production name/ref/URL independently verified; Development excluded;
- single designated migration author and single-writer change window;
- tracked artifact hash equals reviewed Development/clean-room artifact;
- fresh schema/ledger/data/dependency/collision baseline;
- backup and tested restore/forward-recovery appropriate to risk;
- runtime/lock/space estimates and stop thresholds;
- RLS/RPC/grant/client compatibility and security scans PASS;
- backfill/ambiguity/reconciliation and rollback plan approved;
- monitoring dashboard/queries and accountable stop/rollback owners ready;
- no unrelated remote writes or source edits during apply.

On drift, collision, identity ambiguity, unexpected user/business data, backup gap
or partial failure: STOP. Do not patch SQL ad hoc, force insert, run cleanup or
rewrite migration history. After apparent success, authoritative postflight and
customer/merchant smoke are required before PASS.

Committing this plan or a future migration file never authorizes Production apply.
