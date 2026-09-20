# W52K-C signed canonical Production private-preview RC

Signed APK and AAB version **1.0.0+2** were built from authoritative main `6f765ef9fd22bdd5749f0fbe0eb99d2640091c37` plus the version-only change in `pubspec.yaml`. The existing Production private-preview path is selected. No backend access, Production write, public activation or device install occurred.

## Build/runtime contract

- Branch: `astra-release/w52k-c-signed-canonical-production-rc`.
- Flavor/target: `production` / `lib/main_production.dart`.
- Additional define: `ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=true`.
- The existing external Production config supplies `SUPABASE_PRODUCTION_URL`, `SUPABASE_PRODUCTION_ANON_KEY`, `PRODUCTION_PROJECT_REF`, `PRODUCTION_AUTH_SITE_URL`, `PRODUCTION_AUTH_WEB_REDIRECT_URL`, `PRODUCTION_AUTH_MOBILE_CALLBACK_URL`; key values are omitted.
- Project: `mefhfvrgkwciubeajjeb`. Configuration is validated locally and only client publishable credentials are allowed.
- `productionPreviewApplication` requires existing login followed by `ProductionPreviewTaxonomyAdapter.authorize()`: exactly one capability-array item, current-subject match, approved project/bridge/product contracts, compatible taxonomy proof, 24 preview roots, and public activation OFF.
- Canonical repository bindings are installed only after verified authorization. Missing/denied authorization produces login or controlled failure; it never renders the legacy app as a successful preview. Normal public builds retain their legacy behavior.
- Main runtime and UI source are unchanged. The only code/version change is `1.0.0+1` → `1.0.0+2`; no evidence of a previously built versionCode >= 2 was found in the repository release records.

## Validation

- Targeted tests with the preview define: **148 PASS / 0 FAIL / 0 SKIP**, across 22 files.
- Full Flutter suite: **2134 PASS / 0 FAIL / 6 existing SKIP**; skip identities match the prior baseline.
- `flutter analyze --no-pub`: PASS. No test changes, weakened assertions, new skips or dependency upgrades.
- Local config preflight and existing external signing private-key challenge: PASS.
- All 3 ABIs in each artifact contain the approved Production config and private-preview contract/RPC/denial markers.
- Development URL, key define, canonical opt-in and callback are absent. The Development project-ref constant remains only in the unchanged reject-Development guard; no fallback exists.
- APK signature/package/version/debug/alignment checks: PASS. AAB manifest, JAR signature and every signed payload entry: PASS. Expected upload certificate matches both artifacts.
- No service-role/server secret, signing password, actual tester UID, JWT/session, private key block or DB credential assignment was found. No database password was supplied to the build.
- Customer V1 light-only UI, Home max 8 categories, Tüm kategoriler, Category Icon V1, contrast fixes, Reward V1, Cart V2 and accepted customer screens remain unchanged. Custom category visuals remain deferred.

## Frozen artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| APK | 89481479 | `97017d652781c50c2bcb331b442109bdb8d53b1b46f0b8c016f43de04eed581c` |
| AAB | 68917978 | `acaba6132e92314e22253afd2f57d28e4e8306dfc8245769787b89d38d2d22d7` |

- Package/version: `com.esnaftavar.app`, versionName `1.0.0`, versionCode `2`.
- Certificate SHA-256: `3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B`.
- APK: `<USER_HOME>/EsnaftavarReleases/w52k-c/1.0.0+2-main-6f765ef/EsnaftaVar-1.0.0+2-w52k-c-main-6f765ef-production-preview.apk`.
- AAB: `<USER_HOME>/EsnaftavarReleases/w52k-c/1.0.0+2-main-6f765ef/EsnaftaVar-1.0.0+2-w52k-c-main-6f765ef-production-preview.aab`.
- Frozen UTC: 2026-09-20T16:59:01.842473+00:00; copied bytes/hashes verified and artifacts marked read-only.
- Source content SHA-256 (LF-normalized text, tracked files): `71637db321b7cb15d3e6de164591413afc4f2c3f69cbbe5b5a0e03b14b292f7f`. Source/config/signing inputs remained stable throughout the pipeline.
- AAB JAR verification reported self-signed upload-certificate, untrusted PKIX chain, missing timestamp and JarInputStream/JarFile view warnings. The signature verifier succeeded; all 549 payload entries were independently read and verified with JarFile against the pinned certificate, with zero unsigned entries or duplicate names. No store upload acceptance is claimed.

## Physical test handoff

Build readiness is PASS; device install/smoke is **NOT RUN**. W52K-D must separately refresh the existing tester session, renew temporary preview authorization, then verify and install this exact frozen APK. No dependency on the previous session/allowlist TTL was introduced and neither was renewed here.

## TASK_RESULT

```text
W52K_C_SIGNED_CANONICAL_RC: PASS
AUTHORITATIVE_MAIN: 6f765ef9fd22bdd5749f0fbe0eb99d2640091c37
CANONICAL_PRIVATE_PREVIEW_CLIENT_MODE: PASS
PRODUCTION_PROJECT_VERIFIED: PASS
DEVELOPMENT_FALLBACK: NONE
FULL_FLUTTER: 2134 PASS / 0 FAIL / 6 SKIP
ANALYZER: PASS
VERSION_NAME: 1.0.0
VERSION_CODE: 2
PACKAGE: com.esnaftavar.app
APK_PATH: <USER_HOME>/EsnaftavarReleases/w52k-c/1.0.0+2-main-6f765ef/EsnaftaVar-1.0.0+2-w52k-c-main-6f765ef-production-preview.apk
APK_SHA256: 97017d652781c50c2bcb331b442109bdb8d53b1b46f0b8c016f43de04eed581c
APK_SIZE: 89481479
AAB_PATH: <USER_HOME>/EsnaftavarReleases/w52k-c/1.0.0+2-main-6f765ef/EsnaftaVar-1.0.0+2-w52k-c-main-6f765ef-production-preview.aab
AAB_SHA256: acaba6132e92314e22253afd2f57d28e4e8306dfc8245769787b89d38d2d22d7
AAB_SIZE: 68917978
SIGNING_CERT_SHA256: 3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B
SERVICE_ROLE_IN_ARTIFACT: NO
DB_PASSWORD_IN_ARTIFACT: NO
TESTER_UID_IN_ARTIFACT: NO
JWT_IN_ARTIFACT: NO
PUBLIC_CANONICAL_ACTIVATION_PERFORMED: NO
PRODUCTION_WRITE_PERFORMED: NO
PHYSICAL_INSTALL: NOT_RUN
READY_FOR_W52K_D_PHYSICAL_CANONICAL_SMOKE: YES
```

Only the version change and these sanitized evidence files belong in Git. Absolute local user paths, key values, credentials, session identifiers and APK/AAB binaries are excluded.
