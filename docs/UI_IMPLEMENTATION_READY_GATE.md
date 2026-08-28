# UI Implementation Ready Gate

## Current verdict

`READY_TO_START_UI_IMPLEMENTATION: CONDITIONAL`

No Flutter visual implementation starts in Wave 29. “Conditional” means the
prepared architecture can start after the prerequisite owner answers and evidence
checks below; it does not mean any recommendation is already accepted.

## Decisions required before visible Flutter rollout

These eight decisions must be answered first, in this order:

| ORDER | ROOT_ID | REQUIRED BECAUSE |
|---:|---|---|
| 1 | UI-R01 | Final semantic color roles cannot be inferred safely |
| 2 | UI-R02 | Supported theme modes determine every component acceptance matrix |
| 3 | UI-R03 | Home/listing/product direction must be current and C1-reviewed |
| 4 | UI-R06 | AuthGuard is part of foundation/navigation rollout |
| 5 | UI-R04 | Shop CTA hierarchy closes the physical-visit journey |
| 6 | UI-R05 | Cart V2 must not acquire checkout meaning |
| 7 | UI-R07 | Card density fixes Home/listing component geometry |
| 8 | UI-R15 | Acceptance evidence must be defined before baselines are created |

Additional precondition: all six C1 rows must have a current evidence verdict;
OPEN/UNCLEAR rows affecting the selected critical direction require resolution or
an explicit bounded revision plan.

## Staged decisions that can follow initial foundation work

| ROOT_ID | LATEST SAFE POINT |
|---|---|
| UI-R08 | Before Home/product media components are accepted |
| UI-R10 | Before critical-screen copy/golden freeze |
| UI-R11 | Before reviews/purchases/trust wave |
| UI-R12 | Before Wave 9/10 and pilot deferment ledger freeze |

## Decisions safe to defer beyond initial pilot implementation start

| ROOT_ID | SAFE DEFAULT WHILE WAITING | LIMIT |
|---|---|---|
| UI-R09 | Restrained functional motion only | Reduced-motion and clear feedback remain mandatory |
| UI-R13 | Safe centered/max-width behavior | No uncontrolled stretch |
| UI-R14 | Shared tokens/primitives; role-specific screens | Do not redesign Merchant App in Customer rollout |

These three may wait for explicit owner confirmation without blocking Wave 1, but
their recommendations are not final decisions.

## Work unlocked immediately after prerequisites

1. Create semantic Flutter token/theme extensions in visual-parity mode.
2. Add token, theme-mode, contrast and responsive acceptance fixtures.
3. Implement behavior-neutral Button, TextField, StateShell and ScreenShell APIs.
4. Implement BottomNav/AuthGuard presentation while preserving current navigation.
5. Prepare immutable screenshot/golden manifest for approved critical frames.
6. Start Home only after foundation interfaces pass and UI-R03/C1 evidence is ready.

## Work still prohibited by this gate

- Runtime/product behavior changes.
- Auth, Cart V2, QR, review, search, location or wishlist logic changes.
- Taxonomy runtime or fixed proposed category nodes.
- Ads/Reward/Gamification activation.
- Figma mutation without a separately authorized task.
- Owner decisions being inferred from recommended defaults.

## Gate checklist

| CHECK | CURRENT STATE |
|---|---|
| 15/15 roots represented | PASS |
| Required first-eight owner answers | NOT YET ANSWERED |
| C1 current evidence | 0 closed / 3 open / 3 unclear |
| Flutter/Figma implementation | NOT STARTED |
| Architecture/apply map | READY |
| Product Owner finalization in Wave 29 | NO |

`READY_FOR_MOBILE_UI_OWNER_REVIEW: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`FINAL_UI_IMPLEMENTED: NO`
