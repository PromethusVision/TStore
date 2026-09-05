# W50 commercialization gap matrix

Customer UI completion and local technical validation are established. They do
not constitute commercial launch approval. The separate gates below use the
requested commercialization status vocabulary.

| Gate | Status | Proven now | Exact remaining closure requirement / owner |
|---|---|---|---|
| CUSTOMER_TECHNICAL_RC | BLOCKED | 2058 local tests pass; analyzer clean; three-ABI Android AOT/native/resource build and Android Lint pass; safe defects fixed | Release owner supplies existing secure signing and an approved Production client-only manifest, then creates/verifies a fresh APK/AAB. No current installable W50 artifact exists |
| PHYSICAL_QR_E2E | MANUAL | Customer code chain, duplicate handling and immutable eligibility contracts pass locally | Two real devices, ready Merchant counterpart, authorized pilot environment and complete [runbook](W50_PHYSICAL_QR_ACCEPTANCE_RUNBOOK.md) |
| MERCHANT_APP | NOT_STARTED | Customer-facing handoff contracts and legacy scanner source can be inspected | Merchant owner must supply an independently validated pilot app, account/role/shop operation and transaction acceptance. W50 does not implement or certify that product |
| LEGAL_PRIVACY | PROFESSIONAL_REVIEW | Reachable versioned KVKK/Terms, consent wiring, permissions explanation and account/profile paths | Product Owner plus legal/privacy professional validate the exact items below and retain approval |
| SUPPORT_OPERATIONS | OWNER_REQUIRED | Help routes work; selectable `info@esnaftavar.com`; QR/refund guidance is now accurate | Verify mailbox delivery, accountable staffing/escalation, response process, account/data requests and shop/customer dispute handling |
| PLAY_STORE_PUBLISHING | BLOCKED | Canonical app identity, SDK configuration, signing fail-closed contract, native alignment and local resource checks | Store owner: fresh signed artifact/certificate and version allocation; Play Console/account eligibility, listing, privacy URL/declarations, content/data-safety/SDK review and actual device/pre-launch results. No upload here |
| COMMERCIAL_LAUNCH | BLOCKED | Customer local technical package is integration-ready | Product Owner must accept all relevant gates above, merchant coverage/data operations and pilot operating scope. Customer compilation alone cannot close this gate |

`MERCHANT_APP: NOT_STARTED` describes Merchant readiness work in W50; it does
not assert that no Merchant code or other team work exists anywhere. No current
Merchant build/readiness evidence was supplied or inferred from legacy Customer
scanner source.

## Exact legal/privacy/support review list

These are questions for the accountable owners/professionals, not legal advice
or replacement policy text:

1. Confirm the actual data controller/legal entity, registered contact/address
   and rights-request channel match the currently displayed Musaki Software,
   Esenler address and support email. Verify mailbox operation and identity-safe
   handling; no email was sent from this task.
2. Review each declared data category/purpose against current collection: Auth,
   profile/contact/avatar, chosen/saved location, Cart/favorites/recent history,
   messages, notifications, verified purchases and reviews. Distinguish generic
   UI avatar and future capability from data the customer can actually submit.
3. Validate retention periods, account deletion/anonymization behavior and
   exceptions for immutable transaction/review evidence. Check that the displayed
   promises and the actual backend/account-delete procedures agree.
4. Validate service providers, processing regions, overseas transfers, contracts,
   rights handling and incident/escalation process. No provider/legal compliance
   or remote retention policy was certified by repository tests.
5. Review versioned signup agreement records and whether separate optional
   consent is required for any current processing; verify permission explanation
   and saved-location choices reflect actual behavior. Do not enable background
   tracking or future Reward/Ads systems as part of this review.
6. Review terms for physical in-store commerce, QR verification, review/message
   abuse handling and returns/disputes. App-based refund creation is unavailable;
   pilot operations need a truthful external process, not an implied online
   refund engine.
7. Review the packaged SDK footprint and store declarations, including dormant
   scanner/ML Kit/Google transport components and the retained camera permission.
   Inspect actual SDK behavior before making data-collection declarations.

## Deferred maintenance and product boundaries

| Item | Gate-ledger class | Treatment |
|---|---|---|
| Reward economics / coupons | POST_PILOT | No economy/backend exists; runtime Reward stays off, Coupons explicitly unavailable |
| Canonical taxonomy activation | POST_PILOT | Existing opt-in contract stays off; no migration or remote proof call |
| Ads | POST_PILOT | No Ads engine enabled or promised |
| Refund submission | POST_PILOT | Existing preparation UI retained; Help corrected; no backend implementation |
| Dormant Merchant scanner footprint / unused bundled images | POST_PILOT | Review removal and licensing/size separately; no remote seed deletion |
| Dependency versions / Gradle deprecations / duplicate splash assets | POST_PILOT | No demonstrated remaining blocker or reported affected package advisory; avoid mass upgrades |
| iOS signing/archive | STORE_DEPENDENCY | Android-first package; existing unavailable Apple signing environment not fabricated |
| Fresh signed Android install / callbacks / backup / 16KB device | MANUAL_PHYSICAL_GATE | Run on the real final artifact; older physical callback evidence is historical, not W50 reacceptance |

Production remote access and Development writes during W50: **0**.
Commercial launch ready: **NO**.
