# EsnaftaVar Esenler Pilot — Exact-Artifact Go/No-Go

**State:** `CHECKLIST — NO ARTIFACT APPROVED`

## Artifact identity

Record app/platform, semantic version/build, Git commit/tree, environment, package/
flavor/entrypoint, signing certificate public identity, binary hash, build toolchain,
Production backend compatibility, enabled feature flags, test evidence IDs and
store/test track.

## GO requires all

- exact Production project/environment verified; no Development fallback;
- approved client-safe configuration and no secret/service-role credential;
- required migration/RLS/RPC/storage/auth/realtime state validated by authorized
  release process;
- exact artifact automated and physical acceptance passed;
- selected merchant roster, density, catalog truth and QR cohort ready;
- support/monitoring/incident/rollback owners staffed;
- legal/privacy/policy/store gates for actual scope complete;
- acquisition message and cohort match the declared area/features;
- no open P0 and every accepted lower risk is explicit/time-bounded.

## NO-GO if any

Unknown artifact/environment/signing, missing rollback, cross-shop/role risk,
duplicate/wrong-shop QR, unavailable P0 owner, misleading catalog/coverage,
unapproved regulated domain, unresolved critical auth/deletion/privacy issue or
unreconciled Production state.

## Decision record

`decision_id, timestamp, artifact_id/hash, scope/cohort, gate results, open risks,
approvers by role, rollback/pause owner, expiry/review time`.

`EXACT_ARTIFACT_GO: NO`
