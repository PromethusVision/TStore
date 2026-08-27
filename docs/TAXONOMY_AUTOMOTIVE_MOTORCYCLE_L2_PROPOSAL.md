# EsnaftaVar — Otomotiv & Motosiklet L2 Proposal

**Wave:** 15 / Overnight Taxonomy Batch 03

**Belge tarihi:** 28 Ağustos 2026

**Canonical L1:** **Otomotiv & Motosiklet — CONFIRMED / PRODUCT OWNER FINAL**

## 1. Status

**PROPOSED FOR OWNER REVIEW**

Bu belge yalnız L2 bilgi mimarisi önerir. L3/L4 ağacı, stable ID, runtime JSON,
migration, seed veya ürün ataması üretmez. L1 adı ve kapsamı değişmez.

## 2. Scope

Kapsam; otomobil ve motosiklet için fiziksel yedek parça, bakım ürünü, lastik/jant,
araç içi/dışı aksesuar, araç elektriği/elektroniği, güvenlik/acil durum ürünü ve
motosiklet sürücü koruma ekipmanıdır.

Araç satışı, kiralama, servis/işçilik, ekspertiz, sigorta, yakıt, yol yardımı ve
rezervasyon ürün taxonomy'si değildir. Her fiziksel ürün ileride tam olarak bir
primary canonical leaf'e atanır. Marka, model, üretim yılı, motor kodu ve araçla
uyumluluk category değil facet/compatibility ilişkisidir.

## 3. Sources

Kaynaklar 28 Ağustos 2026 tarihinde kontrol edildi. Platform yapıları karşılaştırma
kanıtıdır; node adları veya sıraları kopyalanmadı.

