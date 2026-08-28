# Product Policy Review

**State:** PROPOSED, FAIL-CLOSED, NOT LEGAL ADVICE

## Proposed classes

| Class | Meaning | Default operation |
|---|---|---|
| NORMAL | No special gate identified beyond ordinary safety/content rules | Standard listing eligibility still required |
| AGE_RESTRICTED | Exact age/legal controls required | Block until owner-approved age/fulfilment contract |
| REGULATED | Potentially allowed with defined evidence/seller/claim controls | Review exact product and evidence |
| LEGAL_REVIEW_REQUIRED | Status/scope cannot safely be inferred | Fail closed and escalate |
| EXCLUDED | Outside current allowed channel | Reject/disable under current rules |

## Review inputs

Exact canonical product/variant, intended use, claims, category/facets, manufacturer/provenance, identifiers, condition, merchant/shop verification, jurisdiction, fulfilment, media/content, recall/safety signals, policy version, and evidence validity.

## Decision outputs

`ALLOW`, `ALLOW_WITH_RESTRICTIONS`, `REQUEST_EVIDENCE`, `AGE_GATE_REQUIRED`, `LEGAL_ESCALATION`, `EXCLUDE`, or `SUSPEND_PENDING_REVIEW`. Scope can apply to product, variant, listing, merchant capability, claim, or channel; avoid unnecessary whole-account action.

## Rules

Taxonomy placement is descriptive, not permission. Merchant verification is not product approval. Missing evidence never implies `NORMAL`. Operator applies an approved ruleset and cannot invent a special exception. Policy changes retain prior decision history and trigger impact review for active listings, ads, rewards, reviews, and verified transactions.

Current global taxonomy audit records 32 policy groups, including excluded medicines/live animals/pesticides/firearms/pyrotechnics/tobacco candidates. These remain proposal evidence, not a final legal matrix.

`PRODUCT_POLICY_CLASSES_FINAL: NO`

`TAXONOMY_EQUALS_PERMISSION: NO`
