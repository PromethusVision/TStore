# W39A-R3 Final Home Acceptance

## Decision

The W39A-R2 composition remains frozen and is accepted after bounded C1 polish, responsive closure, complete presentation states and full regression. The result is `FINAL_UI_HOME_V1_CANDIDATE`, not Production-final.

Branch: `ui/w39a-final-ui-foundation-home`

R3 starting HEAD: `f5a8e512b99fea42e6cdee965deda679e383f445`

## Acceptance matrix

| Area | Result | Evidence |
| --- | --- | --- |
| EsnaftaVar brand | PASS | Wordmark is the first visual anchor at 320, 390 and 430 px. |
| R2 structure | PASS | Header, location, search, Reward slot, categories, products, nearby merchants and five-way nav retain their order and purpose. |
| Category C1 | PASS | Uniform icon family, weight, scale, padding, surface, border and shadow; data remains dynamic. |
| Search/header | PASS | Existing compact hierarchy retained; focus surface, long greeting and long location remain bounded. |
| Product C1 | PASS | Image-first card retained; responsive card width, padded copy and image-only next-card cue remove awkward chopped text. |
| Local commerce | PASS | Local price comparison and nearby merchant language remain prominent; no shipping, delivery, payment or checkout semantics were added. |
| Bottom navigation | PASS | Five equal targets, unchanged indices/actions, no raised center cart, safe compact labels at narrow/scaled layouts. |
| Accessibility | PASS | Poppins and canonical tokens retained; 44/48 px targets, important semantics, contrast contract and 130% scaling pass. |

## Reward state acceptance

| State | Completed copy | Remaining copy | Visual result |
| --- | --- | --- | --- |
| 0/5 | `0/5 görev tamamlandı` | `Ödüle 5 görev kaldı` | Clear starting state |
| 1/5 | `1/5 görev tamamlandı` | `Ödüle 4 görev kaldı` | PASS |
| 2/5 | `2/5 görev tamamlandı` | `Ödüle 3 görev kaldı` | PASS |
| 3/5 | `3/5 görev tamamlandı` | `Ödüle 2 görev kaldı` | PASS |
| 4/5 | `4/5 görev tamamlandı` | `Ödüle 1 görev kaldı` | PASS |
| 5/5 | `5/5 görev tamamlandı` | `Ödülü kazandın` | Completed success treatment |

The reward destination/value remains presentation-supplied. Long values, missing subtitle, missing message, feature OFF and fixture ON are tested. The runtime default stays OFF. No payout, redemption or mission behavior was implemented.

## Responsive and content matrix

| Matrix item | Result |
| --- | --- |
| 320 px | PASS; compact labels and product cards remain readable. |
| 390 px | PASS; primary visual reference. |
| 430 px | PASS; max-width Home composition remains centered and bounded. |
| 130% text scale | PASS; category/product sections grow without clipping. |
| Long user and location | PASS with appropriate single-line ellipsis. |
| 48-character Turkish category | PASS with three-line bounded presentation. |
| Long product and merchant | PASS with title/context constraints. |
| Large price/reward value | PASS visually; complete semantic value retained for Reward. |

## State matrix

| State | Result |
| --- | --- |
| Authenticated loaded | PASS |
| Guest | PASS; login/location AuthGuard behavior unchanged. |
| Loading | PASS; no fake records. |
| Empty | PASS; categories, products and nearby merchants have clear copy. |
| Error | PASS; retry affordances retained. |
| Dedicated offline | Not added; current architecture has no separate Home offline state. |

## Evidence

Primary review:

- `test/widget/shop/goldens/w39a_r3_home_reward_3_of_5_390.png`
- `test/widget/shop/goldens/w39a_r3_home_authenticated_320.png`
- `test/widget/shop/goldens/w39a_r3_home_authenticated_430.png`
- `test/widget/shop/goldens/w39a_r3_home_long_text_390.png`

State and Reward evidence:

- `test/widget/shop/goldens/w39a_r3_home_authenticated_390.png`
- `test/widget/shop/goldens/w39a_r3_home_guest_390.png`
- `test/widget/shop/goldens/w39a_r3_home_reward_0_of_5_390.png`
- `test/widget/shop/goldens/w39a_r3_home_reward_5_of_5_390.png`
- `test/widget/shop/goldens/w39a_r3_home_loading_390.png`
- `test/widget/shop/goldens/w39a_r3_home_empty_390.png`
- `test/widget/shop/goldens/w39a_r3_home_error_390.png`

Lineage retained:

- `test/widget/shop/goldens/w39a_r2_home_brand_reward_390.png`

## Verification record

- Targeted Home/regression: 133 passed.
- Taxonomy-independent regression: 439 passed.
- Full Flutter: 1328 passed, 6 existing conditional/live skips, 0 failures.
- Analyzer: no issues.
- Golden evidence: 11 passed and visually inspected.
- No new skips or weakened assertions.

## Explicit boundaries

- Backend changed: NO
- Taxonomy changed: NO
- Production accessed: NO
- Figma modified: NO
- Reward Engine implemented: NO
- Reward runtime enabled: NO
- Dark mode added: NO
- Home structurally redesigned: NO

## Final self-review

A. EsnaftaVar branding immediately visible: YES.

B. Product Owner-approved R2 K’pasa-referenced direction preserved: YES.

C. Five-task Reward structure, completed count, remaining count and value clear: YES.

D. Category visuals materially more cohesive/professional than R2: YES.

E. Local physical-commerce identity retained: YES.

F. Another structural redesign avoided: YES.

`FINAL_UI_HOME_V1_CANDIDATE: YES`

`READY_FOR_W39B_INTEGRATION: YES`
