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
| `0016_engagement_foundation.sql` and `tool/engagement/push_delivery.mjs` | Device/preference/claim contracts and existing notification record transport | Unchanged foundation proposal plus local I0 extension: default-OFF service-only dispatch; all marketing deferred until G/O10, no real provider |
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

### 4.2 Merchant session and private navigation resilience — 2026-10-17

After G preparation integrated at `0c79dca1`, the next authorized local package
hardens existing Merchant access and navigation. This is an implementation of
the existing exact-owner/privacy boundary; no FROZEN product or economic rule
changes. Full G, O8/O9/O10, provider setup and physical acceptance remain gated.

- A loss/change of account authority invalidates the entire private navigation
  scope, including root dialogs, sheets, queued messages and nested editors.
  Returning to the same account between frames must not revive its old scope.
  A successful same-account/unchanged-shop refresh preserves navigation and
  unsaved forms; changed shop revision follows the existing workspace reset.
- Sign-in and sign-out serialize through the existing Auth port. Device binding
  revocation still precedes logout. Refresh/resume cannot reopen the workspace
  while an auth operation is pending. An old logout must not be dispatched after
  account change during revocation; late outcomes reconcile the current identity.
  Already dispatched network operations are not claimed to be cancelled.
- Access reads have a 15-second local timeout and explicit retry. Failed checks
  clear private access, and superseded responses cannot restore it. This timeout
  does not apply to writes or authorize replacement purchases/credential requests.
  Transient session-stream errors require fresh validation. A permanently closed
  stream requires app restart before regaining private access.
- These are local UI/lifecycle guards, not a replacement for server role, live
  Auth session, exact shop ownership or transaction authorization. They do not
  imply instantaneous remote revocation without an event/read, remove server
  evidence, create a second Auth/notification system or activate any capability.

Validation and Integration Agent handoff:
[Merchant session resilience](MERCHANT_SESSION_RESILIENCE_HANDOFF.md).

Implementation follow-through — 2026-10-20: the Merchant host also observes the
stable Auth session identity for the same account. Event identity is captured
from that event's session, so queued S1 → S2 → S1 transitions invalidate private
navigation and old logout continuations. Unchanged-session token refresh still
preserves drafts. Access reads reject both stale success and stale failure;
missing live session provenance fails closed. This implements §§4.2–4.3 without
changing a FROZEN rule or completing any device/remote acceptance gate.
Local validation and review scope:
[same-account session replacement](MERCHANT_SESSION_REPLACEMENT_HANDOFF.md).

### 4.3 Merchant daily edit and photo recovery — 2026-10-17

Following I1 integration at `116557fd`, the next authorized local package
completes reliability of existing Merchant profile/onboarding, listing edits,
catalog submissions and owned photography. No FROZEN product rule changes.

- Fence every multi-step continuation by account and stable Auth session, including
  same-account replacement sessions. Reject stale errors before fallback or
  cleanup. This client guard does not replace live server authorization.
- Bound reads to 15 seconds with explicit retry. Never apply that deadline to
  writes or interpret missing acknowledgement as cancellation. Old read results
  cannot replace a newer attempt or start another request after their deadline.
- On an uncertain photo upload/publication, preserve the existing upload intent
  and stored object. Never automatically retire a potentially published photo.
  Refresh authoritative metadata; only an explicit owner action completes or
  retires the existing intent. A failed refresh disables stale media actions.
- After an uncertain profile/listing save, preserve the in-memory draft and
  require a fresh exact-owner read before another write. Matching values prove
  current state, not an operation receipt. Different values are shown for explicit
  use-current or keep-draft review; the next write still uses optimistic revision
  checks. No automatic overwrite, duplicate onboarding or offline write queue.
- Existing submission retries retain their exact request/payload. Back navigation
  protects edited in-memory forms; authority loss still removes them immediately.
  No private draft, credentials or photo bytes are persisted by this increment.

Existing five tabs, Customer layouts, boolean availability, shared catalog/media
contracts and default-OFF capabilities remain. No migration, provider, financial
activation, Production access or physical J acceptance is introduced.
Delivery and validation: [Merchant catalog recovery](MERCHANT_CATALOG_RECOVERY_HANDOFF.md).

### 4.4 Merchant Android pilot runtime preparation — 2026-10-17

Following management recovery integration at `6b79a4e9`, the Product Owner
approved proceeding toward pilot readiness. This increment prepares a bounded,
nonproduction Android runtime and Merchant account recovery. Existing FROZEN
product rules remain unchanged; remote access, apply, provision, real email/push,
physical J and distribution still need their existing explicit authorization.

- Separate `merchantPilot` installation and callback use the temporary technical
  identifier `com.esnaftavar.app.merchant.pilot`. This is a test identity, not a
  final store-ID decision. Customer identifiers, entrypoints and routing stay fixed.
- Dedicated pilot configuration accepts only the existing nonproduction project
  `tnipyxnvhgelwdpykyez`, HTTPS and client-safe keys. No Customer/local fallback,
  Production URL, server credential or unreviewed capability activation. A valid
  offline manifest does not prove a deployed backend or authorize a connection.
- The common Merchant composition preserves current local opt-ins. The pilot
  preparation composes the base Merchant surfaces with downstream economic,
  claims-v2, review, promotion and provider capabilities OFF. This is an initial
  compatibility/release fixture, not the final pilot feature-selection decision.
  Final pilot enablement requires reviewed server and matching Customer evidence.
- Recovery uses the shared Supabase Auth provider and a Merchant-owned serialized
  navigation gate. Exact pilot callbacks only; a recovery query marker alone is
  not a verified grant. No self-signup, role grant, owner bypass or new Auth store.
- Verification hides private routes and overlays; only the captured stable Auth
  session can update a password. Missing acknowledgement never claims success or
  repeats a write automatically. On completion, clear the local recovery session
  and require fresh login/normal merchant authority checks. Account replacement
  invalidates the grant; same-session token refresh preserves it.
- Persist only a role-specific boolean recovery-pending marker before exchange.
  Interrupted recovery blocks workspace on restart until safe cleanup. No password,
  email, callback token or private draft is written by this marker mechanism.
