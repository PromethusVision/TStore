# Product Variant Lifecycle Model

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 28

A product can stay active while one colour, size, capacity, formulation, edition or
fitment is discontinued. Variant lifecycle is therefore independent.

| State | New listing | Customer behavior | History |
| --- | --- | --- | --- |
| `DRAFT_CANDIDATE` | No | Hidden | Reviewer-visible |
| `ACTIVE` | Yes | Selectable when listing exists | Resolvable |
| `NEEDS_REVIEW` | Safe default no for new attachment | Existing display only if identity/policy remains safe | Resolvable |
| `DISCONTINUED` | Normally no | Not selectable unless owner allows residual stock | Resolvable |
| `MERGED` | No | Successor projection | Permanent alias |
| `SPLIT` | No | Explicit successors, no guessed redirect | Predecessor retained |
| `RETIRED` / `POLICY_BLOCKED` | No | Hidden/restricted | Resolvable |

Variant correction preserves its opaque ID for non-identity metadata. A dimension
change that alters the supplied item creates a successor/variant split rather than
editing history. Listings for a discontinued variant can remain sellable during a
controlled residual-stock window only if owner/policy rules allow it; their verified
purchases keep original variant snapshots.

Adding variants must not create additional product-review entitlement. Search may
show a variant separately only when query intent or availability makes the distinction
material.
