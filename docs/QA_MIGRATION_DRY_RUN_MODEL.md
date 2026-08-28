# Migration Dry-Run Model

State: PROPOSED — OWNER REVIEW REQUIRED

## Sequence

1. create isolated local/ephemeral database at the representative predecessor schema;
2. load sanitized deterministic fixtures and boundary-scale data;
3. capture precheck invariants and timing;
4. apply the exact migration chain using the intended tool version;
5. run postchecks, RLS/RPC/contracts, concurrency, and client compatibility;
6. rehearse interruption/retry and supported rollback or forward-fix;
7. repeat in exact Development project only after authorization;
8. archive non-secret evidence and clean fixtures.

Production snapshots must not enter developer machines or CI. A dry run that differs in migration bytes, baseline, extensions, or environment is not equivalent evidence.

No remote execution is performed by this foundation.

OWNER_DECISION_REQUIRED: select ephemeral environment provider and representative dataset sizes.
