# W48 integration — semantic and approved visual contract review

Status: **FINAL SEMANTIC AND VISUAL ACCEPTANCE PASS — 2026-09-05**.
Current main/source base: `cd1d566c36a669fc9b6cabeaee9a114979ae7fb7`.
W48: `origin/astra-ui/w48-remaining-customer-utility-engagement-final-ui`,
full verified source **257c5aba9a40e6f461cd10ed98a7690f84769e75**.
Approved W3B reference: **733b444445564a5d0efe263efdb5555ade7cf2de**.
Task branch: `codex/astra-wave3a-w48-integration`.

Fresh fetch found no main advance. Source base is exact current main; all seven
source checkpoints are descendants. Worktree started clean and its common Git
directory is the authorized TStore_CLEAN repository. W49 is concurrent and
separate: do not wait for, check out, change or merge its worker branch.

## Exact source scope and boundaries

Source delta: **36 files = 11 runtime Dart + 7 test/fixture Dart + 15 PNG + 3 docs**.
The [W48 ledger](UI_W48_SCOPE_LEDGER.md), [worker result](UI_W48_TASK_RESULT.md)
and [shared caller audit](UI_W48_SHARED_CONSUMER_AUDIT.md) define the source
contract. **14 active units**: FS-21/27/28/29, MD-12/15/16/19/20/21/22/23,
ST-02/03. Four screens, eight active modals/actions and two shared families;
Tier 0/4/10, historical nominal 43 h, Figma 2 LIGHT + 12 NOT_REQUIRED.

Secondary Library is an existing destination family, not an extra route or unit.
Settings/Profile/Privacy/Help/Saved Locations remain previously completed.
Five screens FS-30/31/32/33/34 and three modals MD-05/17/18 retain W49 ownership.
MD-23's nested existing QR completion/rating subtree is a recorded W49 dependency;
its class source is unchanged and no extra inventory unit is invented.

## Four historical location windows

| ID | Historical window | Final reachability classification | Evidence |
|---|---|---|---|
| MD-01 | Permanently denied/settings dialog | **INACTIVE_CONFIRMED** | Only unused LocationHelper's permission-denied path; no runtime import/caller of that helper |
| MD-02 | Location acquisition loading overlay | **INACTIVE_CONFIRMED** | DialogRoute is created inside unused getAddressFromCurrentLocation only |
| MD-03 | Location service disabled dialog | **INACTIVE_CONFIRMED** | showLocationServiceDialog has only that legacy helper as a lib caller |
| MD-04 | Runtime permission explanation | **INACTIVE_CONFIRMED** | showPermissionDialog has only that legacy helper as a lib caller |

A recursive search across all lib Dart finds LocationHelper /
getAddressFromCurrentLocation only in their declaration file; the helper has no
active import, call or route. The two THelperFunctions compatibility dialogs are
called only inside that unused helper. Isolated widget localization tests and a
source logging contract are not navigation entry points. The helper file and
both dialog method bodies match main exactly.

Real service binding is CustomerLocationService -> GeolocatorCustomerLocationService
in service_locator.dart. Nearby uses its existing Cubit, active MD-19 consent and
location result states; Saved Locations captures through the same service.
Existing Home/product-seller entries use the real Saved Locations path.
No old window is restored or counted DONE. The correction removes four stale
active labels, not four completed conversions: 60 -> 56 actual active units;
13 inactive exclusions, plus the separately unbound done FD-05 reference.

## Semantic collision matrix

| Area | Classification | Decision / final gate |
|---|---|---|
| Current-main/source ancestry | NO_CONFLICT | Current main is source base; no intervening path collision |
| Account, Saved Locations, AuthGuard/session/startup, routes and service binding | NO_CONFLICT | No source file change; existing shell/private destination/session contracts remain |
| Wishlist / Home / Product Details | SAFE_TEXTUAL | Existing product identity, missing-product exclusion, duplicate navigation/removal guards and explore callback preserved |
| Recently Viewed and actions | SAFE_TEXTUAL | Same local/customer history, clear/cancel/remove/undo and Product Details callbacks; presentation and selectors change |
| Notifications / Purchases / Chat | SAFE_TEXTUAL | Destination builder and five critical action/pagination methods match main; same IDs, fallback, read mutation and processing locks |
| Coupons | SAFE_TEXTUAL | Same two views, truthful empty messages and explicit not-yet-open usage note; no economics |
| Nearby MD-19 | SAFE_TEXTUAL | Dialog becomes scrollable Final UI; same cancel/confirm keys, text and permission request only after consent |
| Cart MD-20/21/22 and seller MD-12 | SAFE_TEXTUAL | Scrollable Final dialog, button style and existing guards/cancel/confirm/one-mutation behavior retained |
| QR session MD-23 | SAFE_TEXTUAL | Theme, spacing, responsive QR size/state composition; token source, expiration, snapshot validation, summary consent, timer/retry/cancel contracts preserved |
| Shared loader/theme/snackbar | SHARED_COMPONENT_CHANGE_REQUIRED | Three explicitly declared source files; inspect all callers, targeted shared/adjacent tests, previous goldens and full regression |
| Approved W3B 09/11/12 | RECONCILIATION_REQUIRED | Bounded presentation corrections below after source merge; preserve real runtime/state/callbacks |
| W49 / W3B fixture branch | EXCLUDED | Neither branch is merged; no fixture class/import is copied into runtime |

