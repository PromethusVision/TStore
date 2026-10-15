# Merchant trust and Campaign Lite — D+F

Status: local implementation delivered; release gates remain open.
Baseline: `d013b761` (integrated C).
Branch: `agent/merchant-trust-campaigns-df`.

## Audit and delivery plan

- Reuse verified_transactions/items, C service evaluations/revisions and
  purchase_invalidations. Never infer trust from a QR claim or public aggregate.
- Preserve Customer layouts and Merchant five-tab navigation. Dashboard routes
  open trust details and campaign management. Small shared badges/explanations
  and shop offers extend existing identity/profile surfaces.
- Add immutable rule/award history, erasable subject mapping, reviewed area
  assignments, current projections and bounded event/time refresh. Public reads
  expose eligibility, title and explanation, not raw customer/audit identifiers.
- Add owned offer revisions, optimistic edits, idempotent writes, date/type/scope
  validation and published-image selection. Revalidate public eligibility against
  current listing/media state. No second banner, inbox, payment or discount engine.
- Keep badges/offers/client gates OFF by default; additionally gate monetary
  offer publication until B actual-sale compatibility is separately approved.
- Acceptance spans native PostgreSQL contention, real local Auth/HTTP/Storage,
  shared client unit/widget/golden tests, analyzer and complete regression suite.
- Deliver only a task branch commit/push; Integration Agent owns main. Production,
  real geography import, provider setup and physical two-device release stay gated.

## Screen inventory

Merchant dashboard summary; trust/progress/history; full badge explanation;
campaign list (draft/scheduled/active/ended/paused/blocked); create/edit with owned
listing/image selection; preview and activation/deactivation. Customer identity
badge strip/profile history and current shop-offer list/detail reuse shared views.

## Technical decisions

Independent append-only dirty events avoid taking business-row locks in badge
triggers. A bounded trusted worker deduplicates targets and records actual state
transitions; live-read qualification prevents stale eligibility after a threshold
or 90-day boundary. No geography is guessed from text addresses. Full details and
test evidence are recorded in the handoff and sanitized acceptance reports.

## Completed implementation

- Additive 0020: immutable version-1 rules and award/correction snapshots,
  erasable subject map, private projections/events, reviewed versioned geography,
  live public eligibility and bounded server refresh/backfill. No real areas are
  seeded. All new tables have RLS and explicit grants/revokes.
- Additive 0021: owned campaign revisions/receipts, three supported types/scopes,
  optimistic edit detection, exact-request retries, scheduling, publication and
  deactivation, selected product names and existing published image selection.
- Shared typed client: strict decoding, private/public access separation,
  immutable retry commands, away-and-back session invalidation, bounded photo
  signing, independent server-derived expiry and readable image fallback.
- Merchant dashboard routes to trust/progress/history and campaign management.
  Create/edit includes product selection/search/pagination, up to five existing
  photos, date/time, preview, draft-save and explicit publication. Existing five
  tabs are retained. Customer changes stay within profile/shop extensions.
- Default-OFF client `TRUST_COMMERCE_V1_ENABLED`; separate default-OFF server D/F
  gates. D additionally requires C lifecycle readiness. Monetary publication is
  independently OFF. No dependency changes or notification architecture changes.

## Concurrency, privacy and operational constraints

The worker serializes itself with an advisory lock and captures exact event IDs.
It does not lock queue rows before taking subject/Auth FK locks, avoiding a cycle
with concurrent account erasure. Late events remain queued. A first projection
racing Auth deletion returns safely without an orphan identity; this is exercised
using independently blocked PostgreSQL connections, including managed local Auth.
Legacy review callbacks and post-delete cleanup preserve account erasure.

V1 rules are immutable and actually supply numeric thresholds/window/milestones.
Geography validates GeoJSON structure, holes and multipolygons; authoritative
topology/source review remains an operator prerequisite. Assignment is explicit,
versioned, request-idempotent and coordinate-bound. Dataset approval changes
have immutable history and refresh affected shops. A moved shop returns pending.

Technical input ceilings: 100 selected listings, five photos, 100 title characters,
500 description characters and 500 saved campaigns per shop. These bound requests,
not new paid tiers or marketing entitlements. Edits preserve old revision evidence.
An ended/paused/blocked campaign remains owner-visible and cannot appear in the
public projection. All-scope follows current sellable assortment; explicit scopes
fail as a whole if a selected listing is no longer eligible. Retired/invalid images
are omitted without inventing replacement ownership.

Release/run instructions and current evidence: [MERCHANT_DF_HANDOFF.md](MERCHANT_DF_HANDOFF.md).
