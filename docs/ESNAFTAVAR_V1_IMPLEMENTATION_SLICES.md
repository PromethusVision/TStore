# EsnaftaVar V1 — implementation slices and deployment gates

Status: **PLAN ONLY**. Baseline:
`33d0078380feebe1ca6051b72a37e3b536536ff9`. Product rules:
[canonical architecture](ESNAFTAVAR_V1_TRUST_COMMERCE_CANONICAL.md).
No slice below is implemented by Phase 1. Current working UI stays in place.

## Dependency order

```text
A catalog/listing/media ─→ F Campaign Lite ──────────────────┐
       │                                                    │
       └→ B purchase terms/QR claim/returns ─→ C reviews ─→ D badges
                    │                                       │
                    └→ H0 ledger/config ─→ E Reward ──────────┤
                               └────────→ G Ads ←────────────┘
                                              │
                             E + G + H0 ─→ H1 Merchant statements/settlement
                             G + 0016 ─→ I provider/marketing transport
                             all integrated capabilities ─→ J physical/release
```

H1 bounded read follow-through (2026-10-15): after integrated checkout E,
canonical §9.2 permits the existing H0/E balance and statement read surface.
This is a partial H1 delivery; G and approved O8 remain prerequisites for full
statement/settlement closure. No settlement workflow or economic activation is
advanced. See [local read-surface delivery](MERCHANT_STATEMENT_H1_HANDOFF.md).

H0 is intentionally moved before real monetary activation. H1 is the later full
Merchant balance presentation and policy-complete settlement. C/D do not require
Reward or Ads to exist; a customer can review a valid purchase without them.
E/G require H0 accounting but cannot consume each other's eligibility/rotation rules.
A and B need not enable every downstream capability in the same deployment.

Before every production slice: refresh main/source fingerprint, check active
changes in shared files, rehearse an individually numbered migration locally and
in authorized test environment, inspect approved security/taxonomy manifests,
back up where applicable, get explicit Product Owner deployment/write authority.
Feature flags default OFF; existing versioned read paths continue until both
clients and server capability proofs are ready. A successful local test is not
permission to apply a proposal remotely.

## A — Product identity submission, listing images and hero source

- **DB:** extend stable products via identity/type metadata and identifiers;
  candidate submissions/decision audit; listing_images and owned upload intents.
  Keep shop_products.price/availability and existing UUIDs; preserve legacy fields
  until compatibility projections are verified. New product must receive a valid
  assignable canonical category/publication mapping through existing gates.
- **RPC/server:** candidate lookup/submit/review; exact GTIN duplicate resolution;
  owned image upload/finalize/reorder/select-primary; ranked seller read DTO with
  display/organic rank, images and provenance. Similarity suggests only.
- **Flutter:** preserve current add-from-catalog; later add missing-product action,
  owned image controls and ranked-image binding into existing Product Details/
  Seller Comparison hero slots. Product/listing identity are typed separately.
  No UI redesign and no guessed central prices/stock.
- **RLS:** owner/merchant candidate and image intent writes; public only approved
  identity and published media. Admin catalog decisions need server role. Review
  Storage path/MIME/size grants independently; no direct global product write.
- **Tests:** GTIN check digit/normalization and concurrent duplicate; ambiguous
  suggestion never merges; wrong shop upload; orphan/failed upload; atomic primary
  uniqueness; sort/filter/location changes → correct hero and source/fallback;
  zero sellers; taxonomy denied categories; Customer/Merchant regression.
- **Migration risk:** **medium/high**, shared catalogue + Storage + canonical
  publication. Never rewrite applied 0012–0015 or delete legacy products.
- **Production requirements:** authorized schema/storage apply; approved category
  assignment/publish workflow; client/server capability compatibility; rollback
  to old read binding without deleting newly uploaded evidence.

### A follow-through — Merchant daily operations (approved 2026-10-14)

Bounded Merchant V1/A completion under canonical §4.1: actionable overview,
submission status counts, unfinished photo recovery, existing inbox reuse and
fresh reads after mutations/resume. Preserve the accepted UI direction and
boolean availability; do not activate catalog approval or economic metrics.
Validate catalog → listing → photo → fresh session → Customer image using the
existing contracts. Distinguish local database tests, real Storage HTTP and device
acceptance. Any new summary endpoint is owner-scoped and read-only. This does not
change the A–J dependency order or grant Production/remote migration authority.

### Cross-slice Merchant session resilience — 2026-10-17

After G preparation integration (`0c79dca1`), harden the existing Merchant host
under canonical §4.2: replace private route/overlay/message scopes at authority
boundaries, serialize Auth callbacks and logout, reject stale continuations, and
bound access reads with explicit recovery. Preserve normal refresh and draft
editing. This is a client-only lifecycle correction, requiring no migration or
new product policy. Validate actual QR confirmation, nested editor, root overlay,
late-write, same-account return, ownership and failure/retry scenarios alongside
existing Merchant/Customer regressions. Full G/H1/I/J gates remain unchanged.
See [handoff](MERCHANT_SESSION_RESILIENCE_HANDOFF.md).

### A daily-operation recovery follow-through — 2026-10-17

After I1 integration (`116557fd`), canonical §4.3 authorizes one coherent local
reliability package: session-fenced catalog/profile/media continuations, safe
photo acknowledgement recovery, preserved edits with explicit conflict review,
bounded reads and unchanged exact-request submission retry. Reuse current
optimistic writes, upload intents and owner reads; no new migration or product
policy. Validate adapter transport races, UI recovery/navigation, real local
Auth/Storage contracts, full Flutter regressions and both debug artifacts.
Full G/H1/I/J and remote rollout gates stay open.
See [delivery and verification](MERCHANT_CATALOG_RECOVERY_HANDOFF.md).

