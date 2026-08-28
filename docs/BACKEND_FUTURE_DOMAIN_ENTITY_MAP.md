# Backend Future Domain Entity Map

**State:** PROPOSED — OWNER REVIEW REQUIRED WHERE MARKED  
**Wave:** 21 / Workstream C  
**Implementation:** NONE

## Conceptual map

```text
AUTH USER ─1:1─ PROFILE
    └─1:N─ MERCHANT MEMBERSHIP ─N:1─ MERCHANT ORGANIZATION
                 └─scope/capabilities─> SHOP / BRANCH

MERCHANT ORGANIZATION ─1:N─ SHOP (physical branch/location)
                              └─1:N─ SHOP LISTING
CANONICAL PRODUCT ─1:N?─ VARIANT ─1:N─ SHOP LISTING
        ├─ lineage: MERGE / SPLIT / RETIRE
        └─ taxonomy assignment by stable node/version

CUSTOMER + SHOP + LISTING SNAPSHOT
    └─ QR SESSION ─atomic consume─> VERIFIED PURCHASE + ITEMS
                                      ├─evidence─> REVIEW
                                      ├─source─> REWARD LEDGER ENTRY (future policy)
                                      └─signal─> REPUTATION EVIDENCE (future policy)

AD CAMPAIGN ─targets─> SHOP LISTING + revision
OPS CASE ─references─> any governed identity + evidence
EVENT ─references─> committed domain fact; never replaces it
```

## Domain ownership

| Concept | Owns | Must not own |
|---|---|---|
| Auth user | Authentication principal | Merchant/shop rights by itself |
| Profile | Customer-facing application identity and preferences | Organization ownership authority |
| Merchant organization | Legal/operational merchant boundary when approved | Customer profile or product truth |
| Merchant membership | User-to-organization relationship, scope and lifecycle | Global role encoded in client metadata |
| Shop/branch | Physical/local selling location and operational state | Canonical product facts |
| Canonical product | Shared stable product identity and governed facts | Merchant price, stock, SKU or ad state |
| Variant | Selectable identity-changing dimensions | Shop offer, quantity or price |
| Shop listing | Shop offer, price, availability knowledge, merchant SKU, local content | Canonical name/brand/category truth |
| QR session | Bounded invitation to verify one customer/shop context | Payment, review or reward entitlement |
| Verified purchase | Immutable server-authoritative physical-purchase evidence | Advertising causality or payment settlement |
| Review | Customer feedback under verified eligibility | Reward/reputation score editing |
| Ad campaign | Paid placement objective, target and revisions | Organic relevance, review rights or reputation |
| Reward ledger | Governed value/progress entries | Analytics-derived value or review eligibility |
| Badge/reputation signal | Evidence-grade input and governed projection | Paid trust or hidden rating replacement |
| Ops case | Restricted workflow, evidence, decisions and appeal | Silent domain-row rewrite without contract |
| Event | Immutable observation/decision envelope | Authority merely because it was emitted |

## Aggregate boundaries

- **Customer aggregate:** profile and private customer data remain Auth-user
  scoped; account deletion must distinguish deletable personal data from retained
  legal/audit evidence.
- **Merchant aggregate:** organization and membership govern capability; shop is
  the physical/operational scope. The pilot may present one shop without erasing
  this distinction.
- **Catalog aggregate:** canonical product and variant are platform-governed;
  listing is merchant-owned under catalog and policy constraints.
- **Purchase aggregate:** QR consumption and creation of purchase plus item
  snapshots form one transaction boundary.
- **Review aggregate:** active review uniqueness and aggregate refresh are one
  consistency domain, while historical evidence remains immutable.
- **Economic/trust aggregates:** ads, rewards and reputation keep separate ledgers,
  policies and event identities.

## Owner decisions still open

| Decision | Recommendation | Status |
|---|---|---|
| Is current `shops` a branch or a merchant organization? | Treat it as physical shop/branch; add organization only when merchant workflow needs it | OWNER_DECISION_REQUIRED |
| May one listing target a product without a variant? | Yes for unvaried products; variant nullable by contract, never guessed | OWNER_DECISION_REQUIRED |
| Is reputation shop-level, organization-level or both? | Start shop-level evidence; derive organization roll-up only with explainable weighting | OWNER_DECISION_REQUIRED |
| Is a transactional event outbox required in the first merchant pilot? | Require it only for side effects that must not be lost; do not make analytics availability a launch blocker | OWNER_DECISION_REQUIRED |

No entity in this map authorizes a schema change. Names are conceptual and may be
mapped to existing tables during migration planning.

