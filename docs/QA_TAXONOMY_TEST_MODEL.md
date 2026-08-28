# Taxonomy Test Model

**State:** PROPOSED — NO TAXONOMY MUTATION

## Structural checks

- exact expected node counts by level and target state;
- one parent for every non-root node and no cycles/orphans;
- maximum depth four and assignable leaves explicitly marked;
- duplicate display name/slug rules scoped correctly;
- immutable stable ID distinct from mutable Turkish name, slug and path;
- exactly one primary product leaf per product;
- brand and attribute/facet never introduced as category.

## Change checks

| Change | Acceptance |
|---|---|
| Rename | stable ID retained; old display/slug alias classified |
| Move | semantic identity decision recorded; parent changes without ID-from-path |
| Merge | all predecessors map to one successor; aliases/history preserved |
| Split | successor set and classification rule explicit; ambiguous products held |
| Retire | historical resolution works; new assignment denied |
| Proposal finalization | target state changes only with recorded owner approval |

## Search checks

Separate search synonyms from legacy redirects. Test Turkish casing/diacritics, singular/plural, controlled aliases, ambiguous terms and no result. Search must not silently map a split predecessor to one child.

## Current boundary

Owner-final L1 and selected Electronics/Computer subtrees coexist with proposal-only domains and a 651-node legacy reconciliation. Tests must preserve `CANONICAL_FINAL` versus `PROVISIONAL_PROPOSAL`; current runtime rollout remains pending.

`TAXONOMY_RUNTIME_CERTIFIED: NO`