## B — Existing QR, immutable purchase terms, claim, returns and invalidation

- **DB:** extend existing qr_sessions through claim/manual-code companions, device
  session audit and versioned capability; purchase_terms supplement the existing
  verified_transactions/items; append-only return headers/items and fraud decisions.
  No second verified-purchase-items table or independent QR token stack.
- **RPC/server:** claim_existing_qr_v2, reconcile_claim_v2, complete_existing_qr_v2,
  cancel_claim_v2, record_purchase_return_v2, invalidate_purchase_v2. Keep current
  create/get/confirm semantics for legacy sessions while feature OFF. Rate-limit
  shop-scoped six-digit lookup and bind authenticated user/session/device.
  Finalization atomically creates one original purchase and its outbox event.
- **Flutter:** extend existing QrSessionRepository and QR cubit states with
  scan-deadline/completion-deadline distinction and manual code; add product UUID
  to existing purchase item DTO; truthful return reference/status. No offline
  success or invented refund execution.
- **RLS:** current exact-owner/customer participant boundaries; raw token/code
  digests and device session audit server-only. Returns require exact participating
  merchant/authorized process; invalidation only trusted admin with reason.
- **Tests:** scan before120sec then completion within proposed10min; expired first
  scan; simultaneous scan/code; double finalization; account/device revocation;
  old endpoint cannot mutate claimed-v2 expiry; changed cart/price/quote; uncertain
  response reconciliation; excessive/concurrent partial returns; immutable
  item/terms audit; legacy account deletion/pseudonymization compatibility.
- **Migration risk:** **high**, existing confirmed-purchase and QR invariants.
  Legacy purchase terms must be marked unknown, never guessed/backdated.
- **Production requirements:** explicit schema/RPC activation authority; protocol
  flag and old-client compatibility plan; required session provenance; approved
  two-session enforcement mechanism and abuse limits. Physical QR acceptance is J.

### B local implementation authorization — 2026-10-15

The approved local B scope and engineering defaults are canonical §5.1. Delivery
evidence is recorded in [Slice B delivery](SLICE_B_DELIVERY.md). Quote-only terms
are an explicit boundary: economic discounts/coupon/hold/ledger activation remains
later work. Client and server flags default OFF; this does not advance the J
physical gate. Local Storage, managed Auth and multi-connection PostgreSQL
acceptance must be distinguished from ephemeral SQL and mocked client tests.

### A+B acceptance follow-through — authorized 2026-10-15

Canonical §5.2 authorizes bounded local acceptance/hardening on the integrated
A+B baseline. See [acceptance delivery](MERCHANT_AB_ACCEPTANCE_DELIVERY.md) for
real native PostgreSQL evidence and the managed Auth/Storage acceptance, now
**PASS locally** after the Product Owner restored Docker on 2026-10-15. The
21-group managed run includes actual logout rejection on claimed QR operations
and fresh-session signed-image download. Physical two-device J remains OPEN.
This is validation of A+B, not authorization to start C–J or activate
Production. No new migration is required by the current acceptance findings.

### B/E Merchant transaction recovery follow-through — 2026-10-17

After `aca7e985`, canonical §5.3 bounds one coherent local package: recover
uncertain first QR claims, preserve known claim identity/terms, fence stale Auth
errors, and complete durable exact-return retry, local acknowledgement cleanup,
fresh purchase history and protected navigation. Reuse current B/E RPCs, immutable
purchase evidence and the existing account/purchase local retry key. Additive0030
corrects an evidenced actor-identifier projection leak without changing historical
migrations, grants, stored evidence or economics. No refund/provider action is
introduced. Verify a populated local upgrade and transport faults,
controller/storage races, widget/render states, full Flutter regressions, both
debug artifacts and real local Auth/PostgREST/PostgreSQL including checkout
regressions. Physical J and remote rollout remain OPEN.
See [handoff](MERCHANT_COMMERCE_RECOVERY_HANDOFF.md).

## C — Review entitlements, three service criteria, audit and moderation

**Authorized locally on 2026-10-15.** Execute as one complete engineering package
from integrated baseline `cc2d4f7e`, on `agent/merchant-reviews-slice-c`. Canonical
§6.1 records authority and rollout boundaries. Implementation and verification
progress: `MERCHANT_SLICE_C_WORKLOG.md`.

**Local delivery PASS (2026-10-15):** implementation, 2,385 Flutter tests,
17 native database groups and 28 real local managed-service groups passed.
Six existing opt-in live tests remain skipped. See `MERCHANT_SLICE_C_DELIVERY.md`
for evidence and Integration Agent handoff. Main integration, remote application,
privacy/import approval and physical two-device acceptance remain separate gates.

- **DB:** purchase×distinct-product entitlement, service evaluation unique purchase,
  immutable product review revisions/visibility/reopening events, one root reply,
  moderation/report events. Reuse current reviews root and user×product uniqueness.
  Historical scalar shop ratings remain legacy and never synthesize criteria.
- **RPC/server:** existing review RPC v2 adapters; server24h edit/reopen deadline,
  newer-entitlement one-time consumption; public-withdraw; service submit requiring
  all3 criteria; merchant own-origin reply/report; reasoned admin moderation.
  Public product aggregate uses one visible valid review per user/product; merchant
  service aggregate uses latest valid evaluation per user/shop.
