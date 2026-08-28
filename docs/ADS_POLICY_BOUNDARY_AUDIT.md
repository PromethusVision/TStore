# Sponsored Advertising Policy Boundary Audit

**State:** PROPOSED FAIL-CLOSED AUDIT — NOT LEGAL ADVICE

Advertising eligibility is stricter than or equal to catalog eligibility. A product
being correctly categorized, listed or sold by an eligible merchant does not prove
that its advertisement, claim, audience, creative or targeting is allowed.

## Evidence posture

- Türkiye commercial ads must be truthful, distinguishable and not unfair or
  deceptive; exact launch rules require legal review.
- The Ministry of Trade's 2026 targeted-ad direction requires transparent targeting
  criteria and prohibits profiling-based targeted advertising to children.
- Product-specific sector rules remain authoritative and must be rechecked at launch.

Sources:

- [Ministry of Trade — 2026 targeted-ad transparency/children](https://ticaret.gov.tr/haberler/ticaret-bakanligindan-cocuklarin-dijital-guvenligini-guclendirecek-onemli-duzenleme)
- [Ministry of Trade — advertising principles](https://dabm.ticaret.gov.tr/tuketici/ticari-reklamlar)
- [Ministry of Agriculture — food registration/approval](https://www.tarimorman.gov.tr/Konular/Gida-Ve-Yem-Hizmetleri/Gida-Hizmetleri/Kayit-Onay)
- [Ministry of Health — Opticianry Law](https://shgmsmdb.saglik.gov.tr/TR-102383/optisyenlik-hakkinda-kanun.html)
- [Medical-device advertising/sales regulation amendment](https://resmigazete.gov.tr/eskiler/2023/05/20230526-9.htm)
- [Ministry of Agriculture — plant-protection products](https://www.tarimorman.gov.tr/Konular/Bitki-Sagligi-Hizmetleri/Bitki-Koruma-Urunleri-Ve-Makinalari/Bitki-Koruma-Urunleri)

## Domain posture

| Risk family | Proposed advertising posture | Required gate |
|---|---|---|
| Alcohol/tobacco/nicotine | `EXCLUDED_CANDIDATE` | Separate owner/legal authorization; age posture |
| Prescription medicine | `EXCLUDED_CANDIDATE` | Outside current ordinary channel |
| Medical devices/professional/invasive/diagnostic | `RESTRICTED_CANDIDATE` | Exact device/merchant/claim/creative evidence |
| Supplements/vitamins/medical nutrition | `LEGAL_REVIEW_REQUIRED` | Product classification, claim, seller and ad rules |
| Infant formula/regulated baby feeding | `LEGAL_REVIEW_REQUIRED` | Exact product/audience/claim decision |
| PPE/protective goods | `REVIEW_REQUIRED` | Certification, intended use and claim evidence |
| Prescription/custom optics/contact lens | `RESTRICTED_CANDIDATE` | Optician/establishment/product/ad authorization |
| Pesticides/plant-protection products | `EXCLUDED_CANDIDATE` | No ordinary garden-category bypass |
| Firearms/ammunition/explosives/fireworks | `EXCLUDED_CANDIDATE` | No ordinary ad scope |
| Hunting/weapon-like goods | `LEGAL_REVIEW_REQUIRED` | Exact item allowlist, age and merchant controls |
| Hazardous chemicals/batteries/aerosols | `REVIEW_REQUIRED` | Handling, warnings, location/fulfilment constraints |
| Precious/high-value jewellery | `LEGAL_REVIEW_REQUIRED` | Merchant authorization, authenticity and fraud controls |
| Live animals/veterinary products | `EXCLUDED_OR_LEGAL_REVIEW` | Exact V1 scope decision |
| Ordinary policy-safe goods | `NORMAL_CANDIDATE` | Still requires truthful listing/creative and general safety |

## Targeting and creative rules

- No profiling-based targeted advertising to children in the proposed V1.
- No sensitive-health inference or medical-condition targeting.
- No unsubstantiated cure, certification, scarcity, cheapest or discount claim.
- Merchant sector never relaxes product advertising policy.
- Policy changes stop serving even when campaign/budget remains active.
- Missing or conflicting evidence becomes `POLICY_BLOCKED`/review, not approval.

## Owner/legal decisions

1. Exact advertising allowlist by Product L1/leaf and claim type.
2. Age assurance and excluded-product posture.
3. Regulated merchant/product evidence and reviewer.
4. Creative/landing/listing claim rules.
5. Targeting restrictions, retention and customer explanations.
6. Appeal, recall, emergency stop and audit retention.

`AD_POLICY_DEFAULT: FAIL_CLOSED`

`CATALOG_ELIGIBLE_IMPLIES_AD_ELIGIBLE: NO`

`LEGAL_REVIEW_REQUIRED: YES`
