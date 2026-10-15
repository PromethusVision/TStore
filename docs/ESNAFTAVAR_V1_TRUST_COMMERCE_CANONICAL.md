# EsnaftaVar V1 — Trust & Commerce canonical architecture

Status: **PRODUCT RULES FROZEN / ARCHITECTURE PROPOSAL / RUNTIME NOT IMPLEMENTED**.
Product Owner request: 2026-10-13, “Post-Merchant V1 / Phase 1”.
Verified source baseline: `origin/main@33d0078380feebe1ca6051b72a37e3b536536ff9`.
Fetch returned that same SHA; delta from the supplied review baseline: **0 commits**.
Branch: `agent/trust-commerce-architecture`.

This document is the canonical implementation specification for the decisions in
that request. Older scope documents remain historical evidence; their deferred
economic rules do not override these new product decisions. This task authorizes
architecture, local schema proposals and validation, not feature activation.
Repository inspection is local: it is not a report of the live database state.

Related artifacts:

- [Dependency-ordered implementation slices](ESNAFTAVAR_V1_IMPLEMENTATION_SLICES.md).
- [Local, isolated DDL prototype](../supabase/proposals/trust_commerce_phase1_v1.sql).
- [Validation and handoff](ESNAFTAVAR_V1_PHASE1_VALIDATION.md).

## 1. Scope and decision labels

**FROZEN** means a Product Owner rule, including its numerical V1 defaults.
**PROPOSED IMPLEMENTATION** means an engineering design to implement that rule.
**OPEN IMPLEMENTATION** means an unresolved technical choice, not permission to
change a frozen rule. **FUTURE / OUT OF SCOPE** identifies excluded capabilities.

The primary flow remains:

```text
find product → eligible nearby shop → physical store visit
→ physical purchase → existing QR verification → verified purchase
→ review entitlement / reward evaluation / reputation events
```

Single-shop Cart V2 remains canonical. No shipping, delivery checkout, customer
online payment, customer-funded balance, transferable value or cash-out is added.
Reserve-and-pay is a future door, with no V1 provider, checkout or payment schema.
Merchant platform-service billing and coupon receivable accounting are separate
from collecting a customer's physical purchase payment.

Customer/Merchant layouts and currently working behavior remain unchanged in this
phase. Later UI extensions require the relevant implementation slice; a prototype
table or this specification must not silently activate them.

## 2. Existing contracts and conflicts

| Existing source | Reuse | Required extension / conflict |
|---|---|---|
| `0001_core_auth_catalog`: products, brands, categories; `ProductEntity` | Stable product UUID and canonical taxonomy read contract | Product price, stock and images remain legacy fields, not future listing truth; normalized model/GTIN/type are absent |
| `0002_shops`: shops, shop_products; `ShopProductEntity/Model` | Owner RLS, unique(shop_id, product_id), listing price/description/images/active/available | Images are TEXT[] without individual primary/audit records; unit information and submission path absent |
| `SupabaseMerchantRepository`, `MerchantAccess`, Merchant navigation | Server role + exact owner, safe local host, optimistic writes, soft-deactivation, existing tabs | No upload/new master-product, reward, Ads or balance service yet; phase 1 adds no tab |
| `0003_carts_v2`, `CartV2Repository/Cubit` | One active single-shop cart, listing-linked items, cart-change invalidation | No reward reservation, coupon authorization or revision-bound checkout hold |
| `0004_qr_verified_purchases`, `0009` replacements | create_qr_session, get_qr_session_for_verification, confirm_qr_session; unique source session | Current 120-second deadline applies through confirmation; no claim/completion split, manual code, device audit or reward hold |
| verified_transactions + verified_transaction_items | Canonical purchase/header and immutable product/name/quantity/value item evidence | No coupon allocation, final-sale amendment evidence, return policy snapshot, append-only returns or fraud decisions |
| `VerifiedPurchaseEntity/Model` | Existing customer history and reference UI | Client item DTO does not expose the product_id that 0009 stores; service rating DTO has one integer |
| `0001` reviews + `0009` review RPCs | Unique(user_id, product_id), verified item evidence, required 1–5 stars and optional text | Owner edits have no 24-hour limit; delete RPC hard-deletes; eligibility selects earliest purchase; no reopening/moderation/replies/revisions |
| `0005_verified_shop_ratings` | Verified purchase gate, one service evaluation per transaction | Single rating; public average uses all purchases, not latest per customer × merchant; three criteria absent |
| ProductSellersSection / ProductDetailsView / ProductImageSlider | Actual listing eligibility, user sort, existing hero dimensions/fallback component | Seller ordering is widget-local; hero takes central product images and does not observe ranking |
| RewardRepository / RewardProgress / PendingRewardRepository | Existing 0/5 guest shell, auth routing, truthful pending state and account-scoped stream seam | No economic authority; goal=5 is presentation-only and must later be checked against server version |
| BannerRepository / BannerEntity / HomeCampaignCatalog | Editorial cards, active date/copy filtering, existing carousel and safe destinations | General-only client catalog rejects local scope; current take(12) is not a 3-sponsored-card rule or fair rotation |
| NotificationRepository / NotificationsCubit / PushCoordinator | One inbox/Realtime pipeline, permission ports, authenticated lookup, revoke-before-logout | Provider pending; no marketing bucket quota, ad entitlement queue, campaign dedup or server account quota |
| `0016_engagement_foundation.sql` and `tool/engagement/push_delivery.mjs` | Device/preference/claim contracts and existing notification record transport | Draft only; transport filters existing banner validity/window, so it cannot serve a 30-day sponsored entitlement after visibility expiry without extension |
| 0012/0013/0015 + dedicated 0014 activation package | Side-by-side canonical assignment, preview/public capability and publication gates | New products require governed canonical assignment; phase 1 must not bypass or rewrite these |

Inspection anchors: migrations 0004 tables at lines 38–126; 0009 product snapshot
guards at 69–142, review eligibility at 923, update at 1108, delete at 1168;
0005 shop rating table at 32 and average function at 67. These are repository
source references, not claims of remote execution.

### Proposal 0016 decision

**Keep 0016 untouched.** It remains a separately deployable notification foundation
proposal with its existing tests. Phase 1 adds a distinct, unnumbered design
prototype. No migration version is reserved and no proposal becomes an automatic
migration. Later Ads/queue changes extend these existing device/preferences and
delivery contracts; they do not recreate their tables or introduce a second inbox.

