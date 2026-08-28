# EsnaftaVar Taxonomy Change Event Model

**State:** `PROPOSED — TAXONOMY PROPOSALS REMAIN PROPOSALS`

| Change | Candidate event | Identity/history rule |
|---|---|---|
| Rename | `taxonomy_node_renamed` | Stable node ID retained; prior label/slug becomes governed alias |
| Move | `taxonomy_node_moved` | ID retained if concept unchanged; old and new parent/version recorded |
| Split | `taxonomy_node_split` | Predecessor retires; multiple successor IDs; no arbitrary redirect |
| Merge | `taxonomy_nodes_merged` | All predecessor IDs retained; explicit successor and effective version |
| Retire | `taxonomy_node_retired` | Historical identity stays addressable; new assignment disabled |

Events include taxonomy version, decision/provenance reference, effective time,
predecessor/successor IDs and policy impact—not full mutable tree payloads.
Proposal review activity is not published as a canonical change.

Analytics offers two explicit projections: `EVENT_TIME_TAXONOMY` preserves what was
true when the fact occurred; `CURRENT_TAXONOMY_ROLLUP` follows versioned successor
edges and labels ambiguity. Splits are not backfilled to children without
deterministic evidence. Search aliases and identity redirects are different data.

The 24 L1 set can be referenced where owner-final in source; the 22-domain L2
proposal set and merchant sector proposal are not finalized by this document.

`TAXONOMY_EVENT_MODEL_FINALIZED: NO`
