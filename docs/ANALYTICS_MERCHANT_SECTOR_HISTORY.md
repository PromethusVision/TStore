# EsnaftaVar Merchant Sector Analytics History

**State:** `PROPOSED — 67-LEAF SOURCE REMAINS PROPOSAL`

Merchant sector and product taxonomy are independent dimensions. Each shop/branch
assignment should eventually be effective-dated against a stable opaque sector ID
and taxonomy version.

Event-time reports preserve the sector assignment effective at occurrence.
Current-sector reports may reproject through explicit rename/move/merge/split/
retire edges. A sector change does not rewrite the shop's historical events, and a
split does not allocate history to one child without evidence.

Multiple-sector assignment, primary-sector selection, change authority,
verification/policy gates and historical restatement are Product Owner/policy
decisions. Service/merchant sector cannot be inferred from products or search
queries, and product category cannot be inferred from merchant sector.

The source architecture contains 67 proposed assignable leaves; this document
does not finalize them.

`PRODUCT_MERCHANT_TAXONOMY_SEPARATION: REQUIRED`