- **Flutter:** extend existing Reviews/ShopRating/Purchases repositories, failure
  types and capability DTOs; enable optional per-product evaluation + one service
  evaluation (initial submitted purchase evaluation requires all3 service criteria;
  later products reuse that one evaluation); show edit deadline and verified evidence;
  later compact reply and
  report controls inside existing surfaces. No merchant written-review feature.
- **RLS:** customer own rights; merchant cannot delete/score-edit or access other
  shop origins; public projection minimizes identity; audits/admin reasons private.
  Review withdrawal and account deletion must not erase immutable commerce facts
  or accidentally block current self-delete through new FKs.
- **Tests:** quantity3 same product=one entitlement; 3 distinct products=3+1;
  new purchase reopens same public review/count; repeated request cannot extend
  deadline; exact boundary24h; latest service rating; cross-shop reply denial;
  hide/restore/audit; genuine return keeps experience; fraud invalidates rights;
  public averages and deletion/retention regression.
- **Migration risk:** **high**, aggregation, hard-delete replacement and historical
  evidence. Add/read in parallel then capability cutover; no history rewrite.
- **Production requirements:** approved evidence import and privacy/moderation
  process; authorized migrations/RPCs; joint client compatibility acceptance.

## D — Server badge projections and milestone history

**Authorized locally with F on 2026-10-15**, from integrated `d013b761`, on
`agent/merchant-trust-campaigns-df`. Canonical §7.1–7.2 records scope and gates.
Local implementation and native/managed acceptance are complete. Delivery and
release gates: `MERCHANT_DF_HANDOFF.md`; audit: `MERCHANT_DF_WORKLOG.md`.

- **DB:** versioned local areas/assignments, badge rule config, durable award/
  correction events and rebuildable current eligibility projections. Uses valid
  verified purchase and C evaluation evidence rather than new economic events.
- **RPC/server:** read_badges_v1, read_my_trust_v1, trusted process_badge_refresh_v1
  and enqueue_badge_backfill_v1; scheduled rolling90-day
  expiry; local-area assignment review. Exact aggregate thresholds before rounding.
  No hysteresis/grace and no ranking/Reward side effect.
- **Flutter:** small name-adjacent badge composition, highest milestone per family,
  top2–3 +N, complete profile history and persistent outside-tap popover.
- **RLS:** public eligibility/title/explanation only; private fraud/audit/evidence
  IDs are excluded. No client award or threshold mutation.
- **Tests:** 4.70/4.80 and19/20 customer boundaries; repeated customer dedup;
  product ratings at another shop excluded; local-area boundary/ties/N<10;
  rolling90-day expiry removes badge; return/fraud/hidden-valid distinctions;
  review edit never increments count; milestone history vs current family display;
  width/accessibility/popover interaction without redesign.
- **Migration risk:** **medium**, new projections; geography/KVKK policy dependencies.
- **Production requirements:** reviewed area definition/dataset and metric
  provenance; server scheduled jobs enabled with reconciled event cursor.

## H0 — Monetary authority, immutable ledger and versioned policy

Local implementation is delivered from integrated D/F `6ef06be8` on
`agent/merchant-ledger-h0`, following the Product Owner's next-work instruction.
Canonical §9.1 records the bounded accounting scope, trusted-source assumptions
and disabled economic actions. Local evidence: 53 native PostgreSQL groups,
44 managed-service groups, 2407 Flutter tests (6 existing skips), clean analyzer
and both development debug APKs. Handoff: `MERCHANT_H0_HANDOFF.md`; audit:
`MERCHANT_H0_WORKLOG.md`. Integration and every remote/economic gate remain separate.

- **DB:** immutable commerce policy versions, typed ledger accounts/journals/
  postings, monetary source references, offset obligations, event-consumer dedup.
  No seeded live balance, funding, payment provider or mutable cash field.
- **RPC/server:** internal post_balanced_journal_v1, idempotent source claim,
  account-balance projection and append-reversal authority. Economic RPC writes
  related journal in the same transaction. Authenticate merchant service debts;
  no customer online-payment endpoint.
- **Flutter:** minimal read DTO/interface design only until E/H1; monetary amounts
  in integer minor units, display formatting at UI boundary.
- **RLS:** ledger append and economic source mutation server-only; customer own
  coupon/accrual projection and merchant own summarized receivable when activated.
  Privileged admin correction audited; no arbitrary client posting RPC.
- **Tests:** journals balance by currency; source idempotency; duplicate/partial
  transaction rollback; immutable entries; coupon-source-only mandatory reserve;
  unused referral funds bypass reserve; reserve-first partial service offset;
  no overdraft/double recovery; privacy/cross-account isolation.
- **Migration risk:** **high**, economic authority even before any real funding.
- **Production requirements:** reviewed account map, finance/legal policy,
  reconciliation owner and authorized schema deployment. Funding/redemption stays
  OFF until the whole E or G transaction and relevant external contracts are ready.

## E — Reward Counter, Referral Package and coupon integration

**E earning lifecycle authorized locally after H0 integration (`b022f5f3`).**
The Product Owner requested the next large implementation package. Scope and
limits are canonical §8.1 and `MERCHANT_REWARD_E_WORKLOG.md`. This is not approval
for provider funding, remote activation, discounted/coupon-funded checkout,
partially spent offsets, Ads or settlement. Those gates remain separate.

