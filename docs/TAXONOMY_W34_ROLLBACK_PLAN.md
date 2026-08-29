# Wave 34 — Canonical Taxonomy Rollback Plan

Status: **DESIGN ONLY — NO RESTORE OR DATABASE ACTION PERFORMED**

## 1. Rollback objective

Rollback preserves commercial and verified history while returning category
reads and product assignments to the last known-good state. It does not delete
products, listings, reviews, carts, QR sessions, or verified transactions.

OM-R06=B requires a staged migration. The safest rollback is therefore forward
deactivation plus exact mapping restoration, not a blind destructive down
migration.

## 2. Required restore artifacts

Before the first Development write, capture:

- full logical backup and proven restore point;
- exact migration history and schema fingerprint;
- category table export including timestamps/image references;
- `(product_id, category_id)` snapshot for every product;
- demo-tagged product/listing dependency report;
- old category public-state snapshot;
- candidate manifest/import hashes and app commit/version;
- any writes accepted during the change window.

Backups must be stored securely outside the repository. This document contains
no credentials, project secrets, or backup contents.

## 3. Rollback levels

### R0 — additive schema installed, no canonical data imported

Impact is low. Leave additive objects in place or remove them only through a
reviewed forward migration. Old clients and rows remain unchanged. Prefer
leaving harmless nullable columns/tables over risky DDL churn.

### R1 — canonical rows imported as staged, no product reassignment

Set imported rows inactive/staged and revoke their publication. They can remain
for diagnosis. No product-map restore is needed. Validate old category reads.

### R2 — products reassigned, canonical rows not publicly activated

1. freeze category/product classification writes;
2. restore `products.category_id` from the pre-change snapshot by product UUID;
3. mark canonical rows staged/inactive;
4. restore old category active states;
5. validate products, listings, carts, reviews, QR, and verified history;
6. retain relationship/import evidence for postmortem.

### R3 — compatible client deployed and canonical tree activated

1. trigger the approved catalog/taxonomy kill or compatibility mode;
2. stop further product classification writes;
3. choose either:
   - forward hotfix while canonical data stays active, if data is correct and
     only client/RPC behavior is faulty; or
   - R2 mapping restore plus old-tree reactivation when classification is wrong;
4. ensure released clients can still read the fallback contract;
5. monitor Home, browse, search, product, cart, shop, review, and QR journeys.

Client rollback alone may be slow because app-store propagation is not
immediate. Server compatibility must be retained through the rollback window.

### R4 — post-cutover writes exist

Never restore the whole database blindly. Reconcile delta rows created after
the snapshot:

- newly created products need an explicit legacy fallback or quarantine;
- category edits/imports need a manifest-level comparison;
- verified history remains immutable and should not be rolled back;
- carts/wishlists/listings remain attached to preserved product/listing UUIDs.

Use PITR/full restore only for an approved disaster response where selective
forward recovery cannot preserve integrity.

## 4. Rollback triggers

Rollback or disable activation when any P0 condition occurs:

- orphaned or multiply mapped active products;
- wrong cross-domain classification at material scale;
- blocked/regulatory products become publicly visible;
- public RLS/RPC exposes staged/retired nodes;
- product/listing/review/QR/verified-evidence identity or count changes;
- old or new supported client cannot complete pilot-critical browse/cart/QR;
- migration counts or manifest hashes do not reconcile;
- restore evidence is unavailable.

P1 client display/search issues may justify a forward fix if data and policy
gates remain correct; the incident owner decides within the authorized window.

## 5. Rollback invariants and validation

After rollback:

- every product has the exact pre-change category ID or a documented delta
  decision;
- old category public states match the snapshot;
- canonical rows are not public unless intentionally retained;
- product, listing, review, wishlist, cart, QR, and verified transaction counts
  and durable IDs reconcile;
- no first-successor split mapping remains;
- RLS tests pass for anon/customer/merchant roles;
- Home/search/browse work with the declared fallback client contract;
- the incident, commands, actors, before/after counts, and artifact hashes are
  recorded without secrets/PII.

## 6. Production boundary

Development rollback proof is necessary but not sufficient for Production.
Production requires its own restore point, observed data profile, change owner,
rollback owner, signed client compatibility, monitoring, and explicit apply
authority. This wave authorizes none of those actions.
