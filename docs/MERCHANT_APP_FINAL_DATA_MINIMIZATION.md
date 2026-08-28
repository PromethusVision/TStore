# Merchant App Final Data Minimization Pass

Status: **PROPOSED — PRIVACY/SECURITY REVIEW REQUIRED**
Wave: 17 / WP114

## Keep

- Auth reference, scoped merchant membership and minimum security events.
- Merchant/shop public facts plus minimum private verification/support data.
- Listing price/availability/SKU and governed catalog provenance.
- Opaque QR fingerprint, authoritative result and immutable transaction/item snapshot.
- Aggregated metric inputs needed for approved definitions.
- Audit fields needed for security, conflict and support.

## Remove or avoid

- Customer PII in QR, analytics, merchant activity or notifications.
- Raw QR tokens in logs/history/support.
- Staff payroll/personnel details.
- Merchant live-location trails; only shop location.
- Exact stock counts when product does not promise inventory management.
- Free-form policy documents/notes beyond necessary evidence references.
- Cross-shop competitor data and customer-level analytics.
- Speculative ads/reward/badge fields in core records.

## Final checks before implementation

Every API projection declares audience and fields; every stored event declares purpose/retention; every export/deep link rechecks scope; secrets remain server-side. Deletion and immutable evidence retention are distinguished rather than handled by broad cascade assumptions.
