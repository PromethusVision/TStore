# Wave 36A — Bootstrap Package Immutability Manifest

**State:** `EXACT LOCAL CANDIDATE — NOT APPLIED`

**Package taxonomy version:** `canonical-v1.0.0`

**Git base:** `origin/main@b3cc14ebed42ab66d689fe6688c2e75e23c43e68`

This manifest freezes the local candidate inputs that may be used by a later
exact-artifact migration rehearsal. It is not a migration, remote allocation,
Development write, Production ID allocation or activation approval.

## Source lineage

| Source | SHA-256 |
|---|---|
| `docs/TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv` | `0bb853f76a0b27d275b89cacbabcfe0172de2d1f96659ec6f15dc6aa743e0b45` |
| `docs/TAXONOMY_W34_ALIAS_REDIRECT_MANIFEST.csv` | `e4bdf377392d72cc6ad46fdf8aa5cefdbb97905d97d34977c88a6e1451a466bb` |
| `docs/TAXONOMY_W34_FINAL_SPLIT_MERGE_REGISTRY.csv` | `1eab11c53cb019d5778a6f707ab2c64a127909e9a852d08328d936bd580d0ec1` |
| `docs/TAXONOMY_W35_STABLE_ID_OWNER_DECISION.md` | `548b2c0697fbf124b3438f1d20b40b7a6fd3a50fbd49f9031631bc43db3053a4` |
| `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md` | `e14aa4a8eb9937ce90c4f778f546ddce6bb3e1416b06905ec1dd5a40040ba6cf` |

The W35 read-only baseline contains zero Development category rows, so this
candidate allocates one fresh RFC 9562 UUIDv4 for every canonical node and
preserves no live category UUID. Planning keys remain reconciliation keys only.

## Generated CSV checksums

Row counts exclude the header.

| Filename | Rows | SHA-256 |
|---|---:|---|
| `TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv` | 1,563 | `52c35da75129c4c21e4492f658e28452123baeb2532e373c347458762937549d` |
| `TAXONOMY_W36_ALIAS_IMPORT.csv` | 651 | `eb03acf1e6d71912dc1e277cd5e615432df64e670da9f11b900749ef864306cb` |
| `TAXONOMY_W36_ALIAS_TARGET_EDGES.csv` | 1,000 | `9bdeb8748198070379b647f029aa609dfed2cec5c48ba9e6df4d1fdceacdd5e0` |
| `TAXONOMY_W36_CATEGORY_IMPORT.csv` | 1,563 | `4c3fa47f1174312606bea59dc5c1629730bd8ba826ce85d61fd0508d6738db78` |
| `TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv` | 1,563 | `83220cd7b1fa78e8672f6a137cdc20158692bf9406ce62c9133e589db2f27de2` |
| `TAXONOMY_W36_SUCCESSOR_IMPORT.csv` | 1,032 | `1858ebaf9488693e791f3c36c2c7ee5032a1fef20750f576ac2745244b5fb0b3` |

`TAXONOMY_W36_SUCCESSOR_IMPORT.csv` contains 1,000 target-bearing edges plus
32 explicit no-target relationship records, so all 651 predecessor locators
remain represented.

## Overall package digest

The hashes above are SHA-256 over the committed UTF-8/LF Git blob bytes. The
overall digest is SHA-256 over the six CSV records above, sorted by exact
filename, serialized as UTF-8/LF lines:

```text
filename|row_count|lowercase_sha256\n
```

Overall package SHA-256:

`9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091`

Changing or regenerating any UUID, row, order or field invalidates this digest.
A later rehearsal must verify the committed LF-normalized bytes (or normalize a
platform CRLF checkout to LF before hashing) for all six files. Any intentional
change creates a new reviewed candidate package rather than silently mutating
this one.

## Package semantics

- category payload: 1,563 staged rows, `is_active=FALSE`,
  `is_assignable=FALSE`;
- activation qualification: 247 structurally assignable leaf candidates, zero
  public/pilot-active nodes in this package;
- legacy aliases: 410 `RESOLVED`, 209 `AMBIGUOUS`, 8 `TOMBSTONE`, 24
  `UNRESOLVED`;
- alias target edges: 1,000;
- predecessor/successor: 651 locators, 1,000 target edges, 210 split locators,
  591 split target edges and 32 no-target records;
- search synonym rows: 0; legacy redirect and search synonym semantics remain
  separate;
- arbitrary first-child split mapping: 0;
- remote execution: 0.

`BOOTSTRAP_PACKAGE_CHECKSUMS: PASS`
