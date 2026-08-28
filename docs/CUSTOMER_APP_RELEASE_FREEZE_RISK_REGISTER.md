# Customer App Release Freeze Risk Register

| RISK_ID | DESCRIPTION | LIKELIHOOD | IMPACT | MITIGATION | OWNER | BLOCKS_FREEZE | BLOCKS_COMMERCIALIZATION |
|---|---|---|---|---|---|---|---|
| RF-01 | Two-device QR has no final physical acceptance | Medium | Critical | Execute exact camera/wrong-merchant/replay/concurrency plan | Product + QA | NO | YES |
| RF-02 | iOS archive/signing/callback unproven | High | High | Xcode/TestFlight/device acceptance or explicit Android-only pilot | Release owner | NO | YES for iOS |
| RF-03 | Final Production config may drift after prior evidence | Low/Medium | Critical | JIT manual checklist and fail-closed release window | Production owner | NO | YES |
| RF-04 | Final signed artifact/store track differs from tested source | Medium | High | Record commit/version/hash/signer and retest exact artifact | Release owner | NO | YES |
| RF-05 | Taxonomy runtime not implemented | High | High | Decide whether pilot uses current demo taxonomy or waits for migration | Product owner | YES if final taxonomy required | YES |
| RF-06 | Final UI kit not implemented | Certain | Medium/High | Approve rollout scope and run visual/accessibility acceptance | Design/product | NO | YES by current owner plan |
| RF-07 | Device-local search/chat data policy unresolved | Medium | Medium | Record retention/logout policy then test it | Product/privacy owner | YES | YES |
| RF-08 | No crash/incident monitoring | Medium | High | Select privacy-compliant minimum monitoring/support process | Product/operations | NO | CONDITIONAL |
| RF-09 | Eager reads degrade as pilot data grows | Low at pilot | Medium | Monitor and paginate before scale threshold | Engineering | NO | NO |
| RF-10 | Oversized assets increase download/startup cost | High | Medium | Optimize with visual QA in UI rollout | Design/engineering | NO | NO |
| RF-11 | Dependency drift accumulates | Medium | Medium | Bounded upgrade branches plus full regressions | Engineering | NO | NO |
| RF-12 | Merchant App absence prevents end-to-end merchant QR operation | High | Critical | Use authorized verifier tool/pilot process, then build Merchant App | Product/merchant team | NO for customer core | YES for full ecosystem |

No unresolved automatically fixable P0/P1 customer code defect remains in the
Wave 16 registry. Freeze blockers are owner policy/scope decisions; commercial
blockers are physical, platform and Production gates.
