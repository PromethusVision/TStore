# Verified Purchase Identity Model

Status: **OWNER REVIEW DRAFT — DESIGN ONLY**
Wave: 16, Work Package 12

The current canonical contract already stores an immutable server-derived
`product_id` snapshot in QR and verified transaction items. Future catalog layers
must extend historical clarity without replacing that durable evidence.

## Event identity envelope

A verified purchase item should conceptually retain:

| Fact | Purpose |
| --- | --- |
| Verified transaction/item ID | Immutable proof identity. |
| Canonical product ID at purchase | Review eligibility and durable product continuity. |
| Variant ID at purchase, when known | Exact configuration; absence does not invalidate current evidence. |
| Shop listing ID snapshot | Offer that was confirmed; not a durable FK dependency. |
| Shop ID/name snapshot | Merchant context. |
| Product/variant display snapshot | Historical customer-visible meaning after rename/merge/split. |
| Quantity, sell unit, unit price, line total | Commercial facts of the physical event. |
| Confirmed timestamp and actor/source | Server-authoritative provenance. |
| Pack/measure or component snapshot when material | Protects variable measure and bundle history. |

## Correction rules

- Never mutate the purchase event to make current catalog joins look clean.
- Rename and taxonomy move resolve through the same product ID.
- Duplicate merge adds a lineage projection from predecessor to survivor while
  retaining the recorded product ID and snapshot.
- Split maps to a successor only with deterministic snapshot evidence. Ambiguous
  events retain predecessor identity and remain eligible under an explicit owner
transition rule; they are never guessed.
- Listing deletion, shop closure or price change cannot invalidate the purchase.
- Bundle evidence records the purchased bundle and, where server-derived, component
  snapshots; later bundle composition does not rewrite it.

Review eligibility continues to use customer ownership plus durable product proof.
Whether successor mappings confer eligibility after a split is a P0 owner decision.
No client may submit identity or verification flags as authoritative evidence.
