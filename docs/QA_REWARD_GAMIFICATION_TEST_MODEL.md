# Reward / Gamification Test Model

**State:** PROPOSED — FEATURE RUNTIME DEFERRED

## Core properties

- Only approved server-authoritative evidence may produce a ledger evaluation.
- Source event + rule version + subject defines idempotency; replay/retry does not duplicate value.
- Same key with different payload conflicts and is audited.
- `EARN/ADJUST/REVERSE/REDEEM/EXPIRE` is immutable lineage; balance is derived.
- Purchase confirmation never rolls back because downstream reward evaluation fails.
- Review right/content/rating is independent from reward outcome.
- Ads impression/click/spend is not reward, reputation or verified-purchase evidence.
- Fraud signal creates hold/review, not an opaque punitive score.

## Test layers

| Layer | Focus |
|---|---|
| Domain | rule version, thresholds, expiry options and derived balance |
| Ledger/database | uniqueness, concurrency, correction lineage and non-negative invariants if approved |
| Event | authority class, ordering, duplicate delivery and backfill |
| Client | transparent pending/earned/reversed explanation; no dark pattern |
| Abuse | account cycling, replay, collusion, mass events and appeal |
| Decoupling | identical review/organic/ad outcomes regardless of reward state |

## Current gate

Wave 18 is owner-review architecture only; funding, redemption, unit, expiry and V1 launch remain open. Tests must not encode one option as final.

`REWARD_TEST_MODEL_READY: DESIGN_ONLY`
