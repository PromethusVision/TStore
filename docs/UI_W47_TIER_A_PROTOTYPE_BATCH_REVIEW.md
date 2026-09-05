# ASTRA DESIGN OWNER — Tier-A Batch 2 result

Branch: `astra-ui/w47-tier-a-prototype-batch-2`
Base: `origin/main@c63e61d6363f2cbeb816b7cb55e970e40f798d78`
Scope: three light-mode, 390 × 844 Product Owner visual gates. This is a prototype batch, not implementation closeout.

The remote was fetched before creating this fresh branch. The required main HEAD was current. The prior task branch was not continued. Integrated Flutter Final UI supplied the composition, Poppins typography, primary/accent palette, surface buttons and design tokens. No Figma calls were needed.

All three public views expose `visualPrototype: true` as an opt-in presentation seam. The default is **false**. Existing customer routes keep their approved/runtime presentation until Product Owner accepts these gates. The screenshot tests instantiate the real views with local fixture entities and mocked Cubits; no live account or remote data is involved.

## A. Purchases

**Chosen active surface:** `PurchasesView`, loaded **Alışverişlerim** tab. The Settings screen and purchase notifications reach this view; purchase/QR target arguments and target-first history behavior remain intact.

The hierarchy is a compact back/header area, physical-purchase explanation, existing tabs, then flat purchase cards. Each card shows the real shop name, confirmation timestamp, product names, quantities, unit/line amounts and total. The prototype says “Mağazada QR ile doğrulanan alışverişlerin” and “Mağazada doğrulandı”. This is physical purchase history. No order, payment, shipping or delivery state was added.

“Mağazayı gör” invokes the original shop lookup/navigation with the purchase's shop ID. “Esnafa puan ver” opens the existing rating sheet only on unrated purchases; rated records show the actual score. The existing rating handler retains the source QR-session identifier and refresh behavior. Product-detail/review links and product photos were not invented: this purchase item contract has product names and shop-product identifiers, but no canonical product-detail handoff or product image field. There is no separate purchase-detail route to redesign.

The reachable **İade Taleplerim** and **İade Talebi Oluştur** tabs were inspected. They remain the current placeholder surfaces and keep their existing navigation. Their continued visibility is inherited runtime behavior; this prototype does not implement returns.

**Primary evidence:** [Purchases, 390 px](../test/widget/purchases/goldens/w47_purchases_390.png).

An inexpensive BEFORE capture was attempted. Old button-local font overrides rendered with Flutter test's artificial block fallback, so that unreliable PNG was removed. The legacy render smoke remains. The primary prototype evidence has readable Turkish text and was visually inspected.

**Smoke:** 34 tests passed: seven W47 render/navigation/rating/default-off cases plus 27 existing purchase UI cases. The prototype exercises exact shop-ID handoff, the existing rating sheet, rated/unrated distinction, targeted history ordering, back, and return-tab navigation.

**Owner decision:** accept or revise the card density, physical verification language, and prominence of the shop-rating action. No business-rule decision blocks this gate.

## B. Reviews

**Chosen active surface:** `ProductReviewsView`, reached from Product Details and its product-description review entry. Review summary/list, eligibility states, editor and deletion confirmation were inspected. The primary gate shows a loaded canonical-product review list with one editable own review and another customer review.

The header retains actual product identity. A restrained summary presents the real aggregate average, count and supported five-level rating distribution. A compact eligibility panel uses the **same existing status switch**, text and callbacks. Flat review cards show rating, review date, optional title/comment, an anonymous customer label and the existing verification indicator. Own-review edit/delete actions remain attached to the review. No merchant/purchase date, reviewer identity or photo was fabricated.

**Evidence provenance:** the repository reads reviews through `get_product_reviews`. In `20260815000900_0009_verified_product_reviews_storage.sql`, that RPC derives `is_verified_purchase` from the presence of `verified_transaction_item_id`. The UI preserves that server-provided flag; it does not turn a legacy stored boolean into authority. The eligibility RPC and Cubit remain authoritative for mutations.

Canonical rules remain unchanged: merchant-confirmed QR physical-purchase evidence; one active review per customer and canonical product for life; quantity/repeat purchases grant no additional right; indefinite editing; immutable evidence survives deletion/recreation; eligibility does not expire. Backend, repositories, entities, Cubit logic and SQL were not edited.

**Primary evidence:** [Reviews, 390 px](../test/widget/shop/goldens/w47_reviews_390.png).
**Before:** [same fixture, old presentation](../test/widget/shop/goldens/w47_before_reviews_390.png).

