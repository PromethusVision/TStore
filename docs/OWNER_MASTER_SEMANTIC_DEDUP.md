# Owner Master Semantic Deduplication

State: `31 MASTER ROOTS — 8 PRODUCT OWNER FINAL — 23 OPEN`

## Reconciliation result

| Metric | Count |
|---|---:|
| Raw source decisions | 204 |
| Unique source keys | 204 |
| Existing-root anchors | 15 |
| Genuinely new roots | 16 |
| Final master roots | 31 |
| Duplicate/child/dependent/detail rows removed from owner queue | 173 |

The 173 rows did not disappear. Each remains represented once in
`OWNER_MASTER_RAW_DECISION_INVENTORY.csv` and maps to one root in
`OWNER_MASTER_DECISION_APPLY_MAP.csv`.

## Classification reconciliation

| Classification | Rows | Treatment |
|---|---:|---|
| `EXISTING_ROOT` | 15 | Wave 25-derived master root anchor |
| `NEW_ROOT` | 16 | New evidence justifies a distinct master root |
| `CHILD_OF_EXISTING_ROOT` | 70 | Answered inside its root, never asked separately |
| `DEPENDENT_DECISION` | 81 | Asked only if its parent answer makes it material |
| `AUTO_RESOLVABLE_AFTER_PARENT` | 1 | Engineering applies the selected parent rule |
| `PROFESSIONAL_REVIEW_ONLY` | 1 | Routed out of the owner choice queue |
| `IMPLEMENTATION_DETAIL_NOT_OWNER_DECISION` | 6 | Codex/engineering resolves under the contract |
| `DEFERRED_FUTURE_DECISION` | 14 | Retained, but not asked for the first pilot |

## Wave 25 bridge

Wave 25 had 18 roots. Wave 31 preserves the substance of 16, but only 15
distinct master roots are needed because two pairs are semantically merged.

### Materially unchanged — 4

- R03 → `OM-R06` taxonomy/demo activation
- R04 → `OM-R07` Product/Variant/Listing identity
- R05 → `OM-R08` catalog intake/measure/media
- R15 → `OM-R30` Reward timing/economics

### Expanded or merged with newer evidence — 12

- R01 → `OM-R04`: adds cohort/distribution separation and Wave 29 final
  acceptance evidence.
- R02 → `OM-R05`: adds location timing, registration boundary and AuthGuard.
- R07 → `OM-R09`: adds single-owner cohort and measured multi-staff trigger.
- R08 + R09 → `OM-R10`: sector taxonomy, verification and launch allowlist become
  one policy-perimeter root.
- R10 → `OM-R12`: adds merchant self-service freshness and explicit unknown state.
- R11 → `OM-R13`: adds rollout timing and PII-minimized merchant history.
- R12 → `OM-R11`: replaces the abstract app-shape question with three concrete
  operating models.
- R13 → `OM-R29`: Ads timing remains the parent; object/economics/privacy are
  conditional children.
- R16 → `OM-R27`: separates public reputation timing from later algorithms.
- R17 → `OM-R14`: adds staffing, support coverage, pause authority and
  compensating audit controls.
- R18 → `OM-R15`: adds pilot KPI purpose, baseline and minimum monitoring.

### Demoted from independent owner root — 2

- R06 catalog correction history: immutable lineage and no silent evidence loss
  are existing architecture invariants. Only a future ambiguous customer-facing
  collision policy may need a bounded follow-up under `OM-R07`.
- R14 Ads economics/privacy: not material unless `OM-R29` enables Ads. It is an
  auto-gated child of the Ads timing root.

## Genuinely new roots — 16

- Pilot: `OM-R01`, `OM-R02`, `OM-R03`, `OM-R16`, `OM-R17`, `OM-R31`
- Compliance surface: `OM-R18`
- Customer UI: `OM-R19`–`OM-R24`
- Unified evaluation: `OM-R25`, `OM-R26`
- Reputation algorithm/meta badge: `OM-R28`

## Contrarian burden reduction

- Product Owner is not asked to choose CI vendor, exact persistence schema,
  Bayesian prior, app packaging mechanics, motion defaults or audit-log columns.
- Regulated legality, KVKK text, tax treatment and domain licensing are routed to
  professionals; the owner chooses only business scope after/subject to input.
- Public Ads, Reward, badges and meta badges are retained as four post-pilot
  roots, not mixed into the pilot session.
- The 15 Wave 29 UI roots become six UI-specific roots plus two already-global
  gates; seven staged/default details are not separate owner questions.

`SEMANTIC_DUPLICATE_ROOTS: 0`

`ORPHAN_SOURCE_DECISIONS: 0`

`OWNER_FINAL_OPTIONS: 8`

`OWNER_OPEN_ROOTS: 23`
