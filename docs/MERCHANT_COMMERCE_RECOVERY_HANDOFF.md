# Merchant QR, purchase history and return recovery

Baseline: `aca7e985040308adb82d162198811a39030f6262` (integrated catalog
recovery). Task branch: `agent/merchant-commerce-resilience`. Authority: the
Product Owner's next comprehensive implementation request; canonical §5.3 and
the B/E follow-through inventory bound this package.

## User-visible behavior

A lost first QR claim acknowledgement previously returned to ordinary input,
although the server could already hold a claim. Unknown startup/claim results
now keep new input closed until explicit authoritative recovery. A known claim
is reconciled by its exact identity; a nullable latest-claim response cannot
replace it. Claim identity, immutable sale/coupon terms and deadlines must agree
before a later response is accepted. Duplicate actions remain serialized.

Merchant access checks and purchase screens capture the existing Auth session
identity. Replacement sessions, including the same account signing in again,
cannot continue an old workspace operation. Shared QR error handling checks the
captured session before classifying server rejection. A late rejection from an
old session cannot authorize removal of a pending return. Server role, ownership,
installation/session validation and RLS remain authoritative.

Purchase list/detail reads have a 15-second deadline, explicit retry and late
response suppression. Failed detail refresh removes stale actions. Pagination
deduplicates rows while advancing by the server's actual page length, and a
failed later page retains its retry position. Duplicate route opens coalesce.

The return form persists the exact request ID, reason and item quantities before
dispatch. Lost acknowledgements replay that same request, including when the
original request already returned every remaining unit. Pending values are
read-only. A definite rejection requires fresh purchase evidence before editing.
Known server success and local acknowledgement cleanup are separate states:
retrying cleanup does not send another return. Back navigation protects unsaved
drafts and blocks departure during submission. An already-persisted uncertain
request can be recovered after reopening the form.

## Architecture and boundaries

- Reuse current B/E repositories, RPCs and the existing account/purchase-scoped
  `pending_return_b` record. No new offline queue, notification subsystem or
  dependency. The extracted store/controller/form isolate durable retry from UI.
- Validate stored records against original purchased quantities, not remaining
  quantities. Corrupt records are retained and block new writes; they are never
  silently replaced. Same-process per-key serialization preserves the first
  intent and compare-before-clear protects a newer intent. SharedPreferences is
  not a cross-process transaction; server idempotency remains the final guard.
- Optional `QrSessionIdentity` provenance is implemented by the real adapters.
  Host authority loss still disposes private routes. Session guards do not cancel
  requests already dispatched. QR recovery and writes receive no artificial
  timeout because even recovery RPCs may register devices or mutate evidence.
- Shared coupon/purchase decoding rejects negative sale/payment values and
  duplicate return identifiers. No amount, threshold or reward rule changes.
- Customer V1 screen layouts/bootstrap, shared push foundation, default-OFF
  flags, historical migrations and public RPC signatures remain unchanged.

## Additive 0030: purchase API privacy correction

New real HTTP coverage reproduced an existing projection defect: PostgreSQL
evaluates JSON subtraction before concatenation, so subtracting actor keys from
the right-hand object did not remove those keys from the transaction header.
The existing minimized purchase API still exposed `customer_user_id` and
`confirmed_by_user_id`.

`20261017003000_0030_purchase_evidence_privacy.sql` removes those two keys from
the header before concatenation. Every other projected field is preserved. The
private helper remains SECURITY DEFINER with an empty search path and no direct
EXECUTE grant to public/client/service roles. Existing authorized participant RPC
checks and legacy direct-table SELECT contracts are unchanged; this is an API
projection correction, not a claim that every legacy table hides actor IDs.

The migration checks the complete 0025 purchase/coupon contract and uses a
transaction with bounded lock/statement waits. It changes one function and
retains its existing private grants, without updating purchase/return/ledger
rows. Historical migration bytes are untouched. Production/remote deployment
requires separate Product Owner authorization; no remote apply occurred here.

