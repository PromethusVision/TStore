# Merchant App Dashboard Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP38

## Mission

Dashboard, merchant'ın şimdi yapması gereken işleri ve son operasyon durumunu tek bakışta gösterir. Vanity metric duvarı veya finansal satış paneli değildir.

## Proposed priority

1. **Action required:** policy/catalog corrections, inactive shop/listings, unresolved QR outcome.
2. **Today:** verified physical purchases, recent QR results and critical notifications.
3. **Listing health:** unknown/stale availability, missing price/media warnings where relevant.
4. **Customer interest:** product/shop views and direction intents with privacy-safe aggregates.
5. **Reputation:** rating/review counts with no merchant manipulation controls.

## Rules

- Active shop and time window are always visible.
- “Sales” is not used for views, directions or unverified actions.
- Empty, delayed and unavailable metrics are distinguished from zero.
- Aggregates do not expose customer identity or small-cohort behavior.
- Future ads/rewards never blend into organic operational truth.

## V1 recommendation

One actionable dashboard with 4–6 cards; advanced charts and exports deferred. Whether dashboard ships as MUST or SHOULD remains owner review.