**Smoke:** 51 tests passed: 11 W47 cases plus existing review UI, repository, Cubit and verified-storage contract tests. Create and edit use the original editor and exact canonical product/review IDs; deletion uses the evidence-preserving confirmation. Guest, absent eligibility and unverified states cannot present a write action; unverified review rows receive no badge; mutation guards and back navigation are preserved. The successful combined review run also repeated seven purchase prototype cases, yielding 58 passes in that command.

**Owner decision:** accept or revise the product-rating summary, compact eligibility panel and verified-review hierarchy. No eligibility-policy decision is required.

## C. Customer Chat

**Chosen active surface:** `ChatView`, the customer–merchant conversation. `ConversationsView` was also inspected: it already provides the inbox, actual last-message/read/unread state and the conversation handoff. Settings, notifications and existing merchant/product entries reach these flows. The conversation is the primary composition gate; the inbox was not redesigned.

A compact merchant header uses the actual receiver display name and “Mağaza ile görüşme”. Received messages use white surfaces; customer messages use soft primary surfaces. Readable body text, chronological date separators and real timestamps lead to a restrained composer and 48 px send action. The existing `isRead` contract already implements “Okundu/Gönderildi”; those states are retained only for outgoing messages. No online, typing, voice, attachment or AI affordance was added.

The original controller, grapheme limit, draft handling, send callback, receiver ID, in-flight disablement and success clearing remain in place. Reverse list ordering, scrolling, pagination, refresh timers, lifecycle behavior, incoming read marking and back navigation are unchanged. This conversation receives a merchant user ID/name, not a shop-profile navigation contract; the header does not invent a shop link.

**Primary evidence:** [Customer Chat, 390 px](../test/widget/chat/goldens/w47_chat_390.png).
**Before:** [same fixture, old presentation](../test/widget/chat/goldens/w47_before_chat_390.png).

**Smoke:** 41 tests passed: eight W47 cases plus existing conversation and inbox UI cases. The prototype verifies send/receiver ID, trim and success clearing, sending lock, empty/length validation, actual read-status updates, incoming read marking, reverse scrolling/pagination and back/Cubit disposal.

**Owner decision:** accept or revise the quiet merchant header, softer outgoing messages and composer hierarchy. No missing domain capability blocks this gate.

## Verification and scope

- 126 distinct targeted tests passed across the three packages. Final cross-package comparison reran all 26 W47 cases without updating goldens: PASS.
- `flutter analyze --no-pub`: PASS, no issues found.
- `git diff --check` against the base: PASS. Changed-text secret/PII regex scan: PASS (0 credential-pattern, email or Turkish-phone hits); all fixture identities are synthetic. This is a scoped diff scan, not a full-repository security audit.
- Three primary 390 × 844 PNGs and two reliable BEFORE PNGs. All five were visually inspected; fixtures are synthetic.
- No full Flutter suite, new width matrix, comprehensive state/accessibility matrix, dark mode, or implementation closeout. Those remain after visual acceptance.
- Shared runtime components changed: 0. No finalized screen, route, backend, taxonomy, QR rule, review eligibility or purchase-evidence rule changed. No Production access or Development remote write.

## Metrics and calibration

- Scoped completion: 3/3 representative prototypes; 3 independent visual gates ready for review.
- Files changed from base: 16 (six feature presentation files, four test/support files, five PNGs, this report).
- Checkpoints pushed: Purchases `4a92417`; Reviews `6206851`; Chat plus final verification/report in this report's commit. No main merge or force push.
- Observable wall time: approximately 25 minutes through final verification/report preparation.
- Figma calls: 0. Figma quota blocker: NO.
- Shared-component changes: 0. Decision/environment blockers: 0.
- Calibration: **GREEN**. Next Design Owner batch: **SAME_SIZE**, approximately three Tier-A prototypes. The evidence supports bounded opt-in execution; broader production readiness remains unmeasured until visual approval and closeout.

Initial test-only issues (a const fixture property and asynchronous mock stream timing/closure) and two analyzer style/import findings were corrected. They required no domain change. The unusable Purchases BEFORE capture was discarded rather than used as review evidence.

```text
PURCHASES_PROTOTYPE_READY: YES
REVIEWS_PROTOTYPE_READY: YES
CHAT_PROTOTYPE_READY: YES
PURCHASE_RULES_CHANGED: NO
REVIEW_ELIGIBILITY_CHANGED: NO
FIGMA_QUOTA_BLOCKER: NO
FULL_REGRESSION_RUN: NO
READY_FOR_PRODUCT_OWNER_VISUAL_BATCH_REVIEW: YES
```
