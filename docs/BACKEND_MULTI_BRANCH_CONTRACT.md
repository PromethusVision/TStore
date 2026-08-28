# Backend Multi-Branch Contract

**State:** PROPOSED — PILOT MAY REMAIN SINGLE-SHOP UX

## Definitions

- **Organization:** merchant governance boundary.
- **Shop/branch:** one customer-visible physical location and operational scope.
- **Listing:** branch/shop offer. Price and availability may differ by branch.

Current `shops` should map to shop/branch, not be collapsed into organization.
The Customer App keeps stable shop IDs, locations, seller comparison and listing
references.

## Rules

1. Every listing, QR confirmation, shop rating and location belongs to one shop.
2. Membership scope names exact shops or an explicit organization-wide grant.
3. Organization-wide catalog assistance cannot silently overwrite branch price or
   availability.
4. QR issued for Shop A cannot be confirmed by Shop B, even in the same
   organization, unless a future owner-approved shared-counter model exists.
5. Merchant analytics may roll up branches, but raw branch facts remain available.
6. Closing one branch retires its new operations without deleting purchases,
   reviews, ratings or listing history.

## Pilot bridge

The merchant interface may call the only shop “Mağazam”; backend identities must
still be shop-scoped. Creating phantom branches is unnecessary.

## Owner decisions

- organization-wide QR confirmation: recommend **NO** for V1;
- shared listing templates vs branch-owned listing copies:
  `OWNER_DECISION_REQUIRED`;
- shop rating roll-up to organization: recommend display branch truth first,
  aggregate only with transparent semantics.
