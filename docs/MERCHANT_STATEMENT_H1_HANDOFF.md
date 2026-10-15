# Merchant H1 — bounded balance and statement read surface

Base: integrated checkout E at `1374f82835244d34bfa56145dfeb36beedeb0268`.
Task branch: `agent/merchant-statement-h1`.
Canonical authority: §9 and §9.2 of
[Trust & Commerce canonical](ESNAFTAVAR_V1_TRUST_COMMERCE_CANONICAL.md).

## Delivered behavior

The Merchant dashboard can open **Hesap Bakiyesi** behind the default-OFF local
`MERCHANT_STATEMENT_V1_ENABLED` client flag. The server independently requires
both `merchant_statement_config.enabled` and `commerce_ledger_config.enabled`.
No Customer route/UI or notification/provider binding changes.

The screen separates pending coupon receivables, pending unused-package funds,
the mandatory reserve, and each internally released receivable pool. A released
receivable is explicitly **not** proof of a completed payment or withdrawal
authorization. Settlement remains disabled; paid totals and withdrawal dates
are unavailable rather than invented zeroes. There is no funding, transfer,
top-up, withdrawal, payment, settlement or policy-administration action.

History shows net changes and individual movements between the Merchant's own
buckets. Internal releases have zero net value but retain their signed movements.
Original and compensating entries remain visible with expandable, selectable
references. Values are exact integer kuruş strings and Dart BigInt; formatting
never converts to floating point.

Loading, unavailable capability, empty history, retry, partial page failure,
changed history, logout, same-user session events and application resume are
handled separately. Initial reads/refreshes do not display fabricated zeroes.
Duplicate page taps issue one read. A transient page failure can retry the same
cursor; a changed revision discards the partial statement and refreshes from the
first page. The Merchant workspace removes the private route after logout.

## Server contract and privacy

New forward migration:
`20261015002700_0027_merchant_statement_read.sql`.
It adds only a default-OFF read gate and
`read_merchant_statement_v1(p_shop_id,p_limit=20,p_before=NULL,p_revision=NULL)`.
No historical migration, accounting kernel, source rule, stored balance, QR
approval or coupon-reservation behavior is rewritten.

The RPC checks a live Auth session, current Merchant role, active shop and exact
ownership even when the feature is disabled. It reuses the existing session
guard and locks authorization rows for the read. It does not create review
identity rows or perform any accounting writes. Anonymous and service-role RPC
execution is denied; the configuration and raw ledger remain private.

One SQL statement snapshot produces the five buckets, owned journal count,
bounded page (1–50), cursor and reserve cap. Pages order by recorded time and UUID
descending. Cursor membership is checked against owned history. The append-only
owned journal count is a **revision**, not a monetary balance or authorization.
Any new committed journal invalidates an older revision with SQLSTATE 40001.
This intentionally requires a fresh read rather than persisting private snapshots
or assuming sequence allocation equals commit order. Late commits and concurrent
read/write reconciliation are exercised in the database tests.

Only this Merchant's posting codes and signed amounts are projected. No customer
identity, raw source/evidence reference, operator reason, counterparty account,
platform balance or package account is exposed. Reversal references are returned
only when the original journal is also in owned history. The client validates
exact schemas, source enums, own account codes, nonnegative summaries, integer
strings, signed movement sums, page ordering, cursor consistency and scope.
Unknown/malformed financial responses fail closed without raw server diagnostics.

## Scope and remaining gates

This is the read-only part of H1, advanced after E to make existing receivables
reviewable. **Full H1 is not complete.** G and approved O8 finance/legal/provider
policies remain prerequisites for full settlement. No withdrawal cadence,
relationship-exit reserve release, tax treatment, cash refund, disputed coupon
restoration or provider outcome is inferred.

All runtime/config changes used for acceptance are in fresh synthetic local
fixtures only. Production access/write/migration apply: **NONE**. Main merge/push:
**NONE**. Feature flags default OFF. Physical two-device QR acceptance and real
Firebase/APNs delivery remain open.

