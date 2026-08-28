# Backend Production Acceptance Plan

**State:** PLAN ONLY — EXPLICIT HUMAN AUTHORIZATION REQUIRED

## Before the window

- Product Owner resolves applicable P0/policy decisions.
- Release owner identifies exact Production project independently; Development is
  explicitly excluded.
- Current ledger/schema/data/Auth/Storage are inventoried read-only.
- Backup/restore evidence, freeze/single-writer window and abort owner are recorded.
- Exact artifact already passed clean-room and authorized Development acceptance.
- N/N-1 Customer and Merchant compatibility, monitoring and forward/rollback
  procedures are rehearsed.

## Window

1. Repeat identity, drift, writer and backup gates immediately before write.
2. Apply only the immutable authorized artifact; do not paste fragments or improvise.
3. Stop on any exception; verify transaction state read-only before remediation.
4. Verify exact migration ledger, schema, RLS/grants/RPCs, expected data delta and
   absence of unrelated changes.
5. Run minimal read smoke first, then explicitly authorized writes/fixtures only.
6. Observe error, latency, authorization and business-invariant indicators.
7. Clean only exact authorized fixtures and record residual counts.

## No-go/abort

Wrong project, new drift, another writer, missing backup, unexplained count,
cross-tenant access, service-role exposure, duplicate QR consumption, broken old
client or uncertain rollback means no-go/abort. A failed transactional apply is
not permission for manual UPDATE/DELETE or cleanup.

This plan does not authorize Production access, migration apply, fixture creation
or cleanup.
