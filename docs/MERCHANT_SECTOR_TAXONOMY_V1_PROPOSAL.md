# EsnaftaVar Merchant Sector Taxonomy V1 Proposal

**State:** PROPOSED FOR OWNER REVIEW

**Exception:** The exact `Berber, Kuaför & Güzellik Salonu` subtree is already
Product Owner confirmed. Its placement under the proposed wider hierarchy is not
owner-final.

## 1. Proposal objective

This tree answers **“Bu işletme ne tür bir işletme?”** for Turkish neighbourhood
commerce. It is deliberately not the owner-final 24-L1 Product Taxonomy. A merchant
may sell products from any number of Product L1s; every SKU retains its independent
canonical product leaf.

The proposal uses familiar storefront identities, not legal activity-code wording.
NACE/TESK signals support boundaries and verification; they are not copied into the
customer UI.

## 2. Structure and counts

- Proposed navigation families (L1): **14**
- Merchant-sector nodes at L2: **65**
- Specialist L3 leaves: **3** — all are in the owner-confirmed beauty subtree
- Total hierarchy nodes: **82**
- Assignable leaf sectors: **67**
- Proposed maximum depth: **3**
- Default operating model among assignable leaves: `RETAIL 53`, `SERVICE 12`,
  `MIXED 2`

Families and the `Berber, Kuaför & Güzellik Salonu` grouping node are not directly
assignable in the recommendation. Parent assignability remains an owner decision.

## 3. Exact proposed hierarchy

All unmarked nodes below are `PROPOSED FOR OWNER REVIEW`.

### 1. Gıda & Günlük Tüketim

1. Market, Bakkal & Süpermarket
2. Kasap
3. Şarküteri
4. Manav
5. Fırın
6. Pastane & Tatlıcı
7. Kuruyemişçi
8. Aktar
9. İçecek & Su Bayii

### 2. Giyim, Ayakkabı & Aksesuar

1. Giyim Mağazası
2. Ayakkabı Mağazası
3. Çanta & Aksesuar Mağazası
4. İç Giyim Mağazası

### 3. Teknoloji & Elektronik

1. Telefoncu & GSM Mağazası
2. Elektronik Mağazası
3. Bilgisayarcı
4. Beyaz Eşya & Ev Aletleri Mağazası

### 4. Ev, Mutfak & Mobilya

1. Mobilya Mağazası
2. Ev Tekstili Mağazası
3. Züccaciye & Mutfak Gereçleri Mağazası
4. Halı & Kilim Mağazası
5. Perdeci

### 5. Yapı, Hırdavat & Tesisat

1. Nalbur & Hırdavatçı
2. Yapı Malzemeleri Satıcısı
3. Elektrik Malzemeleri Satıcısı
4. Tesisat Malzemeleri Satıcısı
5. Boya & Dekorasyon Malzemeleri Satıcısı

### 6. Otomotiv, Motosiklet & Mobilite

1. Oto Yedek Parçacı
2. Oto Aksesuar Mağazası
3. Lastikçi
4. Motosiklet Mağazası
5. Motosiklet Yedek Parça & Aksesuar Mağazası
6. Bisiklet Mağazası

### 7. Kozmetik, Bakım & Güzellik

1. Kozmetik & Kişisel Bakım Mağazası
2. Parfümeri
3. **Berber, Kuaför & Güzellik Salonu** — `CONFIRMED SUBTREE`; wider parent
   placement remains `PROPOSED`
   1. **Erkek Berberi** — `CONFIRMED — PRODUCT OWNER FINAL`
   2. **Kadın Kuaförü** — `CONFIRMED — PRODUCT OWNER FINAL`
   3. **Güzellik Salonu** — `CONFIRMED — PRODUCT OWNER FINAL`

`Unisex Kuaför` is intentionally absent and must not be added. Booking,
reservation, service availability and service-price models remain `TBD`.

### 8. Anne, Bebek, Oyuncak & Hobi

1. Anne & Bebek Mağazası
2. Oyuncakçı
3. Hobi & El Sanatları Mağazası
4. Müzik & Enstrüman Mağazası

### 9. Kitap, Kırtasiye & Ofis

1. Kitapçı
2. Kırtasiye
3. Ofis Malzemeleri Mağazası

### 10. Spor & Outdoor

1. Spor Malzemeleri Mağazası
2. Outdoor & Kamp Mağazası
3. Balıkçılık & Av Malzemeleri Mağazası

### 11. Evcil Hayvan

1. Pet Shop
2. Akvaryumcu
3. Pet Kuaförü

### 12. Optik, Saat, Takı & Medikal

1. Optik Mağazası
2. Kuyumcu
3. Saatçi
4. Medikal Ürün Mağazası

### 13. Çiçek, Bahçe, Hediyelik & Parti

1. Çiçekçi
2. Bahçe & Yetiştirme Ürünleri Mağazası
3. Hediyelik Eşya Mağazası
4. Parti Malzemeleri Mağazası

