# Astra Wave 3 scope recommendation — Implementation Agent 2

Status: **PLANNING ONLY — 2026-09-05**.
Evidence: [Wave 2B acceptance](ASTRA_WAVE2B_ACCOUNT_HUB_INTEGRATION_RESULT.md),
[current 60-row inventory](UI_W46_POST_ACCOUNT_HUB_INVENTORY.md) and
[calibration](ASTRA_CALIBRATION_LOG.md). No future implementation starts here.

## Scope escalation decision

**IMPLEMENTATION_SCOPE_70_100_RECOMMENDED: NO.**

Three independent implementation packages are GREEN: Discovery ~17 historical
nominal h, Auth/Startup ~30 h, Account Hub ~44 h. Account delivered all nine active
surfaces without runtime reconciliation or shared-primitive changes. This supports
testing a larger coherent contract when one exists; speed alone does not justify
combining unrelated work or taking another owner's files.

The refreshed inventory contains **117 nominal h / 26 units**. Design Owner
Batch 2 and future dependent Agent 3 work reserve **67 h / 8 units**. Even every
unreserved screen, modal and shared-state family totals only **50 h / 18 units**,
below 70 h before coherence and shared ownership constraints are applied.
Thus a 70–100 h Agent 2 package cannot be formed from current non-overlapping UI.
Do not reopen completed Category/Account/Auth work, include Merchant/Ads/Reward
economics/backend work or count tests, variants and goldens as new conversion
units to reach the range. This is an inventory limit, not a failed calibration.

Keep the worker's GREEN / SAME_SIZE capacity recommendation as evidence. The
next assignment is smaller because the remaining coherent work is smaller.
Re-evaluate larger contracts only after a separately authorized inventory grows.

## Recommended package: customer saved products and activity

**24 historical nominal h, 6 active conversion units, 4 screens + 2 menus/dialogs.**
A single Agent 2 branch owns these existing customer destinations. They use
integrated Account/Auth and product-card language and can finish independently
of new Purchases/Reviews/Chat visuals.

| ID | Surface | Nominal h | Tier | Figma | Existing route / behavior boundary |
|---|---|---:|---|---|---|
| FS-21 | Wishlist | 6 | B | FIGMA_NOT_REQUIRED | Tab 3 and favorite guards; same product identity, customer isolation and add/remove behavior |
| FS-28 | Recently Viewed | 6 | B | FIGMA_NOT_REQUIRED | Account destination; existing local history, ordering and Product Details navigation |
| MD-15 | Clear all Recently Viewed | 1 | C | FIGMA_NOT_REQUIRED | Existing clear confirmation; cancel/busy/error and customer scope preserved |
| MD-16 | Recently Viewed item action menu | 1 | C | FIGMA_NOT_REQUIRED | Existing per-item remove action; exact item and route identity preserved |
| FS-29 | Customer Notifications | 8 | B | FIGMA_LIGHT | Home/Account entries; existing loading/error/empty, pagination, read state and typed destinations |
| FS-27 | Customer Coupons | 2 | C | FIGMA_NOT_REQUIRED | Existing truthful unavailable/empty presentation; no coupon/reward economics or invented offers |

Tier A/B/C = **0/3/3**; Figma HEAVY/LIGHT/NONE = **0/1/5**.
Use existing integrated Flutter Final UI as implementation truth. Figma is
forbidden for the five NOT_REQUIRED units. Notifications LIGHT permits only a
targeted reference if the future task explicitly grants it; prefer **0 calls**,
no exploratory crawling. No new per-screen B/C Product Owner gate is needed
unless a major visual divergence or material business ambiguity appears.

## Exact ownership boundary

Agent 2 owns presentation edits in:

- `lib/features/shop/presentation/views/wishlist_view.dart`
- `lib/features/shop/presentation/views/recently_viewed_products_view.dart`
  (including MD-15 and MD-16)
- `lib/features/notifications/presentation/views/customer_notifications_view.dart`
- `lib/features/personalization/presentation/views/customer_coupons_view.dart`
- Dedicated feature-local composition helpers only where needed, plus corresponding
  feature widget tests and uniquely named visual fixtures/goldens.

Consume existing cubit/repository/domain contracts and shared product-card,
favorite-button, typography, spacing and state primitives. Do not edit global
navigation, service locator, Auth/session, Settings/Profile, Nearby/location,
Cart/QR, Purchases/Ratings/Reviews/Chat, shared theme/form/product-card primitives,
dependencies, backend or auth configuration. New routes, models, notification
payload semantics, coupon APIs and stored-data behavior are outside this contract.

