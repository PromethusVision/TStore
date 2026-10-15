# Merchant G preparation — Tanıtım Merkezi handoff

Status: **PASS — local G preparation delivered. Full G remains gated.**
Baseline: `217ef0b7f0b80129e7fac17f435535010a02afe1` (integrated H1 read).
Task branch: `agent/merchant-promotion-g`.

## Delivered behavior

The Merchant dashboard opens a private Tanıtım Merkezi when its local capability
is configured. An owner selects one of four structured template families, one of
two variants, an eligible product/current campaign and an optional existing
published product photo. The server produces the preview from current source
facts. The merchant can save, edit, archive, restore and inspect revision history.

Store and invitation templates use the actual shop name. Product templates use
the exact current price. Campaign templates use typed discount/price facts,
explicit eligible scope and validity dates; freeform campaign marketing claims
are not copied into advertisements. The selected campaign's media restrictions,
public catalog eligibility, stock/availability and real Storage metadata apply.
No new upload or external image URL input is introduced.

A saved draft is preparation only. It creates no paid package, placement, push
entitlement, customer exposure, financial debit, performance event or notification.
The UI says so and does not fabricate zero impression counts or publication status.

## Audit and reuse

Integrated main already contained Merchant auth/shop gates, catalog/media0016,
Campaign Lite0021/0022, review pseudonymous subjects, QR live-session checks,
H0/E accounting and H1 read projection0027. The gap was the owned structured
creative workspace. This package reuses those contracts, existing authenticated
Supabase client, media bucket/signing and Merchant design system. Customer V1
screens and the existing notification architecture are unchanged.

Screen inventory:
- dashboard entry and draft list with disabled/loading/empty/error states;
- editor with structured family/variant controls, source selection and preview;
- eligible source search with bounded additional pages;
- photo selection from existing listing media;
- archived/restorable drafts and historical revision view;
- uncertain-write recovery with edits locked until the exact request resolves.

No broad framework change, new dependency, second wallet, second inbox or shared
global navigation redesign is needed.

## Server/client contract

Forward migration0028 creates private config, draft roots, append-only revisions
and idempotent request receipts. Direct access and helper execution are denied
to PUBLIC/anon/authenticated/service_role. Five owner RPCs expose bounded list,
source choices, preview, mutation and history. Live Auth session, current merchant
role, exact active shop ownership precede even disabled responses and receipt replay.

All changes serialize on the owned shop. Edit/archive use expected revision.
Save recalculates the server fingerprint and rejects changed sources atomically
before a new root is inserted. Stock/category changes, source deletion/unavailability,
price/name/campaign revision changes and invalid/retired photo metadata invalidate
a stored preview. Reads label saved copy as historical/needs update without
silently replacing it. History does not render old photo URLs as current media.

Exact repeated request/payload returns its immutable receipt even after later
edits or feature stop. Reusing a request ID for another command is rejected.
A receipt describes the committed revision, not current freshness or publication.
The client preserves the same command after timeout/unknown response and same-user
session refresh, rejects double taps and discards late responses after session
events/errors. Account changes erase private state. Resume invalidates previews.

Read pages contain at most20 rows. Draft/history order is ascending immutable
creation order so edits and archive operations do not shift pagination. Source
search is a bounded live selector; save always rechecks eligibility. A technical
500-draft-root guard is not an advertising entitlement. Archiving preserves roots
and revision history; no production retention duration is chosen.

## Capability and rollout boundary

Both gates default OFF:
- client `MERCHANT_PROMOTION_V1_ENABLED`, bound only in the loopback-only Merchant
  development bootstrap;
- private `merchant_promotion_config.enabled`.

Production access, writes, migration application and main merge: **NONE**.
0028 is a proposal for authorized rollout, validated only in fresh owned local
fixtures. All historical migrations remain unchanged. Preflight requires existing
catalog/F/live-session/subject/H1 contracts. Transaction, lock timeout, explicit
grants and UTC-normalized fingerprint generation are part of the new migration.

Feature stop hides data on the next request; lifecycle/session events clear local
views. It cannot remotely erase already displayed content without another event.
There is no persistent draft cache or background retry queue. An uncertain request
retained in the open screen is explicitly reconciled; after process restart the
owner reloads their authoritative draft list. Existing short-lived media signing
remains120seconds. No second Storage or Auth policy is introduced.

