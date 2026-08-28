# Release Branch Strategy

State: PROPOSED — OWNER REVIEW REQUIRED

The current permanent-agent worktree model should continue to use task branches and integration through `origin/main`. A standing release branch is not justified until parallel maintenance of a shipped version becomes real.

## Recommended lean model

1. feature/task branches merge through reviewed integration;
2. a release candidate is an immutable tag or recorded main commit;
3. freeze applies to that commit lineage;
4. a hotfix branches from the exact shipped commit when main has moved materially;
5. fixes return to main without force push or history rewrite.

A long-lived release branch adds cherry-pick drift, duplicate fixes, and ownership overhead. Introduce one only when store review latency or supported-version maintenance requires it.

OWNER_DECISION_REQUIRED: approve tag/commit-only releases now or authorize a future maintained release branch when objective triggers occur.
