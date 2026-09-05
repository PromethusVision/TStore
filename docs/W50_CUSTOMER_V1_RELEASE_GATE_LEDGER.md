# W50 Customer V1 release gate ledger

Status: IN PROGRESS. Repository/local assessment only; no deployment approval.
Base: `26b78e0bad764d5a160320f2027db36cd3d6196d`.
Branch: `astra-release/w50-customer-v1-release-gate`.
First retained observation: 2026-09-05 16:30:05 UTC.

## Scope and evidence boundaries

All 17 requested phases are in scope: release truth; repository hygiene; flags;
Android; Auth/deep links; journeys; physical-commerce language; QR/reviews;
failure states; runtime data; privacy/support; dependencies; release build;
install/launch; final quality gates; crash/performance sanity; commercialization.
The 2024 PASS / 0 FAIL / 6 conditional-skip W49 baseline is historical until
W50 executes its own combined gate. The 56 Final UI IDs / 57 compositions remain
closed. Existing inactive routes and SellerComparisonView are not activated.

No Production request or Development write is authorized. Local synthetic
compile configuration is not deployable configuration. No signing keys are
created, rotated, copied or exposed. Only this task branch is published.

## Initial verified findings

| ID | Classification | Exact evidence and consequence |
|---|---|---|
| G01 | PASS | Clean starting worktree; fetch confirms the exact base above. |
| G02 | RELEASE_BLOCKER | `android/key.properties` absent in this worktree and canonical CLEAN checkout. Historical signing evidence does not establish current local availability. Release APK attempt stops at the existing fail-closed Gradle signing guard. |
| G03 | RELEASE_BLOCKER | No `tool/production_release_config.json` in either checkout. The committed synthetic compile fixture is explicitly rejected by deployable-release preflight. No credential search/decryption is undertaken. |
| G04 | MANUAL_PHYSICAL_GATE | `flutter devices --machine` finds Windows and browsers only; `flutter emulators` reports no emulator. Android install/launch and real two-device QR acceptance cannot be claimed. |
| G05 | RELEASE_BLOCKER | Main Android manifest lacks `flutter_deeplinking_enabled=false` while `SupabaseService` owns validated callbacks through `app_links`; competing Flutter route handling needs correction and regression proof. |
| G06 | RELEASE_BLOCKER | Android manifest leaves backup at the platform default and has no extraction exclusions. Persisted Auth/session data must be excluded from cloud backup and device transfer. |
| G07 | PROFESSIONAL_REVIEW | KVKK/Terms are reachable, versioned local documents. Legal entity, retention, overseas transfer, consent and rights handling require professional validation; source text is not certification. |
| G08 | MERCHANT_DEPENDENCY | Customer QR code contracts do not prove a released Merchant app or a physical two-device exchange. |
| G09 | STORE_DEPENDENCY | No store upload or current Play Console inspection is authorized. Version allocation, approved signing, listing and declarations remain external. |
| G10 | OWNER_DECISION | Support address is selectable `info@esnaftavar.com`; mailbox operation, staffing and response handling are not proven by the app. |

## Shared ownership

Android manifest/build configuration is a release-wide consumer. W50 owns only
the scoped hardening delta on this branch; all Auth/QR/rating business contracts
remain unchanged. Main and remote branch deltas will be checked before delivery.
Central coordination documents and the calibration log are not rewritten.

Final classifications, exact tests, artifacts, fixes and remaining gates will
replace this in-progress evidence after validation.
