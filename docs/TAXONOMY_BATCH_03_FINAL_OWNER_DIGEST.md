# EsnaftaVar — Taxonomy Batch 03 Final Owner Digest

**Wave:** 32 / Taxonomy Finalization Sprint C

**Belge tarihi:** 29 Ağustos 2026

**Durum:** `CANDIDATE FOR PRODUCT OWNER FINALIZATION`

**Kaynak:** `origin/agent2/w15-overnight-taxonomy-batch-03@f1e766eeacbcbc1f1ed69ee18d040321645a6796`

## 1. Owner için kısa sonuç

Sekiz canonical L1'in 77 kaynak L2'si değiştirilmeden korunmuş, altlarına 366 L3
ve 16 L4 adayı eklenmiştir. Ağaç 379 terminal product-type leaf içerir.

Yapısal paket birlikte owner review'a hazırdır. Hiçbir seçenek seçilmemiş, hiçbir
düğüm `FINAL` yapılmamış ve hiçbir hassas ürün satışa açılmamıştır.

| Alan | L2 | L3 | L4 | Leaf | Yapısal öneri |
|---|---:|---:|---:|---:|---|
| Otomotiv & Motosiklet | 11 | 61 | 14 | 71 | Aday ağacı birlikte onayla / geri gönder |
| Kitap | 10 | 50 | 0 | 50 | Aday ağacı birlikte onayla / geri gönder |
| Kırtasiye & Ofis | 11 | 59 | 2 | 60 | Aday ağacı birlikte onayla / geri gönder |
| Evcil Hayvan Ürünleri | 7 | 43 | 0 | 43 | Aday ağacı birlikte onayla / geri gönder |
| Gözlük & Optik | 7 | 21 | 0 | 22 | Aday ağacı birlikte onayla / geri gönder |
| Saat & Takı | 11 | 35 | 0 | 36 | Aday ağacı birlikte onayla / geri gönder |
| Sağlık & Medikal | 9 | 44 | 0 | 44 | Yapısal onay ayrı, launch/policy onayı ayrı |
| Çiçek & Bahçe | 11 | 53 | 0 | 53 | Yapısal onay ayrı, live/chemical gate ayrı |

## 2. Owner şimdi neyi onaylayabilir?

Owner her domain için şu üç yoldan birini seçebilir:

- **APPROVE STRUCTURE:** Exact L2/L3/L4 adlarını ve parent-child yollarını canonical
  candidate olarak kabul et.
- **RETURN WITH NAMED CHANGES:** Değişmesini istediği exact node/path'leri belirt.
- **DEFER DOMAIN:** Domain'i toplu finalization dışında bırak; diğer domain'leri
  bağımsız ilerlet.

Yapısal onay; regulated ürün eligibility, merchant yetkisi, satış kanalı, legal
uygunluk, stable ID allocation veya runtime yayınlama onayı değildir.

Önerilen cevap biçimi:

```text
B03-AUTOMOTIVE=APPROVE_STRUCTURE
B03-BOOKS=APPROVE_STRUCTURE
B03-STATIONERY=APPROVE_STRUCTURE
B03-PET=APPROVE_STRUCTURE
B03-OPTICS=APPROVE_STRUCTURE
B03-WATCH_JEWELRY=APPROVE_STRUCTURE
B03-HEALTH=APPROVE_STRUCTURE
B03-FLOWERS_GARDEN=APPROVE_STRUCTURE
```

Bu belge bu cevapların hiçbirini owner adına seçmez.

## 3. Domain karar özeti

### B03-AUTOMOTIVE — Otomotiv & Motosiklet

**Önerilen yapı:** Fitment bir kategori değil facet; ürün family'si primary leaf.
Araç kamerası/OBD/park/multimedya gibi vehicle-fitment electronics burada, generic
electronics kendi L1'inde kalır.

Owner yapısal olarak 11 L2 + 61 L3 + 14 L4'ü review eder. Vehicle chemical, battery,
safety ve fitment doğrulaması ayrıca policy/professional gate'tedir.

### B03-BOOKS — Kitap

**Önerilen yapı:** Yalnız fiziksel kitap. E-kitap, sesli kitap, lisans ve abonelik
bu V1 Product Taxonomy'de yoktur. Yazar, dil, yayınevi, baskı ve format facet'tir.

Owner yapısal olarak 10 L2 + 50 L3'ü review eder.

### B03-STATIONERY — Kırtasiye & Ofis

**Önerilen yapı:** Generic kağıt/etiket/termal rulolar burada; printer-specific toner,
kartuş ve drum `Bilgisayar & Tablet` alanında kalır. Kesici/kimyasal/elektrikli ürün
gates'i taxonomy'den ayrıdır.

Owner yapısal olarak 11 L2 + 59 L3 + 2 L4'ü review eder.

### B03-PET — Evcil Hayvan Ürünleri

**Önerilen yapı:** Species-first L2, function-first L3. Species aynı zamanda typed
facet; ırk, yaş ve beden kategori değildir. Canlı hayvan ve veteriner ilacı leaf'i
yoktur.

Owner yapısal olarak 7 L2 + 43 L3'ü review eder.

### B03-OPTICS — Gözlük & Optik

**Önerilen yapı:** Çerçeve, güneş gözlüğü, hazır okuma, cam, kontakt lens, lens bakım
ve aksesuar ayrı product families. Reçete/custom ölçü/optisyen yetkisi taxonomy
değil legal-policy katmanıdır; optik hizmeti dışarıdadır.

Owner yapısal olarak 7 L2 + 21 L3 ve bir L2-level leaf'i review eder.

### B03-WATCH_JEWELRY — Saat & Takı

