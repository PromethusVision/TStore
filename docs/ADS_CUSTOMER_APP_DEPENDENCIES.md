# Customer App Dependencies for Sponsored Advertising

**State:** INSERTION-POINT AUDIT — NO FLUTTER OR FINAL UI DESIGN

## Candidate insertion points

- Home discovery module;
- Search result list/grid;
- Category/product listing;
- Product Details seller comparison;
- Shop discovery;
- Nearby.

Search and Category are the recommended first pilot surfaces. Seller comparison is
a P0 trust decision. Home/Nearby/shop-awareness are future candidates.

## Required foundations

- stable canonical product/variant/listing/shop identity;
- current organic ranking contract and ads-disabled equivalence tests;
- reusable sponsored card/row states across list/grid/compact/accessibility;
- persistent textual `Sponsorlu`, advertiser identity and why/report controls;
- real price, availability freshness, shop distance and navigation destination;
- deterministic dedup between sponsored and organic representations;
- ad timeout/cancellation with no late layout/rank jump;
- measurement qualification after actual visible render;
- privacy/location controls and coarse fallback;
- error/loading/empty/offline behavior with organic fallback.

## Regression gates later

- disclosure cannot disappear on scroll/recycle/back navigation;
- no duplicate navigation or duplicate impression on rebuild;
- no ad for inactive/deleted/out-of-stock listing;
- no all-sponsored viewport;
- organic order unchanged when ads disabled/unavailable;
- seller comparison same-product invariant;
- screen-reader/contrast/touch/overflow acceptance;
- latency/fault injection and customer report/hide flows.

`CUSTOMER_APP_AD_INSERTION_POINTS_IDENTIFIED: YES`

`CUSTOMER_APP_AD_RUNTIME_READY: NO`

`FLUTTER_CHANGED: NO`
