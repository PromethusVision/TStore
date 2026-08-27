# EsnaftaVar Kozmetik & Kişisel Bakım L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: final L1 **Kozmetik & Kişisel Bakım** için L2 spine önerisi
- Bu belge owner-final karar, stable identity, slug/sort, full L3/L4, typed facet/
  claims policy implementation, runtime/JSON/DB veya remote değişiklik değildir.
- Canonical 24 L1 ve exactly-one-primary-leaf sözleşmesi korunur.

## 2. Scope

Kapsam; insan vücudunun dış kısımlarını temizlemek, koku vermek, görünümünü
değiştirmek, korumak veya iyi durumda tutmak; ağız/diş ve günlük kişisel hijyen
sağlamak için satılan fiziksel consumer ürünler ile bunların manuel uygulama
aksesuarlarıdır.

İlaç, tıbbi cihaz, supplement, professional salon hizmeti, elektrikli kişisel bakım
cihazı ve doğrulanmamış tedavi iddiası bu L1'e sessizce dahil edilmez. Cinsiyet, yaş,
cilt/saç tipi, ingredient, concern, form, renk, koku notası ve marka facet'tir.

## 3. Sources reviewed

Erişim tarihi **2026-08-28**:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek external category ve full-path/ID yaklaşımı incelendi.
- [Google Product Taxonomy — Türkçe](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  cosmetics, skin/hair/nail/oral care, shaving, hygiene ve beauty tool ayrımları
  cross-check edildi; hierarchy doğrudan kopyalanmadı.
- [n11 — Kozmetik & Kişisel Bakım](https://www.n11.com/kozmetik-kisisel-bakim):
  parfüm/deodorant, saç, cilt, makyaj, ağız/diş ile kadın/erkek bakım komşulukları
  incelendi. Gender-based merchandising canonical category sayılmadı.
- [Trendyol — Kozmetik](https://www.trendyol.com/kozmetik-x-c89): makyaj, cilt,
  parfüm/deodorant, saç, ağız, tıraş/ağda/epilasyon, hijyen ve bakım aksesuarı güncel
  discovery sinyalleri cross-check edildi.
- [Amazon Türkiye — satılabilen ürünler](https://satis.amazon.com.tr/satis): makyaj,
  cilt, saç, vücut/banyo, tıraş, epilasyon/ağda ve hijyen ürünleri ile elektrikli
  kişisel bakım aletlerinin ayrı seller kapsamları incelendi.
- [Ticaret Bakanlığı — Kozmetik Ürünler](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/kozmetik-urunler):
  Kozmetik Kanunu/Yönetmeliği, ürün güvenlilik değerlendirmesi, ürün bilgi dosyası ve
  sorumlu teknik eleman katmanı için authoritative kaynak olarak kullanıldı.
- [Kozmetik mevzuat listesi](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/kozmetik-urunler/mevzuat):
  5324 sayılı Kanun ile 2023 Kozmetik Ürünler Yönetmeliği cross-check edildi.
- [Ticaret Bakanlığı — Biyosidal Ürünler](https://urunkurallari.ticaret.gov.tr/tr/sektorel-rehber/biosidal-urunler):
  ruhsat/tescil gerektiren biosidal intended-use ile normal kozmetik/hijyen ürünü
  arasındaki policy sınırı için incelendi.

**SOURCE LIMITATION:** TİTCK'nin bazı kozmetik guidance sayfaları arama/crawler
üzerinden kararlı şekilde listelenmedi; doğrulanabilen resmi ürün-kuralları ve mevzuat
sayfaları kullanıldı, erişilemeyen guidance içeriği hakkında iddia kurulmadı.
Marketplace full seller trees statik export değildir. Hepsiburada'nın güncel public
full-tree export'u doğrulanamadı; öneri ona bağımlı değildir.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 11.**

Bu sayı, gerçek uygulama bölgesi ve farklı attribute/claims profili üreten ürün
ailelerini korur; kadın/erkek/çocuk, ingredient, concern veya marka bazlı paralel
ağaç üretmez. Güneş bakımı özgün SPF/koruma claim ve kullanım şeması nedeniyle ayrı
L2'dir; her form/concern için yeni L2 açılmaz.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | Makyaj | Görünümü renk/kapama/vurgu ile değiştiren kozmetik bulmak |
| 2 | Cilt Bakımı | Yüz/cilt temizleme, nemlendirme ve bakım ürünü bulmak |
| 3 | Güneş Bakımı | Güneş maruziyeti öncesi/sonrası bakım ve koruma ürünü bulmak |
| 4 | Saç Bakımı & Şekillendirme | Saçı temizleyen, bakım veya şekil sağlayan ürün bulmak |
| 5 | Parfüm & Deodorant | Koku verme veya ter/koku kontrolü ürünü bulmak |
| 6 | Banyo & Vücut Bakımı | Duş/banyo temizliği ve vücut bakım ürünü bulmak |
| 7 | El, Ayak & Tırnak Bakımı | El/ayak/tırnağa özgü bakım veya nail cosmetic bulmak |
| 8 | Ağız & Diş Bakımı | Günlük ağız/diş temizlik ve bakım ürünü bulmak |
| 9 | Kişisel Hijyen | Günlük kişisel hijyen/menstrual/incontinence consumable bulmak |
| 10 | Tıraş, Ağda & Epilasyon | Manuel tıraş veya tüy alma ürünü/consumable bulmak |
| 11 | Kozmetik & Bakım Aksesuarları | Kozmetik/bakımı manuel uygulayan yardımcı araç bulmak |

Normalized duplicate: **0**. Exact ad/sıra owner approval'a kadar öneridir.

## 6. Why this granularity

- Uygulama bölgesi ve kullanım işlevi; cilt, saç, ağız, tırnak ve hijyen için farklı
  product/ingredient/claim şemaları üretir.
- Güneş bakımının SPF/UVA/UVB/water-resistance ve kullanım uyarıları genel skin-care
  filtresi olarak saklanamayacak kadar distinct policy profile oluşturur.
- Parfüm ve deodorant ortak koku/odor-control customer anchor'ında tutulur; fragrance
  note ve hedef cinsiyet L2 değildir.
- Manual shaving/epilation consumable bu domain'de; elektrikli cihaz appliance'da.
- Manuel cosmetic applicator/accessory ayrı discoverability sağlar; makeup bag ve
  elektrikli beauty device bu L2'ye çekilmez.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| Makyaj | fondöten, kapatıcı, pudra, allık, far, maskara, eyeliner, ruj, makeup primer/fixer |
| Cilt Bakımı | cleanser, toner, serum, moisturizer, face mask/peeling, lip care, eye-area cosmetic |
| Güneş Bakımı | sunscreen, SPF face/body product, after-sun cosmetic, self-tanning product |
| Saç Bakımı & Şekillendirme | şampuan, saç kremi/maskesi/serumu/yağı, styling gel/wax/spray, hair dye |
| Parfüm & Deodorant | perfume/EDP/EDT/cologne, body mist, deodorant, antiperspirant |
| Banyo & Vücut Bakımı | sabun, duş jeli, banyo tuzu/köpüğü, body lotion/oil/scrub, hand wash |
| El, Ayak & Tırnak Bakımı | hand/foot cream, nail polish/remover, cuticle care, cosmetic nail treatment |
| Ağız & Diş Bakımı | toothpaste, manual toothbrush, floss, mouthwash, tongue cleaner, interdental brush |
| Kişisel Hijyen | menstrual pad/tampon/cup, intimate hygiene, wet wipe, cotton product, adult hygiene consumable |
| Tıraş, Ağda & Epilasyon | manual razor/blade, shaving foam/gel/aftershave, wax/strip, depilatory cosmetic |
| Kozmetik & Bakım Aksesuarları | makeup brush/sponge, eyelash curler, tweezer, manual nail file/clipper, cosmetic applicator |

## 8. Exclusions

- İlaç, tıbbi cihaz, diagnostic/treatment product ve wound care: **Sağlık & Medikal**.
- Vitamin, supplement, edible beauty product: Sağlık/Gıda policy ownership review.
- Elektrikli tıraş/epilasyon cihazı, saç kurutma/şekillendirme cihazı, elektrikli ağız
  duşu/diş fırçası: **Beyaz Eşya & Ev Aletleri**.
- Bebek bezi ve baby-specific bakım/hijyen: **Anne & Bebek** domain review.
- Cinsel sağlık ürünü: **Sağlık & Medikal** policy review; marketing komşuluğu
  Kozmetik ownership'i oluşturmaz.
- Profesyonel kuaför/güzellik salonu makinesi, hizmet, randevu ve uygulama kapsam dışı.
- Makyaj çantası/organizer bag: **Çanta & Aksesuar** veya Ev & Yaşam organizer rule.
- Biyosidal/tedavi iddialı ürün normal personal-care node'una claim yoluyla sızamaz.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Kozmetik ↔ Sağlık & Medikal | Temizleme/koku/görünüm/koruma kozmetik burada; diagnosis, treatment, medical device veya medicinal intended-use Sağlık & Medikal'de. |
| Kozmetik ↔ Beyaz Eşya & Ev Aletleri | Consumable/manual applicator burada; elektrik/pil/motorla ana bakım işlevi sağlayan cihaz appliance. Replacement head exact future rule ister. |
| Kozmetik ↔ Anne & Bebek | General family personal care burada; baby-specific diaper/care product Anne & Bebek review'ünde. Yaş facet'i tek başına taşımaz. |
| Kozmetik ↔ Çanta & Aksesuar | Uygulama fırçası/sünger/törpü burada; taşıma/çanta ana işlevi Çanta & Aksesuar'da. |
| Kozmetik ↔ Gıda/sağlık supplement | Topical cosmetic burada; yenilebilir supplement ilgili ingestible domain policy'sinde. |
| Kozmetik ↔ Merchant/Sector | Kuaför/güzellik salonu Merchant Taxonomy'dir; hizmet/randevu Product Taxonomy değildir. Professional-use physical cosmetic yine ürün işlevine göre atanabilir, cihaz/salon-only risk review ister. |

## 10. Category vs facet decisions

| Category değildir | Facet/policy hint |
|---|---|
| Hedef kullanıcı | kadın, erkek, unisex; bebek/çocuk/yetişkin yaş aralığı |
| Cilt/saç tipi | kuru, yağlı, karma, hassas; kıvırcık, boyalı vb. |
| Concern | akne eğilimi, leke görünümü, yaşlanma karşıtı, kepek, dökülme; claim review |
| Form | krem, jel, serum, yağ, sprey, stick, köpük, toz |
| İçerik | ingredient/INCI, active, allergen/fragrance, concentration |
| Makyaj özelliği | renk/shade, finish, coverage, waterproof, undertone |
| Koku | fragrance family/note, concentration (EDP/EDT), size |
| Güneş | SPF, UVA/UVB, water resistance, face/body, application audience |
| Ticari | marka, set, trend, fiyat, stok, indirim, featured, nearby |

`Erkek Bakımı` ve `Kadın Bakımı` parallel L2 değildir; aynı şampuan, krem veya parfüm
ürün işlevine göre yerleşir, target audience facet'iyle bulunur.

## 11. Search synonyms

| L2 | Controlled search/synonym hints |
|---|---|
| Makyaj | makeup, renkli kozmetik, fondöten, ruj, maskara |
| Cilt Bakımı | skincare, yüz bakımı, nemlendirici, serum, temizleyici |
| Güneş Bakımı | sunscreen, güneş kremi, SPF, after sun, bronzlaştırıcı |
| Saç Bakımı & Şekillendirme | haircare, şampuan, saç kremi, styling, saç boyası |
| Parfüm & Deodorant | fragrance, koku, EDP, EDT, kolonya, deodorant |
| Banyo & Vücut Bakımı | bath body, duş jeli, sabun, vücut losyonu |
| El, Ayak & Tırnak Bakımı | manicure, pedicure, oje, tırnak bakımı, el ayak kremi |
| Ağız & Diş Bakımı | oral care, toothpaste, diş fırçası, gargara, floss |
| Kişisel Hijyen | personal hygiene, kadın hijyen, ped, tampon, ıslak mendil |
| Tıraş, Ağda & Epilasyon | shaving, razor, ağda, depilatory, tüy alma |
| Kozmetik & Bakım Aksesuarları | beauty tools, makyaj fırçası, sünger, cımbız, törpü |

`Serum` tek başına category belirlemez; saç serumu ve cilt serumu application area ile
disambiguate edilir. `Kolonya` ana kullanım/koku formuna göre Parfüm & Deodorant'tadır;
biyosidal claim ayrıca policy review ister.

## 12. Policy/compliance notes

- Kozmetik ürünün güvenlilik değerlendirmesi, ürün bilgi dosyası, responsible person/
  teknik sorumluluk, ingredient/INCI, kullanım/uyarı ve applicable notification
  gereksinimleri category'den ayrı doğrulanmalıdır.
- Hastalık tedavisi/önlenmesi, antiseptik/biyosidal ve medical claim'ler kozmetik
  discovery metninden otomatik kabul edilmez; intended-use classification review ister.
- SPF/UVA/UVB, water resistance, hypoallergenic, dermatologically tested, organic/
  natural, cruelty-free ve efficacy claim'leri evidence gerektirir.
- Aerosol, solvent, hair dye, depilatory ve nail product için hazard/patch-test/
  ventilation/age/usage warning typed policy alanları gerekebilir.
- Personal hygiene ürünlerinde boyut/absorbency, materyal, fragrance ve kullanım
  audience verisi hassas ama category'den ayrı attribute'tur.
- Seller metnindeki `dermokozmetik` ifadesi ilaç/medical onayı anlamına gelmez ve ayrı
  L2 oluşturmaz.

## 13. Ambiguous products

| Ürün | Proposed primary placement / rule |
|---|---|
| SPF'li yüz nemlendirici | Ana marketed function günlük moisturizer ise Cilt Bakımı; güneş koruma primary ise Güneş Bakımı; duplicate yok |
| Renkli güneş kremi | Primary protection claim ile Güneş Bakımı; shade facet |
| Dudak balmı | Cilt Bakımı; renkli lipstick primary ise Makyaj |
| Kolonya | Parfüm & Deodorant; antiseptik/biyosidal intended-use iddiası policy review |
| Antiperspirant | Parfüm & Deodorant; form/active facet |
| El sabunu | Banyo & Vücut Bakımı; surface cleaner Ev & Yaşam, medicinal antiseptic policy review |
| Saç boyası | Saç Bakımı & Şekillendirme; shade/form/oxidant policy attribute |
| Elektrikli epilatör | Beyaz Eşya & Ev Aletleri; ağda/depilatory consumable burada |
| Manuel diş fırçası | Ağız & Diş Bakımı; elektrikli cihaz appliance |
| Makyaj aynası | Ana cosmetic application tool ise Aksesuarlar; decorative wall mirror Ev & Yaşam |
| Makyaj çantası | Çanta & Aksesuar; içindeki cosmetic set component/principal rule ister |
| Akne tedavi ilacı | Sağlık & Medikal; normal cosmetic cleanser/cover product işlevine göre burada |
| Menstrual cup | Kişisel Hijyen; applicable product safety/material policy gerekir |
| Bebek şampuanı | Anne & Bebek ownership review; yaş facet'i ile general shampoo arasında owner kuralı gerekir |

Adjudication: intended use/claim → application area → consumable/manual/electrical →
regulatory class → cross-domain owner → tek leaf. Belirsiz SKU publish edilmeden
policy/taxonomy review'a alınır.

## 14. Future L3/L4 examples

Yalnız feasibility örnekleri; full/final tree değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| Makyaj | Ten Makyajı → Fondöten | Shade/coverage/finish facet'tir. |
| Cilt Bakımı | Yüz Bakımı → Nemlendirici | Cilt tipi/concern/ingredient facet'tir. |
| Saç Bakımı & Şekillendirme | Saç Temizliği → Şampuan | Hair type/claim facet'tir. |
| Parfüm & Deodorant | Parfüm → Eau de Parfum | Gender/fragrance note category olmaz. |
| Ağız & Diş Bakımı | Ağız Temizliği → Diş Macunu | Concern/ingredient/age facet ve policy'dir. |
| Kozmetik & Bakım Aksesuarları | Makyaj Uygulama → Makyaj Fırçası | Brand/material/brush shape facet'tir. |

## 15. Open owner decisions

1. **11 L2 exact adı ve sırası** kabul/ret/revise edilmelidir.
2. **Güneş Bakımı:** ayrı L2 önerisi, Cilt Bakımı altında L3 alternatifiyle owner
   tarafından claim/schema ve local discovery açısından challenge edilmelidir.
3. **Bebek bakım ürünleri:** baby-specific SKU'ların Anne & Bebek ownership'i o domain
   tasarımıyla birlikte finalleştirilmelidir.
4. **Replacement head/accessory:** elektrikli diş fırçası, tıraş/epilasyon cihazı
   aksesuarının device-specific compatibility rule'u appliance domain'inde çözülmelidir.
5. **Kozmetik ↔ biosidal/medical intended-use:** publish-time classification ve claims
   review sahibi belirlenmeden riskli ürünler otomatik atanamaz.

Bu kararlar açıkken agent `FINAL`, stable ID veya runtime mapping üretemez.

## 16. Validation summary

- Canonical L1 **Kozmetik & Kişisel Bakım**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 / duplicate: **11 / 0**
- Gender/age/ingredient/concern/brand as L2: **0**
- Cosmetic/medical/biosidal/appliance boundaries: **PASS — policy decisions OPEN**
- Product/Merchant/Service separation: **PASS**
- Full L3/L4 tree: **NOT PRODUCED**
- Flutter/Figma/JSON/DB/runtime/remote changes: **NONE**

`COSMETICS_PERSONAL_CARE_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`COSMETICS_PERSONAL_CARE_L2_COUNT: 11`

`OWNER_APPROVAL: OPEN`
