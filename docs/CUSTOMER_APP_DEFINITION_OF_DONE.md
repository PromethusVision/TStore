# Customer App Definition of Done

Status: **CANONICAL CLOSEOUT PROPOSAL**
Wave: **16 — Customer App Commercialization Closeout**

## Customer V1 feature freeze

Feature freeze can be declared when all of the following are true:

- Auth, profile, Home/discovery, category/listing, product, seller, shop,
  search, nearby, wishlist, Cart V2, saved locations, reviews, QR customer
  client, in-app notifications, chat, settings and navigation have no open P0
  or automatically fixable P1 defect.
- The O2O contract is explicit: no online payment, shipping or legacy order
  checkout is implied.
- Open owner decisions have a recorded answer or accepted temporary policy.
- Every code change has deterministic tests; analyzer and full suite pass.
- Taxonomy and final UI kit are represented as planned dependencies rather than
  partially implemented branches.
- Remaining work is classified in one owner-visible backlog.

Wave 16 satisfies the functional/code portion. Feature freeze is therefore
**CONDITIONAL**, pending the three owner policy decisions and acceptance of the
external/manual release backlog.

## Commercialization ready

Commercialization requires feature freeze plus:

- final owner-approved taxonomy data/query/navigation migration completed and
  verified against real catalog data, unless the pilot explicitly freezes the
  current demo taxonomy;
- final UI-kit rollout and accessibility/text-scale/physical visual acceptance;
- real two-device QR success, wrong-merchant, expiry, replay and concurrency;
- signed final Android artifact installed and store/internal-track accepted;
- iOS archive/TestFlight/device/callback gates for an iOS launch, or an explicit
  Android-only pilot decision;
- exact Production identity/config, migration/RLS/RPC/Realtime/Storage/Auth/
  SMTP and backup/PITR go/no-go evidence;
- privacy decisions for device-local recent searches/chat draft and monitoring;
- no disposable Production fixtures and an approved rollback/support plan.

Automated compile, widget tests or prior-wave device evidence cannot replace
these time-sensitive final-candidate gates. Current state: **CONDITIONAL / NOT
YET COMMERCIALIZATION READY**.
