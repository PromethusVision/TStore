# Merchant App Shop Profile Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP11

## Customer-visible fields

| Field group | Examples | Rule |
|---|---|---|
| Identity | Display name, verified status if earned | Merchant cannot self-award verification |
| Location | Address display, map coordinate, neighborhood | Coordinate validation and privacy review |
| Contact | Public phone/channel if opted in | Separate from private support contact |
| Opening information | Weekly hours, temporary closure note | Informational; freshness timestamp |
| Merchant sector | Approved primary/secondary labels | Product taxonomy değildir |
| Shop status | Active/temporarily closed/closed | Server/policy state may override |

## Merchant-private fields

- Organization/legal/operator references needed for verification.
- Internal support contact and policy evidence.
- Staff memberships, permissions and invitation state.
- Internal notes, rejection details, audit actor and provenance.
- Merchant SKU, internal availability notes and unpublished drafts where applicable.

## Rules

- Public preview identifies exactly what customers will see.
- Private values never leak into customer APIs, analytics or QR confirmation context.
- Shop name/contact changes may require validation or moderation based on risk.
- Merchant sector may be one primary plus up to three secondary only as a proposal; not owner-final.
- Opening hours are not a guarantee that every listing is available.

## Validation hints

- Unicode-aware normalized display names; preserve legitimate Turkish characters.
- Explicit country/region/address structure plus coordinate, not a single opaque text field only.
- Contact and opening data have `updated_at`/freshness.
- Status reason codes are safe for merchant UX; sensitive policy notes remain private.