Twenty-five critical methods match main after whitespace/trailing-comma
normalization: five Wishlist, five Notifications, three Recently Viewed, ten
QR timer/retry/validation/completion actions and two legacy location dialogs.
The complete _QrSessionCompletedView / State class span matches exactly.
Mixed presentation/action methods (history confirmation, consent, cart dialogs,
QR BlocConsumer branches) were reviewed directly. Model/Cubit/repository,
auth architecture, QR rules and review/rating eligibility have no source edits.

**SHARED_COMPONENT_CHANGE_REQUIRED: YES — source-owned, declared, bounded.**
Exact files:
- `lib/core/common/widgets/progress_indicator.dart`: labeled Final UI loader;
  retains size/color API and adds optional semantics label.
- `lib/core/ui/foundation/esnaftavar_theme.dart`: primary spinner and floating
  snackbar defaults; no global token family or configuration replacement.
- `lib/core/utils/helpers/helper_functions.dart`: typed snackbar color,
  typography/margin only; type/duration/hide/queue behavior retained.

W48 is the source writer; Integration owns combined acceptance. W49's existing
main Purchases/Reviews/Chat consume inherited theme and must be revalidated when
their own source integrates. Do not resolve hypothetical W49 edits by touching
its branch. No extra shared primitive change is planned in Integration.

## Product Owner-approved W3B 09–12 review

The reference review document was authored before approval and says OWNER REVIEW.
The current explicit task records Product Owner approval of all 12 at the exact
reference HEAD; that later authority governs this integration. Reference files
were read/extracted only under ignored .buildlog for comparison. They are fixture
prototypes, not runtime implementations to merge or cherry-pick.

| Ref / ID | Initial classification | Observed difference and planned resolution |
|---|---|---|
| 09 Wishlist / FS-21 | **RECONCILIATION_REQUIRED** | Two-column normal-text catalog and independent favorite action exist. Source uses cover, which can crop the approved contain product imagery; use contain with local spacing/surface and align favorite color to primary. Retain real images/prices/discounts and one-column narrow/large-text accessibility adaptation. |
| 10 Recently Viewed / FS-28 | **ACCEPTABLE_EQUIVALENT** | Same horizontal product rows, identity/brand/price, independent favorite/menu and clear confirmation. Existing inspect affordance, longer runtime text and scalable row height are supported behavior. No fixture data/date/grouping or new action is introduced. |
| 11 Notifications / FS-29 | **RECONCILIATION_REQUIRED** | Existing unread badge/real text/date/type and read-all remain valid; source lacks the approved visible destination arrow. Add it only from the existing canOpenDestination result; an unread system record must not gain a false target. Keep processing/read/navigation contracts. |
| 12 Coupons / FS-27 | **RECONCILIATION_REQUIRED** | Source underline tabs differ from approved filled segmented treatment. Recompose existing TabBar container/indicator/spacing while retaining controller, keys, two empty states and truthful usage-not-open note. |

Source 130% proofs were compared with approved 390px normal-text references;
their different text scale/fixture length is not itself a divergence. Final
integration adds normal-text real-runtime evidence and checks 320/390/430 at
130%, including affected goldens. Only intentional scoped visual proofs may be
updated; previous approved unrelated evidence must remain exact.

## Merge and validation contract

Semantic review permits a normal no-ff W48 merge followed by the three scoped
presentation reconciliations. This is not yet final visual/test acceptance.
Run W48/Wishlist/history/Notifications/Coupons targeted tests, then adjacent
Account/Saved Locations/Nearby/navigation/Auth/shared/seller/Cart/QR tests,
analyzer and one final combined full Flutter suite. Baseline **1841 + 102 = 1943**
before integration-specific tests. Explain every addition; retain the same six
conditional skips, no lost tests or weakened business assertions.

