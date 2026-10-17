# Merchant campaign and promotion management recovery

Status: **PASS — local implementation complete; Integration Agent handoff**.
Baseline: `298290d84540fb8fce023225b348a01d9e3ac305`.
Branch: `agent/merchant-management-recovery`.
Authority: Product Owner's next comprehensive implementation request; canonical
§11.2. FROZEN product decisions are unchanged.

## Audit and completed scope

Existing F Campaign Lite and G preparation supply owned drafts, revision checks,
request receipts, published listing media and source fingerprints. Reuse those
contracts and the existing Merchant draft guard/read helpers and stable Auth
session parser. No second notification architecture or new dependency was added.

The audit found write timeouts in both adapters, user-only Trust provenance,
Promotion invalidation on every token refresh/resume, signing after abandoned
reads, stale action controls, deduplicated-row pagination offsets, duplicate
publication dialogs and edits lost on departure/conflict. This package closes
those gaps across campaign summary/list/editor, product/photo/date/preview
selectors and promotion list/editor/source/history surfaces.

- Stable session continuation checks cover success, error and media signing;
  token refresh preserves work, replacement/broken streams expire private routes.
  Even a missed auth event is detected at the next asynchronous continuation.
- Reads have explicit deadlines and retry; abandoned decoders cannot enqueue
  further signing. Writes remain pending until their transport resolves. Resume
  cannot open another submission. An uncertain result keeps the identical
  immutable request; no automatic retry, timeout-as-cancellation or offline queue.
- Campaign text and promotion selections stay in memory during revision conflict.
  Exact current-record reads precede explicit use-current/keep-draft review.
  The next save uses a fresh revision and new request ID; G also requires a fresh
  grounded preview/fingerprint. A source-only conflict on a new G draft can refresh
  its preview without attempting to recover a nonexistent record. Missing/disabled
  records cannot silently become new records. Unsaved back navigation asks once.
- Raw page offsets advance independently of display deduplication. Retry retains
  the failed offset/query. Failed reads disable stale actions and do not show an
  empty-success state. Product/media reads are bounded; selectors/dialogs coalesce.

Five Merchant tabs, Customer layouts/bootstrap and all financial/publishing rules
remain unchanged. Reviews, reward economics and account settlement surfaces are
outside this package. Shared touches: the Trust adapter/session guard, existing
Merchant recovery panel (optional explanatory copy), canonical/slice additions,
new core continuation helper, migration inventory and local acceptance runners.

## Backend and deployment boundary

Additive0031 adds `read_merchant_campaign_detail_v1` and
`read_merchant_promotion_detail_v1`. They reuse current F/G projections and the
read-only live Auth-session, merchant-role and active owned-shop guard. This avoids
the review guard's unnecessary pseudonymous-subject allocation. Only authenticated
execution is granted; no new table, policy, public/service-role access or write.
Foreign record IDs under an owned shop look like missing IDs. Disabled features
return no detail. History and previously applied migration bytes are intact.

New detail recovery fails closed if0031 is absent. Existing list/create contracts
remain compatible. A read does not prove a write receipt or a stable pagination
snapshot; concurrent changes can conflict again and require another explicit review.
No draft survives process termination in this package. Physical-device acceptance
and remote rollout remain separate from these local continuation guarantees.

Native PostgreSQL17.11: **161 groups PASS**. Actual local Auth/PostgREST/Storage/
PostgreSQL: **185 groups PASS**, including five new SQL and five new HTTP recovery
groups and a populated upgrade in each runtime. Eight F/G tables retain identical
row counts and fingerprints across0031. Existing accounting/notification checks
also pass. Six local-tool safety tests pass. The owned managed stack and native
cluster are stopped; the owned empty Docker network was removed, volumes retained.
The existing pg8 harness concurrent-query deprecation is nonblocking.

## Verification and reproduction

Full Flutter suite: **2853 PASS /0 FAIL /6 existing opt-in SKIP**, including
**63 new regressions** (30 transport,33 widget) versus integrated2790.
Analyzer: **PASS, no issues**. Both MerchantDevelopment and Customer development
debug APKs built successfully. Six conflict-recovery renders at320/390/430px and
130% text scale were inspected: readable wrapped actions, scrollable content,
no render overflow. APKs are build evidence, not device/store acceptance.
The unchanged Customer category rapid-tap warning and plugin Java8 deprecation
warnings, when emitted, are nonblocking; no package upgrade was performed.

Exact source/artifact fingerprints, logs and measured outcomes:
`docs/data/merchant_management_recovery_validation.json`.
Independent evidence:

- `docs/data/merchant_management_recovery_native_acceptance.json`
- `docs/data/merchant_management_recovery_managed_acceptance.json`
- `docs/data/merchant_management_native_upgrade.json`
- `docs/data/merchant_management_managed_upgrade.json`
- `docs/evidence/merchant_management/` (six inspected renders)

From a fresh owned local fixture, following the acceptance README's safety guards:

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs
node tool/merchant_acceptance/native.mjs <owned-postgresql-17-bin> --management-recovery --notifications --commerce-recovery
node tool/merchant_acceptance/acceptance.mjs <fresh-owned-local-run> --management-recovery --notifications --commerce-recovery
node tool/merchant_acceptance/local.mjs stop <that-exact-owned-local-run>
flutter analyze --no-pub
flutter test --no-pub --concurrency=2
flutter test --no-pub --dart-define=MANAGEMENT_CAPTURE=true test/widget/merchant/merchant_management_recovery_test.dart
flutter build apk --debug --flavor merchantDevelopment -t lib/main_merchant_development.dart --no-pub
flutter build apk --debug --flavor development -t lib/main_development.dart --no-pub
```

`--management-recovery` defers0031 until populated F/G fixtures exist, then checks
the upgrade and new reads. Ordinary G fixture installation includes0031 from the
start. `--notifications` rehearses existing proposals locally only; no Firebase/
APNs credential/configuration or provider send occurs. The HTTP suite discards
acknowledgements deliberately; transport failures are separate Dart test evidence.
Early local test iterations corrected a grouped-REVOKE inventory mismatch and
selector loading animation/test-harness lifecycle/scrolling issues. The final
complete suite and evidence above are the acceptance result.

## Integration and open gates

Integration Agent should review only this branch, especially shared Trust session
handling, exact read grants, canonical additions and the acceptance runner flags,
then repeat relevant checks before merging. Merchant Agent performed no main
merge/push, Production access/write, remote migration apply or provider operation.
Full paid G/Ads, real provider configuration, financial execution and physical
two-device QR acceptance J remain OPEN under their existing authorization gates.
No new mandatory manual step is needed to accept this local implementation.