**Önerilen yapı:** Analog, klasik dijital ve mekanik/otomatik saat burada; smartwatch
ve smart ring `Elektronik` alanında. Değerli maden, ayar, taş, sertifika ve fiyat
bandı facet/policy'dir.

Owner yapısal olarak 11 L2 + 35 L3 ve bir L2-level leaf'i review eder. Investment
gold/loose stone kapsamı bu paketle açılmaz.

### B03-HEALTH — Sağlık & Medikal

**Önerilen yapı:** Dokuz functional home-use family korunur ve tüm 53 düğüm
fail-closed kalır. Taxonomy onayı medical satış uygunluğu değildir.

İlaç, aşı, hormon, kontrollü ürün, supplement/takviye, medical nutrition ve ağır
professional hospital equipment için normal launch leaf'i yoktur. Bunlar ayrı
owner/legal workstream olmadan eklenemez.

### B03-FLOWERS_GARDEN — Çiçek & Bahçe

**Önerilen yapı:** Canlı, kesme ve yapay ürün ayrıdır. Canlı bitki/tohum/fide/gübre
legal/fulfilment gate taşır; pesticide/plant-protection ürünü normal online node
değildir. Manual garden tool burada; powered tool `Yapı, Hırdavat & Tesisat`, garden
furniture `Ev & Yaşam` alanındadır.

Fiziksel buket/aranjman product'tır; tasarım, kurulum, bakım, abonelik ve yalnız
teslimat hizmeti değildir.

## 4. Yapısal onaydan ayrı kalan yüksek etkili policy kararları

Bu maddeler tree review'u engellemez; launch/runtime öncesi ayrı karar ve uzman
doğrulaması ister:

| ID | Açık karar | Neden ayrı tutuluyor? |
|---|---|---|
| B03-P01 | Vehicle fitment doğrulama kaynağı ve yanlış uyum sorumluluğu | Facet/compatibility contract; kategori adı çözmez. |
| B03-P02 | Vehicle chemical, battery ve fire-safety SKU/fulfilment matrix'i | Tehlikeli madde, etiket ve taşıma şartları exact SKU'ya bağlıdır. |
| B03-P03 | Çocuk kitabı/içerik yaş uygunluğu politikası | Shelf taxonomy içerik moderasyonu değildir. |
| B03-P04 | Kesici, yapıştırıcı, sanat kimyasalı ve çocuk kırtasiyesi gates'i | Yaş/kimyasal/ürün güvenliği leaf'ten bağımsızdır. |
| B03-P05 | Pet food/claim/veterinary boundary ve live-animal hard block | Species tree satış yetkisi yaratmaz. |
| B03-P06 | Prescription/custom optics, contact lens ve optisyen merchant matrix'i | Reçete/ölçüm/hizmet/yetki ayrı rejimdir. |
| B03-P07 | Precious/high-value goods, investment gold ve loose stone scope'u | Maden/değer/sertifika SKU-level doğrulama ister. |
| B03-P08 | Supplement ve medical nutrition gelecekte excluded mı, ayrı regulated proposal mı? | Mevcut health tree'ye sessiz eklenemez. |
| B03-P09 | Home-use ile professional/invasive/sterile medical threshold'u | Health taxonomy'deki görünürlük eligibility değildir. |
| B03-P10 | Live plant/seed traceability, delivery radius, freshness ve return policy | Canlı fulfilment category yapısından ayrıdır. |
| B03-P11 | Fertilizer eligibility ve pesticide hard-block enforcement | Gübre ile online-excluded bitki koruma ürünü aynı gate değildir. |
| B03-P12 | Physical flower product ile service/subscription listing contract'ı | Product/Service ayrımı listing seviyesinde uygulanmalıdır. |

Bu 12 policy maddesinde seçenek seçilmemiştir.

## 5. Değiştirilmeyen sınırlar

- Canonical 24 L1 adı/sırası değişmedi.
- Product ve Merchant/Sector Taxonomy ayrımı değişmedi.
- OM-R06=B staged stable identity kararı değişmedi; production ID üretilmedi.
- OM-R07=B Product/Variant/Listing ayrımı değişmedi.
- OM-R10=A ordinary allowlist + sensitive fail-closed kararı değişmedi.
- Hizmet, policy state, seller authorization ve search synonym'i product node
  yapılmadı.
- Hiçbir remote environment, runtime, Flutter, Figma, DB veya migration değişmedi.

## 6. Owner onayı sonrası sıra

1. Owner tarafından approve edilen exact yolları canonical decision kaydına işle.
2. Ayrı policy/legal workstream'lerde B03-P01–P12'yi çöz.
3. Stable opaque taxonomy ID mapping'ini OM-R06=B'ye uygun ayrı runtime task olarak
   tasarla; current source slugs için alias/redirect planını koru.
4. Product/Variant/Listing entegrasyonunu OM-R07=B'ye göre yap.
5. Sensitive ingestion/search/merchant eligibility'yi OM-R10=A ile fail-closed test et.

## 7. Owner için güvenlik notu

`APPROVE_STRUCTURE` yalnız adları ve parent-child ağacını kabul eder. Özellikle
Sağlık, Optik, pet claims, precious goods, vehicle chemicals ve canlı/kimyasal
garden ürünleri için “satılabilir”, “yayına hazır” veya “mevzuata uygun” sonucu
üretmez.

## 8. Durum

`BATCH_03_TAXONOMY_FINALIZATION: PASS`

`L2_RECONCILIATION: PASS`

`L34_DESIGN: PASS`

`CROSS_DOMAIN_AUDIT: PASS`

`READY_FOR_BULK_OWNER_FINALIZATION: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
