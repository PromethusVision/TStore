# W52L-F supplemental observer

This directory is additive. It is **not** part of the existing 58-input W52L-E
activation seal. No activation SQL, rollback SQL, migration, mapping, policy gate
or Flutter source is changed.

`observe(db, options, mode, request)` reads the authoritative singleton flag in a
read-only transaction before selecting its classifier. `preflight` and `baseline`
require OFF; `postflight` requires ON. An unexpected state fails closed.

| State | Eligibility classifier | Eligible / gated | Public visible |
| --- | --- | --- | --- |
| OFF before activation | `_w52kb_assignable` (staged) | 14 / 6 | 0 |
| ON after activation | `production_taxonomy_assignment_visible_v1` | 14 / 6 | 14 |
| OFF after rollback | `_w52kb_assignable` (staged) | 14 / 6 | 0 |

ON additionally requires 24 roots, 325 published nodes, 247 assignable leaves and
the exact 0014 ledger. The unchanged sealed state validator checks exact policy,
schema, grants, data, migrations and SQL customer contracts. OFF requires 0014 to
be absent and the four 0015 facades to deny public calls with SQLSTATE 42501.

The previous supplemental observer incorrectly required staged eligibility 14/6
in every state. Publication changes eligible ancestors from `staged` to `active`;
staged eligibility becoming zero is therefore expected. It is measured separately
in the real-copy regression, never used as the ON observer's authority.

Immutable row/metadata coverage is separate from state-dependent classification.
`compare` verifies all 68 protected application/Auth/Storage/private table rowsets
and legacy HTTP results across the transition. After rollback it also requires
the original sealed fingerprint, OFF classification and facade denials.

## Handoff

`handoff.mjs` retains the previous live scheduling and recovery behavior. Its IO
callbacks must call the unchanged sealed W52L-E executor/CLI for activation,
postflight and rollback. Wire `observe` and `compare` from this directory into
those callbacks; do not reuse the old external `coverage` or comparison functions.
Keep the existing owner credential prompt, target/seal/artifact gates, fresh
backup receipt and unknown-commit recovery. No new write method is supplied here.

The required HTTP callback is `request(path, params, single = false)` returning
`{status, data}`. It must issue GET-only requests; `single` selects the PostgREST
object Accept header. There is no default network or credential discovery. The
real-copy rehearsal supplies only container-loopback PostgREST requests.

Before any separately authorized live retry, integrate this additive handoff,
verify its independent source identity and the original activation seal, and
retain the existing Production transport guards. This task performs no live retry.

## Local evidence

`rehearse.mjs` restores the hash-pinned current OFF backup into network-disabled
PostgreSQL 17.6. It invokes the actual handoff with the corrected observer and the
unchanged sealed executor. No observer coverage is mocked. The existing Flutter
public repository integration test exercises the isolated ON state and invokes
the unchanged rollback through its local control callback; no APK/AAB is built.

The restore uses the previously reviewed platform ownership/ACL reconstruction
because a database archive omits some managed-platform metadata. It does not
reconstruct 0012/0013/0015: all three are already in the current archive. There is
no manual SQL repair or new activation mechanism. Final hashes cover all 79
archive table-data sections and all restored sequences, in addition to the
sealed fingerprint and protected metadata.

The current archive also collapses explicit default owner-only ACLs to NULL on
`canonical_categories`, `canonical_category_qualification` and the private
`testers` table. The local restore adapter recreates these three explicit owner
entries before baseline capture.
It accepts only the exact owner/RLS/default ACL state, proves effective privileges
identical before/after and adds zero client grants. This is restore serialization
handling; no SQL is applied to repair a failed activation or rollback. The original
sealed raw catalog comparison is then required to pass without normalization.

Runtime source identity is computed by `observerIdentity()`; `sealedBytes()`
records raw byte hashes for all 58 old inputs plus the unchanged seal file. The
release evidence records both inventories. No secret, identity or raw row data
is included in the evidence.
