# Existing Merchant/Customer badge and trust read recovery

Task branch: `agent/merchant-trust-recovery`.
Base: `88fa667b982608338044219f06897da5007c9eda`.
Product authority: canonical §7.3, existing FROZEN D/F rules.

## Integration context

At the start of this task, a fresh fetch and remote-ref read confirmed main at
`88fa667b`. The latest visible Integration Agent completion concerned notification
preferences. Statement recovery `3b7f3df8c78aecf9bf29bdfc7c98aaf820c26f1c`
was delivered on its task branch but was not an ancestor of main. This task
therefore starts independently from confirmed main; it does not silently
incorporate or certify the statement delivery. Integration Agent owns review
and merge order, including full validation of the combined result.

## Reproduced defects and changes

Before runtime edits, `.buildlog/trust-red.log` recorded **10 PASS / 22 FAIL**.
Actual Supabase SDK/Auth/HTTP fixtures reproduced queued S1→S2→S1 acceptance
in Merchant trust, Customer trust and the shared campaign adapter, including
malformed late responses. Captured session events now use the existing
`AuthenticatedSessionEvents` and `AuthenticatedRequestScope`; no second Auth
system is introduced. Normal renewal remains valid, and missing session
provenance refuses private requests before HTTP.

Private summaries/history now clear on authority or shop changes, bound reads
and catch unexpected transport failures. Resume replaces a pending pagination
generation with fresh state. Failed later pages retry their original cursor.
The existing descending event-ID SQL contract is validated at the adapter and
view boundary; disabled or contradictory responses cannot retain stale history.
No client qualifies badges or changes thresholds. This does not make separately
read pages an atomic snapshot.

Private badge explanations and all-badge dialogs reuse the existing overlay
guard. Shared public shop badges/offers reload on repository/shop replacement
and resume, contain both parallel read failures, and permit bounded retry.
Layout, eligibility, exact server thresholds and offer facts are preserved.

Existing campaign transport tests explicitly supply synthetic session-key
streams; real-SDK tests independently exercise the actual default Auth streams.
Existing campaign mutation/recovery behavior is covered because it shares this
adapter and guard. No new mutation, request queue or automatic replay was added.

## Validation boundaries

- Targeted repository, trust surfaces and adjacent campaign/promotion recovery:
  **127 PASS / 0 FAIL**. Log: `.buildlog/trust-targeted.log`.
- Full Flutter regression: **3174 PASS / 0 FAIL / 6 existing conditional SKIP**.
  Log: `.buildlog/trust-full.jsonl`. This branch adds **49 tests** to confirmed
  main's 3125 baseline. The separate statement delivery's 53 tests are not in
  this independent branch; the lower count relative to that delivery is not
  deletion or weakening of tests.
- `flutter analyze --no-pub`: **PASS, no issues**.
  Log: `.buildlog/trust-analyze.log`.
- Coverage includes actual SDK initial replay/renewal/replacement events,
  captured intermediate identities, mutation acknowledgements, observer failure/
  closure, disposed listeners, bounded and thrown reads, retained pagination
  cursors, malformed history, shop/repository replacement, resume and late
  completions, protected dialogs and 320px / 140% text states.
- Existing golden/layout tests passed without updating golden images.

The initial Customer Android compilation failed because the E: drive was full.
Its log is preserved at
`.buildlog/pilot-device/trust-recovery-20261020/customer.build.log`.
Recovery removed only verified untracked `build/` caches in this task and the
previous statement task. Copied APK bundles and all verification logs were
outside those directories and retained. No dependency or platform settings
were changed to work around the failure.

The retry completed successfully:

- Pair compatibility/preflight: **135 PASS / 0 FAIL / 0 SKIP**.
- Customer Development, Merchant Pilot and Merchant Development ARM64 debug:
  **PASS**. Packaged identities, callbacks, signatures and SHA-256 verified.
- Evidence:
  [verification](data/merchant_trust_recovery_verification.json) and
  [paired builds](data/merchant_trust_recovery_build_pair.json).
- Isolated artifacts:
  `.buildlog/pilot-device/trust-recovery-20261020-retry/`.
- Customer retry reported nonfatal Kotlin incremental-cache diagnostics; Gradle
  completed successfully. Its full diagnostic log is preserved.

Builds precede the delivery commit, so the pair records base `88fa667b` and
`uncommitted_sources: true`. Their verified source fingerprint is
`9aa9205e2d4024f9ca72db2335230942b98dba8f4465ebe79655aaf7b37420f3`.
This identifies the built changes without pretending they were in the base.
The six conditional skip identities match the integrated preference baseline.
No new skip or weakened test was introduced.

Original delivered `EsnaftaVar-Development-a0dfbdfd` APKs and all three copied
statement-recovery compile artifacts were rehashed and remain unchanged.
After preserving the new APKs in the isolated evidence directory, this task's
reproducible `build/` cache was removed again, leaving approximately 5.1 GB free
on E: for subsequent work. Source, logs and APK evidence remain available.

All tests are local; HTTP fixtures use `.invalid` mock transport, synthetic
sessions and no real credentials. Existing SQL was read to check the cursor
contract, not changed or applied. The server's trust read already refreshes badge
projections; this package adds no write authority.

Production/hosted Development access and writes: **NONE**. Migration apply:
**NONE**. Provider configuration/sends: **NONE**. Flags remain default OFF.
New APKs are synthetic compile rehearsals, not distributable pilot candidates.
Physical QR, real provider acceptance, selected pilot merchants/products,
official geography and pilot opening remain separate OPEN gates.

Shared review areas: trust/campaign adapter, trust session/overlay guard,
Merchant and Customer badge views, canonical and slices documents.
Final scope is 12 authored files; `git diff --check`, added-content/new-file
secret/PII scanning and built-source fingerprint verification pass. No generated
metadata, dependency, SQL, global Auth implementation or unrelated checkout
changes are included.
No user phone action is required to complete this local package.
