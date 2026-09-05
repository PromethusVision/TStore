# W50 Customer V1 release gate ledger

Status: **LOCAL HARDENING COMPLETE; DISTRIBUTABLE RC BLOCKED BY LOCAL INPUTS**.
Base: `26b78e0bad764d5a160320f2027db36cd3d6196d`.
Branch: `astra-release/w50-customer-v1-release-gate`.
Validated runtime/test source: `a62f7f97860aec9d908eb3b7f4831723c000371e`.
First retained observation: 2026-09-05 16:30:05 UTC.

Final UI remains complete: 56 stable IDs / 57 active compositions, zero remaining
conversion units. All 17 W50 phases were addressed. Fifteen local audit/fix/evidence
phases are closed; phase 13 packaging is blocked by signing/configuration and
phase 14 install is manual. Those two phases are not counted as successful execution.

## Exact truth ledger

| ID | Classification | Evidence / remaining closure |
|---|---|---|
| G01 | PASS | Clean start, correct CLEAN root/common Git repository, fetched base exact. Task-only checkpoints; final Git truth in result. Protected old TStore untouched |
| G02 | PASS | All 23 supported domains pass local journey/failure contracts; [smoke matrix](W50_CUSTOMER_JOURNEY_SMOKE_MATRIX.md) discloses actual entry points and tests |
| G03 | PASS | Full suite 2058 PASS / 0 FAIL / 6 unchanged conditional live skips; 34 added tests; 174 discovered test files; analyzer clean |
| G04 | PASS | Production/Development namespaced configuration and callbacks remain separate; no Development fallback/server credential accepted; no backend runtime request performed |
| G05 | PASS | Home/Details experiments and Reward off; canonical opt-in does not call proof loader. Three historical visualPrototype=true values select approved real-data Final UI, explicitly reconciled in smoke matrix |
| G06 | PASS | No Ads/payment/online fulfillment engine activated. Cart and QR remain physical preparation and merchant verification |
| G07 | PASS | QR → merchant confirmation → verified purchase → rating/review client/storage contracts preserved. Not physical two-device acceptance |
| G08 | PASS | Typed navigation, foreign/malformed URI rejection, session/guest guards, unavailable notification target and duplicate-action protection covered |
| G09 | PASS | Current-text secret/PII logging scan found no real credential/PII leak; scope/candidates below. No environment or signing material in Flutter assets/Git |
| G10 | PASS | Merged Android manifest: com.esnaftavar.app, 1.0.0+1, min/target SDK 24/36; compileSdk 36; exported/permission audit in build evidence |
| G11 | PASS | Three-ABI release AOT/native/resources compile and Android Lint pass; 12/12 merged 64-bit native libraries meet ELF 16KB alignment. APK ZIP/device compatibility not inferred |
| F01 | FIXED_IN_W50 | Main Android manifest disables competing Flutter deep-link handler, retaining exact app-owned app_links validator; platform/Auth tests pass |
| F02 | FIXED_IN_W50 | Main manifest + backup_rules.xml + data_extraction_rules.xml exclude session/PKCE/cache backup and transfer; explicit cleartext denial; merged resources/Lint prove wiring |
| F03 | FIXED_IN_W50 | Camera hardware optional, so retained scanner permission cannot require a camera for Customer installation. Customer does not request camera |
| F04 | FIXED_IN_W50 | ProductionReleasePreflight + safe mobile example accept exact owner-final mobile Site URL with explicit empty web field; 12 new tests, old web restrictions preserved |
| F05 | FIXED_IN_W50 | Android build.gradle binds requested release flavor to canonical Dart entrypoint; rejects aggregate packaging without flavor. Real Gradle mismatch checks and valid compilation pass |
| F06 | FIXED_IN_W50 | .gitignore protects conventional local release manifests and keystores globally; safe example JSON remains tracked |
| F07 | FIXED_IN_W50 | gradle.properties disables obsolete Jetifier after verified AndroidX compilation, resolving Byte Buddy class-version failure in Lint's plugin test model |
| F08 | FIXED_IN_W50 | Base launch styles plus v28/v29 day/night resources move unsupported API attributes to correct qualifiers; four real Android Lint errors fixed |
| F09 | FIXED_IN_W50 | ProductImageSlider/SelectedProductImage/OtherSameProductsList no longer substitute another product's sample photo. Neutral fallback, accessible label, valid-photo preservation and two inspected proofs |
| F10 | FIXED_IN_W50 | Help FAQ names actual QR kod oluştur action and states refund submission is unavailable; FAQ interaction and existing Account goldens pass |
| R01 | RELEASE_BLOCKER | android/key.properties absent in both known CLEAN checkouts; APK/AAB packaging stops. Owner supplies existing approved secure signing material, without creating/debug-signing a substitute |
| R02 | RELEASE_BLOCKER | No approved namespaced client-only Production manifest supplied or present at conventional local paths. Synthetic fixture is non-deployable. Owner supplies/validates config outside Git; remote revalidation needs separate authority |
| M01 | MANUAL_PHYSICAL_GATE | No connected Android device/configured emulator. Fresh signed install/launch, callbacks, location, backup/transfer and 16KB runtime checks remain in runbook |
| M02 | MANUAL_PHYSICAL_GATE | Two physical devices and independent Merchant counterpart not available/used; complete [QR runbook](W50_PHYSICAL_QR_ACCEPTANCE_RUNBOOK.md) on a separately authorized environment |
| D01 | MERCHANT_DEPENDENCY | No current accepted Merchant pilot build/operations evidence supplied. Legacy scanner source and Customer tests cannot certify Merchant readiness |
| D02 | PROFESSIONAL_REVIEW | Legal entity/contact, collection/retention/deletion, overseas providers, consent and immutable evidence disclosures require review; exact list in [gap matrix](W50_COMMERCIALIZATION_GAP_MATRIX.md) |
| D03 | OWNER_DECISION | Support email technically exposed; mailbox ownership/delivery/staffing/escalation and physical returns/disputes need an operational owner |
| D04 | STORE_DEPENDENCY | Fresh signed artifact, certificate/version allocation, console eligibility, listing/privacy/SDK declarations and pre-launch results; no upload or store account inspection |
| D05 | OWNER_DECISION | Product Owner chooses pilot scope and launch only after separate Customer, QR, Merchant, legal/support/store gates close |
| P01 | POST_PILOT | Reward/coupon economics, Ads, taxonomy activation and refund submission deferred; no unsupported system enabled |
| P02 | POST_PILOT | Dormant scanner/ML Kit footprint, unused example assets, licensing/size review and isolated legacy widgets disclosed; no remote demo/seed deletion |
| P03 | POST_PILOT | Dependency updates, plugin Groovy deprecations, 16 resource warnings and SDK-generated AOT hardening follow-up; no demonstrated remaining compile blocker/reported affected package advisory |

