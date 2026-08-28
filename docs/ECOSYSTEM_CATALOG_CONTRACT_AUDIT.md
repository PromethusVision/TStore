# Ecosystem Product / Variant / Listing Contract Audit

**Result:** PASS WITH OWNER-GATED V1 DEPTH

| Concern | Canonical owner | Reconciled rule |
|---|---|---|
| product identity/name/core facts | platform catalog | shared physical identity; merchant submits evidence/candidate only |
| variant choice identity | platform catalog | explicit when domain correctness requires; no universal V1 backfill |
| taxonomy assignment | platform taxonomy/catalog | one stable primary leaf plus facets; hierarchy rename does not change product ID |
| barcode/GTIN/MPN | assertion/evidence | strong but fallible; never blind auto-link authority |
| price | shop listing | no universal canonical price |
| availability/freshness | shop listing | honest known/unknown/stale semantics; not perfect stock claim |
| merchant SKU | listing in merchant namespace | not canonical identifier |
| canonical media | platform/reviewed promotion | listing photo cannot auto-replace canonical media |
| listing media | authorized shop | rights/policy checked and listing-scoped |
| reviews | canonical product evidence | not listing/campaign owned; shop cannot edit |
| Ads sponsored object | exact eligible listing if Ads launches | campaign does not own listing/product identity |

## Correction rules

- Rename/move keeps stable identity and aliases.
- Merge is allowed only with evidence; predecessor IDs and review/purchase lineage
  remain queryable.
- Split creates explicit successor relationships; ambiguous history remains on the
  predecessor/unresolved lane.
- Retire suppresses future use while preserving history.
- Candidate is never automatically active canonical truth solely because a merchant
  submits or pays.

Open roots: domain variant dimensions, variable measure pilot activation, candidate
activation, merge review collision and regulated allowlist.

`CATALOG_IDENTITY_INVARIANTS: PASS`
