# Slice C — Merchant review center and verified evaluations

Status: local implementation and automated acceptance PASS. Baseline: `cc2d4f7e`.
Branch: `agent/merchant-reviews-slice-c`.

## Audit and architecture

- Reuse `reviews` and its user/product uniqueness and immutable original verified
  item anchor. 0009 currently provides unbounded legacy update and hard delete;
  C adds guarded adapters, lifecycle state and immutable revisions.
- Reuse verified transactions/items and 0018 purchase invalidations. QR creation
  and claims are not evidence. Genuine returns do not revoke experience rights.
- Preserve `shop_ratings` as scalar legacy history. New three-criterion service
  records select the latest valid customer/shop evaluation without fabricated
  conversion of old scores.
- Existing account deletion cascades the public review root. New audit tables
  must survive that cascade without restricting self-delete or keeping readable
  personal text indefinitely. Local encrypted-history/erasable-key proposal is
  documented in canonical §6.1; legal retention and remote conversion are open.
- Reuse Merchant explicit service composition and five-tab navigation. Add the
  review center from the dashboard, with score/sample summary, filters, details,
  one reply and reporting. Extend existing Customer forms only where required
  for criteria, purchase selection/reopening, deadlines and withdrawal.
- Shared notifications and all reward/badge/advertising work remain unchanged.

## Delivery sequence

1. Additive 0019 schema, guarded RPCs, ownership/visibility/privacy compatibility.
2. Native PostgreSQL acceptance including independent concurrent transactions.
3. Shared typed client contracts, Merchant center and Customer form extensions.
4. Unit/widget and real Auth/PostgREST acceptance; analyzer and final diff review.
5. Task branch commit/push and an Integration Agent handoff. Main merge belongs
   to that agent; Production apply and physical-device acceptance are separate.

## Evidence

- Final native PostgreSQL proof: 17 groups passed, including real independent
  connection contention, genuine returns, fraud fallback, private unsupported
  legacy content and account deletion. Managed Auth was not inferred from this.
- Final real local Supabase proof: 28 groups passed, including Auth-issued
  sessions, PostgREST review/reply/moderation/reopening/withdrawal, Storage
  regression, private bounded service-history reads and actual Auth deletion.
  Both dated evidence files record the final migration hash. The 17 database
  groups are repeated in managed acceptance, not 45 distinct behaviors.
- Final complete Flutter suite: 2,385 PASS, 6 existing opt-in live tests skipped.
  The first broad run caught five canonical SQL inventory/style checks; 0019
  now uses explicit prerequisite checks, named blocks, RLS/revokes and the
  exhaustive 54-table inventory. The complete rerun passed without exclusions.
- Six new golden images cover the center, detail and Customer form at 320/390
  widths (320 with 1.3 text scale); existing Customer goldens remain unchanged.
- Harness isolation tests: 5 PASS. Static analyzer: no issues. A restricted
  local-TCP test attempt was rerun with the standard execution permission;
  no endpoint, container or loopback guard was weakened.
- Final flow audit found QR-completion and Customer rating-history adapters;
  these are included as necessary extensions of the existing accepted surfaces.

## Final architecture review

- Read-only screens do not consume purchase rights or reset the edit clock.
  An uncertain write retains one request ID and payload; a new account clears
  modal state and ignores the previous account's late response.
- Legacy proven reviews keep original timestamps and immutable 0009 anchors.
  Unsupported legacy content has no invented purchase/shop and remains private
  once adopted. A later real purchase can upgrade the same root using C provenance.
- Customer history batches at most 100 owned purchase IDs, preserves legacy
  scalar scores separately and displays actual three-criterion records. QR
  completion opens the durable purchase history, never creates a review right.
- Remote rollout policy remains open, especially legacy import, audit retention,
  backup/key erasure and moderation operations. This work did not apply a remote
  migration, activate providers, merge main or declare physical QR acceptance.
- Delivery and integration instructions: [MERCHANT_SLICE_C_DELIVERY.md](MERCHANT_SLICE_C_DELIVERY.md).
