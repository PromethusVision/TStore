# Astra Wave 2 — Scope recommendation

Date: 2026-09-05. **PROPOSAL ONLY — no Wave 2 implementation started.**
Baseline: [38 remaining units / 203 nominal hours](UI_W45_POST_CALIBRATION_SURFACE_INVENTORY.md).
Evidence: [calibration log](ASTRA_CALIBRATION_LOG.md) and
[combined integration result](ASTRA_WAVE1_IMPLEMENTATION_INTEGRATION_RESULT.md).

## Decision

**Implementation: INCREASE_NEXT_SCOPE to approximately 40–60 nominal W44-style
hours per agent/package. Design Owner: SAME_SIZE, at most three Tier A prototypes.**

Discovery (17 nominal h) and Auth/Startup (30 nominal h) independently completed
their full accepted scopes GREEN, then survived combined 1637 PASS / 0 FAIL
regression without feature/test loss or a shared-code reconciliation. Both used
the integrated Flutter foundation with zero Figma calls. W44 nominal estimates
materially overstated observed completion time for these two implementations.
This supports one controlled increase in coherent package scope. It does not
establish a general model speed multiplier or a 40–60-hour elapsed-time promise.

The workers' SAME_SIZE advice was reasonable for their individual samples. The
Integration Agent now has two independent results plus a combined gate, so the
recommendation is larger than either worker's advice. Hard functional bugs,
shared changes and external acceptance remain uncalibrated. Scope is a bounded
feature contract, never permission to skip a difficult unit or tests.

At the initial ~19-minute prototype delivery, Product Owner review was pending/partial. A newer read-only branch checkpoint, 4ae9d6d, now reports all three directions approved and Shop/Cart/Nearby R2 closeout underway. Review/closeout throughput still limits this lane; do not grow its queue beyond three new decisions at once. The W45A branch is not merged here.

## Next two non-overlapping implementation packages

| Owner | Proposed package | Inventory IDs | W44 nominal size | Units |
|---|---|---|---:|---:|
| Implementation Agent 2 | Account Hub + Saved Locations + Privacy/Support | FS-22/23/24/25/26, MD-06/07/08/09 | **44 h** | **9** |
| Implementation Agent 3 | Purchases + Shop Ratings, then Product Reviews | FS-30/31/32, MD-05/17/18 | **25 + 20 = 45 h** | **6** |

This deliberately revises W44's suggested lane allocation: Agent 2 owns Account;
Agent 3 owns the sequential purchase/review chain. Both packages together cover
15 distinct units / 89 nominal hours; if subsequently accepted, the remaining
baseline would be 23 units / 114 nominal hours, before any separate W45A-R2 main
closeout. That is a planning projection, not current completion.

Read-only inspection found newer W45A commits a261004 (Cart CTA) and 4ae9d6d
(Shop responsive/state closeout). Its R2 report says Cart and Nearby continue;
the batch full gate is pending. **Do not assign Shop/Cart/Nearby again or edit
those active owner files.** W45A remains outside this merge. At Wave 2 dispatch,
fetch and reconcile the latest R2 delivery and review decisions explicitly.

### Agent 2 — 44 nominal hours

- Settings 6 h, Profile 7 h, Saved Locations 9 h, Privacy 5 h, Help 4 h,
  edit-profile 4 h, account-delete confirmation 2 h, location editor 5 h and
  delete-location confirmation 2 h. Preserve deletion/session handling, exact-row
  mutations, consent and OS-permission behavior; legacy Address screens stay dead.
- Runtime ownership: active files under
  `lib/features/personalization/presentation/views/` for those five screens,
  their private edit/delete sheet composition and `settings_view_header_section.dart`;
  explicitly exclude coupons/history/notifications and data/Cubit/domain files.
- Start from integrated Auth/Startup. Consume `CustomerAuthFormCard` and legal
  views where appropriate without editing Auth-owned/global listener files.
  Shared location helper behavior stays frozen; any unavoidable helper UI delta
  is Integration-owned and tested against Home/Nearby as well as Saved Locations.
- Tier mix B/C = 7/2. Historical Figma = 2 LIGHT (FS-24, MD-08), 7 NONE.
  Default zero calls using established Flutter form/state surfaces. A genuine
  LIGHT gap permits only a named relevant reference in its future task scope;
  it does not authorize broad file exploration or new design-system work.
- These B/C compositions require no separate per-screen Product Owner gate.
  Account mutation/deletion contracts still receive full regression coverage.

### Agent 3 — 45 nominal hours

- Purchases/history 16 h, shop-rating history 5 h, shop-rating editor 4 h;
  then product reviews/eligibility 14 h, review editor 5 h and delete confirmation
  1 h. Preserve the distinction between verified purchase, shop rating and
  canonical-product review. No payment, order or shipping semantics.
- Exact runtime ownership: lib/features/purchases/presentation/views/purchases_view.dart,
  lib/features/purchases/presentation/views/customer_ratings_view.dart and
  lib/features/shop/presentation/views/product_reviews_view.dart, including their
  private editor sheets/dialogs; associated package-owned tests/goldens only.
  Do not edit Cart/QR, Shop Details, Nearby, Product Details, auth listeners,
  repositories/Cubits, review RPCs or shared product/shop widgets.
