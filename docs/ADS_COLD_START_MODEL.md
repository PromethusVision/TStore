# Sponsored Advertising Cold-Start Model

**State:** PROPOSED SMALL-PILOT BEHAVIOR — NO RUNTIME

## Cold-start conditions

- few active merchants/listings;
- few or zero campaigns in Esenler;
- low per-query/category competition;
- sparse measurement and no trustworthy conversion baseline;
- new merchants without reviews/history;
- uneven geo and Product L1 coverage.

## Rules

1. Zero eligible sponsor means the exact organic experience, not an empty ad module.
2. Low campaign density does not broaden geo, relevance, policy or stock rules.
3. One advertiser cannot occupy every eligible surface merely because no competitor
   exists; page/session/merchant/product caps remain.
4. New merchants qualify through shop/listing/policy evidence, not historical
   reviews or ad spend.
5. No auction price inference from a market with one bidder.
6. Forecasts explicitly show insufficient data instead of projected ROI.
7. Pilot rollout is surface/geo/policy allowlisted with kill switch.

## Proposed pilot

- Esenler only;
- Search and Category surfaces first;
- policy-safe listing allowlist;
- non-auction flat promotion candidate;
- bounded rotation and low density;
- contextual plus local targeting only;
- qualified impression/open shadow metrics;
- customer trust, complaint and organic performance guardrails;
- seller comparison only after separate P0 decision.

## Expansion gates

Adequate organic quality/latency, merchant demand, customer disclosure comprehension,
invalid-traffic controls, dispute operations, policy review capacity and privacy
acceptance must precede wider geo/surfaces or auction evaluation.

`COLD_START_ORGANIC_DEGRADATION_ALLOWED: NO`

`SINGLE_BIDDER_AUCTION_V1: NO`

`ESENLER_PILOT: PROPOSED_NOT_FINAL`
