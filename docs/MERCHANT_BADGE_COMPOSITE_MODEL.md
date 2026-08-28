# Composite and Meta Badge Model

**State:** OPTIONS ARCHITECTURE — OWNER DECISION REQUIRED

## Definitions

- **Base signal:** one eligible structured dimension aggregate.
- **Primary badge:** narrow claim derived from one dimension and safety gates.
- **Composite badge:** combines multiple primary dimensions/badges at the same subject scope.
- **Meta badge:** adds context such as region, time or standing to composite prerequisites.

## Prerequisite semantics

| Pattern | Benefit | Risk |
|---|---|---|
| all specified | strongest explainability | brittle if one dimension barely misses |
| any N of family | flexible | merchant strengths may be unbalanced |
| balanced dimensions | prevents one-dimension dominance | more complex thresholds |
| weighted score | tunable | opaque and easy to game |

Recommended research direction is specified or balanced prerequisites with independently satisfied
sample/confidence gates. Do not add primary badge averages together.

## Safety rules

- Same underlying customer contribution can support multiple dimensions but never count as multiple
  customers inside one requirement.
- Composite confidence is no stronger than its weakest required dimension unless an approved method
  explicitly models joint uncertainty.
- A hidden or revoked prerequisite cannot remain visually implied by the composite.
- Meta badges cannot bypass primary small-sample protection.
- Organization and shop badges never mix in one graph edge without explicit roll-up policy.

## Launch posture

Composite and meta badges should remain unavailable until primary badge meaning, false-positive rate,
fraud operations, appeal handling and customer comprehension are established.

`COMPOSITE_PUBLIC_LAUNCH: DEFER`
`OPAQUE_WEIGHTED_COMPOSITE: NOT_RECOMMENDED`

