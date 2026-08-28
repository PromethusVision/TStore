# Merchant App Custom Product Flow

Status: **PROPOSED — CATALOG OWNER DECISIONS OPEN**
Wave: 17 / WP22

## Scope

Supports handmade, local, unbranded or legitimately barcode-free physical products without forcing a fake brand/barcode. It does not allow arbitrary duplication of existing canonical products.

## Flow

- Search and likely-match review first.
- Select `UNBRANDED`, `HANDMADE` or other governed provenance where applicable.
- Provide minimum stable identity: customer-facing name, taxonomy leaf, distinguishing facts and allowed evidence.
- Submit candidate; policy-sensitive categories fail closed.
- On approval, select canonical product/variant and create shop listing.

## Boundaries

- Repair labor and general service are outside Product Taxonomy; separate service scope remains TBD.
- Made-to-order products, personalization and bundles need owner decisions (`CAT-08`, `CAT-12`).
- Merchant-created description/media does not automatically become canonical shared content.
- No-barcode reuse threshold remains owner decision; lack of barcode alone never proves uniqueness.

## UX

Use plain Turkish (“Markasız”, “El yapımı”, “Barkodu yok”) and explain why review may be needed. Preserve draft and prevent duplicate submissions.
