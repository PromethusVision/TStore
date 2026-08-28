# Test Data Architecture

**State:** PROPOSED

| Class | Meaning | Mutability | Environment |
|---|---|---|---|
| Fixture | small in-test object/input with explicit expected outcome | recreated per test | local |
| Seed | versioned dataset for reproducible schema/journey baseline | idempotent or local reset | local/authorized Development |
| Synthetic | generated non-personal actor/product/shop/event | run-scoped | local/Development |
| Demo | stable customer-visible demonstration catalog | governed product artifact | currently Production demo, read-only to tests |
| Live | remote provider/platform state used by opt-in acceptance | tightly bounded | Development; Production smoke only |

## Ownership and lineage

Every mutable record carries test suite, run ID, created time, environment and cleanup locator outside customer-visible text where schema permits. Fixtures use deterministic semantic inputs; execution instances use unique IDs where parallel isolation matters. Expected results are versioned with the contract they validate.

## Separation

Demo records are not generic mutable test fixtures. Production data is never copied into local tests. Test accounts, QR purchases, reviews, ad/reward events and analytics are excluded from business outcomes. Media fixtures contain no faces, identity documents or copyrighted production assets.

## Drift control

Seed generation has a check mode; tracked output must reproduce byte-for-byte. Schema change updates seed and cleanup in the same reviewed change. A test that depends on implicit pre-existing remote data is non-deterministic and cannot be a merge gate.

`TEST_DATA_SOURCE_OF_TRUTH: OWNER_DECISION_REQUIRED`
