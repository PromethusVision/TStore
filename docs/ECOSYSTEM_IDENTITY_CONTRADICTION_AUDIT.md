# Ecosystem Identity Contradiction Audit

## Reconciled rules

1. Auth user authenticates; membership/capability authorizes merchant work.
2. Merchant organization groups shops; a shop/branch is the physical/customer and
   exact QR boundary. V1 may show one-shop UX without collapsing identities.
3. Merchant sector describes business type; it is not Product Taxonomy, role,
   licence, shop ownership or catalog entitlement.
4. Canonical product identifies shared goods; variant identifies a required choice;
   listing identifies one shop’s offer.
5. Product Taxonomy nodes classify products; facets describe/filter; neither is a
   product primary key or policy authorization.
6. QR session is intent; verified purchase is server-confirmed evidence; review is
   customer content whose right derives from that evidence.
7. Ads campaign, Reward event, reputation signal, analytics event and audit event
   retain separate IDs and authorities.

## Material source tensions

| Tension | Sources | Reconciliation | State |
|---|---|---|---|
| direct owner vs organization/membership | current backend vs Merchant/Backend foundations | additive one-shop membership bridge; current ID remains compatible | RECOMMENDED / ROOT DECISION |
| universal variant expectation vs domain-gated/deferred variants | Catalog/Merchant vs Backend/Pilot | preserve three-layer model; implement variants only where identity correctness requires | RECOMMENDED / ROOT DECISION |
| variable measure MUST in Catalog vs defer in Backend | Catalog vs Backend | product model remains capable; pilot activation waits unit/QR policy | OWNER_DECISION_REQUIRED |
| shop vs branch naming | Merchant/Backend/Analytics | current shop acts as V1 physical branch; organization remains separate future parent | RECOMMENDED |
| merchant sector assignment at organization or branch | Merchant Taxonomy vs Merchant App | organization default + future branch override; not pilot-critical | OWNER_DECISION_REQUIRED |
| review aggregation after product merge/split | Catalog vs current review uniqueness | preserve evidence/history; ambiguous split/collision never guessed | OWNER_DECISION_REQUIRED |
| campaign/listing identity | Ads vs Catalog | sponsored object can only reference exact eligible listing if Ads proceeds | RECOMMENDED |
| reputation shop-wide vs organization-wide | Reward/Reputation vs Merchant | do not launch public reputation until identity/evidence decision | OWNER_DECISION_REQUIRED |
| event identity as business evidence | Analytics vs QR/Reward | analytics references domain IDs but cannot create authority | RESOLVED BY INVARIANT |

No confirmed identity was silently renamed or collapsed.
