# Merchant App Branch Operations

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP14

## Boundary

Canonical product and variant are shared catalog facts. A shop/branch listing is an independent local offer with its own price, availability, merchant SKU and optional local media.

## Proposed behavior

- Merchant chooses active branch before operational work.
- Product search spans canonical catalog; listing search defaults to active branch.
- “Copy to branches” creates explicit target listings from a preview; it does not bind their future price/availability.
- Branch-specific listing edits never mutate sibling branches unless a separately confirmed bulk action names them.
- QR token is validated against the exact intended shop/branch contract; organization membership alone is insufficient.
- Metrics default to active branch and can aggregate organization totals only for authorized users.
- Staff scope is explicit per branch; inheritance is not assumed.

## Conflict handling

- If a source listing changed after copy preview, show revision conflict and require refresh.
- Duplicate canonical product/variant in one branch follows listing uniqueness rules.
- Deactivated branch cannot receive new QR confirmations or be selected for new listing writes.
- Moving a branch does not rewrite verified transaction location snapshots.

## V1 recommendation

Keep branch operations limited to context switching, branch-specific listings and basic organization summary. Shared templates, regional controls and automatic price synchronization are deferred.

## Open decisions

- `BR-01 P0`: Whether branch is distinct from shop at launch.
- `BR-02 P1`: Cross-branch copy included in V1.
- `BR-03 P1`: Which roles may view organization-wide metrics.
