# W52L-D final signed Production public canonical build

Signed APK and AAB **1.0.0+3** are frozen from authoritative main `4cc2bcf4ce80198218e978c43eef9685aafaf504` plus the version-only change in `pubspec.yaml`. The build selects **PRODUCTION_PUBLIC_CANONICAL**. It requires public activation ON to show the canonical customer application. Production was not accessed in this wave.

## Build and runtime contract

- Branch: `astra-release/w52l-d-final-public-canonical-build`.
- Reviewed W52L-B recipe: production flavor, `lib/main_production.dart`, release mode, `ESNAFTAVAR_PRODUCTION_CANONICAL_PUBLIC=true`, `ESNAFTAVAR_PRODUCTION_CANONICAL_PREVIEW=false`.
- Exact project: `mefhfvrgkwciubeajjeb`. The existing external six-field Production client config was validated structurally and used unchanged; publishable-key values are omitted from evidence.
- Existing external signing configuration and keystore were used unchanged. Package `com.esnaftavar.app`, versionName `1.0.0`, versionCode `3`. Repository release evidence previously reached versionCode 2; no downgrade was made.
- Public runtime and public read-facade capabilities must both pass. The client validates the canonical contract, 24 public roots, public activation ON, preview OFF, and no tester/preview requirement. It uses the public product/listing/shop RPCs and revalidates reads.
- While public activation is OFF, the controlled unavailable gate displays: “Katalog şu anda kullanılamıyor. Lütfen tekrar deneyin.” Customer content stays gated; no legacy, Development or private-preview fallback is selected.
- No tester account, allowlist lease or Auth session is required for the public catalog gate. No Auth login/refresh or allowlist renewal was performed for this build.
- Application/runtime code, dependencies, UI and all migrations (including 0012/0013/0014/0015) are unchanged. The only source edit is version `1.0.0+2` → `1.0.0+3`.

## Validation

- Targeted tests with public=true and preview=false: **203 PASS / 0 FAIL / 0 SKIP**, 26 files. Coverage includes runtime selection, mutually exclusive flags, capability verification, OFF denial, no fallback, taxonomy, product scope/detail/search, gated-product rejection and customer widgets.
- Supplemental local fixture checks: **6 PASS / 0 FAIL / 0 SKIP** for seller/shop customer reads, pagination, server-excluded sellers, public OFF after authorization, corrupt mapping, and inactive/duplicate shops. Owner-repository fallback was forbidden. These ignored local build checks use no backend and do not alter the application or the full-suite count.
- Full Flutter suite: **2177 PASS / 0 FAIL / 6 existing SKIP**. Skip identities exactly match main's W52L-B baseline. No assertions were weakened; no skips were added.
- `git diff --check` and exact-value/pattern secret/PII scan: **PASS**. Only the version and two evidence files are included.
- Analyzer: **PASS**, no issues. Local config preflight and external signing private-key challenge: **PASS**.
- All three ABIs in both artifacts contain the exact approved Production URL/client key and the four public read-facade RPC markers. Public OFF/capability gate markers are present; the private-preview authorization entrypoint marker is absent.
- Development URL, key define, opt-in and callback are absent. The bare Development project-ref constant remains in the existing reject-Development guard; it is not a network target or fallback.
- APK package/version/signature and 16 KiB ZIP alignment: **PASS**. AAB manifest and JAR signature: **PASS**. Both use the pinned upload certificate; all 64-bit native libraries pass 16 KiB ELF alignment.
- Exact signing passwords and locally cached tester identities/tokens were checked for exclusion without printing them. No service-role/server key, JWT, private-key block, database-credential assignment, packaged config/keystore/test fixtures or unintended endpoint was found. No database password was supplied to the build. The expected client publishable key is embedded in the client artifacts and never copied into evidence.
- AAB verification retains the usual self-signed upload-certificate, PKIX-chain, missing-timestamp and JarInputStream/JarFile-view warnings. Independent JarFile verification checked **549** payload entries against the pinned certificate, with zero unsigned entries and zero duplicate names. Store acceptance is not claimed.

