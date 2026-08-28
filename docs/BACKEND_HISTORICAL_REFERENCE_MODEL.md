# Backend Historical Reference Model

**State:** PROPOSED

Historical records retain stable entity IDs plus the minimum immutable snapshot
needed to explain what occurred. Current purchase items already demonstrate this
with canonical product identity and product/price/quantity snapshots.

## Rules

- names, paths, SKU, price and media are snapshots, never replacement IDs;
- retired/merged/split entities remain resolvable through restricted lineage;
- historical display distinguishes “then” snapshot from current entity state;
- unknown split mapping remains on predecessor rather than fabricated child;
- account deletion/pseudonymization preserves only purpose-approved subject links;
- access to history follows current purpose/authorization, not merely former
  participation;
- source environment and policy/contract version remain known.

Reviews, rewards, reputation, ads and analytics must consume explicit lineage and
correction events. A backfill may enrich missing references only with defensible
evidence and must preserve original values/audit. Exact snapshot retention is
`OWNER_DECISION_REQUIRED` by domain.

