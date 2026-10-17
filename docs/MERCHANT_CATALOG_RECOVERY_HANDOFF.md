# Merchant günlük kayıt ve fotoğraf toparlanması

Baseline: `origin/main@116557fd` (I1 integration). Task branch:
`agent/merchant-catalog-recovery`. Authority: Product Owner's next comprehensive
work-package request. Canonical §4.3 and the A follow-through inventory define
the bounded scope. Customer V1 layouts and all FROZEN economics are unchanged.

## Problem and behavior

The catalog media adapter previously retired an image after any upload/publish
exception. A publish could have committed before its acknowledgement was lost,
so this compensation could hide a valid customer-facing photograph. It also
checked only user ID, allowing a multi-step continuation to run under a replacement
Auth session of the same user. The basic Merchant adapter and operations adapter
had the same session-generation gap.

All three adapters now capture the existing stable Auth session key at operation
start and check it before/after each asynchronous transport boundary, including
errors. A stale missing-RPC response cannot trigger legacy fallback. The guard
does not claim to cancel a request already dispatched or replace server role,
ownership, RLS or session validation.

Upload failures leave the existing intent/object in place. The UI refreshes
authoritative metadata. Published photos stay published; pending intents can be
explicitly completed or retired. Failed refreshes remove stale mutation controls.
No automatic second upload or compensating retirement is issued. Existing orphan
retention/deployment policy is unchanged.

Profile/onboarding and listing editors preserve the in-memory draft after a
failed save. Before another write, a fresh exact-owner read is required. The
merchant can use the current values or explicitly review their preserved draft
against that version. The next write retains the current optimistic timestamp;
it can still conflict again. A matching read proves current state, not authorship
or an idempotent save receipt. New listing/onboarding uniqueness stays intact.
An existing listing that disappears is not recreated by recovery.

Back navigation asks before discarding edits. Session authority loss continues
to dispose the private workspace, including drafts and dialogs. Nothing new is
persisted on disk. Submission retries reuse the exact existing request ID and
payload; a server-resolved catalog match remains available after returning from
the listing editor. Duplicate editor opens are coalesced.

Catalog, summary, category, submission, photo and recovery reads have a
15-second deadline with retry. Late responses cannot repopulate a superseded
attempt. Write operations remain pending until their transport resolves; no
write timeout is interpreted as failure/cancellation or permission to duplicate.

## Boundaries and compatibility

- No migration, table, policy, RPC signature, dependency, Customer entrypoint,
  shared theme, notification system or economic rule is changed.
- `MerchantRepository` retains its interface. The optional
  `MerchantRecoveryRepository` adds an exact owned listing read, implemented by
  the real and preview adapters. Alternate legacy adapters retain their old save
  behavior until they implement that read; the actual Merchant host uses it.
- Shared Auth session-key parsing is reused unchanged. New adapter test seams
  inject synthetic session identity; real constructors require Auth provenance.
- Existing pre-Slice-A catalog fallback remains only for an absent capability
  in the same captured session. Permission/network errors do not open fallback.
- Shared conflict areas are canonical/slice documents and the local acceptance
  runner. Historical migration/proposal bytes and previous evidence stay intact.
- No Production/hosted backend access, provider send, credentials change,
  schema activation, main merge, signed release or physical-device acceptance.

## Local verification

Final counts, source fingerprints, artifacts and command outcomes are recorded
in `docs/data/merchant_catalog_recovery_validation.json`.

- Full Flutter suite: **2,719 PASS / 0 FAIL / 6 existing opt-in SKIP**.
- Flutter analyzer: **PASS**, no issues.
- New tests: **84** (50 adapter/transport,8 recovery-state,26 widget/render).
- Dedicated new-plus-adjacent run:94 PASS; final render-only run:6 PASS.
- Local acceptance-tool safety tests:6 PASS.
- MerchantDevelopment debug APK: **PASS** (159.7s).
- Customer development debug APK: **PASS** (104.7s).
- Both exact APK hashes are in the validation manifest. These are unsigned-for-
  release development artifacts; no device installation or store release occurred.

The managed suite passed **28 groups** with actual local Auth, PostgREST,
Storage and PostgreSQL17.11. Seven new groups cover committed-write recovery,
stale optimistic revisions, exact owner/duplicate onboarding, interrupted upload,
repeat publication, explicit retirement with retained Storage object and exact
submission replay. The other21 preserve the A+B acceptance journey, including
QR concurrency and revoked-session rejection.

Evidence:
`docs/data/merchant_catalog_recovery_managed_acceptance.json`.
These HTTP contract checks are distinct from Dart transport fault injection and
widget tests; neither is physical two-device proof. The owned local stack was
stopped and its empty labelled network removed; its test volumes remain.

The **84 new Dart regressions** exercise same-account replacement versus token refresh,
missing provenance, stale fallback, upload/signing boundaries, late reads,
uncertain writes, conflict review, onboarding recovery, form navigation,
submission retries and media refresh failures. Six 320/390/430px renders at130%
text scale are kept under `docs/evidence/merchant_catalog_recovery/`.
Category read failure is distinct from a successfully empty category set. Saving
dismisses the keyboard so it cannot drag the recovery choices out of view.

## Integration and remaining gates

Integration Agent should inspect the bounded diff, confirm migration/proposal
bytes and Customer bootstrap are unchanged, run analyzer/full Flutter tests, and
repeat the dedicated managed test with a fresh owned fixture when desired.
Do not merge any unrelated worktree or infer authorization to deploy remotely.

Full G/H1/I, external legal/provider decisions, real Firebase/APNs configuration
and J physical two-device acceptance remain open. This package supplies no
payment, refund, payout, marketing delivery or OS notification acceptance.