Recompute the full active row ledger, explicitly keep W49's eight reserved units
pending, update calibration and coordination and assess the only-W49 milestone.
Record final counts, fixes, proof review and normal branch/main publication after
all gates pass. No Figma, backend, remote Development, Production, taxonomy,
auth architecture, QR rule, eligibility, Ads or Reward economics operation.

## Final visual and semantic acceptance — PASS

Pre-merge review **f50f64d08c1c344c88fb5aabfa02883a109708b7** precedes normal
no-ff merge **499f0e2b8352e2bd4846b23c1cefd6ee2012a556**.
Integration presentation/test checkpoint:
**34361747055c71b3593d6d6516a82707b5966abb**. Text conflicts **0**.

| Approved reference | Initial review | Final acceptance | Real runtime proof |
|---|---|---|---|
| 09 Wishlist | RECONCILIATION_REQUIRED | **ACCEPTABLE_EQUIVALENT — resolved / PASS** | [390/100](../test/widget/w48/goldens/w48_integration_09_wishlist_390_100.png) |
| 10 Recently Viewed | ACCEPTABLE_EQUIVALENT | **ACCEPTABLE_EQUIVALENT / PASS**, runtime unchanged by Integration | [390/100](../test/widget/w48/goldens/w48_integration_10_recent_390_100.png) |
| 11 Notifications | RECONCILIATION_REQUIRED | **ACCEPTABLE_EQUIVALENT — resolved / PASS** | [390/100](../test/widget/w48/goldens/w48_integration_11_notifications_390_100.png) |
| 12 Coupons | RECONCILIATION_REQUIRED | **ACCEPTABLE_EQUIVALENT — resolved / PASS** | [390/100](../test/widget/w48/goldens/w48_integration_12_coupons_390_100.png) |

The accepted equivalents preserve approved composition and real state contracts,
not fixture values or pixel-identical text lengths. Wishlist has two columns at
390/100, contain images and an independent primary favorite control; its existing
narrow/130% single-column adaptation and real discount/fallback behavior remain.
Recently Viewed retains horizontal rows and existing inspect/favorite/history
actions. Notifications keeps its explicit unread badge/type label/processing UI
as a truthful equivalent and adds the approved visible arrow solely from the
existing destination predicate. Read-only system notifications gain no target.
Coupons uses the approved filled segmented treatment and keeps the additional
real-runtime notice that usage is not open. No business capability was added.

Eight new tests check real runtime composition, independent removal/navigation,
normal-text evidence and destination visibility for unread/read system,
suppressed order and custom target cases. The actual destination builder remains
exactly main's implementation. All existing tests/assertions are retained.

Only three runtime files differ from final W48 source: wishlist_view.dart,
customer_notifications_view.dart and customer_coupons_view.dart. Four W48 PNGs
were intentionally updated (two Wishlist, Notifications, Coupons); four new
real-runtime proofs added. The other **11 source PNGs** and **198 main PNGs**
remain exact. No source W3B fixture file/import or W49 branch was merged.

Final gates: **213 targeted PASS**, **1605 adjacent/shared PASS**, analyzer clean,
one full suite **1951 PASS / 0 FAIL / 6 unchanged opt-in skips**. Exact discovered
test paths match all **168 files**; 1841 main + 102 source + 8 integration explains
the full count. Initial new-test string-style notices were fixed before full
suite; no runtime failure, assertion weakening or skip was used to finish.

The four location reclassifications remain **INACTIVE_CONFIRMED**. No unresolved
semantic collision or additional owner decision remains. W48's three declared
shared files are accepted with caller regression; Integration adds no shared
primitive change. Later W49 integration must review its own diff against these
accepted shared defaults and the unchanged QR completion/rating boundary.

[Current inventory](UI_W48_POST_INTEGRATION_INVENTORY.md) has **8 remaining =
5 screens + 3 modals + 0 families**, Tier **3/4/1**, Figma **3/2/3**, all W49.
The nested QR completion/rating dependency remains recorded under that domain;
prototype approval is not counted as W49 completion.

Diff and added-line secret/PII scan **PASS**, no credential/email/phone finding;
synthetic fixtures and source media were reviewed locally. No Figma, Production,
remote Development, backend, taxonomy, auth architecture, QR rule or eligibility
change. Full result and Git publication: [W48 integration result](ASTRA_W48_INTEGRATION_RESULT.md).
