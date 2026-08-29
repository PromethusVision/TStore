# Wave 34A — Remaining Legacy Decisions

**State:** RUNTIME MAPPING REVIEW OPEN — CANONICAL STRUCTURE FINAL

## 1. Re-evaluation result

Wave 33 simulation'da `UNRESOLVED` olan 24 legacy locator, owner-final 24-L1
Canonical V1 ağacına karşı yeniden değerlendirildi. Bunlar yeni structural Product
Owner soruları değildir. Legacy leaf'lerin birden fazla ürün anlamını birleştirmesi,
final ağaçta exact successor bulunmaması veya profesyonel/policy kanıtı gerektirmesi
nedeniyle runtime product reclassification kapılarıdır.

| Classification | Count | Meaning |
|---|---:|---|
| `AUTO_SAFE` | 0 | Exact, policy-free, one-to-one successor yok |
| `AUTO_AFTER_ID_ALLOCATION` | 0 | ID tahsisi tek başına hiçbir unresolved anlamı çözmüyor |
| `MANUAL_RECLASSIFICATION` | 5 | Ürünün gerçek tipine göre existing final leaf seçilmeli; yeni tree kararı gerekmez |
| `POLICY_REVIEW` | 19 | Ürün tipi ayrımıyla birlikte safety/legal/domain-professional gate gerekir |
| `OUT_OF_SCOPE` | 0 | Combined locator'ın tamamı tek başına güvenle out sayılamaz |
| **Total** | **24** | Wave 33 unresolved inventory eksiksiz temsil edildi |

## 2. Exact locator dispositions

| # | Legacy locator | Classification | Final-tree evidence / next safe action |
|---:|---|---|---|
| 1 | `medikal-konfor-ayakkabisi` | `POLICY_REVIEW` | Ordinary comfort use ile medical claim/PPE intent ayrılmalı; evidence olmadan Ayakkabı veya PPE leaf'ine otomatik yönlendirme yok |
| 2 | `alisveris-bez-canta` | `MANUAL_RECLASSIFICATION` | Material (`bez`) facet'tir; gerçek form/use-case'e göre final Çanta leaf'i seçilmeli, exact tote leaf yok |
| 3 | `ampul-dekoratif-isik` | `POLICY_REVIEW` | `Standart Ampuller` yalnız bir alt anlamı karşılıyor; decorative/string/smart ürün ana işlev ve electrical-safety review ile ayrılmalı |
| 4 | `duvar-masa-saati` | `MANUAL_RECLASSIFICATION` | `Duvar Saati` exact yalnız duvar ürünü içindir; masa saati için blind mapping yok |
| 5 | `buz-kalibi-sogutucu-canta` | `POLICY_REVIEW` | `Tüketici Tipi Soğutucu Çanta` yalnız taşıma ürününü karşılar; buz kalıbı ayrı ürün tipi olarak reclassify edilmeli |
| 6 | `yapistirici-bant` | `POLICY_REVIEW` | Yapıştırıcı, construction tape, office tape ve packaging tape farklı final family/policy taşır; product-level split gerekir |
| 7 | `merdiven-iskele-ekipmani` | `POLICY_REVIEW` | Final V1'de exact ladder/scaffold leaf yok; height/safety evidence olmadan yayın veya nearest-node fallback yok |
| 8 | `silecek-ayna` | `POLICY_REVIEW` | Wiper ve vehicle mirror farklı fitment ürünleridir; exact final successor yok |
| 9 | `arac-sarj-donusturucu` | `POLICY_REVIEW` | Araç-specific converter generic Elektronik değildir; vehicle electrical role ve compatibility doğrulanmalı |
| 10 | `lastik-tamir-sisirme` | `POLICY_REVIEW` | Lastik leaf'leri repair/sealant/inflation ürününün successor'ı değildir; safety/hazmat ayrımı gerekir |
| 11 | `motosiklet-canta-tasima` | `POLICY_REVIEW` | Standalone bag ile vehicle-fitment carrier/luggage ayrılmalı; exact motorcycle successor yok |
| 12 | `motosiklet-aksesuari` | `POLICY_REVIEW` | Broad catch-all product identity değildir; actual product function ve fitment ile reclassify edilmeli |
| 13 | `motosiklet-lastigi-bakim-urunu` | `POLICY_REVIEW` | `Motosiklet Lastikleri` yalnız tire ürününü karşılar; maintenance chemical/kit ayrı ve fail-closed kalır |
| 14 | `bebek-odasi-mobilyasi` | `POLICY_REVIEW` | Beşik, karyola, park yatak ve alt-değiştirme furniture finalde ayrıdır; child-safety evidence ile product-level split gerekir |
| 15 | `lazimlik-tuvalet-egitimi` | `POLICY_REVIEW` | Final Anne & Bebek tree'de exact product family yok; adult medical/accessibility leaf'ine fallback yasak |
| 16 | `ahsap-oyuncak` | `POLICY_REVIEW` | `Ahşap` material facet'tir; toy type/age-stage/safety evidence üzerinden final leaf seçilmeli |
| 17 | `spor-koruyucu-destek` | `POLICY_REVIEW` | Sport-specific protector ile medical/support claim ayrılmalı; broad cross-domain redirect yok |
| 18 | `kaykay-scooter` | `POLICY_REVIEW` | `Paten & Kaykay` yalnız skateboard tarafını karşılar; scooter türü ve safety classification ayrıca çözülmeli |
| 19 | `sozluk-atlas-basvuru-kitabi` | `MANUAL_RECLASSIFICATION` | `Sözlükler` bir alt anlamdır; atlas/reference ürününün actual bibliographic türüyle final Kitap leaf'i seçilmeli |
| 20 | `not-kagidi-yapiskanli-not` | `MANUAL_RECLASSIFICATION` | `Bloknotlar` yalnız kısmi eşleşmedir; sticky note için exact successor yok |
| 21 | `hobi-kagidi-el-isi-malzemesi` | `MANUAL_RECLASSIFICATION` | Craft paper/material ile kit ve office-paper anlamları ayrılmalı; tek successor savunulamaz |
| 22 | `ilac-kutusu-gunluk-takip-gereci` | `POLICY_REVIEW` | Medication organizer ve tracking device farklı claim/data boundary taşır; exact Health leaf yok |
| 23 | `besin-destegi-koruyucu-saglik-urunu` | `POLICY_REVIEW` | Legacy umbrella PPE ile supplement anlamını birleştirir; PPE exact leaf'e ayrılabilir, supplement policy-excluded/fail-closed kalır |
| 24 | `tespih-manevi-hediyelik` | `POLICY_REVIEW` | Exact canonical leaf yok; cultural/product-family review olmadan generic gift-intent branch'e taşınmaz |

