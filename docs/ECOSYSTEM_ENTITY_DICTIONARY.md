# Ecosystem Entity Dictionary

**State:** RECONCILED TERMINOLOGY — OWNER-OPEN FUTURE ENTITIES REMAIN PROPOSED

| Entity | Reconciled meaning | Stable identity | Not equivalent to |
|---|---|---|---|
| AUTH_USER | Authentication principal and session subject | Auth provider UUID | customer profile, merchant role, operator authority |
| CUSTOMER | Authenticated person using Customer App capabilities | customer/profile subject linked to Auth user | merchant organization or public review identity |
| PROFILE | Customer-facing/account metadata allowed by profile contract | Auth-linked profile ID | authorization role store |
| MERCHANT_ORGANIZATION | Future legal/operational grouping for memberships and shops | future opaque organization ID | shop, sector, Auth user |
| MEMBERSHIP_STAFF | User-to-organization/shop capability assignment with lifecycle | future membership ID | `profiles.role`, merchant-sector choice |
| SHOP_BRANCH | Customer-visible physical location and exact QR operating boundary | current/future stable shop ID | organization, merchant sector, listing |
| MERCHANT_SECTOR_NODE | Governed answer to “what kind of business is this?” | future immutable sector ID | Product Taxonomy, authorization, licence evidence |
| TAXONOMY_NODE | Owner-governed physical-product classification node | owner-final stable taxonomy node ID | facet, product, sector, policy proof |
| CANONICAL_PRODUCT | Shared repeatably recognizable physical trade item/family | opaque canonical product ID | merchant offer, price, shop SKU |
| VARIANT | Choice-bearing sellable identity below a product where domain rules require it | optional stable variant ID | cart quantity, listing availability |
| SHOP_LISTING | One shop’s offer for a canonical product/variant | listing ID scoped to shop | canonical product or ad campaign |
| QR_SESSION | Short-lived opaque customer intent bound to one shop/cart snapshot | server-issued session/token identity | payment, purchase, review right |
| VERIFIED_PURCHASE | Server-authoritative merchant-confirmed physical purchase evidence | transaction + immutable item IDs | click, direction, order boolean, analytics event |
| REVIEW | Customer-authored product feedback whose eligibility derives from purchase evidence | review ID; uniqueness customer+canonical product | reward, rating aggregate, reputation signal |
| AD_CAMPAIGN | Future paid delivery instruction targeting eligible sponsored listing inventory | campaign ID/version | listing identity, organic relevance, trust badge |
| REWARD_EVENT | Future immutable economic ledger fact created by approved evaluator | reward ledger event ID | generic analytics, review entitlement |
| BADGE_REPUTATION_SIGNAL | Future governed achievement/trust input or derived projection | definition/signal IDs with evidence lineage | customer rating or paid status |
| OPS_CASE | Restricted operational investigation/workflow with evidence and decisions | case ID | broad admin permission or analytics dashboard row |
| DOMAIN_EVENT | Authority-classified fact emitted after committed domain state | event ID + source aggregate/version | raw client telemetry |
| ANALYTICS_EVENT | Minimized measurement observation/derivation for an approved question | event/envelope ID with environment | business authority or audit evidence |
| AUDIT_EVENT | Immutable security/operational evidence of sensitive action | audit event ID and actor/resource linkage | product analytics metric |

## Relationship spine

```text
AUTH_USER -> CUSTOMER/PROFILE
AUTH_USER -> MEMBERSHIP -> MERCHANT_ORGANIZATION -> SHOP_BRANCH
TAXONOMY_NODE -> CANONICAL_PRODUCT -> optional VARIANT -> SHOP_LISTING -> SHOP_BRANCH
CUSTOMER QR_SESSION -> SHOP confirmation -> VERIFIED_PURCHASE -> REVIEW eligibility
SHOP_LISTING -> optional AD_CAMPAIGN (paid delivery only)
VERIFIED_PURCHASE -> optional future REWARD_EVENT / factual reputation signals
DOMAIN STATE -> DOMAIN_EVENT -> minimized ANALYTICS_EVENT
SENSITIVE ACTION -> AUDIT_EVENT / optional OPS_CASE
```

Renames, taxonomy moves, shop display changes or merchant-sector changes do not
replace stable identity. Merge/split/retire require explicit lineage.