## Frozen artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| APK | 89596167 | `04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64` |
| AAB | 68935754 | `17e361684eab4aea6432bfa47a00af543777107c8bf7d0ccd472341b9e77cc79` |

- APK: `<USER_HOME>/EsnaftavarReleases/w52l-d/1.0.0+3-main-4cc2bcf/EsnaftaVar-1.0.0+3-w52l-d-main-4cc2bcf-production-public.apk`.
- AAB: `<USER_HOME>/EsnaftavarReleases/w52l-d/1.0.0+3-main-4cc2bcf/EsnaftaVar-1.0.0+3-w52l-d-main-4cc2bcf-production-public.aab`.
- Signing certificate SHA-256: `3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B`.
- Frozen UTC: `2026-09-24T22:11:49.653466+00:00`. Copies were hash/size verified and marked read-only. Local `SHA256SUMS.txt` and `verification.json` accompany them outside Git.
- Tracked source fingerprint (LF-normalized text): `777d60b4695e2b9f77059ea9ee0d7694802c33b05ba8d84c86e1b3b423c3150d`. Source/config/signing inputs were stable throughout the build.

## Physical check and activation boundary

**PHYSICAL_PUBLIC_OFF_CHECK: NOT_RUN** — no ADB-connected device was available. No APK was installed, and no physical launch/crash/ANR result is claimed; CRASH and ANR are therefore NOT_RUN rather than inferred NO. OFF behavior is verified by automated tests and static artifact checks.

The supplied W52L-C live baseline records 0012/0013/0015 applied, 0014 not applied and public activation OFF. This build did not re-query or change that state. Build readiness for a separate 0014 activation decision is YES; activation and any live smoke remain separate authorized steps.

## TASK_RESULT

```text
W52L_D_FINAL_PUBLIC_CANONICAL_BUILD: PASS
AUTHORITATIVE_MAIN: 4cc2bcf4ce80198218e978c43eef9685aafaf504
PRODUCTION_PUBLIC_RUNTIME: PASS
PUBLIC_OFF_FAIL_CLOSED: PASS
NO_LEGACY_FALLBACK: PASS
NO_DEVELOPMENT_FALLBACK: PASS
NO_PRIVATE_PREVIEW_REQUIREMENT: PASS
FULL_FLUTTER: 2177 PASS / 0 FAIL / 6 SKIP
ANALYZER: PASS
VERSION_NAME: 1.0.0
VERSION_CODE: 3
PACKAGE: com.esnaftavar.app
APK_PATH: <USER_HOME>/EsnaftavarReleases/w52l-d/1.0.0+3-main-4cc2bcf/EsnaftaVar-1.0.0+3-w52l-d-main-4cc2bcf-production-public.apk
APK_SHA256: 04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64
AAB_PATH: <USER_HOME>/EsnaftavarReleases/w52l-d/1.0.0+3-main-4cc2bcf/EsnaftaVar-1.0.0+3-w52l-d-main-4cc2bcf-production-public.aab
AAB_SHA256: 17e361684eab4aea6432bfa47a00af543777107c8bf7d0ccd472341b9e77cc79
SIGNING_CERT_SHA256: 3B:83:D9:8A:B8:D3:2E:0F:3B:99:30:FA:83:76:36:E0:E9:E1:32:19:78:4F:FC:A3:9C:EF:8C:AE:82:A6:66:9B
SERVICE_ROLE_IN_ARTIFACT: NO
DB_PASSWORD_IN_ARTIFACT: NO
TESTER_UID_IN_ARTIFACT: NO
JWT_IN_ARTIFACT: NO
PHYSICAL_PUBLIC_OFF_CHECK: NOT_RUN
CRASH: NOT_RUN
ANR: NOT_RUN
PRODUCTION_WRITE_PERFORMED: NO
PUBLIC_CANONICAL_ACTIVATION_PERFORMED: NO
READY_FOR_0014_PUBLIC_ACTIVATION_DECISION: YES
```

Git scope is the version change and these two sanitized evidence files only. No binary, secret, tester identifier, device serial or absolute local user path is included.
