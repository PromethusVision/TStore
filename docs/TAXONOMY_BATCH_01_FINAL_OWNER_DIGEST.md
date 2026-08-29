# Taxonomy Batch 01 — Final Owner Digest

**State: CANDIDATE FOR PRODUCT OWNER FINALIZATION**

This digest contains only owner-relevant deltas, high-impact depth choices and open gates. It is not a replacement for professional review and does not make any owner selection.

## 1. L2 delta versus prior proposals

| L1 | Old L2 | Candidate L2 | Change |
|---|---:|---:|---|
| Gıda & İçecek | 14 | 14 | All 14 UNCHANGED |
| Giyim & Moda | 10 | 10 | All 10 UNCHANGED |
| Ev & Yaşam | 10 | 10 | All 10 UNCHANGED |
| Züccaciye & Mutfak | 11 | 11 | All 11 UNCHANGED |
| Yapı, Hırdavat & Tesisat | 14 | 14 | All 14 UNCHANGED |
| Kozmetik & Kişisel Bakım | 11 | 11 | All 11 UNCHANGED |
| **Total** | **70** | **70** | **0 structural L2 changes** |

The reconciliation did not find evidence strong enough to rename, move, merge, split or remove an original L2. The proposals remain candidates until Product Owner approval.

## 2. High-impact L3/L4 choices

### Gıda & İçecek

- Consumable content is separated from kitchen objects.
- Baby-specific and medical/supplement nutrition do not enter ordinary food by default.
- Cold-chain products are categorized but remain policy/capability gated.

### Giyim & Moda

- Technical performance garments remain Giyim; equipment remains Spor & Outdoor.
- Ordinary workwear remains Giyim; certified protection-first apparel/footwear routes to Hırdavat PPE.
- Gender, age, size and style remain facets rather than parallel trees.

### Ev & Yaşam

- Smart products route to Elektronik; fixed wiring/plumbing routes to Hırdavat.
- Food-contact storage and kitchen textiles route to Züccaciye.
- Furniture uses L4 only for stable customer-recognized forms.

### Züccaciye & Mutfak

- Manual products remain here; powered appliances route to Beyaz Eşya & Ev Aletleri.
- Food-contact/heat-contact safety stays as professional metadata and policy gates.
- Technical outdoor hydration/cooling equipment does not leak into consumer lunch transport.

### Yapı, Hırdavat & Tesisat

- Gas, fixed electrical, chemical, structural and PPE products fail closed.
- Tool-platform-specific power stays with the tool; generic device power remains Elektronik.
- Smart locks route to Elektronik; mechanical locks remain Hırdavat.

### Kozmetik & Kişisel Bakım

- Medical intended use overrides cosmetic form and routes to professional review.
- Powered personal-care devices route to appliances; consumables/manual accessories remain here.
- Baby-specific products route to Anne & Bebek.

## 3. Owner decisions still required

1. Bulk approve, reject or request changes to each exact L2/L3/L4 candidate tree.
2. Confirm customer-facing wording for `Ferace & Abaya` and a small set of specialist edge nodes.
3. Confirm certified safety footwear remains Hırdavat PPE-owned rather than ordinary Ayakkabı.
4. Confirm that the proposed boundary rules are acceptable as canonical product-placement rules.

These are candidate decisions only. OM-R06, OM-R07 and OM-R10 are already final and are not reopened.

## 4. Professional and policy gates that remain open

| Domain | Required review |
|---|---|
| Gıda & İçecek | Food safety/cold chain, allergens/claims, baby and medical nutrition |
| Giyim & Moda | Certified PPE, performance claims, specialist children/intimate safety where applicable |
| Ev & Yaşam | Electrical, chemical, fire/load and medical-intended-use boundaries |
| Züccaciye & Mutfak | Food-contact materials, pressure, sharp tools and thermal safety |
| Yapı, Hırdavat & Tesisat | Electrical, gas, building, chemical, load-bearing and PPE compliance |
| Kozmetik & Kişisel Bakım | Ingredients, claims, biocidal/medical intended use and baby boundary |

Professional review is a publication gate, not an L1/L2 structural blocker.

## 5. Bulk-approval readiness

Structurally bulk-approvable domains:

1. Gıda & İçecek
2. Giyim & Moda
3. Ev & Yaşam
4. Züccaciye & Mutfak
5. Yapı, Hırdavat & Tesisat
6. Kozmetik & Kişisel Bakım

Machine candidate: 457 nodes, 370 assignable leaves, maximum L4, no L5, duplicate path 0.

Suggested owner action: review the four decisions above, then approve the six structural trees together or identify exact exception paths. Do not approve regulated publication, IDs or runtime migration through this taxonomy decision.

`READY_FOR_BULK_OWNER_FINALIZATION: YES`
`OWNER_FINALIZATION_PERFORMED: NO`
`RUNTIME_IMPLEMENTATION: NO`
