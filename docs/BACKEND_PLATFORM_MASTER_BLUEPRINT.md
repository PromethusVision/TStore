# Platform Backend Contract Master Blueprint

**State:** PROPOSED / RECOMMENDED / OWNER DECISION REQUIRED

This is the executive entry point for Wave 21. It describes how the working
Customer backend can evolve into a Customer + Merchant ecosystem without a
rewrite. It is not SQL, an approved schema or permission to access any remote.

## 1. Preserve and extend

Current canonical contracts remain the baseline: 0001–0009, public discovery,
customer-owned private data, Cart V2, opaque short-lived QR, one-winner merchant
confirmation, verified-purchase snapshots and one active review per customer and
canonical product. Future concepts are additive and must pass the Customer N/N-1
compatibility gate.

## 2. Future identity model

- Auth user and profile remain account identity, not merchant authorization.
- A minimal merchant organization groups membership; a shop/branch is the
  operational and QR authorization boundary.
- Membership grants a small server-evaluated capability set. Revocation and
  suspension take effect on the next command/subscription authorization.
- Canonical product, variant and shop listing are distinct. Listing owns price,
  availability and merchant SKU; the product owns normalized identity/content.
- Stable IDs and explicit lineage preserve history through rename, retire,
  merge, split, account deletion and shop transfer.

## 3. Security and authorization

RLS is least privilege and server-authoritative for anon, customer, merchant,
staff and operator principals. UI roles never authorize. Service-role credentials
never enter Flutter assets, logs or general clients. Privileged commands validate
Auth, active membership, exact resource scope, state transition, revision and
idempotency. Operator interfaces are callers, not authorization sources.

Public/account/customer-private/merchant-private/security/audit/policy/analytics
classes drive grants, event payloads, retention and deletion behavior. Precise
customer location is request-scoped by default; chat and PII never enter generic
analytics.

## 4. Commands, transactions and concurrency

Direct RLS access remains suitable for bounded reads and simple owner-scoped
mutations. RPC/server commands are justified for atomic multi-row transitions,
privileged catalog changes, QR consumption and invariants that direct writes
cannot safely enforce. V1 keeps the command set small.

QR consume plus verified-purchase creation is one transaction with exact-shop,
expiry and one-winner semantics. Idempotency keys make retries return the same
result; row locking/conditional updates and revisions prevent duplicate/lost
mutations. Audit facts are separate from product analytics.

## 5. QR, purchase and review

QR is not payment. Generic analytics, Ads clicks, client telemetry or legacy
booleans cannot create verified purchase. Corrections append/link evidence rather
than silently rewrite history. Review eligibility derives from immutable verified
purchase evidence. Repeat purchase and quantity never multiply review rights.
Ratings remain customer feedback and cannot be hidden by reputation.

## 6. Reads and performance

Bounded detail reads may be direct. Unbounded discovery, seller comparison,
nearby, chat, notifications, audit and dashboard feeds use stable ordering and
cursor pagination. Seller comparison is canonical product to active listing to
active shop; nearby uses request-scoped location and coarse shop coordinates.
Merchant dashboards name verified purchase, soft intent and listing health
separately—none is silently called revenue or sales.

Indexes follow proven filters, joins and order. Search may begin with current
database reads and evolve to a derived model only when scale/relevance evidence
requires it. N+1 and overfetch are measured before denormalization.

## 7. Realtime, notifications and Storage

Realtime is limited to workflows that materially need it; subscriptions repeat
authorization and terminate/reload safely on account switch or revocation. Current
chat/notification semantics are extended rather than rebuilt. Canonical Storage
buckets/paths and server validation remain; product canonical media and merchant
listing media have different write authorities. Orphan cleanup uses referenced,
auditable lifecycle rules.

## 8. Ads, Reward, reputation and events

Paid Ads cannot manufacture review, reward, verified-purchase or reputation
evidence. Generic analytics cannot mutate reward ledgers. Authoritative domain
events originate from committed domain state; client telemetry is untrusted
observation. An outbox is deferred until durable asynchronous consumers and
failure evidence justify its operational cost.

## 9. Migration strategy

Use additive-first expansion, backfill, reconcile, dual-read only when necessary,
then explicitly authorized cutover and later retirement. Avoid dual-write where a
single canonical write plus compatibility projection works. One migration author
owns each wave; remote apply is separate authority. Never rewrite an applied
migration. Development acceptance precedes a single-writer Production window with
backup, abort, rollback/forward-repair and exact postflight gates.

## 10. V1 recommendation

MUST_HAVE: Customer preservation; minimal merchant membership/capabilities;
listing validation/revision; exact-shop QR confirmation; RLS; audit/idempotency;
additive migration and compatibility tests.

SHOULD_HAVE: governed product candidates, selected variants only where identity
requires them, truthful listing freshness/dashboard semantics, cursor pagination
and operation-critical Realtime.

DEFER: full organization hierarchy, universal variants, variable measure,
perfect stock, broad Realtime, generic outbox, automated moderation, Reward,
gamification, paid attribution/billing and public reputation.

## 11. Owner decisions

Twenty-five raw decisions are preserved in twelve semantic roots. The highest
impact choices concern merchant staffing, variant/measure scope, listing truth,
catalog corrections, QR shop binding, deletion/retention, operator governance,
economic/trust systems and privacy. Recommendations are simulated but no option
is selected. See `BACKEND_OWNER_ROOT_DECISIONS.md` and decision cards produced by
the QA queue.

## 12. Implementation and evidence

The recommended first ten waves start with baseline tests, merchant identity,
listing commands and QR verification, then layer merchant operations, candidate
intake, selected variants, catalog correction and approved lifecycle rules.
Stress matrices are design evidence; future SQL/RPC/RLS, integration, concurrency,
physical QR, Development and Production acceptance remain mandatory before launch.

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
