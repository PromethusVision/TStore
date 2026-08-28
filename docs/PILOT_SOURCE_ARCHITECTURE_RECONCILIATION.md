# EsnaftaVar Esenler Pilot — Source Architecture Reconciliation

**State:** `READ-ONLY SOURCE RECONCILIATION — NOT OWNER FINAL`
**Reviewed:** 28 August 2026

## Source manifest

| Source | Remote HEAD | Pilot implication |
|---|---|---|
| Customer commercialization closeout | `1f1812cf9d65cd9ea4c8053f98f9a3c1342caeaa` | Customer O2O core is conditionally complete; exact artifact and physical-device evidence remain. |
| Ecosystem reconciliation | `b3b5c928f36ff91e97e06a6d3ffad3858074489e` | Minimum pilot may use a controlled merchant operating path before a full Merchant App. |
| Merchant App foundation | `2946e49194a29ddb247a47fd077110d2d681b84a` | Architecture exists; merchant runtime/backend is a major gap. |
| Backend contract | `bbcb5f34b535c3ed910f0291d1125c8dd012389e` | Exact-shop authority, atomic QR confirmation, listing truth and idempotency are mandatory. |
| Merchant Sector Taxonomy | `b60254d4d666a860e02989b617ea649cbb8b91dd` | 67 assignable leaves are proposed, not owner-final; regulated/policy-signalled sectors fail closed. |
| Sponsored Ads foundation | `43135b99d6187de205bd431fd780d9871ad61e02` | Ads are a major runtime/operations gap and are not a day-one dependency. |
| Reward/Gamification/Reputation | `e1b0fa44454fc06d353e560d401d69cbac54cde3` | Economic rewards, gamification and public reputation are recommended post-pilot. |
| Operations/Trust & Safety | `f015bb94bae6a4bf6dd6f02fffb419322d08d596` | Lean roles may be combined, but audit, escalation and fail-closed controls remain. |
| Events/Analytics/Observability | `1045301e90440903481300bec27b6fea11da1655` | Health, soft intent and authoritative commerce facts must remain distinct. |
| QA/Release Engineering | `fc86f11d5d1896b497d3e4ada58ffd31105e3d54` | Exact-artifact, physical two-device and environment gates precede rollout. |
| Canonical catalog | `b654e680ca72a79c109a098a237b9813b24516cc` | Stable identity/listing ownership is designed; policy and migration are not runtime-ready. |
| Facet/search architecture | `900a009478a7531362c376ccf9a2ca55ebe04117` | 24 L1 coverage exists; proposed L2/facet gaps must not be treated as final runtime truth. |
| Legacy taxonomy reconciliation | `14ecb5a4aeb16946e7454cc20dbdf2c5f7b2711e` | 651 nodes were audited; 461 are unresolved, so no blind migration is safe. |

No source branch was merged or modified.

## Reconciled launch invariants

1. EsnaftaVar is local physical-commerce discovery: no shipping, online payment,
   classic checkout or classic order flow.
2. A product view, cart action or directions request is intent, not a sale.
3. A verified purchase is a unique server-authoritative QR fact; it is not payment,
   settlement, revenue or invoice evidence.
4. The public listing must bind an existing shop, canonical product/variant where
   applicable, current merchant-owned price/availability and a freshness state.
5. Merchant-sector identity, Product Taxonomy and product facets remain separate.
6. Unknown policy eligibility, merchant authority or QR state fails closed.
7. Ads cannot buy organic rank, trust, review rights, reward or reputation.
8. Test/demo/Development traffic and artifacts must not contaminate Production or
   commercial metrics.
9. A release decision applies to one immutable, signed, hashed artifact.
10. Manual pilot operations can replace automation, never authorization, audit,
    idempotency or evidence.

## Launch dependencies versus future systems

| Capability | Pilot classification | Reason |
|---|---|---|
| Customer discovery/search/product/shop | `MUST` | Core public value proposition. |
| Truthful catalog and active listings | `MUST` | Empty or misleading discovery invalidates the pilot. |
| Merchant/shop verification and bounded authority | `MUST` | Prevents wrong-shop and unauthorized listing/QR actions. |
| QR confirmation and verified-purchase evidence | `MUST IF QR IS ENABLED` | Atomicity and replay safety are non-negotiable; owner may still choose a pre-QR observation phase. |
| Lean support, incident and monitoring | `MUST` | A commercial pilot cannot rely on invisible failures. |
| Full Merchant App | `SHOULD / CONDITIONAL` | A controlled verifier/catalog path can support a narrow pilot. |
| Chat and notifications | `SHOULD` | Useful, but they do not replace support or merchant truth. |
| iOS distribution | `OWNER DECISION` | Android-only can be a bounded pilot option; iOS readiness is currently incomplete. |
| Sponsored Ads engine | `POST-PILOT CANDIDATE` | Adds billing, policy, disclosure, fraud and measurement load before value is proven. |
| Economic Reward/Gamification | `DEFER` | Adds liability, fraud, accounting, dark-pattern and support risk. |
| Composite merchant reputation | `DEFER` | Insufficient evidence and fairness/appeal maturity. |
| Legacy taxonomy migration | `DEFER / SEPARATE` | Not required for a small controlled L1/allowlisted catalog pilot. |

## Evidence conflicts and open gaps

- Customer code readiness does not imply commercial release readiness.
- Merchant architecture does not imply an implemented Merchant App.
- The 24 Product L1 set is final, while most L2 content and all proposed Merchant
  Sector leaves outside the confirmed beauty subtree remain owner-review material.
- A controlled manual path is acceptable only if it preserves exact-shop authority,
  audit and one-winner QR behavior; spreadsheet or shared-admin shortcuts do not.
- No current source proves real Esenler merchant demand, customer conversion,
  merchant willingness to pay, support volume or Production health.
- No prior design converts a merchant count such as 100 into automatic launch
  readiness; density, truth and usable category depth matter more than a raw total.

`ALL_REQUIRED_SOURCE_BRANCHES_ACCOUNTED: YES`

`SOURCE_BRANCH_MERGES: 0`

`OWNER_FINALIZATION_PERFORMED: NO`
