# EsnaftaVar — Gözlük & Optik L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Gözlük & Optik — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Bu belge yalnız L2 bilgi mimarisi önerir. Reçete işleme, optisyenlik hizmeti,
remote satış yetkisi, L3/L4, stable ID, runtime taxonomy veya policy enforcement
uygulamaz.

## 2. Scope

Kapsam; optik gözlük çerçevesi, moda güneş gözlüğü, hazır okuma gözlüğü, gözlük
camı, kontakt lens, kontakt lens bakım ürünü ve gözlük/optik aksesuarıdır.

Bu L1 hem fashion-led hem medical/prescription-led ürün barındırır. Taxonomy ürünün
ne olduğunu tanımlar; satış yetkisi, reçete, ölçüm, kişiye özel üretim, optisyenlik
müessesesi ve tıbbi cihaz uygunluğu ayrı policy/commerce kapısıdır. Marka, cinsiyet,
çerçeve şekli, materyal, renk ve diyoptri category değil facet'tir.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Sunglasses, eyeglass frames, contact lenses ve eyewear accessories ayrı ürün aileleridir; tek en uygun kategori istenir. | Physical product families ve one-primary-leaf ilkesi alındı. Public taxonomy header'ı `2021-09-21`; 2026 Türkiye regulation/taxonomy kaynağı değildir. |
| [Trendyol Gözlük Çerçevesi](https://www.trendyol.com/polo-gozluk-cercevesi-y-s69143) | Çerçeve şekli, materyal, renk, hedef kullanıcı ve marka arama eksenleridir. | Bunlar facet tutuldu; brand-as-category yapılmadı. |
| [Trendyol Gözlük Aksesuarları](https://www.trendyol.com/gozluk-aksesuarlari-x-c108945) ve [n11 Gözlük Aksesuarı](https://www.n11.com/gunes-gozlugu/gozluk-aksesuari) | Kılıf, bez, zincir/ip, klips ve bakım aksesuarları ayrı müşteri niyetidir. | Aksesuar L2'si desteklendi; ana gözlükle kopyalanmadı. |
| [Trendyol lens solüsyonu 2026 örneği](https://www.trendyol.com/pro/vision-lens-solusyonu-p-1170864272) | Kontakt lens temizleme/bakım solüsyonu, lens kabı ve tıbbi cihaz uygunluk iddiasıyla sunulur. | Lens bakımının ayrı schema/policy profili doğrulandı; tek ürün veya claim hukuki onay olarak alınmadı. |
| [Sağlık Bakanlığı — Optisyenlik Hakkında Kanun](https://shgmsmdb.saglik.gov.tr/TR-102383/optisyenlik-hakkinda-kanun.html) ve [Optisyenlik Müesseseleri Yönetmeliği](https://saglik.gov.tr/TR-10467/optisyenlik-muesseseleri-hakkinda-yonetmelik.html) | Optisyenlik mesleği ve müesseseleri ayrı düzenlemeye tabidir. | Prescription/custom optics için fail-closed legal review gerekir. |
| [Sağlık Bakanlığı — tıbbi cihaz temini](https://khgm.saglik.gov.tr/TR-119761/tibbi-cihaz.html) | Reçete edilen gözlük camı/çerçevesi ve kontakt lens, sözleşmeli optisyenlik müesseselerinden temin edilen görmeye yardımcı tıbbi malzeme olarak açıklanır. | Reçeteli ürün ile fashion browse aynı taxonomy'de olsa da commerce eligibility'nin ayrı tutulması gerektiğini destekler. |
| [Sağlık Bakanlığı — optisyenlik müessesesi başvuru süreçleri 2026](https://adanaism.saglik.gov.tr/TR-381500/optisyenlik-muessesesinde-basvuru-surecleri.html) | Müessese, mesul müdür ve zorunlu araç/gereç süreçleri devam eden güncel operasyonel gerekliliklerdir. | Merchant verification ihtiyacını doğrular; taxonomy belgesi ruhsat yeterliliği vermez. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin güncel tam public optics
tree'si alınamadı; pazaryeri ürün sayfaları canonical mevzuat kaynağı sayılmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **7**.

Çerçeve, bitmiş güneş/okuma gözlüğü, kişiselleştirilen cam, kontakt lens, lens bakım
ürünü ve aksesuar farklı attribute/policy şemalarıdır. Model, şekil ve diyoptriyi
L2'ye taşımadan anlamlı ayrım sağlar.

## 5. Exact L2 list

1. Optik Gözlük Çerçeveleri
2. Güneş Gözlükleri
3. Hazır Okuma Gözlükleri
4. Gözlük Camları
5. Kontakt Lensler
6. Kontakt Lens Bakım Ürünleri
7. Gözlük & Optik Aksesuarları

Normalized duplicate: **0**. Marka-as-category: **0**. Cinsiyet/materyal/diyoptri-
as-category: **0**.

## 6. Granularity rationale

- Çerçeve, reçeteli camla tamamlanan temel fiziksel üründür; bitmiş güneş veya hazır
  okuma gözlüğünden farklı schema ister.
- Güneş gözlüğü fashion discovery açısından güçlü ve bitmiş üründür; UV/polarize
  claimleri facet/compliance alanıdır.
- Hazır okuma gözlüğü sabit güçte bitmiş görme yardımcısıdır; custom cam/çerçeve
  siparişi değildir ama regulatory review gerektirebilir.
- Gözlük camları prescription/custom, kaplama, indeks ve ölçüm odaklıdır; servis ve
  fiziksel cam ürünü ayrıştırılmalıdır.
- Kontakt lens, göze temas eden ayrı bir tıbbi/optik ürün ailesidir; renkli/kosmetik
  amaçlı lens de aynı policy kapısından geçer.
- Lens bakım solüsyonu ve kabı, lensin kendisi değildir ve farklı fulfilment/
  kullanım şeması taşır.
- Kılıf, bez, zincir, ip, burun pedi ve tamir kiti major accessory group'tur;
  bunları ana gözlük L2'lerinde çoğaltmaz.

## 7. Inclusions

| L2 | Dahil olan ana ürünler |
|---|---|
| Optik Gözlük Çerçeveleri | Numaralı cam takılmak üzere tasarlanmış yetişkin/çocuk optik çerçeve ve clip-on uyumlu çerçeve |
| Güneş Gözlükleri | Fashion/consumer güneş gözlüğü, polarize güneş gözlüğü ve bitmiş güneş koruma eyewear |
| Hazır Okuma Gözlükleri | Standart diyoptrili hazır okuma gözlüğü ve katlanır/taşınabilir ready-reader |
| Gözlük Camları | Tek/çok odaklı, prescription/custom, güneş/renkli veya koruyucu kaplamalı optik cam/lens blank ürünü |
| Kontakt Lensler | Refractive, toric, multifocal, renkli/kosmetik ve günlük/aylık kontakt lens; exact eligibility saklıdır |
| Kontakt Lens Bakım Ürünleri | Çok amaçlı lens solüsyonu, peroksit sistem, temizleme/durulama ürünü ve kontakt lens kabı |
| Gözlük & Optik Aksesuarları | Kılıf, bez, temizleme aksesuarı, zincir/ip, burun pedi, sap/vida ve küçük tamir seti |

## 8. Exclusions

- VR/AR headset, smart glasses ve kamera/display/consumer-electronics-primary
  gözlük: **Elektronik**.
- İş güvenliği gözlüğü, kaynak gözlüğü ve endüstriyel yüz koruması: primary safety/
  work equipment olarak **Yapı Market** veya Sağlık policy boundary review.
- Yüzme, kayak, bisiklet ve spor performans gözlüğü: primary sport equipment ise
  **Spor & Outdoor**; sıradan fashion sunglasses burada.
- Oyuncak/kostüm gözlük: **Oyuncak** veya Giyim/Kostüm accessory; optik iddia yoktur.
- Göz damlası, ilaç ve reçeteli farmasötik: **EXCLUDED / regulated pharmacy
  channel**, bu L1'e alınmaz.
- Göz muayenesi, refraksiyon ölçümü, cam kesme/takma, bakım/tamir işçiliği:
  **service scope — Product Taxonomy dışında**.
- Genel ekran privacy filter veya bilgisayar gözlüğü iddialı elektronik aksesuar:
  fiziksel gözlükse burada; screen-mounted filter Bilgisayar Aksesuarları.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Elektronik | Görme/fashion eyewear burada; display, kamera, işlemci veya VR experience primary ise Elektronik. |
| Sağlık & Medikal | Bu L1 optik ürün family ownership'ini korur; medical/prescription status listing policy'dir. Genel medikal göz ekipmanı ve tanı cihazı Sağlık & Medikal. |
| Spor & Outdoor | Spor güvenliği/performance primary olan goggle orada; everyday sunglasses burada. |
| Yapı Market | Industrial/OHS protective eyewear orada veya policy review; fashion/vision optics burada. |
| Kozmetik & Kişisel Bakım | Lens temizleme/bakım optik ürünü burada; yüz/kozmetik temizleyici orada. Renkli lens kozmetik amaçlı olsa bile Kontakt Lensler ve legal review. |
| Saat & Takı | Gözlük zinciri ürünle kullanım primary ise burada; bağımsız kolye/takı Saat & Takı. |

## 10. Category vs facet

Aşağıdakiler category değil facet/typed medical attribute'tur:

- marka, koleksiyon/seri, cinsiyet/hedef kullanıcı ve yaş grubu;
- çerçeve şekli, materyali, rengi, ölçüsü, köprü/sap uzunluğu;
- cam materyali, indeks, tasarım, kaplama, renk, UV/polarization;
- sphere, cylinder, axis, addition, base curve, diameter ve pupillary distance;
- kontakt lens kullanım süresi, toric/multifocal, renk ve paket adedi;
- prescription required/available, custom-made ve ready-made durumları;
- compatible/incompatible/conditional/unknown;
- set/bundle. Kılıflı gözlük yeni category oluşturmaz.

Medical ölçüleri category slug'ına veya serbest metne gömmek yerine validated typed
fields olarak tasarlanmalıdır.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Optik Gözlük Çerçeveleri | numaralı gözlük çerçevesi, optik çerçeve, eyeglass frame |
| Güneş Gözlükleri | güneş gözlüğü, sunglasses, güneşlik gözlük |
| Hazır Okuma Gözlükleri | okuma gözlüğü, yakın gözlüğü, ready reader |
| Gözlük Camları | optik cam, numaralı cam, reçeteli gözlük camı |
| Kontakt Lensler | lens, kontak lens, contact lens, renkli lens |
| Kontakt Lens Bakım Ürünleri | lens solüsyonu, lens suyu, lens temizleme, lens kabı |
| Gözlük & Optik Aksesuarları | gözlük kılıfı, gözlük bezi, gözlük zinciri, burun pedi, tamir seti |

`Lens` kelimesi camera lensiyle çok anlamlıdır; göz/kontakt bağlamı yoksa **Elektronik
→ Kamera** sonucuna yönlenebilir.

## 12. Policy/compliance

- Optik çerçeve, prescription/custom gözlük camı, hazır okuma gözlüğü, kontakt lens
  ve lens bakım ürünü için exact tıbbi cihaz/optisyenlik statüsü doğrulanmalıdır:
  **LEGAL_REVIEW_REQUIRED**.
- Merchant'ın optisyenlik müessesesi/mesul müdür/ruhsat doğrulaması gerekebilir;
  kategori ataması satış yetkisi vermez.
- Reçete ve kişisel sağlık ölçüleri hassas veridir; taxonomy attribute'u ile sağlık
  verisi toplama/işleme yetkisi karıştırılmaz.
- Renkli/kosmetik kontakt lens, gözle temas ettiği için fashion ürünü gibi normal
  listing'e açılmaz.
- Güneş gözlüğünde UV/polarize/koruma claimleri kanıt ve ürün güvenliği kontrolü
  ister; sahte marka/certification ayrıca enforcement konusudur.
- Göz ilacı **EXCLUDED**. Tanı/tedavi hizmeti Product Taxonomy dışında.
- Policy class category depth değildir.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| Mavi ışık filtreli numarasız gözlük | Fiziksel eyewear primary ise Optik Çerçeve/bitmiş gözlük için owner leaf kararı; medical claim legal review. Screen filter ise Bilgisayar Aksesuarları. |
| Akıllı sesli gözlük | Display/audio/camera/electronics primary ise Elektronik; sadece optik çerçeve içine pasif tracker accessory değil. |
| Kayak/yüzme gözlüğü | Spor & Outdoor; UV koruması olması fashion sunglasses ownership'i yaratmaz. |
| İş güvenliği gözlüğü | Yapı Market/OHS equipment veya Sağlık policy boundary; bu proposal otomatik atamaz. |
| Clip-on güneş aparatı | Çerçeveye bağlı accessory ise Gözlük & Optik Aksesuarları; bitmiş sunglasses değildir. |
| Renkli kontakt lens | Kontakt Lensler; cosmetic intent policy'yi azaltmaz. |
| Lens kabı + solüsyon seti | Principal bakım ürününe göre Kontakt Lens Bakım; bundle facet. |
| Gözlük temizleme spreyi | Açık eyewear-safe/use ise Optik Aksesuar; generic yüzey temizleyici Ev & Yaşam. |
| Numaralı spor gözlüğü | Primary sport equipment mi custom optic mi olduğuna göre owner rule gerekli; çift atama yok. |

## 14. Future L3/L4 examples

Örnekler final değildir:

- Optik Gözlük Çerçeveleri → Tam Çerçeve; Yarım Çerçeve; Çerçevesiz; Clip-on
  Uyumlu (yalnız schema/volume kanıtı varsa).
- Güneş Gözlükleri → Standard Güneş Gözlüğü; Clip-on Güneş Gözlüğü.
- Gözlük Camları → Tek Odaklı; Progresif/Çok Odaklı; Reçeteli Güneş Camı.
- Kontakt Lensler → Sferik; Torik; Multifokal; Renkli/Kozmetik.
- Kontakt Lens Bakım → Solüsyon; Temizleme Sistemi; Lens Kabı.
- Gözlük & Optik Aksesuarları → Kılıf; Bez/Temizlik; Zincir/İp; Tamir Parçası.

Marka, model, cinsiyet, şekil, renk, diyoptri ve kaplama L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 7 L2 adı ve sırası onaylanmalı.
2. `Gözlük Camları`nın physical product ile custom cutting/fitting service ayrımı
   için listing contract tanımlanmalı.
3. Hazır okuma gözlüğü, çerçeve, kontakt lens ve solüsyon için merchant/product
   eligibility matrix legal tarafından kesinleştirilmeli.
4. Numarasız mavi-ışık gözlüğünün hangi canonical leaf'e gireceği kararlaştırılmalı.
5. Spor ve iş güvenliği gözlüğü için primary-function rule finalleştirilmeli.
6. Numaralı spor gözlüğü ve akıllı gözlük gibi hybrid ürünlerde precedence rule
   belirlenmeli.

Owner onayı olmadan proposal **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Proposed L2 count: **7**
- Normalized duplicate L2: **0**
- Marka/cinsiyet/materyal/diyoptri-as-category: **0**
- Fashion sunglasses ownership: **PASS**
- VR/smart-electronics leakage: **0**
- Prescription/custom optics policy gate: **DOCUMENTED — OPEN**
- Medicine leakage: **0**
- Service leakage: **0**
- Future max depth: **4**
- Runtime/DB/remote değişikliği: **NONE**

`OPTICS_L2_ARCHITECTURE: PASS`

`OPTICS_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
