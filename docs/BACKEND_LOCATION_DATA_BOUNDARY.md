# Backend Location Data Boundary

**State:** PROPOSED — PRECISE CUSTOMER LOCATION IS EPHEMERAL BY DEFAULT

## Customer location

Use device coordinates for the requested nearby calculation and discard them when
the request completes unless the customer explicitly saves a location under the
existing private saved-location contract. Do not create movement history,
merchant-visible coordinates or analytics trails by default.

Logs/events use no point or an approved coarse cell with purpose/retention.
Permissions remain a client/platform UX concern, while backend input validates
range, radius and precision. A merchant receives aggregate/coarse insight only
after privacy thresholds—not the customer's route or home.

## Shop/demo location

Shop coordinates are public only at approved precision and must represent the
shop's declared physical context. Demo `NEIGHBORHOOD_CENTER` coordinates remain
labelled synthetic/approximate and never become exact address claims.

Saved addresses/locations are `CUSTOMER_PRIVATE`; shipping/fulfilment is not
implicitly authorized by nearby search. Precise retention, coarse-cell size and
location analytics are `OWNER_DECISION_REQUIRED` with privacy/legal review.

