# UI Visual Freeze Contract

## Definition

Final visual freeze is reached when an immutable Flutter commit and immutable
Figma reference set have passed functional, structural, accessibility, brand and
product-semantic gates for the agreed pilot scope.

## Required criteria

- Owner-approved brand role, critical screens and unresolved C1 items.
- Dark-mode policy explicitly decided and implemented consistently.
- All 33 primary Customer view files classified as migrated, accepted or explicitly
  pilot-deferred with no usability gap.
- Five critical commerce screens plus AuthGuard match approved hierarchy.
- Canonical component APIs and semantic tokens are frozen.
- No V0/V1 visual or functional defects remain.
- Required viewport/text-scale/golden/semantics/contrast suites pass.
- Physical device walkthrough passes for the exact release artifact.
- Shipping/payment/classic checkout/order UI is absent from active customer paths.
- Dynamic taxonomy fixtures pass without hardcoded proposed nodes.
- Ads/reward/gamification dormant states do not imply active functionality.

## Freeze identifiers

Record:

- Flutter commit and build artifact hash;
- Figma file version plus approved frame/node IDs;
- token/component manifest version;
- screenshot baseline commit;
- supported platforms, widths, theme modes, locale and text-scale range;
- accepted deferments and their severity/owner/date.

## Change control after freeze

| Change | Required action |
|---|---|
| V0/V1 defect | Fix, targeted regression, affected screenshots, release review |
| Copy-only meaning-preserving fix | Copy/a11y review and affected golden update |
| Token/component API change | Reopen affected component and every consumer acceptance |
| Product behavior or taxonomy change | Separate product/runtime task; freeze impact review |
| Cosmetic preference | Post-pilot backlog unless owner explicitly reopens freeze |

## Not sufficient for freeze

- “Looks good on my phone.”
- Figma-only approval without exact Flutter artifact evidence.
- Passing golden tests with missing functional states.
- A 390 px screenshot with no small/large/text-scale coverage.
- Closing visual defects by changing business logic.
