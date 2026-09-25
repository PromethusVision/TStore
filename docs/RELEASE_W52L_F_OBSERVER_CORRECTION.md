# W52L-F supplemental observer correction

Result: **PASS**. The actual corrected handoff completed OFF → ON → OFF on the
current real-backup copy in isolated PostgreSQL 17.6. Production and Development
were not accessed. No APK/AAB was rebuilt. Main was not merged.

Authoritative main: `4368911347eb2755587d02b9d50c25ec2c1653c0`. Task branch:
`astra-release/w52l-f-observer-correction`.

## Cause and correction

The previous supplemental observer required `_w52kb_assignable` to yield 14 eligible
and 6 gated assignments even after public activation. That predicate requires staged
ancestors. Publication makes the reviewed ancestors active, so its eligible count
correctly becomes zero. Treating this as a live defect caused the false rollback.

The observer now reads the authoritative activation singleton before selecting the
classifier. OFF validates staged eligibility and public denial. ON uses
`production_taxonomy_assignment_visible_v1` and the reviewed public customer
contract. Immutable row/metadata comparison excludes the state-dependent classifier.
Unexpected state, real permission drift or failed customer reads still fail closed.

| State | Authoritative classifier | Eligible / gated | Public visible | Result |
| --- | --- | --- | --- | --- |
| OFF staged | STAGED_PRIVATE_PREVIEW_ELIGIBILITY | 14 / 6 | 0 / 14 | PASS |
| ON published | PUBLIC_VISIBILITY_AND_ASSIGNABILITY | 14 / 6 | 14 / 14 | PASS |
| OFF restored | STAGED_PRIVATE_PREVIEW_ELIGIBILITY | 14 / 6 | 0 / 14 | PASS |

The real-copy differential was exactly staged **14 → 0 → 14** and public visible
**0 → 14 → 0**. The previous staged assertion fails in ON; the corrected observer
passes and the actual handoff does **not** trigger an erroneous rollback.

## Exact package preservation

Original seal: `86d9b475013ad534322678b35aef0624742b32efe24e1eb050fe9a4879b8245a`.
All **58 inputs**, plus the seal file separately, were compared by raw bytes before
and after. All also match the requested main's Git contents. No reseal occurred.
The full inventory is in the companion JSON.

Combined raw-byte inventory before/after: `47627097ad8388c89075f1fbbd0ab5d384accbef805cf22b4d0bdf0ddb653a7b`.

Independent supplemental observer source SHA-256:
`4f8711f877069b7e903a1be22e44550bb998bbdf85664e7fb9978c5ca04fc521`.
Its six-file inventory is separate from the original seal. Hashes describe the
UTF-8 LF source files committed here; reproduce that encoding when checking them.
0012, 0013, 0014 activation, 0014 rollback, 0015, mappings, policy gates and Flutter
source remain unchanged.

## Real-copy proof

The current pre-activation backup was used directly: 0012, 0013 and 0015 present;
0014 absent; public OFF. Archive SHA-256:
`ebbd10a9aa518ebacfb306bda6853647271e78ffa440a0baab0b2c1efabd3183`. All **1,110 TOC entries** were restored, none omitted,
including **79 table-data sections**. The container had no network, published ports
or writable backup mount. No older migration payload was used to reconstruct the
application baseline.

Restore-only platform metadata handling retained the previously reviewed extension
ownership and managed-role settings. The archive also collapses three explicit
default owner ACLs to NULL (two canonical tables and the private tester table).
The local restore adapter preserves those explicit owner entries before baseline
capture, with identical effective-privilege hashes and zero new client grants.
Both unchanged raw catalog and security oracles then passed with no filtering or
normalization added. This was automatic restore representation handling; there was
no manual SQL repair during activation, validation or rollback.

The actual corrected handoff ran its OFF observer, demanded a fresh local backup,
called the unchanged sealed 0014 executor with atomic exact ledger handling, and
passed its ON observer. ON results: **24/24 roots, 325/325 published nodes,
247/247 assignable leaves, 14/14 visible products, 6/6 gated products excluded**.
All four 0015 public functions passed.

Public SQL/HTTP checks passed for Home, All Categories, L2/L3/L4, breadcrumb,
alias resolution, search, product listing/details, seller comparison and shop
details. Legacy SQL and anonymous/authenticated HTTP contracts passed. Six
read-only permission probes proved UPDATE/DELETE/INSERT denied for anon and
authenticated without executing DML. The unchanged sealed grant checks also
confirmed zero canonical client write exposure.

The existing real Flutter public repository integration test passed **3/3** against
local PostgREST: anon ON flow, authenticated ON flow, and cached/fresh OFF behavior
after exact sealed rollback. Public reads required no tester lease, preview,
legacy fallback or Development fallback. APK/AAB compilation was not run.

After rollback, the corrected OFF observer passed; 0014 was absent, public OFF,
and all four 0015 functions denied reads again (HTTP 401 / SQLSTATE 42501).
The original sealed fingerprint, **68 protected table rowsets**, Auth/Storage
metadata, all **79 archive table-data sections**, and restored sequences matched.
The temporary local container was stopped at completion.

Final archive row fingerprint before/after:
`2e8e810d99f661be3e92dd87a506b28f095d8c5ab0b14325e7bae2580828ee4d`.

## Quality and handoff

- Observer/unit/recovery/restore guards: **18 PASS**.
- Unchanged activation/facade package regressions: **29 PASS**.
- Total Node tests: **47 PASS**, zero failures/skips.
- Full actual real-copy OFF → ON → OFF: **PASS**.
- Existing real Flutter integration: **3 PASS**, zero failures/skips.
- `git diff --check` and scoped secret/PII scan: **PASS**.
- Frozen APK: `04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64`,
  `1.0.0+3`, `com.esnaftavar.app`; unchanged.

Ready for observer correction integration and the **decision** on a subsequent
0014 live retry. The future owner handoff must use the new `observe` and `compare`
exports, retaining its existing credential prompt, sealed CLI, backup requirement
and recovery logic. This wave performs no live retry or public activation.
