# Gamification Dark-Pattern Audit

**State:** PROPOSED SAFETY GATE — NOT OWNER APPROVED

## Non-negotiable boundary

Reward and gamification must help customers understand earned value and local-commerce discovery. They must not manufacture urgency, shame inactivity, exploit loss aversion or turn purchase frequency into social worth.

## Audit registry

| Pattern | Risk | Required boundary | Severity |
|---|---|---|---|
| Forced spending | A badge, level or benefit requires unnecessary purchases | Participation optional; non-economic alternatives where appropriate; no essential feature gate | P0 |
| Loss-aversion abuse | Progress is threatened without a fair, disclosed rule | No surprise reset; approved expiry disclosed before earning and before loss | P0 |
| Manipulative countdown | Artificial timer pressures a purchase | Countdown only for a real, auditable deadline; never reset deceptively | P0 |
| Artificial scarcity | Fake limited rewards create urgency | Inventory/cap must be authoritative, truthful and explainable | P0 |
| Punishing inactivity | Streak loss or public downgrade shames a customer | No purchase streak recommendation; inactivity cannot reduce customer dignity/access | P0 |
| Social-pressure mechanics | Public ranks expose spend or compare customers | No public spend leaderboard or punitive customer score | P0 |
| Obscured economics | Points appear cash-like without defined value/liability | Plain value, funding, redemption and expiry terms before issuance | P0 |
| Near-threshold spam | Repeated prompts exploit completion bias | Frequency caps, opt-out and quiet hours; no sensitive-product prompts | P1 |
| Paid reputation | Merchant can purchase a trust badge | Ads and reputation ledgers separated; spend excluded as evidence | P0 |
| Review coercion | Reward depends on positive rating/review | Never condition reward on sentiment; review eligibility/value independent | P0 |
| Hidden reversal | Correction removes value without trace or appeal | Linked immutable reversal, notice and dispute route | P1 |
| Sensitive inference | Badge reveals health, alcohol, infant-care or intimate purchases | Fail closed and never publicly derive such badges | P0 |

## Feature posture

- **Streaks:** recommend `DEFER/DO_NOT_USE_FOR_PURCHASES`.
- **Levels:** not needed for pilot; risk of social ranking exceeds demonstrated value.
- **Challenges:** post-pilot only, with discovery-oriented and non-spend alternatives; no unnecessary-purchase requirement.
- **Badges:** possible post-pilot only when evidence, explainability, privacy and revocation gates pass.
- **Economic rewards:** post-pilot recommendation until funding, liability, policy and disputes are owned operationally.

## Pre-release tests

Every surface must pass plain-language comprehension, accessibility, expiry/funding disclosure, frequency control, privacy inference, correction and independent-rating checks. A failed P0 pattern blocks that surface rather than being accepted as a conversion tradeoff.

