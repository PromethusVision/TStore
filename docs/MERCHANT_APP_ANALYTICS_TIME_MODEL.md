# Merchant App Analytics Time Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP41

## V1 windows

- `TODAY`: shop-local calendar day, with timezone displayed.
- `LAST_7_COMPLETE_DAYS`: seven complete local days excluding current partial day unless labeled.
- `LAST_30_COMPLETE_DAYS`: thirty complete local days.
- `CUSTOM`: deferred until validation/export needs are known.

## Event-time rules

- Verified purchase uses authoritative confirmation time.
- Listing health is a point-in-time snapshot, not an event sum.
- View/direction uses accepted event timestamp after dedup/filter policy.
- Late-arriving events update prior windows with a visible freshness marker.
- DST/timezone changes use the shop's recorded timezone at event/report contract; policy must be consistent.

## Comparison

Previous-period comparison is optional and must use equal-duration complete windows. A partial today cannot be compared to a complete yesterday without an explicit label.

## Open decisions

- Analytics processing latency target, dedup windows, shop-timezone source and custom-range availability.