## 3. What owner-final taxonomy resolved

- Canonical V1 structural owner decisions: **0 remaining**.
- Bu 24 kayıt canonical ağaca yeni node eklenmesini otomatik gerektirmez.
- `MANUAL_RECLASSIFICATION`, catalog operator'ın gerçek product evidence üzerinden
  mevcut final leaf seçmesidir; nearest-name bulk mapping değildir.
- `POLICY_REVIEW`, taxonomy placement'i sales/publication authorization saymaz.
- Professional review sonucu exact existing leaf bulunamazsa ürün fail-closed
  exception queue'da kalır; agent yeni taxonomy leaf'i uydurmaz.

## 4. Runtime closure sequence

1. Production UUID allocation kararından sonra target planning keys UUID'lere çevrilir.
2. Actual products read-only envanterlenir; bu 24 legacy locator altında ürün yoksa
   mapping tombstone olarak korunur, farazi product oluşturulmaz.
3. Ürün varsa 5 manual ve 19 policy queue ayrı iş sahiplerine yönlendirilir.
4. Her product exactly one final assignable leaf'e bağlanır veya fail-closed kalır.
5. Alias redirect yalnız ambiguity kalmayan locator için açılır.
6. Development dry-run ve exception count `0` olmadan Production migration yapılmaz.

`PREVIOUS_UNRESOLVED: 24`

`STRUCTURAL_OWNER_DECISIONS_REMAINING: 0`

`RUNTIME_MANUAL_OR_POLICY_REVIEWS: 24`

`NEW_OWNER_QUESTION_CREATED: NO`

`RUNTIME_IMPLEMENTATION: NO`
