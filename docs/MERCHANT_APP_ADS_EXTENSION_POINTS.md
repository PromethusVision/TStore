# Merchant App Ads Extension Points

Status: **PROPOSED — FUTURE ENGINE ONLY**
Wave: 17 / WP63

## Potential future surfaces

- Campaign eligibility/status summary.
- Select eligible shop/listing/product sponsored object.
- Budget/schedule controls only after billing architecture.
- Creative/policy review state and remediation.
- Clearly separated sponsored performance metrics.

## Boundaries now

- No ad campaign creation, payment, auction, targeting or ranking logic in V1.
- Organic dashboard/search metrics remain separate from paid metrics.
- Sponsored disclosure is customer-facing and cannot be hidden by merchant.
- Merchant eligibility does not follow merely from active shop/listing.
- Reputation/badges and verified purchase truth cannot be bought.

Interfaces should reserve stable entity references and policy status, not speculative ad fields in core listing/merchant tables.
