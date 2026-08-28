# Test Sharding Options

**State:** ANALYSIS — NOT CURRENTLY JUSTIFIED BY MEASUREMENT

| Option | Shape | Benefit | Risk |
|---|---|---|---|
| No sharding | one full Flutter job | simplest totals and logs | longer feedback |
| Type shards | unit / widget / architecture-contract | clear ownership and stable split | uneven widget shard |
| Feature shards | Auth/Cart/Shop/etc. | targeted diagnosis | shared-test duplication and maintenance |
| Duration-balanced manifest | measured files distributed by runtime | fastest balanced execution | generated manifest drift/complexity |

## Recommendation

Start unsharded. Capture per-file duration on representative clean/cached runs. Shard only when PR feedback or runner limit is materially problematic. First split static+unit from widget; keep a final aggregation gate that detects missing/duplicate files.

## Integrity requirements

- Every tracked non-live test appears exactly once in the shard manifest.
- New files fail or enter a default catch-all; they never disappear silently.
- Skip totals and failures reconcile across shards.
- Shards share no mutable remote fixture.
- Retry applies to failed tests, not an entire flaky shard indefinitely.

`TEST_SHARDING_ENABLED: NO`

`OWNER_DECISION_REQUIRED: SHARDING_THRESHOLD_AFTER_BASELINE`
