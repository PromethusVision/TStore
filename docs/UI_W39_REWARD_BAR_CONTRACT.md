# W39 Reward Bar Contract

## Status

The Reward Bar is a presentation contract only. Its visual structure is ready for later product and backend work, but Wave 39A implements no reward economy, calculation, eligibility rule, persistence, service call, navigation destination or production content.

Runtime defaults to hidden:

```dart
RewardProgressSlot(
  enabled: false,
  data: null,
)
```

The component renders only when both `enabled == true` and non-null `RewardProgressData` are supplied. `CustomerHomeV1Content` preserves those same defaults, so the production Home does not show a Reward Bar in W39A.

## Presentation data

`RewardProgressData` exposes only:

| Field | Type | Presentation meaning |
| --- | --- | --- |
| `progress` | `double` | Normalized visual progress. Safely clamped to `0...1`; non-finite values become `0`. |
| `title` | `String` | Human-readable structural title. |
| `currentMilestone` | `String?` | Optional current-state label. |
| `nextMilestone` | `String?` | Optional next-state label. |
| `contextualMessage` | `String?` | Optional supporting explanation. |

`onTap` is optional. When absent, the card is not announced or styled as an action. W39A does not assign a destination.

## Explicit non-contracts

The following are intentionally absent and must not be inferred from the component:

- points, currency or Turkish-lira conversion;
- earning formula, threshold, tier or campaign economics;
- coupon, discount, expiry or redemption behavior;
- merchant funding or settlement;
- customer eligibility, fraud controls or gamification engine;
- API, database table, remote-config key or analytics event;
- production copy or fabricated customer reward values.

## Accessibility and resilience

- The progress indicator exposes a Turkish percentage semantic label/value.
- Long title and supporting text are bounded without layout overflow.
- Current and next labels are optional independently.
- Progress fixtures cover `0`, near-zero, midpoint, near-complete and complete states.
- Negative, greater-than-one, `NaN` and infinite values fail safely.
- The leading visual occupies a 44 px target-sized area and any interactive card surface follows the supplied callback only.

## Fixture isolation

The only enabled example is the local golden-test scenario in `test/widget/shop/w39a_home_visual_review_golden_test.dart`. It is test fixture data, is not reachable by the runtime Home and carries no product/economic claim.

## Prerequisites before activation

1. Product owner approves terminology, customer value and economics.
2. Backend contract defines an authoritative normalized progress source and eligibility behavior.
3. Privacy, abuse, expiry and error/empty/loading contracts are approved.
4. Navigation and analytics destinations are specified.
5. Runtime feature gating and production tests are added in a separate authorized wave.

`REWARD_STRUCTURE_READY: YES`

`REWARD_ECONOMICS_IMPLEMENTED: NO`

`REWARD_BACKEND_IMPLEMENTED: NO`

`REWARD_RUNTIME_DEFAULT_ON: NO`

`REWARD_RUNTIME_FAKE_DATA: NO`
