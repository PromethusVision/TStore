# Taxonomy Owner Review Workload Reduction

## Status

**WORKLOAD MODEL — DECISION SUPPORT ONLY / NOT OWNER APPROVED / NOT CANONICAL**

This report distinguishes semantic evidence counts from practical Product Owner answer blocks. The goal is to reduce repeated questions without treating policy, naming or exact L2 approval as automatic.

## Raw evidence workload

| Source layer | Rows | Human-question status | Counting treatment |
|---|---:|---|---|
| Batch 01 owner decisions | 38 | Raw product-owner questions | Counted in 140 raw question rows. |
| Batch 02 owner decisions | 30 | Raw product-owner questions | Counted in 140 raw question rows. |
| Batch 03 owner decisions | 40 | Raw product-owner questions | Counted in 140 raw question rows. |
| Global root decisions | 18 | Existing compressed questions | Counted in 140 raw question rows. |
| Stress root-rule candidates | 14 | Existing compressed questions | Counted in 140 raw question rows. |
| Global collision records | 66 | Decision evidence, not 66 additional meetings | Counted in the 248 source-decision ledger, separate from raw question rows. |
| Placement failure records | 42 | Test evidence, not 42 additional meetings | Counted in the 248 source-decision ledger, separate from raw question rows. |
| **TOTAL source-decision ledger** | **248** | Questions + evidence | Exact inventory total. |
| **Non-COL/non-FAIL question rows** | **140** | Potential human prompts before synthesis | Primary raw-question baseline. |

The 91 ambiguous placement scenarios are additional test evidence. They are not added to 248 or 140 because 88 are already mapped to the same root questions; adding them would double-count the owner burden.

## Deduplication result

| Measure | Count |
|---|---:|
| Source decisions represented | 248/248 |
| Semantic clusters | 18 |
| Final root decision cards | 18 |
| Safe-collapse roots | 12 |
| Roots preserving distinct sub-questions | 6 |
| Repeated raw prompts avoided by safe collapse | 58 |
| Retained source follow-ups in non-collapsible roots | 64 |

The 64 retained source follow-ups do not become 64 separate meetings:

- **17** are policy-family sub-questions under ROOT-01, ROOT-11, ROOT-12, ROOT-15 and ROOT-16. They require legal/compliance/operations evidence rather than unsupported Product Owner judgment.
- **47** are exact domain/editorial source questions under ROOT-18. They are grouped into bulk, minor, substantive and policy-dependent domain blocks.

No retained question disappears; grouping changes review order and presentation, not evidence.

## Practical Product Owner workload

### Pass 1 — root choices

- Root cards requiring an owner choice: **18**.
- Recommended defaults supplied: **18/18**.
- Checkboxes preselected: **0**.
- Expected time: approximately **75–110 minutes** if handled in the optimized sequence, excluding specialist policy work.

### Pass 2 — policy/legal work packets

- Policy-sensitive roots: **9**.
- Current official evidence refresh completed: **9/9**.
- Item-level legal/compliance allowlists finalized: **0**.
- Product Owner role: choose fail-closed product posture and business scope; do not personally certify legal eligibility.
- Specialist work packets: **9**, covering ROOT-01, ROOT-02, ROOT-05, ROOT-07, ROOT-08, ROOT-11, ROOT-12, ROOT-15 and ROOT-16.

### Pass 3 — exact L2/domain review

The 22 exact domain ballots can be scheduled as **15 owner answer blocks**:

| Review block | Domains | Owner answer blocks |
|---|---:|---:|
| One likely-approve bulk block | 8 | 1 |
| Minor-node edit domains | 3 | 3 |
| Substantive-edit domains | 5 | 5 |
| Policy-dependent domains | 6 | 6 |
| **TOTAL** | **22** | **15** |

This is an efficiency proposal, not approval. The owner can always split the eight-domain bulk candidate into individual ballots.

### Naming work

- Naming findings: **40**.
- High severity requiring explicit owner attention: **6**.
- Medium/low findings eligible for grouped editorial treatment: **34**.
- Automatic renames: **0**.
- Recommended handling: include names in their domain block rather than creating a separate 40-question pass.

