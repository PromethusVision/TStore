# EsnaftaVar Location Event Privacy Model

**State:** `PROPOSED PRIVACY-MINIMIZING DESIGN`

| Concept | Candidate event/data | Boundary |
|---|---|---|
| Permission | `location_permission_result` | Permission state and platform only; no coordinates |
| Discovery context | `coarse_location_context_used` | Coarse area/geohash only if purpose and precision are approved |
| Directions intent | `directions_requested` | Shop ID and source surface; destination already known from shop, customer origin omitted |
| Failure | `location_capability_failed` | Bounded OS/service reason; no raw payload |

Precise customer latitude/longitude, movement trails, home/work inference and full
addresses are excluded from general analytics. Runtime may transiently need
location to calculate nearby discovery, but collection for analytics is a
separate purpose and must not be assumed.

Default reporting uses aggregate shop/area counts with minimum cohort thresholds.
Guest identity, precise location and authenticated identity are not combined.
Permission denial is not a security anomaly and must not reduce service access
beyond features that technically require location.

Directions is an intent signal, not arrival, sale, verified purchase or ad
conversion. External map-provider behavior is outside platform proof.

`PRECISE_LOCATION_ANALYTICS_DEFAULT: FORBIDDEN`