0014 is represented by the dedicated publication executor/package, rather than
an ordinary checked-in 0014 migration beside 0015. Migration-directory enumeration
alone must not infer that Production lacks 0014. Inspect its approved manifest in
a separately authorized deployment; do not use generic db push to reconcile it.

## 3. Authority, event and persistence boundaries

**PROPOSED IMPLEMENTATION:** retain a modular Supabase/PostgreSQL application;
no new microservice architecture is needed. Logical modules are:

1. Catalog identity and merchant listings.
2. Existing physical checkout/QR and durable purchase evidence.
3. Reviews, three-criterion service evaluations and moderation.
4. Reputation projections and badge earning history.
5. Reward packages, reservations, contributions and coupons.
6. Merchant Campaign Lite.
7. Ads visibility, attribution and marketing scheduling.
8. Merchant accounting/settlement.
9. Existing notification transport and eventual provider integration.

Module ownership matters: Ads does not decide reward eligibility, Campaign Lite
does not apply cart discounts, badges do not affect organic ordering or economics,
and Flutter displays server decisions rather than minting them.

An append-only `commerce_events` outbox records aggregate/event type, schema and
policy version, source UUID, server timestamp and bounded payload. The verified
purchase transaction inserts its event atomically. A delivery/consumer cursor
tracks retries separately; unique(consumer, event_id) prevents duplicate effects.

The dependency chain is logical, not an all-or-nothing serial queue:

```text
one confirmed source_qr_session_id → one verified_transactions.id
  ├─ one review entitlement per distinct product + one service entitlement
  ├─ at most one positive reward contribution for this purchase
  ├─ valid purchase/review events → badge projection
  ├─ existing notification events → inbox / optional push
  └─ eligible tracked exposure → attribution, never causal proof
```

Review submission is optional and never gates an eligible reward. Notification or
provider failure cannot undo a verified purchase. Consumer replays cannot duplicate
entitlements, coupon issuance, slots, ledger postings, milestone awards or Ads credit.
Critical capacity/coupon decisions are atomic at finalization, not deferred to a
best-effort queue that might oversell a slot.

Financial amounts are TRY integer kuruş (or exact database NUMERIC at the legacy
boundary), with explicit rounding/allocation policy. No binary-floating-point
amount from Flutter is trusted. Timestamps, eligibility windows, quotas and expiry
use server time. Every monetary operation carries an idempotency key and canonical
purchase/package/session references; logs contain no raw QR token or push token.

## 4. Catalog identity, listing media and ranked hero

**FROZEN:** preserve “shared catalog → add to my shop”; later add “Can't find the
product? Add new product”. Central identity holds name, brand, model/variant,
canonical category, barcode/GTIN and normalized identity fields. Listings own
shop, price, availability, description, merchant images, active/passive and units.

**PROPOSED IMPLEMENTATION:**

- Retain products.id and shop_products.id. Add identity companion metadata:
  shared_catalog_product / merchant_unique_product, nullable origin shop, model,
  variant and versioned normalized fields. A unique product still has a central
  identity anchor and a listing; it is not an untyped duplicate product system.
- Unique products require an owning origin shop; another shop's self-service
  request cannot appropriate them. Promotion to shared identity is a governed
  later operation, not automatic based on similarity.
- `product_identifiers` holds validated normalized GTIN. Exact match returns the
  existing identity; concurrent identical GTIN submissions serialize/unique-fail.
  Normalize supported GTIN representations consistently and validate check digits.
  Similar brand/name/model results are suggestions requiring an explicit choice.
- `product_submissions` plus append-only decision events capture new identity
  requests. Existing authoritative category qualification/publication gate remains
  mandatory. Candidate approval and listing activation are separate steps.
  Existing products.price is NOT NULL and old DTOs still parse legacy financial
  fields. New candidate publication therefore requires an explicit compatibility
  insert/read contract in slice A before activation; an arbitrary central price
  must not become public listing truth. Keeping a candidate pending is safer than
  silently inventing that required value or dropping the old column.
- Admin merging later writes product aliases and an audited canonical target.
  Purchase snapshots retain original product UUID/name; no historical rewrite.
- `listing_images`: listing_id, bucket/object key, order, primary flag, created_at,
  updated_at, uploader and publication state. One primary published image per
  listing; object ownership cannot be reassigned. Approved media type/size and
  exact shop/listing path policy are server enforced.
- The current public media resolver remains the URL projection. Existing bucket
  paths `shops/{shop_id}/{listing_id}/...` are retained. Storage is read-active
  today without merchant upload authorization; future upload policies need review.
- Upload uses a bounded owned upload intent, validation, publication and cleanup
  for failed/orphan uploads. Changing the primary image is atomic; legacy TEXT[]
  ordering can be projected during staged migration. Do not copy central stock or
  prices into listings as authoritative values.

**FROZEN ranked image rule:** use the image of the currently ranked first eligible
merchant. Fallback is that listing's primary → another published image from that
same listing → next eligible merchant's image → existing EsnaftaVar placeholder.
An empty eligible set uses placeholder, not a central catalog photo.
The fallback also applies to unpublished, invalid or failed-to-load media;
a primary reference must not trap the hero on a broken image indefinitely.

**PROPOSED IMPLEMENTATION:** introduce one ranked seller result DTO shared by
Product Details, Seller Comparison and the hero selector. It contains listing/shop
UUIDs, eligibility, user-sort rank, display rank, sponsorship label and ordered
published images. The top *displayed* eligible merchant is #1, including a labeled
sponsored block when enabled. Ads therefore may change the displayed source,
but cannot alter its organic rank, rating or badge. Returning both ranks avoids
silently treating paid rank as reputation. Recompute hero after filter/sort/
location changes with a request generation guard; do not keep an old-shop hero
while newer results load. Source attribution is “Photo: X Shop”.

Nearest sort uses validated existing shop/customer coordinates; unknown distance
never bypasses a hard radius filter. Price sort uses listing price. Ties become
deterministic by shop/listing UUID after the intended stable user sort. Layout and
image contain-fit are retained; later slice A wires data into the existing slots.

### 4.1 Merchant daily operations — approved 2026-10-14

**FROZEN scope addition:** the Product Owner approved the daily operations panel
and local usage validation after Slice A. This is bounded completion of Merchant
V1 and A, not authorization to implement B–J or activate Production.

