# W39 Reward Bar Contract

## Status

The Reward card is a presentation-only contract for the Product Owner-approved five-task cycle. It renders only when `enabled == true` and non-null `RewardProgressData` are both supplied. `CustomerHomeV1Content` keeps the runtime defaults `enabled: false` and `data: null`.

No reward economy, eligibility rule, persistence, service call, payout or production activation is included.

## Presentation data

| Field | Type | Presentation meaning |
| --- | --- | --- |
| `completedTasks` | `int` | Completed tasks, safely clamped to 0...5. |
| `rewardAmountText` | `String` | Backend/presentation-supplied reward destination or value; blank values fall back to “Ödül”. |
| `title` | `String` | Structural heading; defaults to “Görev yap, kazan”. |
| `subtitle` | `String?` | Optional compact supporting label. |
| `message` | `String?` | Optional longer presentation note. |

The total is intentionally fixed at five for this approved visual cycle. Derived presentation values expose safe completed count, remaining count, normalized progress and completion state. The fixed non-zero denominator prevents NaN/division errors.

## Visual states

- 0/5 shows the clear starting state and five remaining tasks.
- 1/5 through 4/5 show completed and remaining task counts explicitly.
- 5/5 uses the concise success copy “Ödülü kazandın” and completed segment treatment.
- The reward destination/value badge is present in every enabled state.
- Long reward values truncate visually within a bounded badge but remain complete in semantics.
- Subtitle and message are independently optional.

## Accessibility and resilience

- The card announces title, completed count, remaining/completed state, reward value, subtitle and message when present.
- Five task segments expose completed and remaining counts plus a `completed/total` semantic value.
- Long content is bounded without disabling system text scaling.
- The status row can wrap under narrow or scaled layouts.
- `onTap` is optional; without it the card is not announced as a button.

## Explicit non-contracts

- which actions count as tasks;
- final reward amount or currency conversion;
- earning formula, eligibility or campaign thresholds;
- coupon, wallet, funding, expiry or redemption;
- payout, settlement or accounting;
- abuse prevention or gamification engine;
- API, database, remote-config or analytics behavior.

## Fixture isolation

The illustrative `100 TL` amount is used only by tests and golden fixtures. Runtime Home supplies no fake reward data and keeps the feature OFF.

## Prerequisites before activation

1. Product owner approves task definitions, terminology and economics.
2. Backend defines authoritative completion/value/eligibility data.
3. Privacy, abuse, expiry and error contracts are approved.
4. Navigation, redemption and analytics destinations are specified.
5. Runtime feature gating and production tests are authorized in a later wave.

`REWARD_STRUCTURE_READY: YES`

`REWARD_ECONOMICS_IMPLEMENTED: NO`

`REWARD_BACKEND_IMPLEMENTED: NO`

`REWARD_RUNTIME_DEFAULT_ON: NO`

`REWARD_RUNTIME_FAKE_DATA: NO`
