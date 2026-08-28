# Ecosystem Source Inventory

**Inventory date:** 2026-08-28

**Base:** `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63`

**Consumption:** READ-ONLY; SOURCE BRANCH MERGES = 0

| Foundation | Remote HEAD | Primary evidence | Consumed state |
|---|---|---|---|
| Customer commercialization | `1f1812cf9d65cd9ea4c8053f98f9a3c1342caeaa` | `CUSTOMER_APP_COMMERCIALIZATION_READINESS.md`, `CUSTOMER_APP_MINIMAL_COMMERCIAL_V1.md` | CONDITIONAL / pilot recommendation |
| Canonical catalog | `b654e680ca72a79c109a098a237b9813b24516cc` | canonical identity, V1 scope, owner roots | OWNER REVIEW DRAFT / PROPOSED |
| Merchant taxonomy | `b60254d4d666a860e02989b617ea649cbb8b91dd` | sector identity/readiness/proposal | PROPOSED; confirmed beauty exception only |
| Merchant App | `2946e49194a29ddb247a47fd077110d2d681b84a` | master blueprint, minimal V1, owner roots | PROPOSED |
| Sponsored Ads | `43135b99d6187de205bd431fd780d9871ad61e02` | V1/future, owner roots, contrarian | PROPOSED |
| Reward/Gamification/Reputation | `e1b0fa44454fc06d353e560d401d69cbac54cde3` | master blueprint, pilot review, owner roots | PROPOSED / RECOMMENDED |
| Operations/Trust & Safety | `f015bb94bae6a4bf6dd6f02fffb419322d08d596` | product contract, owner roots, pilot monitoring | PROPOSED / RECOMMENDED |
| Analytics/Observability | `1045301e90440903481300bec27b6fea11da1655` | event identity, owner roots, pilot KPI/monitoring | OPTIONS / RECOMMENDED; nothing final |
| Backend contracts | `bbcb5f34b535c3ed910f0291d1125c8dd012389e` | master blueprint, owner roots, V1 scope | PROPOSED / RECOMMENDED |
| QA/Release | `a09cb31d9deb522a49da3c4e9878b69bfa5fc25d` | QA product contract, release checklist/gates | PROPOSED |
| Facet/Search | `900a009478a7531362c376ccf9a2ca55ebe04117` | facet/search readiness and registries | NEEDS_MINOR_REFINEMENT; not final |
| Legacy taxonomy reconciliation | `14ecb5a4aeb16946e7454cc20dbdf2c5f7b2711e` | source audit, split/merge, readiness | AUDIT COMPLETE; runtime not performed |

## Owner-final evidence

- `ESNAFTAVAR_CATEGORY_TAXONOMY_V1_FINAL.md` and its machine artifact identify
  Product Taxonomy V1 as FINAL (`v1.0.0`, 2026-08-25).
- Explicitly owner-confirmed subtrees/decisions remain final only at their documented
  scope; they do not finalize Merchant Taxonomy, facets, runtime mapping or policy.
- Existing Customer QR/review behavior proven in main is a working canonical
  contract. Foundation recommendations cannot silently revise it.

## Non-final evidence

Merchant Taxonomy, canonical catalog future architecture, Merchant App, Ads,
Reward/Gamification/Reputation, Ops, Analytics, Backend and QA/Release documents
use PROPOSED/RECOMMENDED/OPTIONS/HYPOTHETICAL states. Recommendations are not owner
choices and are not implementation authorization.

## Provenance rule

Branches inherit many shared historical documents. An artifact is attributed to a
foundation only when its system prefix/commit purpose belongs to that branch.
Duplicate inherited copies are context, not independent approvals.
