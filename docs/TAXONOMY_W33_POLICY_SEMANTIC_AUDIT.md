# Wave 33 — Policy Semantic Audit

**State:** POST-R01–R09 RESOLVED AUDIT — NOT LEGAL/REGULATORY APPROVAL

## 1. Core rule

Taxonomy answers **what the physical product is**. It does not decide whether a SKU, merchant, claim, channel, customer age or fulfilment method is legally/commercially eligible. Product Owner structural approval cannot satisfy a lawyer, regulatory, food-safety, electrical, medical, child-safety, PPE or other professional gate.

## 2. Global evidence

| Metric | Result |
|---|---:|
| Resolved candidate leaves | 1,199 |
| `NORMAL` | 587 |
| `REGULATED` | 442 |
| `LEGAL_REVIEW_REQUIRED` | 170 |
| Policy-sensitive leaves | 612 |
| Professional-review leaves | 840 |
| Sensitive leaf with professional review `NO` | 0 |
| Legal-review leaf with professional review `NO` | 0 |
| Candidate rows mistakenly owner-final | 0 |
| Active prohibited/weapon/service leaf found | 0 |

The immutable source baseline remains 1,488 rows/1,200 leaves. R08=A removes one `LEGAL_REVIEW_REQUIRED` professional-review leaf from the resolved tree, producing 1,487 rows/1,199 leaves. The resolved rows remain `CANDIDATE_FOR_PRODUCT_OWNER_FINALIZATION` and continue to require the later 22-tree bulk owner approval. R01–R09 do not waive any professional gate.

## 3. Domain policy profile

| L1 | Leaves | Sensitive | Professional review | Audit result |
|---|---:|---:|---:|---|
| Gıda & İçecek | 71 | 19 | 19 | PASS — cold-chain/high-risk food separated; nutrition boundaries open |
| Giyim & Moda | 43 | 0 | 5 | PASS — certified protection routed out; claim reviews retained |
| Ayakkabı | 41 | 4 | 15 | PASS — safety-footwear owner decision open |
| Çanta & Aksesuar | 45 | 0 | 8 | PASS — high-risk/integrated carriers externally gated |
| Beyaz Eşya & Ev Aletleri | 66 | 11 | 66 | REVIEW — severity vocabulary calibration needed; no gate bypass |
| Ev & Yaşam | 63 | 6 | 13 | PASS — R08 removed/deferred the vague sleep leaf and narrowed the bathroom leaf |
| Züccaciye & Mutfak | 54 | 49 | 50 | PASS — food-contact/heat/sharp/pressure gates retained |
| Yapı, Hırdavat & Tesisat | 79 | 57 | 58 | PASS — gas/electrical/chemical/PPE fail closed |
| Otomotiv & Motosiklet | 71 | 58 | 58 | PASS — fitment/chemical/battery/safety gates retained |
| Kozmetik & Kişisel Bakım | 59 | 55 | 58 | PASS — intended-use/claim gates retained |
| Anne & Bebek | 53 | 49 | 53 | PASS — every leaf has professional review |
| Oyuncak & Hobi | 55 | 44 | 55 | PASS — every leaf reviewed; weapon-like scope absent |
| Müzik & Enstrüman | 72 | 2 | 72 | REVIEW — broad professional flag protects, policy severity needs calibration |
| Spor & Outdoor | 77 | 39 | 77 | PASS — every leaf reviewed; hunting absent |
| Kitap | 50 | 7 | 7 | PASS — physical product only; content/age gates separate |
| Kırtasiye & Ofis | 60 | 23 | 23 | PASS — cutting/chemical/electrical families separated |
| Evcil Hayvan Ürünleri | 43 | 31 | 31 | PASS — food/claim/water chemistry gated; live animal absent |
| Gözlük & Optik | 22 | 20 | 20 | PASS — prescription/contact-lens gates retained |
| Saat & Takı | 36 | 31 | 31 | PASS — precious/high-value/body-jewelry gates retained |
| Sağlık & Medikal | 44 | 44 | 44 | PASS — 44/44 legal-review fail closed |
| Çiçek & Bahçe | 53 | 40 | 40 | PASS — live plant/seed/fertilizer gated; pesticide absent |
| Hediyelik & Parti | 42 | 23 | 37 | PASS — pyrotechnic/pressurized-gas scope absent |

## 4. Policy-semantic findings

