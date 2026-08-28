# Merchant App Activity History

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP51

## Merchant-visible history

- Listing created/retired, price and availability changes.
- Shop profile/status/location change requests and outcomes.
- Catalog candidate/exception status.
- QR verification outcomes at a safe operational level.
- Staff invite, capability and membership changes for authorized owners.

## Audit vs activity

Activity history is a readable projection. Security/audit evidence may contain restricted actor/provenance details and has separate retention/access. Hiding an activity item does not delete audit or verified transaction evidence.

## Requirements

- Server timestamp, shop scope, actor display class, action, target and outcome.
- Before/after values only when safe; redact sensitive fields.
- Stable pagination and deterministic ordering.
- Filters by shop, event family and time.
- No customer identity, raw token or another merchant's data.

Export, retention and staff visibility remain owner decisions.
