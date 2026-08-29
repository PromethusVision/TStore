# Wave 33 — Final Naming and Granularity Review

**State:** RECOMMENDATION — NO SOURCE RENAME APPLIED

## 1. Review principles

- Flag only names that materially confuse product identity, ownership or policy.
- Do not create cosmetic rename churn.
- Turkish customer language may retain widely understood retail borrowings.
- Policy, claim, brand, compatibility and gift intent should not be encoded as category identity.
- Variable depth is expected; equal depth across domains is not a quality target.

## 2. Material naming findings

| ID | Current/source wording | Finding | Recommendation | Type | Owner decision |
|---|---|---|---|---|:---:|
| NAM-001 | `İş & Güvenlik Ayakkabıları` → candidate `İş & Profesyonel Ayakkabılar` | Old name collides with certified PPE ownership | Approve candidate rename; safety footwear remains Hırdavat PPE | Exact non-structural L2 rename | YES |
| NAM-002 | `Balıkçılık & Avcılık` → candidate `Balıkçılık` | Old umbrella implies unapproved hunting capability | Approve candidate rename; hunting remains fail closed | Exact non-structural L2 rename | YES |
| NAM-003 | `Uyku Destek Ürünleri` | “Support” can mean accessory, supplement, medical device or service; product identity is not clear | Defer/remove until exact physical-product set is named, or replace with explicit non-medical product family | Scope clarification | YES |
| NAM-004 | `Bağımsız Banyo Yardımcıları` | “Helper” is too broad and overlaps accessibility/medical aids | If intent is ordinary products, use an exact family such as `Banyo Taburesi & Basamakları`; medical-intent aids stay Sağlık | Exact scope/name clarification | YES |
| NAM-005 | `Medikal İddiasız Masaj & Rahatlama Cihazları` | Negative claim/policy language is embedded in category name | Rename to `Masaj & Rahatlama Cihazları`; keep medical-claim exclusion in policy metadata | Exact non-structural rename | YES |
| NAM-006 | `Kimyasal Olmayan Bitki Koruma Örtüleri` | Negative policy qualifier is unnecessary for an intrinsically physical cover | Rename to `Bitki Koruma Örtüleri`; pesticide/chemical products remain absent by policy | Exact non-structural rename | YES |
| NAM-007 | `Piroteknik Olmayan Konfeti` | Negative prohibition is visible category copy | Rename to `Konfeti`; pyrotechnics remain hard-blocked by policy | Exact non-structural rename | YES |
| NAM-008 | `Piroteknik Olmayan Parti Üflemelileri` | Negative prohibition is visible category copy | Rename to `Parti Üflemelileri`; pyrotechnics remain hard-blocked by policy | Exact non-structural rename | YES |

`NAM-005`–`NAM-008` share one root principle and can be decided together: **category names describe the physical product; policy exclusions live in fail-closed metadata**. The recommendation does not relax any exclusion.

## 3. Reviewed and retained terminology

The following are not considered material blockers:

- `Ferace & Abaya`: both are recognizable Turkish retail/search terms; retain as one grouped leaf unless the owner returns an exact wording exception.
- `French Press`, `Moka Pot`, `Pour-Over`, `Airfryer`, `Outdoor`, `Trekking`, `Fitness`, `Puzzle`, `DJ`, `MIDI`, `SUP`, `clutch`, `hoodie`, `eyeliner`, `bronzer`: established retail terms with Turkish context/synonym support.
- `Stüdyo Monitörleri`: parent path makes audio-monitor identity clear and avoids confusion with Computer monitors.
- `Tüketici Tipi ... Tamir Parçaları`: awkward but materially useful to exclude service and professional/internal parts; no churn proposed.
- `Medikal İddiasız Burun Aspiratörleri` and `Medikal İddiasız Hamile Destekleri`: deliberately retained pending the Anne & Bebek professional review. Removing the qualifier without first defining the exact ordinary physical-product set could widen the Health boundary; this audit therefore does not create a cosmetic rename.
- Singular/plural variation follows natural Turkish retail usage rather than mechanical uniformity.

Brand, model, material, size, color, capacity, compatibility and marketing adjective were not found as standalone terminal categories.

## 4. Granularity audit

| Batch | L1 | L3 | L4 | Leaf | L4/leaf | Assessment |
|---|---:|---:|---:|---:|---:|---|
| 01 | 6 | 340 | 47 | 370 | 12.7% | BALANCED |
| 02 | 8 | 373 | 122 | 451 | 27.1% | BALANCED — domain-driven deeper split |
| 03 | 8 | 366 | 16 | 379 | 4.2% | BALANCED — stable L3 product families |

### Why Batch 02 is deeper

Of its 122 L4 nodes, 105 come from four domains:

- Müzik & Enstrüman: 31
- Spor & Outdoor: 34
- Beyaz Eşya & Ev Aletleri: 23
- Anne & Bebek: 17

These domains contain stable customer-recognized subtypes beneath broad equipment/device families. The remaining four Batch 02 domains contribute only 17 L4 nodes. Review found no evidence that material, capacity, age, brand or compatibility was used merely to manufacture depth.

### Why Batch 03 is shallower

Fourteen of its sixteen L4 nodes belong to Otomotiv & Motosiklet, where vehicle-part family distinctions justify depth. The other two are Kırtasiye product-type distinctions. Books, pet, optics, watches/jewelry, health and garden generally reach a stable product family at L2/L3; adding L4 would repeat format, species, material, claim or intended-user facets.

### Domain classification

| L1 | Granularity |
|---|---|
| Gıda & İçecek | BALANCED |
| Giyim & Moda | BALANCED |
| Ayakkabı | BALANCED |
| Çanta & Aksesuar | BALANCED |
| Beyaz Eşya & Ev Aletleri | BALANCED |
| Ev & Yaşam | BALANCED, with two broad leaf names requiring clarification |
| Züccaciye & Mutfak | BALANCED |
| Yapı, Hırdavat & Tesisat | BALANCED |
| Otomotiv & Motosiklet | BALANCED |
| Kozmetik & Kişisel Bakım | BALANCED |
| Anne & Bebek | BALANCED |
| Oyuncak & Hobi | BALANCED; preschool exception needs owner approval |
| Müzik & Enstrüman | BALANCED; registry decision remains open |
| Spor & Outdoor | BALANCED |
| Kitap | BALANCED |
| Kırtasiye & Ofis | BALANCED |
| Evcil Hayvan Ürünleri | BALANCED |
| Gözlük & Optik | BALANCED |
| Saat & Takı | BALANCED |
| Sağlık & Medikal | BALANCED |
| Çiçek & Bahçe | BALANCED |
| Hediyelik & Parti | BALANCED |

No domain is classified `TOO_NARROW`. The two broad Home leaves are naming/scope decisions, not a reason to redesign the whole domain. No `UNNECESSARY_DEPTH` branch was identified.

## 5. Turkish naturalness result

- Materially confusing source/candidate names: 8 records.
- Semantically independent decisions: four (PPE rename, fishing rename, one grouped Home-scope decision, one grouped policy-qualifier cleanup).
- Cosmetic-only rename recommendations: 0.
- Existing owner-final Elektronik/Bilgisayar names altered: 0.
- Candidate source files altered: 0.

`FINAL_NAMING_REVIEW: PASS_WITH_EXACT_DELTAS`
`GRANULARITY_AUDIT: PASS`
`OWNER_FINALIZATION_PERFORMED: NO`