**Local earning implementation delivered:** 0024 package/capacity/reservation,
unchanged-sale attestation, contribution/maturity/unspent compensation and both
app bindings. Evidence and release boundaries: `MERCHANT_REWARD_E_HANDOFF.md`.
At that earning-only delivery, redemption/customer approval/O7 remained open;
the subsequent extension is recorded below.

**Next local checkout package authorized after earning integration (`af9d5965`).**
Canonical §8.2 and `MERCHANT_CHECKOUT_E_WORKLOG.md` define customer consent,
unchanged-price physical coupon checkout, exact allocations, atomic receivable/
earning and source-aware O7 compensation. Historical migration 0024 is preserved;
0025 extends it with a separate default-OFF capability. This package does not
authorize hosted activation, arbitrary merchant discounts, coupon-restoration
policy, cash refunds, provider/settlement execution or physical acceptance.
Local implementation and validation are delivered in
`MERCHANT_CHECKOUT_E_HANDOFF.md`; this does not mark the external E/O8 gates closed.
Integration correction 0026 enforces the already-frozen net threshold immediately
at coupon approval and prevents live-consent retries from reacquiring on gross
value. Acceptance now observes capacity/funds before completion; 0025 is preserved.

- **DB:** package/terms snapshots, reservation/hold projections, chronological
  append-only contribution/reversal events, issued coupons + immutable five-source
  links, coupon redemption allocations, acceptance preference/forced-lock state.
  H0 posts package fund/service fee, holds, coupon liability and receivables.
- **RPC/server:** buy_or_activate_referral_package_v1 (trusted service funding);
  read_reward_state_v1; ensure/release_reservation_v1; transition_checkout_hold_v1;
  evaluate_existing_purchase_v1; mature_issue_v1; authorize_coupon_use_v1;
  final QR+coupon+slot+ledger atomic RPC; package-expiry/return/admin reconciliation.
  All V1 values read from published versioned server config.
- **Flutter:** bind existing RewardRepository stream and counter, guest0/5 routing,
  pending vs spendable250TL state; Merchant package/acceptance surfaces and Cart/
  QR reservation timer from server. No app restart reset or hardcoded authority.
- **RLS:** guest creates nothing; own reward/coupon state and owner package summary;
  no direct slot/fund/coupon update. Admin reversals with reason and provenance.
- **Tests:** 750−250=500 earns; 500−250 and500−500 do not; same shop repeated5
  allowed; 100 slots concurrent contention; one active package/user reservation;
  qty edits never reset30min; release/reacquire fixed attempt deadline; QR-expiry
  transition hold; exact90days unused×50 refund/service fee retained;24h vs longer
  snapshotted policy; partial return threshold;5-source maturity before spend;
  immutable chronology/rebuild; partial-spent fraud future offset/no cash debt;
  acceptance forced until active+holds close; full reset/account-switch matrix.
- **Migration risk:** **very high**, funded incentive and financial concurrency.
- **Production requirements:** explicit funding/economic/rollout authorization,
  external finance/legal handling, monitored reconciliation/capacity runbook,
  H0+B deployed safely; real provider billing not inferred from local success.

## F — Merchant Campaign / Offer Creator Lite

**Authorized locally with D on 2026-10-15.** Price/percentage publication remains
separately gated because B currently records quote-only sales; no cart-discount
or financial authority is introduced. Local implementation and native/managed
acceptance are complete. See canonical §7.1–7.2 and `MERCHANT_DF_HANDOFF.md`.
The corrected delivery includes forward migration 0022 for required typed amounts
and SQL/HTTP missing/null regression coverage; the initial `ea799206` is not the
integration target by itself.

- **DB:** offers, owned listing membership and immutable revision/selection evidence.
  Types discounted price, percent and announcement; scope listing/multiple/store.
- **RPC/server:** owned create/update/deactivate/read and structured validation.
  Informational offer does not calculate or apply a platform cart discount.
- **Flutter:** “Kampanyalar → Yeni Kampanya Oluştur”, dates/copy/type fields
  and selection from existing owned imagery. Preserve existing navigation style.
- **RLS:** exact merchant ownership; public current eligible copy; no another
  merchant listing or image reference.
- **Tests:** date/type limits; one/many/store scopes; image ownership; real structured
  percentage claim; deactivation/expiry; no cart price/reward mutation.
- **Migration risk:** **medium**, mostly additive; business claims validation needed.
- **Production requirements:** authorized schema/RPCs and approved offer wording;
  no Ads purchase/push or automatic discount rollout implied.

## G — Ads visibility, structured copy and fair scheduling

### G preparation increment: Merchant Tanıtım Merkezi

The next bounded implementation follows canonical §11.1: default-OFF owned
draft workspace, structured source selectors, server-generated preview, existing
media selection, stale-source detection, revision history, archive/restore and
exact-request retry. Forward migration0028 builds on current catalog/F/session
contracts; it does not change prior migrations or Customer screens.

This is **partial G**, not advertising delivery acceptance. Purchase/extension,
reserve-first service debt, sponsored placements, fairness/measurement,
audience/rolling quotas and shared push scheduling remain the scope below.
No open commercial/retention/targeting decision is silently resolved. See
`MERCHANT_PROMOTION_G_HANDOFF.md` for the exact local validation and remote gates.

- **DB:** one visibility package per shop, immutable extension/purchase intervals,
  one push entitlement per purchased interval, serving/impression/click attribution,
  copy revisions and audience queue/rolling24h quota claims. Reference F or shop;
  do not overload banners as reward funding/Ads ledger.
