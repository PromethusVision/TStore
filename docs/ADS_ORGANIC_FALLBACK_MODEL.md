# Ads-Free Organic Fallback Model

**State:** NON-NEGOTIABLE DESIGN INVARIANT — NO RUNTIME CHANGE

## Core contract

Organic discovery is independently executable. The ad engine may add an eligible,
clearly disclosed placement but cannot become a required dependency for Home,
Search, Category, Product Details/Seller Comparison, Shop discovery or Nearby.

## Fallback triggers

- no matching campaign;
- no eligible merchant/shop/listing/product;
- out of stock or stale price/availability;
- policy/review block;
- budget exhausted or campaign paused/ended;
- frequency/density cap;
- geo unavailable/outside scope;
- disclosure/creative variant invalid;
- selector, cache, measurement, budget or fraud service timeout/error;
- inconsistent campaign revision or identity mapping;
- owner rule unresolved.

## Behavior

1. Return/render normal organic results with their normal internal order.
2. Do not reserve blank sponsored space or show ad-specific customer error.
3. Do not wait beyond the ad decision deadline.
4. Do not broaden targeting or select a lower-quality unsafe ad.
5. Measurement failure cannot block organic response or fabricate an impression.
6. Retries are bounded and cannot later reorder a stable page unexpectedly.
7. Ads-disabled configuration is a supported operating mode.

## Validation requirements later

- golden/contract equivalence of ads-disabled versus zero-eligible-ad responses;
- fault injection for selector/budget/measurement/policy dependencies;
- latency tests showing deadline/cancellation;
- no organic ranking mutation from campaign create/pause/delete;
- customer navigation works with ad subsystem completely unavailable.

`NO_SPONSOR_BEHAVIOR: ORGANIC_EXACT_FALLBACK`

`AD_ENGINE_SINGLE_POINT_OF_FAILURE: NO`

`ORGANIC_RANKING_OWNERSHIP: INDEPENDENT`
