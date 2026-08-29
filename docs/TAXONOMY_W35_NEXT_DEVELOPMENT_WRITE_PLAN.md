# Wave 35A-R — Exact Next Development Write Plan

**State:** `FUTURE GATED PLAN — NO WRITE AUTHORIZED OR EXECUTED`

## Live planning inputs

- exact Development ref: `tnipyxnvhgelwdpykyez`;
- PostgreSQL 17.6; canonical migration names `0001`–`0009`;
- 23 public tables, all RLS-enabled;
- category/product/shop/listing/application rows: 0;
- existing category UUIDs to preserve: 0;
- canonical category UUIDs estimated new: 1,563;
- current split/manual/policy product queue: 0;
- native backup/PITR/restore point: unavailable;
- Wave 35B clean-room/live parity: PASS;
- Wave 35C client contract/live parity: PASS, runtime disconnected.

Every remote mutation below requires a separately approved task. This document
does not authorize any gate.

## GATE 1 — Stable UUID allocation

Prerequisites: freeze the 18 anchor-only assignability/activation states and the
exact manifest hash. Allocate one opaque UUIDv4 per 1,563 canonical category
planning keys through a trusted backend-controlled process. Planning key, name,
slug and path are never IDs. Re-run the live zero-category gate immediately
before finalizing the allocation payload; stop if any category appeared.

## GATE 2 — Active migration creation

Convert the reviewed docs-only draft into a new active migration without
rewriting `0001`–`0009`. Add only reviewed schema, constraints, indexes, alias/
lineage model and RLS/grants. Replace all placeholders and retain PostgreSQL 17
compatibility. The Wave 35B draft guard must not simply be removed and applied.

## GATE 3 — Additive schema apply

After local replay and separate Development authorization, apply schema only in
a single-writer window. Do not activate/import canonical rows in this gate.
Verify old client reads, 23 existing table contracts, platform
`rls_auto_enable()` ownership, locks, grants and rollback decision points.

## GATE 4 — Staged canonical import

Import exactly 1,563 canonical rows parent-first as staged/inactive. Re-run the
import to prove idempotency. Validate 24/244/1,096/199 levels, 1,245 leaves,
unique UUID/source keys, parent graph, no cycle/orphan/L5 and complete policy/
professional metadata. Public visibility must remain zero for staged nodes.

## GATE 5 — Legacy/alias import

Import all 651 legacy locators, 1,000 successor edges and explicit alias states:
`RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, `UNRESOLVED`. A split alias has no direct
first-child redirect. Import the 24 manual/policy dispositions fail-closed even
though none currently exists live.

## GATE 6 — Product reassignment/quarantine

JIT re-count products. Current expected workload is zero. If still zero, record
an empty mapping/quarantine result and perform no product update. If any product
exists, stop the zero-baseline path and require a new read-only classification
artifact before writes. Preserve all product/listing/review/wishlist/cart/QR/
verified evidence identities.

## GATE 7 — Client cutover

Freeze a versioned backend capability and separate canonical DTO. Provide RLS-
safe roots, children, breadcrumb, alias state and bounded descendant-product
contracts. Integrate Wave 35C seams behind explicit capability/version checks;
old-schema/new-app and staged-schema/old-app suites must pass. No timeout/error-
based mode guessing.

## GATE 8 — Policy-cleared activation

Activate only reviewed containers and assignable leaves parent-first. Never
activate regulated/legal/professional rows from taxonomy placement alone. Product
and listing public projection must require active, assignable, policy-cleared
classification. The 18 anchor-only states must already be frozen.

## GATE 9 — Postcheck

Verify exact counts, zero graph defects, alias/lineage totals, RLS/grants,
capability/version response and customer root/child/descendant/search behavior.
Run Cart V2, seller comparison, wishlist, reviews, QR/verified-purchase, media,
empty/error/rollback and old/new client regressions. Confirm no unexpected data,
Auth, Storage, Realtime or Production mutation.

## GATE 10 — Rollback decision window

Before Gate 3, approve one strategy:

1. supported backup plus disposable restore proof; or
2. explicit owner acceptance of empty-Development recreation from canonical
   `0001`–`0009` plus the exact new artifact.

During the observation window, rollback deactivates canonical nodes, invalidates
capability/version caches and restores the legacy client path without deleting
lineage/history. Wave 35B forward/rollback/idempotency/failure-injection must be
rerun against the exact active artifact. Do not improvise destructive cleanup.

## Global stop conditions

- wrong project ref or any Production route;
- migration/ledger drift;
- loss of the zero-row baseline without a new mapping review;
- missing approved rollback strategy;
- UUID allocation mismatch or planning-key-as-ID usage;
- arbitrary split successor;
- fail-open policy/RLS behavior;
- incomplete client compatibility or unrelated writes.

`DEVELOPMENT_WRITE_EXECUTED: NO`

`MIGRATION_CREATED: NO`

`UUID_ALLOCATED: NO`

`WRITE_AUTHORIZATION_REQUIRED: YES`