## Auto-resolution estimate

Strict downstream issue units that become deterministic under accepted recommended roots:

| Layer | Auto-resolvable | Retained |
|---|---:|---:|
| Repeated raw prompts | 58 | 64 non-collapsible follow-ups |
| Collision IDs | 66 | 0 unanswered precedence collisions |
| Failure IDs | 26 | 16 ROOT-18 structural/editorial failures |
| Ambiguous placement IDs | 88 | 3 manual cases |
| Naming findings | 0 | 40 |
| Policy-blocked item rows | 0 | 11 safely blocked |
| **STRICT AUTO-RESOLUTION TOTAL** | **238** | Different retained layers are not summed as one owner-question count. |

The 238 total is valid because its four contributing layers are disjoint in the auto-resolution contract. It is not a count of Product Owner clicks.

## Safely deferable work

- Minimum source issue units clearly deferable to L3/L4 after root approval: **13**.
  - 10 source decisions in ROOT-17’s same-L1/future-depth cluster.
  - 3 manual content/supply/kit placement cases: `EDGE-0158`, `EDGE-0159`, `EDGE-0161`.
- Runtime stable IDs, aliases, facets, merchant forms and migration remain deferred until owner-final L2 state.
- Legal/policy allowlists are not “deferred to L3/L4”; they are separate specialist gates.

## Standalone explicit owner answers

| Answer type | Estimated blocks | Notes |
|---|---:|---|
| Root decisions | 18 | Always explicit. |
| Post-root domain review blocks | 15 | Covers all 22 domains through one bulk + 14 individual blocks. |
| **Immediate Product Owner answer blocks** | **33** | Does not include external specialist work. |
| Policy specialist packets | 9 | Feed evidence back into applicable owner scope decisions. |

“33” is a practical session-design estimate. It does not claim that 248 evidence records were semantically reduced to 33 facts.

## Reduction metrics

| Baseline | Optimized workload | Reduction |
|---|---:|---:|
| 140 raw non-COL/non-FAIL question rows | 33 owner answer blocks | **76.4%** |
| 248 total source-decision/evidence rows | 33 owner answer blocks | **86.7% evidence-review burden** |
| 248 total source rows | 18 root-boundary cards only | **92.7% for the root pass**, not final completion |
| 22 exact domain ballots | 15 post-root answer blocks | **31.8% scheduling reduction** |
| 40 naming findings | 6 explicit high-severity choices + grouped editorial handling | **No automatic closure claimed** |

The primary estimated human-question reduction is **76.4%**, from 140 potential question prompts to 33 structured Product Owner answer blocks. The more dramatic 92.7% figure applies only to the first root-boundary pass and must not be used as a final-review claim.

## Remaining bottlenecks

1. Nine policy-sensitive root packets need specialist validation for item-level implementation.
2. Four product-placement rows still lack an approved home.
3. Three ambiguity rows remain manual.
4. Five substantive-edit domains and six policy-dependent domains cannot be bulk approved safely.
5. ROOT-18 still requires explicit owner action; silence is not approval.

## Reconciliation

- Batch decisions: **108**.
- Global/stress compressed questions: **32**.
- Raw non-COL/non-FAIL question rows: **140**.
- Collision/failure evidence rows: **108**.
- Total source-decision ledger: **248**.
- Root questions: **18**.
- Retained non-collapsible source follow-ups: **64**.
- Policy/legal review roots: **9**.
- L3/L4-deferable source issue units: **13**.
- Strict auto-resolvable downstream issue units: **238**.
- Standalone post-root domain answer blocks: **15**.
- Estimated immediate Product Owner answer blocks: **33**.
- Primary estimated question reduction: **76.4%**.
- Owner finalization performed: **NO**.

`OWNER_REVIEW_WORKLOAD_REDUCTION: PASS`

`RAW_QUESTION_ROWS: 140`

`ROOT_QUESTIONS: 18`

`ESTIMATED_OWNER_ANSWER_BLOCKS: 33`

`ESTIMATED_QUESTION_REDUCTION: 76.4%`

`OWNER_FINALIZATION: NOT_PERFORMED`
