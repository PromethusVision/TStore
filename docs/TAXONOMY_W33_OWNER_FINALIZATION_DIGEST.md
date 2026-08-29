# Wave 33 — Product Owner Finalization Digest

**State:** READY FOR OWNER REVIEW — NO OWNER SELECTION RECORDED

This digest reduces the 22 candidate trees to nine root questions. It does not repeat 1,200 leaves. Every unaffected path remains exactly as supplied by the three Wave 32 source batches. Product Owner taxonomy approval and professional/policy approval remain separate gates.

## A. Bulk approve as-is

The following nine L1 candidates have no remaining Wave 33 boundary or material naming decision. Their structure can be approved as supplied, while their professional-review flags remain open:

1. Züccaciye & Mutfak
2. Kozmetik & Kişisel Bakım
3. Otomotiv & Motosiklet
4. Kitap
5. Kırtasiye & Ofis
6. Evcil Hayvan Ürünleri
7. Gözlük & Optik
8. Saat & Takı
9. Sağlık & Medikal

For the other 13 L1s, the unaffected paths can also be bulk approved. Only the exact nodes named under R01–R09 remain exceptional.

## B. Bulk approve with exact non-structural rename

These changes do not alter depth, leaf count or product ownership. They need an owner answer but do not require tree redesign.

| Root | Exact change | Domain | Recommendation |
|---|---|---|---|
| R01 | `İş & Güvenlik Ayakkabıları` → `İş & Profesyonel Ayakkabılar` | Ayakkabı | Approve |
| R02 | `Balıkçılık & Avcılık` → `Balıkçılık` | Spor & Outdoor | Approve |
| R09 | `Medikal İddiasız Masaj & Rahatlama Cihazları` → `Masaj & Rahatlama Cihazları` | Beyaz Eşya & Ev Aletleri | Approve with policy gate unchanged |
| R09 | `Kimyasal Olmayan Bitki Koruma Örtüleri` → `Bitki Koruma Örtüleri` | Çiçek & Bahçe | Approve with chemical/pesticide exclusion unchanged |
| R09 | `Piroteknik Olmayan Konfeti` → `Konfeti` | Hediyelik & Parti | Approve with pyrotechnics exclusion unchanged |
| R09 | `Piroteknik Olmayan Parti Üflemelileri` → `Parti Üflemelileri` | Hediyelik & Parti | Approve with pyrotechnics exclusion unchanged |

The first two names are already present in the Wave 32 candidate rows; the decision is whether to accept those candidate deltas. R09 is a Wave 33 naming recommendation only and has not been applied to the source or unified candidate CSV.

## C. Requires one last owner decision

### R01 — Ordinary professional footwear vs certified PPE

**Question:** Should ordinary occupational footwear stay in Ayakkabı under `İş & Profesyonel Ayakkabılar`, while certified protection-first footwear belongs only to Hırdavat PPE?

**Option A:** Use the evidence-based split and approve the proposed Ayakkabı rename.

**Option B:** Keep the old mixed `İş & Güvenlik Ayakkabıları` umbrella and require a later structural separation.

**Recommended:** Option A.

**Why:** It prevents an ordinary shoe category from implying PPE certification, preserves customer discovery and gives certified safety footwear one canonical owner.

**Affected nodes:** Ayakkabı → `İş & Profesyonel Ayakkabılar`; Hırdavat → `İş Güvenliği & Koruyucu Donanım → İş Güvenliği Ayakkabıları`; related protective apparel/boots use intended-use evidence.

### R02 — Fishing without a hunting umbrella

**Question:** Should the candidate L2 be finalized as `Balıkçılık`, with hunting and weapon-like products remaining fail closed?

**Option A:** Approve `Balıkçılık`; any future hunting proposal requires separate legal/domain review.

**Option B:** Restore `Balıkçılık & Avcılık` despite having no approved hunting leaves.

**Recommended:** Option A.

**Why:** The current seven-node branch contains fishing products only; the broader name would suggest unsupported and policy-sensitive scope.

**Affected nodes:** Spor & Outdoor → `Balıkçılık` and its six leaves; no hunting, firearm, ammunition, airsoft or paintball node is created.

### R03 — Baby-specific formula and food ownership

**Question:** Should baby-specific formula and age-specific foods be discovered under Anne & Bebek while reusing Gıda safety/regulatory evidence?

**Option A:** Anne & Bebek is the primary taxonomy owner for baby-specific formula/food; general food remains Gıda.

**Option B:** Move every edible product to Gıda and keep Anne & Bebek as a discovery alias/facet only.

**Recommended:** Option A.

**Why:** It matches the parent’s shopping task without duplicating identity, while the shared food-policy gate prevents taxonomy placement from granting sale permission.

**Affected nodes:** Anne & Bebek → `Bebek Beslenme → Bebek Formülü & Yaşa Özgü Gıdalar` and four L4 leaves; Gıda remains the policy/evidence dependency.

### R04 — Standalone carrier vs integrated host module

**Question:** Should a separately sold bag remain in Çanta & Aksesuar, while an inseparable, function-bearing carrier follows its host domain?

**Option A:** Standalone bag → Çanta; integrated stroller, hydration, bicycle or safety module → host domain.

**Option B:** Place every carrier in its use-domain, creating repeated bag identities.

**Recommended:** Option A.

