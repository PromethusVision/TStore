# Astra Wave 2A — Tier A batch integration result

Date: **2026-09-05**. **COMBINED ACCEPTANCE PASS**.
Shop Details, Cart V2 and Nearby/Location are FINAL_UI_V1_MAIN on the integration
delivery. This document's publication commit is the docs checkpoint following
the exact tested runtime below; the final task response records the verified
remote main/task SHA. No structural redesign was made.

## Git and reconciliation

| Item | Evidence |
|---|---|
| Starting main | `6cc5d1607da96415f788d5324006bc89fe85d554`; fetched before work and rechecked before publication, unchanged |
| Final source | `b5fe6304d8b3bdf47ee6d40609ff47d409279622`, origin/astra-ui/w45a-tier-a-prototype-batch-1 |
| Source ancestry | All 8276d8d, 39a8653, 6a9542b, a261004, 4ae9d6d, e366149, b2652d6, b5fe630 verified ancestors; QR owner correction included |
| Common ancestor | `4287972429d9befe4ef2637a565ea6d8a2393a5e` |
| Branch / worktree | integration/astra-wave2a-tier-a-batch; C:/Users/Mustafa/.codex/worktrees/0716/TStore_CLEAN |
| Pre-merge review | `8d555c864d2e1cbbe3df65d5c4843e583c47f16e`, PASS before merge |
| No-ff merge | `656c3957aefc32dce4af8e11f6566ef43af4ddfe` |
| Tested runtime / reconciliation checkpoint | `5fe32fda6d6b70223ac0d42d7def1b055caf5f6c`, pushed to integration branch after all test gates |
| Textual conflicts | 0; complete source/current-main changed-path intersection empty |
| Semantic resolution | Three approved presentation defaults activated; Wave 1 functionality preserved; behavior-test selectors/scrolling adapted; session rule superseded explicitly |
| Publication | Normal branch checkpoint push, followed by final docs branch push and fast-forward main push; no force push or history rewrite |

The source's 70-file complete delta (7 runtime Dart, 4 test Dart, 57 PNG,
2 documents) includes the 65-file closeout delta measured from a261004.
Integration changes only the three constructor defaults/comments beyond source
runtime. Six test files reconcile actual default-Final presentation and retain
legacy comparison assertions. The source W43 test additions are also preserved.
Combined delta from starting main: **82 files = 7 runtime Dart + 7 test Dart +
57 PNG + 11 Markdown documents**.

See [pre-merge/final collision review](ASTRA_WAVE2A_TIER_A_COLLISION_REVIEW.md).
No source/main functionality was discarded merely to obtain a clean textual merge.

## Accepted customer behavior

| Surface | Final acceptance |
|---|---|
| Shop Details | Directions/physical visit primary, shop products core, chat/contact secondary. Actual identity/address/hours/rating or honest absent state; loaded/loading/error/no-products, long content, product handoff, directions/phone/chat/back tested. 320/390/430 and 130% matrix; existing 320/200% action test also passes. |
| Cart V2 | Single-shop physical shopping preparation, actual shop/items/quantity/totals, remove/clear/empty/many-items/long-product/large-price/unavailable/recovery states. Exact CTA **QR kod oluştur**; rejected old CTA count **0** in Cart view/part and QR path. |
| QR | Same _preparePurchaseVerification → cart refresh → availability/pricing confirmation → existing QR sheet. Exact listing/cart identity, mutation lock, double-submit, changed-total accept/cancel, refresh after close and verified-purchase handoff preserved. No payment/order/shipping/delivery semantics. |
| Nearby / Location | Actual saved/device location context; denied/missing/unavailable/settings/resume states, privacy copy, loaded/loading/error/zero/many shops and long text. Distance appears only for a listed shop with finite non-negative distance in ready state; unknown/stale/invalid data is not fabricated. Same entity reaches default-Final Shop Details, with duplicate-navigation/back checks. 320/390/430 and 130% matrix passes. |
| Wave 1 | Search/All Products and Auth/Startup, return-to-caller guards, session/recovery listeners and destinations preserved and tested. |

The complete Cart action/confirmation/QR method block, Nearby action/consent/
settings block and Shop product/directions/phone/chat blocks compare identically
with starting main after newline normalization. Core, auth, Cart business/domain/
data, location Cubits/helpers/services, backend, configuration and taxonomy
have no changed files.

## Shared offer-card correction

**SHARED_COMPONENT_CHANGE_REQUIRED: YES** — exact file:
`lib/features/shop/presentation/widgets/seller_comparison_offer_card.dart`.
The source wraps _OfferFact Text in Flexible to fit real distance text at
320 px / 130% (previous 29–31 px overflow); no calculation/callback/business change.

ProductSellersSection's private seller-card builder is its sole direct caller,
only in visualPrototype=true. Dedicated SellerComparisonView opts in and remains
unbound. Both Product Details compositions use ProductSellersSection with its
unchanged default-false seller cards; they are adjacent preservation checks, not
active consumers of this offer-card branch. Home, Search/All Products, Listing,
Nearby and Shop use their own cards and share destinations. W43 and the new
narrow conflict tests exercise the fix directly; W42/Product Details and other
callers pass adjacent regression. No competing current-main change exists.
W42/W43 existing goldens pass unchanged.

**57 source PNG blobs and all 129 pre-existing main PNG blobs are retained.**
Representative Shop, Cart QR/stress and Nearby unknown-distance/narrow images
were inspected locally. No Figma access or golden regeneration was used.

