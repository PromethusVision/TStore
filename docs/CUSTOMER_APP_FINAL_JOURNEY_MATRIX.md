# Customer App Final Journey Matrix

Status: **RE-EVALUATED AFTER WAVE 16 FIXES**

This matrix references the full steps/expectations in
`CUSTOMER_APP_SYNTHETIC_JOURNEYS.md`. “Blocked” means the final commercial
evidence is external; it does not rewrite a passing local contract as a failure.

| Journey | Final state | Evidence / blocker |
|---|---|---|
| J001 | PASS | Strict Production entrypoint contract |
| J002 | PASS | Missing config fails closed |
| J003 | BLOCKED_BY_TAXONOMY | Current demo discovery passes; final taxonomy runtime pending |
| J004 | PASS | Home retryable error |
| J005 | PASS | Home empty state |
| J006 | BLOCKED_BY_TAXONOMY | Current categories pass; final hierarchy pending |
| J007 | PASS | Product pagination/states |
| J008 | PASS | Product navigation |
| J009 | PASS | Product details/fallback |
| J010 | PASS | Seller mapping/prices |
| J011 | PASS | Duplicate navigation guard |
| J012 | PASS | Shop details/products |
| J013 | PASS | Shop partial failure/retry |
| J014 | PASS | Blank search no-call regression |
| J015 | PASS | Exact product search |
| J016 | BLOCKED_BY_TAXONOMY | Flat category search passes; final synonyms/tree pending |
| J017 | PASS | Shop/address search |
| J018 | PASS | Stale-query regression |
| J019 | PASS | Partial search error |
| J020 | PASS | Full search error |
| J021 | PASS | No-result recovery |
| J022 | PASS | Search result navigation |
| J023 | PASS | Guest Nearby fallback |
| J024 | BLOCKED_BY_PHYSICAL | Real GPS acquisition on final candidate |
| J025 | PASS | Permission-denied fallback |
| J026 | BLOCKED_BY_PHYSICAL | Denied-forever settings-return on final device |
| J027 | BLOCKED_BY_PHYSICAL | Location service toggle physical recheck |
| J028 | PASS | Cart AuthGuard |
| J029 | PASS | Favorite AuthGuard |
| J030 | PASS | Profile/login entry |
| J031 | PASS | Duplicate signup fixed/tested |
| J032 | BLOCKED_BY_PHYSICAL | Prior Android PASS; final-candidate confirmation recheck |
| J033 | BLOCKED_BY_PHYSICAL | Prior Android PASS; final-candidate recovery callback recheck |
| J034 | BLOCKED_BY_PHYSICAL | Prior Android PASS; final credential lifecycle recheck |
| J035 | PASS | Own profile/customer role |
| J036 | PASS | Allowed profile update |
| J037 | PASS | No client role mutation |
| J038 | PASS | Wishlist update |
| J039 | PASS | Account switch isolation |
| J040 | PASS | Guest→customer scoped load |
| J041 | PASS | Session-expiry reset/navigation |
| J042 | PASS | First Cart V2 item |
| J043 | PASS | Same-shop add |
| J044 | PASS | Cross-shop conflict |
| J045 | PASS | Replace double-action fixed/tested |
| J046 | PASS | Serialized cart mutations |
| J047 | PASS | Empty cart |
| J048 | BLOCKED_BY_PHYSICAL | Customer QR render/read on real camera |
| J049 | BLOCKED_BY_PHYSICAL | Real elapsed expiry acceptance |
| J050 | BLOCKED_BY_PHYSICAL | Replay on two-device live flow |
| J051 | BLOCKED_BY_PHYSICAL | Coordinated confirmation concurrency |
| J052 | PASS | Verified review eligibility |
| J053 | PASS | Unverified review denial |
| J054 | PASS | Duplicate review idempotency |
| J055 | PASS | Own review update |
| J056 | PASS | Duplicate delete lock |
| J057 | PASS | In-app notifications |
| J058 | PASS | Product chat context |
| J059 | PASS | Draft lifecycle works; retention policy remains owner decision |
| J060 | PASS | Logout reset |
| J061 | BLOCKED_BY_PRODUCTION_MANUAL | Live account delete requires authorized fixture/cleanup |
| J062 | PASS | Saved locations |
| J063 | PASS | Postal-address prototype remains unreachable by V1 design |
| J064 | BLOCKED_BY_PHYSICAL | Background/resume final-device recheck |
| J065 | PASS | Stale repository result guards |
| J066 | PASS | Offline/safe error mapping |
| J067 | BLOCKED_BY_PHYSICAL | Final signed Android upgrade/install |
| J068 | BLOCKED_BY_PHYSICAL | Final Android mail callback |
| J069 | BLOCKED_BY_PHYSICAL | iOS archive/install/callback |
| J070 | BLOCKED_BY_PRODUCTION_MANUAL | JIT Production go/no-go checklist |

## Totals

- PASS: **51**
- BLOCKED_BY_PHYSICAL: **14**
- BLOCKED_BY_TAXONOMY: **3**
- BLOCKED_BY_PRODUCTION_MANUAL: **2**
- BLOCKED_BY_UIKIT: **0** (UI rollout is a global release gate, not a broken
  functional journey)
- FAILED: **0**