- Preserve the accepted Merchant visual direction, separate app and five tabs.
  The overview shows owned product counts (available/unavailable/inactive), quick
  access to catalog addition, price/availability editing, existing QR and profile.
- Surface actual pending/approved/rejected submission counts and unfinished photo
  uploads with direct access to the existing resolution screens. Counts represent
  current state, not unread decisions or promised approval deadlines. Approval
  remains separate from adding the approved product to the shop.
- Notifications reuse the same inbox, repository and state controller. No second
  notification store, provider activation or fabricated unread count.
- Availability remains a boolean; counts are numbers of product listings, not
  inventory quantities. No revenue/profit/Ads-return chart is authorized. Future
  verified transaction totals must never be labeled total shop turnover.
- New product submission is a request, not publication. Catalog operator approval
  and new-product materialization remain gated; no self-service role escalation.
- Refresh after edits, returning to the overview and app resume. Loading/errors
  must not masquerade as zero tasks; old-account responses must not repopulate it.
- Acceptance journey: existing catalog product → owned listing price/availability
  → owned photo upload → fresh app/session read → Customer eligible image source.
  Exercise on an isolated local backend where available. Report synthetic tests,
  real Storage HTTP tests and physical-device acceptance separately. No Production
  access, remote apply, release or final two-device QR acceptance is implied.

The next new foundation remains B (QR/purchase terms/returns); H0 precedes monetary
activation. Historical Phase 1 status at the top describes the original proposal,
not the implementation status of subsequent deliveries.

## 5. Existing purchase evidence, QR claim and returns

**FROZEN:** one QR system. `verified_purchase_items` in product language means
existing `verified_transaction_items`; do not create a parallel copy/table.
Its product_id/name/quantity/unit_price/line_total snapshots remain immutable.

**PROPOSED IMPLEMENTATION:** append purchase terms evidence, referencing the same
verified_transactions UUID, with final_sale_minor, EV_coupon_minor, customer
payment, allocation/version hash, voluntary return duration, policy version,
finalizing merchant user/session/device and claim UUID. The original header/items
are never overwritten to describe a return or a later catalog correction.
Legacy rows with insufficient terms remain `legacy_unclassified`; no retrospective
reward contribution or guessed return window is granted.
Existing total_amount/item prices describe the QR quote. Economic v2 must expose
quoted amounts, merchant discount allocation and finalized sale/coupon/customer
amounts explicitly through purchase_terms and a compatible history DTO. It cannot
label an old quoted header total as the actual discounted final sale. Terms are
captured once at finalization; a return later appends compensation instead of
rewriting either quote evidence or finalized terms.

### QR protocol extension

Existing create/get/confirm contracts and cubit/repository remain insertion points.
Versioned capabilities add:

- One active, single-use token and one six-digit manual code for the SAME session.
- Default first claim/scan TTL: 120 seconds. A successful authorized claim obtains
  a separate bounded completion deadline; **proposed 10 minutes**, server-configured.
- A `qr_claims` companion binds one qr_session_id to exact shop, merchant principal,
  device installation and authenticated session. A second concurrent claim cannot
  finalize twice; same idempotent claimant can resume.
- Manual code is scoped to shop, HMAC/digest protected, never logged or stored in
  clear text, unique among active aliases in its lookup scope. A code does not
  replace authorization. Server enforces bounded attempts/rate limits; numerical
  limits and authentication-session provenance are implementation choices.
- Consuming scan token OR code atomically consumes both. Offline finalization is
  unavailable. Server reconciliation after an uncertain response checks the same
  source session/purchase, never retries a new economic purchase.
- After claim, price/coupon quote and allocations are immutable for that attempt;
  changes require a new quote and customer coupon authorization. Cart mutation,
  owner/role suspension, timeout and cancellation have explicit fail-closed paths.
- Reward reservation becomes a checkout hold tied to this same QR before capacity
  can expire mid-flow; claim success does not itself issue a purchase or reward.
- No V1 staff hierarchy. Exact merchant owner role remains enough. Target max two
  active merchant device sessions; enforcement must use verified Auth session
  identity plus installation, not a client-supplied device UUID alone. Push device
  tokens are not authentication sessions. If reliable session provenance is not
  available, final rollout stays gated rather than claiming enforcement.

Current RPCs expire active sessions and the client `canBeConfirmed` checks the
scan expiry. They cannot already support a claimed 10-minute flow. The later
protocol slice must update these guards together. Legacy endpoints must reject a
v2 economic session before their expiry mutation, and cannot bypass v2 coupon/
capacity checks. Feature OFF keeps existing behavior; no mid-flight protocol
switch. Old clients remain supported for legacy sessions, or receive an explicit
upgrade-required result for economic v2 sessions.

### Return and invalidation foundation

`purchase_returns` and `purchase_return_items` are append-only references to the
existing header/items. Record quantity, sale/EV-coupon allocation, reason, actor,
server time, evidence and administrative/genuine classification. Aggregate return
quantity must not exceed purchased quantity, including concurrent partial returns.
Correction is an additional compensating event, never an UPDATE of the original.

Final sale is after the merchant's own discount. Server snapshot allocations use
exact minor units and a deterministic rounding scheme (proposed proportional
allocation with largest-remainder/UUID tie-break). Return eligibility is calculated
from net remaining sale minus net remaining EV coupon allocation, not from arbitrary
merchant-entered cash values. Cash refund execution and coupon restoration policy
require separately finalized legal/settlement rules; this architecture records
evidence and does not invent a payment-provider refund.

An explicit fraud/admin-invalid purchase event may revoke entitlements and create
reward reversals. A normal genuine return does not mark experience as fraudulent
or automatically remove reviews.

### 5.1 Slice B local implementation — approved 2026-10-15

The Product Owner approved the recommended B implementation and closure of the
previous local acceptance gap. This permits local code/migration preparation and
task-branch validation, not Production activation or main merge.

**Implementation defaults resolving O3 locally:** retain the 120-second scan
window and use a server-configured 600-second completion window from first claim.
The deadline never renews on retry. The signed JWT session ID must match a live
owned Auth session (including its expiry); one installation binds to that session.
Registration serializes per merchant and admits at most two live registered
sessions. Revocation is terminal for that registration. Client installation IDs
and notification tokens cannot establish authority. Real Auth integration remains
a rollout acceptance gate.

