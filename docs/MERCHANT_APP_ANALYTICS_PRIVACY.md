# Merchant App Analytics Privacy

Status: **PROPOSED — PRIVACY REVIEW REQUIRED**
Wave: 17 / WP43

## Minimum necessary data

Merchant analytics should expose aggregates needed to operate listings and shop presence, not customer profiles.

## Forbidden by default

- Customer name, email, phone, UUID or address.
- Individual wishlist, browsing, direction or review-reading history.
- Cross-shop customer journey or competitor performance.
- Raw QR token/session secrets.
- Small-cohort slicing that enables re-identification.

## Controls

- Shop/organization-scoped authorization and server-side aggregation.
- Minimum cohort/display thresholds and coarse time buckets where needed.
- Purpose-limited event retention and documented metric provenance.
- Internal/test/bot filtering without revealing individual event logs to merchant.
- Audit privileged analytics access and exports.

## Owner decisions

- `AN-01 P0`: Which customer-intent metrics launch and lawful basis/notice.
- `AN-02 P1`: Minimum cohort threshold.
- `AN-03 P1`: Retention and merchant export policy.
- `AN-04 P2`: Wishlist signal display; recommendation is aggregate only after threshold.
