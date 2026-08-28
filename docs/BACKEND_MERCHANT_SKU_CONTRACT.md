# Backend Merchant SKU Contract

**State:** PROPOSED

Merchant SKU is a merchant-defined operational identifier for a listing. It is
not canonical product identity, GTIN or a cross-merchant lookup key.

## Contract

- normalized uniqueness is scoped to organization or shop as explicitly chosen;
- raw and normalized values are retained with safe display rules;
- reassignment to another live listing is prohibited without retirement/history;
- SKU mutation requires listing capability and expected revision;
- import retries use idempotency and report same-key/different-payload conflict;
- purchase history stores listing/product identity, not SKU alone.

Recommendation: organization namespace with explicit branch override only if real
merchant workflows require it. Namespace choice is `OWNER_DECISION_REQUIRED`.
