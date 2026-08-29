# Wave 36A-R — Package Digest Reconciliation

**State:** `RECONCILED — PAYLOADS PRESERVED — NOT APPLIED`

## Scope and evidence

This reconciliation compares the Wave 36A package at
`326f0976c8a7392eda4549d743872fa7c11630f5` with the read-only Wave 36B
compiler evidence at
`46c8660c16b252709df05ac327409c284139a970`. The source branch was inspected,
not merged. No remote environment was accessed.

The six working-tree payloads are byte-for-byte equal to their committed Git
blobs. All committed payloads are LF-only and end in LF; this observation is
evidence, not a normalization instruction.

| Canonical order | Payload | Rows | Bytes | Git blob | Raw-byte SHA-256 | Result |
|---:|---|---:|---:|---|---|---|
| 1 | `TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv` | 1,563 | 902,393 | `834262ce8fa5c9fd8e068093f1555911fa1d2a5b` | `52c35da75129c4c21e4492f658e28452123baeb2532e373c347458762937549d` | PASS |
| 2 | `TAXONOMY_W36_ALIAS_IMPORT.csv` | 651 | 319,248 | `078d3ea14b44af634ae97794d955e473cee9ae8f` | `eb03acf1e6d71912dc1e277cd5e615432df64e670da9f11b900749ef864306cb` | PASS |
| 3 | `TAXONOMY_W36_ALIAS_TARGET_EDGES.csv` | 1,000 | 280,473 | `f2a629b5f42bd57435f6d26fa4812cd37eac43b4` | `9bdeb8748198070379b647f029aa609dfed2cec5c48ba9e6df4d1fdceacdd5e0` | PASS |
| 4 | `TAXONOMY_W36_CATEGORY_IMPORT.csv` | 1,563 | 355,124 | `a361c5d1c3945d0219c3830807fa753628d4f319` | `4c3fa47f1174312606bea59dc5c1629730bd8ba826ce85d61fd0508d6738db78` | PASS |
| 5 | `TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv` | 1,563 | 619,495 | `39c3a095d95960bd94b8bd387315b9762480179b` | `83220cd7b1fa78e8672f6a137cdc20158692bf9406ce62c9133e589db2f27de2` | PASS |
| 6 | `TAXONOMY_W36_SUCCESSOR_IMPORT.csv` | 1,032 | 580,652 | `a01c89b66b55c80fc51102717886b374bcdd06ea` | `1858ebaf9488693e791f3c36c2c7ee5032a1fef20750f576ac2745244b5fb0b3` | PASS |

## Root cause

The former manifest value was:

`9687878401513881335a5a1479cdf53e2b4b3108debb3d28297444f3e2808091`

Wave 36B parsed the same six manifest records, independently verified all six
raw Git-blob hashes and row counts, then correctly failed closed because the
documented aggregate preimage hashes to:

`095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`

The mismatch is confined to aggregate metadata. Reconstructing the documented
record order with package-local filenames, decimal row counts, lowercase hex
hashes, UTF-8, one LF per record and a final LF produces a 639-byte preimage and
the corrected value. Filename order, path inclusion/exclusion, LF versus CRLF,
final-newline presence, uppercase versus lowercase hex, raw digest bytes versus
hex strings, and manifest self-inclusion were reviewed as possible ambiguity
classes. None changes the fact that `968787...` is not the digest of the
documented canonical preimage.

No executable Wave 36A aggregate implementation or 639-byte preimage was
committed with `968787...`; therefore its exact transient ad-hoc input cannot be
recovered as a legitimate second contract. The precise repository-level root
cause is an unverified aggregate calculation/transcription value recorded in
the manifest. It is not file corruption, UUID drift, newline conversion or a
Wave 36B validator defect.

## Canonical contract

The authoritative contract is:

- the manifest itself is excluded;
- the six package-local filenames and their order are explicit;
- no host/checkout directory is included; future nested relative paths use
  `/`;
- each payload SHA-256 covers exact raw committed bytes;
- each aggregate line is exactly
  `filename|row_count|lowercase_sha256` followed by one LF;
- row counts exclude the header and use ungrouped base-10 ASCII;
- the aggregate preimage is UTF-8 without BOM and exactly 639 bytes;
- the SHA-256 result is lowercase hexadecimal.

This matches the stricter Wave 36B validator contract. Sorting is not needed
because the manifest order is normative; Wave 36B's English filename sort
produces the same six-file order.

## Preservation and readiness

- payload CSV files modified: **NO**;
- category UUIDv4 allocations regenerated: **NO**;
- canonical rows, aliases, edges, successors or qualification rows regenerated:
  **NO**;
- individual raw-byte hashes: **6/6 PASS**;
- cross-implementation digest: **Node crypto and Python hashlib independently
  returned the same 639-byte-preimage digest, `095849...`**;
- Wave 36B exact checksum adapter at
  `46c8660c16b252709df05ac327409c284139a970`: **PASS**, with the corrected
  upstream digest and all expected `1,563 / 24 / 244 / 1,096 / 199 / 1,245`
  category contracts; its temporary normalized output was not retained;
- Development/Production/Supabase access: **NO**.

`INDIVIDUAL_PACKAGE_HASHES: PASS`

`AGGREGATE_DIGEST_ROOT_CAUSE: IDENTIFIED`

`PAYLOAD_CONTENT_PRESERVED: YES`

`UUID_ALLOCATION_PRESERVED: YES`

`CANONICAL_PACKAGE_DIGEST: PASS`
