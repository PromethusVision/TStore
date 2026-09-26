# Customer launcher icon correction — signed 1.0.0+5

**Current final branded Customer V1 release: 1.0.0+5.** The valid signed
1.0.0+4 intermediate release remains historical and is superseded for branded use.

The POCO X7 Pro now displays the owner-selected **official orange V on white**.
The exact frozen signed APK was installed as an in-place upgrade and its on-device
SHA-256 matches the frozen copy. The agent visually verified the launcher icon
after installation. No uninstall, app-data reset or launcher-data reset occurred.

## Cause and correction

The earlier official-brand work updated Flutter Home and native splash resources,
but the native launcher still used the old T-Store icon. Its generator also still
named the legacy source. The +4 evidence's broad no-active-T-Store claim was incomplete:
it checked compiled Flutter text/assets, not Android's actual launcher reference.
The historical +4 evidence is corrected; +5 supersedes it for branded release use.
The existing +4 frozen APK/AAB files remain unchanged.

- `tool/generate_customer_launcher.ps1` derives the owner-selected V from the
  unchanged official source logo, preserves its orange gradient and proportions,
  and uses the already installed launcher generator. It rejects source hash or
  selected component drift. Near-transparent export noise connecting adjacent
  letters is excluded; the source wordmark itself remains byte-identical.
- All five Android legacy densities now use V-on-white. Modern Android gets
  adaptive foreground/background and monochrome layers; the complete V fits the
  central circular safe area. `icon` and `roundIcon` resolve to the same launcher
  resource. Platform masking remains the launcher's responsibility.
- iOS AppIcon resources are generated from the same V-on-white artwork with no
  alpha channel. No iOS binary was built or physical iOS result claimed.
- VersionName stays `1.0.0`; versionCode advances from `4` to `5`. Public
  Production flavor/entrypoint/defines, app behavior, dependencies, official full
  logo and native splash resources remain unchanged.

## Verification

Analyzer: **PASS**. Public-runtime targeted Flutter tests: **512 PASS / 0 FAIL /
0 SKIP**. Full suite: **2243 PASS / 0 FAIL / the same 6 optional/live SKIP**.
No live opt-in was supplied. No test assertion or skip was changed.

The APK audit follows the compiled manifest icon and round-icon resource IDs to
their legacy/adaptive definitions, then resolves foreground, white background
and monochrome references. All **15 native PNG resources per artifact** match
the new sources. Adaptive artwork passes safe-circle checks at every density;
iOS icons are opaque. This explicitly covers the gap in the prior release audit.

APK/AAB package/version, pinned certificate, release/non-debug status, all three
public-runtime ABI markers, no active Development/private-preview fallback,
64-bit native alignment and APK ZIP alignment pass. Exact signing-password and
cached tester-token/identity exclusion checks pass. No server/service-role key,
JWT, private key or database credential assignment was found. Client publishable
key and signing material were read only from the existing external configuration;
values were not printed or committed. No database password was supplied.

AAB signature verification and independent payload verification passed:
**561 signed entries**, zero unsigned or
duplicate entries, all with the pinned certificate. Usual upload-certificate
self-signed/PKIX/no-timestamp/stream-view warnings do not assert store acceptance.
Source fingerprint and external build inputs remained stable through both builds.

## Frozen artifacts

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| APK | 91126405 | `4c49f9ee2d619c12a8ff53dbc93174acf8f5eb1e59fbe7f54d117cfb0e20c5b1` |
| AAB | 70193078 | `95b14f301a5a628971f9ad7725c59c1cc3ee5e5c963b35bd1cbc9057ad0778da` |

- APK: `<USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+5-launcher-icon/EsnaftaVar-1.0.0+5-launcher-icon-production-public.apk`.
- AAB: `<USER_HOME>/EsnaftavarReleases/final-customer-v1/1.0.0+5-launcher-icon/EsnaftaVar-1.0.0+5-launcher-icon-production-public.aab`.
- Package: `com.esnaftavar.app`; version: `1.0.0+5`.
- Certificate SHA-256: `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- Source base: `a8b0b0f3ed1387fff7737b534db3d5c22b376d07`, descending from integrated main
  `f154c2a762065f2d117a2c1292adf5c8db707a40`.
- Source fingerprint: `3f215f83dd8fc8a727c53abdbfd8541886b8e3db00ff84840d67e888a885d046`.
- Frozen UTC: `2026-09-26T19:59:06.821059+00:00`. Copies are verified and read-only outside Git.

## Device and boundaries

POCO X7 Pro upgrade: **PASS**. Installed version/hash: **PASS**. Physical launcher
icon: **PASS**, checked from an app-icon-only crop before and after. Crops remain
local; no device serial or personal full-screen image enters evidence. The agent
did not launch the customer app or repeat a full customer-flow smoke in this task.

Production and Development were not accessed; no backend write or configuration
change occurred. Push provider config remains **PENDING**, 0016 remains
**proposal-only**, real reward economics remain unimplemented, QR two-device gate
stays **OPEN**, and private-preview cleanup is **NOT_PERFORMED**.

Branch: `codex/customer-launcher-icon-1.0.0+5`. Only launcher resources/generator,
version and sanitized release evidence are committed. APK/AAB, secrets, device
serials, screenshots and personal absolute paths are excluded. No main merge or
force push is part of this task.

## Main integration validation

Integration branch: `integration/final-customer-v1-1.0.0+5`.
Starting main: `f154c2a762065f2d117a2c1292adf5c8db707a40`.
The exact source chain is main → `a8b0b0f3ed1387fff7737b534db3d5c22b376d07`
→ `1196ab853a3b0b2a41bfc3b80f4cd66de0f8d0cb`, with no divergence or conflict.

Integration reran `flutter analyze --no-pub` with zero issues and the full suite:
**2243 PASS / 0 FAIL / the same 6 existing optional/live SKIP**. No test or
application Dart source changed. All 47 incoming paths match the reviewed release
scope. Both commits were scanned for secrets/PII, including PNG metadata across
50 distinct file versions; no secret or personal-data finding remained. The only
email-pattern matches were AppIcon filenames containing size/scale notation.
`git diff --check` passed.

The existing local +5 APK/AAB hashes, sizes, package/version and pinned signing
certificate were independently verified. APK signature verification and AAB JAR
verification passed; the already documented AAB upload-certificate/stream-view
warnings remain, without any claim of store acceptance. The compiled APK icon
and roundIcon resolve to the reviewed legacy/adaptive resources. All 15 launcher
PNGs in each artifact match source alpha and rendered pixels. Five adaptive
densities fit the safe circle, their monochrome masks match, and all 25 iOS
catalog entries resolve to correctly sized opaque icons. The official full logo
is unchanged. Existing +4 APK/AAB hashes also still match their historical evidence.

Integration changes beyond the source commit are documentation only, preserving
the frozen +5 binary inputs. No launcher regeneration, APK/AAB rebuild, +6 version
bump, device installation, app launch or remote operation was performed here.
POCO X7 Pro upgrade/hash/icon acceptance is recorded from the source evidence;
the separate physical customer-flow smoke is still **NOT_RUN** for this release.

Production public canonical **ON** remains the previously recorded state and was
not remotely queried or changed. Push external configuration is **PENDING**,
0016 is **PROPOSAL_ONLY**, real reward economics is **NOT_IMPLEMENTED**, the QR
two-device physical gate is **OPEN**, and private-preview cleanup is
**NOT_PERFORMED**. The earlier no-main-merge statement describes the source task;
this integration advances main with the reviewed +4/+5 chain.
