# ASTRA W52C — Corrected Production Key / Signed RC Result

2026-09-13. **PASS: corrected Production key accepted, new signed APK/AAB
built and frozen.** Production access was anonymous read-only. No Production
write, Auth action, store upload, device install or device launch was performed.
The old W51E APK is historical evidence and must not be used for further
Production smoke.

The owner corrected the external client key before this task. This task did not
edit the client config, signing properties or keystore. No credential value was
printed, copied into source, or committed.
Machine-specific absolute paths below are anonymized. The APK/AAB files and
external configuration/signing inputs are not included in the repository.

| Production gate | Fresh W52C evidence |
|---|---|
| Exact target | `mefhfvrgkwciubeajjeb` / `https://mefhfvrgkwciubeajjeb.supabase.co` |
| Local config | Existing release preflight PASS; exact six string fields, correct URL/ref, publishable format, no placeholder/server-only key/Development config |
| Smallest public read | `categories?select=id&limit=1`: HTTP 200, 1 returned row, no error |
| Exact application query | `categories?select=*&is_active=eq.true&order=sort_order.asc`: HTTP 200, 4 returned rows, no error |
| Remote identity | Both responses matched the exact Production project-ref header |
| RLS/permission | PASS for these anonymous category SELECT requests |
| Schema contract | PASS for the current application's category query; not a claim about every database contract |
| Initial pre-build checks | 18:56:28.810 / 18:56:29.057 UTC, before source preparation/build |
| Build-input-bound checks | 19:01:13.292 / 19:01:13.406 UTC; same config bytes retained and compared throughout the pipeline |
| Total Production operations | Four GET requests: the two checks above at each of the two gates; no user session, rows or headers recorded |

The corrected key resolves the previous `401 Invalid API key` blocker. The
current application contract was read from the exact release source, including
`is_active=true` and ascending `sort_order`. Development was not contacted.

`git fetch origin --prune` completed against the existing canonical origin.
The exact source selected for the new builds was:

```text
SOURCE_MAIN_COMMIT: 4f0da8201e2571200e99fa3dfe76387e3a1486ce
W51E_SOURCE_COMMIT: 6a1cf14639124bf709c6a988b9e8290ac7757c60
TASK_BRANCH: codex/w52c-production-key-signed-rc
WORKTREE: <local-worktree>/TStore_W52C
```

All three commits after the W51E source were inspected: `0500c30` (W51E
evidence), `1ea0f5e` (its merge), and `4f0da82` (W51F evidence). Their combined
delta is six Markdown files under `docs/`. Runtime, Android, dependencies,
assets, config source and tests are unchanged. Current main is binary-source-
equivalent to W51E; the owner-corrected external publishable key intentionally
changes the new binary's configuration.

Build preparation used cached dependencies with `--offline --enforce-lockfile`.
Only ignored SDK/wrapper/helper files were prepared. Generated plugin file
contents were verified equal to Git before refreshing their line-ending/index
state. No application source or test edits were needed.

| Source integrity checkpoint | UTC | Result |
|---|---|---|
| Initial | 19:01:11.956 | Exact source commit, CLEAN |
| APK build start | 19:05:54.140 | Same source and tracked-file content digest, CLEAN |
| APK/AAB build end | 19:08:33.756 | Same source and tracked-file content digest, CLEAN |
| Freeze | 19:09:37.643 | Source and output digests rechecked |

All checkpoints used Git tree `152e047331c8aa6e587b35da2aa80d7632d3e55c` and
tracked working-file digest
`777220f8f9127acdb3510e40287c792614fddfc4fb01be8f4da45f3421beb15b`.
The external config, signing properties and keystore remained byte-identical
during the build pipeline. The later evidence-only commit does not change the
binary source.

Signing used only the existing external files:

- `<external-signing>/key.properties`
- `<external-signing>/esnaftavar-upload.jks`
- Alias: `esnaftavar-upload`.

The existing private key passed a random challenge sign/verify check. Its
certificate is valid until `2054-01-03T01:08:21Z`. Both actual artifacts matched
the expected certificate SHA-256:

```text
3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B
```

The release used `lib/main_production.dart`, `AppEnvironment.production`,
explicit `production` flavor and release mode. Production namespaced defines
came only from the approved external JSON. The callback remains
`com.esnaftavar.app://login-callback/`; mobile-only Site URL matches, and web
redirect is explicitly empty. Canonical preview, experimental fixtures, test
runtime and Reward economics remain off; approved real-data Final UI defaults
and safe release logging remain intact.

| Validation | W52C result |
|---|---|
| Existing release config preflight | PASS before build |
| External signing/private-key proof | PASS, 51.172 seconds |
| Release/signing/config/Auth/deep-link/default/fixture/asset targeted matrix | 153 PASS, 0 FAIL, 0 SKIP; 16 files; 27.671 seconds |
| `flutter analyze --no-pub` | No issues found; 22.4 seconds reported by analyzer |
| Full `flutter test --no-pub --reporter=json` | 2065 PASS, 0 FAIL, 6 unchanged conditional skips; 86.469 seconds |
| Full suite coverage | 175/175 test files executed; all 245 golden PNGs retained |
| Android `lintProductionRelease` | PASS, 0 errors, 16 existing warnings; 91.078 seconds |
| APK build | PASS, 19:05:54.141 → 19:08:01.721 UTC; 127.594 seconds |
| AAB build | PASS, 19:08:02.369 → 19:08:33.385 UTC; 31.016 seconds |
| APK signature / identity | PASS; one signer, expected certificate, package/version, debug signing OFF |
| APK/native alignment | ZIP 16 KB and all 64-bit native ELF LOAD segments PASS |
| AAB signature / identity | Jarsigner verification and independent certificate check PASS |
| Independent AAB payload verification | 548 signed entries; 0 unsigned payload, 0 duplicate names; all payload certificates match |
| Actual signing-password scan | 1089 expanded archive entries, UTF-8 and UTF-16LE; 0 matches |

