# Global Compliance Issue Inventory

**State:** CONSOLIDATED RAW ISSUE REGISTER — NO FINAL DECISIONS  
**Raw issues:** 85  
**Source snapshots:** see `COMPLIANCE_SOURCE_BRANCH_REGISTRY.md`

Each row is a distinct operational question discovered in the foundation branches.
The default is deliberately conservative; it is not a legal conclusion.

## Privacy and data — 20

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| PRIV-01 | Controller/processor/separate-controller roles by purpose/vendor | backend, ads, analytics | map before launch — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-02 | Activity-specific notice at account creation | customer, QA | required dependency — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-03 | Separate notice and consent where consent is actually used | ads, analytics | no bundled acceptance — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-04 | Exact/coarse customer location collection | customer, backend | transient minimum by default — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-05 | Saved addresses and saved locations | backend | customer-private, bounded purpose — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-06 | Location analytics/cohort threshold | analytics, ads | no precise trail; coarse only after approval — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-07 | Raw search-query retention | analytics | off for pilot — `PRODUCT_OWNER` + `KVKK/PRIVACY_SPECIALIST` |
| PRIV-08 | Auth/session/device/IP logging | customer, backend, ops | redact and purpose-limit — `TECHNICAL_ARCHITECT` |
| PRIV-09 | Chat/private attachment access | backend, ops | participant/case scoped — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-10 | QR/verified-purchase retention | backend, reward, ops | evidence minimum; period unresolved — `LAWYER` + `KVKK/PRIVACY_SPECIALIST` |
| PRIV-11 | Reviews linked to account after deletion | backend, ops | anonymize/retain/delete rule needed — `LAWYER` + `PRODUCT_OWNER` |
| PRIV-12 | Account deletion across Auth/Storage/vendors/backups | backend, QA, ops | dependency-aware workflow — `TECHNICAL_ARCHITECT` + privacy review |
| PRIV-13 | Data-subject intake and identity verification | ops, QA | no password/OTP; 30-day process — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-14 | Retention schedules by data class | backend, analytics, ops | no “forever” default — `LAWYER` + privacy review |
| PRIV-15 | Pseudonymization versus true anonymization | analytics, backend | linked hashes remain personal-data candidates — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-16 | International transfer and cloud vendors | backend, QA | transfer mechanism/vendor map required — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-17 | Security breach triage/72-hour procedure | ops, backend | incident playbook required — `KVKK/PRIVACY_SPECIALIST` |
| PRIV-18 | Operator/staff access to PII and documents | ops, merchant app | least privilege/case/evidence scope — `TECHNICAL_ARCHITECT` + privacy review |
| PRIV-19 | Store privacy/Data Safety declarations | QA | actual Production data-flow reconciliation — `PRODUCT_OWNER` + privacy review |
| PRIV-20 | Synthetic/demo/test traffic and data | QA, analytics | no real PII; separate from commercial metrics — `TECHNICAL_ARCHITECT` |

## Platform role and customer communications — 8

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| ROLE-01 | 6563/ETAHS/ETHS applicability to discovery-only model | customer, backend | no self-classification — `LAWYER` |
| ROLE-02 | 5651 role for listings/reviews/chat/media | customer, ops | notice/removal analysis — `LAWYER` |
| ROLE-03 | Consumer-law relationship for platform service | customer, QA | terms/support review — `LAWYER` |
| ROLE-04 | Price/availability is merchant assertion | backend, catalog | timestamps/source + no guarantee — `PRODUCT_OWNER` |
| ROLE-05 | QR is not payment/receipt/revenue evidence | customer, backend, reward | prominent bounded explanation — `PRODUCT_OWNER` + `LAWYER` |
| ROLE-06 | Terms of use and merchant terms | customer, merchant app | professional draft/review required — `LAWYER` |
| ROLE-07 | Support/contact and complaint route | customer, ops, QA | reachable pilot route — `PRODUCT_OWNER` |
| ROLE-08 | Transactional versus commercial electronic messages | customer, ads | per-message classification/IYS review — `LAWYER` |

