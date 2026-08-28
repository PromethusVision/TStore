# Backend Availability Contract

**State:** PROPOSED — NO PERFECT REAL-TIME STOCK CLAIM

Availability is a listing-owned statement with evidence and freshness. Recommended
conceptual states are `KNOWN_IN_STOCK`, `KNOWN_OUT_OF_STOCK`, `UNKNOWN` and
`RETIRED`; exact enum remains open.

## Rules

- `UNKNOWN` is not in stock and must not be silently ranked/advertised as such;
- source, observed time and freshness window accompany the state;
- explicit merchant update and future integrated stock are different provenance;
- public display may say “mağazaya sor” for unknown under owner-approved UX;
- QR issue revalidates active shop/listing; it does not prove current inventory;
- purchase confirmation snapshots what was confirmed, not a stock decrement system;
- retirement and policy block are separate from temporary out-of-stock.

The pilot need not promise exact quantity. Ads may require stricter fresh-known
availability than organic discovery. Domain freshness and whether unknown may be
advertised are `OWNER_DECISION_REQUIRED`.