Code aliases are shop-scoped HMACs under a server-only key. Both scan and manual
entry claim the same existing QR; only the identical claimant can resume. Bound
attempts to 5 per Auth session/minute and 30 per shop/hour, using server-time fixed
windows. Rejected guesses commit their counters. No raw credential is logged.
One pending claim per merchant Auth session prevents abandoning an uncertain
operation to start another. After an uncertain result, recover that claim from
the server; never mint a replacement purchase. Disabling the flag prevents new
v2 creations/claims but permits existing claims to reconcile, complete or cancel.
Legacy entrypoints reject v2 before expiry mutation even while the flag is off.

**B evidence boundary:** this implementation verifies the unamended quoted sale,
with exact integer minor units, final sale = quote and EV coupon = 0. Discounts,
coupon authorization/spending and reward/capacity/ledger operations stay gated
to their later slices. Do not claim that B already implements their atomic
checkout. Missing historical terms are `legacy_unclassified`. A missing real shop
return policy stays explicitly `unspecified` with unknown duration; no legal
return window or monetary refund entitlement is invented.

Merchant UI extends the existing QR tab with manual entry, claim recovery and a
nested verified-purchase/return history. Five tabs and the accepted visual system
remain. Return requests persist a bounded local pending request until server
acknowledgement; retries reuse the same ID. A recorded return never claims a cash
refund. Admin correction appends a full reversal of a specific return; fraud
invalidation appends separate evidence. Neither edits the original purchase.
Later review/reward consumers use these events under their own authorized slices.

Customer changes are restricted to opt-in v2 manual-code/status compatibility in
the existing QR surface and the already-stored product UUID in purchase DTOs.
Both client opt-in and server enablement default OFF. Previous real Storage HTTP
acceptance, real Auth/concurrent PostgreSQL validation and physical acceptance J
must be reported independently of ephemeral SQL, mocked transport and widget tests.

### 5.2 A+B acceptance and hardening — authorized 2026-10-15

The Product Owner authorized an autonomous persistent task to validate the
integrated A+B scope locally, fix evidenced defects and deliver a task-branch
handoff. Existing FROZEN product rules remain unchanged. Bound environment
diagnosis to approximately 45 minutes; preserve Docker data and complete
independent verification if managed local services remain unavailable.

Real native PostgreSQL/pgcrypto/connection contention, managed Auth/Storage HTTP
and physical two-device acceptance are separate gates. Native PostgreSQL with
synthetic Auth/Storage tables cannot close the managed-service gate. The
[A+B acceptance report](MERCHANT_AB_ACCEPTANCE_DELIVERY.md) records the evidence
and remaining gates. This authority does not include Production access, main
merge, provider activation or new deferred capabilities.

**Acceptance update — 2026-10-15:** after the Product Owner restored Docker,
the isolated managed-service suite passed all 21 groups using actual Auth,
PostgREST, Storage and PostgreSQL. This closes the local managed-service gate,
including live-session rejection on QR finalization/reconciliation after logout.
The informational capability read is not itself a transaction authorization
check. Existing frozen rules, default-OFF flags and migration bytes are unchanged.
Physical two-device acceptance J and Production authorization remain separate.

## 6. Product review and merchant-service projections

**FROZEN:**

- Verified purchase only; viewing/cart/QR creation/claim alone gives no entitlement.
- One entitlement per distinct purchased product, irrespective of quantity.
- Evaluation is optional overall. If a purchase evaluation is submitted, exactly
  friendliness, communication and cleanliness are all required 1–5; service
  criteria are submitted only once per purchase; no merchant written review.
- Three distinct products allow up to three product evaluations + one service
  evaluation. Product stars required, written text optional.
- One user × product has one active public review. Another verified purchase can
  reopen that existing review for 24 hours without another public rating/count.
- One customer's latest valid merchant service evaluation contributes to that
  merchant's public score; historical evaluations stay auditable.
- Product review editing closes after 24 hours from creation/reopening. User may
  withdraw public display afterward; immutable/audit history remains.
- Merchant may reply once to a product review from a purchase at their shop, and
  report it. No rating/text rewrite, customer review deletion or foreign-shop reply.
- Admin may hide/restore/under-review/abuse-flag and hide a reply, with reason/audit.
  Admin cannot silently rewrite user text. Public evidence label: “Verified purchase”.

**PROPOSED IMPLEMENTATION:**

1. Keep `reviews` as the public root and its unique(user_id, product_id).
   Add lifecycle/visibility companion, immutable revisions and entitlement uses.
   A companion durable review UUID is retained even if an authorized account
   deletion removes the public projection; it is not a second public review store.
2. `review_entitlements` unique(purchase_id, product_id), anchored to a verified
   item and ownership. On creation, save a server edit deadline. For reopening,
   the customer explicitly consumes a newer unused entitlement once; server
   `reopened_at + 24h` is fixed. Repeating that entitlement/request cannot reset
   the deadline. A fresh purchase is not a second public review.
3. Every rating/text edit appends a revision; public projection points to the
   latest permitted revision. Revision stores originating purchase/shop, so
   merchant-specific scores never infer origin from the product's global rating.
   The 0009 trigger forbids changing reviews.verified_transaction_item_id:
   retain that original legacy evidence anchor. V2 revision/entitlement provenance
   supplies the current origin and validity; reopening must not overwrite the
   old FK or weaken its ownership guard. Old clients cannot edit a reopened v2
   record through an unbounded legacy endpoint.
4. Current get/submit/update/delete RPC contracts gain a negotiated v2 projection;
   user withdrawal becomes visibility change + audit event, not data erasure.
   `can_edit` is server-computed from ownership, validity and edit_until.
5. Merchant reply is one per stable review root, anchored to the originating
   revision/purchase/shop. A reply to an old origin is not attached to a later
   revision originating at another shop. History remains audit-only; V1 has no
   reply thread. Reports reference immutable revision and actor.
6. Merchant service submissions append three-criterion evaluations, unique per
   purchase. Public metrics select latest valid evaluation per customer × shop by
   server submitted_at, then UUID. The aggregate score is the equal-weight mean
   of the three criterion means; expose sample size and criterion scores separately.
   Never synthesize three criteria from a historical scalar rating.
   Proposed submission choreography: the initial purchase evaluation atomically
   includes all three service criteria and any selected product ratings. Later
   evaluations of remaining products reuse that purchase's service evaluation
   rather than rating the merchant again. Standalone calls must not bypass the
   frozen all-three requirement; exact form/RPC compatibility is finalized in C.
