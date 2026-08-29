# Wave 36 taxonomy migration tooling

This directory contains an offline-only compiler and PostgreSQL-WASM rehearsal
harness. It has no Supabase client, URL, project-link, access-token, or remote
apply implementation.

## Commands

Generate a deterministic **test-only** fixture:

```text
node tool/taxonomy_migration/generate_synthetic_fixture.mjs --output <package-dir>
```

Normalize and verify an exported Wave36A package (all upstream Git-blob and
overall hashes must pass):

```text
node tool/taxonomy_migration/adapt_wave36a_package.mjs --source <archive-root> --source-head <sha> --output <package-dir>
```

The adapter preserves all category UUIDs. It derives only deterministic UUIDv5
administrative row IDs from exact alias/relationship import keys; those IDs are
not canonical category identity.

Compile a reviewed external package into staging artifacts:

```text
node tool/taxonomy_migration/compile.mjs --input <package-dir> --output <artifact-dir>
```

Validate a previously captured read-only precheck snapshot. This never applies:

```text
node tool/taxonomy_migration/jit_precheck.mjs --input <package-dir> --snapshot <snapshot.json>
```

Run the isolated PGlite rehearsal. `--local` is mandatory:

```text
node tool/taxonomy_migration/local_apply_harness.mjs --local --input <package-dir> --pglite-root <local-pglite-package>
```

If `--input` is omitted, the harness generates an ephemeral synthetic package.
That package proves tooling behavior only and is never a Development or
Production stable-ID package.

## Safety invariants

- Unknown remote flags are rejected; remote mode is not implemented.
- The compiler never allocates UUIDs. Exact UUIDs must be present in input.
- The Wave36A adapter rejects any source or aggregate checksum mismatch before
  it writes a normalized package.
- The synthetic generator is separate and marks every allocation test-only.
- Forward SQL requires a package-SHA session token, runs in one transaction,
  imports staged/inactive rows, and contains no delete.
- A second apply is accepted only for the same recorded package/version.
- Rollback is scoped to an empty-application bootstrap and removes only rows
  owned by that exact package. It preserves migration and platform metadata.
- Split history is imported as evidence; the tool never selects a successor for
  a product.
