# Final Customer V1 signed branded build 1.0.0+4

> Launcher correction: 1.0.0+4 still packaged the legacy T-Store **native launcher
> icon**. The original no-active-T-Store audit covered Flutter AOT and splash only.
> Its launcher coverage was incomplete. The signed **1.0.0+5** V-on-white release
> fixes this and supersedes +4 for branded release use; +4 binaries are unchanged.
> See [launcher correction and physical verification](RELEASE_CUSTOMER_LAUNCHER_ICON_1_0_0_PLUS_5.md).

Signed Production public-canonical APK and AAB are frozen from authoritative main
`f154c2a762065f2d117a2c1292adf5c8db707a40` with only `pubspec.yaml` changed from `1.0.0+3` to `1.0.0+4`.
Package: `com.esnaftavar.app`; versionName: `1.0.0`; versionCode: `4`.
Branch: `astra-release/final-customer-v1-1.0.0+4`. Main merge and force push are outside this task.

## Build and runtime

Production flavor, `lib/main_production.dart`, release mode, public define `true`,
private-preview define `false`. Exact project: `mefhfvrgkwciubeajjeb`.
The existing external client config and external signing properties/keystore were
used unchanged. No config values, passwords or credentials are included here.
Local structural preflight and signing private-key challenge passed.

Public capabilities gate the customer app and use the four public read-facade
RPCs. Failure closes the public catalog; there is no legacy, Development or
private-preview fallback. Public catalog access requires no tester lease.
Public activation ON is the previously supplied live state; this build did not
query, change or revalidate Production. No Production/Development network request,
Auth login/refresh, migration, campaign upload or preview cleanup was performed.

## Included customer experience

- Official unchanged EsnaftaVar logo, Android native branded launch resources and
  the two-second branded Flutter startup with “Kargo bekleme, EsnaftaVar”.
- Home logo/slogan/search/reward/carousel/category hierarchy, seller surface
  separation, five campaign compositions and safe remote-to-local fallback.
- Ödül Sayacı, Reward Center and reduced-motion-aware animations. Runtime uses
  `PendingRewardRepository`: truthful empty progress and history, no real reward
  earning, invented merchant eligibility or financial promise.
- First-run onboarding and persisted completion; an existing completion flag
  legitimately suppresses repeat onboarding.
- Shared notification/push interfaces, local preferences and guarded routing.
  **Firebase/APNs external configuration remains PENDING.** No live push delivery
  is claimed. The undeployed backend/provider fail closed; unused optional code
  may be removed by release tree shaking.
- `supabase/proposals/0016_engagement_foundation.sql` remains proposal-only,
  outside migrations, absent from mobile packages and unapplied remotely.

iOS branded launch sources passed the automated image/resource tests. This task
builds Android APK/AAB only; no iOS binary or iOS signing result is claimed.

## Validation

- Analyzer: **PASS**, zero issues.
- Full Flutter suite: **2243 PASS / 0 FAIL / 6 existing optional/live SKIP**.
  Skip identities exactly match the recorded baseline; no new skips or weakened
  assertions. Tests used local fixtures with live opt-ins disabled.
- Public-runtime targeted suite: **494 PASS / 0 FAIL / 0 SKIP** in 49 files.
  Additional official logo/native splash/carousel checks: **18 PASS / 0 FAIL /
  0 SKIP**. Both targeted runs selected public=true and preview=false.
- Package/version/signatures match in both artifacts. APK ZIP and all 64-bit
  native ELF libraries pass 16 KiB alignment checks. Release is not debuggable.
- All three ABIs of both packages contain the approved Production URL/client
  key, public facade/gate markers, official logo path, slogan, five campaign IDs,
  reward empty-state copy, onboarding flag and notification preferences copy.
- The official logo's packaged bytes match SHA-256
  `a87dc38bcd50dd2650c71257e664c744ad28982f8eddd452f50029c6fe25fb30`.
  All 20 Android light/dark/density splash source variants match packaged alpha
  and rendered pixels over both black and white. PNG optimization only changes
  invisible color data. No active T-Store display text exists; the internal Dart `TStore` class
  name is historical implementation naming, not user-facing branding. Legacy
  image files remain in the unchanged broad asset bundle, but none of the six
  compiled ABI payloads references their paths. Customer branding is EsnaftaVar.
- No active Development endpoint/key/callback or private-preview gate entrypoint
  is present. The existing bare Development ref remains only in its reject guard.
- Exact signing passwords and existing locally cached tester identifiers/tokens
  were checked for exclusion without printing them. No server/service-role key,
  JWT, private key block, database credential assignment, Firebase privileged
  credential, keystore or provider-config file was found. No DB password was
  supplied. The client publishable key is necessarily packaged, never in evidence.
