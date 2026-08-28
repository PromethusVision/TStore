# Merchant App Shop Location Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP12

## Proposed capture flow

1. Merchant enters/searches address.
2. Device GPS or geocoding suggests a pin; permission is optional and purpose-specific.
3. Merchant corrects pin manually on map.
4. System compares structured address, district boundary and coordinate plausibility.
5. Merchant previews customer-facing map/address.
6. Risky mismatch becomes `LOCATION_REVIEW_REQUIRED`; it is not silently accepted.

## Conceptual fields

- Structured address components and customer display address.
- Latitude/longitude with source (`GPS`, `GEOCODE`, `MANUAL`).
- Accuracy/confidence and last verified timestamp.
- District/neighborhood reference where available.
- Branch/shop relation and customer visibility setting.
- Review status/reason class; not implementation schema.

## Safety rules

- Exact coordinate must be within valid geographic ranges.
- GPS denial does not block manual entry; no exact location collected without purpose.
- A branch move is a high-impact change and should not silently reuse old proximity cache.
- Nearby ranking uses server-approved/current coordinate, not unreviewed device draft.
- Home-based or sensitive-address merchants require a separate privacy decision; do not assume public exact pin.

## Open decisions

- `LOC-01 P0`: Which business types may hide or fuzz exact customer-facing location?
- `LOC-02 P1`: Activation threshold for district/address mismatch.
- `LOC-03 P1`: Who may approve a shop move and whether step-up auth is required?
