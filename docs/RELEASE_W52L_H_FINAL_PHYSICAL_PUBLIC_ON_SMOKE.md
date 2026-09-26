# W52L-H: final physical public-ON customer smoke

**PASS. The exact frozen public APK passed the physical customer checklist on
POCO X7 Pro. The Customer V1 public canonical acceptance gate is PASS.**
Production remained ON; no Production write or rebuild was performed.

- Authoritative main: `b9614de6342273067b14437cf0e34eca9141229c`.
- Evidence branch: `astra-release/w52l-h-final-physical-public-on-smoke`.
- Production: `mefhfvrgkwciubeajjeb`.
- [Structured evidence](data/w52l_h_final_physical_public_on_smoke_validation.json).

## Frozen client and physical installation

The APK SHA-256 was verified before installation and read back from the installed
package afterward. APK signature and package identity passed in both checks.

- APK SHA-256: `04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64`.
- Package/version: `com.esnaftavar.app`, `1.0.0+3`; release, not debuggable.
- Certificate SHA-256: `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- Runtime: `PRODUCTION_PUBLIC_CANONICAL`; public define true, preview define false.
- Device: POCO X7 Pro, `2412DPC0AG`, Android 16 / SDK 36, physical and ADB-authorized.
- Install: replacement with `--no-incremental -r`; existing app data preserved.
- No uninstall, data clear, downgrade, rebuild or re-signing.

Current Flutter/Android implementation and dependency lock matched frozen source
`4cc2bcf4ce80198218e978c43eef9685aafaf504`. The only pubspec difference was the previously
reviewed W52L-D version bump from 1.0.0+2 to 1.0.0+3. No source was edited here.

## Physical acceptance

The agent launched the installed APK and directly observed the Home accessibility
tree: eight real root cards, the All Categories link, and no OFF/unavailable gate.
Personal greeting text was omitted and no Home screenshot was stored.

The Product Owner then completed the single grouped physical checklist and
reported **“tüm checklist başarılı”**. This confirms:

| Physical check | Result and evidence |
| --- | --- |
| Launch, Home, maximum eight roots | PASS; direct device observation |
| All Categories, all 24 roots | PASS; owner physical checklist |
| L2 / L3 / L4 | PASS; Gıda & İçecek → Bakliyat, Tahıl & Makarna → Bakliyat → Mercimek |
| Breadcrumb and back navigation | PASS; owner physical checklist |
| Search and product listing | PASS; USB search and results |
| Product details and seller comparison | PASS; owner physical checklist |
| Shop details | PASS; owner physical checklist |
| Login/private-preview requirement or unavailable gate | Absent throughout the checklist |
| Endless loading, crash or ANR/freeze | None reported; app remained foreground/running |

Product-image placeholder status was not separately reported. No additional image
quality claim or design change is included in this acceptance result.

Post-smoke app-UID-filtered logs covered the launch/test window: **2116
lines**, zero selected error classes and zero database error codes. Raw logs and
device serials were not stored. The foreground check confirmed the app was open
and the phone unlocked after the owner's report.

## Public policy and target verification

Anonymous Production HTTP checks passed before and after physical navigation,
without an Auth session, tester identity or preview lease. Both checks independently
confirmed the complete published category set and exact eligible/gated product sets:

| Read-only check | Before | After |
| --- | --- | --- |
| Public canonical ON | PASS | PASS |
| Public roots | 24 | 24 |
| Published nodes | 325 | 325 |
| Assignable leaves | 247 | 247 |
| Eligible products visible | 14/14 | 14/14 |
| Gated product/details/listing access excluded | 6/6 | 6/6 |
| Public facade and customer read contracts | PASS | PASS |
| Anonymous GET responses | 86 × HTTP 200 | 86 × HTTP 200 |

The facade exposed 198 eligible listing rows and 57 active shops. Its published
scope is distinct from the prior full-database baseline of 285 listing rows.
The current migration ledger and full-table totals were not queried in this wave;
W52L-G remains the prior ledger/data-integrity evidence. No DB password was needed.

Public customer API checks included L2/L3/L4, breadcrumb, exact leaf, alias/search,
all 14 product details and seller sets, all six gated product/listing denials,
and shop reads. They used only the approved Production hostname.

The preserved phone Auth session state was not inspected or changed, and no
login/logout was requested. No tester dependency is supported by the absence of
a phone login/preview gate, the frozen public client contract and successful
anonymous server reads. No legacy, Development or preview fallback was observed.
The verified source rejects a different Production host and fails closed rather
than falling back. App logs did not emit a hostname; no packet-capture proof is
claimed.

## Scope, quality and next gates

No purchase, order, review, QR confirmation, favorite/profile or catalog mutation
was requested. No migration, backup, rollback, policy/allowlist modification or
preview bridge removal was performed. Production remains public canonical ON.

Only these two sanitized evidence documents are committed. No credentials, JWT,
UID, private connection details, personal data, device serial, absolute local user
path, raw log, APK or AAB is included. Secret/PII and committed-diff checks apply
to both files. No Flutter build/analyzer was needed for evidence-only changes.

The prerequisite for a separate private-preview cleanup task has passed; **0013
has not been removed**. The project is ready to begin a separately scoped QR
two-device gate; **that gate has not been run**. No new Production action is
authorized or performed by these readiness statements.

## TASK_RESULT

```text
W52L_H_FINAL_PHYSICAL_PUBLIC_ON_SMOKE: PASS
AUTHORITATIVE_MAIN: b9614de6342273067b14437cf0e34eca9141229c
APK_SHA256: 04d71bfd25920c171fd25f27416ee22f74f851608bb3c79b1561dc4966827f64
APK_IDENTITY: PASS
DEVICE_CONNECTED: YES
INSTALL_UPGRADE: PASS
APP_LAUNCH: PASS
PUBLIC_CANONICAL_ON: PASS
OFF_UNAVAILABLE_GATE_ABSENT: PASS
NO_TESTER_DEPENDENCY: PASS
NO_PRIVATE_PREVIEW_DEPENDENCY: PASS
HOME: PASS
HOME_ROOT_LIMIT_8: PASS
ALL_CATEGORIES: PASS
ROOTS_24_24: PASS
L2_NAVIGATION: PASS
L3_NAVIGATION: PASS
L4_NAVIGATION: PASS
BREADCRUMB: PASS
PRODUCT_LISTING: PASS
PRODUCT_DETAILS: PASS
SELLER_COMPARISON: PASS
SHOP_DETAILS: PASS
SEARCH: PASS
BACK_NAVIGATION: PASS
ELIGIBLE_PRODUCTS: 14/14
GATED_PRODUCTS_EXCLUDED: 6/6
LEGACY_FALLBACK_OBSERVED: NO
DEVELOPMENT_FALLBACK_OBSERVED: NO
PRIVATE_PREVIEW_FALLBACK_OBSERVED: NO
ENDLESS_LOADING: NO
CRASH: NO
ANR: NO
PRODUCTION_WRITE_PERFORMED: NO
CUSTOMER_V1_PUBLIC_CANONICAL_GATE: PASS
READY_FOR_PHYSICAL_SMOKE_EVIDENCE_INTEGRATION: YES
READY_FOR_PRIVATE_PREVIEW_CLEANUP: YES
READY_FOR_QR_TWO_DEVICE_GATE: YES
```
