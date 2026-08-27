# EsnaftaVar Giyim & Moda L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: canonical Product Taxonomy içindeki final L1 **Giyim & Moda**
- Bu belge yalnız L2 omurgasıdır. Owner-final karar, stable identity, slug/sort,
  eksiksiz L3/L4, facet schema, merchant taxonomy veya runtime mapping değildir.
- Canonical 24 L1, exactly-one-primary-leaf ve Product/Merchant/Facet ayrımı korunur.

## 2. Scope

Fiziksel giyim ürünlerini müşterinin aradığı ürün formuna göre sınıflandıran, kadın/
erkek/çocuk ağaçlarını çoğaltmayan ve yerel moda aramalarını facet/search katmanında
koruyan L2 omurgası önerilir. Ayakkabı, çanta, takı, gözlük ve ayrı fiziksel aksesuar
L1'leri bu ağaca çekilmez.

Bir SKU yalnız bir primary category yolu kullanır. Cinsiyet hedefi, yaş grubu, beden,
renk, materyal, kesim, desen, sezon, marka, kullanım anı ve modest/tesettür stili
category yerine typed facet veya kontrollü discovery sinyalidir.

## 3. Sources reviewed

Erişim tarihi **2026-08-28**:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek harici category ve tam path/ID sözleşmesi incelendi.
- [Google Product Taxonomy — Türkçe](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  clothing product form, underwear, sleepwear, outerwear ve uniform ayrımları
  cross-check edildi; ağacın kendisi kopyalanmadı.
- [Amazon Türkiye — satılabilen ürün ve kategoriler](https://satis.amazon.com.tr/satis):
  kıyafet, elbise, spor giyim ve iç çamaşırı local seller kapsamı incelendi.
- [Amazon TR Apparel Style Guide](https://m.media-amazon.com/images/G/41/rainier/help/Amazon_TR_Apparel_StyleGuide.pdf):
  apparel listing'de ürün türü ile diğer niteliklerin ayrımı için seller-side sinyal
  olarak incelendi.
- [Trendyol — güncel ana discovery](https://www.trendyol.com/): kadın/erkek üst-alt,
  elbise, iç giyim, dış giyim ve çocuk giyim terimleri search-intent cross-check'idir.
- [Trendyol — Tesettür Giyim](https://www.trendyol.com/tesettur-giyim-x-c81):
  güçlü yerel modest-fashion intent'i ve alt ürün formlarının birbiriyle çakışma
  riski birlikte incelendi.
- [n11](https://www.n11.com/): giyim/ayakkabı, moda ve yerel discovery grupları
  directional source olarak kullanıldı.
- [Ticaret Bakanlığı — Tekstil Ürünleri](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/tekstil-urunleri):
  elyaf kompozisyonu, kalıcı/okunabilir etiketleme ve dağıtıcı sorumluluğunun
  category değil product-policy/attribute gereksinimi olduğu doğrulandı.
- [Ticaret Bakanlığı — Ürün Güvenliği](https://www.ticaret.gov.tr/tuketici/piyasa-gozetimi/urun-guvenligi):
  çocuk/bebek giyim dahil textile safety kapsamı policy notlarında kullanıldı.

**SOURCE LIMITATION:** Trendyol ve n11'in tüm seller category ağacı public statik
bir export olarak doğrulanamadı; dinamik sayfalarda görülen adlar yalnız intent sinyali
olarak kullanıldı. Hepsiburada'nın güncel ve eksiksiz public kategori export'u
doğrulanamadığı için öneri ona bağımlı değildir. Marketplace merchandising ayrımı
canonical EsnaftaVar ownership kararı sayılmadı.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 10.**

Bu omurga ürün formu ve farklı merchant attribute profili üreten ayrımları korur;
cinsiyet/yaş/stil başına paralel ağaç açmaz. Çok geniş `Kadın Giyim`, `Erkek Giyim`
ve `Çocuk Giyim` dalları reddedilerek duplicate leaf riski azaltılır.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | Üst Giyim | Üst bedene giyilen günlük ana parça bulmak |
| 2 | Alt Giyim | Alt bedene giyilen ana parça bulmak |
| 3 | Elbise & Tulum | Tek parça gövde giyimi bulmak |
| 4 | Takım & Kombinler | Birlikte satılan koordineli giyim seti bulmak |
| 5 | Dış Giyim | Hava/katman koruması sağlayan dış parça bulmak |
| 6 | İç Giyim | Tenle doğrudan ilişkili iç katman ürünü bulmak |
| 7 | Ev & Uyku Giyimi | Evde dinlenme veya uyku için giyim bulmak |
| 8 | Spor & Performans Giyimi | Fiziksel aktivite için tasarlanmış teknik giyim bulmak |
| 9 | Mayo & Plaj Giyimi | Yüzme/plaj kullanımına özgü giyim bulmak |
| 10 | İş Giyimi & Üniforma | Mesleki görev veya kurumsal standart için giyim bulmak |

Normalized duplicate: **0**. Exact ad/sıra owner approval'a kadar öneridir.

## 6. Why this granularity

- Product-form spine, aynı tişörtü kadın/erkek/çocuk/tesettür/büyük beden altında
  çoğaltmaz; bunları filtre ve search intent olarak korur.
- İç giyim, uyku/ev giyimi, yüzme ve performans giyim farklı fit/material/safety
  attribute profilleri oluşturduğu için ayrı L2'dir.
- `Takım & Kombinler`, gerçekten tek SKU olarak birlikte satılan koordineli giyim
  setini taşır. Müşterinin sonradan oluşturduğu look/kombin category değildir.
- `İş Giyimi & Üniforma`, mesleki dayanım/görünürlük/standard şeması nedeniyle doğal
  ürün ailesidir; kişisel koruyucu donanım bu dalda değildir.
- Abiye, tesettür, günlük, klasik ve sokak stili güçlü keşif terimleri olsa da ürün
  formu boyunca kesiştiğinden L2 yapılmamıştır.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| Üst Giyim | tişört, gömlek, bluz, tunik, kazak, sweatshirt, hırka |
| Alt Giyim | pantolon, jean, etek, şort, tayt |
| Elbise & Tulum | günlük elbise, abiye elbise, tulum, salopet |
| Takım & Kombinler | takım elbise, eşofman takımı, alt-üst set, koordineli iki/çok parçalı SKU |
| Dış Giyim | mont, kaban, ceket, trençkot, yağmurluk, parka, yelek |
| İç Giyim | sütyen, külot, boxer, atlet, korse, termal iç katman |
| Ev & Uyku Giyimi | pijama, gecelik, sabahlık, ev giyimi seti |
| Spor & Performans Giyimi | forma, koşu/fitness/tenis/yoga için teknik üst-alt ve performans apparel |
| Mayo & Plaj Giyimi | mayo, bikini, boardshort, rashguard, plaj elbisesi/pareo |
| İş Giyimi & Üniforma | iş tulumu, aşçı/sağlık/okul üniforması, reflektif iş giysisi |

## 8. Exclusions

- Ayakkabı ve terlik: **Ayakkabı**.
- Çanta, cüzdan, kemer, şapka, eşarp/şal, eldiven gibi bağımsız aksesuarlar:
  **Çanta & Aksesuar** ownership review.
- Saat/takı ve gözlük: kendi final L1'leri.
- Spor ekipmanı ve koruyucu spor donanımı: **Spor & Outdoor**.
- PPE; baret, koruyucu gözlük, respiratör, iş güvenliği ekipmanı: **Yapı,
  Hırdavat & Tesisat** proposal boundary'si; iş giysisi burada kalır.
- Kostüm oyuncak/role-play seti: **Oyuncak & Hobi** veya **Hediyelik & Parti**
  product-intent review; günlük giyilebilir apparel burada kalır.
- Terzilik, kuru temizleme, kiralama ve styling hizmeti Product Taxonomy dışıdır.
- Dijital pattern, moda aboneliği, hediye kartı ve sadece içerik ürünü kapsam dışıdır.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Giyim ↔ Ayakkabı | Bedene giyilen textile apparel burada; ayak giyimi her durumda Ayakkabı. |
| Giyim ↔ Çanta & Aksesuar | Ana clothing garment burada; bağımsız aksesuar kendi L1'inde. Garment'e dikili kemer ownership'i değiştirmez. |
| Giyim ↔ Spor & Outdoor | Teknik apparel burada; top, mat, raket, çadır, spor koruyucu ve ekipman Spor & Outdoor'da. |
| Giyim ↔ Yapı/Hırdavat | İş giysisi/üniforma burada; sertifikalı PPE ve iş güvenliği donanımı ilgili safety domain review'ünde. |
| Giyim ↔ Anne & Bebek | Bebek/çocuk garment ürün formuna göre burada; emzirme/hamilelik fonksiyonu baskın özel ürün Anne & Bebek boundary review'üne gider. Yaş tek başına L1 taşımaz. |
| Giyim ↔ Hediyelik & Parti/Oyuncak | Gerçek giyim ürünü burada; tek kullanımlık parti kostümü veya role-play toy ana kullanımına göre diğer domain'e gider. |
| Giyim ↔ Merchant/Sector | Butik, terzi, tesettür mağazası veya çocuk giyim mağazası Merchant Taxonomy olabilir; Product L2 değildir. |

## 10. Category vs facet decisions

| Category değildir | Facet/search/collection olarak tutulur |
|---|---|
| Cinsiyet hedefi | kadın, erkek, unisex; product fit/audience attribute |
| Yaş/evre | yenidoğan, bebek, çocuk, genç, yetişkin; age range |
| Beden/fit | XXS–..., büyük beden, petite, tall, oversize, slim/regular |
| Stil/örtünme | tesettür/modest, klasik, casual, streetwear, vintage |
| Kullanım anı | abiye, davet, düğün, mezuniyet, günlük, ofis |
| Materyal | pamuk, yün, keten, deri, sentetik; doğrulanmış composition |
| Görsel özellik | renk, desen, yaka, kol boyu, paça/kesim |
| Ticari sinyal | marka, sezon koleksiyonu, trend, indirim, featured, nearby |

Tesettür güçlü bir search/merchant intent'tir; canonical duplicate yaratmadan
facet + curated discovery collection ile karşılanabilir. `Ferace` gibi gerçek ürün
tipleri gelecek L3 placement review'ünde uygun product-form dalına bağlanır.

## 11. Search synonyms

| L2 | Controlled search/synonym hints |
|---|---|
| Üst Giyim | üst, topwear, tişört, t-shirt, gömlek, bluz, tunik |
| Alt Giyim | bottomwear, pantolon, jean, kot, etek, şort, tayt |
| Elbise & Tulum | dress, abiye, tulum, salopet |
| Takım & Kombinler | takım elbise, suit, alt üst takım, eşofman takımı |
| Dış Giyim | outerwear, mont, kaban, ceket, trençkot, yağmurluk |
| İç Giyim | underwear, lingerie, sütyen, boxer, atlet |
| Ev & Uyku Giyimi | pijama, sleepwear, loungewear, gecelik, sabahlık |
| Spor & Performans Giyimi | activewear, spor kıyafeti, forma, fitness giyim |
| Mayo & Plaj Giyimi | swimwear, mayo, bikini, plaj kıyafeti |
| İş Giyimi & Üniforma | workwear, iş kıyafeti, üniforma, önlük |

`Kot` material/look olarak birden çok formu çağırabilir; product title'daki jean
pantolon ile kot ceket bağlamı farklı primary L2'ye çözülür.

## 12. Policy/compliance notes

- Elyaf kompozisyonu ve tekstil dışı hayvansal kökenli parça bilgisi category değil,
  doğrulanabilir listing/etiket attribute'udur.
- Çocuk/bebek ürünlerinde kordon, küçük parça, yanıcılık/kimyasal ve ürün güvenliği
  kontrolleri age facet'i ile policy motorunda uygulanmalıdır.
- `Organik`, `geri dönüştürülmüş`, `antibakteriyel`, `UV korumalı`, `su geçirmez`,
  `alev geciktirici` gibi iddialar serbest synonym değil evidence gerektiren claim'dir.
- Beden sistemi, ölçü tablosu, materyal yüzdeleri ve bakım talimatı typed data olmalı;
  category adından türetilmemelidir.
- İş giysisindeki koruyucu özellik beyanı, ürünü otomatik PPE yapmaz; applicable
  standard/certification doğrulanmadan güvenlik iddiası gösterilmemelidir.

## 13. Ambiguous products

| Ürün | Proposed primary placement / rule |
|---|---|
| Tesettür tunik | Üst Giyim; `tesettür/modest` facet/collection |
| Ferace / abaya | Ana ürün formu ve owner L3 kararıyla Elbise & Tulum veya Dış Giyim; duplicate yok |
| Tesettür mayo | Mayo & Plaj Giyimi; modest facet |
| Abiye elbise | Elbise & Tulum; occasion facet |
| Blazer | Dış katman olarak pazarlanıyorsa Dış Giyim; suit SKU içindeyse Takım & Kombinler |
| Alt-üst pijama seti | Ev & Uyku Giyimi; set olması Takım & Kombinler'e taşımaz çünkü use-schema baskın |
| Eşofman takımı | Takım & Kombinler; sport/performance facet. Tek parça eşofman altı Alt Giyim olabilir |
| Spor sütyeni | İç Giyim veya future technical-sports child; exact L3 owner review, duplicate yok |
| İş tulumu | İş Giyimi & Üniforma; disposable chemical PPE ise safety review |
| Kostüm / cosplay kıyafeti | Dayanıklı wearable apparel ise product-form; toy/party ana intent ise ilgili L1 review |
| Şal / eşarp | Çanta & Aksesuar boundary review; tesettür intent'i Giyim'e taşımaz |
| Hamile elbisesi | Elbise & Tulum + maternity facet; medical/support function baskınsa Anne & Bebek review |

Adjudication: ana garment formu → primary kullanım/function → gerekli attribute/policy
şeması → cross-domain owner → tek leaf. Kararsız SKU review'a alınır, kopyalanmaz.

## 14. Future L3/L4 examples

Yalnız feasibility örnekleridir; full tree/final leaf değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| Üst Giyim | Üstler → Tişört | Cinsiyet, baskı, kol ve yaka facet'tir. |
| Alt Giyim | Pantolon → Jean Pantolon | Renk, fit ve bel yüksekliği facet'tir. |
| Dış Giyim | Mont & Kaban → Kaban | Sezon/material facet; marka node olmaz. |
| İç Giyim | Üst İç Giyim → Sütyen | Beden/cup/support facet'tir. |
| Spor & Performans Giyimi | Performans Üstleri | Spor dalı ancak farklı şema kanıtlanırsa child olabilir. |
| İş Giyimi & Üniforma | Mesleki Üniformalar → Sağlık Üniforması | Kurum/marka category olmaz. |

## 15. Open owner decisions

1. **10 L2 exact adı ve sırası** kabul/ret/revise edilmelidir.
2. **Tesettür:** öneri L2 değil facet + controlled collection'dır. Owner, güçlü yerel
   intent ile duplicate-free product-form mimarisi arasındaki bu kararı açıkça
   onaylamalıdır.
3. **Ferace/abaya exact placement:** gelecek L3 pilotunda Elbise & Tulum ile Dış
   Giyim arasındaki ana-form kuralı örnek katalogla finalleştirilmelidir.
4. **Bebek/çocuk garment ↔ Anne & Bebek:** öneri normal apparel'ın burada kalmasıdır;
   functional maternity/nursing ürünler ilgili domain tasarımıyla birlikte çözülmelidir.
5. **Spor sütyeni ve teknik base layer:** İç Giyim ile Spor & Performans arasındaki
   exact leaf ownership L3 pilotunda test edilmelidir.

Bu kararlar açıkken agent `FINAL` veya canonical runtime mapping üretemez.

## 16. Validation summary

- Canonical L1 **Giyim & Moda**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 / duplicate: **10 / 0**
- Gender/age/style/brand as L2: **0**
- Tesettür intent recorded without duplicate branch: **PASS — owner decision OPEN**
- Product/Ayakkabı/Aksesuar/Spor/PPE boundaries: **PASS**
- Product/Merchant/Service separation: **PASS**
- Full L3/L4 tree: **NOT PRODUCED**
- Flutter/Figma/JSON/DB/runtime/remote changes: **NONE**

`CLOTHING_FASHION_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`CLOTHING_FASHION_L2_COUNT: 10`

`OWNER_APPROVAL: OPEN`