| Kaynak | Gözlem | Kullanım / sınırlama |
|---|---|---|
| [Google Product Taxonomy public file](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) ve [Merchant Center ana-fonksiyon kuralı](https://support.google.com/merchants/answer/6324436?hl=en-GB) | Vehicle parts/accessories; tires/wheels; fluids; motorcycle protective gear gibi farklı şema aileleri vardır ve ürün için tek en uygun kategori istenir. | Ana işlev ve tek primary leaf ilkesi alındı. Public dosya bugün erişilebilir olsa da header sürümü `2021-09-21`; 2026 pazar ağacı sayılmadı. |
| [Trendyol Otomobil & Motosiklet](https://www.trendyol.com/otomobil-ve-motosiklet-x-c105777?pi=2) | Oto yedek parça, lastik/aksesuar, akü, iç aksesuar ve bakım dili Türkiye müşterisinde görünürdür. | Türkçe arama niyeti doğrulandı; merchandising sırası canonical kabul edilmedi. |
| [n11 Motosiklet Yedek Parça & Aksesuar](https://www.n11.com/motosiklet/yedek-parca-ve-aksesuar) | Akü, fren, filtre, debriyaj, aydınlatma, yağ, kilit/alarm, bakım, egzoz ve süspansiyon ayrışır. | Motosiklet parça şemasının otomobilden ayrı L2 gerektirdiğini destekler; alt dallar L2'ye şişirilmedi. |
| [n11 Araba](https://www.n11.com/araba/arac-satis) | Araç ilanı ile araç parçası/aksesuar niyetleri aynı pazaryerinde ayrı yüzeylerdir. | Araç satışının bu ürün taxonomy'sine alınmamasını destekler. |
| [Çevre, Şehircilik ve İklim Değişikliği Bakanlığı yönetmelik listesi](https://cygm.csb.gov.tr/yonetmelikler-440) ve [Atık Yağların Yönetimi Yönetmeliği](https://webdosya.csb.gov.tr/db/cygm/icerikler/yon-30985at-kyagyonynt-20201224171101.pdf) | Atık akü/pil ve atık yağ için çevresel yükümlülükler vardır. | Akü, yağ ve kimyasal ürünler category derinliğiyle değil policy/fulfilment kontrolüyle ele alınmalıdır. Bu belge hukuki uygunluk kararı vermez. |

**Source limitation:** Hepsiburada ve Amazon Türkiye'nin güncel, eksiksiz ve
public L2 ağaçları güvenilir biçimde alınamadı. Bu platformlar için eksik yapı
varsayılmadı.

## 4. Recommended L2 count

Önerilen L2 sayısı: **11**.

Bu sayı otomobil/motosiklet parçası gibi farklı fitment şemalarını ayırır; fren,
filtre, egzoz veya motor parçası gibi gelecek L3'leri L2'ye taşımaz.

## 5. Exact L2 list

1. Otomobil Yedek Parçaları
2. Motosiklet Yedek Parçaları
3. Araç İçi Aksesuarları
4. Araç Dış Aksesuarları
5. Lastik, Jant & Tekerlek Ürünleri
6. Akü & Araç Elektriği
7. Araç Elektroniği
8. Araç Bakım & Temizlik
9. Motor Yağı, Sıvı & Katkılar
10. Motosiklet Kask & Koruma Ekipmanları
11. Araç Güvenlik & Acil Durum Ürünleri

Normalized duplicate: **0**. Marka-as-category: **0**. Attribute-as-category:
**0**.

## 6. Granularity rationale

- Otomobil ve motosiklet yedek parçaları farklı fitment veri modelleri ve mağaza
  rafları nedeniyle iki L2'dir; motor/fren/egzoz L3/L4'e bırakılır.
- İç/dış aksesuar müşterinin arama dili ve kullanım yeriyle kolay ayrılır.
- Lastik/jant; ebat, mevsim, yük ve araç tipi facetleri nedeniyle bağımsız major
  department'tır.
- Akü/araç elektriği ile araç elektroniği ayrılır: ilki aracın güç/başlatma/elektrik
  sistemi, ikincisi bilgi-eğlence, kayıt, navigasyon ve yardımcı elektronik cihazdır.
- Bakım/temizlik ile yağ/sıvı/katkı; tehlike, taşıma ve uyumluluk profilleri farklı
  olduğu için ayrıdır.
- Motosiklet sürücü koruması, sıradan giyimden farklı güvenlik ve sertifikasyon
  gerektirir. Stil, cinsiyet veya sürüş tipi alt kategori değil facet'tir.
- Güvenlik/acil durum; ilk yardım çantası, reflektif ekipman, takoz ve yangın
  söndürücü gibi araçta bulundurulan işlevsel ürünleri tek yerde toplar.

## 7. Inclusions

| L2 | Dahil olan ana ürün aileleri |
|---|---|
| Otomobil Yedek Parçaları | Motor, fren, süspansiyon, direksiyon, debriyaj, egzoz, filtre, kaporta ve araç-model uyumlu mekanik parçalar |
| Motosiklet Yedek Parçaları | Motor, aktarma, fren, süspansiyon, egzoz, filtre, aydınlatma gövdesi ve motosiklet-model uyumlu parçalar |
| Araç İçi Aksesuarları | Paspas, koltuk kılıfı, organizer, güneşlik, araç içi tutucu ve iç trim aksesuarı |
| Araç Dış Aksesuarları | Portbagaj, tavan barı, araç örtüsü, dış trim, çamurluk ve model uyumlu dış koruma |
| Lastik, Jant & Tekerlek Ürünleri | Otomobil/motosiklet lastiği, jant, zincir, bijon ve lastik/jant aksesuarı |
| Akü & Araç Elektriği | Marş aküsü, motosiklet aküsü, alternatör, marş motoru, sigorta, röle ve araç elektrik parçası |
| Araç Elektroniği | Araç kamerası, multimedya ünitesi, park sensörü/kamerası, GPS navigasyon, OBD cihazı ve araç tipi şarj/voltaj ürünü |
| Araç Bakım & Temizlik | Şampuan, cila, temizleyici, mikrofiber, fırça, bakım aparatı ve araç yüzey koruma ürünü |
| Motor Yağı, Sıvı & Katkılar | Motor/şanzıman yağı, antifriz, fren/hidrolik sıvısı, cam suyu ve araç sistemi katkıları |
| Motosiklet Kask & Koruma Ekipmanları | Motosiklet kaskı; sertifikalı mont/pantolon/eldiven/bot; dizlik, dirseklik ve sırt koruyucu |
| Araç Güvenlik & Acil Durum Ürünleri | Araç ilk yardım seti, reflektif yelek/üçgen, takoz, çekme halatı, araç tipi yangın söndürücü ve mekanik araç güvenlik kilidi |

## 8. Exclusions

- Otomobil/motosiklet satış ilanı, kiralama, servis, tamir, montaj, ekspertiz,
  çekici, sigorta ve abonelik: **service/transaction scope — excluded**.
- Akaryakıt: bu consumer product taxonomy'sine sessizce alınmaz.
- Bisiklet ve bisiklet koruma ekipmanı: **Spor & Outdoor**.
- Genel telefon/tablet tutucusu, power bank ve generic consumer electronics:
  ana işlevine göre **Elektronik** veya **Bilgisayar & Tablet**; sırf araçta
  kullanılabilir diye buraya gelmez.
- Genel temizlik kimyasalı: **Ev & Yaşam**; ürün açıkça araç yüzeyi/araç sistemi
  için formüle edilmediyse otomotive atanmaz.
- Moda deri ceketi/botu: **Giyim** veya **Ayakkabı**; motosiklet koruma standardı ve
  primary protective function yoksa koruma ekipmanı değildir.
- Profesyonel lift, ağır servis makinesi ve atölye kurulumu: **Yapı Market** veya
  ayrı B2B/policy review; consumer yedek parçasına karıştırılmaz.

## 9. Cross-domain boundaries

| Sınır | Canonical kural |
|---|---|
| Elektronik | Vehicle-fitment-first kamera, multimedia, park sensörü ve OBD ürünü Araç Elektroniği; generic kamera, tablet, telefon, kulaklık veya power ürünü Elektronik. |
| Bilgisayar & Tablet | Generic USB hub/dock Bilgisayar Aksesuarları; yalnız araç elektrik sistemine göre tasarlanmış interface/adapter burada. |
| Spor & Outdoor | Motosiklet kaskı/koruyucu ekipman burada; bisiklet kaskı ve cycling protection Spor & Outdoor. |
| Giyim / Ayakkabı | CE/koruyucu primary işlevli motosiklet montu, eldiveni ve botu burada; moda/işlevsiz görünüm ürünü ilgili fashion L1'de. |
| Ev & Yaşam | Genel temizlik ürünü orada; araç yüzeyi/trim/motor bakımı için açıkça formüle edilmiş ürün burada. |
| Yapı Market | Genel el aleti orada; araç-model-specific mekanik parça burada. Oto bakım el alet setleri owner review gerektirir. |
| Sağlık & Medikal | Genel ilk yardım malzemesi Sağlık & Medikal; araç mevzuatı/taşıma amacıyla paketlenmiş araç ilk yardım seti burada, içeriği facet/kit olarak tutulur. |

## 10. Category vs facet

Category ürünün ne olduğudur; aşağıdakiler facet/compatibility alanıdır:

- araç türü: otomobil, motosiklet, hafif ticari;
- marka, model, kasa kodu, model yılı, motor kodu, OEM/MPN;
- universal/model-specific fitment ve compatible/incompatible/conditional/unknown;
- lastik ebadı, mevsim, hız/yük endeksi, jant çapı ve bijon aralığı;
- akü gerilimi, kapasitesi, kutup yönü ve start-stop uyumu;
- yağ viskozitesi, spesifikasyon/onay, hacim ve kullanım sistemi;
- bağlantı tipi, ekran boyutu, çözünürlük, kamera açısı;
- kask bedeni, koruma standardı, malzeme, renk ve cinsiyet;
- paket/set durumu. Bundle kendi kategorisi değildir.

## 11. Search synonyms

| Canonical L2 | Controlled search hints |
|---|---|
| Otomobil Yedek Parçaları | oto yedek parça, araba parçası, otomobil parçası |
| Motosiklet Yedek Parçaları | motor yedek parça, motosiklet parçası, moto parça |
| Araç İçi Aksesuarları | oto iç aksesuar, araba içi aksesuar, iç trim |
| Araç Dış Aksesuarları | oto dış aksesuar, dış trim, tavan aksesuarı |
| Lastik, Jant & Tekerlek Ürünleri | oto lastik, motor lastiği, jant, teker ekipmanı |
| Akü & Araç Elektriği | oto akü, motosiklet aküsü, marş elektriği |
| Araç Elektroniği | oto elektronik, araç kamerası, multimedya, park sensörü |
| Araç Bakım & Temizlik | oto bakım, araç temizliği, detailing ürünü |
| Motor Yağı, Sıvı & Katkılar | oto yağ, antifriz, araç sıvısı, motor katkısı |
| Motosiklet Kask & Koruma Ekipmanları | motor kaskı, moto koruma, sürücü ekipmanı |
| Araç Güvenlik & Acil Durum Ürünleri | trafik seti, araç ilk yardım, reflektör, oto güvenlik |

Synonym, canonical node veya marka boost'u üretmez. `Motor` kelimesi motosiklet,
motor parçası veya elektrik motoru anlamına gelebileceği için bağlamla ayrıştırılır.

## 12. Policy/compliance

- Normal aksesuar ve mekanik parçalar varsayılan olarak **NORMAL** olabilir; exact
  ürün, satıcı ve mevzuat koşulu ayrıca doğrulanır.
- Akü, yağ, antifriz, fren sıvısı, aerosol, solvent, katkı ve yangın söndürücü;
  tehlikeli madde, taşıma, etiket, depolama ve atık yükümlülüğü nedeniyle en az
  **LEGAL_REVIEW_REQUIRED** onboarding kapısından geçmelidir. Owner/policy matrix
  onaylamadan otomatik listelenmez.
- Kask ve koruyucu ekipmanda uygunluk işareti/standard iddiası doğrulama alanıdır;
  kategori adı sertifika kanıtı değildir.
- Araç güvenlik/immobilizer ve radyo haberleşme özellikli cihazlarda teknik mevzuat
  kontrolü gerekebilir.
- Yakıt ve illegal emisyon/safety bypass ürünü launch kapsamında **EXCLUDED**
  önerilir; exact exclusion listesi owner/legal kararıdır.
- Bu sınıflar taxonomy depth değildir; listing eligibility ve fulfilment kapısıdır.

## 13. Ambiguous products

| Ürün | Öneri / belirsizlik |
|---|---|
| EV duvar tipi şarj cihazı | Araç aksesuarı mı elektrik altyapısı mı olduğu kurulum/ana işleve bağlı; **owner decision required**. Taşınabilir vehicle-specific kablo Araç Elektroniği/Araç Elektriği adayıdır. |
| Araç içi buzdolabı | Vehicle-fitment/12V primary ise Araç İçi Aksesuar; ev/kamp primary ise ilgili L1. |
| Oto bakım el aleti seti | Vehicle-specific kullanım kanıtı varsa burada; generic lokma/anahtar seti Yapı Market. |
| Jump starter + power bank | Ana işlev araç çalıştırma ise Akü & Araç Elektriği; generic power bank ise Elektronik. |
| Android multimedya ekranı | Vehicle-fitment-first ise Araç Elektroniği; generic tablet Elektronik/Bilgisayar & Tablet. |
| Motosiklet interkomu | Helmet/rider communication primary; Araç Elektroniği adayı. Genel Bluetooth headset Elektronik. |
| Araç taşıma tavan çantası | Dış aksesuar mı Çanta & Aksesuar mı: vehicle-mount-specific ise Araç Dış Aksesuarları. |
| Vintage/collectible vehicle part | Kullanılabilir yedek parça ise burada; yalnız koleksiyon nesnesi ise Antika & Koleksiyon. |

## 14. Future L3/L4 examples

Örnekler final değildir ve max depth 4'ü aşmaz:

- Otomobil Yedek Parçaları → Motor & Filtre; Fren; Süspansiyon & Direksiyon;
  Aktarma; Egzoz; Kaporta.
- Motosiklet Yedek Parçaları → Motor; Aktarma & Debriyaj; Fren; Süspansiyon;
  Egzoz; Aydınlatma Parçaları.
- Lastik, Jant & Tekerlek Ürünleri → Lastik; Jant; Kar Zinciri; Bijon & Aksesuar.
- Araç Elektroniği → Araç Kamerası; Multimedya; Park Sistemleri; Navigasyon & OBD.
- Araç Bakım & Temizlik → İç Temizlik; Dış Yüzey Bakımı; Cila & Koruma;
  Uygulama Aksesuarları.
- Motor Yağı, Sıvı & Katkılar → Motor Yağı; Şanzıman Yağı; Antifriz & Soğutma;
  Fren/Hidrolik Sıvıları; Katkılar.
- Motosiklet Kask & Koruma Ekipmanları → Kask; Koruyucu Giyim; Eldiven;
  Koruyucu Bot; Vücut Koruyucuları.

Ebat, viskozite, araç modeli ve standard gibi değerler L3/L4 yapılmaz.

## 15. Owner decisions

1. Exact 11 L2 adı, sıra ve `Otomobil`/`Araç` dil tercihi onaylanmalı.
2. EV şarj kablosu, taşınabilir şarj ekipmanı ve wallbox için Otomotiv–Yapı
   Market/Elektronik sınırı kararlaştırılmalı.
3. Oto bakım el aleti setlerinin vehicle-specific kanıt eşiği belirlenmeli.
4. Akü, yağ, sıvı, aerosol ve yangın söndürücü için launch eligibility/policy
   sınıfları legal/operations tarafından kesinleştirilmeli.
5. Motosiklet interkomunun Araç Elektroniği altında kalması onaylanmalı.
6. Ağır ticari, tarım aracı ve deniz aracı parçalarının consumer scope'a girip
   girmediği ayrı karara bağlanmalı.

Owner onayı olmadan belge **FINAL** yapılmaz.

## 16. Validation

- Canonical L1 adı değişmedi: **PASS**
- Exact proposed L2 count: **11**
- Normalized duplicate L2: **0**
- Marka-as-category: **0**
- Araç fitment attribute-as-category: **0**
- Otomobil/motosiklet parça sınırı: **DOCUMENTED**
- Generic Electronics leakage guard: **PASS**
- Service/vehicle-sale leakage: **0**
- Akü/yağ/kimyasal policy gate: **DOCUMENTED — OWNER/LEGAL REVIEW OPEN**
- Future depth: **L1→L2→L3→L4 maximum respected**
- Runtime/DB/remote değişikliği: **NONE**

`AUTOMOTIVE_MOTORCYCLE_L2_ARCHITECTURE: PASS`

`AUTOMOTIVE_MOTORCYCLE_L2_READY_FOR_OWNER_REVIEW: YES`

`OWNER_FINALIZATION: NO`

`RUNTIME_IMPLEMENTATION: NO`
