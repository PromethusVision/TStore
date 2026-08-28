# Backend Taxonomy Change Contract

**State:** PROPOSED — NO TAXONOMY RUNTIME CHANGE

| Change | Identity behavior | Dependent behavior |
|---|---|---|
| Rename | Keep node ID; new display revision | Search/snapshots retain prior label where historical |
| Move | Keep node ID if semantics unchanged | Recompute paths and policy checks |
| Split | New child IDs; predecessor retained | Products require evidence; ambiguous rows remain unresolved |
| Merge | Survivor/new successor plus lineage | Resolve duplicate assignments and policy compatibility |
| Retire | Stop new assignment | Preserve historical references and successor guidance |

Changes require impact preview across products, listings, search/facets, ads,
rewards, badges, reputation and analytics. Category-explorer achievements must use
stable IDs/rule versions, not mutable paths.

No automatic product reassignment based only on a node name. Split/merge semantics,
grandfathering and policy transitions are `OWNER_DECISION_REQUIRED`. Every rollout
needs versioned reads and backward compatibility before old paths retire.
