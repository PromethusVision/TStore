# W50 physical QR and signed-device acceptance runbook

Current status: **MANUAL_PHYSICAL_GATE — NOT EXECUTED**.
This document is a future acceptance procedure, not authorization to access
Production or write Development during W50. A later owner must explicitly name
the permitted pilot environment/accounts/operations before this procedure runs.

## Entry requirements and evidence sheet

The release owner supplies an approved, namespaced client-only configuration
and existing signing material through secure local files. No password/token is
pasted into a task, log or report. Run release preflight, build the specific
Production flavor/entrypoint, verify the signing certificate and record the
fresh package hash. The W50 synthetic fixture and August 23 packages are not
acceptable substitutes. Use an independently ready Merchant counterpart for the
same authorized environment and a different physical device.

Record in restricted local evidence:

| Field | Required record |
|---|---|
| Customer artifact | Source commit, APK name, application ID, version name/code, SHA-256 and signing verification result |
| Merchant counterpart | Source/build/version/hash and owning team; account's actual authorized shop |
| Devices | Customer and Merchant model, Android version; device time/timezone; network state |
| Backend authorization | Environment alias, owner approval reference and allowed mutations/cleanup scope |
| Accounts/data | Logical aliases for customer A/customer B/shop A/shop B; nonpersonal test product identities and expected prices/quantities |
| Scenario results | PASS/FAIL, time, expected/actual outcome and redacted evidence path |
| Sensitive evidence | Mask faces/contact data, QR payload/session token, auth links/codes, credentials and private identifiers in screenshots/logs |

## Signed install, launch and Auth

1. Verify the new package's hash/certificate, install on the intended test device
   without deleting an unrelated app/account. Record installation and launcher
   label; confirm package `com.esnaftavar.app` and the selected version.
2. Cold-launch with no saved session; complete or skip onboarding, reach Home,
   browse/category/search/product/Shop/Nearby and return. Repeat without network:
   app must show recoverable failure/empty state instead of a crash or permanent
   splash. Capture only app-filtered redacted crash output.
3. On the separately authorized backend, use the actual signup/confirmation and
   recovery email flow. Test cold and warm callback opening, expired link and
   wrong environment/malformed callback rejection. Verify one destination, not
   duplicate navigation. Never place a live callback token in a shell command.
4. Test session restore, protected-tab login/cancel/return, logout/expiry cleanup,
   location denial/service-off and Android back behavior. Test the final package
   on a supported older Android device and a current/16KB environment where
   available. Record any untested OS combinations instead of extrapolating.

## Physical transaction and review matrix

| Step | Action | Required outcome |
|---|---|---|
| QR-01 | Customer A adds actual products from shop A, including quantity >1, and chooses **QR kod oluştur** | Displayed shop/items/quantity/total match the current Cart. This creates no payment or completed online order |
| QR-02 | Merchant A scans the displayed QR on the second physical device and explicitly confirms the actual shop transaction | Exactly one accepted verification; customer receives completed state and the purchase becomes visible. Record network/refresh delay actually observed |
| QR-03 | Open Purchases from the completion action, then close/reopen through Account; inspect any related notification | Same verified physical purchase; correct customer/shop/items/amount and bounded target refresh, no duplicate purchase |
| QR-04 | Submit shop rating through the existing completion/eligible transaction flow; attempt duplicate taps and reopen history | One submission in flight; correct verified transaction/score; rated history and failure retry work under the existing contract |
| QR-05 | Navigate to the purchased canonical product through Product Details → Product Reviews | Merchant-confirmed evidence permits the existing product review action. There is no invented direct purchase-item review route |
| QR-06 | Repeat a physical purchase and increase quantity for the same customer/canonical product | Neither repeat purchase nor quantity creates additional active-review rights: at most one active review for that customer/product for life |
| QR-07 | Edit the review, then delete and recreate it through existing controls | Current edit contract works; recreation retains immutable verified purchase evidence. Exact storage identity proof requires separately authorized read access; UI alone cannot prove immutability |
| QR-08 | Customer B or a never-confirmed product attempts the same review flow | No eligibility borrowed from customer A. Legacy `is_verified_purchase=true` without canonical merchant-confirmed evidence must not establish a right |
| QR-09 | Scan a used, expired, cancelled or invalid session, and a session belonging to shop A with Merchant B | Explicit refusal; no second purchase, no rating/review eligibility and no private customer leakage |
| QR-10 | Change price/availability/quantity before QR completion; test expired refresh and offline generation failure | Existing changed-Cart consent/error/retry flow; no acceptance of stale totals, duplicate session or false success |
| QR-11 | Navigate away/back, background/resume and temporarily interrupt connectivity around confirmation | Reconciliation finds the authoritative purchase without inventing success or losing completed evidence |

Eligibility does not expire. A finite physical test cannot establish that rule
for all future time; use the unchanged repository/storage contract and its
regression tests alongside physical evidence. Local code PASS for immutable
evidence, ownership, uniqueness and legacy exclusion already exists; it remains
distinct from the two-device result.

## Exit and stop conditions

Physical QR PASS requires both devices, a ready Merchant build, explicit backend
authorization, a fresh signed Customer artifact, the complete relevant matrix and
retained sanitized results. A single successful scan is insufficient.

Stop the affected scenario on wrong environment/account, duplicate verification,
unexpected eligibility, wrong totals, crash, or disclosure. Preserve evidence and
report the defect; do not change protocol/eligibility or repair live rows ad hoc.
Cleanup must follow the later owner's exact authorized scope. Unexecuted rows
remain MANUAL, and failures remain FAIL until corrected and retested.

W50 result: no connected Android device, configured emulator or physical Merchant
counterpart was used; no transaction, review, rating or backend cleanup was run.