7. User withdrawal, moderation visibility and fraud validity are separate facts.
   Hidden public reviews do not enter public product averages. A visibility-only
   action does not itself invalidate purchase evidence or reward eligibility.
8. Product-at-shop badge metric uses valid latest product-rating evidence per
   customer × product × shop from that shop's purchases, with distinct customer
   threshold. This historical evidence does not create additional public reviews.
   No global rating or cross-shop purchase enters that shop's metric.
9. Account deletion must evolve with audit retention/pseudonymization before
   rollout. Do not accidentally block existing self-delete with restrictive new
   public-review/auth-user FKs, or retain readable PII forever. Retention duration,
   display anonymization and legal process remain professional-policy inputs.

Migration strategy: preserve old reviews/evidence, import only provable provenance
into versioned history, mark missing evidence ineligible, retain old read paths
until capability-gated client/server cutover. There is no inferred 24-hour “now”
window for every old row and no fabricated multi-criterion backfill.

### 6.1 Slice C local implementation authorization — 2026-10-15

The Product Owner approved the proposed complete Slice C package with
“onaylıyorum başla”. This authorizes isolated task implementation, local schema
and real-service acceptance, Merchant review center/dashboard, and necessary
extensions to existing Customer review/purchase forms. It does not authorize
Production deployment, main integration, D–J work or Customer UI redesign.

The implementation accepts the §6 proposed three-criterion atomic submission,
equal-weight service aggregate and one reply per durable root. Reopening is an
explicit submission against a newer unused purchase entitlement, not a side
effect of reading a screen. Retries retain the original server deadline.
The source purchase of the current revision controls merchant reply visibility.
An existing reply consumes the root's sole reply slot even after origin changes.

Local compatibility policy: the capability starts OFF; proven legacy review
provenance is adopted without resetting its original creation deadline. No
scalar service score is backfilled into the three criteria. Old mutation RPCs
must enforce C bounds for adopted roots and must not bypass the initial service
evaluation requirement once C is enabled. Withdraw and moderation remain
separate from fraud invalidation; genuine returns preserve experience evidence.

Privacy implementation is a local technical proposal for rollout review:
immutable revisions keep encrypted text with an independently erasable subject
key; authorized account deletion removes its public projection and subject key,
while commerce IDs, numeric evidence and non-readable audit chronology remain.
No legal retention duration or production legacy-data conversion is approved by
this implementation authorization. Production rollout remains gated on explicit
evidence-import and privacy/moderation policy approval and client compatibility.

Local implementation status: Slice C is implemented and locally verified; see
[delivery and evidence](MERCHANT_SLICE_C_DELIVERY.md). This updates only C's
execution status, not the original architecture baseline at this document's top.
Customer history exposes actual three-criterion records separately from legacy
scalar ratings; QR completion links to the verified purchase history. Bounded
legacy import is operator-only and requires its separate rollout review.

## 7. Badges

**FROZEN:** status/reputation only. No monetary, organic-rank or Reward advantage.
Show practical name-adjacent badges; compact top 2–3 plus +N; profile full set.
Tap opens persistent explanation popover until outside tap. Not an auto-dismiss
toast. Display design is a later extension of existing components.

| Merchant badge | Authoritative qualification |
|---|---|
| Güleryüzlü Esnaf | Friendliness average ≥4.70; ≥20 distinct verified contributing customers |
| Ürünleri Sevilen Esnaf | Product ratings originating AT THIS SHOP average ≥4.80; ≥20 distinct verified customers |
| Mahallenin Yıldızı | Last 90 days, top 10% by DISTINCT verified customer count within deterministic local area |
| İletişimi İyi | Communication average ≥4.80; ≥20 distinct verified customers |
| Tertemiz Esnaf | Cleanliness average ≥4.80; ≥20 distinct verified customers |

No hysteresis/grace: dynamic eligibility disappears as soon as the condition is
false and returns when true. Compare exact aggregates before display rounding.

**PROPOSED local area:** versioned official neighborhood polygon within
city/district (initial cohort Esenler), derived from validated shop coordinates.
It is compatible with existing proximity coordinates, unlike each user's changing
radius. One authoritative area assignment per shop/version, audited on change.
No trusted assignment → neighborhood badge pending, not fabricated from address.
Proposed percentile calculation: among active eligible shops in the same area
with ≥1 valid verified customer in the rolling 90 days, sort count descending then
shop UUID; select first ceil(N × 0.10). Boundary ties use that UUID rule rather
than expanding arbitrarily beyond the selected size. Area dataset/version,
candidate cohort and tie policy need engineering acceptance before rollout.

Customer purchase milestones: 10, 50, 100, 250; last title
“EsnaftaVar'ın Yıldızı”. Product-review milestones: 10 “Aktif Yorumcu”,
50 “Deneyimli Yorumcu”, 100 “Uzman Yorumcu”, 250 “Mahalle Rehberi”.
Only valid verified product review roots count; updating a root contributes zero
additional review count. Visibility-only withdrawal is not fraud/spam invalidation.
One valid purchase UUID counts once even if repeated QR callbacks exist.

Persist all award events; name-adjacent presentation shows only highest eligible
level in each family. Profile may show historical earned levels with correction
history. Fraud/spam invalidation removes invalid evidence from current counts;
it does not erase audit events. Dynamic recalculation is event-driven plus a
server scheduled time-window expiry refresh, so 90-day expiry works without a
new purchase. Exact recalculation latency is an implementation SLO, not grace.

### 7.1 D+F local implementation — approved 2026-10-15

The Product Owner approved the combined Merchant trust and Campaign Lite package
with “Uygulamaya geç”, after integration of C at `d013b761`. This authorizes
isolated local implementation of D and F, bounded additions to accepted Customer
surfaces, real local acceptance, and a task-branch delivery. It does not authorize
remote writes, main integration, monetary H0/E/G/H1 activation or provider setup.

Badge eligibility is computed from authoritative valid purchase/review evidence,
with exact thresholds before rounding. Persist award/correction transitions and
deduplicate replays; update public eligibility at read time so a delayed worker
never grants a grace period. A bounded server worker records event-driven changes
and scheduled 90-day expiries; its deployment remains a separate rollout gate.
Use the proposed active-shop cohort, ceil(N*0.10) and UUID tie-break locally.
Official area data, version and assignment review remain unapproved: no trusted
assignment means pending. A coordinate change invalidates a prior assignment.