- **RPC/server:** service purchase/extend using H0 reserve-first debt offset;
  select sponsored candidates AFTER hard filters; fair max3 + user-sort-internal
  ordering; organic merge/dedup; Home max3 sponsored cards preserving editorial;
  grounded structured copy generator; oldest eligible entitlement scheduler;
  revalidate stale claims; replay-safe event and attribution collection.
- **Flutter:** later bind labeled “Sponsorlu” results/carousel slots and Merchant
  preview/select/reporting. Price/duration from server; paid status separate badges.
- **RLS:** owned configuration/report summary; public only selected grounded ads;
  private marketing audience/quotas and publisher records. No client ranking weight,
  entitlement grant or abuse-prone raw impression INSERT.
- **Tests:**0/1/2/3/>3 sponsors; absent exact product, out of radius, unavailable and
  failed filters excluded; eligible fair rotation; extension adds time not weight;
  internal price sort; sponsor/organic one occurrence; Home editorial preserved;
  ad copy unsupported claim denial; visibility7day vs push30day; campaign-recipient
  dedup; per-user1 sponsored+1 general rolling24h across devices; oldest queue;
  quota deferral leaves entitlement; stale claim refresh; attribution not causality.
- **Migration risk:** **high**, paid promises, ranking and measurement integrity.
- **Production requirements:** explicit commercial authorization and versioned
  price/config; finance/legal policy; target/consent/retention review; fairness
  observability and exact service-purchase reconciliation. Sending is gated by I.

### F/G management recovery follow-through — 2026-10-17

After `298290d8`, canonical §11.2 bounds one complete local package across
Campaign Lite and Tanıtım Merkezi: stable-session continuation checks, serialized
uncertain writes, preserved edits with explicit conflict review, exact owned
detail reads, bounded selectors/pages and protected navigation. Additive0031
reuses existing F/G projections and authority; no economic or provider activation.
Validate stale session/error/signing races, resume while writing, exact retries,
concurrent revisions, source drift, ownership/grants, narrow renders, full Flutter
regressions and both debug artifacts. Historical migrations and Customer layouts
remain unchanged. See `MERCHANT_MANAGEMENT_RECOVERY_HANDOFF.md` for evidence.

## H1 — Merchant statement, reserve and settlement

- **DB:** H0-ledger projections for blocked/pending/reserve/withdrawable/paid/
  reversals, immutable settlement request/outcome evidence; no second balance.
- **RPC/server:** read_merchant_statement_v1 and authorized settlement workflow
  when policy exists. Coupon receivables refill1000TL reserve; other sources stay
  separate. Platform-service debt consumes reserve FIRST. Posted settlement
  requires externally confirmed outcome, not a client button.
- **Flutter:** “Hesap Bakiyesi” with statement/history and source/type grouping;
  available withdrawal UI only when server policy grants it. No top-up or transfer.
- **RLS:** own merchant statement; detailed cross-merchant/platform accounting
  private; external settlement confirmation admin/server-only with audit.
- **Tests:** coupon vs unused-fund source discrimination; threshold1000 exact;
  reserve refill after offset;500 reserve toward1000 service; blocked/settled and
  reversal reconciliation; simultaneous withdraw/service debt; missing legal policy
  prevents payout; existing Merchant auth/navigation unaffected.
- **Migration risk:** **very high** if external payout is enabled, otherwise additive
  projection. Customer card payment remains excluded.
- **Production requirements:** final withdrawal/closure/legal/provider policy,
  settlement operations owner and explicit payout/write authorization. No schedule
  or payment-provider behavior is selected by this plan.

## I — Shared notification/provider integration

- **DB:** separately review/deploy unchanged0016 foundation, then approved additive
  G scheduler/claim contract. Keep notifications and push_devices/preferences/
  delivery keys canonical; no second inbox or notification-auth system.
- **RPC/server:** existing register/disable/preferences/lookup ports; one trusted
  queue/provider adapter; user-based quota before device fan-out; uncertain send
  reconciliation and consent/content recheck. Day caps do not govern service lane.
- **Flutter:** existing PushCoordinator in both hosts; explicit permission action,
  installation persistence, rotate serially, revoke before logout/account switch,
  existing authenticated destination lookup. Keep pending-config truthfulness.
- **RLS:** no token list exposure; own consent read; server sending only. Secrets
  belong outside Flutter/repo in approved server management.
- **Tests:** foreground/background/terminated; opt-in/out; user/role switch;
  revoked-token failure; duplicate tap/send; cross-device quota; denied OS permission;
  provider accepted vs displayed semantics; marketing window and stale offer.
- **Migration risk:** **high**, outbound delivery/privacy and consent.
- **Production requirements:** matching Firebase/APNs configuration, secret handling
  approval, reviewed transport deployment, nonproduction physical evidence,
  explicit send/rollout authority. No OS delivery guarantee.

### I0 preparation increment (before full I)

- Rehearse unchanged engagement0016 plus separate0029 proposal explicitly in
  fresh local fixtures, outside automatic migration discovery.
- Use the same inbox/devices/preferences/delivery keys. No Customer/Merchant UI
  redesign, dependency or provider SDK.
- Default-OFF service-only worker/store with committed claim/begin boundaries,
  live-session and revision checks, safe terminal acknowledgement and bounded
  fanout. All marketing remains deferred pending G/O10.
