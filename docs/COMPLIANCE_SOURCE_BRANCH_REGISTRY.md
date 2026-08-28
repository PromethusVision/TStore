# Compliance Source Branch Registry

**State:** READ-ONLY RECONCILIATION INPUT — 2026-08-28
**Merge status:** None of the sources below was merged.

This registry freezes the exact evidence snapshots used by Wave 24. Branch documents
are architecture and proposal inputs, not enacted policy or legal determinations.

| Source lane | Read-only ref and HEAD | Principal inputs reviewed | Issues carried into Wave 24 |
|---|---|---|---|
| Customer App closeout | `origin/agent1/w16-customer-app-commercialization-closeout@1f1812cf9d65cd9ea4c8053f98f9a3c1342caeaa` | customer feature audits, release blockers, account/auth/location/QR/review behavior | notices, support contact, location, account lifecycle, verified-purchase claim |
| Canonical catalog | `origin/agent3/w16-canonical-product-catalog-foundation@b654e680ca72a79c109a098a237b9813b24516cc` | policy metadata, provenance, dedup/merge/split, variable measure | taxonomy versus permission, claim evidence, recall, provenance, policy version |
| Merchant taxonomy | `origin/agent2/w16-merchant-sector-taxonomy-foundation@b60254d4d666a860e02989b617ea649cbb8b91dd` | sector policy audit, regulated-sector boundaries, stress cases | ordinary versus regulated merchant, evidence scope, mixed-sector shops |
| Merchant App | `origin/agent1/w17-merchant-app-master-foundation@2946e49194a29ddb247a47fd077110d2d681b84a` | regulated onboarding, staff/role, shop verification | minimum evidence, expiry/revocation, capability-level approval, appeals |
| Sponsored ads | `origin/agent2/w16-sponsored-advertising-engine-foundation@43135b99d6187de205bd431fd780d9871ad61e02` | policy audit, privacy architecture, sponsored disclosure, targeting | `Sponsorlu`, targeted advertising, children, sensitive inference, ad eligibility |
| Rewards/reputation | `origin/agent1/w18-reward-gamification-reputation-foundation@e1b0fa44454fc06d353e560d401d69cbac54cde3` | economic liability, policy boundary, governance, badges | stored/economic value, tax/accounting, expiry, transfers, regulated incentives |
| Operations/Trust & Safety | `origin/agent2/w19-platform-operations-trust-safety-foundation@f015bb94bae6a4bf6dd6f02fffb419322d08d596` | product/merchant review, privacy, appeals, retention, audit | due process, operator PII, case evidence, sensitive corrections, policy version |
| Backend | `origin/agent1/w21-platform-backend-contract-foundation@bbcb5f34b535c3ed910f0291d1125c8dd012389e` | PII/location/chat boundaries, deletion, retention, QR/price | controller decisions, deletion dependencies, historical evidence, price claims |
| Analytics/observability | `origin/agent3/w20-platform-event-analytics-observability-foundation@1045301e90440903481300bec27b6fea11da1655` | privacy classes, minimization, location/search retention | purpose separation, raw query risk, coarse location, aggregate thresholds |
| QA/release | `origin/agent2/w22-platform-qa-release-engineering-foundation@fc86f11d5d1896b497d3e4ada58ffd31105e3d54` | privacy release dependency, Production-data boundary, store disclosures | notice/store consistency, deletion route, no Production testing with real PII |
| Global L2 audit | `origin/agent3/w15-global-l2-cross-batch-audit@7796080e703e4dd3189073b95d196fac82bd93f4` | cross-domain and policy-boundary audit | 24-L1 leakage, regulated-product signals, taxonomy not permission |
| Global owner decisions | `origin/agent1/w15-global-owner-decision-resolution-pack@44fb61de3fff7aa324c3709ef7d111825aa3951d` | unresolved taxonomy/policy decisions | owner/policy/legal routing, exclusions and allowlists |
| Product placement | `origin/agent1/w15-global-product-placement-stress-test@c61ff565d633d30a92b544337f483b1a21ae03f6` | cross-domain product placements and policy flags | mixed regulated goods, product-versus-service, ambiguous intended use |
| Legacy reconciliation | `origin/agent2/w15-legacy-taxonomy-reconciliation-audit@14ecb5a4aeb16946e7454cc20dbdf2c5f7b2711e` | legacy policy flags, split/merge risk, product impact | policy state migration, aliases, historical decisions, no silent reclassification |

## Reconciliation rule

- Owner-final taxonomy names remain descriptive identity only.
- Proposal-branch policy classes remain proposals until the appropriate reviewer
  approves an executable rule.
- A later source-branch update requires a new evidence review; this registry does
  not track branches dynamically.
- No source-branch content was copied into runtime, DB, migrations or configuration.