## Advertising — 8

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| ADS-01 | Persistent `Sponsorlu` disclosure on all paid placements | ads | mandatory design contract candidate — `LAWYER` + `PRODUCT_OWNER` |
| ADS-02 | “Neden Sponsorlu?” explanation | ads | show material criteria/control — `PRODUCT_OWNER` |
| ADS-03 | Contextual versus behavioral targeting | ads, analytics | contextual-only pilot recommendation — `KVKK/PRIVACY_SPECIALIST` |
| ADS-04 | Children and profiled advertising | ads | no profiled child targeting — `LAWYER` + privacy review |
| ADS-05 | Sensitive health/purchase inference | ads, reward | prohibited candidate — `KVKK/PRIVACY_SPECIALIST` |
| ADS-06 | Merchant-level ad reporting | ads, analytics | aggregate/minimum-cohort only — `KVKK/PRIVACY_SPECIALIST` |
| ADS-07 | Discount/cheapest/nearest/scarcity claims | ads, catalog | evidence and effective-time rules — `LAWYER` + `PRODUCT_OWNER` |
| ADS-08 | Catalog eligibility versus ad eligibility | ads, catalog | separate, ads no less restrictive — `DOMAIN_REGULATORY_SPECIALIST` |

## Reviews and UGC — 7

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| UGC-01 | What “verified purchase” means to consumers | customer, backend | publish clear methodology — `LAWYER` + `PRODUCT_OWNER` |
| UGC-02 | Positive/negative review parity | customer, ops | no merchant-veto or score manipulation — `LAWYER` |
| UGC-03 | Review rejection reason and response timing | ops, customer | objective reasons + safe notice — `LAWYER` |
| UGC-04 | Merchant response/report right | ops | response is not removal power — `PRODUCT_OWNER` |
| UGC-05 | Defamation, illegal content, privacy and safety reports | ops | case-based moderation/escalation — `LAWYER` |
| UGC-06 | Review evidence after purchase correction/account deletion | backend, ops | immutable history + visible status rule — `LAWYER` |
| UGC-07 | Chat/media/report evidence retention | backend, ops | shortest case-necessary period — `KVKK/PRIVACY_SPECIALIST` |

## Merchant verification — 8

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| MER-01 | Ordinary identity/shop existence evidence | merchant taxonomy/app | minimum scoped verification — `PRODUCT_OWNER` |
| MER-02 | Regulated-sector capability evidence | merchant taxonomy/app, ops | fail closed — `DOMAIN_REGULATORY_SPECIALIST` |
| MER-03 | Evidence expiry/revocation/recheck | merchant app, ops | versioned status + trigger — `DOMAIN_REGULATORY_SPECIALIST` |
| MER-04 | Mixed ordinary/regulated inventory | merchant taxonomy, catalog | approve capability/product, not whole shop — `PRODUCT_OWNER` |
| MER-05 | Staff roles and evidence access | merchant app, ops | least privilege — `TECHNICAL_ARCHITECT` |
| MER-06 | Verification badge wording | merchant app, reward | exact scope; no “official/guaranteed” implication — `LAWYER` |
| MER-07 | Suspension effects and appeal | ops, merchant app | proportional, reasoned, reversible where safe — `LAWYER` + `PRODUCT_OWNER` |
| MER-08 | Documents retention and disclosure | merchant app, ops | field minimization; no customer exposure — `KVKK/PRIVACY_SPECIALIST` |

## Regulated products — 15

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| PROD-01 | Alcohol listing/discovery/advertising/reward boundary | taxonomy, ads, reward | V1 exclude from ads/rewards; listing legal review — `LAWYER` |
| PROD-02 | Tobacco/nicotine and adjacent devices | taxonomy, ads, reward | excluded pending exact allowlist — `LAWYER` |
| PROD-03 | Human medicines | taxonomy, merchant, ads | exclude from V1 ordinary channel — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-04 | Medical devices by class/intended use | catalog, merchant, ads | item/seller/claim evidence — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-05 | Supplements/health claims | taxonomy, ads, reward | approved product + claim review — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-06 | Medical nutrition/infant formula | taxonomy, ads, reward | promotion-sensitive; fail closed — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-07 | Prescription/custom optics and contact lenses | taxonomy, merchant | licensed-scope review — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-08 | Veterinary medicines and health products | taxonomy, merchant | ordinary Pet Shop does not authorize — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-09 | Pesticides/plant-protection products | taxonomy, merchant | internet sale/promotion fail closed — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-10 | Hazardous chemicals, biocides, aerosols, batteries | catalog, ads | item-level handling/label/fulfilment review — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-11 | PPE and safety claims | taxonomy, catalog | conformity/intended-use evidence — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-12 | Firearms/ammunition/weapon-like goods | taxonomy, merchant, ads | excluded pending exact legal allowlist — `LAWYER` |
| PROD-13 | Pyrotechnics/explosives | taxonomy, ads | excluded from V1 — `LAWYER` |
| PROD-14 | Precious metal/jewellery/high-value goods | merchant, catalog | merchant authorization/authenticity/fraud review — `DOMAIN_REGULATORY_SPECIALIST` |
| PROD-15 | Automotive oils/chemicals/safety-critical parts | taxonomy, merchant | ordinary goods only after SKU policy — `DOMAIN_REGULATORY_SPECIALIST` |

