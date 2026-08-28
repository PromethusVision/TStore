# Owner Master Customer UI Implementation Gate

State: `8 BLOCKING DECISIONS — NO ANSWER SELECTED`

Wave 29'un sekiz implementation blocker'ı korunmuştur. AuthGuard ve final
acceptance evidence zaten global köklerin içindedir; ikinci kez sorulmaz.

## Gate registry

| Order | Wave 29 decision | Master root | Question | Non-final recommendation | Blocks |
|---:|---|---|---|---|---|
| 1 | UI-R01 | OM-R19 | Semantic palette rolleri? | Teal/green primary, terracotta accent | all UI tokens/components |
| 2 | UI-R02 | OM-R20 | Pilot dark mode kapsamı? | Consistent light-only pilot | theme acceptance matrix |
| 3 | UI-R03 | OM-R21 | Critical screen direction? | Current direction + bounded C1 corrections | Home/listing/product/seller |
| 4 | UI-R06 | OM-R05 | Guest protected-action AuthGuard? | Contextual explanation, then existing login | protected journeys/navigation |
| 5 | UI-R04 | OM-R22 | Shop Details primary CTA? | Physical visit/directions primary | Shop Details hierarchy |
| 6 | UI-R05 | OM-R23 | Cart V2 product meaning? | Physical-shopping preparation, not checkout | Cart/QR education |
| 7 | UI-R07 | OM-R24 | 390 px card density? | Balanced two-line local-context cards | cards/grids/lists |
| 8 | UI-R15 | OM-R04 | Final acceptance evidence? | Immutable frames + exact artifact + physical checks | UI rollout acceptance |

## Why two decisions map to existing global roots

- UI-R06 is the presentation consequence of `OM-R05` guest/auth/location
  policy. Asking it separately could create contradictory access behavior.
- UI-R15 is the visual evidence portion of `OM-R04` exact-artifact release
  acceptance. A design screenshot cannot certify a different build.

Both remain explicit gate rows and retain their Wave 29 source IDs.

## Staged, dependent or engineering decisions

| Wave 29 | Treatment | Parent |
|---|---|---|
| UI-R08 fallback/icon style | dependent; apply after palette/critical direction | OM-R19, OM-R21 |
| UI-R09 motion | engineering safe default; reduced motion honored | OM-R21 |
| UI-R10 Turkish tone | dependent content pass | OM-R21 |
| UI-R11 trust/future signals | dependent; do not imply unavailable features | OM-R21 |
| UI-R12 visual deferment | staged scope decision inside critical direction | OM-R21 |
| UI-R13 tablet behavior | engineering baseline; full tablet polish can defer | OM-R21 |
| UI-R14 Customer/Merchant sharing | engineering architecture after merchant model | OM-R11 |

## Gate close rule

The UI gate closes only when all eight owner answers are recorded and the
selected direction has immutable reference frames plus exact-artifact physical
evidence. This document does not mark those checks PASS.

`UI_BLOCKER_DECISIONS: 8`

`UI_DECISIONS_DUPLICATED_IN_GLOBAL_QUEUE: 0`

`CUSTOMER_UI_IMPLEMENTATION_GATE: OPEN`

