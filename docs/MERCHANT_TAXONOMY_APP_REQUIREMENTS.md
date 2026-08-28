# EsnaftaVar Merchant Taxonomy — Future App Requirements

**State:** REQUIREMENTS ONLY — NO SCREEN, RUNTIME OR BACKEND IMPLEMENTATION

## 1. Current-state constraints observed read-only

The current canonical shop schema stores shop identity/contact/location/opening
hours/activity/rating and owner relation, but no merchant-sector identity,
primary/secondary assignment, operating model, policy status or sector history. The
current unique owned-shop constraint also models at most one shop per owner account.

Project state records merchant role/login, shop create/edit and QR scanner as partial;
merchant catalog/stock/price management and analytics are not implemented. These are
facts for future planning, not authorization to change schema or code in this wave.

## 2. Taxonomy data contract the app will need

- versioned merchant-sector tree with immutable IDs;
- Turkish display names, definitions, controlled search aliases and hierarchy;
- assignable/non-assignable and active/retired state;
- owner state (`PROPOSED` must never ship as final without approval);
- one effective primary plus zero-to-three effective secondary assignments;
- `RETAIL/SERVICE/MIXED` operating model separate from sector;
- policy class and server-authoritative verification state separate from sector;
- predecessor/successor guidance for rename/move/merge/split/retire;
- no dependency on Product Taxonomy IDs or paths.

## 3. Onboarding sector selection

Future Merchant App must support:

- search by canonical name and controlled Turkish aliases;
- browse through non-assignable families to assignable leaves;
- short inclusion/exclusion definitions;
- exactly one primary selection;
- optional suggested secondaries within the owner-approved limit;
- unresolved “other” request without publishing arbitrary free text;
- targeted regulated-sector notice and review state;
- idempotent save/retry and resume;
- the exact confirmed beauty leaves, with no `Unisex Kuaför`.

Sector selection cannot grant merchant Auth role or regulated capabilities.

## 4. Dashboard contextualization

Sector can influence low-risk defaults such as:

- terminology/examples;
- likely catalog shortcuts;
- relevant help articles;
- optional policy checklist visibility;
- suggested Product L1/L2 discovery entry points;
- later sector-specific benchmark availability.

It must not hide cross-domain products, force one Product L1, rewrite catalog
categories or assume services/booking exist.

## 5. Catalog defaults

- Use merchant→product mapping as optional suggestions only.
- Merchant may create/list products from any approved Product Taxonomy leaf.
- Every physical product is classified independently.
- Sector changes do not bulk-move products.
- Product-tree changes do not rewrite merchant sector.
- Regulated sector does not authorize regulated products; product policy remains per
  SKU.
- Service-only merchants may have no product catalog.

## 6. Merchant profile and customer discovery

Customer-facing merchant profile may need:

- primary sector label;
- a limited, owner-approved presentation of secondaries;
- retail/service/mixed indicator only if useful and understandable;
- verified regulatory/business badges only from server-authoritative evidence;
- current sector labels resolved from stable IDs;
- search match through aliases without displaying every alias;
- retired/changed sector continuity.

The profile should not present raw NACE codes as its main label.

## 7. QR and verified-purchase flows

Existing QR purchase confirmation should remain sector-agnostic:

- merchant ownership/auth and immutable cart/price snapshots control confirmation;
- sector does not relax merchant authorization or transaction integrity;
- a sector change does not invalidate genuine historical transactions;
- reviews/badges remain server-authoritative;
- future service verification, if approved, needs its own evidence contract rather
  than pretending a service is a product purchase.

No QR, review or purchase code is changed here.

## 8. Reviews and badges

- Merchant reviews can report current sector for discovery while preserving
  historical merchant identity.
- Product reviews stay tied to verified product purchase and Product Taxonomy.
- A future service review needs a typed service subject and explicit owner decision.
- `Optik`, `Kuyum`, `Medikal` or similar label is not itself a verified badge.
- Verification expiry/revocation must be independently represented.

## 9. Sector-specific statistics later

Potential future dashboard comparisons must:

- use stable sector ID and effective history;
- distinguish primary from secondary membership;
- disclose minimum sample/eligibility rules;
- keep Product Taxonomy analytics independent;
- avoid exposing sensitive policy/verification evidence;
- avoid claiming causal performance from sector alone.

The current project has no analytics/event infrastructure. This requirement does not
select or add one.

## 10. Sector change and governance UX

- Show current primary/secondaries and effective status.
- Allow correction requests with plain-language reason.
- Re-run applicable policy review for controlled target sectors.
- Handle retired nodes with successor choices; never silently resolve a split.
- Preserve previous assignment history.
- Explain customer-facing impact before confirmation.
- Do not alter catalog categories as a side effect.

## 11. Offline, loading and error behavior

A future implementation should fail safely:

- do not publish a stale/unknown sector after taxonomy-version mismatch;
- cached browse may be read-only, but final save validates the active version;
- duplicate submission must be idempotent;
- partial secondary-save failure must not create two primaries;
- policy-review timeout remains pending, not approved;
- alias ambiguity opens disambiguation, not first-result selection.

## 12. Privacy/security requirements

- Merchant client cannot self-award role, verification or compliance badge.
- Evidence documents and detailed licence data use restricted server-side handling
  in any future design.
- Customer-facing UI exposes only approved status/necessary public facts.
- Audit history records source/status without leaking sensitive evidence.
- Sector search telemetry, if later added, needs privacy review.

## 13. Explicit non-requirements for this phase

- full Merchant App screen design;
- DB/schema/migration;
- Product Taxonomy implementation;
- booking, reservation, staff/calendar or service-price model;
- analytics provider/event implementation;
- Auth/role changes;
- QR/review changes;
- remote Production/Development configuration.

## 14. Owner decisions blocking implementation design

1. Final merchant tree and parent assignability.
2. Secondary-sector limit and evidence rules.
3. Breadth: product-adjacent merchants only or broader local services.
4. Regulated-sector allowlist, evidence and review owner.
5. Customer-facing secondary/operating-model presentation.
6. Branch/multi-location account model.
7. Booking/reservation/service-price remains a separate `TBD` decision.

`MERCHANT_APP_TAXONOMY_REQUIREMENTS: READY_FOR_OWNER_REVIEW`

`APP_IMPLEMENTATION_PERFORMED: NO`
