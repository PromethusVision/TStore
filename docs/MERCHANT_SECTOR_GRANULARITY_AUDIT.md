# EsnaftaVar Merchant Sector Granularity Audit

**State:** AUDIT OF V1 PROPOSAL — NO AUTOMATIC REWRITE

## Method

Every proposed hierarchy node is classified with exactly one requested label:

- `BALANCED`: understandable, durable merchant identity at its level;
- `TOO_BROAD`: likely needs an owner split or tighter definition;
- `TOO_NARROW`: likely better represented by a broader sector plus metadata;
- `UNNECESSARY`: no independent taxonomy value found;
- `LIKELY_PARENT`: useful for browse/governance but should not normally be assigned;
- `REGULATED_SPECIAL_CASE`: plausible identity whose launch needs separate scope/
  policy review.

The audit does not alter the proposal. A regulated classification is not a legal
conclusion. The internally confirmed beauty subtree is not reopened.

## Node audit

| NODE_ID | LEVEL | NODE | OWNER STATE | CLASSIFICATION | FINDING |
|---|:---:|---|---|---|---|
| MSF-01 | L1 | Gıda & Günlük Tüketim | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-02 | L1 | Giyim, Ayakkabı & Aksesuar | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-03 | L1 | Teknoloji & Elektronik | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-04 | L1 | Ev, Mutfak & Mobilya | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-05 | L1 | Yapı, Hırdavat & Tesisat | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-06 | L1 | Otomotiv, Motosiklet & Mobilite | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-07 | L1 | Kozmetik, Bakım & Güzellik | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-08 | L1 | Anne, Bebek, Oyuncak & Hobi | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-09 | L1 | Kitap, Kırtasiye & Ofis | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-10 | L1 | Spor & Outdoor | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-11 | L1 | Evcil Hayvan | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-12 | L1 | Optik, Saat, Takı & Medikal | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-13 | L1 | Çiçek, Bahçe, Hediyelik & Parti | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSF-14 | L1 | Tamir, Bakım & Yerel Hizmetler | PROPOSED | LIKELY_PARENT | Browse/governance family; recommend non-assignable. |
| MSS-001 | L2 | Market, Bakkal & Süpermarket | PROPOSED | TOO_BROAD | Real local identity, but scope/scale or product-intent leakage needs owner definition. |
| MSS-002 | L2 | Kasap | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-003 | L2 | Şarküteri | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-004 | L2 | Manav | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-005 | L2 | Fırın | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-006 | L2 | Pastane & Tatlıcı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-007 | L2 | Kuruyemişçi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-008 | L2 | Aktar | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-009 | L2 | İçecek & Su Bayii | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-010 | L2 | Giyim Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-011 | L2 | Ayakkabı Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-012 | L2 | Çanta & Aksesuar Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-013 | L2 | İç Giyim Mağazası | PROPOSED | TOO_NARROW | Standalone specialists exist; weigh acquisition value against alias/secondary specialization. |
| MSS-014 | L2 | Telefoncu & GSM Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-015 | L2 | Elektronik Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-016 | L2 | Bilgisayarcı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-017 | L2 | Beyaz Eşya & Ev Aletleri Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-018 | L2 | Mobilya Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-019 | L2 | Ev Tekstili Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-020 | L2 | Züccaciye & Mutfak Gereçleri Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-021 | L2 | Halı & Kilim Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-022 | L2 | Perdeci | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-023 | L2 | Nalbur & Hırdavatçı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-024 | L2 | Yapı Malzemeleri Satıcısı | PROPOSED | TOO_BROAD | Real local identity, but scope/scale or product-intent leakage needs owner definition. |
| MSS-025 | L2 | Elektrik Malzemeleri Satıcısı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-026 | L2 | Tesisat Malzemeleri Satıcısı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-027 | L2 | Boya & Dekorasyon Malzemeleri Satıcısı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-028 | L2 | Oto Yedek Parçacı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-029 | L2 | Oto Aksesuar Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-030 | L2 | Lastikçi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-031 | L2 | Motosiklet Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-032 | L2 | Motosiklet Yedek Parça & Aksesuar Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-033 | L2 | Bisiklet Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-034 | L2 | Kozmetik & Kişisel Bakım Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-035 | L2 | Parfümeri | PROPOSED | TOO_NARROW | Standalone specialists exist; weigh acquisition value against alias/secondary specialization. |
| MSS-036 | L2 | Berber, Kuaför & Güzellik Salonu | CONFIRMED_GROUPING_PARENT_PLACEMENT_PROPOSED | LIKELY_PARENT | Owner-confirmed grouping; wider placement proposed; recommend assignment to exact confirmed child. |
| MSS-037 | L3 | Erkek Berberi | CONFIRMED_SUBTREE | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-038 | L3 | Kadın Kuaförü | CONFIRMED_SUBTREE | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-039 | L3 | Güzellik Salonu | CONFIRMED_SUBTREE | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-040 | L2 | Anne & Bebek Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-041 | L2 | Oyuncakçı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-042 | L2 | Hobi & El Sanatları Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-043 | L2 | Müzik & Enstrüman Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-044 | L2 | Kitapçı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-045 | L2 | Kırtasiye | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-046 | L2 | Ofis Malzemeleri Mağazası | PROPOSED | TOO_NARROW | Standalone specialists exist; weigh acquisition value against alias/secondary specialization. |
| MSS-047 | L2 | Spor Malzemeleri Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-048 | L2 | Outdoor & Kamp Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-049 | L2 | Balıkçılık & Av Malzemeleri Mağazası | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-050 | L2 | Pet Shop | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-051 | L2 | Akvaryumcu | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-052 | L2 | Pet Kuaförü | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-053 | L2 | Optik Mağazası | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-054 | L2 | Kuyumcu | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-055 | L2 | Saatçi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-056 | L2 | Medikal Ürün Mağazası | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-057 | L2 | Çiçekçi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-058 | L2 | Bahçe & Yetiştirme Ürünleri Mağazası | PROPOSED | REGULATED_SPECIAL_CASE | Recognizable business identity; public activation and evidence scope must fail closed. |
| MSS-059 | L2 | Hediyelik Eşya Mağazası | PROPOSED | TOO_BROAD | Real local identity, but scope/scale or product-intent leakage needs owner definition. |
| MSS-060 | L2 | Parti Malzemeleri Mağazası | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-061 | L2 | Telefon & Elektronik Teknik Servisi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-062 | L2 | Bilgisayar Teknik Servisi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-063 | L2 | Beyaz Eşya Teknik Servisi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-064 | L2 | Terzi & Giyim Tadilatı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-065 | L2 | Ayakkabı Tamircisi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-066 | L2 | Anahtarcı | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-067 | L2 | Kuru Temizleme & Çamaşırhane | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |
| MSS-068 | L2 | Bisiklet Servisi | PROPOSED | BALANCED | Recognizable durable business identity at proposed depth. |

## Count reconciliation

| Classification | Count |
|---|---:|
| BALANCED | 53 |
| TOO_BROAD | 3 |
| TOO_NARROW | 3 |
| UNNECESSARY | 0 |
| LIKELY_PARENT | 15 |
| REGULATED_SPECIAL_CASE | 8 |
| **Total nodes** | **82** |

## Highest-value owner reviews

1. `Market, Bakkal & Süpermarket`: combined local identity reduces onboarding, but
   owner should decide whether scale distinction matters to customers.
2. `Yapı Malzemeleri Satıcısı`: broad identity is real, yet retailer vs project/
   installer scope needs definition.
3. `Hediyelik Eşya Mağazası`: common shop identity, but gift intent must not absorb
   products with stronger Product Taxonomy owners.
4. `İç Giyim Mağazası`, `Parfümeri`, `Ofis Malzemeleri Mağazası`: real specialist
   shops exist; owner should decide if their acquisition value justifies standalone
   sectors rather than aliases/secondary specializations.
5. Eight regulated special cases need sector-scope and evidence decisions before
   public activation.

`MERCHANT_GRANULARITY_AUDIT: PASS`

`PROPOSAL_AUTOMATICALLY_CHANGED: NO`

