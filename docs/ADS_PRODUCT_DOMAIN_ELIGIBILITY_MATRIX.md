# Sponsored Advertising — Product Domain Eligibility Matrix

**State:** PROPOSED FOR PRODUCT OWNER AND POLICY REVIEW  
**Scope:** Design-only risk triage across the 24 owner-final Product Taxonomy L1 domains. This is not a runtime allowlist, legal opinion, or product-level approval.

## 1. Interpretation

The matrix assigns a proposed default **review posture**, not blanket permission. Every sponsored `SHOP_LISTING` still needs current listing, merchant, shop, stock/availability, price, evidence, targeting, budget, creative, location, and policy checks.

Postures:

- `NORMAL_CANDIDATE`: ordinary products may enter standard eligibility; exact restricted products can still be blocked.
- `REVIEW_REQUIRED`: domain has material claim, safety, age, licensing, compatibility, perishability, or cross-domain risk requiring extra rules/evidence.
- `RESTRICTED_CANDIDATE`: do not serve until a product-specific allowlist, verification, evidence, and review contract exists.
- `EXCLUDED_CANDIDATE`: not accepted for paid placement under the proposed model.

No entire L1 is proposed as unconditionally excluded. Product-level exclusions still apply within every L1.

## 2. Matrix

| # | Owner-final L1 | Proposed posture | Principal advertising boundary |
|---:|---|---|---|
| 1 | Gıda & İçecek | REVIEW_REQUIRED | Perishable/temperature-sensitive goods, alcohol/tobacco, supplements, health claims, registration, age limits, and delivery feasibility require explicit rules. Ordinary packaged food is not automatically prohibited. |
| 2 | Giyim & Moda | NORMAL_CANDIDATE | Exact available listing, truthful material/size claims, and no body-image or discriminatory targeting. Gender/size are facets, not category proof. |
| 3 | Ayakkabı | NORMAL_CANDIDATE | Exact size/stock and truthful material/condition; medical/orthopedic claims move to evidence review. |
| 4 | Çanta & Aksesuar | NORMAL_CANDIDATE | Counterfeit/high-value claims and cross-boundary watch/jewelry items require review; ordinary accessories may use standard eligibility. |
| 5 | Elektronik | NORMAL_CANDIDATE | Exact model/variant, warranty/condition, price, stock, and device/function boundary required; surveillance and hazardous power products may need review. |
| 6 | Bilgisayar & Tablet | NORMAL_CANDIDATE | Exact model/configuration, compatibility, condition, stock, and price snapshot required; no inferred specification claims. |
| 7 | Beyaz Eşya & Ev Aletleri | REVIEW_REQUIRED | Installation, electrical/gas safety, energy/performance, delivery/service-area, warranty, and exact model claims need stronger evidence. |
| 8 | Ev & Yaşam | NORMAL_CANDIDATE | Exact product and availability; avoid service/installation promises unless separately supported. |
| 9 | Züccaciye & Mutfak | NORMAL_CANDIDATE | Food-contact/safety claims must be factual; ordinary kitchenware may use standard eligibility. |
| 10 | Yapı, Hırdavat & Tesisat | REVIEW_REQUIRED | Hazardous chemicals, electrical/gas components, PPE/safety claims, professional-use products, and installation services require policy separation. |
| 11 | Otomotiv & Motosiklet | REVIEW_REQUIRED | Vehicle fitment, road safety, chemicals/oils, batteries, regulated equipment, and service/product boundaries require exact evidence. |
| 12 | Kozmetik & Kişisel Bakım | REVIEW_REQUIRED | Health/treatment claims, ingredient restrictions, authenticity, hygiene, age sensitivity, and professional services require review. |
| 13 | Anne & Bebek | REVIEW_REQUIRED | Infant safety, feeding, sleep, health claims, age suitability, recalls, and vulnerable-audience protections require stricter review. |
| 14 | Oyuncak & Hobi | REVIEW_REQUIRED | Age suitability, child safety, batteries/projectiles/chemicals, collectibles, and digital/service boundaries require rules. |
| 15 | Müzik & Enstrüman | REVIEW_REQUIRED | Exact instrument/accessory compatibility and condition; services, tickets, copyright content, and high-value instruments need separation/review. |
| 16 | Spor & Outdoor | REVIEW_REQUIRED | Protective/safety equipment, weapons-like/hunting items, supplements, age limits, fitment, and professional claims require review. |
| 17 | Kitap | NORMAL_CANDIDATE | V1 concerns physical books; digital rights/subscriptions and restricted/age-sensitive content need separate policy. Sponsorship must not imply editorial endorsement. |
| 18 | Kırtasiye & Ofis | NORMAL_CANDIDATE | Ordinary physical supplies; toner/cartridge follows printer compatibility, while chemicals, blades, and professional devices may need review. |
| 19 | Evcil Hayvan Ürünleri | REVIEW_REQUIRED | Live animals and veterinary medicines are excluded; ingestibles, health claims, species suitability, and welfare-sensitive products need policy review. |
| 20 | Gözlük & Optik | RESTRICTED_CANDIDATE | Prescription/custom optics, contact lenses, optician rules, health claims, and measurement dependencies require an explicit verified allowlist. Ordinary non-prescription accessories may later be carved out. |
| 21 | Saat & Takı | RESTRICTED_CANDIDATE | Precious/high-value goods, authenticity, hallmark/material claims, insurance/security, counterfeit risk, and smartwatch boundary require explicit controls. |
| 22 | Sağlık & Medikal | RESTRICTED_CANDIDATE | Prescription/restricted products, medical-device status, professional devices, diagnosis/treatment claims, evidence, and vulnerable users require fail-closed allowlisting. |
| 23 | Çiçek & Bahçe | REVIEW_REQUIRED | Live plants, invasive/protected species, pesticides/plant-protection products, fertilizers/chemicals, delivery viability, and arrangement/service boundary need rules. |
| 24 | Hediyelik & Parti | REVIEW_REQUIRED | Age-restricted/unsafe novelty items, food/alcohol bundles, pyrotechnics, personalized claims, event services, and mixed-product bundles require review. |

