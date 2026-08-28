# Merchant Verification and Regulated-Sector Policy Matrix

**State:** PROPOSED — EVIDENCE SETS AND LEGAL ELIGIBILITY NOT FINAL

## Separation rules

- Auth user, merchant profile, shop, sector, capability, product, listing and claim
  are separate objects/decisions.
- Sector selection never changes Auth role or grants permission.
- A verified merchant is not approved for all products; an approved product is not
  approved for all ads/rewards.
- Customer-visible badges state only the exact verified fact and current scope.

## Verification tiers

| Tier | Meaning | Minimum concept |
|---|---|---|
| `ORDINARY_BASELINE` | ordinary local merchant/shop | authenticated principal, shop relationship, business/contact facts actually needed, source and timestamp |
| `EVIDENCE_REVIEW` | activity commonly needs registration/premises/safety evidence | exact capability, minimum authoritative evidence, issuer/scope/expiry and reviewer |
| `REGULATED_SPECIALIST` | licence/professional authorization or controlled goods | fail closed; domain specialist applies current rules; recheck/revocation |
| `EXCLUDED_CAPABILITY` | current EsnaftaVar channel does not support it | reject exact capability with reason and appeal; ordinary separable activity may continue |

## Sector matrix

| Sector family/examples | Proposed tier | Evidence question | Product/capability boundary |
|---|---|---|---|
| Ordinary clothing, footwear, bags, books, stationery, furniture, ordinary electronics/computer | `ORDINARY_BASELINE` | real principal/shop and accurate public facts | regulated SKU still escalates |
| Market/bakkal/supermarket | `EVIDENCE_REVIEW` | food-business registration/activity where applicable | alcohol/tobacco/supplement/formula not inferred |
| Butcher/delicatessen/bakery/pastry/nut seller | `EVIDENCE_REVIEW` | production/retail activity, food registration, hygiene/cold-chain scope | exact food/claim/packaging rules per SKU |
| Greengrocer/food-water beverage dealer | `EVIDENCE_REVIEW` | registered activity/source/traceability as applicable | no automatic alcohol or plant-protection scope |
| Aktar | `REGULATED_SPECIALIST` | ingestible/cosmetic/plant/claim mix cannot be inferred | every supplement/health/biocidal product exact classification |
| Electric/white-goods/building/plumbing/material seller | `EVIDENCE_REVIEW` | installation, gas, electrical and safety capability | selling is not licensed installation; hazardous product separate |
| Paint/chemical/decor material seller | `EVIDENCE_REVIEW` | chemical/storage/label activity | exact hazardous/biocidal SKU review |
| Auto parts/accessory/tyre/motorcycle | `EVIDENCE_REVIEW` | safety-critical products, fitment and any service scope | merchant does not validate compatibility or PPE automatically |
| Barber/hairdresser/beauty salon | `EVIDENCE_REVIEW` | premises/activity/hygiene; exact current requirements | medical/treatment procedure not inferred |
| Anne & Bebek merchant | `EVIDENCE_REVIEW` | ordinary retail facts | formula, medicine, device and restraint/sleep safety separate |
| Fishing/hunting goods | `REGULATED_SPECIALIST` | exact ordinary fishing versus weapon/ammunition capability | weapon scope excluded pending specialist allowlist |
| Pet Shop/aquarium shop | `REGULATED_SPECIALIST` | product-only versus live-animal/veterinary activity | ordinary food/accessory separable; live/veterinary fail closed |
| Pet groomer | `EVIDENCE_REVIEW` | grooming/hygiene/welfare scope | no veterinary-service claim |
| Optical shop | `REGULATED_SPECIALIST` | optician/establishment/scope/current status | prescription/custom/contact-lens capability exact |
| Medical product shop | `REGULATED_SPECIALIST` | sales-centre/product-class/authorization | medicines/pharmacy not inferred |
| Jeweller | `REGULATED_SPECIALIST` | current authorization and exact activity | authenticity/purity/value claims separately evidenced |
| Garden/growing-products shop | `REGULATED_SPECIALIST` for controlled inputs | ordinary plants/tools versus authorized plant-protection capability | pesticides remain blocked in ordinary internet scope |
| Technical service | `EVIDENCE_REVIEW` | real service scope and any authorized-service claim | customer device data, warranty and installation separate |
| Locksmith/security service | `EVIDENCE_REVIEW` | identity and sensitive service scope | emergency/mobile access requires specific controls |

## Evidence envelope

`SUBJECT`, `SHOP`, `CAPABILITY`, `EVIDENCE_TYPE`, `ISSUER`, `REFERENCE`, `SCOPE`,
`VALID_FROM`, `EXPIRES_AT`, `REVOCATION_CHECK`, `REVIEWER_CLASS`, `DECISION`,
`POLICY_VERSION`, `REASON`, `RECHECK_TRIGGER`, `RAW_DOCUMENT_RETENTION_CLASS`.

Only approved extracted facts should be visible to ordinary operators. Raw evidence
is restricted; customers see a precise badge/explanation, never the document.

## Lifecycle

`DRAFT → IDENTITY_CHECK → EVIDENCE_REQUIRED/UNDER_REVIEW → APPROVED_SCOPED /
RESTRICTED / REJECTED_UNSUPPORTED → RECHECK_DUE / SUSPENDED → SUPERSEDED/CLOSED`.

Expiry, revocation, policy change, material activity change, conflicting report and
document integrity signal trigger recheck. Loss of one capability should not suspend
unrelated ordinary activity where safely separable.

## Suspension and appeal

Suspension records exact scope, evidence, policy version, effective time, dependent
listings/ads/QR/staff effects and safe reason. Urgent containment can precede full
review, followed by prompt reassessment. Appeal preserves the original decision and
uses a different reviewer for high-impact cases where staffing allows; a one-person
pilot uses structured evidence and later sample review.

## Owner/professional decisions

- exact ordinary merchant minimum — `PRODUCT_OWNER` + `LAWYER`;
- sector/capability evidence sets — `DOMAIN_REGULATORY_SPECIALIST`;
- document minimization/retention — `KVKK/PRIVACY_SPECIALIST`;
- badge labels and customer meaning — `PRODUCT_OWNER` + `LAWYER`;
- recheck frequency and staffing — `PRODUCT_OWNER` after specialist input.

`MERCHANT_VERIFICATION_FINALIZED: NO`