Visibility-only withdrawal/hiding does not invalidate milestone evidence.
Fraud-invalid purchases and abuse-flagged review roots are excluded. Shop product
metrics use latest valid evidence per customer/product/source shop, including
historic origins; never borrow global product averages or another shop's reviews.
The first three purchase milestones use neutral numeric titles (10/50/100
alışveriş); the frozen 250 title and review-family titles stay unchanged.

Local implementation details consistent with those rules:
- D is effectively enabled only while C's evaluation lifecycle is enabled. This
  prevents legacy physical review deletion from being interpreted as a V1
  visibility-only withdrawal. Legacy changes still enqueue refresh work.
- A later account-role change does not erase a valid historical buyer's
  contribution; account removal and fraud/abuse remain separate validity events.
- Award/correction history retains the rule version and numeric qualification
  snapshot. Account erasure removes the user mapping and pending user events.
- Saving an edit makes the offer an unpublished draft; publishing it again is
  explicit. This avoids silently changing a promise that is currently visible.
- Public offers include the names of their selected products and server time.
  An open Customer offer card expires from that server-derived deadline without
  requiring another purchase or an app restart. Prices/cart terms stay unchanged.

### 7.2 D+F rollout boundaries

Campaign Lite reuses owned listings and published listing media. It never edits
cart/listing prices, QR quote terms, Reward capacity or organic ranking. Existing
B records quote-only sales; therefore price/percentage offers have a separate
default-OFF publication gate until actual-sale/offer reconciliation is approved.
Local synthetic tests may exercise this gate; they do not approve live discounts.
Announcement offers and draft/preview flows can be verified independently.
Official geography, privacy/retention and truthful offer wording remain reviewed
deployment inputs, not fabricated engineering approvals.

## 8. Ödül Sayacı, packages, reservation and coupon

**FROZEN numerical defaults, stored in versioned server configuration:**

| Rule | V1 value |
|---|---|
| Cycle | 5 eligible purchases → 250 TL coupon; each contributes 50 TL / +1 / 20% |
| Eligible amount | final sale − EV coupon ≥500 TL |
| Referral package | 100 transaction slots; 5,000 TL fund + 750 TL nonrefundable service fee = 5,750 TL |
| Package duration | Exactly 90 days; one active per shop |
| Reservation | 30 minutes, server time, one active per authenticated user |
| QR first claim | Default 120 seconds; separate proposed 10-minute completion window |
| Maturity | max(24 hours, voluntary return duration snapshotted at purchase) |
| Coupon expiry | None in V1; nullable expires_at supports a later version |

Repeated purchases at the same merchant count; five distinct merchants are not
required. Guest sees default 0/5 and login routing, with no slot or real reward state.

Examples (TL): 750−250=500 → +1; 500−250=250 →0; 500−500=0 →0.
This explicitly supersedes any older fully-coupon-funded earning rule. Physical
payment is evidence of the discounted sale, not a platform online card charge.

### Package and capacity invariants

Package activation requires a trusted platform-service purchase/funding record.
Server snapshots config version, activation/expiry and monetary terms. No mutable
Flutter price or local success state activates funding. Accounting/provider/legal
contracts for merchant payment remain separately gated.

For each package:

```text
free slots + reservation/checkout-held slots + consumed slots
  + expired/refunded slots = original 100 slots
```

Consumed is a net capacity projection after applicable reversals, not the count
of every historical grant row. Releasing a consumed pre-maturity slot changes the
projection and appends compensation; it does not delete the original grant.

Capacity transfers lock the package and reservation with a single deterministic
lock order. Funding holds match 50 TL per slot. Reserve/finalize/expire/return/
cancel have unique keys; zero capacity returns an honest ineligible/queued result.
No “payment successful” assumption can add funds or create another package.

At expiry, free unused slots produce merchant receivable unused_slots ×50 TL.
Already valid holds retain earmarked capacity until their short terminal deadline;
release produces an additional expiry refund, consumption does not. New holds
cannot begin on the expired package. Service fee is never included in refund.
Old held package and a new active package do not share balances/slots.

### Reservation state machine

Threshold is estimated single-shop net customer payment, excluding planned EV
coupon. The server recomputes it from authoritative prices/allocations.

```text
none → reserved(expires_at fixed) → checkout_hold(completion deadline) → consumed
                        └→ released / expired / cancelled
```

Authenticated threshold crossing attempts an automatic reservation. Cart/quantity
changes may update eligibility, but cannot reset the original deadline. Dropping
below threshold releases capacity. If it rises within the same checkout attempt,
any reacquisition retains the original attempt deadline; after expiry an explicit
fresh user attempt is required. Reconnect/restart only reads server expires_at.
No background or endless implicit renew loop. One active reservation/hold per
user; switching shop must release the old one transactionally.

The canonical cart revision and intended coupon authorization are snapshotted.
Near expiry, existing QR creation/claim transitions reservation into a checkout
hold atomically while still valid. Completion timeout/cancel returns capacity.
Finalization may consume a valid hold or atomically claim an available slot;
it may not earn when both are absent. Final amount below 500 releases the hold.

### Immutable contributions and coupon maturity

`reward_contributions` contains chronological positive purchase effects and
compensating reversals, linked to existing purchase, package and config. Never
physically move contributions between cycles. A rebuildable chronological
allocation projection assigns current valid evidence into groups of five and
remainder 0–4. Pending group display is locked 250 TL, not spendable value.

Before issuance, a pre-maturity reversal drops invalid evidence and recomputes
only the pending projection; original contribution rows stay in place. Stable
issued allocations remain immutable. A spendable coupon is materialized once
all five linked contributions mature, with unique issuance/allocation key and
source links. Multiple queued groups mature in chronological order, not a later
group ahead of an unmatured earlier contribution.

Normal pre-maturity return that reduces net customer payment below 500 reverses
the 50 TL contribution, restores 50 TL fund and one slot; after package expiry
that capacity becomes the corresponding unused-fund receivable. A normal genuine
post-maturity return does not ordinarily claw back earned reward. Fraud/
chargeback/admin-confirmed abuse may append a reversal even after maturity.

