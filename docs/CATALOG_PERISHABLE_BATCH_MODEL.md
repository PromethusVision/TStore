# Perishable, Lot and Batch Model

Status: **OWNER REVIEW DRAFT — NO INVENTORY IMPLEMENTATION**
Wave: 16, Work Package 25

Expiry, lot and freshness describe a physical inventory cohort at a shop, not the
shared product identity. Formulation, net pack and storage requirement can be product
or variant facts; the dates printed on a particular unit are batch/listing facts.

## Ownership

| Fact | Layer |
| --- | --- |
| Recipe/formulation, package size, required storage class | Product/variant |
| Manufacturer lot/batch number | Listing inventory batch |
| Production/packing date | Listing inventory batch |
| Best-before/use-by/expiry | Listing inventory batch with policy semantics |
| Received/opened timestamp | Shop inventory event |
| Freshness/near-expiry claim | Derived from trusted dates and current time |
| Price/discount for a batch | Listing/batch offer |

## Rules

- Unknown expiry is explicit; it must not become a fabricated future date.
- Expired or unsafe inventory can block the batch/listing without retiring the
  canonical product sold safely elsewhere.
- Lot data may be sensitive operational information; customer display and retention
  should be limited to what policy and traceability require.
- Batch corrections are audited. Historical verified purchase retains observed lot/
  expiry only when captured authoritatively; absence does not get backfilled by join.
- Recall may target product, variant, lot, manufacturer or listing and is modeled as
  a policy/operational event, not an identity merge.
- Open foods and freshly made goods may use prepared-at/sell-by/freshness windows
  rather than manufacturer expiry; exact policy is domain/legal review.

V1 may support only availability plus optional expiry warning while deferring batch
inventory management. It must still keep batch facts out of canonical identity.