Only **R01/R02** are remaining local Customer artifact blockers. Physical,
Merchant, legal, support, store and commercial acceptance are separate gates.
No safe in-scope runtime/build defect found was left as an audit-only recommendation.

## Scan and runtime data

The local scan covers current tracked text and W50 additions, not Git history or
ignored credential stores. It checks private-key headers, server tokens/JWTs,
GitHub/AWS patterns, sensitive filenames, runtime email/phone literals, diagnostic
sites, demo/fixture/localhost and TODO/FIXME/HACK markers. Reports contain paths
and line numbers, never matched secrets. No runtime TODO/FIXME/HACK blocker found.

- One server-key-shaped match is an existing synthetic negative test in
  `test/unit/core/production_release_preflight_test.dart`; no real credential.
- Five runtime email occurrences are the same public support address in
  KVKK/Terms/Help. Two phone-shaped literals remain in the unbound legacy
  user_addresses_view.dart (lines 42/49); no ownership is inferred and their
  values are not reproduced. No hardcoded private contact/test login in active UI.
- 54 diagnostic declarations/calls inspected. Shared loggers are disabled in
  release; HTTP diagnostics omit URLs/headers/bodies/messages. The legacy
  PlatformExceptionHelper interpolates an exception but has no runtime caller
  and uses the disabled logger. It was not activated.
- Marker candidates include defensive fixture rejection, fromDemo parsing
  boundaries/comments and the inactive device utility's example.com helper.
  No hardcoded dev endpoint or fixture repository is used by Production bootstrap.
  The real active sample-photo fallback was fixed in F09.
- Old Store/Orders/address/location/review widgets and standalone Seller Comparison
  remain excluded. The generic illustrated profile avatar is not a fake customer
  photograph. Existing Development seed assets/content are not deleted or treated
  as current live Production truth.

This is a scoped repository gate, not a penetration-test/legal certificate.
Final scan counts and baseline-preservation proof are in the result and ignored
local machine-readable audit files.

## Narrow Android Lint classification

One exact-message exception in `android/app/lint.xml` covers only Geolocator's
unused BackgroundNotification class. Customer uses one-shot ordinary
LocationSettings, no foreground-notification configuration or background stream.
A new architecture test guards that condition. No global permission check,
assertion, test or lint severity is disabled. Actual OS push/background tracking
must remove/reassess the exception. Lint ends at 0 errors / 16 resource warnings.
[Build evidence](W50_ANDROID_RELEASE_BUILD_EVIDENCE.md) retains all earlier failures.

## Shared ownership and integration

W50 owns release configuration, three media widgets and Help/preflight changes.
Exact shared paths: `android/app/build.gradle`, `android/gradle.properties`,
main Android manifest/resources/Lint config, `.gitignore`,
`lib/core/supabase/production_release_preflight.dart`, and
`lib/features/shop/presentation/widgets/product_image_slider.dart`,
`selected_product_image.dart`, `other_same_products_list.dart` in that directory.
Consumers include both Android flavors, Auth callbacks, Product Details and the
unbound Seller Comparison media consumer. Existing/new tests and full suite pass.

No Auth/session architecture, navigation map, global provider/theme token,
backend/schema/migration, QR protocol, review eligibility or dependency version
changed. Media fallback and Help truth are the only visible Flutter changes.
All 243 pre-W50 PNGs remain exact; two proofs added. No unresolved shared-file
collision is known. Final fetch/main delta and clean task-branch push are recorded
in the result. Worker does not merge main.
