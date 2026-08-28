# EsnaftaVar Taxonomy Reconciliation Automation Plan

**State:** DESIGN ONLY — NO AUTOMATION OR MIGRATION EXECUTED

## 1. Purpose

This plan converts the reconciliation inventory into five mutually exclusive
future execution lanes. The lane is not an authorization to mutate data. It tells
a later, separately approved migration project how much evidence and human review
each row needs.

The classification is reproducible from
`docs/TAXONOMY_LEGACY_NODE_RECONCILIATION.csv`; no hidden production data was used.

## 2. Classification precedence

Apply rules in this order so every one of the 651 rows lands in exactly one lane:

1. **POLICY_REVIEW** — `POLICY_FLAG` is non-empty. Policy eligibility takes
   precedence over structural confidence.
2. **BLOCKED** — target state is `NO_TARGET_YET`/`OUT_OF_SCOPE`, or action is
   `UNRESOLVED` and no target L2 container is known.
3. **AUTO_SAFE** — target is `CANONICAL_FINAL`, owner decision is not required,
   confidence is high, policy flag is empty, and action is one-to-one
   `KEEP`/`RENAME`/`MOVE`/`RENAME_AND_MOVE`.
4. **AUTO_AFTER_OWNER_FINAL** — target is `PROVISIONAL_PROPOSAL`, the L2 row has a
   unique target, action is `KEEP`/`RENAME`, confidence is medium/high, and no
   policy flag is present.
5. **MANUAL_REVIEW** — every remaining row, including all splits and unresolved
   lower nodes whose container is known but exact successor is not.

This precedence is deliberately conservative. A policy flag never disappears
because a structural mapping looks easy, and a proposal never becomes auto-safe
because its label resembles the legacy label.

## 3. Lane counts

| Automation lane | Count | Percent of 651 |
|---|---:|---:|
| AUTO_SAFE | 87 | 13.4% |
| AUTO_AFTER_OWNER_FINAL | 13 | 2.0% |
| MANUAL_REVIEW | 360 | 55.3% |
| POLICY_REVIEW | 130 | 20.0% |
| BLOCKED | 61 | 9.4% |
| **Total** | **651** | **100.0%** |

Rounding explains the displayed percentage sum. Integer counts are authoritative.

### Action cross-check

| Lane | Action distribution |
|---|---|
| AUTO_SAFE | KEEP 14; MOVE 59; RENAME 8; RENAME_AND_MOVE 6 |
| AUTO_AFTER_OWNER_FINAL | KEEP 5; RENAME 8 |
| MANUAL_REVIEW | SPLIT 83; UNRESOLVED 277 |
| POLICY_REVIEW | KEEP 1; MOVE 1; RENAME 1; RENAME_AND_MOVE 3; UNRESOLVED 124 |
| BLOCKED | RETIRE 1; UNRESOLVED 60 |

The cross-check reproduces all inventory action counts exactly.

## 4. AUTO_SAFE

`AUTO_SAFE` means structurally suitable for future scripted handling only after
stable IDs, a Development dry-run, referential checks, alias checks, and explicit
migration authorization exist. It does not mean “run now.”

Potential operations include:

- preserving a canonical L1 identity;
- applying an owner-final rename while preserving the stable ID;
- moving an owner-final Electronics/Computer node while preserving semantic
  identity;
- storing the old slug/path as a typed redirect.

The script must still refuse rows if deployed product/category evidence differs
from the audited source or if an alias collision appears.

## 5. AUTO_AFTER_OWNER_FINAL

These 13 legacy L2 rows have a single currently proposed L2 successor and no
structural split in the present proposal. They remain non-executable until:

1. the Product Owner finalizes the relevant L2 name/boundary;
2. a canonical stable ID is assigned;
3. lower-level descendants are separately reconciled;
4. policy and product evidence are rechecked.

Owner changes to a proposal invalidate the current lane and require regeneration
of the reconciliation inventory.

## 6. MANUAL_REVIEW

The 360 rows include all 83 split predecessors plus 277 lower-level nodes whose
provisional/final container is known but exact successor is not.

Manual review may produce a deterministic future rule, but only from evidence such
as verified product type, compatibility attributes, intended use, material/form,
or policy state. Name-only heuristics are acceptable for triage, not final product
mutation.

For non-assignable umbrella nodes, review focuses on successor graph, aliases,
saved filters, and analytics. For assignable leaf splits, review must also decide
each affected product or establish a validated deterministic rule.

## 7. POLICY_REVIEW

The 130 rows preserve legacy risk flags. Counts by flag are non-exclusive:

| Legacy policy/risk flag | Rows |
|---|---:|
| `safety_critical` | 56 |
| `regulated_review` | 29 |
| `compatibility_critical` | 26 |
| `hazmat_review` | 24 |
| `claim_sensitive` | 19 |
| `age_sensitive` | 9 |
| `cold_chain` | 9 |

Because one row can carry several flags, these totals exceed 130. This audit does
not provide legal advice or decide listing eligibility. A policy-reviewed node may
later return to an automation lane only through an explicit versioned disposition.

## 8. BLOCKED

The 61 blocked rows consist of:

- 60 unresolved nodes with no uniquely supported target L2;
- one inactive `hediyelik-obje` retirement candidate with no approved target.

They require owner-final lower design, better product/category evidence, or an
explicit retirement/out-of-scope decision. A future tool must stop on these rows;
it must not choose the first candidate or infer a production ID.

## 9. Future automation stages

### Stage A — immutable input validation

- verify source hash and taxonomy version;
- verify 651 unique source locators and exact action/lane counts;
- verify target state is final for executable rows;
- verify stable IDs and successor graph exist;
- verify no proposal branch content is treated as deployed truth.

### Stage B — read-only deployed-data profile

- inventory deployed categories, products, listings, links, and saved filters;
- bind deployed UUIDs to audited source locators with evidence;
- report unknown/orphaned/duplicate assignments;
- never mutate Production during profiling.

### Stage C — Development dry-run

- copy/prepare authorized Development data;
- apply one versioned mapping;
- generate product reassignment/manual queues;
- install aliases in a test-only resolver;
- validate hierarchy, search, deep links, analytics, and rollback;
- rerun idempotently and compare counts.

### Stage D — gated execution package

- freeze owner and policy decisions;
- attach dry-run evidence and rollback plan;
- isolate `BLOCKED` and unresolved products;
- obtain explicit Production authorization;
- execute with checkpoints, observability, and post-run reconciliation.

None of these stages was executed by this audit.

## 10. Acceptance

- Every inventory row classified exactly once: 651/651.
- Lane count sum: 651.
- Proposal targets auto-safe before owner finalization: 0.
- Splits in AUTO_SAFE: 0.
- Policy-flagged rows outside POLICY_REVIEW: 0.
- Blocked rows silently assigned: 0.

`RECONCILIATION_AUTOMATION_PLAN: PASS`

