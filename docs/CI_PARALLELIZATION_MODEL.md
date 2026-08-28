# CI Parallelization Model

State: PROPOSED — OWNER REVIEW REQUIRED

Parallelization is introduced after timing data identifies independent bottlenecks.

## Safe candidates

- analyzer/static checks versus unit/widget tests;
- deterministic test shards with stable manifests;
- Android compile and iOS static/native validation;
- domain contract suites using isolated databases/accounts.

Jobs must not share mutable fixtures, remote accounts, output paths, caches with write races, or migration databases. Results aggregate by exact commit, and all required shards must report. Live Development and physical tests remain serialized where collision or rate limits exist.

Recommendation: start with coarse jobs, then shard the longest stable suite only when queue/runtime savings exceed orchestration cost.

OWNER_DECISION_REQUIRED: choose target feedback time after baseline CI runs.