The six existing skips match W51E by name: two Development Auth/RLS tests,
two Development Realtime tests, and two Production live tests. No opt-in was
enabled and no new skip was added. The targeted matrix overlaps the full suite;
these counts must not be summed. Full-suite execution occurred once in W52C.

Jarsigner's existing warning classes remain visible: self-signed upload
certificate, untrusted public PKIX chain, no timestamp, and stream/JarFile
signing-view discrepancy. The independent verifying `JarFile` reader consumed
every payload and checked the pinned signer for every entry. This proves the
local archive integrity; it does not claim Play Store acceptance or upload.

Both actual binaries were scanned independently. All three AOT ABIs contain
the corrected approved publishable key and Production URL, with no old rejected
W51E key. The only embedded configured Supabase URL is Production. No active
Development config, fixture product data, test/mock endpoints, sample product/
banner/review assets, packaged secret/config files, private-key block,
server-secret value or server-role JWT was found. The three approved Home
fallback promo images remain byte-equal to source.

The Development ref and literal `service_role` remain in each `libapp.so` as
the existing fail-closed config rejection guards. They are not active backend
configuration or server credentials. Therefore `NONE` below means no active
config leak and no credential leak, not zero occurrences of these guard words.

New artifacts were copied with exclusive creation into a new W52C folder,
rehashed and marked read-only at **2026-09-13 19:09:37.643 UTC / 22:09:37.643
Türkiye**. No previous output was overwritten.

| Artifact | Frozen evidence |
|---|---|
| APK path | `<release-root>/w52c/1.0.0+1-main-4f0da82/EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.apk` |
| APK SHA-256 | `096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a` |
| APK size | 89,348,517 bytes |
| AAB path | `<release-root>/w52c/1.0.0+1-main-4f0da82/EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.aab` |
| AAB SHA-256 | `275e5e1a367ccc7098c44149110ff977ea3ad1fa6440b9dd75ceefd4611d62bf` |
| AAB size | 68,793,270 bytes |
| Both manifests | `com.esnaftavar.app`, versionName `1.0.0`, versionCode `1`, debuggable OFF |
| Both ABI sets | `arm64-v8a`, `armeabi-v7a`, `x86_64` |
| Adjacent evidence files | `verification.json`, `SHA256SUMS.txt` in the same frozen folder |

The historical W51E APK
`c5d8835832c4d7c050e7da85b4074813a5a99f15ecdd01c00a715693adde037b`
and AAB
`b785374a879dd35641c22114777a8e053565b2b28d6a766489268bf782d7eacb`
were rehashed and preserved unchanged. They are superseded by W52C for all
future Production acceptance. Earlier W51C-R artifacts were also preserved.

The next authorized device task must use the new exact W52C APK above. Device
install/launch must precede phone online smoke, and physical two-device QR
acceptance remains a separate action. These physical gates were not run or
declared passed here. No keystore or key was rotated or created. The protected
old `TStore` repository and other agents' worktrees were not changed.

```text
PRODUCTION_CONFIG_VALID: PASS
PUBLISHABLE_KEY_ACCEPTED: YES
MINIMAL_PRODUCTION_READ: PASS
APP_CATEGORY_QUERY_DIRECT_READ: PASS
CATEGORY_ROW_COUNT: 4
RLS_PERMISSION: PASS
SCHEMA_CONTRACT: PASS

SOURCE_MAIN_COMMIT: 4f0da8201e2571200e99fa3dfe76387e3a1486ce

NEW_SIGNED_APK_CREATED: YES
NEW_APK_SHA256: 096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a
NEW_SIGNED_AAB_CREATED: YES
NEW_AAB_SHA256: 275e5e1a367ccc7098c44149110ff977ea3ad1fa6440b9dd75ceefd4611d62bf

SIGNING_CERT_MATCH: PASS
BINARY_CONFIG_LEAKAGE: NONE_ACTIVE; REJECTION_GUARD_LITERALS_PRESENT
BINARY_SECRET_LEAKAGE: NONE
FULL_TEST_SUITE: PASS
ANALYZER: PASS

PRODUCTION_WRITE_PERFORMED: NO
STORE_UPLOAD_PERFORMED: NO
DEVICE_INSTALL_PERFORMED: NO

OLD_W51E_APK_SUPERSEDED: YES
NEW_EXACT_APK_FROZEN_FOR_PHYSICAL_GATE: YES
READY_FOR_NEW_DEVICE_INSTALL_LAUNCH_GATE: YES
READY_FOR_PRODUCTION_ONLINE_SMOKE: YES
```

Readiness means the artifact and direct Production read gates are ready; it
does not replace the pending device install/launch or physical smoke evidence.
The only tracked W52C change is this evidence document. Runtime, configuration
source, Android, dependencies, assets, tests and goldens are unchanged. Delivery
is confined to the W52C task branch; no main merge/push is part of this task.