If already spent, do not create a customer cash debt: record an internal future
reward offset obligation, recover from future eligible reward accruals, and show
the authoritative pending/available result. Recovery cannot silently double-charge
coupon balance and future accrual. Unspent issued value may be administratively
restricted/reversed with audit; partially spent value splits those cases.

Coupons are reward/discount instruments, not a wallet/e-money surface. No top-up,
transfer, user funding, cash-out or cash-equivalent-item redemption. Partial spend
uses immutable redemption allocations and locked server balance. Coupon eligibility
must fail closed for a catalog/listing whose cash-equivalent classification is
unknown. No ad/push state or badge can enlarge a coupon balance.

Customer authorization caps coupon use for the physical sale; merchant cannot
spend it unilaterally. The exact in-app approval mechanism is a later QR extension.
The final sale, coupon debit, merchant receivable and purchase evidence commit
atomically or none do; cash/card payment at the physical store stays outside the
platform.

Coupon acceptance: a normal merchant may toggle the preference. Effective
acceptance is forced ON during active Referral Package OR any open reservation/
hold from that obligation. A client cannot turn it OFF while forced. Once those
conditions end, normal merchant control returns; store preferred value separately
from computed lock/effective state. Acceptance does not by itself grant earning.

## 9. Merchant balance and immutable accounting

**FROZEN direction:** “Hesap Bakiyesi”, statement-like history with separate
blocked/pending, mandatory offset reserve, withdrawable receivable, paid/settled
and reversals. No transfer or merchant top-up and no electronic-wallet wording.

**PROPOSED IMPLEMENTATION:** append-only journal/posting ledger, balanced by
currency, per-source idempotency and explicit source class. Projections sum
postings; a mutable balance column is never authority. Reversal references the
original journal and posts a compensating entry; settled rows are not rewritten.
Server checks postings balance in one transaction before publishing it.

Only receivables from CUSTOMER USE OF EV COUPONS refill mandatory reserve to
1,000 TL. Remaining coupon receivable becomes withdrawable after any legitimate
pending/settlement gate. Unused Referral Package fund receivable and other sources
do not refill mandatory reserve automatically.

While relationship is active, reserve is ordinarily not cash-withdrawable. It is
used FIRST for Ads/Referral Package or other allowed platform-service debt:
1,000 TL service due + 500 TL reserve → reserve offset500 + other permitted source500.
Following coupon receivables refill any reserve gap before adding withdrawable
receivable. No reserve debit can exceed existing reserve or charge an invented
customer/merchant funded wallet.

The Reward slice requires minimal ledger/source provenance before monetary
activation; full Merchant statement/settlement UI can follow. It is unsafe to
implement funded rewards first and defer its accounting authority until after Ads.
Withdrawal cadence, relationship closure/reserve release, funding provider,
cash-equivalent perimeter, dispute/refund treatment and tax/legal wording remain
external policy inputs. Missing policy disables the corresponding withdrawal/
billing action; engineering does not invent a schedule or a legal conclusion.

## 10. Merchant Campaign Lite

**FROZEN:** an informational, store-applied offer, distinct from Ads and Reward.
Scope one listing, multiple listings or all shop; type discounted price, percentage
discount or general offer/announcement. Title/start/end/short description and
existing merchant/listing images. No BOGO, second-item, segmented price, code
generator, stacking or automatic cart discount engine.

**PROPOSED IMPLEMENTATION:** `merchant_offers` + `merchant_offer_listings`, exact
owned shop, validated date range and type-appropriate structured amount/percent.
Selected images must belong to eligible owned listings. Offer discounts describe
the real physical-store offer; confirmed final sale records actual merchant-applied
discount, not an invented client cart calculation. Ads may reference an offer but
does not modify its business terms.

Server invariant (D/F integration correction): price offers require a non-null
integer minor-unit amount; percentage offers require a non-null integer
basis-point amount. Missing keys and explicit JSON null are both invalid for the
required field, including draft creation and editing. Announcement offers carry
neither amount. The database must enforce this independently of client form
validation; SQL CHECK must never accept UNKNOWN for this invariant. This corrects
enforcement of the existing type-appropriate amount rule, not a new offer type.

## 11. Ads visibility, fair selection and attribution

**FROZEN:** one backend-configurable visibility product, default 7 days:
store-wide eligible product sponsorship + local Home rotation + one sponsored
marketing-push entitlement + performance reporting. One active package per shop;
additional purchase extends time rather than adding rotation weight.

**PROPOSED pipeline:**

1. Apply exact product/relevance, hard brand/category, selected radius/distance,
   availability and all explicit user filters before sponsorship candidate selection.
2. Deduplicate to one eligible merchant per result (select deterministic listing if
   future multi-variant listing support permits more than one).
3. Fair exposure scheduler selects max3 distinct sponsored shops from eligible pool;
   proposed atomic least-viewable-exposure count per placement/local query cohort,
   last_served_at then stable UUID, with bounded impression dedup.
4. Sort those selected shops internally by the user's requested meaningful sort.
   Label each “Sponsorlu”. Do not reserve empty slots for 0/1/2 candidates.
5. Remove selected shops from organic output; unselected sponsors may appear once
   at their unchanged organic position. Buying more time cannot buy extra weight.
6. Home keeps editorial cards and adds at most3 sponsored merchant cards per
   user/session, local relevance and fair rotation. Repeated carousel renders are
   not new impressions. Guest exposure uses a short-lived opaque session, not
   Reward state or a durable unconsented identity.

Creative is template-driven from real structured data, existing owned images and
merchant preview/selection. No uncontrolled initial banner uploads or fabricated
“cheapest/best/fresh/20% off” claims. Paid placement never becomes a badge.

Versioned performance events: ad_impression, ad_click, shop_view,
directions_requested, verified_purchase. Each uses impression/event id, observed
server time, placement, package, context and retention policy. Attribution
(proposed configurable7-day window, deterministic last eligible touch) records
observed association, not proof that the ad caused the purchase. Fraud/duplicate
events do not inflate reporting or fair rotation.

## 12. Sponsored push entitlement and shared transport

**FROZEN:** each 7-day package creates one push entitlement valid **30 days from
package start**, independent of visibility end. Extension purchases record their
own one entitlement and start timestamp without increasing ranking weight.
Proposed extension semantics: added 7-day interval starts at the current paid end;
the corresponding 30-day entitlement starts at that interval's start, not an
arbitrary refresh timestamp.