## Rewards and reputation — 7

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| REW-01 | Whether points/vouchers create economic liability | reward | no economic pilot before review — `ACCOUNTANT/TAX_ADVISER` + `LAWYER` |
| REW-02 | Cross-merchant value transfer/payment regulation | reward | prohibited until TCMB/legal analysis — `LAWYER` |
| REW-03 | Funding, invoice/VAT/accounting treatment | reward | case-specific design required — `ACCOUNTANT/TAX_ADVISER` |
| REW-04 | Earn/redeem/expire/reverse terms | reward, backend | immutable ledger + clear terms — `LAWYER` + accountant |
| REW-05 | Regulated-product incentives | reward, taxonomy | excluded pending domain review — `DOMAIN_REGULATORY_SPECIALIST` |
| REW-06 | Reputation/badge claim meaning | reward, merchant | evidence-based, no paid influence — `PRODUCT_OWNER` + `LAWYER` |
| REW-07 | Public badges revealing sensitive behavior | reward, privacy | no sensitive purchase inference — `KVKK/PRIVACY_SPECIALIST` |

## Operations and appeals — 7

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| OPS-01 | High-risk action authorization/evidence/audit | ops | case + reason + before/after — `TECHNICAL_ARCHITECT` |
| OPS-02 | Separation of duties in one-person pilot | ops | compensating review/logging — `PRODUCT_OWNER` |
| OPS-03 | Suspension/restriction proportionality | ops, merchant app | capability-scoped where safe — `LAWYER` |
| OPS-04 | Appeal eligibility/independence/reopening | ops | preserve original decision and history — `LAWYER` + `PRODUCT_OWNER` |
| OPS-05 | Customer-facing reason versus abuse-signal secrecy | ops | meaningful but non-gameable reason — `LAWYER` |
| OPS-06 | Verified-purchase correction | backend, ops | append correction, never silent erase — `LAWYER` |
| OPS-07 | Policy/version change impact on active content | ops, catalog, ads, reward | impact scan, no retroactive silent rewrite — `PRODUCT_OWNER` |

## Claims, provenance and price — 5

| ID | Issue | Primary source lanes | Default/routing |
|---|---|---|---|
| CLAIM-01 | Catalog provenance and manufacturer/identifier claims | catalog, ops | evidence source + version — `PRODUCT_OWNER` |
| CLAIM-02 | Product merge/split preserving policy/history | catalog, backend, ops | successor graph + audit — `TECHNICAL_ARCHITECT` |
| CLAIM-03 | Availability freshness | backend, merchant app | timestamp and stale-state wording — `PRODUCT_OWNER` |
| CLAIM-04 | Price, comparison price and discount proof | backend, ads | no inferred discount; source snapshot — `LAWYER` |
| CLAIM-05 | QR/review evidence is not invoice/payment proof | backend, customer, ops | explicit disclosure — `LAWYER` + `PRODUCT_OWNER` |

## Count reconciliation

| Family | Count |
|---|---:|
| Privacy/data | 20 |
| Platform role/communications | 8 |
| Advertising | 8 |
| Reviews/UGC | 7 |
| Merchant verification | 8 |
| Regulated products | 15 |
| Rewards/reputation | 7 |
| Operations/appeals | 7 |
| Claims/provenance/price | 5 |
| **Total** | **85** |

