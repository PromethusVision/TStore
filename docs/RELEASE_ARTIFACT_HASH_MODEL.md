# Release Artifact Hash Model

**State:** PROPOSED

## Hash contract

Use SHA-256 over exact final bytes after signing/packaging. Record lowercase hex digest, byte size, artifact type, manifest revision and computation tool/version. AAB, APK, IPA/archive export, symbols/source maps and any web bundle receive separate entries.

## Lifecycle

1. Build in a clean controlled workspace.
2. Sign/package once.
3. Compute hash and write immutable manifest.
4. Upload/promote the same bytes.
5. Re-download from internal distribution where possible and compare signer/package/version/hash or platform-equivalent identity.
6. Bind smoke, approval and observability release record to the digest.

## Rules

- Hash before signing is not the shipped artifact hash.
- A renamed/copy-identical file keeps identity; a rebuild from the same commit is a new candidate if bytes differ.
- Hash is integrity evidence, not proof of trusted build origin by itself.
- Manifest is reviewed and stored independently from mutable local build folders.
- Logs may print digest but never signing keys/passwords.

Future CI may add provenance attestation if repository plan/tooling supports it; it does not replace store signing verification.

`OWNER_DECISION_REQUIRED: MANIFEST_STORAGE_AND_ATTESTATION`