- Prove concurrent claims/begin, first opt-out, token rotation, account/session
  change, unknown acknowledgement and stale-token disable using real PostgreSQL
  and local Auth/PostgREST; retain adjacent commerce regressions.
- This is local preparation only. Full I, O10 policy, real provider sends and
  physical J remain OPEN. See canonical12.1 for the precise safety/availability
  tradeoff and provider-call boundary.

### I1 local client preparation (before full I)

- Reuse the shared coordinator, device/preference RPCs and authenticated inbox.
  Prepare only the loopback Merchant composition with schema switch OFF and
  provider unconfigured. Preserve Customer hosts/layout and existing consent.
- Serialize initial enrollment, early token rotation, uncertain writes and
  revoke-before-logout. Fence same-user replacement Auth sessions as well as
  account/role/authority changes; make errors recoverable and truthful.
- Persist only role-scoped installation UUID/cleanup marker. Interrupted-process
  recovery invalidates the old provider token before a new installation is used.
  A configured provider must prove token deletion; no silent deletion success.
- Test lifecycle races, restart/cleanup failures, stale HTTP responses, tap
  validation/dedup, Merchant settings/inbox/logout and narrow-screen rendering.
  This increment does not supply real provider or physical acceptance evidence.
- Canonical12.2 defines recovery limitations. Full I and J remain OPEN; no remote
  apply, SDK setup, marketing scheduling or automatic re-enrollment is authorized.

## J — Physical two-device E2E and release validation

- **DB:** no speculative migration; compare approved schema/grant/manifest and
  reconcile test evidence. Never run blind Production fixture cleanup.
- **RPC/server:** observe existing versioned contracts across customer and exact
  owner merchant; verify one purchase/entitlement/contribution/ledger outcome.
- **Flutter:** real Customer/Merchant device artifacts from exact reviewed commits;
  camera/manual-code, backgrounding, auth/device lifecycle, local failure paths,
  granted settings and authoritative history/reward/review surfaces.
- **RLS:** wrong merchant/customer/expired/replayed codes denied; minimized history
  and no cross-user reads; device/session audit agrees with server principal.
- **Tests:** two physical devices, both consume channels, deadline split and last
  reserved slot; returns/review rights/reward maturity/coupon partial use; Ads/push
  where approved; release identity/signing/callback checks and store acceptance.
- **Migration risk:** no new migration by default; live fixtures carry operational
  risk and require exact scope/cleanup authorization.
- **Production requirements:** explicit physical/live test and fixture authority,
  reviewed signed artifacts/legal surfaces/runbooks and final owner acceptance.
  Phase 1 and Merchant local-core tests cannot declare this gate PASS.

### J0 — Merchant Android pilot runtime preparation (2026-10-17)

After `6b79a4e9`, canonical §4.4 bounds a preparatory delivery: isolated Android
pilot flavor/entrypoint, nonproduction configuration validation, shared Merchant
composition, separate callback and serialized password recovery with restart
protection. Existing Customer and local Merchant entrypoints retain their behavior.
No new dependency, migration or backend permission is introduced.

Validate configuration/credential rejection, cross-app callbacks, PKCE proof,
late/session-replacement and uncertain-write recovery, root-overlay removal,
small-screen forms, Gradle flavor/config/signing guards and adjacent regressions.
This does not close J: remote configuration/apply, real email, exact signed artifact,
physical two-device evidence and Product Owner release acceptance remain OPEN.
An unconfigured debug artifact is not distributable. The initial base-core pilot
composition is not a waiver of any later business feature or FROZEN rule.
See [delivery](MERCHANT_PILOT_RUNTIME_HANDOFF.md).

J0 integration rejected `ef216b3a` after two real-SDK response races. Corrective
validation must delay actual GoTrue HTTP/PKCE-storage completions across account
replacement, same-account new sessions, logout, away-and-back and missing
acknowledgements; assert both JWT subject and stored user remain consistent.
Response staging must protect shared Auth before mutation, not only detect the
problem afterwards. The prior delivery's test counts do not supersede that FAIL.

### J1 — Base-core backend and real-repository local rehearsal (2026-10-17)

After integrated J0 (`c801292b`), canonical §4.5 defines a bounded local package.
Audit the existing core runtime contracts, install only the explicit unchanged
Development base + A/operations chain into a fresh owned local stack, and execute
actual Merchant and matching Customer repositories against Auth/PostgREST/Storage.
Include deliberately broken schema/grant/policy/Storage variants, role/owner
denials, default-OFF assertions and exact source/schema fingerprints. Preserve the
existing extended A–I acceptance runners; this narrower profile supplements them.

No runtime feature, new migration, provider or remote apply is authorized by J1.
Use [handoff and reproduction](MERCHANT_PILOT_BACKEND_HANDOFF.md) and the dated
`merchant_pilot_backend_{contract,acceptance}.json` artifacts. Missing real backend,
callback/mail, physical/release and operational evidence still leaves J OPEN.

### J2 — Guarded pilot preparation and read-only hosted comparison (2026-10-17)

After J1 integration (`55cee012`), canonical §4.6 authorizes local preparation.
Use the unchanged Development ledger0001–0011 as a populated upgrade baseline,
then rehearse the atomic catalog-media0016 + operations0017 candidate. Separate
explicit taxonomy activation from schema, shared Auth callback proposals and
cohort identities. Preserve category policy/review metadata; do not use the
extended synthetic fixture's policy overrides as a real activation plan.

