# Wave 37A — Artifact Hash Lineage Reconciliation

Status: **RECONCILED — BENIGN_EXPECTED SOURCE OF VARIANCE FIXED**

Frozen category package: **unchanged**

Remote access: **none**

## 1. Immutable upstream package

Authoritative source:
`origin/agent1/w36-exact-taxonomy-bootstrap-package@d9c45a1c2acd94fe0bfa52b16772718142c0664a`

Aggregate SHA-256:
`095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`

The six Git blobs were extracted with `git cat-file blob`, so checkout line
ending conversion could not modify them.

| Payload | Rows | Bytes | SHA-256 |
|---|---:|---:|---|
| `TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv` | 1,563 | 902,393 | `52c35da75129c4c21e4492f658e28452123baeb2532e373c347458762937549d` |
| `TAXONOMY_W36_ALIAS_IMPORT.csv` | 651 | 319,248 | `eb03acf1e6d71912dc1e277cd5e615432df64e670da9f11b900749ef864306cb` |
| `TAXONOMY_W36_ALIAS_TARGET_EDGES.csv` | 1,000 | 280,473 | `9bdeb8748198070379b647f029aa609dfed2cec5c48ba9e6df4d1fdceacdd5e0` |
| `TAXONOMY_W36_CATEGORY_IMPORT.csv` | 1,563 | 355,124 | `4c3fa47f1174312606bea59dc5c1629730bd8ba826ce85d61fd0508d6738db78` |
| `TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv` | 1,563 | 619,495 | `83220cd7b1fa78e8672f6a137cdc20158692bf9406ce62c9133e589db2f27de2` |
| `TAXONOMY_W36_SUCCESSOR_IMPORT.csv` | 1,032 | 580,652 | `1858ebaf9488693e791f3c36c2c7ee5032a1fef20750f576ac2745244b5fb0b3` |

Payload files, ordering, paths, aliases, successor relationships, lifecycle,
policy state, and all 1,563 category UUIDs are unchanged. No UUID was generated.

## 2. Reported discrepancy

| Lineage | Normalized package SHA-256 | Artifact-set SHA-256 |
|---|---|---|
| Wave 36B-R | `9934ed6f44636aed83399e25e6c8e627d0fca8295c5fe622052c1ac15b9a56ff` | `fe3b34cb0a9138be0d4ba81f96baac0271816273d310fd16b6a803baa0c47000` |
| Previous Wave 37 attempt | `32e1904e5bd41b9bf5aa86ecb365da41bfec36a55641c2d100d420d166fcc32b` | `75c122e34f38f38bc6a38534c6ea73e59acde630a450d44a1cb0da295a9289b7` |

The previous Wave 37 wrapper-bound active candidate SHA was
`e6263c8364956f0965f01090ed9c4ad0f8f00a92e0645ce0f8b9928a7973605a`.
It is superseded and was never applied remotely.

## 3. Proven cause

The frozen six-file taxonomy package and compiler source were not different.
The old runtime-contract builder hashed raw checked-out bytes of the nine
repository SQL migrations. Git configuration had `core.autocrlf=true`, without
a repository `.gitattributes` rule fixing SQL line endings.

Only the checked-out bytes of
`20260812000100_0001_core_auth_catalog.sql` differed between the two compared
worktrees:

| Checkout | Bytes / endings | Raw SHA-256 |
|---|---|---|
| Wave 36-style worktree | 26,351 bytes; 728 CRLF | `243274d0122f663396ec1a4b9ce52f79a7356fd85ce8f8d1e51316b62f62fb67` |
| Previous Wave 37 worktree | 26,349 bytes; 726 CRLF + 2 LF | `01f775dd5660f63be78842ecd32e3978f6503bb15ccc585cf9a5f0a932d56291` |
| Canonical committed LF content | UTF-8/LF | `783991b4942f3be5cdfa41b3a62285f421383b051812d46d0acfc09f9cecef33` |

This changed the old migration-history SHA from
`515393550dc68dac111287e4504b2bcf21f1d441d4901e20677000561066875d`
to
`a39a26a1b0dd418e86294be671f532bc2d65cf14016a3c0686021da37568d231`.
That runtime hash is embedded in the normalized manifest, so the difference
propagated into normalized package, generated SQL, and artifact-set hashes.

The migration identifier and wrapper metadata explain why active candidate
hashes differ from compiler `forward.sql`, but they do **not** explain the two
reported normalized-package/artifact-set values: those already differed before
the wrapper was added. Output filenames, CSV ordering, UUIDs, and normalization
of the six frozen CSVs were not causes.

## 4. Classification and correction

Classification: **BENIGN_EXPECTED** with respect to taxonomy content and
database semantics. The discrepancy was checkout metadata, not category or SQL
semantic drift. It was nevertheless an artifact-lineage defect because the old
hash identity was not portable across valid worktrees.

Wave 37A fixes the defect by defining
`migration_hash_contract = UTF8_LF_CANONICAL_V1`: repository migration SQL is
required to be valid UTF-8 and hashed after CRLF-to-LF canonicalization; lone
carriage returns fail closed. This normalization applies only to repository
migration contract hashing. It does not rewrite or normalize any frozen
taxonomy CSV.

The corrected migration-history SHA is now reproducible across both compared
worktrees:
`28e8c361ef3f6f0142a9df4a20c7016bbbf4d511e9f0c9e87b57fa7068a897ff`.

## 5. New deterministic freeze

| Artifact identity | SHA-256 |
|---|---|
| Frozen upstream category package | `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406` |
| Corrected normalized compiler package | `f73d6c0f432dd788a4f47a807280017fb068d3cdc21455e8d277a0767511f0a2` |
| Corrected artifact set | `840ab06907f40ae938f22302b7aeebc0da46c04149d9d6f219f7559197f02341` |
| Compiler `forward.sql` | `1c8a3b7ad210ac5447ad8caff96b20de14467658bc8af09bd8c2856ff2d02d73` |
| Compiler `rollback.sql` | `e8cddea5de5a54bacaf11063b1053cce2898a85567fa186420344ab06f1a6bdf` |
| Compiler `postcheck.sql` | `a12f97bd9e5cf09a4bcf0e1d82646a4393fbc38eb4309dcbaba9bd76c9ce96d7` |
| Identifier-bound staged candidate | `40fade490cde5f31b5c649ada301852b2abb40c0979a4f2e45bcd735b4f876b8` |

The frozen upstream SHA must remain stable forever for this package. The
normalized SHA remains stable while the exact frozen payload, canonical runtime
contract, and ledger mapping remain unchanged. The artifact-set SHA remains
stable for that normalized package and compiler contract. The staged candidate
SHA additionally depends on the assigned migration identifier and local
operational prelude; it must be re-reviewed if either changes.

All earlier normalized/compiler/active hashes are superseded by this Wave 37A
freeze. No remote authority is implied.
