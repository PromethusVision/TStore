# Customer App Synthetic Journeys

Status: **EXECUTED AGAINST LOCAL/CONTROLLED CONTRACTS**  
Wave: **16 — Customer App Commercialization Closeout**

`CURRENT_RESULT` is based on automated local tests and static contracts unless
the row explicitly says physical or Production-manual. No remote environment
was contacted during this wave.

| JOURNEY_ID | START_STATE | STEPS | EXPECTED_RESULT | AUTOMATABLE | PHYSICAL_REQUIRED | CURRENT_RESULT |
|---|---|---|---|---|---|---|
| J001 | Fresh guest | Launch Production entrypoint with valid client-safe contract | Home starts without Development fallback | YES | NO | PASS |
| J002 | Missing config | Launch entrypoint without URL/key | Safe actionable startup failure, no fallback | YES | NO | PASS |
| J003 | Guest/Home | Load discovery | Active categories and featured products render | YES | NO | PASS |
| J004 | Guest/Home/error | Discovery repository fails | Retryable error, no raw backend detail | YES | NO | PASS |
| J005 | Guest/Home/empty | Empty catalog response | Intentional empty state | YES | NO | PASS |
| J006 | Guest | Open each active category | Correct category products, no leakage | YES | NO | PASS |
| J007 | Guest/category | Paginate product list | Loading/append/end states remain coherent | YES | NO | PASS |
| J008 | Guest/category | Open product card | Matching Product Details opens once | YES | NO | PASS |
| J009 | Guest/product | Load product details | Name/category/state and fallback image are usable | YES | NO | PASS |
| J010 | Guest/product | Load sellers | Listings map to correct shop/product and prices | YES | NO | PASS |
| J011 | Guest/product | Rapidly tap one seller/shop action | One destination/action is opened | YES | NO | PASS |
| J012 | Guest/shop | Open shop | Matching shop data and products render | YES | NO | PASS |
| J013 | Guest/shop/error | Shop products fail | Shop identity remains; retry is offered | YES | NO | PASS |
| J014 | Guest/search | Enter whitespace | Search resets; no backend request | YES | NO | PASS |
| J015 | Guest/search | Search exact product term | Ranked product result appears | YES | NO | PASS |
| J016 | Guest/search | Search category-adjacent term | Category plus its products appear without duplicates | YES | NO | PASS |
| J017 | Guest/search | Search shop/address term | Active matching shop appears | YES | NO | PASS |
| J018 | Guest/search | First query resolves after second | Old response cannot replace latest result | YES | NO | PASS |
| J019 | Guest/search/partial error | One source fails | Remaining results plus safe warning | YES | NO | PASS |
| J020 | Guest/search/full error | All sources fail | Retryable generic error | YES | NO | PASS |
| J021 | Guest/search/no result | Use impossible query | Empty result offers edit/show-all recovery | YES | NO | PASS |
| J022 | Guest/search/result | Tap result | Correct Product Details opens | YES | NO | PASS |
| J023 | Guest/nearby | Load shops without granting location | Shops remain discoverable without crash | YES | NO | PASS |
| J024 | Guest/nearby | Approve explanation and location permission | Real coordinates sort nearby shops | PARTIAL | YES | PHYSICAL_REQUIRED |
| J025 | Guest/nearby | Deny permission | Shop list remains; clear denied state | YES | NO | PASS |
| J026 | Guest/nearby | Deny forever then open settings | Settings route and resume refresh work | PARTIAL | YES | PHYSICAL_REQUIRED |
| J027 | Guest/nearby | Disable location service | Service-specific recovery, no generic crash | YES | YES | PASS_LOCAL; PHYSICAL_RECHECK |
| J028 | Guest/cart action | Open Cart | Login flow precedes protected cart | YES | NO | PASS |
| J029 | Guest/favorite | Tap favorite | Login guard prevents anonymous write | YES | NO | PASS |
| J030 | Guest/profile | Open protected profile action | Login entry is reachable | YES | NO | PASS |
| J031 | Guest/auth | Submit valid signup twice rapidly | One signup use-case call | YES | NO | PASS_FIXED |
| J032 | Awaiting confirmation | Open valid mobile confirmation callback | Session/profile refresh and success feedback | YES | YES | PASS_LOCAL; PRIOR_ANDROID_PASS |
| J033 | Recovery requested | Open recovery callback | Update-password UI opens | YES | YES | PASS_LOCAL; PRIOR_ANDROID_PASS |
| J034 | Recovery UI | Save valid new password | Fresh credential proof gates success | YES | YES | PASS_LOCAL; PRIOR_ANDROID_PASS |
| J035 | Authenticated customer | Load profile | Own customer profile and role render | YES | NO | PASS |
| J036 | Authenticated customer | Update allowed profile fields | Only allowed fields are sent | YES | NO | PASS |
| J037 | Authenticated customer | Attempt role escalation through client contract | No role field is exposed/mutated | YES | NO | PASS |
| J038 | Authenticated customer | Add favorite | Wishlist refreshes once | YES | NO | PASS |
| J039 | Customer A then B | Switch session | A cart/wishlist cleared; B data loaded | YES | NO | PASS |
| J040 | Guest then customer | Sign in | Guest residuals cleared; scoped data loaded | YES | NO | PASS |
| J041 | Authenticated customer | Session expires | Local scoped state clears and Home opens with warning | YES | NO | PASS |
| J042 | Authenticated/customer cart | Add first shop product | Active single-store cart loads | YES | NO | PASS |
| J043 | Cart for shop A | Add product from shop A | Quantity/item updates normally | YES | NO | PASS |
| J044 | Cart for shop A | Add product from shop B | Explicit conflict state asks before replacement | YES | NO | PASS |
| J045 | Cart conflict | Confirm replacement twice rapidly | Only one replacement RPC is issued | YES | NO | PASS_FIXED |
| J046 | Loaded cart | Increment/decrement/remove rapidly | Mutations serialize and preserve valid quantity | YES | NO | PASS |
| J047 | Empty cart | Open cart | Clear empty state, no QR action | YES | NO | PASS |
| J048 | Eligible cart | Show in store | Opaque short-lived QR session renders | YES | YES | PASS_LOCAL; PHYSICAL_GATE_OPEN |
| J049 | Active QR | Wait beyond expiry | Expired state replaces active QR | YES | YES | PASS_LOCAL; PHYSICAL_GATE_OPEN |
| J050 | Used QR | Attempt replay | Backend contract rejects second confirmation | YES | YES (two-device acceptance) | PASS_CONTRACT; PHYSICAL_GATE_OPEN |
| J051 | Two verifiers | Confirm same token concurrently | At most one verified transaction | YES | YES | PASS_CONTRACT; PHYSICAL_GATE_OPEN |
| J052 | Verified purchase | Open product review | Eligible submit state uses durable product evidence | YES | NO | PASS |
| J053 | No verified purchase | Open review composer | Submission remains blocked | YES | NO | PASS |
| J054 | Existing review | Submit again | Existing review refreshes; no duplicate active review | YES | NO | PASS |
| J055 | Own review | Edit allowed fields | Rating/title/comment update and aggregate refresh | YES | NO | PASS |
| J056 | Own review | Delete twice rapidly | One RPC; eligible state refreshes | YES | NO | PASS |
| J057 | Customer/notifications | Load and mark in-app notification | Own list and unread state update safely | YES | NO | PASS |
| J058 | Customer/product | Start product chat | Conversation preserves product context | YES | NO | PASS |
| J059 | Guest/product chat | Prepare message then authenticate | Pending local draft resumes within defined window | YES | NO | PASS; OWNER_POLICY_OPEN |
| J060 | Customer/settings | Logout | Auth state, cart, wishlist and navigation reset | YES | NO | PASS |
| J061 | Customer/settings | Delete own account | Canonical flow ends local session on success | YES | YES/remote | PASS_LOCAL; PRODUCTION_MANUAL |
| J062 | Guest/address | Open active location management | Saved-locations flow is available behind auth | YES | NO | PASS |
| J063 | Customer/postal address | Seek legacy postal-address screen | No active route exposes prototype | YES | NO | DEFERRED_NOT_IN_V1 |
| J064 | Backgrounded app | Resume after settings/session changes | Lifecycle refreshes without duplicate work | YES | YES | PASS_LOCAL; PHYSICAL_RECHECK |
| J065 | Slow network | Refresh list twice | Stale response cannot overwrite latest generation | YES | NO | PASS |
| J066 | Offline | Trigger repository operation | Safe Turkish error, no secret/raw backend payload | YES | NO | PASS |
| J067 | Android release | Install signed Production artifact over app | Data-preserving install and startup | PARTIAL | YES | PRIOR_PASS; CURRENT_ARTIFACT_RECHECK |
| J068 | Android mail app | Open confirmation/recovery link | `com.esnaftavar.app` callback routes correctly | PARTIAL | YES | PRIOR_PASS; CURRENT_ARTIFACT_RECHECK |
| J069 | iOS release | Install/archive and open auth callback | Correct bundle/scheme and app routing | PARTIAL | YES | BLOCKED_BY_IOS |
| J070 | Production operator | Verify config/RLS/SMTP/backup before release | Manual evidence matches release contract | NO | YES | PRODUCTION_MANUAL |

## Automated subset

The local suite covers 62 of 70 rows fully or at contract/widget level. Eight
rows retain a physical-device, store-signing or Production-manual component.
Contract-level PASS is never used as a substitute for the physical result.
