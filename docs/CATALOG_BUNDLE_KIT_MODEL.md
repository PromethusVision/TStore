# Bundle / Kit Catalog Model

Status: **OWNER REVIEW DRAFT — NO PROMOTIONS ENGINE**
Wave: 16, Work Package 7

A bundle is a sellable composition, not automatically a taxonomy category. Each
component retains its own canonical product owner and taxonomy placement.

## Bundle types

| Type | Catalog identity | Components | Listing behavior |
| --- | --- | --- | --- |
| Manufacturer bundle | Canonical bundle/product with responsible manufacturer and, when present, own GTIN | Fixed, governed bill of materials | Many shops may list the same bundle. |
| Fixed retail set/kit | Canonical set when composition and packaging are stable/repeatable | Fixed quantities; substitutions create a new version/identity | Shared listing reuse allowed. |
| Merchant-created bundle | Merchant-scoped bundle listing/candidate | Explicit component snapshots and quantities | Not automatically promoted to global canonical identity. |
| Multipack | Pack variant/product, not general bundle | Repeated same component | Governed by pack quantity model. |
| Virtual promotion | No new product identity | Existing line items combined by an offer rule | Outside catalog; historical transaction records actual items. |

Examples such as keyboard + mouse sets, tool kits, cosmetic gift sets, school
supply sets, cookware sets and gaming bundles follow the same composition test.
A title containing “set”, “kit” or “bundle” is not enough.

## Required conceptual facts

- bundle ID and type;
- responsible creator/manufacturer and provenance;
- fixed versus substitutable composition;
- component product/variant identities and quantities;
- packaging/net content and global identifier when valid;
- lifecycle and version/effective interval;
- policy result for both the bundle and every component.

## Identity and correction rules

- Composition change is identity-bearing for a fixed bundle. Minor packaging text
  can be a metadata correction when contents remain identical.
- Merchant substitutions in a flexible offer are listing events, not silent edits
  to a canonical fixed set.
- A bundle cannot hide an excluded or regulated component; policy evaluates all
  components and the complete offer.
- Search may group a bundle near components but must label it as a set and never
  merge it with a component.
- Reviews for a manufacturer/fixed canonical bundle attach to the bundle product.
  Component reviews are not copied. Merchant-created bundle feedback, if ever
  supported, must not pollute component product aggregates.
- Verified purchase snapshots retain bundle identity plus component snapshot when
  known so later composition changes remain auditable.
