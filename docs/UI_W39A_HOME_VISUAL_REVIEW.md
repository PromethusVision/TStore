# W39A Home Visual Review

## Final review status

W39A-R3 preserves the Product Owner-approved R2 Home composition and closes its visual polish, responsive behavior, state coverage and regression evidence. The resulting implementation is marked `FINAL_UI_HOME_V1_CANDIDATE`; it is an authoritative baseline for later screen rollout, not a Production-final release.

Figma, backend, taxonomy, Production and Reward Engine behavior were not modified. The final Home presentation remains opt-in in the existing visual-prototype seam, and the Reward slot remains runtime default OFF.

## R2 composition freeze

The following approved structure remains unchanged:

- visible EsnaftaVar wordmark, greeting and compact location hierarchy;
- search directly below location;
- optional “Görev yap, kazan” card with five task segments;
- horizontal category row;
- image-first local product discovery;
- nearby merchant context;
- five equal bottom-navigation destinations without a raised cart action.

## R3 C1 polish

- Category icons now use one Material icon language, uniform 24 px weight, consistent 46 px inner surfaces, semantic labels, canonical borders and subtle token shadow. The category layout and dynamic taxonomy inputs did not change.
- Search, header, location, merchant rows and five-way navigation were retained and visually verified against R2. No structural redesign was introduced.
- Product-card widths now respond to the available Home width. At the primary width, the next card leaves an image-only carousel cue; partial product copy is not chopped at the viewport edge.
- Product text has consistent internal padding, two-line title safety, one-line merchant context and anchored price emphasis.
- At 320 px or 130% text scale, the visible Home and nearby navigation labels use concise Turkish forms while their semantics retain the full destination names.

## Reward presentation review

The owner-approved contract is fixed at five tasks per visual cycle. Tests cover 0/5, 1/5, 2/5, 3/5, 4/5 and 5/5. The card always presents completed count, remaining count and the supplied reward value; 5/5 changes to the concise completed state “Ödülü kazandın”.

Long reward values are bounded visually and remain complete in semantics. Optional subtitle and optional message are independently safe. Invalid task counts clamp to 0...5, so the fixed denominator cannot produce NaN or division errors. The illustrative `100 TL` value exists only in test fixtures.

## Final local visual evidence

All files are deterministic Flutter goldens generated from local fixtures. The approved R2 screenshot is retained unchanged for lineage.

| Scenario | Evidence |
| --- | --- |
| R2 approved lineage | `test/widget/shop/goldens/w39a_r2_home_brand_reward_390.png` |
| Authenticated Home, 390 | `test/widget/shop/goldens/w39a_r3_home_authenticated_390.png` |
| Guest Home, 390 | `test/widget/shop/goldens/w39a_r3_home_guest_390.png` |
| Reward 0/5, 390 | `test/widget/shop/goldens/w39a_r3_home_reward_0_of_5_390.png` |
| Reward 3/5, 390 | `test/widget/shop/goldens/w39a_r3_home_reward_3_of_5_390.png` |
| Reward 5/5, 390 | `test/widget/shop/goldens/w39a_r3_home_reward_5_of_5_390.png` |
| Long Turkish content at 130% text scale, 390 | `test/widget/shop/goldens/w39a_r3_home_long_text_390.png` |
| Loading, 390 | `test/widget/shop/goldens/w39a_r3_home_loading_390.png` |
| Empty, 390 | `test/widget/shop/goldens/w39a_r3_home_empty_390.png` |
| Error, 390 | `test/widget/shop/goldens/w39a_r3_home_error_390.png` |
| Authenticated Home, 320 | `test/widget/shop/goldens/w39a_r3_home_authenticated_320.png` |
| Authenticated Home, 430 | `test/widget/shop/goldens/w39a_r3_home_authenticated_430.png` |

## Responsive, state and accessibility result

- 320, 390 and 430 px evidence renders without horizontal overflow.
- 100% and 130% text scales pass; scaled category and product rows grow vertically instead of clipping.
- Long user, location, category, product, merchant, reward and large-price fixtures render without meaningful content loss. Ellipsis is limited to bounded single-line contexts, with full semantic values where relevant.
- Existing 44/48 px interaction targets remain intact. Category actions gained explicit Turkish semantics.
- Canonical Poppins typography, light tokens and previously verified contrast thresholds remain unchanged.
- Authenticated, guest, loading, empty and error states use the same approved Home language. No separate offline state was invented because current Home architecture exposes loading/error rather than a dedicated offline state.

## Verification

- Home and adjacent targeted matrix: 133 passed, 0 failed.
- Taxonomy-independent Cart V2 / QR / Reviews / Wishlist / Seller Comparison / Auth matrix: 439 passed, 0 failed.
- Full Flutter suite: 1328 passed, 6 pre-existing conditional/live skips, 0 failed.
- `flutter analyze --no-pub`: no issues.
- Golden matrix: 11 passed; images inspected after generation.

## Remaining deferred work

- Reward economics, mission definitions, funding, redemption, expiry and abuse controls remain undefined.
- Reward backend and runtime activation remain out of scope.
- Production activation and rollout to later customer screens require a separate integration wave.

`R2_COMPOSITION_PRESERVED: YES`

`HOME_FINAL_UI_V1_CANDIDATE: YES`

`FIGMA_MODIFIED: NO`

`REWARD_RUNTIME_ACTIVE: NO`
