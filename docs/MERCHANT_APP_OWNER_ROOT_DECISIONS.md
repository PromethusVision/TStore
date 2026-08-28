# Merchant App Owner Root Decisions

Status: **PROPOSED — OWNER_DECISION_REQUIRED**
Wave: 17 / WP92

## RD-01 — Merchant/catalog policy and verification gate (P0)

- **QUESTION:** Which merchants/products may activate, with what evidence?
- **OPTIONS:** A all ordinary self-serve; B approved allowlist + review-signalled fail-closed; C manual review for all.
- **RECOMMENDED:** B.
- **WHY:** Balances pilot speed with regulated/unknown risk.
- **TRADEOFF:** Moderation ownership and allowlist maintenance.
- **AFFECTED FEATURES:** Onboarding, shop/catalog activation, policy, support.

## RD-02 — Organization/shop/branch topology (P0)

- **QUESTION:** What multi-shop structure launches?
- **OPTIONS:** A direct user→one shop; B organization→shops with simple single-shop UX; C enterprise hierarchy.
- **RECOMMENDED:** B.
- **WHY:** Avoids later identity rewrite without enterprise UI.
- **TRADEOFF:** More backend authorization concepts.
- **AFFECTED FEATURES:** Membership, listing, QR, analytics, staff.

## RD-03 — Staff and permission launch model (P0)

- **QUESTION:** Is staff management V1, and how granular?
- **OPTIONS:** A owner only; B owner + narrow QR/catalog staff presets; C full custom roles.
- **RECOMMENDED:** B if pilot shops use staff, otherwise A activation with B-ready backend.
- **WHY:** Cashier/editor separation has security value; custom matrix is premature.
- **TRADEOFF:** Invite/revoke/session support burden.
- **AFFECTED FEATURES:** QR, catalog, shop settings, security.

## RD-04 — Canonical identity roots (P0)

- **QUESTION:** Final product/variant/listing, identifier, merge/split and bundle rules?
- **OPTIONS:** A simplify to product+listing; B retain three layers with governed defaults; C allow merchant-defined global identity.
- **RECOMMENDED:** B; decide each catalog source P0 explicitly.
- **WHY:** Preserves durable product evidence and local offer truth.
- **TRADEOFF:** Moderation and variant complexity.
- **AFFECTED FEATURES:** Search, listing, reviews, QR snapshots, analytics.

## RD-05 — Candidate/custom activation (P0)

- **QUESTION:** Can missing/custom products become visible before catalog approval?
- **OPTIONS:** A never; B restricted merchant-private draft then governed approval; C immediate public listing.
- **RECOMMENDED:** B with policy fail-closed.
- **WHY:** Preserves merchant work without polluting canonical identity.
- **TRADEOFF:** Draft projection and review queue.
- **AFFECTED FEATURES:** Candidate, custom, moderation, customer discovery.

## RD-06 — QR lifecycle semantics (P0)

- **QUESTION:** TTL, validation reservation, logout binding and temporarily-closed behavior?
- **OPTIONS:** A confirm-time atomic consume with current short TTL and no reservation; B short validation reservation; C long/offline acceptance.
- **RECOMMENDED:** A; fail closed offline and for ineligible shop.
- **WHY:** Smallest fraud/concurrency surface.
- **TRADEOFF:** More customer QR regeneration under slow operation.
- **AFFECTED FEATURES:** Customer QR, Merchant scan, review evidence, support.

## RD-07 — Variable-measure verified snapshot (P0)

- **QUESTION:** How is requested vs actual quantity confirmed?
- **OPTIONS:** A customer quantity only; B merchant actual only; C requested + merchant-confirmed actual snapshot.
- **RECOMMENDED:** C with governed units/precision.
- **WHY:** Honest physical-purchase evidence without changing review rights.
- **TRADEOFF:** More confirmation UI and validation.
- **AFFECTED FEATURES:** Listing, QR context, transaction items, analytics.

## RD-08 — Service/mixed/booking boundary (P0)

- **QUESTION:** Do services/bookings enter Merchant V1?
- **OPTIONS:** A product-retail pilot only; B shop presence for service/mixed but no service catalog/booking; C full service catalog/booking.
- **RECOMMENDED:** B.
- **WHY:** Supports merchant reality without inventing a booking engine.
- **TRADEOFF:** Service merchants have limited operations initially.
- **AFFECTED FEATURES:** Onboarding, taxonomy, catalog, navigation.

## RD-09 — Analytics launch/privacy scope (P0)

