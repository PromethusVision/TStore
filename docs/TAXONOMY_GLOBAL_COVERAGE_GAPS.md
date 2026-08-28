# Global Taxonomy Coverage Gap Audit

## Status and method

**AUDIT FINDINGS — NO OWNER FINALIZATION / NO PROPOSAL REWRITE**

This audit records physical local-retail product families that have no natural L1, have an L1 but no sensible proposed L2, or can only be placed by distorting a neighboring node. It also records non-product and policy-gated offers that should not be “fixed” by inventing a product category. Suggested actions are candidates for owner review only.

## Gap register

| Gap ID | Product family | Possible L1 | Why current tree fails | Suggested action | Owner decision required | Severity | Evidence |
|---|---|---|---|---|---|---|---|
| GAP-001 | İnsan gıda takviyeleri (vitamin, mineral, kapsül) | Sağlık & Medikal / Gıda & İçecek | Sağlık L2'leri cihaz, destek ve sarfa odaklı; Gıda L2'lerinde takviye evi yok. “İlaç” veya “atıştırmalık” olarak zorlamak yanlış. | NEW_L2_CANDIDATE + POLICY_EXCLUSION sınırı | YES | HIGH | EDGE-0005 |
| GAP-002 | Sporcu beslenmesi ve protein tozları | Gıda & İçecek / Spor & Outdoor / Sağlık & Medikal | Ürün yenilebilir ancak mevcut gıda L2'leri doğal arama niyetini karşılamıyor; spor kullanım amacı tek başına kategori olmamalı. | NEW_L2_CANDIDATE veya owner-approved nutrition grouping | YES | HIGH | EDGE-0004 |
| GAP-003 | Medikal amaçlı oral/enteral beslenme ürünleri | Sağlık & Medikal | Medikal sarf L2'si uygulama setini alır, tüketilen formülü değil. Generic içecek sınıflaması intended use'u kaybeder. | NEW_L2_CANDIDATE + POLICY_EXCLUSION | YES | HIGH | EDGE-0006, EDGE-0012 |
| GAP-004 | Bitmiş numarasız bilgisayar/mavi ışık gözlükleri | Gözlük & Optik | “Optik Gözlük Çerçeveleri” yalnız çerçeve sinyali verir; bitmiş fakat reçetesiz gözlük doğal leaf bulamıyor. | FUTURE_L3 veya L2 scope clarification | YES | MEDIUM | EDGE-0116 |
| GAP-005 | Kişiselleştirilmiş basılı fotoğraf kitapları/albümler | Kitap / Kırtasiye & Ofis / Hediyelik & Parti | Yayın kitabı, boş albüm ve siparişe göre üretilen basılı obje ayrımı mevcut L2'lerde açık değil. | FUTURE_L3 veya NO_CHANGE + fulfillment rule | YES | MEDIUM | EDGE-0155 |
| GAP-006 | Generic spor çantası ile teknik spor taşıma ekipmanı | Çanta & Aksesuar / Spor & Outdoor | Generic spor salonu çantası için “Valiz & Seyahat Çantaları” zorlanıyor; teknik dağcılık çantası ise domain safety özellikleri taşıyor. | FUTURE_L3 + generic/domain-specific accessory root rule | YES | HIGH | EDGE-0040, EDGE-0041 |
| GAP-007 | Bebek bakım çantaları | Anne & Bebek / Çanta & Aksesuar | Bebek-özel organizer ile generic çanta formu arasında owner-final primary kural yok. | FUTURE_L3 + root boundary decision | YES | HIGH | EDGE-0037 |
| GAP-008 | Profesyonel ekipman taşıma kutuları | Çanta & Aksesuar / Müzik / Fotoğraf & Kamera / Bilgisayar | Tek bir “equipment bag” kuralı yok; gitar ve kamera kutusu domain aksesuarı iken laptop çantası Çanta önerisinde. | NO_CHANGE + root rule, sonra ilgili FUTURE_L3 | YES | HIGH | EDGE-0038, EDGE-0039, EDGE-0042, EDGE-0044 |
| GAP-009 | Tüketici güvenlik/takip cihazları | Elektronik | Akıllı Ev & Güvenlik node'u taşınabilir nesne/pet/araç takip cihazlarını ancak zorlayarak alıyor. | FUTURE_L3 veya NEW_L2_CANDIDATE | YES | MEDIUM | EDGE-0084 |
| GAP-010 | Generic araç soketi güç adaptörleri | Elektronik / Otomotiv & Motosiklet | Çakmak soketi araç fitment mı, yalnız giriş tipi mi belirsiz; generic USB power owner rule'u ile çakışıyor. | NO_CHANGE + fitment root decision | YES | HIGH | EDGE-0076 |
| GAP-011 | USB ölçüm/test cihazları | Yapı, Hırdavat & Tesisat / Elektronik | Bağlantı standardı ürünü Elektronik'e çekerken primary function ölçümdür; test ekipmanının kapsamı consumer dilinde net değil. | NO_CHANGE + primary-function rule | YES | MEDIUM | EDGE-0066 |
| GAP-012 | Pro-audio ile consumer audio arasındaki sınır | Müzik & Enstrüman / Elektronik | Stüdyo monitörü, podcast mikrofonu ve PA hoparlörü aynı fiziksel formun consumer sürümleriyle yarışıyor. | FUTURE_L3 + professional-intended-use root rule | YES | HIGH | EDGE-0097, EDGE-0101, EDGE-0106 |
| GAP-013 | PC-first mikrofon ve kamera-first kablosuz mikrofon | Bilgisayar & Tablet / Fotoğraf & Kamera / Müzik & Enstrüman | “Bilgisayar Aksesuarları”, recording gear ve camera accessory arasında capture workflow rule'u yok. | NO_CHANGE + primary-workflow root rule | YES | HIGH | EDGE-0102, EDGE-0103 |
| GAP-014 | Toy-grade elektronik ile gerçek işlevsel cihaz sınırı | Oyuncak & Hobi / Elektronik / Müzik | Oyuncak drone, klavye ve robotik setlerde yaş etiketi tek başına ürün yeteneğini anlatmıyor. | NO_CHANGE + toy-grade capability rule | YES | HIGH | EDGE-0085, EDGE-0091, EDGE-0093 |
| GAP-015 | Bitmiş tarım/bahçe ölçüm cihazı ile maker sensörü | Çiçek & Bahçe / Elektronik | Sera sensörü complete instrument olduğunda “Sera Ekipmanı”; çıplak modül olduğunda “Elektronik Bileşenler”. Sınır açık yazılmamış. | FUTURE_L3 + finished-product/component rule | YES | MEDIUM | EDGE-0149 |
| GAP-016 | Elektrikli bahçe makineleri | Çiçek & Bahçe / Yapı, Hırdavat & Tesisat | “Bahçe El Aletleri” adı elektrikli çit budama makinesini doğal karşılamıyor; generic power-tool L2 ile yarışıyor. | L2 scope clarification veya NEW_L2_CANDIDATE | YES | HIGH | EDGE-0143 |
| GAP-017 | Multi-product hediye setleri | Ürünü oluşturan birden fazla L1 | Tek ürün için primary leaf ilkesi, kolye+küpeler veya yüzük+çiçek line-item bundle'ında hangi düzeyde uygulanacağı tanımlanmadan çalışmıyor. | NO_CHANGE + bundle/line-item root rule | YES | HIGH | EDGE-0151, EDGE-0157 |
| GAP-018 | Fiziksel SIM başlangıç kitleri | Elektronik / Telefon & Aksesuarları | Owner-final karar Product Taxonomy V1'den dışlar; operatör aktivasyon/policy alanı hazır değil. | POLICY_EXCLUSION | YES | HIGH | Owner-final phone boundary |
| GAP-019 | İkinci el/yenilenmiş ürünler | Mevcut fiziksel ürün owner'ı | Ayrı kategori açmak duplication yaratır; condition, garanti ve disclosure sözleşmesi henüz runtime değil. | FACET_ONLY + policy metadata | YES | MEDIUM | EDGE-0168 |
| GAP-020 | İlaç ruhsatlı insan/veteriner ürünleri | Policy-gated | Kategorik yakınlık satış yetkisi değildir; mevcut product proposal'ları ruhsatlı ilaç satışı için onay değildir. | POLICY_EXCLUSION | YES | CRITICAL | EDGE-0016, EDGE-0135 |
| GAP-021 | Pestisit, piroteknik, silah/mühimmat | Policy-gated | Local retailde fiziksel olabilirler ancak legal/safety gate olmadan taxonomy home üretmek yanlış kabul sinyali verir. | POLICY_EXCLUSION | YES | CRITICAL | EDGE-0144, EDGE-0166, EDGE-0167 |
| GAP-022 | Onarım, bakım, montaj ve eğitim emeği | Future service taxonomy | Telefon ekran değişimi, kombi bakımı, cam montajı ve müzik dersi fiziksel product node'larına sızar. | SERVICE_TAXONOMY | YES | HIGH | EDGE-0162–EDGE-0165 |
| GAP-023 | Dijital lisans ve indirilebilir içerik | Future digital-goods scope | Current mission physical local retail; indirilebilir e-kitap fiziksel Kitap L2'sine konursa fulfillment/policy bozulur. | POLICY_EXCLUSION veya future digital taxonomy | YES | HIGH | EDGE-0169 |
| GAP-024 | Hediye çeki / stored-value ürünleri | Financial/policy scope | Fiziksel kart formu onu Kırtasiye veya Hediyelik ürünü yapmaz; finansal değer ve kullanım koşulları baskındır. | POLICY_EXCLUSION | YES | CRITICAL | EDGE-0161 |

