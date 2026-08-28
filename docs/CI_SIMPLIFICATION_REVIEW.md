# CI Simplification Review

**State:** PROPOSED — NO WORKFLOW CREATED

## Minimal useful jobs

1. static/format/diff/analyzer;
2. deterministic Flutter tests;
3. secret/dependency scan;
4. migration static/ephemeral contract when tooling exists;
5. Android compile contract.

Use clean checkout, pinned actions, read-only PR permissions and no secrets for untrusted code. Full regression can run on main and risk-selected PRs.

## Do not add yet

- many shards before timing evidence;
- nightly suites without change volume;
- self-hosted runners/device cloud;
- broad caches with weak trust separation;
- macOS CI before iOS pilot decision;
- automatic signing/store/Production migration;
- dashboards measuring vanity counts.

Manual protected release remains safer initially because signing, devices, store roles and Production require human authority. CI should remove repetition, not manufacture release permission.