**Why:** Physical identity stays stable and compatibility remains a facet, yet genuinely integrated systems remain discoverable with the equipment they serve.

**Affected nodes:** Çanta → `Bebek Bakım Çantaları`, `Enstrüman Çantaları`; Anne & Bebek stroller modules; Spor → `Teknik Hidrasyon & Taşıma Sistemleri`, `Bisiklete Monte Çanta & Taşıyıcılar`.

### R05 — Traditional Turkish instrument registry

**Question:** Should traditional instruments use one registry-backed canonical leaf per instrument instead of being duplicated across broad instrument families?

**Option A:** Keep the proposed exact traditional-instrument registry and map alternate names/styles as synonyms or relationships.

**Option B:** Repeat instruments under multiple families for navigation convenience.

**Recommended:** Option A.

**Why:** It provides one canonical product path and prevents duplicate identity while allowing multiple discovery routes later.

**Affected nodes:** Müzik & Enstrüman → `Geleneksel Türk Müziği Enstrümanları`, including Bağlama, traditional wind and percussion families.

### R06 — Preschool taxonomy exception

**Question:** Should `Bebek & Okul Öncesi Oyuncaklar` remain an explicit schema-bearing exception even though age is normally a facet?

**Option A:** Retain the exception because these product families have distinct safety/schema needs; other ages remain facets.

**Option B:** Remove the age-stage branch and classify every item only by toy form.

**Recommended:** Option A.

**Why:** The exception is narrow, safety-relevant and customer-recognizable; it does not justify turning general age bands into categories.

**Affected nodes:** Oyuncak & Hobi → `Bebek & Okul Öncesi Oyuncaklar` and five L3 leaves.

### R07 — Intrinsic gift identity

**Question:** Should Hediyelik & Parti contain only products whose identity is intrinsically commemorative/gift-presentation, while ordinary products given as gifts remain in their base domain?

**Option A:** Use the intrinsic-keepsake test; gift intent, recipient and personalization remain facets.

**Option B:** Allow gift intent to duplicate ordinary products under Hediyelik.

**Recommended:** Option A.

**Why:** It preserves one canonical leaf per product and prevents Hediyelik from becoming a second copy of every L1.

**Affected nodes:** Hediyelik → `Hatıra & Hediyelik Objeler`, `Hediye Paketleme & Sunum`; ordinary decor, flower, jewelry, clothing and food stay in their base domains.

### R08 — Two broad Home support/helper leaves

**Question:** Should the two ambiguous Home leaves be narrowed/deferred before finalization?

**Option A:** Defer/remove `Uyku Destek Ürünleri` until an exact non-medical family exists; replace `Bağımsız Banyo Yardımcıları` with an exact ordinary family such as `Banyo Taburesi & Basamakları` if that is the intended scope.

**Option B:** Retain both broad labels with `LEGAL_REVIEW_REQUIRED` and resolve products individually later.

**Recommended:** Option A.

**Why:** Taxonomy names should state the physical product. The current labels can absorb supplements, medical devices, accessibility aids or services despite the policy gate.

**Affected nodes:** Ev & Yaşam → `Yatak & Uyku Ürünleri → Uyku Destek Ürünleri`; `Banyo Aksesuarları → Bağımsız Banyo Yardımcıları`.

### R09 — Policy exclusions in labels or metadata

**Question:** Should exact physical-product names replace four negative policy qualifiers while fail-closed policy metadata remains unchanged?

**Option A:** Use the four clean names in section B and enforce medical, chemical/pesticide and pyrotechnic exclusions in policy metadata.

**Option B:** Retain the defensive source wording in customer-facing taxonomy.

**Recommended:** Option A.

**Why:** A category should say what the product is; a shorter label does not authorize a prohibited claim or product when the separate policy gate remains mandatory.

**Affected nodes:** one appliance leaf, one garden leaf and two party leaves listed in section B. The two Anne & Bebek `Medikal İddiasız ...` leaves are intentionally outside this bulk rename pending their professional scope review.

## D. Blocked by structural issue

**None.** The audit found zero unresolved structural P0 blocker. R01–R09 are exact boundary, naming or scope decisions and do not require redesigning an entire L1 tree.

## E. Taxonomy ready but professional policy review remains

Every candidate L1 contains at least one professional-review leaf. Across all candidates:

- professional-review leaves: **841**;
- policy-sensitive leaves: **613** (`REGULATED` 442 + `LEGAL_REVIEW_REQUIRED` 171);
- policy-sensitive leaf missing professional review: **0**.

Owner finalization can approve product identity and placement, but must not activate these leaves for runtime commerce. Required lanes include legal/regulatory, food safety, electrical/gas/product safety, PPE/sport/vehicle safety, child/toy safety, medical/optical/cosmetic claims, agriculture/pet and high-value goods.

## Minimal owner workload

- Root answers required: **9**.
- Domains fully approvable as-is: **9**.
- Remaining 13 domains: approve all unaffected paths in bulk, then answer only the applicable R01–R09 exceptions.
- Structural redesign required: **0 domains**.
- Professional review waived by an owner answer: **0 leaves**.

`FINAL_OWNER_DIGEST: PASS`
`READY_FOR_BULK_OWNER_FINALIZATION: YES`
`OWNER_FINALIZATION_PERFORMED: NO`
`RUNTIME_IMPLEMENTATION: NO`
