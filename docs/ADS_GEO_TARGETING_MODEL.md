# Sponsored Geo Targeting Model

**State:** PROPOSED LOCAL-COMMERCE MODEL — NO LOCATION ENGINE

## Principle

An EsnaftaVar ad promotes a real physical shop in a customer-relevant local context.
Campaign geography is anchored to the verified shop coordinate; it is not a free
polygon or nationwide audience chosen independently by the merchant.

## Context sources

| Source | Use | Privacy/quality rule |
|---|---|---|
| Current device location | Current nearby intent | Use only with valid permission/purpose; avoid retaining exact trail |
| Saved customer location | Explicit home/work shopping context | Customer-controlled; purpose and retention disclosed |
| User-selected map/location | Strong explicit intent | Prefer over inferred location for that request |
| District/city fallback | Coarse discovery when precise location unavailable | Never imply exact nearness |
| Shop coordinate | Mandatory supply-side anchor | Verified/active shop location; relocation revalidates campaign |

## Campaign geo options

- shop-centered radius with owner-defined minimum/maximum;
- selected neighbourhood/district intersection containing or adjacent to the shop;
- city scope only for explicitly approved low-density fallback;
- service area later, only after service-location evidence and product decision.

Manual radius is a bounded targeting choice, not permission for nationwide delivery.
No campaign can detach from every active physical shop.

## Serve-time rules

1. Resolve the request's explicit current/saved/selected location context.
2. Validate shop coordinate and campaign geo revision.
3. Apply platform local-eligibility ceiling before merchant-selected radius.
4. Calculate distance using the same truth source as organic results.
5. If location is missing/denied/stale, use an honest coarse fallback or no ad.
6. Never display `nearest` merely because the ad passed a geo gate.

## Privacy-minimizing posture

- store campaign geo, not a customer's longitudinal location trail;
- decision events retain a coarse geo/context class where possible;
- do not build home/work inference from repeated visits;
- do not export precise coordinates to merchants;
- location-based profiling and children require legal/privacy review.

## Failure behavior

Unknown location, geocoder failure, moved shop, invalid radius or timeout suppresses
the ad and preserves organic results. It must not broaden targeting silently.

`NATIONWIDE_V1_ADS: NO`

`PHYSICAL_SHOP_ANCHOR: REQUIRED`

`EXACT_RADIUS_LIMITS_FINALIZED: NO`