- Integration correction to the implementation boundary: GoTrue can mutate its
  session before returning a verification/update response. Run those requests in
  disposable, non-refreshing SDK response buffers against the same Auth provider
  and existing PKCE store. They have no persistent session or application services;
  the shared client remains the sole application session. Publish a verified,
  internally consistent, unexpired recovery session only while its captured
  shared identity is still valid. Never copy a password-update response into the
  shared session. Observe event snapshots throughout the operation so changing
  away and back cannot revive a grant. Also fence the preceding pending-marker
  write. Mixed JWT/user identity cannot silently clear the pending gate. This
  corrects the existing account-isolation rule; it adds no product permission.
- Pilot release tasks require the exact target, validated configuration and the
  existing external pinned-certificate signing proof. Debug keys cannot produce
  signed release output. An unconfigured debug build shows a safe setup surface.

See [pilot runtime preparation](MERCHANT_PILOT_RUNTIME_HANDOFF.md). Real provider,
physical two-device acceptance, final signing/distribution and remote deployment
remain separate gates. No store or live-pilot readiness claim follows from this work.

### 4.5 Base-core pilot backend rehearsal — 2026-10-17

After the J0 security correction was integrated at `c801292b`, the Product Owner
authorized the next readiness package. This is local verification of the existing
§4.4 base-core composition, not final pilot feature selection or a new product rule.

- Use the existing owned, literal-loopback Supabase acceptance stack and actual
  Flutter repositories. Exercise real Auth, PostgREST and private Storage through
  onboarding, profile, listing price/availability/deactivation, catalog requests,
  media publication/retirement, dashboard and the shared notification inbox.
- The minimal **Development-track local fixture** uses unchanged migrations
  0001–0011 plus catalog-media0016 and operations0017. Production0012/0013,
  publication executor0014, public-read0015, claims0018+ and the separate
  engagement0016/dispatch0029 proposals are not implied dependencies of this
  fixture. This list is not an authorized remote migration/apply plan.
- Keep catalog decisions OFF; all later runtime capabilities retain the existing
  OFF defaults. Validate matching Customer listing/image DTOs and legacy QR
  compatibility. Legacy repeat confirmation is rejected as already used; this
  does not adopt claims-v2 idempotency or close physical QR acceptance.
- Capture exact migration/source hashes and schema, grant, policy, trigger,
  constraint and Storage fingerprints. Read-only inspection does not itself
  prove behavioral acceptance. Changed fingerprints require review; a local
  PASS cannot certify an uninspected hosted backend or extended feature set.
- Real inbox CRUD is separate from Realtime delivery and device push. The local
  stack does not accept physical hardware, real recovery mail, provider delivery,
  signing/distribution, operational account provisioning or any remote writes.

See [base-core backend handoff](MERCHANT_PILOT_BACKEND_HANDOFF.md). Existing FROZEN
rules and Customer screens remain unchanged; no migration or dependency is added.

### 4.6 Pilot preparation and Esenler intake — 2026-10-17

After J1 integration (`55cee012`), the Product Owner authorized a comprehensive
local preparation package. Production remains excluded. Every test-server write,
including Auth settings, taxonomy activation, provisioning and SQL repair, must
be presented concretely for separate approval before execution. Prior permission
to read the named Development project and resume it is not write authorization.

- The confirmed pilot location is **Istanbul / Esenler**. The owner wants broad
  merchant participation, including market/bakkal, stationery, clothing and
  potentially barber/salon businesses. Participants and their number are not yet
  selected. This is a recorded product objective, not approval of every category
  or a change to FROZEN capability, policy or professional-review decisions.
