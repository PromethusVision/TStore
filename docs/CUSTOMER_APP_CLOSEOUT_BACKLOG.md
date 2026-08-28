# Customer App Closeout Backlog

Status: **ORDERED EXECUTION SOURCE-OF-TRUTH CANDIDATE**

| Bucket | ID | TASK | WHY | DEPENDENCY | COMPLEXITY | CODEX UNATTENDED | OWNER NEEDED |
|---|---|---|---|---|---|---|---|
| BLOCKING | CUST-QR-001 | Complete physical two-device QR matrix | Core O2O proof requires camera, merchant ownership, replay and concurrency | Two devices + authorized fixtures | M | NO | YES |
| BLOCKING | CUST-CONFIG-001 | Run final Production go/no-go checklist read-only/controlled | Remote config and data are time-sensitive | Authorized Production operator | M | PARTIAL | YES |
| BLOCKING | CUST-STORE-001 | Build/sign/install final Android candidate and internal-track review | Public artifact must match tested code/signature/version | Secure signing + Play Console | M | PARTIAL | YES |
| BLOCKING | CUST-IOS-001 | Archive/sign/TestFlight and physical callback | Required for iOS commercialization | macOS/Xcode/signing/device | L | PARTIAL | YES |
| NEXT | CUST-PRIV-001 | Decide recent-search logout/account-switch retention | Device-local history may cross account boundaries | Privacy/product decision | XS | NO | YES |
| NEXT | CUST-PRIV-002 | Decide pre-login chat-draft retention | Device-local draft may cross account boundaries | Privacy/product decision | XS | NO | YES |
| NEXT | CUST-NAV-001 | Confirm public Nearby policy | Resolves brief/runtime contradiction | Product decision | XS | NO | YES |
| AFTER_TAXONOMY | CUST-TAX-001 | Implement owner-final taxonomy runtime | Final catalog structure affects models, queries, routes, search and data | Final manifest + migration authorization | XL | PARTIAL | YES |
| UI_KIT | CUST-UI-001 | Roll final design system through active journeys | Current visuals are intentionally non-final | Figma/UI kit | XL | PARTIAL | YES |
| PHYSICAL | CUST-PHY-002 | Recheck GPS, network switching and background/resume on final binaries | Platform behavior cannot be fully simulated | Final Android/iOS artifacts | M | NO | YES |
| PRODUCTION | CUST-MON-001 | Select privacy-compliant crash/incident monitoring | Pilot needs operational diagnosis | Owner/privacy/provider | M | PARTIAL | YES |
| OPTIONAL | CUST-SCALE-001 | Add pagination to eager customer collections | Avoid growth-scale read/memory issues | Real scale targets | L | YES | NO |
| OPTIONAL | CUST-ASSET-001 | Re-encode oversized visual assets with visual QA | Reduce first download/bundle size | Final UI assets | M | PARTIAL | YES |
| OPTIONAL | CUST-DEPS-001 | Upgrade dependencies in bounded compatibility batches | Reduce drift without closeout risk | Dedicated branch/test matrix | L | YES | NO |
| OPTIONAL | CUST-PUSH-001 | Design push notification feature | Current V1 has only in-app notifications | Product/backend/provider | XL | PARTIAL | YES |
| OPTIONAL | CUST-AVATAR-001 | Define avatar bucket/policy before exposing upload UI | Dormant repository has no active backend contract | Storage/schema authorization | M | PARTIAL | YES |
| OPTIONAL | CUST-ADDR-001 | Decide whether future commerce needs postal addresses | O2O V1 uses saved locations; prototype is not active | Future commerce/service model | L | NO | YES |

No item in this table is a hidden inline TODO. Each maps to the failure registry,
deferred classification or an explicitly physical/release follow-up.