## Verification and reproduction

Final checks: **2497 Flutter PASS / 0 FAIL / 6 existing SKIP**, 39 focused tests
(32 added), analyzer PASS, five harness safety tests PASS, and both debug APKs
PASS. Merchant compilation recovered from the existing Windows Kotlin incremental
daemon/cache error through Gradle's successful fallback; no application or
dependency workaround was added.

Machine-readable evidence:

- [Delivery checks and fingerprints](data/merchant_statement_h1_delivery_validation.json)
- [Native PostgreSQL proof](data/merchant_statement_h1_native_acceptance.json):
  113 groups, real PostgreSQL/pgcrypto and independent connections, synthetic
  Auth/Storage schema; not managed-service evidence.
- [Managed local service proof](data/merchant_statement_h1_managed_acceptance.json):
  115 groups with actual local Auth/PostgREST/Storage, including HTTP logout
  invalidation and SQL/HTTP statement authorization.
- [Real API projection fixture](data/merchant_statement_h1_contract.json):
  synthetic own-account responses, decoded by a Dart contract test; no tokens.
- [Mobile render evidence](evidence/statement_h1/): 320/390/430px at 130% text
  scale, unavailable/error/changed-history states, release and reversal history.

The statement scenarios run after integrated B/C/D/F/H0/E/checkout acceptance,
including the prior net-threshold reservation repair. Source segregation,
reserve cap/refill/service consumption, exact large amounts, zero-net releases,
reversals, all-page reconciliation, foreign/invalid cursors, revoked/suspended
accounts, late commits, concurrent snapshots and default-OFF gates are covered.

```powershell
flutter analyze --no-pub
flutter test --no-pub
flutter test --no-pub --dart-define=STATEMENT_CAPTURE=true test/unit/commerce_ledger test/widget/merchant/merchant_statement_test.dart
npm --prefix tool/merchant_acceptance ci --no-audit --no-fund
npm --prefix tool/merchant_acceptance test
node tool/merchant_acceptance/native.mjs <owned-local-postgresql-17-bin> --statement
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run-directory>
node tool/merchant_acceptance/acceptance.mjs <same-owned-run-directory> --statement
node tool/merchant_acceptance/local.mjs stop <same-owned-run-directory>
```

Use only new fixtures and free loopback ports. No Docker-wide prune/reset,
existing project database, hosted fallback or secret-bearing diagnostic dump.
The harness retains synthetic data and stops its own services after validation.

APK compile checks use development debug and merchantDevelopment debug with
existing QR/review/trust/reward/checkout defines; the Merchant build additionally
enables `MERCHANT_STATEMENT_V1_ENABLED`. Compilation is not physical/device or
remote-release acceptance. Exact outcomes/hashes are in the delivery report.

## Deployment and review boundary

0027 is additive and transactional. Rehearsal applies the exact ordered local
chain. All earlier Git migration contents are unchanged; Windows checkout line
endings change seven raw fixture hashes relative to the preceding delivery.
Both local manifests agree byte-for-byte, and the delivery report verifies
historical content against canonical LF Git bytes separately. An authorized rollout would review
the source account map, reconciliation ownership and privacy contract, deploy
the compatible RPC, then deliberately enable the read gate/client flag.
This handoff grants no such remote authority.

Disabling the statement gate hides the projection on the next authenticated read;
it does not cancel earning, checkout, reservations or ledger posting. The H0
operational stop remains a separate control. Previously viewed data cannot be
remotely erased from a device without a refresh/session event; no persistent
client financial cache was added. Preserve all journals when rolling back a
client/read-gate rollout; use a reviewed forward correction if needed.

Shared review areas: additive migration chain and migration contract allowlist,
existing ledger adapter/domain, Merchant bootstrap/services/dashboard, canonical
and slice notes, local acceptance harness. No dependency/lockfile, theme,
Customer bootstrap/navigation, shared push or historical migration changes.
