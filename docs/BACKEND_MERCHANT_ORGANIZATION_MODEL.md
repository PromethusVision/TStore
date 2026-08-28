# Backend Merchant Organization Model

**State:** PROPOSED — OWNER_DECISION_REQUIRED
**Implementation:** NONE

## Separation

`AUTH USER`, `MERCHANT ORGANIZATION` and `SHOP` are different subjects. A user
authenticates; an organization is the governed merchant boundary; a shop is a
physical/local selling location. Current `shops.owner_user_id` remains the active
compatibility contract until an authorized membership migration exists.

## Proposed organization responsibilities

- stable merchant identity, lifecycle and policy state;
- membership root and organization-wide capabilities;
- shared business-facing configuration that is not shop-specific;
- links to one or more shops without absorbing their physical identity;
- audit subject for verification, suspension and governance.

An organization does not own canonical product truth, customer data, review
content or ad/reward/reputation decisions. Those systems reference it under their
own contracts.

## Lifecycle

`CANDIDATE → ACTIVE → SUSPENDED → RETIRED` is a conceptual progression, not an
enum decision. Suspension blocks privileged merchant mutations under a bounded
policy; public historical facts and customer rights remain readable as required.
Transfer, merge or split requires explicit lineage, affected membership/shop
preview and audit.

## Evolution bridge

Pilot shops may map one-to-one to organizations initially, but the mapping must
be explicit. No migration should infer an organization from display name or grant
membership solely because a profile role says `merchant`.

## Open decisions

- organization legal-verification scope: `OWNER_DECISION_REQUIRED`;
- one-shop pilot auto-organization backfill rule: `OWNER_DECISION_REQUIRED`;
- organization transfer/merge semantics: `OWNER_DECISION_REQUIRED`.

**Recommendation:** introduce the organization only with Merchant App onboarding;
keep Customer App shop IDs and reads stable.