Per user, rolling24-hour marketing caps are separate buckets:
max1 sponsored merchant + max1 EsnaftaVar general = max2. No carryover. Service/
transactional events use another lane. Quotas are user-based across devices; OS
tokens/notification rows are transport details, not extra quota.

Only opted-in users passing local targeting are eligible. Unique(ad/campaign,
user) enforces at-most-once recipient reach. Oldest eligible unused entitlement
is not unfairly skipped by newer purchases. Quota full defers the right inside
its valid window, not silently consumes it or limits it to7 days. Expiry with no
eligible recipients is an explicit reasoned outcome; compensation is not invented.
Campaign identity remains stable across package extensions and copy revisions;
changing a wording family is not permission to reach the same recipient again.

**PROPOSED IMPLEMENTATION:** entitlement → approved structured content revision →
fair audience queue → atomic recipient quota/claim → existing notifications row →
existing push delivery store/provider. One entitlement is one logical campaign
broadcast, possibly many authorized recipients; it is not consumed per device.
Recipient selection seals a bounded audience batch and its claim history.

Generator intent → subtype → live merchant/product/offer facts → approved copy
variants → merchant preview/select → queue. Families: store introduction,
product feature, offer, invitation; track recent wording family per recipient
within a bounded retention window. A short constrained merchant note remains
optional future behavior, not an unreviewed initial injection path.

Revalidate opt-in, target eligibility, merchant/listing/offer status and claims
at dispatch. After7-day visibility ends, use current timeless shop copy or ask
merchant to refresh; expired offer/price claims cannot be sent from a snapshot.
Do not call the current banner-window guard unchanged for this later entitlement.
Use configurable local delivery window; initial concept10:00–20:30 Europe/Istanbul.

Outcomes distinguish queued, quota_deferred, planned, provider_accepted, unknown,
failed and entitlement_expired. “Sent” means defined provider submission outcome,
not OS display. Unknown provider acknowledgements retain a durable claim and
require reconciliation, not blind resend or freeing the quota immediately.
In-app notifications may describe entitlement status without adding another inbox.
Firebase/APNs setup and physical acceptance remain a separate last integration.

## 13. RLS, privacy and migration safety

Server entrypoints derive auth.uid/profile role and exact shop owner; client-supplied
owner, actor, device, price, eligibility, balance, rank and timestamps are not
authority. Privileged functions use fully qualified objects, constrained search
path, revoked PUBLIC/anon execution and least-privilege explicit grants. Admin
moderation requires trusted server admin role and reason; no Flutter admin shortcut.

Public projections expose approved catalog/listing media, public reviews and
aggregate badges/score only. No raw entitlements, purchase/customer history,
device tokens, fraud/audit notes, merchant accounting or candidate identities leak.
Customer reads own private state, merchant reads own business state with minimized
customer data; writes for economic/audit records go through atomic RPC/server paths.
Storage upload rights are reviewed separately. Local proposal enables RLS with
no client policies/grants and supplies no operational RPC: it is deliberately inert.

The prototype uses an isolated `phase1_design` schema, references existing purchase/
listing/product IDs and leaves public/auth/storage untouched. It is a DDL shape
rehearsal, not a complete migration/RPC/security implementation. Its local guard
rejects missing rehearsal opt-in and non-PGlite execution. Later numbered
migrations must be authored per slice against a fresh authorized fingerprint.
The named Production project `mefhfvrgkwciubeajjeb` is identification-only here;
no connection or state verification against it is authorized or performed.

Expand → validate → dual-read compatibility → capability opt-in → audited cutover →
later contract cleanup. Do not remove products.price/stock/images, change existing
QR enum/deadline or rewrite rating aggregation in this phase. Exact 0012/0013/0014/
0015 semantics and 0016 bytes stay unchanged. No generic remote db push, seed,
cleanup, catalog republish or Production access is part of this task.

Retention and pseudonymization need legal/KVKK review; “immutable history” means
commercial/economic facts cannot be overwritten, not unlimited raw PII retention.
Geography dataset and event retention must be approved before collecting detailed
location/marketing measurement. No legal approval is inferred from architecture.

## 14. Open implementation register

| ID | Choice to resolve in the named slice | Frozen rule protected |
|---|---|---|
| O1 | GTIN normalization/check-digit library; identity similarity method/threshold; canonical candidate approval path | Exact matches strongest; ambiguous matches never auto-merge |
| O2 | Image count/size/MIME, upload grant protocol and retention; one ordered primary projection | Merchant-owned photographs + ranked-source fallback |
| O3 | Verified Auth session claim provenance, two-device-session limit mechanism; code rate limits; final completion duration | One QR source; server-time claim/hold, no offline finalization |
| O4 | Legacy proven-review import policy and deletion/pseudonymization choreography | No fabricated evidence/criteria; audit preserved; existing account behavior considered |
| O5 | Official neighborhood dataset/version, assignment review and percentile cohort acceptance | Last90 days, top10%, deterministic locality, no rank advantage |
| O6 | Slot-fund concurrency/reconciliation SLO, deterministic monetary allocation, customer coupon approval affordance | 500 TL net-of-EV threshold, 30min nonrenewing reservation, immutable evidence |
| O7 | Detailed administrative reversal ordering and partial-spend future-offset projection | No customer cash debt; no double recovery or row moves |
| O8 | Finance/legal withdrawal cadence, relationship exit, refunds/chargebacks, service-payment provider | Source-specific reserve, no wallet/top-up/transfer; no invented policy |
| O9 | Fairness cohort/impression visibility definition, audience bounds, retention, attribution window | Max3, exact hard filters, one merchant occurrence, no causal claims |
| O10 | Push audience-seal policy, quota claim reconciliation, copy-family retention; provider binding | 30day right; 1+1 rolling24h caps; no promised OS delivery |

No unresolved item above changes a frozen numerical rule automatically. Review
service score equal-weight aggregation and strict one-reply-per-root are explicit
engineering defaults requiring slice-level acceptance, not silently deployed changes.

## 15. Future / out of scope

Customer online payments/reserve-and-pay, shipping/delivery checkout, staff
management, advanced promotion/stacking/segment pricing, transferable or funded
wallet/e-money flows, badge monetary/rank benefits, algorithmic composite trust
score, automatic ambiguous catalog merge and arbitrary ad uploads are excluded.
Physical two-device QR and provider/store release acceptance are later gated
validation work; the current phase cannot declare them complete.