## 3. Posture Counts

| Posture | Count |
|---|---:|
| NORMAL_CANDIDATE | 9 |
| REVIEW_REQUIRED | 12 |
| RESTRICTED_CANDIDATE | 3 |
| EXCLUDED_CANDIDATE | 0 |
| **Total** | **24** |

## 4. Cross-Domain Exclusions and Review Gates

Regardless of L1, the proposed V1 must exclude or hold until explicit policy approval:

- illegal, recalled, counterfeit, stolen, or nonexistent products;
- prescription products and unapproved treatment/diagnostic claims;
- tobacco/nicotine and other age-restricted products without an owner-final policy;
- weapons, explosive/pyrotechnic products, and hazardous controlled materials without an owner-final policy;
- live animals;
- services represented as product listings;
- unavailable, inactive, unpriced, or materially stale shop listings;
- claims not supported by catalog evidence;
- products whose merchant authorization or required verification cannot be established.

Product grouping, merchant sector, free-text keywords, or historical campaign approval must never override these current checks.

## 5. Domain-Specific Notes

### Regulated health and optics

`Gözlük & Optik` and `Sağlık & Medikal` are restricted candidates because a broad L1 classification cannot prove that an exact product may lawfully or safely be advertised by a particular merchant. Product-specific allowlists, professional/merchant verification, claims evidence, and policy review are prerequisites.

### Food, supplements, cosmetics, and infant goods

These require claim-aware and product-type-aware policies. A registration or merchant document may be necessary evidence but is not itself an advertising endorsement. Sensitive audience targeting remains minimized and behavioral profiling is deferred.

### Plants and plant-protection products

Ordinary flowers/plants, arrangements, growing supplies, fertilizers, and plant-protection products must be distinguished. Pesticide/plant-protection advertising and live-plant movement need product-specific policy rather than broad L1 eligibility.

### High-value goods

Precious jewelry and high-value watches require authenticity, value/material claim, merchant verification, dispute, and fraud controls before paid amplification. Smartwatches remain in `Elektronik`, not `Saat & Takı`.

## 6. Required Evidence Layers

Eligibility should be the intersection of:

1. product-domain/product-type policy;
2. exact listing and current catalog state;
3. merchant/shop identity and required verification;
4. claim/evidence/creative review;
5. customer/surface/location suitability;
6. campaign budget, schedule, and pacing;
7. disclosure and ranking guardrails.

Unknown evidence is not positive evidence.

## 7. Open Owner Decisions

1. Product-level V1 allowlist/exclusion list inside each `REVIEW_REQUIRED` and `RESTRICTED_CANDIDATE` L1.
2. Whether alcohol, age-restricted products, supplements, contact lenses, precious goods, pesticides, and professional medical devices are excluded or admitted through verified review.
3. Which ordinary subdomains may be carved out from restricted L1s for standard eligibility.
4. Required merchant documents and renewal intervals per product policy.
5. Whether any sensitive domain is excluded entirely from launch even when legally permissible.

## 8. Recommendation

Treat the matrix as conservative policy routing. Start V1 with a narrow owner-approved product allowlist, not an L1-wide opt-in. Expand only after exact evidence, moderation, dispute, and audit controls are proven.

