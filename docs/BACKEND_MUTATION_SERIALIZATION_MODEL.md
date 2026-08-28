# Backend Mutation Serialization Model

**State:** PROPOSED

Serialize only on the smallest authoritative business subject to protect an
invariant; avoid global locks.

| Subject | Protected invariant |
|---|---|
| QR session | one terminal consumption / one transaction |
| customer + product | one active review |
| active cart customer/shop | one coherent single-shop cart mutation |
| listing | monotonic revision and SKU/price/availability consistency |
| membership | no lost capability/scope or revoke race |
| campaign budget envelope | no overspend/double reservation |
| reward account/source event | no duplicate value |
| product lineage operation | one compatible merge/split transition |

Use conditional state updates, row/advisory locks or unique constraints according
to implementation evidence. Define lock order for multi-entity operations, bound
waits and return retryable conflict separately from policy denial. Never use a
client mutex as the only protection.
