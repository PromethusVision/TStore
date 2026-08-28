# Catalog Edit Governance

Status: **OWNER REVIEW DRAFT — NO PERMISSION IMPLEMENTATION**
Wave: 16, Work Package 30

Editing means submitting or resolving sourced assertions. Authority follows the
field layer, not possession of a product page.

## Authority matrix

| Actor | Canonical data | Listing data | Policy data | Taxonomy assignment |
| --- | --- | --- | --- | --- |
| Merchant | Propose new/correction with evidence | Edit own shop price, availability, SKU, local content/media | Supply evidence; cannot approve | Receive suggestions/propose correction; cannot finalize root rules |
| System | Normalize, validate, detect conflict, derive projections | Validate/freshness checks | Apply owner-approved deterministic rules fail-closed | Suggest from governed taxonomy/rules |
| Admin/catalog steward | Resolve evidence-backed canonical conflicts, merge/split under gates | Intervene for abuse/policy with audit | Apply approved policy; escalate legal/owner ambiguity | Apply owner-final taxonomy and controlled mappings |
| Trusted importer | Submit covered fields within contract | Only when explicitly delegated | Never exceeds contract/evidence authority | Map only to approved stable identities |
| Product owner/legal owner | Decide root product/policy behavior | Set platform rules, not merchant facts | Finalize P0 policy/product choices | Finalize taxonomy/product boundary decisions |

## Field controls

- Brand/manufacturer/model, GTIN/ISBN/MPN, pack, variant dimensions, canonical media,
  primary leaf and product lifecycle require governed evidence.
- Merchant owns only its listing; cross-shop agreement is evidence, not edit rights.
- Policy-sensitive and merge/split edits require separation of proposal and approval.
- Normalized equivalent edits may auto-apply under a versioned rule; semantic changes
  create a new assertion and review impact analysis.
- Self-approval is forbidden where the actor benefits from a canonical/policy change.

## Change gates

Every mutation requires actor, reason, before/after, provenance and rule version.
High-impact changes preview affected listings, reviews, verified purchases, search,
wishlists/cart, analytics and aliases. P0 changes require explicit owner policy and a
reversible plan. Bulk import cannot bypass per-field validation or audit.
