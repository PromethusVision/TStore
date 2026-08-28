# Merchant App Dependencies for Sponsored Advertising

**State:** DEPENDENCY AUDIT — NO MERCHANT APP IMPLEMENTATION

## Required foundations before ads runtime

1. Canonical merchant organization/principal and active shop/branch ownership.
2. Merchant taxonomy owner review/stable IDs where sector context is used; sector
   remains independent from product/ad eligibility.
3. Canonical product/variant and shop-listing identity/lifecycle.
4. Merchant catalog management with active listing, price and availability
   freshness.
5. Server-authoritative merchant/shop/product policy and evidence state.
6. Campaign/pricing/budget/lifecycle owner decisions.
7. Payment/billing/tax/invoice/credit/dispute architecture if charging occurs.
8. Admin review, fraud/invalid traffic and appeal operations.
9. Measurement/privacy/retention and reporting definitions.
10. Native sponsored preview component with immutable disclosure contract.

## Future Merchant App insertion points

- Ads entry gated by eligibility;
- listing target selector;
- contextual/geo targeting and duration/budget form;
- exact `Sponsorlu` preview;
- submit/review/status and safe edit/pause/end;
- defined metrics, spend/credit freshness and disputes;
- policy/fraud reason classes without customer/security leakage.

## Current-state implications

Project backlog says merchant catalog/stock/price management and analytics are not
complete product modules. Existing merchant role/shop/QR capabilities are not enough
to support advertising. Ads must not become a shortcut that adds a parallel product
or price source.

`MERCHANT_APP_READY_FOR_ADS_RUNTIME: NO`

`MERCHANT_CATALOG_DEPENDENCY: BLOCKING`

`APP_IMPLEMENTATION_PERFORMED: NO`