- Prerequisites: separately validated Cart/QR R2 integration; accepted Purchases
  and Reviews directions from Design Batch 2. Scope review, fixture mapping and
  read-only contract review may proceed beforehand. Dependent final composition
  and integration wait for those gates; no duplication of ongoing Cart work.
- Order within one agent: Purchases + shop-rating checkpoint, then product
  Reviews/eligibility/editor checkpoint, then combined purchase/review/Auth
  regression. Eligibility remains server-authoritative; one active customer /
  canonical-product review and existing mutation guards must be unchanged.
- Tier A/B/C = 2/3/1. Historical Figma = 2 HEAVY, 1 LIGHT, 3 NONE. Use Design
  Owner's approved Flutter prototypes; default new Figma calls zero. Editor
  LIGHT may consume only a concrete missing reference under the future task's
  authority. No per-state Figma work or design-system duplication.

This pair uses the completed Auth foundation and follows the physical-shopping
critical path already being closed by W45A-R2. It has no shared screen/editor
file and does not give Account and Nearby simultaneous location-helper writes.
Account can start after task assignment; the 45-hour chain follows the Cart and
visual gates. Delayed gates remain explicit blockers, never a reason to implement
another agent's work or silently substitute a smaller package.

## Checkpoint, collision and testing policy

- Start each newly assigned large package in a fresh Astra task with an isolated
  worktree, verified current main and explicit exact-file ownership. This
  recommendation creates neither tasks nor implementation authorization.
- Commit/push after each coherent feature/state group and its targeted tests;
  aim for roughly 4–8 nominal-hour groups: Settings/Profile, Saved Locations,
  Privacy/Help and final gates in Agent 2; Purchases, shop-rating history/editor,
  Reviews/eligibility/editor and final gates in Agent 3. These are size labels, not arbitrary wall-clock deadlines.
- `lib/core/ui`, theme/tokens, shared forms/buttons/state primitives, navigation,
  DI/bootstrap, global listeners, pubspec and common test harness have one
  Integration writer. Reserve shared edits before a worker changes the file;
  list exact files, reason, consumers/tests and owner branch. Independent work
  continues; no overlapping primitive edits and no hidden screen-local duplicate.
- Freeze destination APIs and business contracts. A textual clean merge still
  needs semantic review, source-blob preservation and discovered-test comparison.
  Integrate approved W45A-R2 through its separate gate, then ready Account and
  purchase/review packages in dependency order with cross-consumer regression;
  never merge a prototype branch wholesale as a substitute for that gate.
- At each checkpoint run local affected unit/widget/contract tests. Cover real
  loading/empty/error/success/partial, guest and signed-in states, duplicate taps,
  slow/offline responses, 320/390/430 px, 130% text, keyboard and 44 px controls.
  Compare committed goldens against the accepted Final UI composition.
- Run analyzer and one complete Flutter suite at each final worker package gate;
  run a combined full suite after integration. No assertion weakening, new skip,
  blind golden update or live-environment opt-in to obtain a green result.
- No Figma calls for NONE surfaces. HEAVY is Design Owner composition work,
  preferably already available Flutter evidence; LIGHT is one specific unresolved
  reference, never exploratory crawling. Report classification and actual calls
  separately. Zero calls do not waive owner visual decisions.

## Design Owner Batch 2 — at most three decisions

Propose **FS-30 Purchases, FS-32 Product Reviews, FS-34 Chat detail**: three
remaining Tier A compositions, one representative 390 px Flutter prototype each.
They prepare the Cart -> Purchases -> verified Reviews chain and the final
communication path. W44 full-implementation labels total 16 + 14 + 14 = 44 h;
this is **not a 44-hour prototype estimate**. No new prototype-time estimate is
claimed from one sample.

Historical classification is HEAVY for all three; first use integrated Flutter
tokens, cards and evidence, with **zero Figma calls planned**. Any actual Figma
access needs future task authority. Batch 1's now-reported approvals and ongoing R2 closeout are reconciled before
opening another owner queue; no more than three actionable new prototypes.
Nearby remains unfinished on main despite its reported direction approval.

## When to increase to 70–100 nominal hours or reduce

Consider 70–100 only after **both 40–60-hour packages** finish at least 90% of
their original contracts (target 100%), each GREEN, with no critical regression,
major drift, unexplained test loss or more than one substantive owner correction;
their combined integration must also pass. Require bounded non-overlapping file
ownership, useful pushed checkpoints, a manageable review queue and no increase
in hidden shared work. Two fast clocks alone do not qualify. Keep Design Owner
at three decisions even if implementation grows.

Reduce or split at feature boundaries if a critical Auth/data/QR contract issue,
substantial owner redesign, repeated collision, prolonged unresolved dependency,
unreviewable diff, new skips/test weakening or unfinished scope appears. Mark
YELLOW/RED according to the protocol; retain failed evidence and blocked units
in the denominator. Separate genuinely new functional/backend work into an
explicitly assigned task rather than hiding it inside a UI size increase.

`DESIGN_OWNER_NEXT_SIZE: SAME_SIZE`

`IMPLEMENTATION_NEXT_SIZE: INCREASE_NEXT_SCOPE`

`IMPLEMENTATION_NOMINAL_RANGE: 40–60 h`

`IMPLEMENTATION_SCOPE_INCREASE_RECOMMENDED: YES`