Wishlist favorite buttons also appear in catalog/Details; use their current
public behavior, do not change the shared button while updating its list caller.
Notifications' existing order/detail and chat/thread destination builders remain
intact, including IDs, payload fallback and read behavior. Agent 3 may implement
their destination presentation independently while preserving constructor APIs.
If that API must change, Integration reconciles it once after both checkpoints;
workers do not edit each other's files.

If a common primitive change becomes unavoidable, report
**SHARED_COMPONENT_CHANGE_REQUIRED** with exact files, callers and reason.
Integration assigns one writer before any competing shared edits. No shared
change is currently required or pre-authorized by this recommendation.

## Disjoint reservation map

| Lane | Exact remaining units | Units | Nominal h | Dependency / authority |
|---|---|---:|---:|---|
| Agent 2 candidate | FS-21/27/28/29, MD-15/16 | 6 | 24 | Integrated Account/Auth/products; no visual Batch 2 dependency |
| Design Batch 2 / dependent Agent 3 | FS-30/31/32/33/34, MD-05/17/18 | 8 | 67 | Purchases, Reviews, Chat directions require Product Owner gates; preserve their implementation ownership |
| Later location/Cart/QR presentations | MD-01/02/03/04/12/19/20/21/22/23 | 10 | 22 | Explicit single writer for location helpers, Nearby, Cart and QR sheet; coordinate Purchases caller before assignment |
| Integration shared-state family work | ST-02/03 | 2 | 4 | Shared progress/feedback across unfinished callers; isolated ownership |
| Total | Every remaining ID exactly once | **26** | **117** | No overlap or unassigned inventory ID |

The reserved 67 h consists of the earlier Purchases/Ratings -> Reviews candidate
(45 h / 6 units: FS-30/31/32, MD-05/17/18) plus conversation list and Chat (22 h /
2 units: FS-33/34). Agent 2 must not absorb either set, even if a design gate
temporarily blocks the other lane. Design Owner stays near three owner-reviewable
Tier A prototypes per batch. Prototype completion alone does not close runtime.

## Checkpoints and acceptance

1. Wishlist + Recently Viewed + its two actions: **14 h historical scope**.
   Preserve auth/customer isolation, exact product navigation, favorites, local
   history order, clear/remove cancel/confirm and loading/error/empty behavior.
   Run targeted tests and representative narrow/large-text visual checks, then
   commit/push this coherent checkpoint.
2. Notifications: **8 h**. Preserve type-based routing, unread/read transitions,
   pagination, duplicate-tap/slow-request behavior and existing fallback data.
   Test real destination identity against integrated Purchases/Chat APIs, then
   commit/push the completed checkpoint.
3. Coupons truthful presentation: **2 h**. Keep current unavailable/empty meaning;
   no eligibility, discount, transaction or reward engine is introduced. Test
   relevant navigation/state and commit/push.
4. Combined gate: account/navigation/auth/product and notification overlap tests,
   analyzer, one full Flutter suite, no lost tests/new skips, diff and secret/PII
   audit, representative visual evidence and TASK_RESULT. Worker pushes its
   branch only; Integration reviews and merges main separately.

This is one multi-package contract: complete all independent scoped units.
A real blocked Notifications destination contract does not stop the independent
Wishlist/history/Coupons work. Record the blocker and preserve completed pushed
checkpoints. Never weaken/skip tests or stop because a nominal-hour label is met.
No arbitrary elapsed-time threshold defines success.

## Owner decisions and next calibration

No new owner decision is required to prepare this recommendation. A future
assignment supplies execution authority and re-anchors then-current main.
Material business/security/data-integrity, major visual direction or remote
authority questions remain genuine owner gates; routine B/C composition does not.

Report scoped attempted/completed units, observable timing boundary, files,
commits/pushes, targeted/full/analyzer results, Figma calls, blockers, owner
corrections and shared collisions. Apply protocol GREEN/YELLOW/RED honestly:
GREEN supports SAME_SIZE or INCREASE_NEXT_SCOPE when coherent inventory exists;
YELLOW supports SAME_SIZE or REDUCE; RED requires REDUCE. The six-unit candidate
must complete coherently, not stop after one destination.

**READY_FOR_IMPLEMENTATION_AGENT2_WAVE3: YES — recommendation ready; not started.**
