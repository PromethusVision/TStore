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
| `docs/TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv` | `779f6dcd4535dd306158c532682ba2447d0570a80abf42a6c37c76558450152b` |
| `docs/TAXONOMY_W34_ALIAS_REDIRECT_MANIFEST.csv` | `bf230c5ee5b6c0bddae7cc185d071de70afbe4fef851a73a690c7a08031b0b90` |
| `docs/TAXONOMY_W34_FINAL_SPLIT_MERGE_REGISTRY.csv` | `9e8f6649fa877e872bc771326852b3da005ebfe99931dfc4d39416232c85fd61` |
| `docs/TAXONOMY_W35_STABLE_ID_OWNER_DECISION.md` | `548b2c0697fbf124b3438f1d20b40b7a6fd3a50fbd49f9031631bc43db3053a4` |
| `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md` | `4f7e652f8bef56eb747dcba7296a5fc5edafdabfa935e35436675d23b949012a` |

The W35 read-only baseline contains zero Development category rows, so this
candidate allocates one fresh RFC 9562 UUIDv4 for every canonical node and
preserves no live category UUID. Planning keys remain reconciliation keys only.

## Generated CSV checksums

Row counts exclude the header.

| Filename | Rows | SHA-256 |
|---|---:|---|
| `TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv` | 1,563 | `bef6c2afef319c2b8776edaedb2def75d49786a58c2838c64d32f3ee64ab8b37` |
| `TAXONOMY_W36_ALIAS_IMPORT.csv` | 651 | `4a864703a3e5c3c028433424dad245ed1497c2f3731602cc7c55aaa03bf369e2` |
| `TAXONOMY_W36_ALIAS_TARGET_EDGES.csv` | 1,000 | `a140c69be4e67feb0b2769f61119f6c595f8d6e14bf86940b9ab252dab286e23` |
| `TAXONOMY_W36_CATEGORY_IMPORT.csv` | 1,563 | `7f4476aefe52f7164b9480838821799c911ad0a9182318c6c54cb7084b7ea03a` |
| `TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv` | 1,563 | `25f37393417d4eef99223d79fb567ccdacc931b3cf474de77e40dc80e8750355` |
| `TAXONOMY_W36_SUCCESSOR_IMPORT.csv` | 1,032 | `a045560a87bc0c017005931553c0cb6daf52cb6149ccab798e213f4b3b2e9251` |

`TAXONOMY_W36_SUCCESSOR_IMPORT.csv` contains 1,000 target-bearing edges plus
32 explicit no-target relationship records, so all 651 predecessor locators
remain represented.

## Overall package digest

The overall digest is SHA-256 over the six CSV records above, sorted by exact
filename, serialized as UTF-8 lines:

```text
filename|row_count|lowercase_sha256\n
```

Overall package SHA-256:

`138fac79aaf3ac25c31b65f47d7599be86684d6ffa646c96a04099fda4eb17ed`

Changing or regenerating any UUID, row, order, field or line ending invalidates
this digest. A later rehearsal must verify all six file hashes before use; any
intentional change creates a new reviewed candidate package rather than silently
mutating this one.

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
