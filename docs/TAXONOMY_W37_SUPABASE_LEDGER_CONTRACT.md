# Wave 37A — Supabase Migration Ledger Contract

Status: **VERIFIED CONTRACT — LOCAL GUARD CORRECTION COMPLETE**

Evidence source: Wave 35 authorized Development read-only inventory

Runtime access in this task: **none**

## 1. Root cause

The Wave 36 guard compared repository migration filenames with only
`supabase_migrations.schema_migrations.name`. That assumption is incompatible
with the verified Development ledger. Supabase stores the applied migration
timestamp in `version` and the short migration label in `name`.

For example, repository file
`20260812000100_0001_core_auth_catalog.sql` is represented by the verified
ledger pair:

- `version = 20260812010907`
- `name = 0001_core_auth_catalog`

The repository filename timestamp and the applied ledger version can differ.
The mapping therefore cannot be reconstructed by splitting the repository
filename and treating its leading timestamp as the live ledger version.

## 2. Canonical baseline mapping

The guard uses this explicit 9/9 baseline derived from the Wave 35 evidence.
This task did not reconnect to Development to refresh it.

| # | Repository migration | Ledger `version` | Ledger `name` |
|---:|---|---|---|
| 1 | `20260812000100_0001_core_auth_catalog.sql` | `20260812010907` | `0001_core_auth_catalog` |
| 2 | `20260812000200_0002_shops.sql` | `20260812011047` | `0002_shops` |
| 3 | `20260812000300_0003_carts_v2.sql` | `20260812011128` | `0003_carts_v2` |
| 4 | `20260812000400_0004_qr_verified_purchases.sql` | `20260812013109` | `0004_qr_verified_purchases` |
| 5 | `20260812000500_0005_verified_shop_ratings.sql` | `20260812013220` | `0005_verified_shop_ratings` |
| 6 | `20260812000600_0006_chat_notifications_account.sql` | `20260812013308` | `0006_chat_notifications_account` |
| 7 | `20260812000700_0007_storage_realtime.sql` | `20260812013403` | `0007_storage_realtime` |
| 8 | `20260814000800_0008_fix_profile_role_guard.sql` | `20260814000820` | `0008_fix_profile_role_guard` |
| 9 | `20260815000900_0009_verified_product_reviews_storage.sql` | `20260815000900` | `0009_verified_product_reviews_storage` |

Canonical ordered pair-set SHA-256:
`5e1c594d53d0df2422a19563c0affe233e99a949082ca7f4f25056192903349c`

## 3. Repository filename parser

Repository filenames must match:

`<14 ASCII digits>_<4 ASCII digits>_<lowercase ASCII words>.sql`

The parser returns the repository timestamp and short name, but the live
`version` still comes from the explicit verified mapping above. The parser:

- accepts a filename only, never a path;
- rejects `/` and `\` path separators;
- is independent of Windows/POSIX separators and locale;
- rejects malformed timestamps, ordinals, casing, extensions, and labels;
- checks every current repository migration has exactly one verified mapping.

## 4. Corrected fail-closed guard

The generated SQL now compares exact `(version, name)` pairs after deterministic
sorting. It rejects:

- duplicate pair;
- duplicate version;
- duplicate name;
- malformed ledger row;
- a known version paired with the wrong name;
- a known name paired with the wrong version;
- a missing expected pair;
- an unexpected pair.

Row order is not semantic: the exact same nine pairs in a different query order
pass. Same row count, matching names without versions, or matching versions
without names never pass.

## 5. Before and after

Before Wave 37A, an exact verified Development ledger would fail because the
guard expected full repository filenames in `name`. After Wave 37A, the exact
9/9 pair set passes, while full filenames incorrectly placed in `name` fail as
malformed ledger rows.

The active Supabase migration directory was not changed. This contract corrects
offline compiler/rehearsal tooling only and grants no remote apply authority.