The populated local upgrade compares every purchase payload with the old payload
minus exactly those two keys, and fingerprints seven immutable tables before and
after. A separate native fresh-install run tests the corrected projection with
the full checkout regression chain. Managed acceptance exercises actual local
Auth, PostgREST, Storage and PostgreSQL, including replay and foreign-owner denial.

The final populated rehearsal compared **98 purchases**, 98 item rows, 62 terms,
11 returns, 11 return items, 609 journals and 1,284 postings. All seven table
fingerprints stayed identical. The earlier 100-purchase exploratory proof also
included two newly-created recovery purchases; the final reproducible command
intentionally upgrades before creating those two purchases.

Fresh native PostgreSQL 17.11 passed **104 groups**; real local managed services
passed **114 groups**, including ten new recovery HTTP groups, three projection
groups and the populated upgrade. The owned managed stack was stopped, its empty
labelled network removed and test volumes retained. Native shutdown completed.
The six local-tool safety tests passed after stopping the owned stack; attempting
them while that stack occupied their fixed test port caused an environment-only
port collision. Existing pg 8 harness concurrency deprecation remains nonblocking.

## Verification and reproduction

Final measured counts, artifacts, source fingerprints and limitations are in
`docs/data/merchant_commerce_recovery_validation.json`. Separate evidence:

- `docs/data/merchant_commerce_recovery_native_acceptance.json`
- `docs/data/merchant_commerce_recovery_managed_acceptance.json`
- `docs/data/merchant_purchase_privacy_upgrade.json`
- Six 320/390/430px QR/return renders at 130% text scale under
  `docs/evidence/merchant_commerce_recovery/`.

Final full Flutter suite: **2,790 PASS / 0 FAIL / 6 existing opt-in SKIP**,
including **71 new regressions** versus the integrated 2,719-test baseline.
Analyzer: **PASS**, no issues. All six final renders were inspected, including
the wrapped quantity helper and readable pending values on 320px screens.
An unchanged Customer category rapid-tap test emits one nonblocking hit-test
warning; new Merchant tests emit none. The first full run found the newly-added
migration missing from the exact file inventory; that inventory and the new
migration's preflight/timeouts were corrected before the final complete pass.

Both development debug Android packages passed: MerchantDevelopment (155.0s)
and Customer development (76.6s). Exact APK sizes/hashes are in the validation
manifest. Existing plugin Java 8 source/target deprecation warnings are
nonblocking; no dependency upgrade or device installation was performed.

After preparing and starting a fresh owned local acceptance run using the
existing tooling (never supply a remote URL):

```powershell
node --test tool/merchant_acceptance/safety.test.mjs
node tool/merchant_acceptance/native.mjs <owned-postgresql-17-bin> --commerce-recovery
node tool/merchant_acceptance/acceptance.mjs <fresh-owned-local-run> --commerce-recovery --privacy-upgrade
node tool/merchant_acceptance/local.mjs stop <that-exact-owned-local-run>
flutter test --no-pub --concurrency=2
flutter analyze --no-pub
```

`--privacy-upgrade` first tests the pre0030 chain, then applies0030 to that
populated local fixture and executes the recovery checks. Native mode installs
0030 before the regression chain. Without `--privacy-upgrade`, managed mode also
tests a fresh installation. See the acceptance README for fixture safety rules.
HTTP tests deliberately discard acknowledgements; injected Dart transport
failures and widget tests are distinct evidence, not physical network/device
acceptance. Debug APKs are build artifacts only, not store releases.

## Integration and open gates

Integration Agent should inspect shared QR/purchase contracts, the additive
migration, canonical/slice additions and acceptance runner changes, repeat the
relevant checks and merge only this task branch. No main merge or main push was
performed by Merchant Agent. No Production access, remote migration, provider
send, financial execution or credential change is part of this package.

Physical two-device QR acceptance J, real Firebase/APNs setup, external
legal/provider and financial deployment gates remain OPEN. No actual money
refund, coupon restoration, payout or final device acceptance is asserted.
