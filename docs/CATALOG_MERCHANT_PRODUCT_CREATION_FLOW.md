# Merchant Product Creation Flow

Status: **OWNER REVIEW DRAFT — FUTURE MERCHANT APP, NO UI IMPLEMENTATION**
Wave: 16, Work Package 13

The default merchant action is to reuse an existing canonical product/variant and
create only a shop listing. Merchants should describe what they sell; they should
not be forced to design taxonomy.

## State flow

```text
SEARCH_EXISTING
  -> SELECT_PRODUCT
     -> SELECT_VARIANT
        -> ATTACH_SHOP_LISTING
  -> CREATE_VARIANT_CANDIDATE
     -> REVIEW_OR_SAFE_ACTIVATION
        -> ATTACH_SHOP_LISTING
  -> CREATE_PRODUCT_CANDIDATE
     -> CLASSIFY_AND_DEDUP
        -> REVIEW_OR_SAFE_ACTIVATION
           -> ATTACH_SHOP_LISTING
```

## Step contracts

1. `SEARCH_EXISTING`: accept barcode, manufacturer/model, plain name and the
   shop's prior catalog. Return grouped product/variant candidates with reasons.
2. `SELECT_PRODUCT`: confirm shared identity facts, never price/stock.
3. `SELECT_VARIANT`: choose a known size/colour/capacity/pack/fit. If none exists,
   propose only the missing dimension and evidence.
4. `CREATE_VARIANT_CANDIDATE`: dedup against sibling variants and validate the
   product's domain-specific required identity facts.
5. `CREATE_PRODUCT_CANDIDATE`: capture minimal name, physical type, maker/brand if
   known, pack/measure, identifier/evidence and photos; system proposes taxonomy.
6. `ADMIN/SYSTEM_REVIEW`: required for identifier conflict, ambiguous duplicate,
   regulated/excluded class, unsafe taxonomy, or merge-impacting change.
7. `ATTACH_SHOP_LISTING`: merchant sets price, availability/stock knowledge, local
   SKU, optional shop media/description and sell unit.

## Activation policy

Low-risk candidate activation versus mandatory review is an owner decision. A
candidate can remain non-discoverable while the merchant listing draft is saved.
Policy-sensitive items fail closed. Merchant contribution never grants authority
to overwrite canonical brand/model, identifier assignment, taxonomy or policy.

Every transition records actor, source and candidate-match evidence. Returning to
search after a possible duplicate is always supported; creating a duplicate must
never be the easiest path.