Deliver an offline bundle generator, per-file hashes, strict target/source/proof
checks, independent review scopes, rollback/replay/drift/concurrency tests and
an actual Flutter-repository journey after the candidate upgrade. Existing
extended runners and Customer runtime remain unchanged.

Read-only hosted comparison initially rejected the generic local baseline:
narrower service-role grants, infrastructure defaults/managed RLS trigger and
corrupted notification text differ. Reproduce the pinned observed profile locally
and require exact metadata equality before rehearsing the candidate. This mirror
and18-group rehearsal passed. A matching captured baseline permits an approval
proposal, not remote execution, notification repair or permission expansion.
The owner confirmed Esenler and broad-sector intent; exact participants, category
leaves, service capabilities and catalog preparation remain explicit open items.

Use [handoff](MERCHANT_PILOT_PREPARATION_HANDOFF.md),
[approval packet](MERCHANT_PILOT_APPROVAL_PACKET.md) and the dated
`merchant_pilot_preparation_*` / `merchant_pilot_remote_observation.json` evidence.
J2 supplies local preparation, not remote apply or final J readiness.

### J3 — Approved A-only Development installation (2026-10-17)

After J2 integration PASS (`e839a25a`), canonical §4.7 records explicit owner
authorization for review-packet item A on `tnipyxnvhgelwdpykyez`, plus acceptance
of broad-sector intake with gradual cohorts and the existing service boundaries.
Only the reviewed, unchanged catalog-media0016 + operations0017 pair was applied.
Its approved plan, source hashes, fresh baseline and absence of a competing
installation were checked first; the single atomic operation committed once.

Hosted read-only postchecks PASS: 13 ledger entries, original eleven preserved,
both new stored SQL hashes match approved sources, 35 public tables with RLS,
required owner/Customer RPC permissions, private media bucket, decisions OFF,
zero products/identities and unchanged captured original schema/taxonomy hashes.
These are actual hosted structural observations; local J2 behavioral tests remain
separate evidence. No hosted account journey or physical device test was run.

See [installation handoff](MERCHANT_PILOT_TEST_INSTALLATION_HANDOFF.md), its
sanitized JSON receipt and reproducible read-only SQL. No app, dependency,
migration-source or feature-default change. B–E remain unapproved, Production is
excluded and only Integration Agent may merge the documentation task branch.
J remains OPEN pending catalog/cohort, Auth/mail/provider, physical QR and release
acceptance. Do not replay the already-applied A candidate.

### J4 — Notification repair and first-cohort readiness preparation (2026-10-17)

Canonical §4.8 bounds the next local package after J3 integration (`ad42c92d`).
Prepare a separate E review source and atomic wrapper for the two existing
notification functions, exact baseline/token/source checks and one forward ledger
entry. Rehearse on an owned post-A mirror with populated notification/history
rows; prove drift/replay/concurrency rejection, late-error rollback, function
authority preservation, canonical Turkish output and real Auth inbox isolation.
Keep C callback matching, B category proposals and D private provisioning gates
independent. Produce an offline, source-bound review bundle with incomplete intake
explicitly identified; no automatic A replay or account/catalog SQL is generated.

No Customer/app runtime, dependency, historical migration, notification provider
or service-business capability changes. This package does not itself authorize
any hosted repair or Auth save. Use [handoff](MERCHANT_PILOT_LAUNCH_PREPARATION_HANDOFF.md)
and [intake guide](MERCHANT_PILOT_INTAKE_GUIDE.md). J remains OPEN.

### J5 — Approved C/E Development application (2026-10-17)

Following J4 integration (`e7efc4d6`), canonical §4.9 records explicit owner
authorization and completed C/E application on `tnipyxnvhgelwdpykyez` only.
Fresh URL read, exact additive save and reload verification passed. E used the
unchanged source-bound J4 wrapper after exact baseline/concurrency checks; it
committed once, with independent read-only postchecks matching local-proved schema,
function and ledger hashes. Function authority, original 13 ledger/source hashes,
taxonomy, RLS, catalog decisions and notification row fingerprints were preserved.

Git changes contain documentation and sanitized evidence only. Main integration
must not replay A/E. See [handoff](MERCHANT_PILOT_TEST_CE_HANDOFF.md). B/D, real mail
and device callbacks, provider configuration, physical QR, signed distribution,
Production and final pilot acceptance retain separate gates. J remains OPEN.

### J6 — First-cohort category/catalog/account preparation (2026-10-17)

Following integrated J5 (`8031bad3`), canonical §4.10 authorizes local preparation
with actual participants/products still unknown. Add source-bound offline intake,
minimized observation, separate guarded B and existing-account role-D candidates,
and explicit existing-catalog identity/GTIN matching. No Auth creation, catalog
materialization, price invention, submission-decision activation or A/C/E replay.

Rehearse only on a new owned stack matching the installed post-C/E structure:
state/token/authority/concurrency/replay/rollback guards, exact category/role
changes, preserved shared product identity, real Auth owner isolation and the
existing complete Flutter repository journey. Synthetic fixture products are
not a remote publication method. No app/dependency/historical migration changes.

Use [J6 handoff](MERCHANT_PILOT_COHORT_HANDOFF.md). Default output contains no write
SQL. Real B/D approval awaits selected facts and fresh observations; controlled
new-product materialization and the legacy-price/read contract remain a distinct
implementation gate before catalog population. Production and full J stay OPEN.

### J7 — Controlled catalog publication and legacy-price compatibility (2026-10-18)

