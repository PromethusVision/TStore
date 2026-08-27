# EsnaftaVar Ev & Yaşam L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: final L1 **Ev & Yaşam** için L2 spine önerisi
- Owner approval, stable identity, slug/sort, full L3/L4, facet implementation,
  runtime/JSON/DB veya remote değişiklik değildir.
- Canonical 24 L1 ile Product/Merchant/Facet/Service ayrımları korunur.

## 2. Scope

Kapsam; evin döşenmesi, uyku konforu, tekstil, dekorasyon, taşınabilir aydınlatma,
düzenleme, banyo kullanımı ve elektrikli olmayan günlük temizlik/çamaşır bakımı için
satılan fiziksel ürünlerdir. Mutfakta hazırlama/servis, sabit yapı/tesisat, elektrikli
ev aleti, bahçe ürünü ve profesyonel hizmet kendi L1/domain'inde kalır.

Oda, stil, renk, materyal, ölçü, marka ve dekorasyon trendi category değildir. Her SKU
tek primary leaf kullanır; pazaryerlerinin geniş `Ev & Yaşam` menüleri canonical L1
sınırlarını geçersiz kılmaz.

## 3. Sources reviewed

Erişim tarihi **2026-08-28**:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek external category ve full-path yaklaşımı incelendi.
- [Google Product Taxonomy — Türkçe](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  furniture, linens/bedding, decor, lighting ve household supplies ayrımları
  cross-check edildi; EsnaftaVar ağacına doğrudan kopyalanmadı.
- [n11 — Ev & Yaşam](https://www.n11.com/ev-yasam): mobilya, ev tekstili,
  dekorasyon/aydınlatma ve banyo/ev gereçleri yerel intent sinyalleri incelendi.
  Aynı menüdeki mutfak, yapı/bahçe, kırtasiye ve supermarket komşulukları özellikle
  canonical L1 sınırı sayılmadı.
- [Amazon Türkiye — tüm kategoriler](https://www.amazon.com.tr/b?node=26248552031):
  Ev & Yaşam, Mutfak, Sağlık/Temizlik ve Yapı Market'in ayrı üst müşteri girişleri
  cross-check edildi.
- [Amazon Türkiye — satılabilen ürünler](https://satis.amazon.com.tr/satis): mobilya,
  dekorasyon, banyo, züccaciye ve ev aksesuarı seller kapsamları incelendi.
- [Trendyol](https://www.trendyol.com/): mobilya, banyo, ev dekorasyon, halı/perde ve
  temizlik arama terimleri discovery sinyali olarak gözden geçirildi.
- [Ticaret Bakanlığı — Tekstil Ürünleri](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/tekstil-urunleri):
  çarşaf/havlu/döşemelik dahil elyaf kompozisyonu ile etiket gereksinimleri category
  yerine product-policy/attribute katmanına yön verdi.
- [Ticaret Bakanlığı — piyasa gözetimi](https://ticaret.gov.tr/haberler/ticaret-bakanligi-tarafindan-2024-yilinin-ilk-yarisinda-gerceklestirilen-piyasa-gozetimi-ve-denetimi-faaliyetleri):
  mobilya, tekstil ve deterjan gibi ev ürünlerindeki kimyasal/fiziksel/mekanik riskler
  policy notları için authoritative sinyal olarak kullanıldı.

**SOURCE LIMITATION:** Trendyol, n11 ve Amazon'un dinamik merchandising ağacı aynı
derinlikte eksiksiz statik export sağlamadı. Görünen product-family terimleri
triangulation için kullanıldı; commercial placement canonical ownership sayılmadı.
Hepsiburada'nın güncel public full-tree export'u doğrulanamadı; öneri ona dayanmaz.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 10.**

Bu sayı; müşterinin gerçek ürün ailesi niyetlerini görünür kılarken oda/stil/material
tabanlı çoğaltmayı önler. Mutfak, bahçe, yapı/tesisat ve appliance leakage'i L2 sayısı
arttırılarak kapatılmamış, açık cross-domain rule ile çözülmüştür.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | Mobilya | Oturma, çalışma, yemek, depolama veya uyuma için furniture bulmak |
| 2 | Yatak & Uyku Ürünleri | Yatak, yastık ve uyku desteği ürünü bulmak |
| 3 | Ev Tekstili | Yatak/banyo/yaşam alanı için esnek textile ürün bulmak |
| 4 | Perde & Pencere Tekstili | Pencereyi örtme/gölgeleme amaçlı textile bulmak |
| 5 | Halı, Kilim & Paspas | Zemini örten taşınabilir textile/surface ürünü bulmak |
| 6 | Dekorasyon & Duvar Aksesuarları | Mekânı görsel olarak tamamlayan dekor ürünü bulmak |
| 7 | Aydınlatma | Taşınabilir/dekoratif aydınlatma ürünü bulmak |
| 8 | Düzenleme & Saklama | Ev eşyasını düzenleyen, gıda dışı saklama ürünü bulmak |
| 9 | Banyo Aksesuarları | Sabit tesisat olmayan banyo kullanım ürünü bulmak |
| 10 | Ev Temizliği & Çamaşır Bakımı | Elektrikli olmayan temizlik, deterjan ve çamaşır bakım ürünü bulmak |

Normalized duplicate: **0**. Ad ve sıra owner approval'a kadar öneridir.

## 6. Why this granularity

- Mobilya ile mattress/pillow gibi uyku destek ürünleri farklı ölçü, firmness,
  taşıma ve ürün güvenliği şeması nedeniyle ayrılmıştır.
- Ev tekstili şişirilmemiş; güçlü ölçü/montaj/arama şeması olan perde ile zemin
  kaplayan halı/kilim ayrı L2 olmuştur.
- Dekorasyon ve aydınlatma ayrı teknik attribute/policy gerektirir. Sabit elektrik
  tesisatı ve smart endpoint bu L2'ye alınmamıştır.
- Düzenleme/saklama, mobilya olmayan organizer/storage ürünlerini taşır. Gıda ile
  temas eden mutfak saklama ürünü Züccaciye & Mutfak'ta kalır.
- Temizlik gereci ve consumable aynı household task intent'inde toplanır; elektrikli
  temizlik cihazı appliance ownership'ini korur.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| Mobilya | koltuk, kanepe, masa, sandalye, dolap, kitaplık, baza, karyola, sehpa |
| Yatak & Uyku Ürünleri | yatak/mattress, yastık, alez, yatak pedi/topper, uyku destek ürünü |
| Ev Tekstili | nevresim, çarşaf, battaniye, pike, yatak örtüsü, havlu, bornoz, koltuk örtüsü |
| Perde & Pencere Tekstili | tül/fon/stor perde, blackout perde, perde aksesuarı textile seti |
| Halı, Kilim & Paspas | halı, kilim, yolluk, kapı/banyo paspası, taşınabilir zemin örtüsü |
| Dekorasyon & Duvar Aksesuarları | vazo, biblo, çerçeve, poster/tablo, dekoratif ayna, duvar saati, mumluk |
| Aydınlatma | masa lambası, lambader, avize, abajur ve non-smart consumer luminaire |
| Düzenleme & Saklama | giyim/çekmece organizer, vakumlu hurç, ayakkabı düzenleyici, genel storage box |
| Banyo Aksesuarları | sabunluk, diş fırçalık, duş rafı, çöp kovası, klozet fırçası, havluluk aksesuarı |
| Ev Temizliği & Çamaşır Bakımı | deterjan, yüzey temizleyici, süpürge/fırça/paspas, kova, bez, ütü masası, kurutmalık |

## 8. Exclusions

- Pişirme, hazırlama, servis ve gıda saklama ürünü: **Züccaciye & Mutfak**.
- Buzdolabı, süpürge, ütü, hava temizleyici ve diğer elektrikli cihaz: **Beyaz Eşya
  & Ev Aletleri**.
- Batarya/musluk/lavabo/duş seti, boru, sabit montaj, boya, yapıştırıcı, electrical
  installation: **Yapı, Hırdavat & Tesisat**.
- Smart bulb, connected lock/sensor/camera: owner-final **Elektronik → Akıllı Ev &
  Güvenlik**.
- Canlı bitki, saksı, bahçe mobilyası/aletleri: **Çiçek & Bahçe** sınır review'ü.
- Ofis kırtasiyesi ve computer desk electronics kendi L1'lerinde kalır.
- Taşınma, iç mimari, temizlik, montaj, tadilat ve kiralama hizmetleri kapsam dışıdır.
- Room/style/brand/season/ranking/featured gibi merchandising grupları L2 değildir.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Ev & Yaşam ↔ Züccaciye & Mutfak | Gıda hazırlama/servis/temas/saklama ana işleviyse Züccaciye; genel ev organizer'ı burada. |
| Ev & Yaşam ↔ Yapı/Hırdavat | Taşınabilir ev ürünü burada; binaya sabitlenen tesisat, yapı malzemesi ve tool ilgili L1'de. |
| Ev & Yaşam ↔ Beyaz Eşya & Ev Aletleri | Pasif/non-electric gereç burada; elektrik/pil ile ana household function sağlayan appliance kendi L1'inde. |
| Ev & Yaşam ↔ Elektronik | Normal luminaire burada; connected smart-home endpoint Elektronik'te. Sadece LED içermesi smart yapmaz. |
| Ev & Yaşam ↔ Çiçek & Bahçe | Indoor decorative empty vase burada; canlı/cut flower, growing container ve gardening ürünleri Çiçek & Bahçe review'ünde. |
| Ev & Yaşam ↔ Kırtasiye & Ofis | Ev mobilyası burada; ofis consumable/stationery kendi L1'inde. Home-office kullanımı tek başına ownership taşımaz. |
| Ev & Yaşam ↔ Sağlık & Medikal | Normal mattress/pillow burada; açık medikal cihaz/ortez/tedavi ürünü Sağlık & Medikal policy review'ünde. `Ortopedik` pazarlama sözü tek başına taşımaz. |

## 10. Category vs facet decisions

| Category değildir | Facet/policy hint |
|---|---|
| Oda | salon, yatak odası, çocuk odası, banyo, antre, home office |
| Stil | modern, klasik, İskandinav, bohem, rustik, minimal |
| Materyal | ahşap, metal, cam, pamuk, yün, polyester, seramik |
| Ölçü | en/boy/yükseklik, yatak ölçüsü, perde ölçüsü, halı ebadı |
| Renk/desen | renk ailesi, motif, texture, finish |
| Montaj | assembled/flat-pack, duvara montaj, taşıma kapasitesi |
| Claim | ortopedik, antibakteriyel, leke tutmaz, alev geciktirici; evidence gerekir |
| Ticari | marka, fiyat, stok, indirim, trend, featured, nearby |

## 11. Search synonyms

| L2 | Controlled search/synonym hints |
|---|---|
| Mobilya | furniture, ev eşyası, koltuk, masa, dolap |
| Yatak & Uyku Ürünleri | mattress, yatak, yastık, uyku ürünü, topper |
| Ev Tekstili | home textile, nevresim, çarşaf, havlu, battaniye |
| Perde & Pencere Tekstili | curtain, tül, fon, stor, blackout |
| Halı, Kilim & Paspas | carpet, rug, yolluk, paspas |
| Dekorasyon & Duvar Aksesuarları | ev dekoru, dekor, duvar süsü, tablo, ayna |
| Aydınlatma | lighting, lamba, avize, lambader, abajur |
| Düzenleme & Saklama | organizer, hurç, düzenleyici, storage box |
| Banyo Aksesuarları | bathroom accessory, sabunluk, duş rafı |
| Ev Temizliği & Çamaşır Bakımı | temizlik malzemesi, deterjan, mop, laundry care |

`Yatak` sözcüğü bed-frame ve mattress anlamına gelebilir; product form/attribute ile
Mobilya veya Yatak & Uyku'ya disambiguate edilir.

## 12. Policy/compliance notes

- Mobilyada taşıma kapasitesi, devrilme/ankraj, çocuk erişimi, malzeme ve assembly
  talimatı typed safety data olmalıdır.
- Tekstil ürünlerinde elyaf kompozisyonu ve gerekli işaretleme doğrulanmalıdır.
- Deterjan/kimyasal temizlik ürünlerinde hazard, kullanım/uyarı, çocuk güvenliği ve
  uygun ambalaj policy katmanıdır; category güvenlik onayı anlamına gelmez.
- Elektrikli aydınlatma ürününde applicable electrical safety/energy data category'den
  ayrı doğrulanır; sabit installation requirement açıkça gösterilmelidir.
- `Ortopedik`, `antibakteriyel`, `hipoalerjenik`, `alev geciktirici` ve sustainability
  iddiaları evidence olmadan synonym/filtre olarak sunulmamalıdır.

## 13. Ambiguous products

| Ürün | Proposed primary placement / rule |
|---|---|
| Baza/karyola | Mobilya; mattress Yatak & Uyku |
| Yastık | Yatak & Uyku; dekoratif kırlent Dekorasyon veya future textile leaf review |
| Alez/yatak pedi | Yatak & Uyku; nevresim/çarşaf Ev Tekstili |
| Banyo havlusu | Ev Tekstili; sabunluk/duş rafı Banyo Aksesuarları |
| Banyo paspası | Halı, Kilim & Paspas; oda facet'i banyo |
| Mutfak dolabı | Furniture SKU ise Mobilya; sabit yapı/proje/installation product-service boundary review |
| Erzak kavanozu | Gıda temas/saklama ana işleviyle Züccaciye & Mutfak |
| Genel plastik saklama kutusu | Düzenleme & Saklama; food-contact claim yoksa burada |
| Avize | Aydınlatma; fixed wiring component/anahtar/kablo Yapı/Hırdavat |
| Smart ampul | Elektronik → Akıllı Ev & Güvenlik; normal ampul/luminaire owner L3 boundary review |
| Dekoratif saksı | Yetiştirme kabı ise Çiçek & Bahçe; yalnız dekoratif obje ise Dekorasyon review |
| Robot süpürge | Beyaz Eşya & Ev Aletleri; temizlik intent'i category ownership'i değiştirmez |
| Ütü masası | Ev Temizliği & Çamaşır Bakımı; elektrikli ütü appliance |

Karar sırası: ana fiziksel işlev → fixed/portable → elektrikli/connected → food-contact
→ policy/attribute schema → tek owner leaf. Çözülmeyen SKU duplicate edilmez.

## 14. Future L3/L4 examples

Yalnız feasibility örnekleridir; full tree ve final node değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| Mobilya | Oturma Mobilyaları → Koltuk | Oda/style/material facet'tir. |
| Yatak & Uyku Ürünleri | Yataklar → Yaylı Yatak | Ölçü/sertlik facet'tir; medical claim değildir. |
| Ev Tekstili | Yatak Tekstili → Nevresim Takımı | Renk/desen/ölçü facet'tir. |
| Dekorasyon & Duvar Aksesuarları | Duvar Dekoru → Tablo & Poster | Sanatçı/tema category şişirmez. |
| Düzenleme & Saklama | Giyim Düzenleme → Hurç | Oda facet olabilir. |
| Ev Temizliği & Çamaşır Bakımı | Temizlik Gereçleri → Mop & Paspas Sistemleri | Motorlu cihaz bu child'a girmez. |

## 15. Open owner decisions

1. **10 L2 exact adı ve sırası** kabul/ret/revise edilmelidir.
2. **Normal ampul/luminaire ↔ fixed electrical:** exact Aydınlatma/Yapı boundary'si
   L3 pilotu ve gerçek SKU örnekleriyle finalleştirilmelidir; smart bulb Elektronik'te
   owner-final olarak kalır.
3. **Bahçe mobilyası/dekoratif saksı:** Ev & Yaşam ile Çiçek & Bahçe arasındaki
   product-intent kuralı o domain tasarımıyla birlikte owner-final yapılmalıdır.
4. **Mutfak/banyo dolabı ve sabit mobilya:** standalone product ile ölçüye özel
   installation/service ayrımı açık policy gerektirir.
5. **Temizlik kimyasalları:** Ev & Yaşam ownership önerisi, gelecekteki safety/claim
   policy sahibi tarafından onaylanmalıdır.

Bu kararlar açıkken agent canonical/runtime karar üretemez.

## 16. Validation summary

- Canonical L1 **Ev & Yaşam**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 / duplicate: **10 / 0**
- Kitchen/Hardware/Appliance/Smart-home leakage guards: **PASS**
- Room/style/material/brand as category: **0**
- Product/Merchant/Service separation: **PASS**
- Full L3/L4 tree: **NOT PRODUCED**
- Flutter/Figma/JSON/DB/runtime/remote changes: **NONE**

`HOME_LIVING_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`HOME_LIVING_L2_COUNT: 10`

`OWNER_APPROVAL: OPEN`
