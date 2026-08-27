# Müzik & Enstrüman L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Müzik & Enstrüman`
- Önerilen L2 sayısı: **10**
- Bu belge owner-final karar veya runtime taksonomisi değildir.
- L3/L4 örnekleri tam alt ağaç değildir.

## 2. Scope

Bu alan çalınabilir müzik enstrümanlarını, performans/kayıt amacı baskın uzman ses ekipmanını, enstrüman amplifikasyon/efekt ürünlerini ve bunlara özgü aksesuar-bakım-sarf ürünlerini kapsar. Türkiye'deki yerel enstrüman mağazalarının bağlama ve benzeri geleneksel ürünlerini görünür kılarken genel tüketici ses elektroniğiyle karışmayı engeller.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | Brass, electronic, percussion, string ve woodwind enstrüman aileleri ile enstrüman aksesuarlarının ayrılması | Kamu sürümü 2021-09-21; Türkiye geleneksel enstrüman dili zayıf |
| [n11 Müzik](https://www.n11.com/muzik) | Gitar, piyano, keman, kemençe, bağlama, zurna, vurmalı, klavye, mikser, synthesizer ve aksesuar yerel dili | Marketplace merchandising ağacı canonical sınır değildir |
| [Hepsiburada evde müzik kaydı rehberi](https://www.hepsiburada.com/hayatburada/muzik-studyolari-evlere-tasindi-evde-muzik-kaydinin-olmazsa-olmazlari/) | Ses kartı, mikrofon ve monitörün kayıt amacıyla birlikte değerlendirilmesi | Tam kategori ağacı değil, kullanım amacı sinyali |
| [Hepsiburada DJ ekipmanı rehberi](https://www.hepsiburada.com/hayatburada/dj-olmak-djlige-giris-ve-ekipman-listesi/) | DJ kontrolcü, mikser ve performans ekipmanı dili | Kapsamlı ürün sınıflandırması değildir |

## 4. Recommended L2 count

**10 L2** önerilir. Enstrüman aileleri çok geniş tek `Enstrümanlar` düğümünde bırakılmaz; fakat her enstrüman adı L2 yapılmaz. Geleneksel Türk müziği dalı, yerel keşif için önerilen kontrollü bir istisnadır ve duplicate primary leaf üretmemek için açık bir isim registry'si gerektirir.

## 5. Exact L2 list

1. Gitar & Bas
2. Piyano, Org & Klavyeli Çalgılar
3. Telli & Yaylı Çalgılar
4. Nefesli Çalgılar
5. Vurmalı Çalgılar
6. Geleneksel Türk Müziği Enstrümanları
7. Elektronik Müzik & DJ Ekipmanları
8. Stüdyo, Kayıt & Canlı Ses Ekipmanları
9. Enstrüman Amfi & Efektleri
10. Enstrüman Aksesuar, Bakım & Sarf Malzemeleri

## 6. Granularity rationale

- Gitar/bas ve klavyeli çalgılar güçlü ayrı yerel mağaza raflarıdır.
- Diğer akustik enstrümanlar yapısal ses üretim ailesine göre gruplanır.
- Geleneksel Türk müziği dalı, bağlama/kemençe/ney/zurna gibi müşteri dilini görünür kılar; aynı ürün akustik ailede ikinci kez bulunamaz.
- Elektronik müzik/DJ ile stüdyo-kayıt-canlı ses farklı üretim/performans görevleridir.
- Enstrüman amfisi/efekti genel hoparlörden ayrılır; aksesuar/sarf tek yardımcı L2'de toplanır.

## 7. Inclusions

1. **Gitar & Bas:** akustik/klasik/elektro gitar, bas gitar ve doğrudan enstrümanları.
2. **Piyano, Org & Klavyeli Çalgılar:** akustik/dijital piyano, org, performans klavyesi ve klavyeli çalgılar.
3. **Telli & Yaylı Çalgılar:** keman, viyola, çello, kontrbas, arp ve geleneksel registry'ye ayrılmamış diğer telliler.
4. **Nefesli Çalgılar:** flüt, klarnet, saksafon, trompet ve geleneksel registry'ye ayrılmamış nefesliler.
5. **Vurmalı Çalgılar:** bateri, cajon, perküsyon, zil ve geleneksel registry'ye ayrılmamış vurmalılar.
6. **Geleneksel Türk Müziği Enstrümanları:** bağlama/saz, ud, kanun, kemençe, ney, zurna ve owner onaylı exact yerel registry.
7. **Elektronik Müzik & DJ Ekipmanları:** synthesizer/modüler synth, groovebox, sampler, DJ kontrolcü ve DJ mikseri.
8. **Stüdyo, Kayıt & Canlı Ses Ekipmanları:** audio interface, kayıt mikrofonu, stüdyo monitörü, canlı mikser ve kayıt/PA amaçlı uzman ekipman.
9. **Enstrüman Amfi & Efektleri:** gitar/bas amfisi, enstrüman kabini, pedal ve çoklu efekt işlemcisi.
10. **Enstrüman Aksesuar, Bakım & Sarf Malzemeleri:** tel, pena, baget, nota sehpası, stand, akort cihazı ve enstrümana özgü bakım/sarf.

## 8. Exclusions

- Genel tüketici kulaklığı, hoparlör, soundbar ve karaoke tüketici seti → `Elektronik > Ses & Kulaklık`.
- Bilgisayarın iç ses kartı ve genel PC çevre birimi → `Bilgisayar & Tablet`.
- Oyuncak piyano, oyuncak gitar ve rol oyuncağı → `Oyuncak & Hobi`.
- Nota kitabı ve müzik yayını → `Kitap`.
- Genel kablo/adaptör/güç ürünü → `Elektronik > Güç, Şarj & Bağlantı`; enstrümana özgü kablo burada aksesuar olabilir.
- Konser bileti, müzik dersi, stüdyo kiralama, tamir ve prodüksiyon hizmeti → ürün taksonomisi dışında.
- Dijital DAW aboneliği, sample lisansı ve streaming hizmeti → fiziksel ürün taksonomisi dışında.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Müzik & Enstrüman vs Elektronik/Ses | Dinleme amaçlı genel tüketici sesi Elektronik; müzik üretimi, kayıt, canlı performans veya enstrüman sinyal zinciri burada. |
| Müzik & Enstrüman vs Bilgisayar & Tablet | Genel PC bileşeni/çevre birimi Bilgisayar & Tablet; kayıt amacı baskın audio interface ve stüdyo ekipmanı burada. |
| Müzik & Enstrüman vs Oyuncak & Hobi | Akort edilebilir ve performans amacı taşıyan gerçek enstrüman burada; rol oyuncağı Oyuncak & Hobi alanında. |
| Müzik & Enstrüman vs Kitap | Fiziksel enstrüman/aksesuar burada; nota, metot ve müzik kitabı Kitap'ta. |
| Müzik & Enstrüman vs Çanta & Aksesuar | Enstrümana özgü gig bag owner kararına bağlı; genel taşıma ilkesi Çanta & Aksesuar, enstrüman satış bağlamı burada olabilir. |
| Müzik & Enstrüman iç sınırı | Owner onaylı geleneksel registry, yapısal telli/nefesli/vurmalı dallardan öncelikli ve tek primary leaf üretir. |

## 10. Category vs facet

Facet/attribute olarak kalır: marka, model, seviye, yaş, sağ/sol el, boyut, akort, tel sayısı, gövde ağacı, analog/dijital, bağlantı tipi, kanal sayısı, güç, renk, paket/set durumu ve müzik türü.

`Başlangıç`, `profesyonel`, `Bluetooth`, `USB` veya bir sanatçı adı L2 değildir.

## 11. Search synonyms

| Canonical terim | Arama ipuçları |
|---|---|
| Gitar & Bas | klasik gitar, akustik gitar, elektro gitar, bas gitar |
| Piyano, Org & Klavyeli | piyano, dijital piyano, org, keyboard, klavye |
| Telli & Yaylı | keman, viyola, çello, arp |
| Nefesli | flüt, klarnet, saksafon, trompet, üflemeli |
| Vurmalı | bateri, davul, cajon, perküsyon, zil |
| Geleneksel Türk Müziği | bağlama, saz, ud, kanun, kemençe, ney, zurna |
| Elektronik Müzik & DJ | synth, synthesizer, sampler, groovebox, DJ controller |
| Stüdyo, Kayıt & Canlı Ses | ses kartı, audio interface, stüdyo mikrofonu, monitör, mikser, PA |
| Enstrüman Amfi & Efektleri | gitar amfisi, bas amfisi, pedal, multi efekt |

## 12. Policy notes

- Normal enstrüman ve aksesuarlar: `NORMAL`.
- Yüksek ses gücü, lazer/pyro içeren sahne ekipmanı veya şebeke elektriğine bağlı profesyonel cihazlar ek güvenlik bilgisi gerektirebilir.
- Nesli koruma altındaki hayvan materyali, fildişi, kabuk veya egzotik ağaç iddiası taşıyan ürün: `LEGAL_REVIEW_REQUIRED` ve provenance kanıtı olmadan yayınlanmamalıdır.
- Kablosuz mikrofon/frekans ekipmanı uygunluk gerektirebilir.
- Sahte marka ve yetkisiz dijital lisans içerikleri engellenmelidir.
- Ders, konser, kiralama, tamir ve dijital abonelik hizmetleri dışarıdadır.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Bağlama | Geleneksel Türk Müziği Enstrümanları | Yerel keşif için carve-out; Telli altında duplicate olamaz. |
| Kemençe | Geleneksel Türk Müziği Enstrümanları | Owner onaylı registry kuralı gerekir. |
| MIDI klavye | Elektronik Müzik & DJ veya Klavyeli | Nota/performance klavyesiyse L2 2; salt kontrol yüzeyiyse L2 7. |
| USB stüdyo mikrofonu | Stüdyo, Kayıt & Canlı Ses | Bağlantı tipi facet; kayıt amacı primary. |
| Karaoke mikrofon/hoparlör seti | Elektronik > Ses & Kulaklık | Genel tüketici eğlence ürünü; profesyonel kayıt/PA değil. |
| Çocuk ukulelesi | Müzik & Enstrüman veya Oyuncak & Hobi | Akort ve gerçek performans mümkünse burada; rol oyuncağıysa Oyuncak & Hobi. |
| Enstrüman çantası | Müzik & Enstrüman veya Çanta & Aksesuar | Uzman satış bağlamı ile genel taşıma ilkesi owner kararı gerektirir. |

## 14. Future L3/L4 examples

- `Gitar & Bas → Gitarlar → Elektro Gitarlar`
- `Piyano, Org & Klavyeli Çalgılar → Piyanolar → Dijital Piyanolar`
- `Geleneksel Türk Müziği Enstrümanları → Bağlama Ailesi → Kısa Sap Bağlamalar`
- `Stüdyo, Kayıt & Canlı Ses Ekipmanları → Mikrofonlar → Kondenser Mikrofonlar`
- `Enstrüman Amfi & Efektleri → Efekt Pedalları`

Örnekler final değildir; değişken derinlik ve maksimum L4 korunur.

## 15. Open owner decisions

1. `Geleneksel Türk Müziği Enstrümanları` ayrı L2 olarak kalmalı mı, yoksa geleneksel tür facet'iyle yapısal ailelere mi dağıtılmalı?
2. Ayrı L2 kalırsa exact geleneksel enstrüman registry'sinde hangi adlar bulunmalı?
3. MIDI klavye için “çalınabilir enstrüman” ile “kontrol yüzeyi” eşiği nasıl uygulanmalı?
4. Enstrümana özgü taşıma çantası Müzik & Enstrüman mı, Çanta & Aksesuar mı sahiplenmeli?
5. Karaoke tüketici ürünü ile canlı ses/PA ekipmanı sınırını hangi teknik alanlar belirlemeli?

## 16. Validation summary

- Canonical L1 adı değişmedi: **PASS**
- L2 sayısı 10, duplicate başlık yok: **PASS**
- Geleneksel dal için tek-primary-leaf registry şartı yazıldı: **PASS**
- Tüketici sesi, Bilgisayar & Tablet, Oyuncak & Hobi, Kitap ve Çanta & Aksesuar sınırları yazıldı: **PASS**
- Marka, seviye, bağlantı ve müzik türü facet olarak korundu: **PASS**
- Hizmet/dijital abonelik dışlandı: **PASS**
- Materyal/frekans/güvenlik riskleri fail-closed: **PASS**
- Full L3/L4 finalize edilmedi: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`MUSIC_INSTRUMENTS_L2_STATE: PROPOSED FOR OWNER REVIEW`

`MUSIC_INSTRUMENTS_L2_COUNT: 10`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`MUSIC_INSTRUMENTS_READY_FOR_OWNER_REVIEW: YES`
