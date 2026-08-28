# Backend Stable Identity Contracts

**State:** PROPOSED CROSS-DOMAIN CONTRACT — NO IDS GENERATED
**Wave:** 21 / Workstream E

## Universal rules

1. Identity is an immutable opaque key, never a mutable name, slug, email, phone,
   taxonomy path, barcode, SKU or display order.
2. Renames, transfers, merges, splits and retirement do not reuse an identity for
   a different real-world subject.
3. References use IDs plus necessary immutable snapshots. A snapshot preserves
   history but does not replace the referenced identity.
4. Environment is a hard boundary. Development/test/demo identity is never
   accepted as Production identity by fallback.
5. Idempotency key, event ID, correlation ID and entity ID are distinct.
6. Deletes/merges use explicit lifecycle/lineage; historical evidence is not
   silently reassigned.

## Identity registry

| Subject | Stable identity requirement | Mutable/non-identity data | Historical rule |
|---|---|---|---|
| Customer | Auth principal plus application profile ID | Email, name, device/session | Account lifecycle may pseudonymize; purchase/review audit references follow approved retention |
| Merchant organization | Independent opaque organization ID | Legal/display name, contact, plan | Transfer/rename keeps ID; closure retires it |
| Shop/branch | Stable physical/operational location ID | Name, address, hours, coordinates | Move/closure is versioned; do not reuse ID for another shop |
| Membership | Stable user-organization relationship ID | Capabilities, scope, status | Revocation is a transition, not row disappearance from audit |
| Canonical product | Stable platform-governed product ID | Name, media, taxonomy display | Merge/split creates lineage; historical IDs remain resolvable |
| Variant | Stable selectable identity within product family | Labels, media, facet display | Correction/versioning must not mutate one sellable identity into another |
| Shop listing | Stable shop offer ID | Price, availability, SKU, local media | Retirement preserves purchase/ad references |
| Verified purchase | Immutable server-created transaction ID | Corrective status/annotation | Never reused or overwritten; corrections append facts |
| Review | Stable review ID under customer/product uniqueness | Text, rating, visible state/revision | Edit preserves ID and revisions; delete/restore follows policy |
| Ad campaign | Immutable campaign ID plus revision IDs | Name, budget, schedule, target settings | Copy/relaunch gets new ID; served snapshot keeps revision |
| Reward entry | Immutable ledger entry ID and source identity | Derived balance/progress | Reverse/expire/redeem by new entry, never overwrite |
| Reputation evidence | Immutable signal ID + rule version + source | Derived score/badge projection | Reclassification/revocation retains source and reason |
| Ops case | Stable restricted case ID | Assignment, severity, lifecycle | Decisions/evidence append; case IDs never recycled |
| Event | Globally unique event occurrence ID | Delivery metadata | Duplicate delivery keeps same ID; correction is a new linked event |

## Namespace rules

- A GTIN may identify product evidence under a governed type, but it does not
  substitute for internal canonical product identity.
- Merchant SKU and merchant barcode are unique only inside their declared
  merchant/shop namespace.
- Current `shop_products.id` should be treated as the listing identity unless a
  future migration supplies a total, durable mapping.
- Current `products.id`, `shops.id`, `verified_transactions.id` and `reviews.id`
  remain authoritative historical references.
- External/provider IDs are stored with provider/type provenance and cannot be
  trusted across providers.

## Merge, split and correction

- **Merge:** retain predecessor IDs and an immutable `MERGED_INTO` relation; new
  writes use the approved survivor/successor only after policy checks.
- **Split:** retain the predecessor and explicit child relations. Existing evidence
  stays on the predecessor unless a governed, evidenced mapping exists.
- **Correction:** append a revision/correction event with actor, reason, policy and
  before/after references. Do not delete the original fact.
- **Retirement:** stops new use but preserves reads needed for purchase, review,
  ads, reward, reputation, analytics and operations history.

## Open owner decisions

| Decision | Recommendation | Status |
|---|---|---|
| Can a merchant organization be transferred? | Permit only a governed ownership transition with audit and fresh authorization | OWNER_DECISION_REQUIRED |
| Product merge survivor vs new successor ID | Reuse an existing survivor only when semantics are identical; otherwise create successor | OWNER_DECISION_REQUIRED |
| Product split historical attribution | Keep unresolved predecessor identity; never guess | OWNER_DECISION_REQUIRED |
| Customer deletion retention/pseudonymization | Define by purpose and legal/policy review before implementation | OWNER_DECISION_REQUIRED |
| Shop move: same shop or new branch? | Use material continuity criteria and manual review for ambiguous moves | OWNER_DECISION_REQUIRED |

`STABLE_IDENTITY_RUNTIME_IMPLEMENTED: NO`
