# EsnaftaVar — Sağlık & Medikal L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Sağlık & Medikal — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Bu high-policy-risk belge yalnız L2 bilgi mimarisi önerir. Hiçbir ürünün satışa
uygun olduğunu ilan etmez; ilaç/takviye eklemez, L3/L4, stable ID, runtime taxonomy,
merchant authorization veya remote değişiklik üretmez.

## 2. Scope

Kapsam; ilk yardım/yara bakımı, evde sağlık ölçüm cihazı, ortopedik destek,
mobilite yardımı, rehabilitasyon/fizik tedavi ürünü, solunum/evde bakım cihazı,
medikal sarf/hasta bakımı, kişisel koruyucu medikal ürün ve günlük yaşam yardımcı
ürünüdür.

Bu domain'de kategoriye dahil olmak satışa uygunluk anlamına gelmez. Exact SKU'nun
tıbbi cihaz sınıfı, ÜTS/registration, satıcı yetkisi, reklam/sağlık beyanı, reçete,
saklama ve fulfilment koşulları ayrı fail-closed policy katmanında doğrulanmalıdır.

İlaçlar, supplement/takviyeler, kozmetik ve sağlık hizmetleri bu L2 omurgasına
sessizce eklenmez.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Medical equipment, monitoring, mobility/accessibility, respiratory, first aid ve protective supplies farklı product families olarak ayrılır; tek en uygun kategori istenir. | Functional schema families ve one-primary-leaf ilkesi alındı. Public dosya header'ı `2021-09-21`; Türkiye regulation kaynağı değildir. |
| [Trendyol Medikal Ekipman 2026](https://www.trendyol.com/medikal-ekipman-x-c144917) | Ortopedik destek, tabanlık, atel ve ev tipi tansiyon/ateş ölçümü gibi ürünler aynı müşteri alanında görünürdür. | Home-use product breadth doğrulandı; pazar listing'i legal eligibility kanıtı sayılmadı. |
| [n11 Sağlık & Medikal araması](https://www.n11.com/saglik-ve-medikal-urunler?q=steteskoplu+tansiyon+alet) | Ölçüm cihazı, ilk yardım/medikal, tansiyon cihazı, manşet ve profesyonel araçlar yan yana görünür. | Measurement/accessory schema ayrımı desteklendi; profesyonel ürünler normal consumer L2'ye otomatik açılmadı. |
| [Amazon Türkiye Tansiyon Ölçüm Cihazları](https://www.amazon.com.tr/b?node=13526300031) | Sağlık & Kişisel Bakım > Tıbbi Malzeme ve Ekipman > Teşhis/Ölçüm yapısı; device/accessory ürünleri bulunur. | Evde ölçüm major department'ı desteklenir; Amazon tree kopyalanmadı. |
| [Sağlık Bakanlığı — Tıbbi Cihaz Satış, Reklam ve Tanıtım Yönetmeliği](https://erisilebilir.saglik.gov.tr/TR-8070/tibbi-cihaz-satis-reklam-ve-tanitim-yonetmeligi.html) ve [Tıbbi Cihaz Satış Merkezleri görevleri](https://istanbulism.saglik.gov.tr/TR-157488/tibbi-cihaz-satis-merkezleri-biriminin-gorev-islemleri.html) | Satış merkezi yetkilendirmesi, reklam/tanıtım ve denetim süreçleri vardır. | Merchant/product eligibility taxonomy'den ayrıldı; bu belge hukuki uygunluk vermez. |
| [3359 sayılı Sağlık Hizmetleri Temel Kanunu](https://mackaftr.saglik.gov.tr/TR-709054/3359-sayili-saglik-hizmetleri-temel-kanunu.html) | 2025 ek hükümlerinde sahte tıbbi cihaz ve izin verilen yer/usul dışında satış, reklam, dağıtım/pazarlamaya yaptırım düzenlenmiştir. | Sahte/izinsiz cihaz için fail-closed policy ve doğrulama gereğini güçlendirir. |
| [Sağlık Bakanlığı — Tıbbi Cihaz tanımları/temini](https://khgm.saglik.gov.tr/TR-119761/tibbi-cihaz.html) | Tıbbi cihaz, sarf, ortez/protez ve reçete edilen görmeye yardımcı ürünler ayrıştırılır. | Ortez/protez, prescription optics ve general health product boundaries için authoritative context sağlar. |

**Source limitation:** Hepsiburada'nın güncel tam public health tree'si alınamadı.
Marketplace bulunabilirliği mevzuata uygun satış kanıtı olarak kullanılmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **9**.

Bu yapı ev kullanımındaki anlamlı fonksiyon/schema ailelerini ayırır; hastalık,
tedavi iddiası, marka, profesyonel uzmanlık veya cihaz risk sınıfını kategori yapmaz.

## 5. Exact L2 list

1. İlk Yardım & Yara Bakımı
2. Evde Sağlık Ölçüm Cihazları
3. Ortopedik Destekler & Kompresyon
4. Hareket & Mobilite Yardımcıları
5. Rehabilitasyon & Fizik Tedavi Ürünleri
6. Solunum & Evde Bakım Cihazları
7. Medikal Sarf & Hasta Bakım Ürünleri
8. Kişisel Koruyucu Medikal Ürünler
9. Günlük Yaşam & Erişilebilirlik Yardımcıları

Normalized duplicate: **0**. Hastalık-as-category: **0**. İlaç/supplement L2:
**0**.

## 6. Granularity rationale

- İlk yardım/yara bakımı hızlı müdahale ve dressing schema'sı taşır; reçeteli ilaç
  değildir.
- Evde ölçüm cihazları ölçüm türü, doğruluk, manşet/sensör ve kayıt gibi ortak
  attribute'lara sahiptir.
- Ortopedik destek/kompresyon vücut bölgesi, beden, destek derecesi ve medical claim
  açısından mobilite aracından ayrıdır.
- Tekerlekli sandalye, yürüteç, baston ve koltuk değneği movement/weight/load schema
  ailesidir.
- Rehabilitasyon/fizik tedavi ürünleri egzersiz/terapi işlevlidir; cihaz claimi ve
  profesyonel gözetim ayrıca policy'dir.
- Solunum/evde bakım cihazları nebulizer, suction, oxygen/airway ve sleep-respiratory
  sistemlerin teknik/consumable compatibility'sini toplar.
- Medikal sarf/hasta bakım, disposable/non-device bakım ürünlerini; PPE ise temas/
  koruma standardı ve kullanım rolünü ayrı taşır.
- Günlük yaşam/erişilebilirlik yardımları; reacher, transfer, banyo/tuvalet ve günlük
  aktivite ürünleridir, mobilya/dekor değildir.

## 7. Inclusions

| L2 | Dahil olan ana ürünler — exact eligibility saklıdır |
|---|---|
| İlk Yardım & Yara Bakımı | İlk yardım çantası, steril gaz/kompres, bandaj, flaster, yara örtüsü, antiseptic olmayan fiziksel bakım aksesuarı |
| Evde Sağlık Ölçüm Cihazları | Tansiyon aleti, ateş ölçer, pulse oximeter, glukometre, sağlık tipi baskül ve device-specific manşet/strip/sensör |
| Ortopedik Destekler & Kompresyon | Dizlik, bileklik, korse, atel, ortopedik tabanlık, boyunluk ve kompresyon çorabı |
| Hareket & Mobilite Yardımcıları | Tekerlekli sandalye, yürüteç, rollator, baston, koltuk değneği ve mobilite aksesuarı |
| Rehabilitasyon & Fizik Tedavi Ürünleri | TENS/EMS cihazı, terapi bandı/topu, el egzersiz ürünü, fizik tedavi yardımcı ekipmanı |
| Solunum & Evde Bakım Cihazları | Nebulizer, aspiratör, oxygen concentrator/aksesuarı, CPAP/BPAP cihaz/maske ve home-care monitoring support |
| Medikal Sarf & Hasta Bakım Ürünleri | Enjektör/kanül gibi eligibility-gated sarf, hasta alt bezi/örtü, idrar/ostomi bakım sarfı, muayene sarfı ve bakım seti |
| Kişisel Koruyucu Medikal Ürünler | Medical mask/respirator, muayene eldiveni, koruyucu önlük, bone, galoş ve yüz siperi |
| Günlük Yaşam & Erişilebilirlik Yardımcıları | Tutunma/transfer yardımcısı, tuvalet yükseltici, banyo oturağı, kavrama/uzanma aracı, yeme-içme ve giyinme yardımcısı |

## 8. Exclusions

- Reçeteli, reçetesiz, kontrollü veya kısıtlı insan ilacı; aşı, hormon, tıbbi gaz:
  normal Product Taxonomy'de **EXCLUDED / regulated pharmacy channel**.
- Vitamin, mineral, bitkisel ürün, spor supplementi ve gıda takviyesi: bu proposal'da
  L2 yok; **LEGAL_REVIEW_REQUIRED / separate owner policy decision**.
- Kozmetik, kişisel bakım, skincare, saç bakım ve parfüm: **Kozmetik & Kişisel
  Bakım**. Sağlık claimi L1'i değiştirmez.
- Cinsel uyarım/adult stimulation ürünleri: bu proposal'a **dahil değildir**;
  owner/legal policy olmadan eklenmez.
- Sağlık hizmeti, doktor/terapist randevusu, laboratuvar testi hizmeti, bakım,
  kiralama, montaj ve abonelik: **service scope — excluded**.
- MRI, ultrasound, x-ray, surgical workstation, operating-room system ve ağır
  professional hospital equipment: consumer L2'ye sessizce alınmaz;
  **LEGAL_REVIEW_REQUIRED / B2B scope**.
- Optik çerçeve, gözlük camı, kontakt lens: **Gözlük & Optik** ownership + policy.
- Spor performans bandı/fitness ürünü tıbbi claim/intent yoksa **Spor & Outdoor**.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Kozmetik & Kişisel Bakım | Beauty/grooming primary ürün orada; tıbbi cihaz/sarf/support primary burada. Marketing claim tek başına ownership değiştirmez. |
| Gözlük & Optik | Görme düzeltme/eyewear family orada; diğer medikal cihaz ve bakım burada. Prescription status ayrı policy'dir. |
| Spor & Outdoor | Fitness/performance/recreation primary ise Spor; rehabilitation/orthopedic medical support primary ise burada. |
| Ev & Yaşam | Genel mobilya, yastık, banyo ürünü orada; erişilebilirlik/transfer/hasta bakım primary ve medical schema varsa burada. |
| Elektronik | Wellness smartwatch/consumer wearable Elektronik; dedicated medical measurement device burada. App connectivity category değiştirmez. |
| Anne & Bebek | Bebek bakım ürünü orada; neonatal/professional medical device burada ve legal review. |
| Otomotiv | Araç için mevzuat seti olarak paketlenmiş ilk yardım kiti Otomotiv; generic/home first-aid kit burada. |
| Evcil Hayvan | İnsan ürünü burada; veterinary medicine normal consumer taxonomy'de excluded, pet bakım ürünleri Evcil Hayvan. |

## 10. Category vs facet

Aşağıdakiler category değil facet/policy metadata'dır:

- marka, model, MPN/UDI/registration ve manufacturer;
- intended use, home/professional use, reusable/single-use ve sterile status;
- tıbbi cihaz risk/classification, conformity evidence ve seller authorization;
- ölçüm türü/aralığı/doğruluğu, kullanıcı sayısı, memory/connectivity;
- vücut bölgesi, sağ/sol, beden, destek/kompresyon derecesi;
- load capacity, kullanıcı boy/kilo aralığı, foldability ve drive/manual type;
- material, latex-free, sterile/non-sterile, package count;
- device-consumable compatibility ve compatible/incompatible/conditional/unknown;
- medical/therapeutic claim ve prescription requirement;
- bundle/kit. İlk yardım seti içerik facet'i taşır; set yeni category değildir.

Hastalık adı category yerine intended-use/claim metadata'sı olabilir; sağlık beyanı
kanıtlanmadan search boost veya eligibility üretmez.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| İlk Yardım & Yara Bakımı | ilk yardım, pansuman, yara bakım, bandaj, gazlı bez |
| Evde Sağlık Ölçüm Cihazları | tansiyon aleti, ateş ölçer, oksimetre, şeker ölçüm, sağlık monitörü |
| Ortopedik Destekler & Kompresyon | dizlik, bileklik, korse, atel, ortopedik, varis/kompresyon çorabı |
| Hareket & Mobilite Yardımcıları | tekerlekli sandalye, yürüteç, rollator, baston, koltuk değneği |
| Rehabilitasyon & Fizik Tedavi Ürünleri | fizik tedavi, rehabilitasyon, TENS, EMS, terapi bandı |
| Solunum & Evde Bakım Cihazları | nebulizatör, aspiratör, oksijen cihazı, CPAP, solunum cihazı |
| Medikal Sarf & Hasta Bakım Ürünleri | medikal sarf, hasta bakım, bakım örtüsü, ostomi, disposable medical |
| Kişisel Koruyucu Medikal Ürünler | medikal maske, respiratör, muayene eldiveni, önlük, yüz siperi |
| Günlük Yaşam & Erişilebilirlik Yardımcıları | erişilebilirlik, banyo oturağı, tuvalet yükseltici, transfer, uzanma aparatı |

`Masaj aleti` ve `fitness bandı` çok anlamlıdır; medical intended use/evidence yoksa
Kozmetik/Elektronik/Spor alanında kalır.

## 12. Policy/compliance

- Bu L1'de varsayılan launch posture **fail-closed** olmalıdır. Exact SKU ve merchant
  doğrulanmadan kategori assignment satışa açılmaz.
- Prescription/restricted medicines: **EXCLUDED**. İlaç internet/kanal kuralları
  ayrı yasal rejimdir; normal marketplace ürün dalı oluşturulmaz.
- Supplement/takviye: **LEGAL_REVIEW_REQUIRED**, ayrı owner kararına kadar L2 yok.
- Tıbbi cihaz/sarf/PPE/orthopedic/respiratory ürün: classification, registration,
  conformity, traceability, seller authorization, advertisement/claim ve recall
  metadata'sı doğrulanmalı; default **LEGAL_REVIEW_REQUIRED**.
- Professional-only, sterile/invasive, implantable, diagnostic test ve high-risk
  devices consumer launch için **LEGAL_REVIEW_REQUIRED** veya **EXCLUDED** olabilir.
- Sahte/registration belirsiz cihaz **EXCLUDED**. Medical claim kanıtı olmayan ürün
  tıbbi etkiyle pazarlanamaz.
- Sağlık verisi toplanması taxonomy görevi değildir; app-connected cihaz için
  privacy/security review gerekir.
- Policy class category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Wellness smartwatch/fitness tracker | Elektronik; medical device olarak ayrıca ruhsatlı/dedicated intended use yoksa Evde Sağlık Ölçüm'e gelmez. |
| Smart scale | Dedicated health measurement product ise Evde Ölçüm; sıradan banyo tartısı Ev & Yaşam/Kozmetik boundary owner rule. |
| Masaj tabancası | Fitness/recovery consumer device ise Spor/Elektronik; registered rehabilitation intended use varsa legal review ile Rehabilitasyon. |
| Ortopedik yastık | Medical support claim/evidence varsa Ortopedik Destek; generic comfort pillow Ev & Yaşam. |
| Compression sock | Medical compression grade varsa Ortopedik; ordinary fashion/support sock Giyim. |
| Test strip | Belirli registered measurement device consumable ise Evde Ölçüm; device compatibility mandatory. |
| Antiseptik solüsyon | İlaç/biocidal/cosmetic statüsüne göre farklı rejim; İlk Yardım'a otomatik atanmaz. |
| Disposable mask | Medical/PPE certification/intended use varsa Kişisel Koruyucu Medikal; fashion mask Giyim/Aksesuar. |
| Hospital bed | Home medical/hasta bakım cihazı mı general furniture mı ve seller eligibility owner/legal review; proposal otomatik atamaz. |
| Supplement | Ayrı policy/owner kararı; bu 9 L2'den hiçbirine atanmaz. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- İlk Yardım & Yara Bakımı → İlk Yardım Setleri; Bandaj & Flaster; Steril Kompres &
  Yara Örtüsü; Pansuman Aksesuarları.
- Evde Sağlık Ölçüm → Tansiyon; Ateş; Oksijen/Nabız; Glikoz; Vücut Ölçüm;
  Device-specific Sarf & Aksesuar.
- Ortopedik Destek → Diz/Dirsek/El; Bel/Boyun; Ayak/Tabanlık; Atel; Kompresyon.
- Mobilite → Tekerlekli Sandalye; Yürüteç/Rollator; Baston/Koltuk Değneği;
  Mobilite Aksesuarı.
- Rehabilitasyon → Elektroterapi; Egzersiz/Terapi; El Rehabilitasyonu;
  Sıcak/Soğuk Uygulama (policy kanıtıyla).
- Solunum & Evde Bakım → Nebulizer; Aspiratör; Oksijen Destek; CPAP/BPAP;
  Maske/Hortum/Filtre.
- Medikal Sarf & Hasta Bakım → İnkontinans; Ostomi; Muayene/Pansuman Sarfı;
  Bakım Örtüsü; Eligibility-gated İnvasive Sarf.

Hastalık, marka, risk class, beden ve cihaz modeli L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 9 L2 adı/sırası ve fail-closed launch posture onaylanmalı.
2. Tıbbi cihaz risk sınıfı, ÜTS/registration, merchant authorization ve remote-sale
   eligibility için authoritative legal/product matrix hazırlanmalı.
3. Supplement/takviye ürünlerinin tamamen excluded mı ayrı gelecekte regulated
   proposal mı olacağı kararlaştırılmalı.
4. Professional-only, invasive/sterile diagnostic ve home-care cihazların consumer
   scope threshold'u belirlenmeli.
5. Wellness consumer device ile medical device intended-use precedence rule'u
   tanımlanmalı.
6. Hospital bed, smart scale, orthopedic pillow ve massage device boundaries
   finalleştirilmeli.
7. Product recall, UDI/traceability, claim moderation ve health-data integration
   requirements ayrı readiness workstream'e atanmalı.

Owner/legal onayı olmadan proposal **FINAL** veya satışa hazır yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **9**
- Normalized duplicate L2: **0**
- Prescription/restricted medicine normal-category leakage: **0**
- Supplement normal-category leakage: **0**
- Cosmetics leakage: **0**
- Adult stimulation product inclusion: **0**
- Professional medical device auto-eligibility: **0**
- Service leakage: **0**
- Fail-closed policy gate: **DOCUMENTED — OWNER/LEGAL WORK OPEN**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`HEALTH_MEDICAL_L2_ARCHITECTURE: PASS`

`HEALTH_MEDICAL_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
