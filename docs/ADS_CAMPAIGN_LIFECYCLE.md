# Sponsored Campaign Lifecycle

**State:** PROPOSED STATE MACHINE — NO DATABASE IMPLEMENTATION

## States

| State | Can edit? | Can serve? | Meaning |
|---|:---:|:---:|---|
| `DRAFT` | Yes | No | Merchant prepares target, geo, budget and schedule |
| `PENDING_REVIEW` | Limited/cancel | No | Submitted revision awaits automated/human checks |
| `ACTIVE` | Via revision | Yes, if all serve-time gates pass | Approved and inside time/budget window |
| `PAUSED` | Yes | No | Merchant/platform reversible stop |
| `BUDGET_EXHAUSTED` | Budget only | No | Daily/total available amount exhausted |
| `ENDED` | No normal edit | No | Schedule completed or merchant ended campaign |
| `REJECTED` | New revision/appeal | No | Review rejected requested campaign scope/content |
| `POLICY_BLOCKED` | Restricted | No | Current policy/evidence blocks serving |

Eligibility can suppress an `ACTIVE` campaign without rewriting its lifecycle. A
campaign is served only when lifecycle **and** target/shop/listing/policy/budget
checks pass.

## Proposed transitions

- `DRAFT -> PENDING_REVIEW` on idempotent submit;
- `PENDING_REVIEW -> ACTIVE` only from server-authoritative approval and valid
  schedule/funding;
- `PENDING_REVIEW -> REJECTED/POLICY_BLOCKED` with reason;
- `ACTIVE <-> PAUSED` with actor/reason/history;
- `ACTIVE -> BUDGET_EXHAUSTED` atomically at cap;
- `BUDGET_EXHAUSTED -> ACTIVE` only after valid daily reset or approved budget
  revision, never by client clock;
- active/non-serving states -> `ENDED` when schedule/merchant termination applies;
- policy update may move any otherwise serving state to `POLICY_BLOCKED`;
- material edit creates a revision and can return to `PENDING_REVIEW`.

## History rules

- immutable campaign ID survives pause/resume and ordinary edits;
- every transition records actor, source, reason, effective time and revision;
- rejected/blocked history is retained and not overwritten by later approval;
- deleted listing/shop does not delete campaign history;
- retry/duplicate callbacks are idempotent;
- client cannot directly write `ACTIVE`, approval or spent state.

`CAMPAIGN_STATE_MACHINE: READY_FOR_OWNER_REVIEW`

`CLIENT_ACTIVATES_CAMPAIGN_DIRECTLY: NO`

`HISTORY_PRESERVED: YES`