Following integrated J6 (`465d8842`), implement canonical §4.11 locally: private
operator publication of exact pending physical-product submissions, append-only
batch receipts, atomic identity/GTIN/decision materialization and explicit shared
target selection. Existing `decide_catalog_submission_v1` remains OFF. The schema
candidate is Development-only; Production canonical assignment is never bypassed.

Tagged zero is a storage compatibility sentinel, not an offer. Preserve legacy
DTO numeric parsing while current Customer price fallbacks suppress tagged central
price/discount and retain listing-price precedence. No layout redesign, dependency
change, global config change, economic activation or historical migration rewrite.
Compatible clients must be reviewed before first real publication; old clients
that ignore the marker remain a deployment gate.

Rehearse exact post-C/E schema → proposed installation → selected publication →
actual Merchant listing/media/fresh-session/Customer/purchase repositories. Cover
permission and state drift, Auth races, whole-batch rollback, GTIN/similarity/brand
conflicts, unique ownership, replay/lost acknowledgement and immutable evidence.
Keep prior cohort category/role preparation available on the exact new schema.

Use [J7 handoff](MERCHANT_PILOT_CATALOG_PUBLICATION_HANDOFF.md). The default bundle
contains a **schema review candidate**, but no product publication SQL when real
inputs are missing. Integration merges code/evidence only. Hosted schema apply
and each real row batch need separate approval; Production and full J stay OPEN.

### J8 — Approved Development catalog infrastructure application (2026-10-18)

Following J7 integration (`50c1b16c`), explicit owner approval authorized only the
private schema installation on `tnipyxnvhgelwdpykyez`. Canonical §4.12 and the
[J8 handoff](MERCHANT_PILOT_TEST_CATALOG_INSTALLATION_HANDOFF.md) record one committed
transaction, exact stored source, preserved historical ledger/data, 36 RLS tables,
closed client privileges, empty publications and decisions OFF. Production and
all actual category/account/catalog changes remain excluded.

Hosted raw fingerprint differs from the local proof solely in CRLF storage of the
three new function bodies; a limited read-only normalization reproduces the entire
local schema hash exactly. Preserve raw evidence and old local proof. Do not replay
installation during integration. The next local preparation package must reproduce
this exact hosted profile and bind the existing source/state/permission guards to
it before real row proposals; old LF-only preparation is intentionally fail-closed.

Git changes are documentation, sanitized observations and read-only verification
SQL only. This is structural hosted acceptance, not a real cohort, compatible-build
distribution, email/provider, physical QR or final pilot acceptance. J remains OPEN.

### J9 — Installed-profile cohort/publication preparation (2026-10-18)

Following J8 integration (`62e7ba4a`), canonical §4.13 authorizes local preparation
against the observed raw hosted structure. Mirror ONLY the three observed CRLF
function bodies on an owned loopback fixture, verifying all LF/raw hashes and the
entire structure. Preserve J7/J8 sources and proof; never install or normalize
anything remotely as part of this package.

Add a source-bound offline entrypoint for separate cohort/publication review.
Reuse existing transactional contracts, exact data/authority locks and distinct
approval tokens. Default bundles have no mutation or installer SQL. Full inputs
still need fresh exact observations, private paths, compatible clients and separate
Product Owner approval; installation receipt is not participant evidence.

Rehearse actual category/role preparation, two merchant submissions to one shared
identity, malformed/different state, permission drift, concurrent Auth changes,
whole-batch rollback, repeat/lost-acknowledgement handling and the existing Flutter
repository journey. Verify empty defaults, stale-source refusal and protected file
output. See [J9 handoff](MERCHANT_PILOT_INSTALLED_READINESS_HANDOFF.md). No app,
dependency, historic migration, remote write or Production access; full J is OPEN.

### J10 — Paired Android artifact and field-acceptance preparation (2026-10-18)

After integrated J9 (`3a2d0361`), canonical §4.14 bounds an offline paired build
and verification package. Reuse existing Customer Development / Merchant pilot
entrypoints, all base-profile OFF flags, callback identities, actual configuration
validators and external release-signing policy. Preserve Customer UI/runtime,
historical source-bound J7/J9 proofs, migrations and shared notification foundation.

Produce both APKs from one source/config profile after focused compatibility and
Auth-race regressions. Verify packaged identity/callback/signature/permissions,
version and payload, fingerprint source/config/artifacts and reject drift or
overwritten output. Synthetic debug output is a compilation rehearsal only; an
approved real client input and clean reviewed source are required for a later
candidate. Existing pinned signing remains mandatory for release; no signing
material is created/read during the synthetic rehearsal.

Prepare three field sessions with exact paired-artifact evidence, explicit OPEN
gates, failure handling and support/withdrawal boundaries. The machine review
checks observation completeness/binding; it cannot certify human evidence or
turn reported PASS into pilot-opening authority. See [J10 handoff](MERCHANT_PILOT_DEVICE_PACKAGE_HANDOFF.md).
No remote access/write, actual user accounts, distribution or physical QR; J stays OPEN.

## Definition of readiness per slice

Every slice supplies a bounded diff, compatible capability contract, required
RLS/authority tests, numeric boundary/concurrency/idempotency tests, analyzer and
adjacent regression evidence, migration rehearse/rollback plan, source fingerprint,
and a task branch commit/push. Local implementation and remote authorization are
reported separately. No new slice is silently activated because another slice
passed. Implementation-only questions O1–O10 are resolved in the owning slice,
with professional-policy questions retained as external gates.
