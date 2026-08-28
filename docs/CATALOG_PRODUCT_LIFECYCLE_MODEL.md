# Canonical Product Lifecycle Model

Status: **OWNER REVIEW DRAFT — NO ENUM IMPLEMENTATION**
Wave: 16, Work Package 27

| State | Assignable to new listing | Discoverable | Historical resolution |
| --- | --- | --- | --- |
| `DRAFT_CANDIDATE` | No | No | Yes to authorized reviewers |
| `ACTIVE` | Yes, subject to policy | Yes when offers/policy allow | Yes |
| `NEEDS_REVIEW` | Owner-rule dependent; safe default no for identity conflicts | Existing safe projection may remain | Yes |
| `MERGED` | No; redirect to successor | Through successor | Yes, permanent predecessor alias |
| `SPLIT` | No; no arbitrary child redirect | Successors only after mapping | Yes, predecessor retained |
| `RETIRED` | No | Normally no | Yes |
| `POLICY_BLOCKED` | No | No or restricted according to policy | Yes to authorized history |

## Transition rules

- Candidate activation requires sufficient identity, taxonomy and policy evidence.
- Rename, spelling correction and taxonomy move are revisions, not lifecycle changes.
- `NEEDS_REVIEW` is used for identifier, merge, policy or provenance conflict; it
  never grants an unsafe listing path.
- Merge and split are terminal lineage events for the predecessor. Reversal creates
  a new audited correction, not history deletion.
- Retirement means the real-world product is no longer assignable or supported; it
  does not erase reviews, wishlists, purchases, deep links or analytics.
- Policy block can be temporary and jurisdictional; it is independent from product
  discontinuation.

Product state does not set shop stock/availability. An active product may have zero
active listings; a retired listing elsewhere does not retire the product.
