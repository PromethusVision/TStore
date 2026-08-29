# Wave 36 — Empty Development Recreation Plan

Status: **PLAN ONLY — NO REMOTE RECREATION OR ACCESS PERFORMED**
Scope: EsnaftaVar Development empty application state
Production equivalence: **not assumed**

## 1. Why recreation is the rollback boundary

The observed Development environment is on a plan without a native restorable
point and its application tables were empty at the Wave 35 read-only profile.
This makes a reviewed empty-environment recreation possible, but it is not the
same as a database backup. It is acceptable only while the JIT precheck proves
that categories, products, shops, and shop listings are still zero and no
customer/merchant state would be discarded.

If any application data appears, this plan stops. The ordinary backup/restore
and data-preserving migration path becomes mandatory.

## 2. Source-controlled reconstruction inputs

Recreation must bind one reviewed set of artifacts:

1. repository commit and the nine ordered files in `supabase/migrations/`;
2. per-file and aggregate migration SHA-256 values;
3. exact external Wave36A canonical UUID/import package and package SHA;
4. compiled forward/rollback/postcheck artifact-set SHA;
5. redacted environment configuration inventory;
6. Storage bucket definitions from migration 0007/0009;
7. Realtime publication membership from migration 0007;
8. Auth configuration inventory captured by an authorized environment owner;
9. explicit Development project-ref/URL identity;
10. configuration values that are secrets, stored outside source and logs.

The taxonomy package reconstructs application taxonomy only. It does not own
Auth users, Storage objects, platform helper functions, Supabase internal
metadata, project secrets, SMTP/OAuth configuration, or Production state.

## 3. JIT stop conditions

Immediately before a future authorized apply/recreation, the offline precheck
must be fed a newly captured read-only snapshot and return PASS for:

- exact Development ref `tnipyxnvhgelwdpykyez`;
- categories/products/shops/shop_products each zero;
- exact migration filenames and hashes;
- exact expected application schema-contract hash;
- no unexpected object/policy/function drift;
- one observable writer/change owner and declared write freeze;
- exact package/artifact SHA;
- no active or partial prior taxonomy import.

Any mismatch stops execution. A stale snapshot is not reusable.

## 4. Future authorized recreation sequence

This sequence is specification, not an executable remote command list:

1. Record authorization, operator, repository commit, target ref, and window.
2. Reconfirm empty counts and configuration inventory read-only.
3. Export any available logical metadata/schemas even though application rows
   are empty; record hashes in a secure external location.
4. Recreate/reset only the exact Development project through the separately
   approved Supabase owner route.
5. Apply the canonical repository migration chain from zero in filename order.
6. Verify 23 public tables, RLS/policy/function/grant contracts, Storage bucket
   definitions, and Realtime publication membership.
7. Restore approved Development Auth/URL/configuration values from the secure
   inventory. Do not substitute Production secrets.
8. Rerun JIT schema/history/empty-count precheck.
9. Apply the exact compiled taxonomy forward artifact with its SHA token.
10. Run all structural, policy, alias, relationship, admin-visibility, and RPC
    postchecks before client activation.
11. Keep all nodes staged/inactive. Client rollout and public activation remain
    separate authorized phases.
12. Record final hashes and results without secrets or PII.

## 5. Taxonomy bootstrap rollback

For a still-empty Development application, the generated rollback:

- requires local/review guard semantics and exact package SHA;
- refuses if any product references package categories;
- refuses a partial/unowned package count;
- removes package-owned alias edges, aliases, relationships, allocations,
  import marker, and package categories in child-first order;
- preserves repo migration history and unrelated platform metadata;
- leaves additive nullable taxonomy schema/functions available for diagnosis.

Leaving harmless additive schema is intentional. Removing columns/tables in the
same incident would add unnecessary DDL risk. A later reviewed forward migration
may retire unused schema.

## 6. Full environment recreation validation

After reconstruction, verify independently:

- repository migration names/hashes and table count;
- categories/products/shops/listings zero before import;
- exact 1,563-node package counts after import;
- L1/L2/L3/L4 = 24/244/1,096/199 and leaves = 1,245;
- parent/cycle/duplicate/policy checks zero;
- aliases = 651, alias edges = 1,000;
- relationship rows = 1,032, successor edges = 1,000;
- all public taxonomy reads return zero while staged;
- admin tables are unavailable to anon/authenticated;
- seven versioned read-contract functions exist and fail closed;
- Storage buckets and Realtime publication match repository migrations;
- Auth/deep-link configuration matches the redacted Development inventory;
- no Production credential/configuration was used.

## 7. When this plan becomes invalid

Stop using empty recreation when any of these appears:

- customer, merchant, product, shop, listing, review, QR, chat, or Storage data;
- migration/config drift without a reviewed reconciliation;
- a requirement to preserve Development incident evidence;
- an exact package or compiler SHA mismatch;
- inability to prove environment identity or single-writer control.

Then require a data-preserving backup/restore plan and independently rehearsed
selective rollback. Empty Development success never authorizes Production.