Rollback means disabling the client/server preparation gates and preserving
history/receipts. Do not delete drafts or rewrite prior migrations to roll back.
A reviewed forward correction is required for schema changes. This document
grants no remote rollout authority.

## Validation

Final checks: **2539 Flutter PASS / 0 FAIL / 6 existing SKIP**, **42 new focused
tests PASS**, analyzer PASS, five harness safety tests PASS, **125 native
PostgreSQL groups PASS** and **130 actual local-service groups PASS**. Both
Merchant and Customer development debug APKs compiled successfully.

Initial parallel validation exhausted host memory headroom; one native attempt
lost its connection and the initial build/test attempts were interrupted. Those
attempts are not PASS evidence. Final Flutter tests used two workers; final APKs
were built sequentially with a task-local 2 GiB Gradle heap, 768 MiB metaspace and two
workers. No repository Gradle/dependency setting was changed. Final local services
and native clusters are stopped; synthetic database volumes remain preserved.

Merchant compilation enables `MERCHANT_PROMOTION_V1_ENABLED` alongside the
existing QR/review/trust/reward/checkout/statement flags. Customer compilation
retains its existing feature flags. APK compilation is not physical acceptance.

Final machine-readable results and source/build hashes:
[data/merchant_promotion_g_delivery_validation.json](data/merchant_promotion_g_delivery_validation.json).

- Native PostgreSQL evidence:
  [merchant_promotion_g_native_acceptance.json](data/merchant_promotion_g_native_acceptance.json).
- Actual local Auth/PostgREST/Storage evidence:
  [merchant_promotion_g_managed_acceptance.json](data/merchant_promotion_g_managed_acceptance.json).
- Real synthetic API projection decoded by Dart tests:
  [merchant_promotion_g_contract.json](data/merchant_promotion_g_contract.json).
- Render evidence: [promotion_g](evidence/promotion_g/) at320/390/430px with130% text.
  Rendering is automated widget evidence, not physical-device acceptance.

The DB suite includes integrated B/C/D/F/H0/E/checkout/H1 regressions, including
the prior coupon net-threshold reservation repair. New groups cover default-OFF,
real ownership/roles/logout, structured claim rejection, exact money, foreign
sources, stale snapshot rollback, concurrent writes, idempotent recovery,
archive/history, pagination, RLS, no ledger/notification side effects, and actual
upload → signed bytes → retirement → stale-save rejection.

Reproduce only in new owned fixtures with free loopback ports:

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=PROMOTION_CAPTURE=true test/unit/merchant_promotions test/widget/merchant/merchant_promotion_test.dart
npm --prefix tool/merchant_acceptance ci --no-audit --no-fund
npm --prefix tool/merchant_acceptance test
node tool/merchant_acceptance/native.mjs <owned-local-postgresql-17-bin> --promotion
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-owned-run-directory> --promotion
node tool/merchant_acceptance/local.mjs stop <same-owned-run-directory>
```

`--promotion` retains the complete preceding statement/checkout/reward chain.
It writes separate G evidence and does not overwrite the prior H1 contract fixture.
Synthetic data/logs remain in ignored task scratch; do not publish local service
keys. No Docker-wide cleanup, reset or hosted fallback is authorized.

## Remaining gates and shared review areas

Migration manifests record the exact locally executed bytes. Historical migration
contents are compared against baseline Git after canonical LF normalization;
platform checkout line endings can otherwise change raw file hashes.

Full G remains open: versioned commercial price, purchase/extension and H0 debt
consumption, sponsored serving/fair rotation, observation/attribution policy,
audience/consent/rolling quotas and push scheduling. O8/O9/O10, full H1 settlement,
I provider setup and J physical two-device acceptance remain separate work.
No real-device/manual step is required to assess this bounded preparation package.

Shared diff: Merchant service composition, dashboard/bootstrap; additive migration
and its contract allowlist; canonical/slice notes; owned local acceptance harness.
No Customer UI/runtime, theme, dependency/lockfile, shared notification foundation
or previous migration is changed. Integration Agent alone reviews/merges main.