- Preserve the distinction in [taxonomy §12](ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md#12-confirmed-merchantsector-scope-decisions):
  merchant sector is not a product category. Barber/salon sector intent already
  exists; booking, service prices, employees, slots and service availability remain
  TBD. Physical goods sold by a service business use their own eligible product
  leaves. No hair-cut/service listing or new sector runtime is implied here.
- Local preparation separates schema, explicit category leaves/ancestors, shared
  Auth callbacks and private cohort provisioning into independent review scopes.
  A schema approval cannot activate categories, approve submissions or grant roles.
  The existing two catalog/operations migrations remain unchanged; historical
  ledger timestamps are preserved, including their differences from filenames.
- Rehearse atomic upgrade on a populated owned local baseline; preserve existing
  rows, reject drift/replay/concurrent preparation and prove late-error rollback.
  Include table-wide privileges and future-object defaults, not only column RLS.
  The generated review token is an accidental-execution guard; it proves neither
  human authorization nor the identity of the executing database.
- Category preparation requires explicit leaf UUIDs and preserves every policy,
  professional-review, parent and identity field. This bounded automatic helper
  accepts only fully staged NORMAL/not_required paths; it is intentionally narrower
  than the complete taxonomy governance process. Other leaves require their own
  review, not a silent override. No real leaves are selected by this delivery.
- Real test-server inspection is metadata-only. A local PASS does not supersede
  a mismatching hosted fingerprint. Read-only inspection found narrower hosted
  service-role privileges, different infrastructure defaults and two notification
  functions containing corrupted Turkish literals. Do not repair these, relax the
  fingerprint or widen hosted permissions under local implementation authority.
  J2 reproduced the pinned observed profile in the owned local stack, preserving
  its narrower grants and managed RLS trigger; all captured metadata then matched
  exactly and the18-group upgrade/repository rehearsal passed. This permits an
  exact schema candidate to be presented for approval; no remote write follows
  automatically. Existing corrupted text remains a separate repair/release gate.

See [preparation handoff](MERCHANT_PILOT_PREPARATION_HANDOFF.md) and
[Product Owner review packet](MERCHANT_PILOT_APPROVAL_PACKET.md). This package
does not close remote compatibility, physical two-device QR, provider/mail,
catalog population, signing/distribution or final pilot feature-selection gates.

### 4.7 Approved Development installation and sector intake — 2026-10-17

After J2 integration PASS (`e839a25a`), the Product Owner explicitly authorized
only review-packet item A on Development project `tnipyxnvhgelwdpykyez`. This is
the scoped exception to §4.6's pending write gate, not a general deployment grant.
The approved plan SHA-256 is
`8bf0303b5c3c2ea48663b73eb15c83e922617474ce9e83362ad82dff54a0348a`:
unchanged catalog-media0016 and operations0017, their two new ledger records and
the reviewed atomic wrapper. Fresh target, source, baseline and concurrency
checks remain mandatory. Production is excluded. Items B–E (category activation,
Auth callbacks, accounts/catalog provisioning and notification text repair)
still require separate approval; no downstream capability is enabled by A.

The owner also accepted broad-sector applications with gradual onboarding in
small groups, including barber/salon candidates. Physical goods use their own
eligible product categories and existing policy/review rules. Haircuts, treatments,
booking, service pricing, staff and slots remain TBD; do not represent services
as stock products or promise that functionality. The first cohort and its size
remain undecided. This acceptance preserves taxonomy §12 and all FROZEN rules.

Item A was applied once and independently checked through read-only hosted SQL:
13 ledger entries, 35 public tables with RLS, the required nine client RPCs and
private listing-media Storage configuration. Original captured schema/privilege
metadata and taxonomy fingerprints are preserved; decisions remain OFF. See the
[installation receipt](MERCHANT_PILOT_TEST_INSTALLATION_HANDOFF.md). This is hosted
schema acceptance only; remote user journeys and final pilot opening remain OPEN.

### 4.8 Next pilot preparation: notifications, callbacks and intake — 2026-10-17

After J3 integration PASS (`ad42c92d`), the owner requested the next pilot package.
This authorizes local implementation/rehearsal and review artifacts, while §4.7's
separate remote-write gates remain in force. No new business feature is approved.

- Item E prepares a forward-only correction of the six known Turkish literals in
  the existing chat and verified-purchase notification functions. Preserve old
  notification rows, recipients/action metadata, function owners/OIDs/ACLs, RLS,
  triggers and the shared notification architecture. A separate new ledger entry
  belongs to the proposed atomic operation; never replay or edit historical0006.
  The proposal stays outside automatic migration discovery and requires exact
  Development identity, current post-A baseline and separate owner approval.
- The local post-A fixture must match the full observed hosted schema. The 22
  newly installed A function bodies were observed with CRLF line endings; local
  reproduction may change only those line endings after exact normalized-body
  verification, then must pass the original full hosted fingerprint. Do not
  rewrite hosted functions or substitute a relaxed expected fingerprint.
- Item C remains the exact four additive callbacks already proposed. Preserve
  existing callbacks and all other shared Auth settings; reread settings before
  application. Configuration matching is not real email or physical-device proof.
- Intake preparation records missing participants, explicit eligible product
  leaves, verified catalog/account/ownership, paired Customer, recovery, device,
  distribution and support evidence. No template or self-reported boolean can
  authorize provisioning or certify pilot readiness. No participant identity,
  private contact or credential is collected in committed artifacts.
- Decisions remain OFF and catalog population remains a separate unresolved
  operational gate. Do not seed products, grant merchant roles, approve product
  submissions or represent services as products under preparation authority.

See [J4 handoff](MERCHANT_PILOT_LAUNCH_PREPARATION_HANDOFF.md) and
[pilot intake guide](MERCHANT_PILOT_INTAKE_GUIDE.md). B–E remote actions, Production,
provider/mail, physical two-device QR and final pilot opening retain their gates.

### 4.9 Approved Development C/E application — 2026-10-17

After J4 integration PASS (`e7efc4d6`), the Product Owner explicitly authorized
only C's four exact additive callbacks and E's guarded notification text repair
on Development `tnipyxnvhgelwdpykyez`. Both were applied once and verified. This
supersedes their earlier pending-approval status, not any FROZEN product rule.

- C: a fresh empty list received the four previously reviewed exact URLs; a page
  reload verified persistence. Site URL remained unchanged. No SMTP, confirmation,
  template or provider setting was edited. This is not real mail/device evidence.
- E: the exact post-A baseline matched; the reviewed atomic wrapper corrected
  six literals in the two existing notification functions and appended one new
  ledger entry. The full resulting fingerprint matches the local proof. Function
  authority, all 13 prior ledger records/source hashes, taxonomy, RLS and catalog
  gates were preserved. No historical notification rewrite or test send occurred.
- A and E are already installed. Do not replay either candidate when integrating
  this receipt. Future corrections require new review, not history removal.
- B/D category, account and catalog changes remain separately gated. Production,
  real mail/PKCE/device acceptance, provider setup, physical QR, signed distribution
  and final pilot opening are outside this authorization. J remains OPEN.

See [J5 test application receipt](MERCHANT_PILOT_TEST_CE_HANDOFF.md). No application
runtime, dependency, service-business scope or economic rule changed.

### 4.10 First-cohort category/catalog/account preparation — 2026-10-17

After J5 integration (`8031bad3`), the owner authorized a comprehensive local
preparation package and confirmed that real participants/products are not yet
selected. No real identities, products or category selection may be invented.
Production is excluded; any Development mutation requires a concrete separate
approval. No FROZEN rule changes or new service/economic features are approved.

- B proposals bind exact selected eligible leaves/ancestors and the observed
  catalog as well as taxonomy/schema; disclose products activation could expose.
  Preserve policy/review metadata and reject drift, concurrent writes and replay.
- D preparation distinguishes existing identity verification from creating Auth
  accounts. No password, private contact, invitation or confirmation override is
  generated. A proposed customer → merchant role change needs exact reviewed
  accounts and live status/ownership rechecks; no admin, demotion or shop transfer.
- Catalog matching preserves shared identities, GTIN uniqueness and exact owner
  restrictions. One shared product may serve multiple merchants. Similarity or
  an exact barcode cannot silently authorize a new product or choose a listing.
- The empty catalog and legacy required price remain a publication/compatibility
  gate. Do not invent a price, seed real products, turn on decisions or bypass
  canonical assignment. The next materialization contract needs separate review;
  synthetic pre-existing products are permissible only in isolated local proofs.
- Missing inputs emit a read-only observation template and incomplete readiness,
  never a fake completed cohort. A/C/E installation must not be replayed. Real
  mail, physical QR, provider, signed distribution and final pilot acceptance stay
  open. J remains OPEN.

See [J6 handoff and remaining catalog contract](MERCHANT_PILOT_COHORT_HANDOFF.md).

### 4.11 Controlled pilot catalog publication and legacy-price compatibility — 2026-10-18

After J6 integration (`465d8842`), the owner authorized this local implementation
package. This resolves the open §4 materialization/read contract; it does not
change a FROZEN rule or authorize a hosted write. Production remains excluded.
Real participants/products are still unknown. The historical J6 no-materializer
statement describes that package; J7 adds the following separately gated path.

- Publish only explicitly reviewed existing merchant submissions for physical
  goods. Recheck exact active category, current verified merchant/shop ownership,
  normalized identity and GTIN. Services/appointments remain out of scope; a
  service-sector merchant may still sell eligible physical products.
- Keep `products.price NOT NULL`. Newly materialized identities carry reserved
  `attributes._catalog_price_contract = listing_only_v1`, storage price `0`, null
  sale price and stock `0`. These values are compatibility sentinels, never a
  free offer, quoted price or inventory. A server guard prevents repricing or
  removing/changing the tag. Existing untagged rows are not backfilled/repriced.
- Current readers preserve the tag through the existing ProductModel JSON paths.
  For tagged/unknown contracts, legacy price/discount fallback is suppressed in
  horizontal/vertical cards, wishlist and recently viewed. Existing seller-price
  labels retain precedence; absent a seller label, show “Esnaf fiyatını gör”.
  Preserve screen structure, navigation and untagged historical behavior.
- Older clients that ignore the tag are **not compatible with first publication**.
  A reviewed compatible Customer/Merchant build pair is a separate data-publication
  gate. Installing private schema alone does not authorize publishing rows.
- Use an operator-only helper and append-only batch receipt. Revoke all client
  and service-role access to this helper/receipt; keep the existing broad decision
  switch OFF. No admin UI, direct client catalog write or second catalog exists.
  The Development candidate explicitly refuses the Production canonical schema;
  it cannot substitute for governed Production assignment/publication.
- Each bounded batch pins target, exact submissions/targets/brand choices, review
  references, schema, catalog and taxonomy observations. Recheck under transaction
  locks, including selected Auth authority. Identity, identifiers, decisions and
  receipt commit together; any failure rolls back the entire batch. Shared
  identity reuse needs explicit selection; unique-origin ownership is preserved.
  Similarity does not auto-merge. Brand creation cannot bypass an existing name.
- No listing is created or activated by approval. Merchant listing prices,
  availability, media and purchase snapshots retain their existing authority.
  Lost acknowledgements use a read-only receipt; replay never creates new rows.
  After commit, corrections require a separately reviewed forward action, not
  deletion of catalog, decision or purchase history.
- J6 category/existing-account checks remain usable through a source-bound adapter
  for the exact rehearsed J7 schema, with fresh observations and separate tokens.
  Do not relax old baseline checks or replay A/C/E. Schema and each real catalog
  batch require distinct owner approvals. Local proof is not remote acceptance.

See [J7 handoff and concrete test-only approval scope](MERCHANT_PILOT_CATALOG_PUBLICATION_HANDOFF.md).

### 4.12 Approved Development catalog infrastructure installation — 2026-10-18

After independently verified J7 Integration PASS (`50c1b16c`), the owner's explicit
approval was applied only to Development `tnipyxnvhgelwdpykyez`: one private batch
receipt table, three private SECURITY INVOKER helpers, two protective triggers and
ledger `20261018003300 / 0033_pilot_catalog_publication`. The unchanged source-bound
transaction committed once. No product publication, category/account changes,
Auth/Storage/notification changes, A/C/E replay or Production access occurred.

Fresh read-only checks preserved the fourteen historical ledger/source hashes,
twelve observed business-table row hashes and taxonomy/catalog hashes. The new
stored source matches the approved LF SHA-256. All 36 public tables have RLS,
the three helpers/receipt deny client and service-role access, publication receipts
and products remain empty, and the broad decision switch remains OFF.

Raw hosted schema is `d9607df877e9115eb811d984e561b4e7`, not the local rehearsal's
`590f31a8d4e3485d6b23434e17bd9d40`. A separate read-only diagnostic proves the entire
structure matches that rehearsal when ONLY the three newly installed function
definition hashes use CRLF-to-LF normalization. All other schema components remain
unchanged in this comparison. Preserve both observations; do not rewrite remote
definitions, old proof, or schema guards to force a match. This is a storage-format
observation, not a FROZEN product-rule change or permission exception.

J7 preparation still requires its exact LF rehearsal fingerprint and must fail
closed on this raw hosted profile. Before any actual row plan, locally reproduce
and validate the three observed bodies and exact full hosted structure, then bind
preparation to that proven profile. Installation acceptance does not imply that
this subsequent preparation adapter or any actual merchant journey is complete.
Compatible clients, exact separate category/account/publication approvals and full
J device/provider/distribution gates remain open. See [J8 installation receipt](MERCHANT_PILOT_TEST_CATALOG_INSTALLATION_HANDOFF.md).

### 4.13 Installed-profile pilot preparation — 2026-10-18

After J8 integration (`62e7ba4a`), the owner authorized the next local preparation
package. Reproduce the observed three function bodies on an owned loopback fixture
and require the exact raw J8 schema `d9607df877e9115eb811d984e561b4e7`. The adapter
must verify the immutable J8 receipt, unchanged J7 source/proof and each observed
function's LF/raw hashes before a local mirror. It must reject unknown executable
text, changed permissions, different baseline, wrong host/port and mirror replay.
This does not authorize modifying hosted functions or relaxing schema comparison.

Use separate installed-profile preparation for cohort and publication. Reuse the
existing category/account/submission/GTIN/ownership/price/atomic receipt contracts
without rewriting historical sources, proofs or migrations. Bind new local proof
to all preparation/runtime sources. Real observations must carry the exact raw
schema; old LF, unknown fingerprints and changed sources fail closed. Do not use
the dated installation receipt as fresh account, category or product evidence.

Default output contains incomplete intake and read-only observation/structure
queries, never installation, account creation or mutation SQL. Complete selected
inputs may produce distinct review-only category, role or publication candidates;
these remain separately authorized operations and contain no automatic approval
token or connection/apply option. Private inputs stay outside Git, plain names
cannot escape their directories, and existing bundles cannot be overwritten.

Actual cohort selection, compatible client review, exact remote row approval,
provider/mail, signed distribution, physical QR and full J acceptance remain open.
No service/appointment capability, new product rule or FROZEN exception is added.
See [J9 installed-profile preparation](MERCHANT_PILOT_INSTALLED_READINESS_HANDOFF.md).

### 4.14 Paired Android artifact and field-acceptance preparation — 2026-10-18

Following J9 integration (`3a2d0361`), the owner authorized the next comprehensive
local package. This prepares an auditable Customer/Merchant pair using existing
Development / merchantPilot flavors and entrypoints. No FROZEN rule, Customer
screen, identity, server permission, feature default or final pilot scope changes.

- One validated Development client input generates both applications' build
  settings. The existing Merchant configuration and shared Supabase contracts are
  cross-checked offline. All later economic/claims/review/promotion/push-schema
  capabilities and Development canonical-taxonomy opt-in stay OFF in this base
  profile. This profile is a compatibility fixture, not final feature selection.
- Run the catalog-price, callback, Merchant recovery/race and pair-configuration
  regressions before building. Bind the two artifacts to the same source snapshot,
  configuration hashes, version and toolchain. Inspect actual APK package names,
  callbacks, permissions, backup/debug settings, signature and executable payload;
  source manifests or build exit codes alone do not prove the packaged identity.
- A synthetic-key debug rehearsal proves compilation/packaging only. It must be
  explicitly non-distributable and must never be installed/launched as a real
  server test. A later candidate uses an exact clean reviewed commit and separate
  approved client input. Release uses the existing external pinned signing path;
  no key generation, signature fallback, credential discovery or distribution.
- Preserve independent per-file and source hashes; changed inputs, overwritten
  artifacts, mismatched pair or stale source require rebuilding/review. Local
  hashes detect drift, not malicious forgery or Product Owner authorization.
- Physical observations bind exact pair hashes and pseudonymous device aliases.
  Keep access/recovery, catalog/media and two-device purchase scenarios distinct.
  Empty evidence stays OPEN; reported observations cannot automatically authorize
  real data writes, provider delivery, legal/support policy or pilot opening.

No remote access, setup, mail/send, account provision, schema change or physical
acceptance is implied. Old Production Customer acceptance does not accept this
Development pair. Real cohort/catalog approval, email/provider, reviewed signed
distribution, physical QR and owner acceptance remain OPEN. See
[paired device package](MERCHANT_PILOT_DEVICE_PACKAGE_HANDOFF.md) and
[field acceptance runbook](MERCHANT_PILOT_FIELD_ACCEPTANCE.md).

### 4.15 Auth/mail rehearsal and existing-provider audit — 2026-10-18

Following integrated J10 (`3da793c6`), the next authorized local package exercises
the existing shared Auth provider, Merchant recovery backend/controller and exact
Customer/Merchant callback contracts against actual local GoTrue, SMTP capture
and the installed public schema. This adds no app Auth store, screen, dependency,
permission, migration, economic rule or Customer redesign.

- Local mail never leaves the owned synthetic fixture. Real server responses
  verify confirmation, PKCE recovery, password persistence/fresh login, replay,
  wrong-app/device, account-switch races, lost acknowledgement and preserved
  role/ownership. In-memory preference/storage fixtures are not physical Android
  lifecycle evidence. Local confirmation/rate settings are explicitly NOT a
  mirror of hosted Development Auth policy.
- Shared Turkish confirmation/recovery HTML retains `{{ .ConfirmationURL }}` and
  the initiating application's redirect. It is a review candidate only; no hosted
  template is replaced. No Resend key, SMTP password, real recipient, token or
  credential enters Flutter, tracked files or evidence.
- **Corrected provider fact:** the owner confirmed an existing Resend account,
  `auth.esnaftavar.com` and sender `noreply@auth.esnaftavar.com`. This supersedes the
  earlier domain-registration-only answer. Do not provision another service or
  account. Historical Production delivery is recorded in
  `PRODUCTION_AUTH_EMAIL_PRECHECK.md`; it is not Development acceptance.
- Fresh read-only audit found Resend domain/sending/DKIM/SPF verified and a
  sending-only key named for Production. Development `tnipyxnvhgelwdpykyez` has
  custom SMTP OFF, confirmation OFF, no Auth hooks, the four reviewed callbacks
  present and `http://localhost:3000` fallback unchanged. No Production project
  was accessed; no key value was read. Existing key visibility/age is not a new
  authenticated send or proof of credential validity.
- Any Development SMTP/credential binding, confirmation-policy/template/fallback
  change or real send needs separate exact approval. Never copy or rotate the
  Production-named credential automatically. Shared Resend domain/TLS/tracking/DNS
  changes can affect Production and are outside a test-project-only approval.

See [J11 delivery](MERCHANT_PILOT_AUTH_MAIL_HANDOFF.md) and
[existing-provider audit](MERCHANT_PILOT_EXISTING_EMAIL_AUDIT.md) for the original
local package and pre-authorization audit. The later authorized operation is below.

#### Authorized Development mail follow-up — 2026-10-18

The owner separately approved Development SMTP binding, its automatic 30-email/hour
limit, one owner-controlled email-confirmed test account without merchant authority,
and delivery/password-recovery testing. Only `tnipyxnvhgelwdpykyez` was targeted.
The owner created/entered the dedicated domain-restricted sending credential and
account passwords in the official UI; no Resend secret entered files, Flutter or Git.
Saved SMTP settings and the existing 60-second per-user interval were read back.
Confirmation policy remains OFF; templates, fallback, callbacks, shared DNS/TLS/
tracking and Production settings were not changed.

The supplied Merchant Android debug candidate passed 135 compatibility tests and
artifact/source checks. Resend's Development-key-filtered list reports the recovery
email **Delivered**. The owner reports installation, inbox receipt, link-driven
password reset and arrival at the expected no-merchant-authority screen. Record
this as **PASS for this single-account Merchant recovery path**, with provider and
owner observations distinguished; it is not independent observation of the phone.
See [acceptance and exact artifact](MERCHANT_PILOT_DEVELOPMENT_MAIL_ACCEPTANCE.md).

J remains OPEN: Customer/registration mail acceptance, broader physical failure
cases, real merchant/shop/catalog preparation, signed distribution, two-device QR
and the Product Owner's pilot-opening decision remain separate. This test does not
authorize merchant-role/shop assignment or further hosted mutations.

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

### 5.3 Merchant transaction recovery — 2026-10-17

After daily catalog recovery integrated at `aca7e985`, the next local package
hardens existing B/E Merchant QR, purchase history and return evidence. No FROZEN
economic rule, refund policy, claim deadline or ownership permission changes.

- An unacknowledged first claim or failed startup recovery keeps new QR input
  closed until existing server recovery succeeds. A known uncertain claim always
  reconciles that exact claim, never replaces it with a nullable latest-record
  read. Reconciliation cannot substitute different immutable claim terms.
  Exceptions remain recoverable; no write is timed out, cancelled or automatically
  resubmitted. Device-registering QR recovery RPCs are also left serialized.
- Capture stable Auth session identity before workspace preflight and reject
  stale errors as well as successes. An old-session rejection cannot authorize
  clearing a durable return intent. These are local continuation fences; live
  server authorization remains mandatory.
- The existing account/purchase-scoped B retry record remains the only locally
  persisted return intent. Validate its bounded request/reason/item quantities
  against original purchase evidence, including already-returned units for exact
  retry. Corrupt records fail closed and are retained. Within one process, local
  editors serialize and preserve the existing intent; acknowledgement clears only
  the matching request/payload. This is not a cross-process database lock or an
  offline mutation queue.
- A known server success and a failed local cleanup are separate states. Retry
  cleanup without sending another return. Unknown acknowledgement retries only
  the original request. A definite server rejection permits editing only after
  fresh purchase evidence; it never invents a refund or restores a coupon.
- Purchase reads have a 15-second presentation deadline and explicit retry.
  Refresh replaces stale detail/actions; pagination deduplicates display rows
  while retaining server offsets, without claiming snapshot pagination. Navigation
  coalesces duplicate opens, protects unsaved in-memory forms and blocks back
  during submission. Host authority loss still disposes all private routes.

Local real-database acceptance reproduced an existing projection defect:
PostgreSQL subtraction bound to the right JSON operand and failed to remove
`customer_user_id` and `confirmed_by_user_id` from the merged purchase payload.
Additive migration0030 subtracts them from the header before composition.
It preserves every other payload field, private helper grants, immutable rows,
return allocation and ledger amounts. Historical0018/0025 bytes remain intact;
remote application still requires explicit Product Owner authorization.
Client purchase/checkout parsers also reject impossible negative physical payment.

No second QR system, Customer layout redesign or provider activation is introduced.
Local contract and client-fault evidence remain
separate from physical two-device J. Delivery:
[Merchant transaction recovery](MERCHANT_COMMERCE_RECOVERY_HANDOFF.md).

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

### 8.1 E earning lifecycle — local implementation boundary

After H0 integration (`b022f5f3`), the Product Owner requested the next large
implementation package. Implement package/capacity, reservations/checkout holds,
earning, five-source maturity, unspent compensation and Merchant/Customer read
surfaces locally. All FROZEN numerical rules above remain unchanged.

E-enabled purchases use the existing QR identity with an earning companion. The
merchant explicitly confirms that the unchanged quote is the actual final sale
and EV coupon use is zero. Old clients cannot finalize that companion through a
legacy completion endpoint; ordinary B-only purchases remain unchanged and never
earn retroactively. Discount amendments and coupon use require a new complete
quote/customer-approval transaction and remain disabled in this delivery.

Real funding requires a separately approved provider/operations process. Local
trusted activation accepts exact external funding and merchant-consent attestations
and applies reserve first; no app button can assert payment success. Reserve,
available receivables and external funding remain distinct accounting sources.

One cart attempt has a fixed server deadline, including release/reacquisition;
after expiry a new attempt requires explicit user action. Existing short checkout
holds remain tied to their original package. Capacity and H0 journal changes commit
with the purchase/return evidence or roll back together. A short serialization
epoch orders local V1 reward writes; no provider call occurs inside that lock.

Pending contributions rebuild chronologically; issued source links never move.
Normal pre-maturity threshold loss restores the contribution's package capacity
and fund (or its expired unused-fund receivable). Ordinary post-maturity returns
retain rewards; audited invalidation reverses unspent value. Redemption remains
disabled, and partially spent O7 recovery still belongs to the later complete
redemption/return extension. No customer cash debt or external cash refund is
inferred. Provider, legal, deployment and physical acceptance gates stay open.

Local implementation and verification are recorded in
`MERCHANT_REWARD_E_HANDOFF.md`; this does not mark the full E redemption slice or
the physical QR acceptance complete.

### 8.2 Local customer-authorized coupon checkout extension

After integration of the earning delivery at `af9d5965`, the Product Owner
authorized the next implementation package. The local checkout extension uses
the same QR, claim, purchase and H0 journal; it changes no FROZEN numerical rule.
Its separate client/server capability defaults OFF. Earlier §8.1 describes the
earning-only delivery; the following supersedes its local redemption/O7 boundary.

- The Customer reviews the authoritative sale, selected coupon and physical
  payment amounts before creating a coupon QR. Exact approval binds the cart and
  classification fingerprint, live Auth session, request UUID and immutable QR.
  Old completion APIs reject coupon contracts before economic effects. Merchant
  confirmation attests all three amounts; no unilateral merchant coupon use.
- The existing net-payment threshold also governs capacity at approval time.
  Approval below the snapshotted threshold releases the reservation/checkout hold
  and its earmarked fund in that same transaction, before merchant claim. Reopen,
  replay or reservation refresh cannot reacquire capacity against the gross sale
  while that consent is live. An eligible net amount retains its valid hold;
  cancelling consent permits normal reassessment with the original attempt deadline.
- Listed sale prices remain unchanged. Merchant discounts/price amendments still
  require a new quote and approval and are not an implemented discount engine.
  Unknown or cash-equivalent classification blocks coupon use for the whole cart.
  Classification is private, append-only trusted-operator evidence with policy
  reference/reason; approval of the actual legal perimeter remains an external gate.
- Coupon lots consume oldest issuance first, then original source chronology.
  Line coupon allocation uses proportional minor-unit arithmetic, largest
  remainder and listing UUID ties. Final terms retain the original quote plus
  exact allocated coupon/payment and return-policy snapshot. Purchase, debit,
  source uses, merchant reserve/pending receivable and net-eligible earning commit
  together. Only redemption fills the reserve; no settlement execution is added.
- Audited invalidation splits each source into unspent reversal and spent future
  reward offset. Restored original package fund/capacity and memo obligation are
  journaled atomically, without customer cash debt. Recovery happens from the next
  mature chronological group immediately before spendable coupon issuance, in the
  same transaction. Pending contributions remain contingent until maturity; this
  prevents a normal pre-maturity return from recovering the same offset twice.
  Five immutable source links and 250 TL face remain; remaining value may be less
  or zero after offset recovery. A later invalidation of an offset-funded source
  creates only that source's invalid value, not a second recovery of the old obligation.
- Genuine return evidence allocates each returned quantity from the remaining
  item sale/coupon amounts, rounding down until the final remaining quantity.
  An administrative correction reverses that exact recorded allocation. This
  preserves totals even for out-of-order corrections. Neither cash refund nor
  coupon restoration is executed or represented as successful; O8 stays open.
- Exact retries reconcile existing receipts even after gate-off. New approval
  requires both checkout and E/H0/B readiness. Live customer session and current
  classification are rechecked at finalization; changed balance fails atomically.

Implementation/acceptance records: `MERCHANT_CHECKOUT_E_WORKLOG.md` and
`MERCHANT_CHECKOUT_E_HANDOFF.md`. Physical two-device acceptance, provider funding,
classification policy, legal/settlement approval, reconciliation operations and
explicit remote deployment authorization remain separate release gates.

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

### 9.1 H0 local implementation boundary — 2026-10-15

Following the Product Owner's instruction to start the next work after D/F
integration (`6ef06be8`), H0 implements the dependency-ordered accounting substrate.
It does not activate E/G/H1, deploy remotely or approve monetary/legal policy.
The immutable V1 policy stores the already frozen §8 amounts/durations and §9
reserve cap; policy metadata seeds no account balance or real funding.

Trusted server modules/operators register typed, immutable source attestations.
Their evidence reference is not payment-provider verification or proof of coupon
consent/eligibility. E/G must validate those facts and call source/journal/consumer
operations inside their complete transaction. Mobile users and service_role have
no posting, source-registration, policy-write or raw-accounting permission.

Account classes separate merchant coupon-pending/available, unused-fund-pending/
available and mandatory reserve; customer pending/coupon value; package free/held
fund; platform control/service accounts; and a separate noncash future-offset
obligation. Signed integer postings sum to zero in TRY; protected accounts cannot
overdraw. Balances are sums of immutable postings, never cached mutable authority.
Integer JSON strings preserve exact money across browser/mobile runtimes.

Only coupon-redemption sources replenish reserve, up to the snapshotted cap.
Unused-package sources remain in their own pending pool. Trusted pending-release
entries retain source class; they do not authorize a bank withdrawal. Platform
service entries consume reserve first, then explicitly selected available claims.
Exact compensating reversals preserve history and reject insufficient remaining
value, repeated reversal or reserve overfill after a subsequent refill. H0 does
not invent a partial reclassification to make a reversal succeed; E owns that
later source-allocation workflow. Funding/redemption/settlement capabilities
remain OFF.

H0's future-offset primitive is conservative: it excludes all current unspent
customer value before allowing a bounded obligation against an original reward
source. Recovery simultaneously consumes future pending accrual and reduces that
obligation, with original-source/accrual caps and no duplicate full reversal.
E still owns per-coupon/source spent allocation and detailed O7 partial reversal;
cases not safely representable by H0 fail closed. General return postings are
reserved but disabled until that allocation policy/transaction is implemented.
No customer cash debt, payout policy, provider success or eligibility is inferred.

H0 adds only read contracts and an unbound read-only Dart adapter. Existing Reward
screens and Merchant tabs do not become balance/financial surfaces; that remains
H1. Deployment needs the reviewed account map, reconciliation owner and explicit
Product Owner authority described in the slices. Local acceptance is separate.

### 9.2 H1 bounded local read surface — 2026-10-15

After checkout E and the net-threshold repair integrated at `1374f828`, the next
Merchant package exposes existing H0/E records as “Hesap Bakiyesi”. This advances
only the read-only part of H1. Full H1 still depends on G and approved O8 policy;
no FROZEN economic rule, payout schedule or provider decision changes.

An independently default-OFF statement gate and local Merchant client flag bind
the existing accounting adapter. One exact-owner, live-session RPC returns all
five Merchant account buckets and bounded journal pages from the same database
snapshot. Only the Merchant's postings are projected; customer identities,
source/evidence references, operator reasons and platform/counterparty accounts
remain private. No duplicate ledger, mutable balance, new inbox or Customer UI
change is introduced.

Pending coupon and unused-package funds remain separate. Internally released
receivables are labelled “Beklemesi tamamlanan alacak”, never bank-withdrawable
or paid. The reserve is separate and not cash-withdrawable. Missing settlement
policy is explicit: no payout action, paid total, cash refund or settlement
success is invented. Original and compensating entries remain visible.

Each page includes a revision derived from the append-only owned journal count.
If a new journal commits between pages, the server rejects the old revision and
the client clears the partial statement and requests a fresh read. This avoids
mixing balances with older pages, including transactions that started earlier but
committed later. Role/ownership/session checks precede even disabled reads.
Account changes, resume, missing capability and failures never retain another
account's financial data or fabricate zero balances.

All schema rehearsal and synthetic accounting writes are local/test only.
Production, settlement, G, provider delivery and physical two-device acceptance
remain separately gated. Delivery evidence: [H1 read surface](MERCHANT_STATEMENT_H1_HANDOFF.md).

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

### 11.1 G preparation boundary — Merchant promotion drafts

The local G preparation increment implements the existing structured-creative
decision only. Its four template families are store introduction, product,
current campaign announcement and store invitation, with two fixed copy variants.
Only current owned eligible catalog/campaign facts and existing published listing
media may populate a preview. Campaign freeform copy is not treated as proof of
advertising claims. Explicit campaign scope and dates remain visible.

An owner may preview, save, revise, archive and restore a **draft**. A saved draft
is neither a purchased package nor a published advertisement. Saving requires the
server to revalidate the exact preview fingerprint; source drift requires a fresh
preview. Reads label previously saved content as needing an update when current
facts differ. Immutable revision history is historical content, not live price or
publication evidence. Repeated uncertain writes reconcile the original immutable
request; they must not create another draft.

This increment uses independent default-OFF client/server capability gates.
The 500-root-per-shop technical guard and 20-row read pages are abuse/resource
bounds, not commercial entitlements. Historical roots/revisions are not removed
by archiving. This does not choose a production retention policy.

No advertising price, purchase/debit, paid interval, push entitlement, targeting,
ranking/rotation, Home placement, measurement/attribution or provider delivery is
enabled by draft preparation. No separate balance or notification foundation is
created. Full G, O8/O9/O10 policy work, H1 settlement, I and physical J remain
separate gates. The FROZEN seven-day product and thirty-day push entitlement
rules above/below are unchanged.

### 11.2 F/G Merchant management recovery — 2026-10-17

After transaction recovery integrated at `298290d8`, the next authorized local
package completes existing Campaign Lite and promotion-draft recovery. It changes
no FROZEN offer, paid-placement, accounting or notification rule.

- Capture stable Auth session identity for private routes and every adapter
  continuation, including image signing and error classification. Same-session
  token refresh preserves work; replacement sessions and broken authority streams
  invalidate it. Existing server owner/session checks remain authoritative.
- Bound reads with explicit retry and suppress late continuations. Writes keep
  their pending state until transport resolves; neither an artificial timeout nor
  app resume may open a second submission. Uncertain responses retry only the
  original immutable command. No automatic write retry or offline queue is added.
- Protect unsaved in-memory campaign/creative selections on back navigation.
  A revision conflict preserves the draft, reads the exact owned current record,
  then requires explicit use-current or keep-draft review. The next save uses that
  current revision and can conflict again. A fresh read is not a write receipt;
  a missing/disabled record cannot become an implicit new campaign or draft.
- Add bounded exact-owner detail reads for those existing records in forward
  migration0031, reusing current projections, authority checks and default-OFF
  gates. No tables, historical migration edits, grants to public/service roles,
  paid operation or new persistence store. Missing new RPCs fail closed during
  recovery until the separately authorized deployment is available.
- Refresh/resume and failed reads cannot leave stale action controls active.
  List/source/history offsets advance by raw server page size, independently of
  display deduplication. Page retry stays on the failed page; no snapshot-pagination
  guarantee is introduced. Product/photo selectors retain truthful errors and
  bounded loading; duplicate dialogs and route opens coalesce.

Preserve five Merchant tabs, existing Customer layouts and shared notifications.
Local transport, widget, real database/API and build evidence remain separate
from physical-device J and Production rollout. Full G, settlement and provider
activation remain gated. See [delivery](MERCHANT_MANAGEMENT_RECOVERY_HANDOFF.md).

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

### 12.1 I0 preparation boundary — durable service transport

The local I0 increment extends the existing notification foundation. It does not
complete I or choose O10 audience/quota/retention policy. The unchanged
`0016_engagement_foundation.sql` proposal is rehearsed first; the separate
`0029_push_dispatch_i0.sql` proposal then adds a default-OFF server gate and
service-only dispatch. Neither proposal is silently promoted into automatic
migrations. No provider configuration, automatic runner or outbound real send
is enabled.

The concrete dispatcher rejects **all marketing and campaign-associated** rows,
including opted-in general banners, until the canonical user-based caps and
eligibility contract exist. This closes the old draft dispatcher's uncapped
marketing path; the FROZEN 1+1 caps and thirty-day entitlement remain unchanged.
Service messages retain their independent preference and generic lock-screen
copy. Private content still requires authenticated existing-notification lookup.

Device registration binds to an existing verified live Auth session and rotates
an opaque revision on account, session, token, platform or enabled-state changes.
Old unbound registrations require registration again. Claim and begin recheck
the current recipient role, consent, gate and device/session. A late invalid-token
response disables only the exact attempted revision, never a replacement owner
or token. Client disable is bound to the current Auth session as well as owner.
Logout invalidates selection even when client-side disable was missed. Dispatch
requires read-committed transactions, so an older repeatable-read snapshot cannot
miss a just-committed first opt-out.

One existing (notification, installation, role) delivery key can reach the provider
at most once. A planned claim transitions durably to **unknown before external
I/O**. A crash, timeout or lost database acknowledgement preserves that claim.
Only an explicit provider acceptance/rejection may resolve it; trusted later
reconciliation requires provider evidence. Replaying dispatch never resends any
existing key, including cancelled/unattempted keys. I0 has no automatic retry,
claim expiry or operator override. This conservative preparation is not a
guarantee of delivery. “Provider accepted” never means displayed by the OS.

Validation and dispatch have a defined boundary: revocation committed before
begin cancels the attempt; revocation after begin cannot recall an in-flight
external message. Generic copy and authenticated destination lookup remain
necessary even with these checks. A page contains at most100 installation IDs;
the cursor continues fanout without adding a commercial entitlement or device
allowance. No token or provider error body enters evidence/claim records.

Real transport deployment, provider evidence binding, retention review,
marketing G/O10 and physical-device acceptance remain separately gated.

### 12.2 I1 local client preparation — 2026-10-17

After I0 integrated at `4613988b`, the next authorized local package prepares
the existing shared mobile transport and Merchant host. No FROZEN rule changes.
The provider remains unconfigured; the local schema switch defaults OFF, and
the existing loopback-only Merchant bootstrap remains enforced. Customer layout,
host binding, provider SDK/configuration and actual delivery are not activated.

- Permission remains an explicit user action. Device enrollment is independent
  of service/marketing consent; local preferences never become server opt-in.
  Token rotations subscribe before initial token retrieval and serialize with
  registration. Logout waits for pending SDK/registration work before revocation.
  An uncertain write is not cancelled by a timeout or duplicated by another tap.
- The shared coordinator fences operations with authority revision and stable
  Auth session identity, including same-user replacement sessions. A refresh of
  the same Auth session is not replacement. The backend adapter discards stale
  responses; the server remains the sole live-session/role/ownership authority.
- Per-app-role local storage contains only an installation UUID and a cleanup
  marker, persisted before token acquisition. No account, session, token or
  credential is stored there. An interrupted process requires explicit reconnect:
  invalidate the previous provider token, persist a fresh installation, then
  request registration. Never disable an old binding with a new session's rights.
  A normal same-session exit disables the server binding before deleting the
  provider token. Failure to revoke, delete or persist cleanup prevents reuse.
- Recovery does not claim an abandoned server row was disabled or an in-flight
  message recalled. Generic I0 copy and authenticated record lookup still apply.
  Provider deletion must positively invalidate the old token or report failure;
  proving this with a real SDK and reviewing retired-row retention are rollout
  gates. This conservative local increment does not implement automatic
  re-enrollment or promise cold-start/background OS delivery.
- Merchant settings expose pending, permission, connected and recoverable-error
  states through the shared controls. A validated tap opens the existing inbox,
  never a payload-supplied privileged route. Account authority loss invalidates
  listeners and pending lookup; duplicate taps are bounded and deduplicated.
  Preference/notification reads have a 15-second timeout with retry; writes keep
  their pending outcome and do not infer success or cancellation.

Full I, G/O10 marketing, Customer host/provider binding, physical-device J and
Production remain separately gated. No migration or second inbox is introduced.

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
