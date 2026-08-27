# EsnaftaVar Gıda & İçecek L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: canonical Product Taxonomy içindeki final L1 **Gıda & İçecek**
- Bu belge yalnız L2 omurgası önerir; owner approval, stable ID, slug, sort order,
  L3/L4 full tree, facet schema, runtime veya veri değişikliği değildir.
- Canonical 24 L1, Product/Merchant/Facet ayrımı ve mevcut owner-final Elektronik ile
  Bilgisayar & Tablet kararları aynen korunur.

## 2. Scope

Amaç, müşterinin yakındaki esnafta fiziksel gıda ürününü ürün ailesi üzerinden
bulmasını; merchant'ın da her SKU'yu tam bir primary leaf'e yerleştirebilmesini
sağlayacak L2 omurgasını önermektir. Restoran/yemek teslimatı, hizmet, dijital ürün,
merchant sektörü, kampanya ve teslimat yöntemi Product Taxonomy kapsamı değildir.

Bu öneri taze, soğuk zincirli, ambient, donuk ve paketli fiziksel ürünleri kapsar.
Bir ürün tam olarak bir primary category yolu kullanır; beslenme tercihi, içerik,
menşe, marka, paket ölçüsü ve saklama koşulu facet/policy verisidir.

## 3. Sources reviewed

Erişim tarihi **2026-08-28** olan araştırma kaynakları:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek Google category değeri, ID/full-path kullanımı ve sürekli gelişen
  harici taxonomy sinyali incelendi. Google ağacı EsnaftaVar'a kopyalanmadı.
