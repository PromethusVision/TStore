# EsnaftaVar Global Facet Registry

**Wave:** 15 / Global Facet, Attribute & Search Architecture  
**Date:** 28 August 2026  
**State:** `PROVISIONAL ARCHITECTURE — READY FOR OWNER REVIEW`  
**Runtime:** None; concept IDs are documentation-only and are not UUIDs, columns or API keys.

## Contract

Taxonomy answers **what the product is**. A facet answers **what characteristics it
has**. Search wording, listing eligibility and compatibility are separate contracts.
The registry therefore does not create category nodes, approve products, define a
Production schema or make the 22 proposed L2 domains final.

Data types use `TEXT`, `ENUM`, `BOOLEAN`, `INTEGER`, `DECIMAL`, `RANGE`, `DATE`,
`IDENTIFIER`, `STRUCTURED` and `RELATION`. `CONTROLLED` means a governed value set;
`MEASURED` means normalized numeric value plus unit; `REFERENCE` means a reference
to a separately governed entity. `ALL` in applicability means potentially reusable,
not automatically required in every leaf.

## Registry

| FACET_ID_CONCEPT | TURKISH_NAME | ENGLISH_TECHNICAL_NAME | DATA_TYPE | VALUE_TYPE | UNIT | MULTI_VALUE | SEARCH_FILTERABLE | DISPLAYABLE | SORTABLE | DOMAIN_SCOPE | APPLICABLE_L1 | CATEGORY_CONFUSION_RISK | EXAMPLES | NOTES |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| FACET-G-001 | Marka | Brand | TEXT | REFERENCE | — | NO | YES | YES | YES | GLOBAL_SHARED | ALL | HIGH | yerel üretici markası | Marka category/synonym değildir. |
| FACET-G-002 | Üretici | Manufacturer | TEXT | REFERENCE | — | NO | YES | YES | YES | GLOBAL_SHARED | ALL | MEDIUM | üretici ticari unvanı | Marka ile aynı kavram değildir. |
| FACET-G-003 | Model | Model designation | TEXT | CONTROLLED | — | NO | YES | YES | YES | GLOBAL_SHARED | dayanıklı ürünler | HIGH | model kodu | Category identity üretmez. |
| FACET-G-004 | Renk ailesi | Color family | ENUM | CONTROLLED | — | YES | YES | YES | YES | GLOBAL_SHARED | ALL | HIGH | siyah; lacivert | Vendor shade ayrıca saklanabilir. |
| FACET-G-005 | Malzeme | Material | ENUM | CONTROLLED | — | YES | YES | YES | NO | GLOBAL_SHARED | ALL | HIGH | pamuk; çelik; cam | Kompozisyon yüzdesi ayrı facet'tir. |
| FACET-G-006 | Stil | Style | ENUM | CONTROLLED | — | YES | YES | YES | NO | GLOBAL_SHARED | giyim; ev; aksesuar | HIGH | klasik; modern | Koleksiyon/category değildir. |
| FACET-G-007 | Desen | Pattern | ENUM | CONTROLLED | — | YES | YES | YES | NO | GLOBAL_SHARED | giyim; ev; kırtasiye | MEDIUM | çizgili; geometrik | Serbest title yerine kontrollü aile. |
| FACET-G-008 | Ürün durumu | Condition | ENUM | CONTROLLED | — | NO | YES | YES | NO | GLOBAL_SHARED | ALL | HIGH | yeni; yenilenmiş | Eligibility ayrıca policy'dir. |
| FACET-G-009 | Menşe | Country/region of origin | TEXT | CONTROLLED | ISO/yerel kod | YES | YES | YES | YES | GLOBAL_SHARED | ALL | MEDIUM | TR; Ege | Claim kanıtı gerekebilir. |
| FACET-G-010 | Hedef kullanıcı sunumu | Audience presentation | ENUM | CONTROLLED | — | YES | YES | YES | NO | GLOBAL_SHARED | giyim; ayakkabı; bakım; aksesuar | HIGH | kadın; erkek; unisex | Product identity değildir. |
| FACET-G-011 | Yaş / yaşam evresi | Age or life stage | RANGE | MEASURED | ay/yıl | YES | YES | YES | YES | GLOBAL_SHARED | çocuk/bebek/pet odaklı ürünler | HIGH | 0–6 ay; yetişkin | Safety gate ile karıştırılmaz. |
| FACET-G-012 | Paket adedi | Package count | INTEGER | MEASURED | adet | NO | YES | YES | YES | GLOBAL_SHARED | ALL | LOW | 6 adet | Set içeriğiyle aynı değildir. |
| FACET-G-013 | Set / bundle durumu | Bundle state | ENUM | CONTROLLED | — | NO | YES | YES | NO | GLOBAL_SHARED | ALL | HIGH | tekil; set; kit | Principal product leaf korunur. |
| FACET-G-014 | Fiziksel form | Physical form | ENUM | CONTROLLED | — | NO | YES | YES | NO | GLOBAL_SHARED | çoklu domain | HIGH | sprey; jel; tablet form | Ancak gerçek product type ise leaf olabilir. |
| FACET-G-015 | Kullanım ortamı | Use environment | ENUM | CONTROLLED | — | YES | YES | YES | NO | GLOBAL_SHARED | ev; spor; elektronik; yapı | MEDIUM | iç mekân; dış mekân | Merchant sector değildir. |
| FACET-G-016 | Bakım talimatı | Care instruction | TEXT | CONTROLLED | — | YES | NO | YES | NO | GLOBAL_SHARED | tekstil; ayakkabı; ev; takı | LOW | elde yıkama | Display verisidir. |
| FACET-G-017 | Garanti türü | Warranty type | ENUM | CONTROLLED | — | NO | YES | YES | NO | GLOBAL_SHARED | dayanıklı ürünler | MEDIUM | üretici garantisi | Süre listing/offer verisi olabilir. |
| FACET-G-018 | Kişiselleştirilebilir | Personalization available | BOOLEAN | CONTROLLED | — | NO | YES | YES | NO | GLOBAL_SHARED | hediye; aksesuar; takı | HIGH | evet | Hizmet node'u üretmez. |
| FACET-D-001 | Beden etiketi | Size label | TEXT | CONTROLLED | beden sistemi | NO | YES | YES | YES | DOMAIN_SHARED | giyim; ayakkabı; bebek; koruyucu ürün | HIGH | M; 42; 3-6 ay | Ölçüden ayrı tutulur. |
| FACET-D-002 | Fiziksel ölçüler | Dimensions | STRUCTURED | MEASURED | mm/cm/m | NO | YES | YES | YES | DOMAIN_SHARED | ev; cihaz; çanta; bahçe | HIGH | 60×40×30 cm | Eksen sırası typed olmalıdır. |
| FACET-D-003 | Net ürün ağırlığı | Net weight | DECIMAL | MEASURED | g/kg | NO | YES | YES | YES | DOMAIN_SHARED | gıda; ürün; spor; yapı | MEDIUM | 750 g | Kargo ağırlığı değildir. |
| FACET-D-004 | Kapasite | Capacity | DECIMAL | MEASURED | domain birimi | NO | YES | YES | YES | DOMAIN_SHARED | cihaz; çanta; kap; depolama | HIGH | 128 GB; 25 L | Unit family zorunlu. |
| FACET-D-005 | Sıvı hacmi | Liquid volume | DECIMAL | MEASURED | ml/L | NO | YES | YES | YES | DOMAIN_SHARED | gıda; bakım; kimyasal; kap | MEDIUM | 500 ml | Kapasite kavramıyla ekranda birleşebilir. |
| FACET-D-006 | Çap | Diameter | DECIMAL | MEASURED | mm/cm | YES | YES | YES | YES | DOMAIN_SHARED | mutfak; saat; optik; yapı | MEDIUM | 28 cm | Bağlam/ölçüm noktası gerekir. |
| FACET-D-007 | Uzunluk | Length | DECIMAL | MEASURED | mm/cm/m | YES | YES | YES | YES | DOMAIN_SHARED | kablo; tekstil; takı; bahçe | MEDIUM | 2 m | Eksenli dimensions'tan ayrı sorgulanabilir. |
| FACET-D-008 | Kalıp / oturuş | Fit | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | giyim; ayakkabı; optik; koruyucu ürün | HIGH | dar; regular; wide | Uyumluluk sonucu değildir. |
| FACET-D-009 | Malzeme kompozisyonu | Material composition | STRUCTURED | MEASURED | % | YES | YES | YES | NO | DOMAIN_SHARED | giyim; ev tekstili; takı | MEDIUM | %80 pamuk | Toplam yüzde doğrulanır. |
| FACET-D-010 | İçindekiler | Ingredient list | TEXT | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | gıda; kozmetik; pet; kimyasal | HIGH | su; yulaf | INCI/etiket sırası korunabilir. |
| FACET-D-011 | Alerjen | Allergen | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | gıda; kozmetik; pet | HIGH | süt; fındık | Yokluk claim'i evidence ister. |
| FACET-D-012 | Beslenme özelliği | Dietary property | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | gıda; pet | HIGH | vegan; glutensiz | Sertifika/claim ayrı policy facet'i. |
| FACET-D-013 | Cilt tipi | Skin type | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | kozmetik; kişisel bakım | HIGH | kuru; hassas | Medical condition değildir. |
| FACET-D-014 | Saç tipi | Hair type | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | saç bakımı; elektrikli bakım | HIGH | kıvırcık; boyalı | Concern ayrı claim olabilir. |
| FACET-D-015 | Ton ve bitiş | Shade and finish | STRUCTURED | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | makyaj; boya; dekor | MEDIUM | mat; sıcak bej | Renk ailesinden ayrıdır. |
| FACET-D-016 | Koku ailesi | Fragrance family | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | parfüm; bakım; ev | MEDIUM | odunsu; narenciye | Nota serbest metin olmamalı. |
| FACET-D-017 | Nominal güç | Rated power | DECIMAL | MEASURED | W/kW | NO | YES | YES | YES | DOMAIN_SHARED | elektronik; cihaz; alet; müzik | HIGH | 65 W | Güç category değildir. |
| FACET-D-018 | Gerilim | Voltage | RANGE | MEASURED | V | YES | YES | YES | YES | DOMAIN_SHARED | elektrikli ürünler | HIGH | 220–240 V | AC/DC niteliği gerekir. |
| FACET-D-019 | Akım | Current | RANGE | MEASURED | A/mA | YES | YES | YES | YES | DOMAIN_SHARED | elektronik; yapı; araç | MEDIUM | 3 A | Giriş/çıkış rolü tutulur. |
| FACET-D-020 | Batarya kapasitesi | Battery capacity | DECIMAL | MEASURED | mAh/Wh | NO | YES | YES | YES | DOMAIN_SHARED | elektronik; alet; araç | HIGH | 10.000 mAh | Kimya ve voltage ayrı alanlardır. |
| FACET-D-021 | Konnektör tipi | Connector type | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | elektronik; bilgisayar; müzik; araç | HIGH | USB-C; XLR | Category/compatibility ile karışabilir. |
| FACET-D-022 | Kablosuz protokol | Wireless protocol | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | elektronik; bilgisayar; ev cihazı | HIGH | Wi‑Fi 6; Bluetooth | Version separate value olabilir. |
| FACET-D-023 | Ekran boyutu | Screen size | DECIMAL | MEASURED | inç | NO | YES | YES | YES | DOMAIN_SHARED | elektronik; bilgisayar; optik cihaz | HIGH | 15,6 inç | Fiziksel gövde ölçüsü değildir. |
| FACET-D-024 | Çözünürlük | Resolution | STRUCTURED | MEASURED | px/dpi | YES | YES | YES | YES | DOMAIN_SHARED | ekran; kamera; yazıcı | MEDIUM | 1920×1080 px | Ölçüm bağlamı zorunlu. |
| FACET-D-025 | Depolama kapasitesi | Storage capacity | DECIMAL | MEASURED | GB/TB | YES | YES | YES | YES | DOMAIN_SHARED | elektronik; bilgisayar | HIGH | 512 GB | Marketing decimal/binary farkı not edilir. |
| FACET-D-026 | Bellek kapasitesi | Memory capacity | DECIMAL | MEASURED | GB | YES | YES | YES | YES | DOMAIN_SHARED | elektronik; bilgisayar | HIGH | 16 GB RAM | Storage ile birleşmez. |
| FACET-D-027 | İşletim sistemi | Operating system | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | telefon; bilgisayar; akıllı cihaz | HIGH | Android; Linux | Sürüm ayrı normalized değer olabilir. |
| FACET-D-028 | Hedef tür | Intended species | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | evcil hayvan; bahçe riskleri | HIGH | kedi; köpek | Pet L2 navigation'ını değiştirmez. |
| FACET-D-029 | Vücut bölgesi | Body area | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | sağlık; bakım; koruyucu ürün | HIGH | diz; yüz; saç | Hastalık/tedavi claim'i değildir. |
| FACET-D-030 | Değerli materyal | Precious material | ENUM | CONTROLLED | — | YES | YES | YES | NO | DOMAIN_SHARED | saat & takı; enstrüman | HIGH | altın; gümüş; fildişi iddiası | Provenance/policy ayrıca gerekir. |
| FACET-L-001 | İşlemci ailesi | CPU family | TEXT | CONTROLLED | — | NO | YES | YES | YES | LEAF_SPECIFIC | elektronik; bilgisayar | HIGH | mobil/masaüstü CPU ailesi | Marka bağımlı node üretmez. |
| FACET-L-002 | Grafik işlemci ailesi | GPU family | TEXT | CONTROLLED | — | NO | YES | YES | YES | LEAF_SPECIFIC | bilgisayar | HIGH | ayrık GPU ailesi | Model reference olabilir. |
| FACET-L-003 | İşlemci soketi | CPU socket | ENUM | CONTROLLED | — | NO | YES | YES | NO | LEAF_SPECIFIC | bilgisayar bileşenleri | HIGH | AM5; LGA1700 | Uyumluluk girdisidir. |
| FACET-L-004 | Bellek standardı | Memory standard | ENUM | CONTROLLED | — | YES | YES | YES | NO | LEAF_SPECIFIC | bilgisayar bileşenleri | HIGH | DDR5; SO-DIMM | Hız ayrı numeric facet olabilir. |
| FACET-L-005 | Yenileme hızı | Refresh rate | DECIMAL | MEASURED | Hz | YES | YES | YES | YES | LEAF_SPECIFIC | ekran; monitör | MEDIUM | 144 Hz | Gaming category değildir. |
| FACET-L-006 | Baskı teknolojisi | Print technology | ENUM | CONTROLLED | — | NO | YES | YES | NO | LEAF_SPECIFIC | yazıcı | MEDIUM | lazer; mürekkep püskürtmeli | Device type ile karışmaz. |
| FACET-L-007 | Sarf verimi | Consumable yield | INTEGER | MEASURED | sayfa | NO | YES | YES | YES | LEAF_SPECIFIC | yazıcı sarfı | LOW | 1.500 sayfa | Standard test condition gerekir. |
| FACET-L-008 | Lens yuvası | Lens mount | ENUM | CONTROLLED | — | YES | YES | YES | NO | LEAF_SPECIFIC | fotoğraf & kamera | HIGH | mirrorless mount ailesi | Compatibility girdisidir. |
| FACET-L-009 | Odak uzaklığı | Focal length | RANGE | MEASURED | mm | NO | YES | YES | YES | LEAF_SPECIFIC | fotoğraf & kamera | LOW | 24–70 mm | Lens mount'tan ayrıdır. |
| FACET-L-010 | Lastik ebadı | Tire size | STRUCTURED | CONTROLLED | standard | NO | YES | YES | YES | LEAF_SPECIFIC | otomotiv & motosiklet | HIGH | 205/55 R16 | Tek string değil bileşenlidir. |
| FACET-L-011 | Yağ viskozitesi | Oil viscosity | ENUM | CONTROLLED | SAE | NO | YES | YES | YES | LEAF_SPECIFIC | otomotiv & motosiklet | MEDIUM | 5W-30 | Onay standardı ayrıca tutulur. |
| FACET-L-012 | Ayakkabı numara sistemi | Shoe size system | STRUCTURED | CONTROLLED | EU/UK/US | YES | YES | YES | YES | LEAF_SPECIFIC | ayakkabı | HIGH | EU 42 | Display conversion explicit olmalı. |
| FACET-L-013 | Yüzük ölçü sistemi | Ring size system | STRUCTURED | CONTROLLED | TR/EU/US/mm | YES | YES | YES | YES | LEAF_SPECIFIC | saat & takı | HIGH | TR 14 | İç çap/çevreyle karışmaz. |
| FACET-L-014 | Basım dili | Publication language | ENUM | CONTROLLED | BCP 47 | YES | YES | YES | NO | LEAF_SPECIFIC | kitap | HIGH | tr; en | Kitap category'si değildir. |
| FACET-L-015 | Yazar / yayınevi | Author and publisher | STRUCTURED | REFERENCE | — | YES | YES | YES | YES | LEAF_SPECIFIC | kitap | MEDIUM | yazar; yayınevi | Ayrı rolleri korunur. |
| FACET-L-016 | Enstrüman türü | Instrument type | ENUM | CONTROLLED | — | NO | YES | YES | NO | LEAF_SPECIFIC | müzik & enstrüman | HIGH | akustik gitar; klarnet | L3 adayıyla review gerekebilir. |
| FACET-C-001 | Uyumlu cihaz ailesi | Compatible device family | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | elektronik; bilgisayar; cihaz | HIGH | telefon; kamera | Tek başına `compatible` üretmez. |
| FACET-C-002 | Uyumlu model | Compatible model | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | aksesuar/sarf/yedek parça | HIGH | model ailesi | Versioned model registry gerekir. |
| FACET-C-003 | Araç uyumu | Vehicle fitment | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | otomotiv & motosiklet | HIGH | kasa/motor/yıl aralığı | Yapılandırılmış ilişki olmalı. |
| FACET-C-004 | Arayüz standardı | Interface standard | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | bilgisayar; elektronik; müzik | HIGH | PCIe; HDMI | Konnektör formundan ayrıdır. |
| FACET-C-005 | Aksesuar ekosistemi | Accessory system | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | elektronik; cihaz; bebek | HIGH | montaj rayı; ekosistem | Marka synonym'i değildir. |
| FACET-C-006 | Batarya platformu | Battery platform | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | yapı aletleri; bahçe | HIGH | 18 V platform ailesi | Voltage tek başına uyum değildir. |
| FACET-C-007 | Yazıcı sarf uyumu | Printer consumable fit | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | bilgisayar & tablet | HIGH | kartuş ↔ yazıcı modeli | Yield ayrı facet'tir. |
| FACET-C-008 | Ev aleti aksesuar uyumu | Appliance accessory fit | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | beyaz eşya & ev aletleri | HIGH | filtre ↔ cihaz modeli | Universal claim doğrulanır. |
| FACET-C-009 | Montaj standardı | Mounting standard | RELATION | REFERENCE | — | YES | YES | YES | NO | COMPATIBILITY | TV; monitör; yapı; araç | HIGH | VESA; ray ölçüsü | Fiziksel dimensions da gerekir. |
| FACET-C-010 | Uyumluluk sonucu | Compatibility state | ENUM | DERIVED | — | NO | YES | YES | NO | COMPATIBILITY | compatibility kullanan tüm alanlar | LOW | compatible; conditional | Yalnız rule engine sonucu; merchant yazamaz. |
| FACET-P-001 | Sertifika / uygunluk kanıtı | Certification evidence | STRUCTURED | REFERENCE | — | YES | YES | YES | NO | POLICY_METADATA | regüle/güvenlik ürünleri | HIGH | standart; issuer; expiry | Category listing izni vermez. |
| FACET-P-002 | Güvenlik sınıfı | Safety class | ENUM | CONTROLLED | — | YES | YES | YES | NO | POLICY_METADATA | oyuncak; PPE; cihaz; yapı | HIGH | koruma sınıfı | Evidence ile bağlanır. |
| FACET-P-003 | Tehlike sınıflandırması | Hazard classification | STRUCTURED | CONTROLLED | — | YES | NO | YES | NO | POLICY_METADATA | kimyasal; batarya; basınçlı ürün | HIGH | yanıcı; aşındırıcı | Search boost amacıyla kullanılmaz. |
| FACET-P-004 | Tıbbi kullanım amacı | Medical intended use | TEXT | CONTROLLED | — | YES | NO | YES | NO | POLICY_METADATA | sağlık; optik; claim riski | HIGH | ölçüm; destek | Serbest merchant claim'i değildir. |
| FACET-P-005 | Tıbbi cihaz sınıfı | Medical device class | ENUM | CONTROLLED | — | NO | YES | YES | NO | POLICY_METADATA | sağlık & medikal; optik | HIGH | applicable sınıf | Yetkili kanıt gerekir. |
| FACET-P-006 | Satıcı yetki durumu | Seller authorization | ENUM | DERIVED | — | NO | NO | YES | NO | POLICY_METADATA | regüle domainler | LOW | verified; required; denied | Ürün facet'i değil listing gate'idir. |
| FACET-P-007 | Yaş kısıtı | Age restriction | STRUCTURED | CONTROLLED | yıl | NO | NO | YES | NO | POLICY_METADATA | kesici; kimyasal; riskli ürün | HIGH | 18+; yetişkin gözetimi | Hedef yaş facet'inden ayrıdır. |
| FACET-P-008 | İddia kanıt durumu | Claim evidence state | ENUM | DERIVED | — | NO | NO | YES | NO | POLICY_METADATA | claim taşıyan tüm alanlar | LOW | verified; pending; rejected | Claim metniyle aynı değildir. |
| FACET-P-009 | İzlenebilirlik kimliği | Traceability identifier | IDENTIFIER | REFERENCE | — | YES | NO | YES | NO | POLICY_METADATA | gıda; medikal; canlı; değerli ürün | LOW | lot; UDI; seri | Hassas veri olmamalı. |
| FACET-P-010 | Kurulum gereksinimi | Installation requirement | ENUM | CONTROLLED | — | NO | YES | YES | NO | POLICY_METADATA | yapı; beyaz eşya; elektrik | HIGH | kullanıcı; uzman; yetkili servis | Hizmet category'si değildir. |
| FACET-R-001 | Normalize renk ailesi | Normalized color family | ENUM | DERIVED | — | YES | YES | YES | YES | DERIVED | ALL | LOW | siyah | Vendor shade'den türetilir. |
| FACET-R-002 | Normalize beden bandı | Normalized size band | ENUM | DERIVED | — | YES | YES | YES | YES | DERIVED | giyim; ayakkabı; bebek | LOW | küçük; orta; büyük | Orijinal beden kaybolmaz. |
| FACET-R-003 | Uyumluluk güven düzeyi | Compatibility confidence | ENUM | DERIVED | — | NO | NO | YES | NO | DERIVED | compatibility kullanan alanlar | LOW | verified; inferred; unknown | Sonuç state'inden ayrıdır. |
| FACET-R-004 | Normalize ölçü gösterimi | Normalized unit display | TEXT | DERIVED | locale | NO | NO | YES | YES | DERIVED | ölçülü tüm facet'ler | LOW | 1,5 L | Raw numeric değeri değiştirmez. |

## Registry counts and guardrails

| Scope | Count |
|---|---:|
| `GLOBAL_SHARED` | 18 |
| `DOMAIN_SHARED` | 30 |
| `LEAF_SPECIFIC` | 16 |
| `COMPATIBILITY` | 10 |
| `POLICY_METADATA` | 10 |
| `DERIVED` | 4 |
| **Total concept facets** | **88** |

- A scope label is reuse guidance, not automatic applicability.
- Display label aliases never create a second concept ID.
- `POLICY_METADATA` is never a listing permission by itself.
- `DERIVED` values are never merchant-editable source facts.
- Open questions remain owner/policy review items; this registry finalizes none.

`GLOBAL_FACET_REGISTRY_STATE: PROVISIONAL_FOR_OWNER_REVIEW`

`FACET_CONCEPT_COUNT: 88`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
