# Backend Product Merge Contract

**State:** PROPOSED HIGH-RISK OPERATION — NO MERGE EXECUTED

Merge resolves two or more canonical identities determined to represent the same
product. It is an audited lineage operation, not bulk foreign-key rewriting.

## Preconditions

- evidence, provenance and policy-compatible identity match;
- dependency preview for listings, purchases, reviews, ratings, ads, rewards,
  reputation, media and analytics;
- survivor/new-successor decision and conflict plan;
- expected revisions, idempotency key and authorized second-review posture;
- Development dry run and rollback/forward correction plan.

## Effects

Predecessors become resolvable aliases/retired identities. New discovery may use
the successor; historical purchase snapshots keep original identity plus lineage.
Duplicate listings and customer/product reviews are not silently collapsed.

Review collision policy and whether to select a survivor or new successor are
`OWNER_DECISION_REQUIRED`. Original facts and operator audit are never deleted.