- AAB JAR verification passed. Expected self-signed certificate/PKIX/no-timestamp/
  stream-view warnings are retained in JSON. Independent verification checked
  **550 signed payload entries**,
  zero unsigned entries, zero duplicate names, all with the pinned certificate.
  Store acceptance is not claimed.
- The clean checkout initially lacked ignored Gradle launcher files. They were
  restored from the installed Flutter SDK after exact hash comparison with the
  prior verified release tools. No tracked toolchain or application source changed.
- Tracked source fingerprint and external inputs were stable through both builds.
  Whitespace and scoped secret/PII scans pass. Only the version and two sanitized
  evidence documents belong to this release commit; binaries remain outside Git.

## Frozen artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| APK | 91042415 | `b3485ab44ee1c21ad41c86be81c82b696a25623e5ce10a2001af7a5ece010f96` |
| AAB | 70114414 | `559a1bbf040b003735e61700c2a56373ea411ceb97fa9b66de6d9f7280873a45` |

- APK: `<USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+4-main-f154c2a/EsnaftaVar-1.0.0+4-final-customer-v1-main-f154c2a-production-public.apk`.
- AAB: `<USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+4-main-f154c2a/EsnaftaVar-1.0.0+4-final-customer-v1-main-f154c2a-production-public.aab`.
- Signing certificate SHA-256: `3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B`.
- Frozen UTC: `2026-09-26T19:41:32.902618+00:00`. Copies are hash/size verified and read-only.
  `SHA256SUMS.txt` and a local verification manifest accompany them outside Git.
- Tracked source fingerprint (LF-normalized text): `3032ed8ed032bbecc3b06737aaab54a162fb585f206972be935d7de3f0ff5d82`.

## Physical and remaining boundaries

**PHYSICAL_FINAL_UI_SMOKE: NOT_RUN.** No ADB-ready phone was connected at the
final availability check. No install, app-data reset or physical launch took
place; crash and ANR are NOT_RUN, not inferred NO. Automated startup/onboarding
and customer UI checks passed. The QR two-device physical gate stays **OPEN**.
Private-preview cleanup is **NOT_PERFORMED**. Production remains untouched.

## TASK_RESULT

```text
FINAL_CUSTOMER_V1_SIGNED_BUILD: PASS
AUTHORITATIVE_MAIN: f154c2a762065f2d117a2c1292adf5c8db707a40
VERSION_NAME: 1.0.0
VERSION_CODE: 4
PACKAGE: com.esnaftavar.app
PRODUCTION_PUBLIC_RUNTIME: PASS
NO_LEGACY_FALLBACK: PASS
NO_DEVELOPMENT_FALLBACK: PASS
NO_PRIVATE_PREVIEW_REQUIREMENT: PASS
OFFICIAL_BRANDING_PACKAGED: PASS
OLD_TSTORE_ACTIVE_BRANDING: YES
FINAL_POLISH_ENGAGEMENT_PACKAGED: PASS
PUSH_FOUNDATION_PACKAGED: PASS
PUSH_PROVIDER_EXTERNAL_CONFIG: PENDING
REAL_REWARD_ECONOMICS_IMPLEMENTED: NO
ENGAGEMENT_0016_PROPOSAL_ONLY: PASS
FLUTTER_ANALYZE: PASS
FULL_FLUTTER: 2243 PASS / 0 FAIL / 6 SKIP
APK_PATH: <USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+4-main-f154c2a/EsnaftaVar-1.0.0+4-final-customer-v1-main-f154c2a-production-public.apk
APK_SHA256: b3485ab44ee1c21ad41c86be81c82b696a25623e5ce10a2001af7a5ece010f96
AAB_PATH: <USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+4-main-f154c2a/EsnaftaVar-1.0.0+4-final-customer-v1-main-f154c2a-production-public.aab
AAB_SHA256: 559a1bbf040b003735e61700c2a56373ea411ceb97fa9b66de6d9f7280873a45
SIGNING_CERT_SHA256: 3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B
SERVICE_ROLE_IN_ARTIFACT: NO
DB_PASSWORD_IN_ARTIFACT: NO
JWT_IN_ARTIFACT: NO
TESTER_UID_IN_ARTIFACT: NO
SIGNING_SECRET_IN_ARTIFACT: NO
FIREBASE_SERVER_SECRET_IN_ARTIFACT: NO
PHYSICAL_FINAL_UI_SMOKE: NOT_RUN
CRASH: NOT_RUN
ANR: NOT_RUN
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
QR_TWO_DEVICE_PHYSICAL_GATE: OPEN
PRIVATE_PREVIEW_CLEANUP: NOT_PERFORMED
BINARY_AFFECTING_DELTA: YES
READY_FOR_FINAL_BUILD_EVIDENCE_INTEGRATION: NO
```
