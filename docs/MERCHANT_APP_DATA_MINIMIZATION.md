# Merchant App Data Minimization

Status: **PROPOSED — PRIVACY REVIEW REQUIRED**
Wave: 17 / WP61

## Collection test

Every field/event must have documented purpose, authorized audience, retention, deletion/immutability rule and minimum precision. “Might be useful later” is not a purpose.

## Minimize by domain

- **QR:** opaque token input; no customer identity in code/log; merchant sees purchase context only.
- **Analytics:** shop/product aggregates; no individual customer journeys.
- **Onboarding:** only required identity/policy evidence; restricted access.
- **Catalog:** product/listing facts and provenance; no unrelated personal details.
- **Location:** public shop coordinate/address, not merchant/staff live location history.
- **Staff:** membership contact/role/security events only; no payroll/personnel profile.
- **Support:** safe correlation IDs and reason classes; secrets/raw tokens excluded.

## Lifecycle

Draft, rejected, expired invite, audit, policy evidence and immutable verified evidence require distinct retention policies. Account/shop closure does not imply deletion of legally/security-relevant evidence; it also does not justify indefinite raw data retention.
