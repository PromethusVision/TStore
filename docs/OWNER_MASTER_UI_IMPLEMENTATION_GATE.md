# Owner Master Customer UI Implementation Gate

State: `8/8 OWNER DECISIONS FINAL — RUNTIME AND EVIDENCE GATES OPEN`

Wave 29'un sekiz implementation blocker'ı korunmuştur. AuthGuard ve final
acceptance evidence zaten global köklerin içindedir; ikinci kez sorulmaz.

Product Owner finalized every gate direction as option A on 2026-08-29.

## Gate registry

| Order | Wave 29 decision | Master root | Final | Canonical direction | Still blocks |
|---:|---|---|---|---|---|
| 1 | UI-R01 | OM-R19 | A | Teal/green primary, terracotta accent | runtime tokens/components |
| 2 | UI-R02 | OM-R20 | A | Consistent light-only pilot | theme cleanup/acceptance |
| 3 | UI-R03 | OM-R21 | A | Current direction + bounded C1 corrections | screen implementation/evidence |
| 4 | UI-R06 | OM-R05 | A | Contextual explanation, then existing login | AuthGuard implementation; KVKK open |
| 5 | UI-R04 | OM-R22 | A | Physical visit/directions primary | Shop Details implementation |
| 6 | UI-R05 | OM-R23 | A | Physical-shopping preparation, not checkout | Cart/QR implementation |
| 7 | UI-R07 | OM-R24 | A | Balanced two-line local-context cards | cards/grids/lists implementation |
| 8 | UI-R15 | OM-R04 | A | Immutable frames + exact artifact + physical checks | evidence not executed |

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

The owner-decision portion is closed. The UI implementation/evidence gate closes
only after the selected direction is implemented, immutable reference frames are
recorded and exact-artifact physical evidence passes. This document does not mark
those checks PASS.

`UI_BLOCKER_DECISIONS: 8`

`UI_DECISIONS_DUPLICATED_IN_GLOBAL_QUEUE: 0`

`CUSTOMER_UI_OWNER_DECISIONS: CLOSED`

`CUSTOMER_UI_RUNTIME_EVIDENCE_GATE: OPEN`