## Gap totals

| Suggested action family | Gap count |
|---|---:|
| NEW_L2_CANDIDATE (alone or paired with policy) | 6 |
| FUTURE_L3 / FUTURE_L4 or scope clarification | 8 |
| FACET_ONLY / NO_CHANGE root rule | 6 |
| POLICY_EXCLUSION | 8 |
| SERVICE_TAXONOMY | 1 |

Counts overlap because one gap may need both a structural candidate and a policy gate.

## Highest-impact findings

1. Supplements, sports nutrition and medical nutrition need one coordinated P0 decision; three independent category additions would create duplication.
2. Generic-versus-domain-specific accessory rules are more valuable than adding parallel bag, charger, sensor and microphone nodes.
3. Regulated, dangerous, financial, digital and service offers must fail closed. A missing product node is safer than silently treating policy eligibility as taxonomy placement.
4. Bundle taxonomy should operate on physical line items; gift intent should remain a collection/occasion signal.

## Validation

- Real physical-retail gaps distinguished from service/policy exclusions: PASS.
- Edge evidence references: present.
- Proposal documents modified: NO.
- New canonical categories finalized: NO.
- Runtime implementation: NO.

`GLOBAL_COVERAGE_GAP_AUDIT: PASS`

`OWNER_FINALIZATION: NOT_PERFORMED`