- **QUESTION:** Which intent metrics, thresholds and retention launch?
- **OPTIONS:** A listing health + verified purchases only; B add aggregate views/directions under thresholds; C customer-level analytics.
- **RECOMMENDED:** B after privacy definition; C excluded.
- **WHY:** Actionable insights without identity leakage.
- **TRADEOFF:** Aggregation/dedup/privacy operations.
- **AFFECTED FEATURES:** Dashboard, metrics, privacy, support.

## RD-10 — Review interaction/moderation (P1)

- **QUESTION:** Are public replies in V1 and how are reports handled?
- **OPTIONS:** A read/report only; B one public reply; C private resolution workflow.
- **RECOMMENDED:** A for pilot.
- **WHY:** Lowest retaliation/moderation burden.
- **TRADEOFF:** Less merchant response capability.
- **AFFECTED FEATURES:** Reviews, notifications, moderation.

## RD-11 — Availability freshness (P1)

- **QUESTION:** When is merchant availability stale and what happens?
- **OPTIONS:** A label only; B reminder then unknown; C auto out-of-stock.
- **RECOMMENDED:** B after threshold research.
- **WHY:** Avoids false stock while not claiming absence.
- **TRADEOFF:** Notifications and merchant maintenance.
- **AFFECTED FEATURES:** Listings, Customer App, dashboard.

## RD-12 — Bulk operations (P1)

- **QUESTION:** Which bulk writes launch and are results atomic?
- **OPTIONS:** A none; B selected-listing availability with per-row results; C price/retire/cross-branch bulk.
- **RECOMMENDED:** B.
- **WHY:** Useful, reversible and bounded.
- **TRADEOFF:** Partial-result UX/audit.
- **AFFECTED FEATURES:** Catalog, activity, support.

## RD-13 — Listing media rights/promotion (P1)

- **QUESTION:** Can local media publish and become canonical?
- **OPTIONS:** A canonical only; B moderated listing media, no auto-promotion; C direct canonical promotion.
- **RECOMMENDED:** B when storage/moderation ready.
- **WHY:** Local realism without shared-catalog tampering.
- **TRADEOFF:** Rights/moderation/storage burden.
- **AFFECTED FEATURES:** Listings, Customer App, catalog operations.

## RD-14 — Notification channels (P1)

- **QUESTION:** Which events use push/email and which are mandatory?
- **OPTIONS:** A in-app only; B critical push + in-app; C broad multi-channel.
- **RECOMMENDED:** B with minimal previews/quiet-hour policy.
- **WHY:** Critical action visibility without notification overload.
- **TRADEOFF:** Delivery/consent/support work.
- **AFFECTED FEATURES:** Security, catalog, shop, QR.

## RD-15 — Client architecture/sharing (P1)

- **QUESTION:** Separate native app or web-first, and what is shared?
- **OPTIONS:** A separate Flutter + narrow packages; B one app with role UI; C web-only pilot.
- **RECOMMENDED:** A, validated against merchant research.
- **WHY:** QR/device fit and independent security/release lifecycle.
- **TRADEOFF:** Two apps and package governance.
- **AFFECTED FEATURES:** All implementation/release/test work.

## RD-16 — Price history (P1)

- **QUESTION:** What history is retained/shown/exported?
- **OPTIONS:** A audit only restricted; B merchant-visible recent history; C long export/analytics.
- **RECOMMENDED:** B with policy-defined retention; export deferred.
- **WHY:** Correction/support value without analytics bloat.
- **TRADEOFF:** Storage/privacy/support semantics.
- **AFFECTED FEATURES:** Price editor, activity, analytics.

## RD-17 — Navigation/dashboard composition (P2)

- **QUESTION:** Four or five primary destinations and dashboard depth?
- **OPTIONS:** A four tabs with reviews in summary; B five tabs; C QR-first single-task home.
- **RECOMMENDED:** Usability-test A and B; keep QR one tap away.
- **WHY:** Information architecture should follow pilot frequency.
- **TRADEOFF:** Discoverability vs simplicity.
- **AFFECTED FEATURES:** UX/navigation only.

## RD-18 — Future-engine surfaces (P2)

- **QUESTION:** When do ads/reward/gamification placeholders appear?
- **OPTIONS:** A none until engines approved; B hidden extension routes; C visible coming-soon UI.
- **RECOMMENDED:** A, with contract-level extension points only.
- **WHY:** Avoids false promises and scope creep.
- **TRADEOFF:** Later navigation change.
- **AFFECTED FEATURES:** Future ads, rewards, badges.
