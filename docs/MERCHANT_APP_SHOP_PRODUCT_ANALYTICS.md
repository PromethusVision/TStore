# Merchant App Shop and Product Analytics

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP42

## Shop scope

Shop analytics aggregate authorized customer-interest, verified-purchase and listing-health signals for one shop/branch. Organization aggregation is a separate permissioned view.

## Product/listing scope

- Product rows use durable canonical product identity.
- Variant/listing drill-down is optional only where enough data exists.
- Historical events preserve snapshot identity across later catalog merge/split decisions; migration semantics remain owner decisions.
- Retired listings can appear in historical metrics but not active-listing counts.

## Recommended V1 table

Canonical product, active listing state, current price freshness, product views, direction intent attribution if defined, verified purchase count and eligible review aggregate. Sorts are explicit; hidden sponsored weighting is forbidden.

## Boundaries

- Other merchants' listing performance is not exposed.
- “Best selling” is not used unless verified-purchase definition and coverage make it honest.
- Low-volume customer behavior is suppressed/aggregated.
- Product views cannot be presented as shop visits.
