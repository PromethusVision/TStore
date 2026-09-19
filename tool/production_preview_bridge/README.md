# Production private preview bridge (W52K-B)

This directory prepares and tests additive 0013. It has no live deployment
command. Production and Development access are prohibited for this wave.

`build_artifacts.mjs` generates the new SQL facade and its exact rollback from
the frozen 0012 DTO functions. It verifies the original 0012 SHA-256 first and
never edits that file. Runtime authorization and product scope are new explicit
contracts, rather than renamed calls alone.

`rehearse.mjs` accepts these local process environment inputs:

| Input | Required value |
| --- | --- |
| `W52KB_DOCKER` | Local Docker executable |
| `W52KB_CONTAINER` | Fresh name matching `w52kb-[a-z0-9]+` |
| `W52KB_DUMP` | Outside-repository W52J-A retry backup, exact frozen hash |
| `W52KB_PROOF_DIR` | Private absolute directory outside this repository |

Run from the repository root with `node tool/production_preview_bridge/rehearse.mjs`.
Only the local `desktop-linux` named pipe is accepted. The PG17.6 image digest,
network `none`, absence of ports, task label, and read-only backup mount are
verified. The already available `/tmp/postgrest` executable is copied from the
stopped `w52hr-pg176-proof` container; that container is never started or changed.

The latest available archive predates 0012. The runner restores every archive
object and all 69 table-data sections, then applies unchanged 0012 through the
sealed main-integrated W52J-B/C engine **inside the isolated copy only**. It
snapshots that state, applies 0013 and its ledger row atomically, and verifies
the HTTP/SQL contracts. Two disposable Auth identities and one tester membership
are local fixtures; category/product data is real. Local JWT signing material
is random per run and never written into Git or printed.

The runner then removes only 0013 additions and its exact ledger row, removes
local test identities, verifies the original 0012 snapshot and all 69 archive
tables, and stops the container. It never rolls back 0012. The archive ledger
comparison accounts explicitly for the unchanged 0012 ledger row; the complete
0012 ledger is separately compared before/after the preview rollback.

Private outputs:

- `rehearsal.json`: safe metadata, counts, hashes, grants and results.
- `real-copy-contract.json`: actual local HTTP payloads for the Flutter proof;
  **do not commit or publish this file**.

Set `W52KB_CONTRACT_PATH` to that private capture and run:

```text
flutter test --no-pub tool/production_preview_bridge/real_copy_contract_test.dart
```

This explicitly invoked test fails if the capture is missing. It adds no skipped
test to the normal Flutter suite. It performs no network calls.

Review `docs/RELEASE_W52K_B_PRODUCTION_PREVIEW_BRIDGE.md` before any future live
decision. Do not run a generic migration push: the Development 0010/0011 chain
and Production 0012/0013 chain are mutually exclusive. A separately authorized
live executor must verify target/baseline/backup, apply only reviewed 0013 with
its ledger transaction, and provision an approved Auth UID with an expiry.
No UID is pre-authorized by this artifact. `rollback.sql` intentionally leaves
ledger ownership to that executor; the rehearsal demonstrates atomic ledger
reconciliation. No Production write or RC build is authorized by this README.