| ID | Finding | Evidence | Severity | Required action | Structural finalization blocker |
|---|---|---|---|---|:---:|
| POL-001 | Cross-batch meaning of `NORMAL` vs `REGULATED` is not fully calibrated | 228 leaves are `NORMAL` while still requiring professional review | P1 POLICY | Define policy-class semantics before runtime; preserve professional gate meanwhile | NO |
| POL-002 | Appliance severity is internally conservative but label-inconsistent with other electrical domains | 55/66 appliance leaves are `NORMAL+PRO=YES`, while lighting/tool electrical leaves often use `REGULATED` | P1 POLICY | Electrical/compliance specialist reviews class mapping; do not bulk relabel blindly | NO |
| POL-003 | Music candidate applies professional review much more broadly than policy class | 72/72 professional-review leaves; only 2 sensitive policy leaves | P2 POLICY | Calibrate whether review is catalog quality, electrical compliance or policy eligibility | NO |
| POL-004 | Home support/helper language could admit medical-intent products | R08=A removes/defer the sleep-support leaf and renames the bathroom leaf to `Banyo Taburesi & Basamakları` | RESOLVED OWNER / OPEN POLICY | Keep medical/accessibility scope outside this ordinary physical family unless separately reviewed | NO — RESOLVED |
| POL-005 | Parent policy is an aggregate, not SKU permission | Source trees elevate parent to strictest descendant in some batches | P2 DATA | Runtime policy must evaluate leaf/SKU evidence, not parent display alone | NO |
| POL-006 | Exclusion is represented by absence, not normal leaf | No firearm/ammunition/airsoft/paintball/hunting-weapon/firework/explosive/pesticide/live-animal/drug/supplement leaf | P0 SAFETY | Keep ingestion/search fail closed; taxonomy approval cannot add synonyms that bypass absence | NO — current state safe |
| POL-007 | Owner and professional approvals are distinct | Resolved rows still require bulk tree approval; 840 resolved leaves separately require professional review | P0 GOVERNANCE | Record both gates independently | NO |

The audit found no evidence that a known prohibited concept was silently granted a `NORMAL` commerce leaf. `POL-004` is owner-resolved; `POL-001`–`POL-003` remain professional metadata-calibration work and do not permit policy relaxation.

## 5. Sensitive-domain checks

### Food / baby / health

- General food remains Gıda; baby-specific formula/food is visible only as a candidate and requires owner + professional resolution.
- Medical nutrition, supplements, drugs, vaccines, hormones and controlled products have no normal leaf.
- Food/allergen/cold-chain claims remain SKU/listing evidence, not category permission.

### PPE / sports / automotive

- Occupational, sport, motorcycle, optical and medical protection use distinct intended-use owners.
- Certified claims require evidence; ordinary clothing/footwear cannot inherit certification from category wording.
- Hunting and weapon-like capability remains absent.

### Electrical / gas / chemical

- Professional-review flags prevent `NORMAL` electrical labels from being treated as automatic approval.
- Gas, fixed electrical, building chemistry, vehicle chemicals/batteries and hazardous garden chemistry remain fail closed.
- Policy-class calibration must precede any runtime allowlist.

### Cosmetics / optics / medical / pet

- Medical intended use overrides cosmetic or accessory form.
- Contact lens/refractive/custom optics require external merchant/legal eligibility.
- Veterinary drugs and live animals are absent; pet food and claims remain gated.

### High-value / child / live goods

- Precious-metal/stone/certification values are facets/evidence; investment-gold and loose-stone expansion remains out of scope.
- Child restraints, formula, sleep and toy safety retain professional review.
- Live plants, seed/fide and fertilizer remain legal/fulfilment gated; pesticide is absent.

## 6. Excluded-concept evidence

Active candidate path counts:

- `Avcılık`: 0
- firearm/tüfek/tabanca/ammunition/mühimmat: 0
- airsoft/paintball: 0
- firework/havai fişek/maytap/explosive: 0
- pesticide/herbicide/fungicide product leaf: 0
- live-animal product leaf: 0
- drug/vaccine/hormone/supplement product leaf: 0
- labor, booking, subscription or digital-service leaf: 0

The two paths containing the word `Piroteknik` explicitly say `Piroteknik Olmayan`; they do not enable pyrotechnics.

## 7. Professional-review routing

Required review lanes remain:

- lawyer/regulatory: restricted goods, optics, medical, cosmetic claims, baby formula, precious goods;
- food safety: food contact, cold chain, allergen and baby nutrition;
- electrical/gas/product safety: appliances, tools, installation, lighting, battery and pressure products;
- PPE/sport/vehicle safety: certification, activity and fitment boundaries;
- child/toy safety: age, restraint, small parts, chemicals and connected products;
- agriculture/pet: live goods, fertilizer, feed/claims and water chemistry.

## 8. Outcome

All 22 resolved candidate structures may proceed to one bulk owner-finalization session because no structural P0 or unauthorized policy relaxation was found. Policy metadata must not be activated at runtime until `POL-001`–`POL-003` and applicable professional gates are resolved.

`POLICY_SEMANTIC_AUDIT: PASS`
`UNAUTHORIZED_POLICY_RELAXATION: NONE_FOUND`
`PROFESSIONAL_REVIEW_TREATED_AS_OWNER_APPROVAL: NO`
`PROFESSIONAL_REVIEW_GATES: OPEN`
`RUNTIME_IMPLEMENTATION: NO`
