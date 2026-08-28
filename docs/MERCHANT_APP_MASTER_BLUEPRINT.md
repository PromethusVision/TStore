# Merchant App Master Blueprint

Status: **PROPOSED — EXECUTIVE OWNER REVIEW**
Wave: 17 / WP100

## Mission

A separate operations companion that lets local merchants maintain shop/listing truth and server-authoritatively verify physical purchases. It complements Customer App; it is not Customer App with role-specific buttons.

## Minimal V1

Sixteen must-have capabilities: secure auth/context/authorization, fail-closed onboarding, shop profile/location/lifecycle, canonical search, listing/price/availability, candidate/custom/barcode flows, QR scan/security/reconciliation, audit and critical notifications. Seven SHOULD capabilities are removable from pilot; five areas deferred; ads/reputation/rewards remain future engines.

## Architecture

```text
AUTH USER -> MEMBERSHIP -> MERCHANT ORGANIZATION -> SHOP/BRANCH
CANONICAL PRODUCT -> OPTIONAL VARIANT -> SHOP LISTING
CUSTOMER QR -> ATOMIC SHOP CONFIRMATION -> VERIFIED TRANSACTION/ITEM EVIDENCE
```

Merchant sector, product taxonomy, catalog identity, listing, role, review, verified purchase, ad campaign and reputation/badge remain separate concepts.

## Critical contracts

- Search existing canonical product before candidate creation.
- Merchant owns shop listing price/availability/SKU, not canonical facts.
- QR uses opaque short-lived token, server time, shop binding, one-time atomic consume and status reconciliation; offline fails closed.
- One active review per customer + canonical product for life, based only on immutable verified evidence.
- Every mutation checks membership, shop scope, capability, lifecycle, policy and revision.
- Analytics is aggregate/minimized and never relabels intent as sales.

## Owner decision gate

42 raw questions reduce to 18 roots: P0 = 9, P1 = 7, P2 = 2. Resolve P0 policy/identity/shop/staff/catalog/candidate/QR/variable-measure/service/analytics decisions before backend/runtime design is frozen.

## Implementation sequence

Owner decisions → backend/versioned contract → separate app/config → auth/context → onboarding/shop → catalog/listing → candidate/custom → QR → approved reviews/analytics/notifications → pilot hardening and physical acceptance.

## Deliberately deferred

Online payment/order/shipping, ERP/accounting/WMS/CRM, full booking, bulk price, advanced multi-branch automation, merchant review replies by default, ads campaign manager, rewards and gamification.

## Readiness

Research architecture is ready for owner review. Runtime, backend, Production/Development and existing canonical documents are untouched. Catalog/backend remain major gaps until owner decisions and implementation phases.
