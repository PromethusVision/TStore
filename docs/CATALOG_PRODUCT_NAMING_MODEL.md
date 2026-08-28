# Product Title / Display Name Model

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 18

## Name projections

| Projection | Purpose | Shape |
| --- | --- | --- |
| Canonical display title | Human-readable shared product/model | `[Brand if known] [Family/Model] [Product Type]` without seller claims. |
| Variant label | Distinguishes a selectable configuration | Concise ordered suffix such as colour, size, capacity, edition or pack. |
| Full customer title | Product plus selected variant | Canonical title + minimal variant suffix. |
| Search-normalized title | Retrieval only | Deterministic case/diacritic/punctuation normalization plus aliases; never displayed as truth. |
| Merchant listing label | Shop-local supplemental wording | Optional, moderated; cannot replace identity or inject global claims. |

## Rules

- Prefer structured brand, model, product type and pack fields over parsing a long
  title. Do not repeat the same term or taxonomy path.
- Pack quantity appears in the full title when it distinguishes the sellable unit.
- Model-number punctuation and leading zeros remain significant in structured data;
  search may add tolerant aliases without altering canonical display.
- Marketing superlatives, prices, stock, location, keyword lists, seller names and
  campaign text do not belong in canonical titles.
- Unbranded/custom products use clear functional descriptors and maker attribution
  when appropriate; they do not invent a “Generic” brand.
- Rename creates a permanent search/deep-link alias and retains stable product ID.

Generic examples: `Maker M20 Kablosuz Kulaklık — Siyah`; `Yerel Fırın Ekşi Mayalı
Ekmek — 500 g`; `Yazar / Eser — 2. Baskı, Ciltsiz`. The exact Turkish title grammar
and per-domain field order remain an owner/content-system decision.
