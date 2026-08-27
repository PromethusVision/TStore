# Spor & Outdoor L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Spor & Outdoor`
- Önerilen L2 sayısı: **10**
- Owner-final karar, runtime implementasyonu veya riskli ürünlere satış izni değildir.
- L3/L4 örnekleri yalnız gelecek derinlik kontrolüdür.

## 2. Scope

Bu alan fiziksel egzersiz, spor performansı, kamp/doğa etkinliği, bisiklet, su/kış sporu ve balıkçılık için üretilen gerçek ekipmanı kapsar. Spor kıyafeti ve ayakkabısı kendi L1'lerinde; akıllı giyilebilirler Elektronik'te; medikal destekler Sağlık & Medikal'de kalır.

Avcılık ürünlerinin tümü normal katalog ürünü değildir. Silah, mühimmat, patlayıcı ve mevzuat açısından belirsiz ürünler fail-closed ele alınır.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | Athletics, outdoor recreation, camping/hiking, cycling, fishing, water/winter sports ve koruyucu ekipman aileleri | Kamu sürümü 2021-09-21; bazı silah/av dalları EsnaftaVar için satış izni anlamına gelmez |
| [n11 Spor & Outdoor](https://www.n11.com/spor-outdoor) | Fitness, bireysel/takım sporu, kamp, balıkçılık, kış, bisiklet ve su sporu yerel dili | Marketplace'in avcılık kapsamı canonical güvenlik politikası değildir |
| [Amazon Türkiye kategori dizini](https://www.amazon.com.tr/b?node=21034466031) | Outdoor, takım oyunları, balıkçılık ve su sporlarının ayrı alışveriş niyetleri | Tam ve stabil kategori ağacı değildir |
| [Hepsiburada evde egzersiz ekipmanı rehberi](https://www.hepsiburada.com/hayatburada/evde-spor-yapmak-icin-ihtiyaciniz-olan-egzersiz-aletleri/) | Fitness/kondisyon müşteri dili | Tam kategori ağacı değil, kullanım sinyali |
| [Hepsiburada kış kampı malzemeleri](https://www.hepsiburada.com/hayatburada/kis-kampcilarinin-olmazsa-olmaz-10-malzemesi/) | Kamp, uyku, taşıma ve güvenlik ekipmanı ilişkisi | İçerik rehberi; canonical sınıflandırma değildir |

## 4. Recommended L2 count

**10 L2** önerilir. Takım/raket/bireysel/dövüş sporları farklı ekipman ailelerini yönetir; kamp, bisiklet, su ve kış outdoor kümeleri ayrı kalır. Balıkçılık ile policy-gated avcılık yerel mağaza bulunabilirliği için aynı L2 başlığında önerilir, ancak riskli ürünler kategori var diye otomatik yayınlanmaz.

## 5. Exact L2 list

1. Fitness & Kondisyon
2. Takım Sporları
3. Raket Sporları
4. Bireysel Sporlar & Jimnastik
5. Dövüş Sporları
6. Outdoor, Kamp & Trekking
7. Bisiklet
8. Su Sporları
9. Kış Sporları
10. Balıkçılık & Avcılık

## 6. Granularity rationale

- `Tüm Sporlar` kadar geniş, her spor dalını L2 yapacak kadar parçalı değildir.
- Takım ve raket sporları farklı ekipman kataloglarına sahiptir.
- Fitness/kondisyon, salon/ev egzersiz ekipmanını; bireysel sporlar ise atletizm, jimnastik ve diğer disiplinleri yönetir.
- Kamp/trekking, bisiklet, su ve kış etkinliklerinin güvenlik ve uyumluluk ihtiyaçları farklıdır.
- Balıkçılık/avcılık için kategori ile satış politikası ayrılır; yüksek riskli ürünler fail-closed kalır.

## 7. Inclusions

1. **Fitness & Kondisyon:** kondisyon cihazı, ağırlık, direnç bandı, egzersiz matı ve antrenman ekipmanı.
2. **Takım Sporları:** futbol, basketbol, voleybol, hentbol ve takım sporu top/ekipmanları.
3. **Raket Sporları:** tenis, masa tenisi, badminton, squash ve padel ekipmanı.
4. **Bireysel Sporlar & Jimnastik:** atletizm, jimnastik, yoga ekipmanı, dart ve politika açısından normal bireysel spor araçları.
5. **Dövüş Sporları:** boks/kickboks/martial arts antrenman ve koruyucu ekipmanı; gerçek silah değildir.
6. **Outdoor, Kamp & Trekking:** çadır, uyku tulumu, kamp mobilyası, trekking batonları ve uzman outdoor pişirme/aydınlatma ekipmanı.
7. **Bisiklet:** bisiklet, bisiklete özgü parça, kask, kilit, pompa ve sürüş aksesuarı; motorlu sınır hariç.
8. **Su Sporları:** yüzme, dalış, sörf, kano/SUP ve su sporu güvenlik ekipmanı.
9. **Kış Sporları:** kayak, snowboard, kızak ve bunlara özgü ekipman/koruma.
10. **Balıkçılık & Avcılık:** olta, makara, misina ve normal balıkçılık ekipmanı; av ürünleri yalnız owner-policy tarafından izin verilen exact kapsamda.

## 8. Exclusions

- Spor ayakkabısı → `Ayakkabı`; spor giyimi → `Giyim & Moda`.
- Akıllı saat/fitness bandı → `Elektronik > Giyilebilir Teknoloji`.
- Genel GPS, kamera, kulaklık ve tüketici elektroniği → ilgili `Elektronik` dalı.
- Medikal ortez, rehabilitasyon veya tedavi cihazı → `Sağlık & Medikal`.
- Oyuncak top, oyuncak çadır ve oyun ölçekli aktivite ürünü → `Oyuncak & Hobi`.
- Araç motosiklet parçası ve motorlu taşıt → `Otomotiv & Motosiklet`.
- Ateşli silah, mühimmat, patlayıcı ve bunların temel parçaları → `EXCLUDED`.
- Spor dersi, kamp turu, rehberlik, üyelik, kiralama ve etkinlik hizmeti → ürün taksonomisi dışında.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Spor & Outdoor vs Ayakkabı | Ayakta giyilen ayakkabı Ayakkabı'da; spor dalı facet/L3 olur. Spor ekipmanı burada. |
| Spor & Outdoor vs Giyim & Moda | Giyilen genel spor tekstili Giyim & Moda'da; spora özgü sert koruyucu ekipman burada. |
| Spor & Outdoor vs Elektronik | Akıllı saat ve genel elektronik Elektronik'te; sporun ana mekanik ekipmanı burada. Entegre sensör ürünü otomatik taşımaz. |
| Spor & Outdoor vs Oyuncak & Hobi | Gerçek performans/güvenlik ekipmanı burada; oyun ölçekli oyuncak Oyuncak & Hobi alanında. |
| Spor & Outdoor vs Sağlık & Medikal | Performans/koruma ekipmanı burada; tedavi, rehabilitasyon ve medikal iddia Sağlık & Medikal'de. |
| Spor & Outdoor vs Otomotiv & Motosiklet | Motorsuz bisiklet burada; motorlu araç ve fitment gerektiren taşıt parçası Otomotiv & Motosiklet'te. E-bike/e-scooter owner kararı bekler. |
| Spor & Outdoor vs Beyaz Eşya & Ev Aletleri/Züccaciye & Mutfak | Uzman taşınabilir kamp ocağı burada; genel mutfak cihazı/gereci kendi L1'inde. |

## 10. Category vs facet

Facet/attribute: marka, spor dalı alt türü, yaş, cinsiyet sunumu, beden, renk, malzeme, seviye, iç/dış mekân, oyuncu sayısı, ağırlık, uzunluk, kapasite, su geçirmezlik, mevsim, uyumluluk ve sertifika.

`Profesyonel`, `kadın`, `karbon`, `Bluetooth` veya takım/lig adı L2 değildir.

## 11. Search synonyms

| Canonical terim | Arama ipuçları |
|---|---|
| Fitness & Kondisyon | spor aleti, kondisyon, ağırlık, dambıl, resistance band |
| Takım Sporları | futbol, basketbol, voleybol, hentbol |
| Raket Sporları | tenis, badminton, masa tenisi, ping pong, padel |
| Bireysel Sporlar & Jimnastik | atletizm, yoga, pilates, jimnastik, dart |
| Dövüş Sporları | boks, kickboks, karate, taekwondo, MMA |
| Outdoor, Kamp & Trekking | kamp, trekking, hiking, çadır, uyku tulumu, baton |
| Bisiklet | bisiklet, bike, kask, bisiklet pompası, bisiklet parçası |
| Su Sporları | yüzme, dalış, surf, sörf, kano, SUP |
| Kış Sporları | kayak, snowboard, kızak |
| Balıkçılık & Avcılık | olta, makara, misina, balıkçılık, av malzemesi |

## 12. Policy notes

- Normal spor/kamp ekipmanı: `NORMAL`; koruma ve taşıma kapasitesi iddiaları doğrulanmalıdır.
- Ateşli silah, mühimmat, patlayıcı ve ana silah parçaları: `EXCLUDED`.
- Airsoft/paintball, yay/arbalet, güçlü fırlatıcı, av bıçağı ve silah-benzeri ürün: `LEGAL_REVIEW_REQUIRED`; otomatik normal ilan yoktur.
- Dalış, tırmanış, kış ve su güvenliği ürünlerinde standart/sertifika ve kullanım sınırı gerekir.
- Gıda yakıt kartuşu, basınçlı tüp, lityum batarya veya kimyasal içeren outdoor ürünleri taşıma/depolama politikası gerektirebilir.
- “Zayıflatır”, “tedavi eder” veya rehabilitasyon iddiaları Sağlık & Medikal sınırına ve policy review'a gider.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Trekking ayakkabısı | Ayakkabı > Spor Ayakkabıları | Ürün kimliği ayakkabıdır; trekking facet/L3. |
| Akıllı spor saati | Elektronik > Giyilebilir Teknoloji | Elektronik cihaz kimliği baskın. |
| Hidrasyon sırt çantası | Spor & Outdoor veya Çanta & Aksesuar | Entegre teknik sistem baskınsa burada; genel çantaysa Çanta & Aksesuar. |
| E-bike / e-scooter | Owner kararı gerekli | Bisiklet ile motorlu taşıt/şehir mobilitesi sınırı. |
| Kamp ocağı | Outdoor, Kamp & Trekking | Uzman taşınabilir outdoor ekipmanı; genel tezgâh cihazı değildir. |
| Oyuncak çadır | Oyuncak & Hobi | Oyun ölçekli ve güvenlik sözleşmesi farklıdır. |
| Ok/yay veya airsoft ürünü | Otomatik kategori yok | Legal/policy review tamamlanmadan normal yayınlanamaz. |
| Spor dizliği | Spor & Outdoor veya Sağlık & Medikal | Darbe koruması/performance burada; tedavi/ortez iddiası Sağlık & Medikal. |

## 14. Future L3/L4 examples

- `Fitness & Kondisyon → Ağırlık Antrenmanı → Dambıllar`
- `Takım Sporları → Futbol → Futbol Topları`
- `Outdoor, Kamp & Trekking → Kamp → Çadırlar`
- `Bisiklet → Bisiklet Parçaları → Fren Parçaları`
- `Su Sporları → Dalış → Dalış Maskeleri`

Örnekler final L3/L4 değildir; maksimum gelecek derinlik L4'tür.

## 15. Open owner decisions

1. Avcılık kelimesi L2'de tutulmalı mı, yoksa V1'de yalnız `Balıkçılık` olarak mı açılmalı?
2. Airsoft/paintball, okçuluk ve av bıçakları için exact izin/dışlama matrisi nedir?
3. E-bike ve e-scooter Spor & Outdoor mı, Otomotiv & Motosiklet mi sahiplenmeli?
4. Hidrasyon/teknik bisiklet çantasında Spor & Outdoor sahipliğini tetikleyen kriter nedir?
5. Koruyucu dizlik/bileklikte performans koruması ile medikal ortez sınırı hangi alanlarla doğrulanmalı?

## 16. Validation summary

- Canonical L1 adı değişmedi: **PASS**
- L2 sayısı 10, duplicate yok: **PASS**
- Spor ayakkabısı ve giyimi ilgili L1'lerde tutuldu: **PASS**
- Elektronik, Oyuncak & Hobi, Sağlık & Medikal ve Otomotiv & Motosiklet sınırları yazıldı: **PASS**
- Marka, yaş, malzeme ve seviye facet olarak korundu: **PASS**
- Ateşli silah/mühimmat/patlayıcı dışlandı: **PASS**
- Belirsiz riskli ürünler fail-closed: **PASS**
- Hizmetler ve full L3/L4 kapsam dışı: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`SPORTS_OUTDOOR_L2_STATE: PROPOSED FOR OWNER REVIEW`

`SPORTS_OUTDOOR_L2_COUNT: 10`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`SPORTS_OUTDOOR_READY_FOR_OWNER_REVIEW: YES`