## Validation and test preservation

| Gate | Result |
|---|---|
| Final UI behavior reconciliation recheck | 69 PASS / 0 FAIL / 0 SKIP |
| Targeted Shop/Cart/QR/Nearby/Location/Search/All Products/AuthGuard/Startup | **758 PASS / 0 FAIL / 0 SKIP** |
| Adjacent Home/Category/Listing/Details/Seller/Wishlist/Reviews and shop units | **572 PASS / 0 FAIL / 0 SKIP** |
| flutter analyze --no-pub | **No issues found**, 39.0 s tool-reported |
| ONE combined flutter test --no-pub --reporter json | **1766 PASS / 0 FAIL / 6 existing conditional skips**, 105.610 s runner |
| Test discovery | **163/163** files; main 160 and source 160 form exactly this union; missing 0, unexpected 0 |
| git diff --check | PASS |
| Secret/PII scan | Added text checked for private keys, token/JWT patterns, credential assignments, email/phone identifiers; no credential/PII candidate found. Local synthetic fixtures reviewed. |

Count reconciliation: **1637 current-main + 128 source additions + 1 integration
tab-default test = 1766** (equivalently 1430 + 207 + 128 + 1).
Targeted counts overlap full-suite coverage and are not added to its total.
Six unchanged opt-in tests cover development Auth/RLS, product reviews, two
Realtime cases and two production smoke cases. Their opt-in flags were not
enabled; they made no Development/Production calls. No new skip or weakened
business/security assertion was introduced.

Initial activation exposed **179 PASS / 34 FAIL** in legacy-presentation test
expectations. The first adaptation produced **202 PASS / 12 FAIL** from offscreen
lazy-list actions and a changed button widget type. Final tests reveal/scroll
actual controls before acting, keep pending-callback/double-submit assertions,
and assert the approved copy/types. Legacy-specific presentation assertions
remain on explicit false; source responsive/golden tests now use the actual
default-Final constructors. The SDK lock/cache restriction was retried with
authorized SDK access; no test was bypassed. There was only one full-suite run.

Reproduction uses the changed Shop/Cart/Nearby tests plus widget/cart, unit/cart,
widget/auth, unit/auth, Search/All Products, location helpers/saved locations,
auth architecture and offline auth integration for the targeted gate. The
adjacent gate covers remaining widget/shop and unit/shop files, widget/wishlist,
unit/wishlist and unit/reviews. Local JSON logs and exact path sets are retained
under ignored .buildlog/wave2a-*; production/live flags are absent.

## Inventory and next package

[Refreshed row ledger](UI_W45A_POST_TIER_A_INTEGRATION_INVENTORY.md) independently
checks routes, actual constructors/callers, active modals and shared families.
Reachable full screens **34**, active modals **23**, state families **3**.
Final reachable screens **20**, active modals **4**, shared families **1**;
unbound historical Seller Comparison remains separate.

Remaining: **14 full screens + 19 modals + 2 shared families = 35 units**.
Tier A/B/C **3/15/17**; FIGMA_HEAVY/LIGHT/NOT_REQUIRED **3/6/26**.
Unchanged QR/location/cart modal presentations were not closed just because their
behavior tests passed. The next Design Owner batch is to be selected from
FS-30 Purchases, FS-32 Reviews and FS-34 Chat.

## Calibration, protocol and task metrics

- Attempted/completed: **11/11 contracted phases; 3/3 approved screens**.
  Git delivery is the final publication step. No blocker or required owner
  decision remains; no new substantive owner correction during integration.
- Observed integration start **01:57:22 UTC** (04:57:22 Europe/Istanbul); full-gate
  audit **02:39:28 UTC**: **42m06s** through verification, excluding final docs/Git
  publication. This is an observed local boundary, not an execution deadline.
- Four coherent integration checkpoints: pre-merge review, source no-ff merge,
  default/test reconciliation, protocol/inventory/calibration/coordination docs.
- Figma classification: three historically HEAVY screens; this integration
  explicitly forbids access. Observable Figma calls **0**. Remote operations only
  fetch/push Git; Development writes and Production access **0**.
- Shared collision: one reviewed offer-card source correction, no unresolved
  competing edit. Foundation/navigation/config/AGENTS.md unchanged.
- Integration calibration **GREEN / SAME_SIZE**: complete scoped package,
  no critical regression, no major drift, no owner correction.
- [Calibration log](ASTRA_CALIBRATION_LOG.md) records prototype ~19 min, 3/3,
  107 targeted tests, Figma 0, GREEN; one QR-copy owner correction; closeout
  32m33s, 65 files, 54 proofs, 1558/0, Figma 0, GREEN/SAME_SIZE.
  Keep Design Owner near **three Tier A prototypes per visual batch** because
  Product Owner review throughput currently limits the visual pipeline.
- [Protocol session section](ASTRA_EXECUTION_PROTOCOL.md) now defaults to persistent
  Astra conversations. Fresh sessions require model change, explicit independent
  audit/clean-room, observed context degradation or another justified isolation
  need. Each package fetches and re-anchors to current main plus its contract.
  Unrelated protocol sections and AGENTS.md are unchanged.

Production, Development writes, backend, taxonomy, canonical activation, Ads,
Reward economics, Merchant App and dark mode were outside scope and unchanged.