### 14. Tamir, Bakım & Yerel Hizmetler

1. Telefon & Elektronik Teknik Servisi
2. Bilgisayar Teknik Servisi
3. Beyaz Eşya Teknik Servisi
4. Terzi & Giyim Tadilatı
5. Ayakkabı Tamircisi
6. Anahtarcı
7. Kuru Temizleme & Çamaşırhane
8. Bisiklet Servisi

## 4. Assignability and default operating model

| Default | Sectors |
|---|---|
| `RETAIL` | All assignable leaves except those listed below |
| `SERVICE` | Erkek Berberi; Kadın Kuaförü; Güzellik Salonu; Pet Kuaförü; all eight leaves under Tamir, Bakım & Yerel Hizmetler |
| `MIXED` | Lastikçi; Optik Mağazası |

The default does not override a merchant's actual operation. A telefoncu with a
material repair workshop can be `MIXED` without creating a new taxonomy node or
changing its primary/secondary sector automatically.

## 5. Inclusion and exclusion rules

### Gıda & Günlük Tüketim

- Includes recognizable food-led storefronts and specialist fresh/packaged food
  sellers.
- A supermarket's cosmetics, stationery or pet shelf remains cross-Product-L1
  inventory, not secondary merchant sectors by default.
- Restaurant, catering, alcohol, tobacco and pharmacy concepts are not inferred.

### Retail families

- The merchant name reflects the durable retail proposition, not each product
  family stocked.
- `Hediyelik Eşya Mağazası` does not own jewellery, food, flower or home-goods
  products sold as gifts.
- `Telefoncu & GSM Mağazası` does not own generic audio/power or computer products;
  their canonical Product Taxonomy rules still apply.
- `Nalbur & Hırdavatçı` can sell electrical, garden and household items without
  forcing them into the product hardware domain.

### Services

- A repair-service leaf describes labor/expertise, not replacement parts.
- Product sale and service transactions remain distinct future records.
- Home-visit/service-area capability is metadata, not another sector.
- Booking/reservation and service-price architecture are outside this proposal.

### Regulated boundaries

- Optik, medikal, kuyum and regulated-plant-protection activity are fail-closed
  verification/policy scopes.
- A general `Eczane`, veterinary clinic or agricultural pesticide dealer is not
  silently added to the tree.
- Balıkçılık/av retail does not authorize weapon-like or restricted goods.
- Sector approval never authorizes a product listing.

## 6. Why this granularity

The proposal keeps common standalone Turkish businesses distinct where their
customer intent, professional language and acquisition motion differ (`kasap`,
`manav`, `telefoncu`, `bilgisayarcı`, `nalbur`, `kırtasiye`, `optikçi`). It avoids
creating nodes for every department, service, inventory line or Product L1.

Potentially close pairs remain separate only where merchants commonly identify
with them independently:

- Fırın vs Pastane & Tatlıcı
- Kasap vs Şarküteri
- Kitapçı vs Kırtasiye
- Telefoncu vs Bilgisayarcı
- Çiçekçi vs Hediyelik Eşya Mağazası
- Kuyumcu vs Saatçi

The primary/secondary model handles genuine combinations without hybrid-name
inflation.

## 7. Open Product Owner decisions

1. Approve, merge or rename the 14 proposed navigation families.
2. Approve the 64 proposed assignable leaves outside the three confirmed beauty
   leaves, and the proposed beauty-parent placement.
3. Decide whether `Market, Bakkal & Süpermarket` should remain one customer-facing
   sector or split by operating scale.
4. Decide whether `İç Giyim Mağazası`, `Parfümeri` and `Ofis Malzemeleri Mağazası`
   warrant standalone sectors or should become secondary aliases/facets.
5. Confirm the broad `Optik, Saat, Takı & Medikal` family despite mixed policy risk,
   or separate its navigation grouping without changing assignable leaves.
6. Decide whether `Tamir, Bakım & Yerel Hizmetler` is the correct parent for all
   eight service leaves.
7. Confirm recommended maximum of three secondary sectors.
8. Decide parent-node assignability. Recommendation: non-assignable families and
   non-assignable confirmed beauty grouping.
9. Establish the regulated-merchant verification owner and launch allowlist.
10. Booking/reservation/service price remains `TBD`; it is not a taxonomy decision.

## 8. Proposal safeguards

- Duplicate exact assignable sector names: **0**
- Brand-as-sector: **0**
- Product category used as merchant ownership rule: **0**
- Owner-finalization added by this document: **0**
- Confirmed beauty subtree altered: **NO**
- `Unisex Kuaför`: **ABSENT**
- Runtime/DB/remote implementation: **NO**

`MERCHANT_SECTOR_TAXONOMY_V1: PROPOSED_FOR_OWNER_REVIEW`

`CONFIRMED_BEAUTY_SUBTREE_PRESERVED: PASS`
