# EsnaftaVar Global Metric Registry

**State:** `PROPOSED V0 — DEFINITIONS NOT OWNER-FINAL`

| METRIC_ID | NAME | DEFINITION / NUMERATOR | DENOMINATOR | SOURCE_EVENTS | ENTITY_SCOPE | TIME_WINDOW | PRIVACY | CAVEAT |
|---|---|---|---|---|---|---|---|---|
| `app_start_count` | App starts | Distinct valid app-start events | — | `app_started` | release/environment | day | Essential | Not active people |
| `authentication_failure_rate` | Auth failure rate | Valid failed attempts | All observable attempts | auth outcomes | release/environment | hour/day | Essential/security | Client coverage may differ |
| `search_count` | Searches | Distinct valid submissions | — | `search_submitted` | taxonomy/environment | day | Product analytics | Raw query unnecessary |
| `search_zero_result_rate` | Zero-result rate | Presented searches with zero results | All valid presented searches | search presentation | taxonomy/index version | day/week | Product analytics | Result count is not satisfaction |
| `product_view_count` | Product views | Qualified distinct view events | — | `product_viewed` | product/listing/shop | day/week | Product analytics | Soft signal |
| `seller_comparison_count` | Seller comparisons | Distinct comparison opens | — | seller comparison | product | day/week | Product analytics | Soft signal |
| `shop_view_count` | Shop views | Qualified distinct shop opens | — | `shop_opened` | shop/branch | day/week | Product analytics | Not store visit |
| `directions_intent_count` | Directions intents | Distinct valid requests | — | `directions_requested` | shop/branch/product context | day/week | Product analytics | Not arrival/sale |
| `wishlist_add_count` | Wishlist adds | Persisted add transitions | — | wishlist add | product | day/week | Product analytics | Soft intent |
| `cart_add_count` | Cart V2 adds | Persisted add transitions | — | cart add | listing/product/shop | day/week | Product analytics | No checkout |
| `verified_purchase_count` | Verified physical purchases | Distinct authoritative purchase facts | — | verified purchase | shop/product/listing | shop-local day/week | Essential | Not payment/revenue |
| `verified_purchase_item_count` | Verified purchased items | Governed item quantity sum | — | verified purchase | shop/product/listing | shop-local day/week | Essential | Requires item evidence |
| `active_review_count` | Active eligible reviews | Latest active eligible review revisions | — | review lifecycle | product/shop | as-of/day | Product analytics | Deletion/update restates |
| `average_rating` | Average rating | Sum active eligible ratings | Active eligible rating count | review lifecycle | product/shop | as-of/window | Product analytics | Show count/distribution |
| `active_listing_count` | Active listings | Latest revisions in active state | — | listing lifecycle | shop/catalog | as-of/day | Essential | Inventory health |
| `qr_failure_rate` | QR validation failure rate | Valid server failures | All server validation outcomes | QR outcomes | shop/release | hour/day | Security/essential | Reasons restricted |
| `ad_impression_count` | Ad impressions | Events meeting selected validity rule | — | ad impressions | campaign/revision/surface | day | Ad measurement | Qualification/billing open |
| `ad_open_count` | Sponsored opens | Distinct valid ad opens | — | ad opened | campaign/revision/target | day | Ad measurement | Not conversion |
| `ad_attribution_candidate_count` | Attribution candidates | Distinct model outputs | — | source interactions + outcomes | campaign/shop | model window | Ad measurement | Reporting only |

Every row requires a metric-definition version, owner, freshness, quality-filter
version and change log before runtime. Ratios cannot be published without a valid,
same-scope denominator.

`GLOBAL_METRIC_REGISTRY_FINALIZED: NO`

