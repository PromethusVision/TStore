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

## Definition of readiness per slice

Every slice supplies a bounded diff, compatible capability contract, required
RLS/authority tests, numeric boundary/concurrency/idempotency tests, analyzer and
adjacent regression evidence, migration rehearse/rollback plan, source fingerprint,
and a task branch commit/push. Local implementation and remote authorization are
reported separately. No new slice is silently activated because another slice
passed. Implementation-only questions O1–O10 are resolved in the owning slice,
with professional-policy questions retained as external gates.