- [Google Product Taxonomy — Türkçe düz metin](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  food/beverage product-type ayrımları cross-check için kullanıldı.
- [Amazon Türkiye — satılabilen ürün ve kategoriler](https://satis.amazon.com.tr/satis):
  içecek, çay/kahve, atıştırmalık, bakliyat/makarna, konserve, sos/salça,
  yağ/sirke, kuruyemiş, baharat ve pastacılık kümeleri incelendi.
- [n11 — Gıda & Şekerleme](https://www.n11.com/supermarket/gida-ve-sekerleme):
  kahvaltılık, atıştırmalık, bakliyat, sos, kuruyemiş, baharat, deniz ürünü,
  unlu mamul, hazır ve donuk gıda yerel discovery sinyalleri incelendi.
- [n11 — Süpermarket](https://www.n11.com/supermarket): taze meyve-sebze, içecek,
  yağ ve market komşulukları cross-check edildi.
- [Trendyol](https://www.trendyol.com/): güncel ana sayfadaki gıda/içecek arama ve
  discovery terimleri yalnız yerel synonym/intent sinyali olarak incelendi.
- [Tarım ve Orman Bakanlığı — Gıda Kodeksi ve Yem Mevzuatı](https://www.tarimorman.gov.tr/GKGM/Menu/129/Gida-Kodeks-Ve-Yem-Mevzuati-Daire-Baskanligi):
  etiketleme, tüketiciyi bilgilendirme, katkı ve beslenme beyanı katmanlarının
  category'den ayrı tutulması için authoritative policy kaynağı olarak incelendi.
- [Türk Gıda Kodeksi gıda kategorileri kılavuzu](https://www.tarimorman.gov.tr/GKGM/Belgeler/DB_Gida_Isletmeleri/TGK_Gida_Katki_Maddeleri_Yonetmeligi_Gida_Kategorileri_Kilavuzu.pdf):
  yasal ürün sınıflarının merchant-facing shopping taxonomy ile aynı şey olmadığı,
  fakat süt/et/işlenmiş ürün sınırlarının policy validation'a girdi verdiği görüldü.
- [Tütün mamulleri ve alkollü içkilerin satış/sunum yönetmeliği](https://www.tarimorman.gov.tr/TADAB/Belgeler/Y%C3%B6netmelikler/yonetmelik_27808_07.01.2011.pdf):
  yaş/kanal/ruhsat/reklam riskleri nedeniyle alkol ve tütünün V1'e sessizce
  eklenemeyeceği doğrulandı.

**SOURCE LIMITATION:** Trendyol'un tam seller category ağacı ile bazı dinamik
pazaryeri menüleri crawler'a kararlı ve eksiksiz bir hierarchy vermedi. Görünen
terimler directional signal olarak kullanıldı; görünmeyen dal veya sıralama hakkında
iddia kurulmadı. Hepsiburada'nın güncel tam kategori ağacı public, statik ve güvenilir
bir kaynak olarak doğrulanamadığı için öneri ona bağımlı değildir.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 14.**

Bu sayı üst öneri bandındadır; gıda alanında taze/soğuk/donuk saklama, ürün bazlı
allergen/etiket şeması ve güçlü yerel alışveriş niyetleri gerçek ayrım üretir. L2'ler
marka, diyet, öğün, hedef kitle veya kampanyaya göre şişirilmemiştir.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | Taze Meyve & Sebze | Taze bitkisel gıda bulmak |
| 2 | Et, Tavuk, Balık & Şarküteri | Taze/işlenmiş hayvansal ana ürün bulmak |
| 3 | Süt Ürünleri & Yumurta | Süt türevi veya yumurta ürünü bulmak |
| 4 | Ekmek, Unlu Mamuller & Pastacılık | Hazır ekmek, hamur işi veya pastane ürünü bulmak |
| 5 | Bakliyat, Tahıl & Makarna | Kuru bakliyat, tahıl, pirinç veya makarna bulmak |
| 6 | Un, Şeker & Pişirme Malzemeleri | Evde pişirme/pastacılık için temel ingredient bulmak |
| 7 | Yağ & Sirke | Yemeklik yağ veya sirke bulmak |
| 8 | Kahvaltılık | Bal, reçel, ezme, zeytin veya kahvaltılık gevrek bulmak |
| 9 | Atıştırmalık, Şekerleme & Kuruyemiş | Doğrudan tüketilen snack/tatlı/kuruyemiş bulmak |
| 10 | Alkolsüz İçecekler | Çay/kahve dahil alkolsüz içecek veya hazırlama ürünü bulmak |
| 11 | Sos, Baharat & Çeşni | Yemeğe tat/aroma veren sos veya çeşni bulmak |
| 12 | Konserve & Kavanoz Ürünleri | Isıl işlemli/korunmuş konserve-kavanoz ürünü bulmak |
| 13 | Hazır & Pratik Gıda | Paketli, hızlı hazırlanan fiziksel gıda bulmak |
| 14 | Donuk Gıda | Donmuş muhafaza edilen fiziksel gıda bulmak |

Normalized duplicate: **0**. L2 adları öneridir; owner approval olmadan canonical
kimlik, sıra veya runtime route değildir.

## 6. Why this granularity

- Taze, soğuk zincir, donuk ve ambient ürünler aynı merchant operasyonuna zorla
  sıkıştırılmadı.
- Bakliyat/tahıl/makarna; un/şeker/pişirme; yağ/sirke arasında güçlü ürün tipi ve
  facet farkı bulunduğu için belirsiz bir `Temel Gıda` catch-all'ı kullanılmadı.
- Kahvaltılık, Türkiye'deki fiziksel market ve pazaryeri keşfinde güçlü bir shopping
  intent'tir; ancak peynir/yumurta gibi açık ürün tiplerini ikinci kez sahiplenmez.
- Konserve ile hızlı hazırlanan paketli gıda ayrıldı: muhafaza yöntemi ve merchant
  şeması farklıdır. Donuk ürün ayrıca cold-chain enforcement gerektirir.
- On dört L2, ileride doğal L3 gerektiğinde açılabilir; her L2'nin zorunlu L3'ü yoktur.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| Taze Meyve & Sebze | taze meyve, sebze, mantar, taze ot |
| Et, Tavuk, Balık & Şarküteri | kırmızı et, kanatlı, balık/deniz ürünü, sucuk, salam, pastırma |
| Süt Ürünleri & Yumurta | süt, yoğurt, ayran, kefir, peynir, tereyağı, krema, yumurta |
| Ekmek, Unlu Mamuller & Pastacılık | ekmek, simit, poğaça, börek, hazır pasta/tatlı, paketli unlu mamul |
| Bakliyat, Tahıl & Makarna | mercimek, fasulye, nohut, pirinç, bulgur, yulaf, makarna |
| Un, Şeker & Pişirme Malzemeleri | un, şeker, kabartma ürünü, maya, kakao, pasta süsleme ingredient'i |
| Yağ & Sirke | zeytinyağı, ayçiçek yağı, diğer yemeklik yağ, üzüm/elma sirke |
| Kahvaltılık | bal, reçel, pekmez, tahin, fındık/fıstık ezmesi, zeytin, gevrek, granola |
| Atıştırmalık, Şekerleme & Kuruyemiş | çikolata, şeker, bisküvi, cips, bar, kuruyemiş, kuru meyve |
| Alkolsüz İçecekler | su, gazlı/gazsız içecek, meyve suyu, çay, kahve, bitki çayı, içecek tozu |
| Sos, Baharat & Çeşni | salça, ketçap, mayonez, yemek sosu, baharat, tuz, seasoning mix |
| Konserve & Kavanoz Ürünleri | sebze/balık/et konservesi, turşu, kavanozda korunmuş ürün |
| Hazır & Pratik Gıda | hazır çorba, noodle, paketli hazır yemek, instant meal |
| Donuk Gıda | donuk sebze/meyve, pizza, mantı, patates, donuk et/balık ve hamur ürünü |

## 8. Exclusions

- Restoran yemeği, catering, paket servis, rezervasyon ve yemek hazırlama hizmeti.
- Alkollü içecek ve tütün ürünü: owner/policy/legal gate olmadan V1'e eklenmez.
- Takviye edici gıda, vitamin/mineral ve medikal beslenme: **Sağlık & Medikal**
  policy review alanı.
- Bebek maması ve bebek beslenme ürünü: **Anne & Bebek** ownership review alanı.
- Evcil hayvan maması: **Evcil Hayvan Ürünleri**.
- Mutfak kabı/servis ekipmanı: **Züccaciye & Mutfak**.
- Kahve makinesi, blender, tost makinesi: **Beyaz Eşya & Ev Aletleri**.
- Tohum/fide/canlı bitki: **Çiçek & Bahçe**; yenilebilir hasat ürünü Gıda'dır.
- Marka, yöre, helal, vegan, organik, glutensiz, şekersiz ve kampanya category değildir.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Gıda ↔ Sağlık & Medikal | Normal yiyecek/içecek burada; supplement/medikal amaçlı ingestible ayrı policy ownership'e gider. Sağlık beyanı tek başına category taşımaz. |
| Gıda ↔ Anne & Bebek | Bebek maması/formül ve yaşa özel beslenme Anne & Bebek review'ündedir; aile tüketimine yönelik normal gıda hedef yaş facet'iyle burada kalır. |
| Gıda ↔ Evcil Hayvan | İnsan tüketimi burada; pet food her durumda Evcil Hayvan Ürünleri. |
| Gıda ↔ Züccaciye & Mutfak | Tüketilebilir ürün burada; kap, saklama kutusu, fincan ve pişirme gereci Züccaciye'de. |
| Gıda ↔ Beyaz Eşya & Ev Aletleri | Çay/kahve fiziksel consumable burada; demleme/pişirme cihazı appliance alanında. |
| Gıda ↔ Çiçek & Bahçe | Taze yenilebilir ürün burada; yetiştirme amacıyla satılan tohum/fide/bitki Çiçek & Bahçe'de. |
| Gıda ↔ Hediyelik & Parti | Çikolata/şekerleme ürün tipine göre burada kalır; hediye paketi veya parti malzemesi category taşımaz. Bundle principal product rule ile atanır. |

## 10. Category vs facet decisions

| Category değildir | Facet/policy olarak tutulması gereken örnekler |
|---|---|
| Diyet/tercih | vegan, vejetaryen, glutensiz, laktozsuz, keto, şekersiz |
| Sertifika/beyan | organik, coğrafi işaret, helal, katkısız; doğrulanmış evidence gerektirir |
| İçerik | allergen, ingredient, kakao oranı, yağ/protein oranı, aroma |
| Ambalaj | net miktar, adet, paket tipi, çoklu paket |
| Saklama | ambient, soğuk, donuk; temperature/cold-chain capability |
| Menşe | ülke, il/yöre, üretici; category node değildir |
| Kullanım | kahvaltı, spor öncesi, çocuk tüketimi; açık ürün tipi ownership'ini bozmaz |
| Ticari sinyal | marka, fiyat, indirim, featured, nearby, stok |

## 11. Search synonyms

| Canonical öneri | Controlled search/synonym hints |
|---|---|
| Taze Meyve & Sebze | manav, meyve sebze, yeşillik |
| Et, Tavuk, Balık & Şarküteri | kasap, et ürünleri, deniz mahsulü, şarküteri |
| Süt Ürünleri & Yumurta | mandıra, süt mamulleri, peynir, yoğurt |
| Ekmek, Unlu Mamuller & Pastacılık | fırın, pastane, hamur işi, bakery |
| Bakliyat, Tahıl & Makarna | kuru gıda, bakliyat, hububat, pasta noodle bağlama göre disambiguate edilir |
| Un, Şeker & Pişirme Malzemeleri | pastacılık malzemesi, baking ingredients |
| Yağ & Sirke | yemeklik yağ, zeytinyağı, vinegar |
| Kahvaltılık | kahvaltı, bal reçel, gevrek, cereal |
| Atıştırmalık, Şekerleme & Kuruyemiş | snack, çerez, çikolata, tatlı atıştırmalık |
| Alkolsüz İçecekler | meşrubat, soft drink, çay kahve |
| Sos, Baharat & Çeşni | seasoning, spice, salça, yemek sosu |
| Konserve & Kavanoz Ürünleri | canned food, turşu, kavanoz ürün |
| Hazır & Pratik Gıda | instant, hazır yemek, hızlı yemek |
| Donuk Gıda | dondurulmuş, frozen, buzluk ürünü |

Synonym, ownership'i değiştirmez. `Pasta` sözcüğü Türkçede cake ve bazı yabancı
dillerde makarna anlamına geldiği için title/context ile disambiguate edilmelidir.

## 12. Policy/compliance notes

- Etiket, allergen, ingredient, net miktar, son tüketim/tavsiye edilen tüketim ve
  saklama verisi category tree dışında typed policy alanları gerektirir.
- `Organik`, `glutensiz`, `şekersiz`, hastalık/tedavi ve beslenme/sağlık beyanları
  serbest metin synonym değil; doğrulama ve mevzuat kontrolü gerektirir.
- Soğuk/donuk ürünün category'si delivery veya stok güvenliği sağlamaz. Merchant
  capability, sıcaklık zinciri ve availability ayrı release gate olmalıdır.
- Alkol/tütün için V1 node önerilmez. Gelecekte yalnız açık owner kararı, yaş kontrolü,
  ruhsat, görünürlük/reklam ve yerel kanal hukuku tasarımıyla değerlendirilebilir.
- Ağırlıkla satılan ürünlerde ölçü birimi ve fiyatlandırma category değil listing
  contract'ıdır; yanlış birim karşılaştırmasına izin verilmemelidir.

## 13. Ambiguous products

| Ürün | Proposed primary placement / decision rule |
|---|---|
| Granola / kahvaltılık gevrek | Kahvaltılık; bar formu doğrudan snack olarak pazarlanıyorsa Atıştırmalık |
| Tereyağı | Süt Ürünleri & Yumurta; `Yağ & Sirke`ye duplicate edilmez |
| Zeytin | Kahvaltılık; yağ için işlenen zeytinyağı Yağ & Sirke |
| Tuz | Sos, Baharat & Çeşni; bulk ingredient kullanımı duplicate category üretmez |
| Kakao | Ham/pişirme ingredient'i ise Un, Şeker & Pişirme; içecek karışımı ise Alkolsüz İçecekler |
| Dondurma | Donuk Gıda; süt içeriyor diye Süt Ürünleri'ne duplicate edilmez |
| Donuk börek/pizza | Donuk Gıda; saklama/merchant schema baskın |
| Kavanoz domates sosu | Hazır yemek değilse Sos; preserved whole/chunk vegetable ise Konserve & Kavanoz |
| Protein bar | Normal food SKU ise Atıştırmalık; supplement/tedavi beyanı varsa Sağlık policy review |
| Bitki çayı | Alkolsüz İçecekler; tıbbi/tedavi iddiası ayrıca policy review gerektirir |
| Bebek bisküvisi/formül | Anne & Bebek ownership review; Gıda'ya sessizce atanmaz |
| Hediye sepeti | Tek dominant ürün varsa principal leaf; heterojen bundle category değildir ve manual review gerekir |

Adjudication sırası: ana ürün tipi → merchant attribute/policy şeması → saklama
gereksinimi → cross-domain owner → tek primary leaf. Çözülemeyen ürün duplicate
edilmez; taxonomy review kuyruğuna alınır.

## 14. Future L3/L4 examples

Aşağıdakiler yalnız feasibility örneğidir; full tree veya final node değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| Et, Tavuk, Balık & Şarküteri | Et Ürünleri → Kırmızı Et | Kesim/gramaj/menşe facet'tir. |
| Süt Ürünleri & Yumurta | Peynir → Beyaz Peynir | Yağ oranı, süt türü ve yöre facet'tir. |
| Bakliyat, Tahıl & Makarna | Bakliyat → Mercimek | Kırmızı/yeşil gerçekten ayrı merchant schema gerektirmiyorsa facet kalır. |
| Alkolsüz İçecekler | Sıcak İçecekler → Kahve | Kavurma/öğütme/menşe facet'tir. |
| Atıştırmalık, Şekerleme & Kuruyemiş | Şekerleme → Çikolata | Kakao oranı ve dolgu facet'tir. |
| Donuk Gıda | Donuk Hamur Ürünleri | Doğal leaf L3'teyse yapay L4 açılmaz. |

## 15. Open owner decisions

1. **14 L2'nin exact adı ve sırası** owner tarafından kabul/ret/revise edilmelidir.
2. **Bebek gıdası/formül ownership'i:** öneri Anne & Bebek yönündedir; o domain
   tasarımıyla birlikte finalleştirilmelidir.
3. **Normal food ↔ supplement/medikal beslenme sınırı:** claim ve mevzuat policy
   contract'ı tanımlanana kadar şüpheli ürünler unassigned review'da kalmalıdır.
4. **Alkol:** V1 dışı kalma önerisi owner/policy tarafından açıkça onaylanmalıdır;
   sessiz L2 eklenmemelidir.
5. **Hazır & Pratik Gıda ile Konserve sınırı:** önerilen product-form kuralı L3 pilot
   örnekleri üzerinde owner tarafından challenge edilmelidir.

Bu maddeler açıkken agent `FINAL`, canonical ID veya runtime mapping üretemez.

## 16. Validation summary

- Canonical L1 adı **Gıda & İçecek**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 count: **14**
- Exact list item count / normalized duplicate: **14 / 0**
- Brand-as-category / commercial collection: **0 / 0**
- Diet, ingredient, package and cold-chain facets separated: **PASS**
- Product/Merchant/Service separation: **PASS**
- Cross-domain ownership rules: **PASS — owner decisions explicitly open**
- Alcohol/tobacco silently activated: **NO**
- Full L3/L4 tree produced: **NO**
- Flutter/Figma/JSON/DB/runtime/remote change: **NONE**

`FOOD_BEVERAGE_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`FOOD_BEVERAGE_L2_COUNT: 14`

`OWNER_APPROVAL: OPEN`
