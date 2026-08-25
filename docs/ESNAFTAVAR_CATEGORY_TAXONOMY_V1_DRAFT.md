# EsnaftaVar Canonical Category Taxonomy V1 Draft

**Durum:** Product owner review taslağı

**Sürüm:** `2026-08-25.v1-draft`

**Makine kaynağı:** `docs/data/esnaftavar_category_taxonomy_v1_draft.json`

## Kapsam ve kullanım sözleşmesi

Bu ağaç K'pasa ekran adlarından veya dört kategorili Esenler demo verisinden türetilmedi. EsnaftaVar'ın yerel fiziksel ürün keşfi, arama, filtre, merchant ürün girişi, analitik, reklam hedefleme ve öneri ihtiyaçları için canonical ürün sınıflandırmasıdır. Bir canonical ürün tam olarak bir aktif **atanabilir yaprağa** bağlanır; üst düğümler gezinme ve raporlama roll-up'ıdır. Marka, varyant, offer/listing, mağaza, stok ve fiyat kategori değildir.

## Sayılar

| Seviye | Rol | Düğüm |
|---|---|---:|
| L1 | Ana Kategori | 20 |
| L2 | Alt Kategori | 91 |
| L3 | Ürün Grubu | 505 |
| L4 | Ürün Tipi | 32 |
| **Toplam** |  | **648** |
| Atanabilir yaprak | L2-L4 olabilir | 526 |

L4 yalnız telefon/bilgisayar aksesuarı, depolama, evcil hayvan maması ve araç parçası gibi L3'ün merchant açısından hâlâ belirsiz kaldığı dallarda kullanılır. Derinlik hedef değil, ürün ayrıştırma ihtiyacının sonucudur.

## L1 ana kategoriler

1. Market & Gıda
2. Moda & Giyim
3. Ayakkabı
4. Çanta & Giyim Aksesuarı
5. Elektronik
6. Bilgisayar & Tablet
7. Beyaz Eşya & Ev Aletleri
8. Ev & Yaşam
9. Züccaciye & Mutfak
10. Yapı & Hırdavat
11. Otomotiv & Motosiklet
12. Kişisel Bakım & Kozmetik
13. Bebek & Çocuk
14. Oyuncak, Hobi & Müzik
15. Spor & Outdoor
16. Kitap & Kırtasiye
17. Pet Shop
18. Optik, Saat & Takı
19. Sağlık & Medikal
20. Çiçek, Bahçe & Hediyelik

## Örnek derin yollar

- Elektronik > Telefon Aksesuarları > Telefon Koruma & Taşıma > Cep Telefonu Kılıfı — `cep-telefonu-kilifi`
- Elektronik > Telefon Aksesuarları > Telefon Koruma & Taşıma > Ekran Koruyucu — `telefon-ekran-koruyucu`
- Elektronik > Telefon Aksesuarları > Telefon Şarj & Güç > Telefon Şarj Cihazı — `telefon-sarj-cihazi`
- Elektronik > Telefon Aksesuarları > Telefon Şarj & Güç > Telefon Şarj Kablosu — `telefon-sarj-kablosu`
- Elektronik > Telefon Aksesuarları > Telefon Şarj & Güç > Powerbank — `powerbank`
- Elektronik > Telefon Aksesuarları > Telefon Şarj & Güç > Kablosuz Şarj Cihazı — `kablosuz-sarj-cihazi`
- Elektronik > Telefon Aksesuarları > Telefon Tutucu & Giriş Aksesuarları > Araç & Masa Telefon Tutucu — `telefon-tutucu`
- Elektronik > Telefon Aksesuarları > Telefon Tutucu & Giriş Aksesuarları > Selfie Çubuğu & Uzaktan Kumanda — `selfie-cubugu-uzaktan-kumanda`
- Elektronik > Telefon Aksesuarları > Telefon Tutucu & Giriş Aksesuarları > Dokunmatik Kalem — `dokunmatik-kalem`
- Elektronik > Telefon Aksesuarları > Telefon Yedek Bileşenleri > Telefon Bataryası — `telefon-bataryasi`

## Alias örnekleri

- **Market & Gıda:** market, gıda, gida, bakkal, süpermarket
- **Bakliyat:** kuru bakliyat, fasulye nohut mercimek
- **Pirinç, Bulgur & Tahıl:** pirinç, bulgur, tahıl, tahil
- **Makarna & Erişte:** makarna, erişte, eriste, noodle
- **Un & Hamur İşi Malzemeleri:** un, maya, kabartma tozu
- **Şeker, Tuz & Baharat:** şeker, seker, tuz, baharat
- **Sıvı Yağ, Sos & Sirke:** yağ, yag, sos, sirke
- **Süt & Yoğurt:** süt, sut, yoğurt, yogurt
- **Peynir:** beyaz peynir, kaşar, kasar
- **Tereyağı & Margarin:** tereyağı, tereyagi, margarin
- **Zeytin:** siyah zeytin, yeşil zeytin
- **Bal, Reçel & Sürülebilir Ürünler:** bal, reçel, recel, fındık kreması, ezme
- **Su & Maden Suyu:** su, soda, maden suyu
- **Çay & Bitki Çayı:** çay, cay, bitki çayı
- **Kahve & Kakao:** kahve, Türk kahvesi, filtre kahve, kakao
- **Gazlı İçecek & Meyve Suyu:** kola, gazoz, meyve suyu, soğuk çay

Alias'lar kategori adının yerine geçmez. Arama indeksinde Türkçe küçük/büyük harf, şapka/ASCII yazımı, birleşik-ayrı yazım ve yaygın kullanıcı terimleri normalize edilmelidir. Marka adları alias listesine eklenmez; marka ayrı facet ve sinyaldir.

## Filter/attribute stratejisi

- `cross_category_filter_family_ids`: marka ve ürün durumu tek bir kategoriye özgü değildir; gerçek aktivasyon leaf kuralına ve product owner politikasına bağlıdır.
- Fiyat, stok/uygunluk ve mağaza mesafesi canonical ürün değil, mağaza offer/listing bağlamıdır.
- Her düğüm `applicable_filter_family_ids` taşır. Yapraklar merchant formunu ve müşteri facet'lerini yönlendirir; üst düğüm değerleri varsayılan/inheritance başlangıcıdır.
- Beden, renk, numara, kapasite gibi variant üreten alanlar yine attribute'tur. Varyant kimliği canonical kategori yaratmaz.
- Araç ve cihaz uyumluluğu kontrollü referans verisi ister; marka-model adları kategori düğümü yapılmaz.
- Attribute tanımları ileride ayrı, versiyonlu bir registry olmalıdır: tip, birim, kardinalite, zorunluluk, varyant/facet rolü, izinli değerler ve kategori bağları.

## Risk politikası

JSON'daki `risk_flags` hukuki uygunluk kararı değildir; moderasyon ve belge kontrolü için routing sinyalidir. İlaç, tütün/nikotin, alkollü içki, silah/mühimmat/patlayıcı, yasa dışı madde, canlı hayvan ve dijital-only/hizmet domainleri bu V1 ürün ağacına bilerek alınmamıştır. Tıbbi cihaz, optik ölçülü ürün, gıda takviyesi, çocuk güvenlik ürünü, kimyasal ve araç güvenlik parçası ilgili risk bayrağıyla owner/legal operasyon kararına tabidir.

## Otomatik doğrulama özeti

| Kontrol | Sonuç |
|---|---|
| `json_parse_and_required_generation_contract` | PASS |
| `duplicate_slugs` | PASS |
| `duplicate_sibling_names_tr_normalized` | PASS |
| `cycles` | PASS |
| `orphan_nodes` | PASS |
| `parent_level_consistency` | PASS |
| `maximum_depth_4` | PASS |
| `leaf_assignment_consistency` | PASS |
| `known_filter_family_references` | PASS |
| `known_risk_flag_references` | PASS |
| `brand_as_category_guard` | PASS |
| `attribute_as_category_guard` | PASS |
| `bare_ambiguous_name_guard` | PASS |
| `turkish_display_spelling_guard` | PASS |
| `duplicate_alias_within_node` | PASS |

L4 oranı toplam düğümlerin %4,9'udur; maksimum derinlik 4'tür. Üretim doğrulaması duplicate slug/sibling, cycle, orphan, parent-level, leaf assignment, filter/risk referansı, marka-kategori, attribute-kategori, çıplak belirsiz ad, Türkçe görünür yazım ve node-içi duplicate alias kapılarını fail-closed uygular.

## Complete tree

- **Market & Gıda** `market-gida` — Ana Kategori; alias: market, gıda, gida, bakkal, süpermarket
  - **Temel Gıda** `temel-gida` — Alt Kategori
    - **Bakliyat** `bakliyat` — atanabilir yaprak; alias: kuru bakliyat, fasulye nohut mercimek
    - **Pirinç, Bulgur & Tahıl** `pirinc-bulgur-tahil` — atanabilir yaprak; alias: pirinç, bulgur, tahıl, tahil
    - **Makarna & Erişte** `makarna-eriste` — atanabilir yaprak; alias: makarna, erişte, eriste, noodle
    - **Un & Hamur İşi Malzemeleri** `un-hamur-isi-malzemeleri` — atanabilir yaprak; alias: un, maya, kabartma tozu
    - **Şeker, Tuz & Baharat** `seker-tuz-baharat` — atanabilir yaprak; alias: şeker, seker, tuz, baharat
    - **Sıvı Yağ, Sos & Sirke** `sivi-yag-sos-sirke` — atanabilir yaprak; alias: yağ, yag, sos, sirke
  - **Kahvaltılık & Süt Ürünleri** `kahvaltilik-sut-urunleri` — Alt Kategori
    - **Süt & Yoğurt** `sut-yogurt` — atanabilir yaprak; alias: süt, sut, yoğurt, yogurt; risk: cold_chain
    - **Peynir** `peynir` — atanabilir yaprak; alias: beyaz peynir, kaşar, kasar; risk: cold_chain
    - **Tereyağı & Margarin** `tereyagi-margarin` — atanabilir yaprak; alias: tereyağı, tereyagi, margarin; risk: cold_chain
    - **Yumurta** `yumurta` — atanabilir yaprak; risk: cold_chain
    - **Zeytin** `zeytin` — atanabilir yaprak; alias: siyah zeytin, yeşil zeytin
    - **Bal, Reçel & Sürülebilir Ürünler** `bal-recel-surulebilir-urunler` — atanabilir yaprak; alias: bal, reçel, recel, fındık kreması, ezme
  - **İçecek & Atıştırmalık** `icecek-atistirmalik` — Alt Kategori
    - **Su & Maden Suyu** `su-maden-suyu` — atanabilir yaprak; alias: su, soda, maden suyu
    - **Çay & Bitki Çayı** `cay-bitki-cayi` — atanabilir yaprak; alias: çay, cay, bitki çayı
    - **Kahve & Kakao** `kahve-kakao` — atanabilir yaprak; alias: kahve, Türk kahvesi, filtre kahve, kakao
    - **Gazlı İçecek & Meyve Suyu** `gazli-icecek-meyve-suyu` — atanabilir yaprak; alias: kola, gazoz, meyve suyu, soğuk çay
    - **Çikolata & Şekerleme** `cikolata-sekerleme` — atanabilir yaprak; alias: çikolata, cikolata, gofret, şekerleme, sakız
    - **Bisküvi, Kraker & Kek** `biskuvi-kraker-kek` — atanabilir yaprak; alias: bisküvi, kraker, kek
    - **Cips & Patlamış Mısır** `cips-patlamis-misir` — atanabilir yaprak; alias: cips, patlamış mısır, popcorn
    - **Kuruyemiş & Kuru Meyve** `kuruyemis-kuru-meyve` — atanabilir yaprak; alias: kuruyemiş, kuruyemis, kuru meyve
  - **Taze, Donuk & Hazır Gıda** `taze-donuk-hazir-gida` — Alt Kategori
    - **Taze Meyve** `taze-meyve` — atanabilir yaprak; alias: meyve, manav
    - **Taze Sebze** `taze-sebze` — atanabilir yaprak; alias: sebze, manav
    - **Ekmek & Unlu Mamuller** `ekmek-unlu-mamuller` — atanabilir yaprak; alias: ekmek, fırın, firin, simit, poğaça
    - **Et & Tavuk Ürünleri** `et-tavuk-urunleri` — atanabilir yaprak; alias: kasap, kırmızı et, tavuk; risk: cold_chain
    - **Şarküteri** `sarkuteri` — atanabilir yaprak; alias: şarküteri, sarkuteri, sucuk, salam; risk: cold_chain
    - **Balık & Deniz Ürünleri** `balik-deniz-urunleri` — atanabilir yaprak; alias: balıkçı, balikci, deniz ürünü; risk: cold_chain
    - **Dondurulmuş Gıda** `dondurulmus-gida` — atanabilir yaprak; alias: donuk gıda, dondurulmuş ürün; risk: cold_chain
    - **Hazır Yemek & Meze** `hazir-yemek-meze` — atanabilir yaprak; alias: hazır yemek, meze, şarküteri mezesi; risk: cold_chain
- **Moda & Giyim** `moda-giyim` — Ana Kategori; alias: giyim, tekstil, konfeksiyon, moda
  - **Üst Giyim** `ust-giyim` — Alt Kategori
    - **Tişört** `tisort` — atanabilir yaprak; alias: tişört, tisort, t-shirt
    - **Gömlek & Bluz** `gomlek-bluz` — atanabilir yaprak; alias: gömlek, gomlek, bluz
    - **Kazak & Hırka** `kazak-hirka` — atanabilir yaprak; alias: kazak, hırka, hirka
    - **Sweatshirt & Hoodie** `sweatshirt-hoodie` — atanabilir yaprak; alias: sweat, kapüşonlu, hoodie
    - **Tunik** `tunik` — atanabilir yaprak; alias: uzun tunik
  - **Alt Giyim** `alt-giyim` — Alt Kategori
    - **Pantolon** `pantolon` — atanabilir yaprak; alias: kumaş pantolon
    - **Jean** `jean` — atanabilir yaprak; alias: kot pantolon, denim
    - **Etek** `etek` — atanabilir yaprak
    - **Şort** `sort` — atanabilir yaprak; alias: şort, sort, bermuda
    - **Tayt & Eşofman Altı** `tayt-esofman-alti` — atanabilir yaprak; alias: tayt, eşofman, esofman
  - **Dış Giyim & Tek Parça** `dis-giyim-tek-parca` — Alt Kategori
    - **Mont, Kaban & Parka** `mont-kaban-parka` — atanabilir yaprak; alias: mont, kaban, parka
    - **Ceket & Blazer** `ceket-blazer` — atanabilir yaprak; alias: ceket, blazer
    - **Yağmurluk & Rüzgarlık** `yagmurluk-ruzgarlik` — atanabilir yaprak; alias: yağmurluk, yagmurluk, rüzgarlık
    - **Elbise** `elbise` — atanabilir yaprak; alias: abiye, günlük elbise
    - **Tulum** `tulum-giyim` — atanabilir yaprak; alias: giyim tulumu
    - **Takım Elbise** `takim-elbise` — atanabilir yaprak; alias: takım, damatlık
  - **İç Giyim, Ev Giyimi & Fonksiyonel Giyim** `ic-giyim-ev-giyimi-fonksiyonel` — Alt Kategori
    - **İç Çamaşırı** `ic-camasiri` — atanabilir yaprak; alias: iç giyim, atlet, külot, boxer
    - **Sütyen & Korse** `sutyen-korse` — atanabilir yaprak; alias: sütyen, sutyen, korse
    - **Pijama & Gecelik** `pijama-gecelik` — atanabilir yaprak; alias: pijama, gecelik, sabahlık
    - **Çorap & Külotlu Çorap** `corap-kulotlu-corap` — atanabilir yaprak; alias: çorap, corap, külotlu çorap
    - **İş Kıyafeti & Üniforma** `is-kiyafeti-uniforma` — atanabilir yaprak; alias: iş elbisesi, önlük, üniforma; risk: safety_critical
    - **Mayo & Plaj Giyimi** `mayo-plaj-giyimi` — atanabilir yaprak; alias: mayo, bikini, deniz şortu
- **Ayakkabı** `ayakkabi` — Ana Kategori; alias: ayakkabı, ayakkabi, kundura
  - **Günlük & Klasik Ayakkabı** `gunluk-klasik-ayakkabi` — Alt Kategori
    - **Günlük Bağcıklı Ayakkabı** `gunluk-bagcikli-ayakkabi` — atanabilir yaprak; alias: casual ayakkabı
    - **Mokasen & Loafer** `mokasen-loafer` — atanabilir yaprak; alias: mokasen, loafer
    - **Babet & Düz Ayakkabı** `babet-duz-ayakkabi` — atanabilir yaprak; alias: babet, düz ayakkabı
    - **Klasik Ayakkabı** `klasik-ayakkabi` — atanabilir yaprak; alias: kundura, resmi ayakkabı
    - **Topuklu Ayakkabı** `topuklu-ayakkabi` — atanabilir yaprak; alias: stiletto, dolgu topuk
  - **Spor Ayakkabı** `spor-ayakkabi` — Alt Kategori
    - **Koşu Ayakkabısı** `kosu-ayakkabisi` — atanabilir yaprak; alias: koşu ayakkabısı, running
    - **Yürüyüş Ayakkabısı** `yuruyus-ayakkabisi` — atanabilir yaprak; alias: yürüyüş, walking
    - **Günlük Sneaker** `gunluk-sneaker` — atanabilir yaprak; alias: sneaker, spor ayakkabı, spor ayakkabi
    - **Salon & Antrenman Ayakkabısı** `salon-antrenman-ayakkabisi` — atanabilir yaprak; alias: fitness ayakkabısı, court ayakkabı
    - **Futbol Ayakkabısı** `futbol-ayakkabisi` — atanabilir yaprak; alias: krampon, halı saha ayakkabısı
  - **Bot & Çizme** `bot-cizme` — Alt Kategori
    - **Bot** `bot` — atanabilir yaprak; alias: günlük bot
    - **Çizme** `cizme` — atanabilir yaprak; alias: çizme, cizme
    - **Kar & Yağmur Botu** `kar-yagmur-botu` — atanabilir yaprak; alias: kar botu, yağmur botu
    - **Trekking Ayakkabısı & Botu** `trekking-ayakkabisi-botu` — atanabilir yaprak; alias: outdoor ayakkabı, hiking bot
  - **Sandalet, Terlik & Uzmanlık Ayakkabısı** `sandalet-terlik-uzmanlik-ayakkabisi` — Alt Kategori
    - **Sandalet** `sandalet` — atanabilir yaprak
    - **Terlik** `terlik` — atanabilir yaprak; alias: ev terliği, plaj terliği
    - **Deniz Ayakkabısı** `deniz-ayakkabisi` — atanabilir yaprak; alias: havuz ayakkabısı
    - **İş Güvenliği Ayakkabısı** `is-guvenligi-ayakkabisi` — atanabilir yaprak; alias: çelik burun ayakkabı, iş botu; risk: safety_critical
    - **Medikal & Konfor Ayakkabısı** `medikal-konfor-ayakkabisi` — atanabilir yaprak; alias: ortopedik ayakkabı, sabo; risk: regulated_review, claim_sensitive
- **Çanta & Giyim Aksesuarı** `canta-giyim-aksesuari` — Ana Kategori; alias: çanta, canta, giyim aksesuarı
  - **Günlük Çantalar** `gunluk-cantalar` — Alt Kategori
    - **El Çantası** `el-cantasi` — atanabilir yaprak; alias: kadın çantası, handbag
    - **Omuz & Çapraz Çanta** `omuz-capraz-canta` — atanabilir yaprak; alias: omuz çantası, çapraz çanta
    - **Sırt Çantası** `sirt-cantasi` — atanabilir yaprak; alias: backpack
    - **Bel Çantası** `bel-cantasi` — atanabilir yaprak; alias: waist bag
    - **Alışveriş & Bez Çanta** `alisveris-bez-canta` — atanabilir yaprak; alias: tote bag, bez çanta
  - **İş, Okul & Cihaz Çantaları** `is-okul-cihaz-cantalari` — Alt Kategori
    - **Laptop Çantası** `laptop-cantasi` — atanabilir yaprak; alias: bilgisayar çantası
    - **Evrak Çantası** `evrak-cantasi` — atanabilir yaprak; alias: briefcase, iş çantası
    - **Okul Çantası** `okul-cantasi` — atanabilir yaprak; alias: öğrenci çantası
    - **Fotoğraf Makinesi Çantası** `fotograf-makinesi-cantasi` — atanabilir yaprak; alias: kamera çantası
  - **Seyahat Çantaları** `seyahat-cantalari` — Alt Kategori
    - **Valiz** `valiz` — atanabilir yaprak; alias: bavul
    - **Seyahat Çantası** `seyahat-cantasi` — atanabilir yaprak; alias: duffel, spor seyahat çantası
    - **Kabin & El Bagajı** `kabin-el-bagaji` — atanabilir yaprak; alias: kabin boy valiz, el bagajı
    - **Makyaj & Bakım Çantası** `makyaj-bakim-cantasi` — atanabilir yaprak; alias: makyaj çantası, toiletry bag
  - **Küçük Deri Ürünleri & Giyim Tamamlayıcıları** `kucuk-deri-giyim-tamamlayicilari` — Alt Kategori
    - **Cüzdan & Kartlık** `cuzdan-kartlik` — atanabilir yaprak; alias: cüzdan, cuzdan, kartlık
    - **Kemer** `kemer` — atanabilir yaprak
    - **Şapka & Bere** `sapka-bere` — atanabilir yaprak; alias: şapka, sapka, bere
    - **Atkı, Şal & Fular** `atki-sal-fular` — atanabilir yaprak; alias: atkı, şal, fular
    - **Eldiven** `eldiven` — atanabilir yaprak
    - **Kravat & Papyon** `kravat-papyon` — atanabilir yaprak; alias: kravat, papyon
    - **Şemsiye** `semsiye` — atanabilir yaprak; alias: şemsiye, semsiye
    - **Saç Aksesuarları** `sac-aksesuarlari` — atanabilir yaprak; alias: toka, taç, saç bandı
- **Elektronik** `elektronik` — Ana Kategori; alias: elektronik, teknoloji, elektronik eşya
  - **Telefon & Giyilebilir Teknoloji** `telefon-giyilebilir-teknoloji` — Alt Kategori
    - **Akıllı Telefon** `akilli-telefon` — atanabilir yaprak; alias: cep telefonu, telefon, smartphone, akıllı cep telefonu
    - **Tuşlu Cep Telefonu** `tuslu-cep-telefonu` — atanabilir yaprak; alias: tuşlu telefon, klasik telefon
    - **Akıllı Saat** `akilli-saat` — atanabilir yaprak; alias: smart watch, smartwatch
    - **Akıllı Bileklik** `akilli-bileklik` — atanabilir yaprak; alias: aktivite bilekliği, smart band
    - **GPS Takip Cihazı** `gps-takip-cihazi` — atanabilir yaprak; alias: takip cihazı, çocuk takip saati
  - **Telefon Aksesuarları** `telefon-aksesuarlari` — Alt Kategori
    - **Telefon Koruma & Taşıma** `telefon-koruma-tasima` — Ürün Grubu
      - **Cep Telefonu Kılıfı** `cep-telefonu-kilifi` — atanabilir yaprak; alias: telefon kılıfı, telefon kabı, case
      - **Ekran Koruyucu** `telefon-ekran-koruyucu` — atanabilir yaprak; alias: kırılmaz cam, temperli cam, ekran filmi
    - **Telefon Şarj & Güç** `telefon-sarj-guc` — Ürün Grubu
      - **Telefon Şarj Cihazı** `telefon-sarj-cihazi` — atanabilir yaprak; alias: şarj aleti, sarj aleti, adaptör
      - **Telefon Şarj Kablosu** `telefon-sarj-kablosu` — atanabilir yaprak; alias: şarj kablosu, USB kablo
      - **Powerbank** `powerbank` — atanabilir yaprak; alias: taşınabilir şarj, power bank
      - **Kablosuz Şarj Cihazı** `kablosuz-sarj-cihazi` — atanabilir yaprak; alias: wireless şarj, şarj pedi
    - **Telefon Tutucu & Giriş Aksesuarları** `telefon-tutucu-giris-aksesuarlari` — Ürün Grubu
      - **Araç & Masa Telefon Tutucu** `telefon-tutucu` — atanabilir yaprak; alias: telefon standı, araç içi telefon tutucu
      - **Selfie Çubuğu & Uzaktan Kumanda** `selfie-cubugu-uzaktan-kumanda` — atanabilir yaprak; alias: selfie stick, bluetooth deklanşör
      - **Dokunmatik Kalem** `dokunmatik-kalem` — atanabilir yaprak; alias: stylus, tablet kalemi
    - **Telefon Yedek Bileşenleri** `telefon-yedek-bilesenleri` — Ürün Grubu; risk: safety_critical, compatibility_critical
      - **Telefon Bataryası** `telefon-bataryasi` — atanabilir yaprak; alias: cep telefonu pili; risk: safety_critical, hazmat_review, compatibility_critical
      - **Telefon Ekran Modülü** `telefon-ekran-modulu` — atanabilir yaprak; alias: yedek telefon ekranı, LCD ekran; risk: compatibility_critical
  - **Ses & Görüntü Sistemleri** `ses-goruntu-sistemleri` — Alt Kategori
    - **Kulaklık** `kulaklik` — atanabilir yaprak; alias: bluetooth kulaklık, kablosuz kulaklık, earbuds, headphone
    - **Taşınabilir Hoparlör** `tasinabilir-hoparlor` — atanabilir yaprak; alias: bluetooth hoparlör
    - **Ev Ses Sistemi** `ev-ses-sistemi` — atanabilir yaprak; alias: soundbar, ev sinema sistemi
    - **Mikrofon** `mikrofon` — atanabilir yaprak; alias: kablosuz mikrofon, yaka mikrofonu
    - **Televizyon** `televizyon` — atanabilir yaprak; alias: TV, smart TV
    - **Projeksiyon Cihazı** `projeksiyon-cihazi` — atanabilir yaprak; alias: projektör, projeksiyon
    - **Medya Oynatıcı** `medya-oynatici` — atanabilir yaprak; alias: TV box, streaming cihazı
    - **Uydu Alıcısı & Anten** `uydu-alicisi-anten` — atanabilir yaprak; alias: uydu cihazı, çanak anten
  - **Kamera & Güvenlik Elektroniği** `kamera-guvenlik-elektronigi` — Alt Kategori
    - **Fotoğraf Makinesi** `fotograf-makinesi` — atanabilir yaprak; alias: kamera, dijital fotoğraf makinesi
    - **Aksiyon Kamerası** `aksiyon-kamerasi` — atanabilir yaprak; alias: action cam, aksiyon kamera
    - **Kamera Lensi & Fotoğraf Aksesuarı** `kamera-lensi-fotograf-aksesuari` — atanabilir yaprak; alias: objektif, tripod, fotoğraf aksesuarı
    - **Güvenlik Kamerası** `guvenlik-kamerasi` — atanabilir yaprak; alias: IP kamera, CCTV
    - **Alarm & Akıllı Kapı Zili** `alarm-akilli-kapi-zili` — atanabilir yaprak; alias: alarm sistemi, görüntülü kapı zili
    - **Bebek Kamerası & Telsizi** `bebek-kamerasi-telsizi` — atanabilir yaprak; alias: baby monitor, bebek telsizi
  - **Oyun Konsolu & Aksesuarları** `oyun-konsolu-aksesuarlari` — Alt Kategori
    - **Oyun Konsolu** `oyun-konsolu` — atanabilir yaprak; alias: konsol
    - **Oyun Kolu & Kontrolcü** `oyun-kolu-kontrolcu` — atanabilir yaprak; alias: gamepad, joystick
    - **Konsol Aksesuarı** `konsol-aksesuari` — atanabilir yaprak; alias: konsol standı, şarj istasyonu
    - **Fiziksel Video Oyunu** `fiziksel-video-oyunu` — atanabilir yaprak; alias: oyun diski, kutu oyun yazılımı
  - **Elektronik Güç, Kablo & Bileşen** `elektronik-guc-kablo-bilesen` — Alt Kategori
    - **Pil & Şarjlı Pil** `pil-sarjli-pil` — atanabilir yaprak; alias: kalem pil, şarjlı pil; risk: hazmat_review
    - **Genel Adaptör & Güç Kaynağı** `genel-adaptor-guc-kaynagi` — atanabilir yaprak; alias: AC adaptör, DC adaptör
    - **Ses, Görüntü & Veri Kablosu** `ses-goruntu-veri-kablosu` — atanabilir yaprak; alias: HDMI kablo, AUX kablo, USB kablo
    - **Uzaktan Kumanda** `uzaktan-kumanda` — atanabilir yaprak; alias: TV kumandası, akıllı kumanda
    - **Hobi Elektronik Bileşeni** `hobi-elektronik-bileseni` — atanabilir yaprak; alias: devre elemanı, sensör, lehim bileşeni
- **Bilgisayar & Tablet** `bilgisayar-tablet` — Ana Kategori; alias: bilgisayar, computer, PC, tablet
  - **Bilgisayar, Tablet & Okuyucu** `bilgisayar-tablet-okuyucu` — Alt Kategori
    - **Dizüstü Bilgisayar** `dizustu-bilgisayar` — atanabilir yaprak; alias: laptop, notebook
    - **Masaüstü Bilgisayar** `masaustu-bilgisayar` — atanabilir yaprak; alias: desktop, kasa bilgisayar
    - **All-in-One & Mini Bilgisayar** `all-in-one-mini-bilgisayar` — atanabilir yaprak; alias: hepsi bir arada bilgisayar, mini PC
    - **Tablet** `tablet` — atanabilir yaprak; alias: tablet bilgisayar
    - **E-Kitap Okuyucu** `e-kitap-okuyucu` — atanabilir yaprak; alias: e-reader, elektronik kitap okuyucu
  - **Bilgisayar Bileşenleri** `bilgisayar-bilesenleri` — Alt Kategori
    - **Ana Bilgisayar Bileşenleri** `ana-bilgisayar-bilesenleri` — Ürün Grubu
      - **İşlemci** `bilgisayar-islemcisi` — atanabilir yaprak; alias: CPU, işlemci
      - **Anakart** `anakart` — atanabilir yaprak; alias: motherboard
      - **RAM Bellek** `ram-bellek` — atanabilir yaprak; alias: RAM, bellek
      - **Ekran Kartı** `ekran-karti` — atanabilir yaprak; alias: GPU, grafik kartı
    - **Dahili Depolama Bileşenleri** `dahili-depolama-bilesenleri` — Ürün Grubu
      - **SSD** `ssd` — atanabilir yaprak; alias: katı hal diski, NVMe SSD
      - **Dahili Sabit Disk** `dahili-sabit-disk` — atanabilir yaprak; alias: HDD, hard disk
      - **Optik Sürücü** `optik-surucu` — atanabilir yaprak; alias: DVD yazıcı, Blu-ray sürücü
    - **Kasa, Güç & Soğutma** `kasa-guc-sogutma` — Ürün Grubu
      - **Bilgisayar Kasası** `bilgisayar-kasasi` — atanabilir yaprak; alias: PC kasa
      - **Bilgisayar Güç Kaynağı** `bilgisayar-guc-kaynagi` — atanabilir yaprak; alias: PSU
      - **Bilgisayar Soğutma** `bilgisayar-sogutma` — atanabilir yaprak; alias: işlemci soğutucu, kasa fanı
  - **Bilgisayar Çevre Birimleri** `bilgisayar-cevre-birimleri` — Alt Kategori
    - **Monitör** `monitor` — atanabilir yaprak; alias: bilgisayar ekranı
    - **Klavye** `klavye` — atanabilir yaprak; alias: keyboard
    - **Mouse & Mousepad** `mouse-mousepad` — atanabilir yaprak; alias: fare, mouse, mouse pad
    - **Webcam** `webcam` — atanabilir yaprak; alias: web kamera
    - **Grafik Tablet** `grafik-tablet` — atanabilir yaprak; alias: çizim tableti
    - **USB Hub & Dock İstasyonu** `usb-hub-dock-istasyonu` — atanabilir yaprak; alias: USB çoğaltıcı, dock
  - **Ağ, Harici Depolama & Baskı** `ag-harici-depolama-baski` — Alt Kategori
    - **Modem & Router** `modem-router` — atanabilir yaprak; alias: modem, yönlendirici, router
    - **Ağ Cihazı & Adaptörü** `ag-cihazi-adaptoru` — atanabilir yaprak; alias: switch, access point, Wi-Fi adaptör
    - **USB Bellek & Hafıza Kartı** `usb-bellek-hafiza-karti` — atanabilir yaprak; alias: flash bellek, memory card
    - **Harici Disk & NAS** `harici-disk-nas` — atanabilir yaprak; alias: external disk, taşınabilir disk, NAS
    - **Yazıcı** `yazici` — atanabilir yaprak; alias: printer, lazer yazıcı, mürekkep püskürtmeli
    - **Tarayıcı** `tarayici` — atanabilir yaprak; alias: scanner
    - **Kartuş & Toner** `kartus-toner` — atanabilir yaprak; alias: mürekkep kartuşu, toner
- **Beyaz Eşya & Ev Aletleri** `beyaz-esya-ev-aletleri` — Ana Kategori; alias: beyaz eşya, beyaz esya, elektrikli ev aleti
  - **Soğutma Cihazları** `sogutma-cihazlari` — Alt Kategori
    - **Buzdolabı** `buzdolabi` — atanabilir yaprak; alias: buz dolabı
    - **Derin Dondurucu** `derin-dondurucu` — atanabilir yaprak; alias: dondurucu
    - **Mini Buzdolabı** `mini-buzdolabi` — atanabilir yaprak; alias: mini bar
    - **Su Sebili** `su-sebili` — atanabilir yaprak; alias: sıcak soğuk su sebili
  - **Çamaşır & Bulaşık Cihazları** `camasir-bulasik-cihazlari` — Alt Kategori
    - **Çamaşır Makinesi** `camasir-makinesi` — atanabilir yaprak; alias: çamaşır makinası
    - **Kurutma Makinesi** `kurutma-makinesi` — atanabilir yaprak; alias: çamaşır kurutma
    - **Bulaşık Makinesi** `bulasik-makinesi` — atanabilir yaprak; alias: bulaşık makinası
    - **Ütü** `utu` — atanabilir yaprak; alias: buharlı ütü, ütü
    - **Dikiş Makinesi** `dikis-makinesi` — atanabilir yaprak; alias: dikiş makinası
  - **Pişirme & Mutfak Cihazları** `pisirme-mutfak-cihazlari` — Alt Kategori
    - **Fırın** `firin-cihazi` — atanabilir yaprak; alias: ankastre fırın, mini fırın
    - **Ocak** `ocak-cihazi` — atanabilir yaprak; alias: ankastre ocak, set üstü ocak
    - **Davlumbaz & Aspiratör** `davlumbaz-aspirator` — atanabilir yaprak; alias: davlumbaz, mutfak aspiratörü
    - **Mikrodalga Fırın** `mikrodalga-firin` — atanabilir yaprak; alias: mikrodalga
    - **Çay & Kahve Makinesi** `cay-kahve-makinesi` — atanabilir yaprak; alias: çaycı, kahve makinesi, Türk kahvesi makinesi
    - **Blender, Mikser & Doğrayıcı** `blender-mikser-dograyici` — atanabilir yaprak; alias: blender, mikser, rondo
    - **Tost, Izgara & Airfryer** `tost-izgara-airfryer` — atanabilir yaprak; alias: tost makinesi, elektrikli ızgara, air fryer
    - **Su Isıtıcı & Elektrikli Pişirici** `su-isitici-elektrikli-pisirici` — atanabilir yaprak; alias: kettle, elektrikli tencere, pirinç pişirici
  - **Temizlik, İklimlendirme & Kişisel Ev Aleti** `temizlik-iklimlendirme-kisisel-ev-aleti` — Alt Kategori
    - **Elektrikli Süpürge** `elektrikli-supurge` — atanabilir yaprak; alias: robot süpürge, dikey süpürge
    - **Buharlı Temizleyici** `buharli-temizleyici` — atanabilir yaprak; alias: buhar makinesi
    - **Klima** `klima` — atanabilir yaprak; alias: split klima, portatif klima
    - **Vantilatör & Hava Soğutucu** `vantilator-hava-sogutucu` — atanabilir yaprak; alias: fan, vantilatör
    - **Isıtıcı & Soba** `isitici-soba` — atanabilir yaprak; alias: elektrikli ısıtıcı, infrared soba; risk: safety_critical
    - **Hava Temizleyici & Nem Cihazı** `hava-temizleyici-nem-cihazi` — atanabilir yaprak; alias: hava temizleyici, nemlendirici
    - **Saç Kurutma & Şekillendirme Cihazı** `sac-kurutma-sekillendirme-cihazi` — atanabilir yaprak; alias: saç kurutma makinesi, saç düzleştirici
    - **Tıraş & Epilasyon Cihazı** `tiras-epilasyon-cihazi` — atanabilir yaprak; alias: tıraş makinesi, epilatör
- **Ev & Yaşam** `ev-yasam` — Ana Kategori; alias: ev yaşam, ev & yaşam, ev dekorasyon
  - **Mobilya** `mobilya` — Alt Kategori
    - **Koltuk & Kanepe** `koltuk-kanepe` — atanabilir yaprak; alias: koltuk, kanepe, çekyat
    - **Masa & Sandalye** `masa-sandalye` — atanabilir yaprak; alias: yemek masası, sandalye
    - **Yatak, Baza & Başlık** `yatak-baza-baslik` — atanabilir yaprak; alias: yatak, baza, yatak başlığı
    - **Dolap & Şifonyer** `dolap-sifonyer` — atanabilir yaprak; alias: gardırop, şifonyer
    - **Raf, Kitaplık & TV Ünitesi** `raf-kitaplik-tv-unitesi` — atanabilir yaprak; alias: kitaplık, duvar rafı, TV sehpası
    - **Çalışma Mobilyası** `calisma-mobilyasi` — atanabilir yaprak; alias: çalışma masası, ofis sandalyesi
  - **Ev Tekstili** `ev-tekstili` — Alt Kategori
    - **Nevresim & Yatak Örtüsü** `nevresim-yatak-ortusu` — atanabilir yaprak; alias: nevresim takımı, yatak örtüsü
    - **Yastık & Yorgan** `yastik-yorgan` — atanabilir yaprak; alias: yastık, yorgan
    - **Havlu & Bornoz** `havlu-bornoz` — atanabilir yaprak; alias: banyo havlusu, bornoz
    - **Perde & Stor** `perde-stor` — atanabilir yaprak; alias: tül perde, stor perde
    - **Halı & Kilim** `hali-kilim` — atanabilir yaprak; alias: halı, kilim, yolluk
    - **Battaniye, Örtü & Kırlent** `battaniye-ortu-kirlent` — atanabilir yaprak; alias: battaniye, koltuk örtüsü, kırlent
  - **Dekorasyon & Aydınlatma** `dekorasyon-aydinlatma` — Alt Kategori
    - **Avize & Tavan Aydınlatması** `avize-tavan-aydinlatmasi` — atanabilir yaprak; alias: avize, plafonyer
    - **Masa, Lambader & Gece Lambası** `masa-lambader-gece-lambasi` — atanabilir yaprak; alias: abajur, lambader, gece lambası
    - **Ampul & Dekoratif Işık** `ampul-dekoratif-isik` — atanabilir yaprak; alias: ampul, LED şerit, ışık zinciri
    - **Ayna** `ayna` — atanabilir yaprak; alias: duvar aynası, boy aynası
    - **Çerçeve & Duvar Dekoru** `cerceve-duvar-dekoru` — atanabilir yaprak; alias: resim çerçevesi, tablo, duvar süsü
    - **Duvar & Masa Saati** `duvar-masa-saati` — atanabilir yaprak; alias: duvar saati, masa saati
    - **Mum & Oda Kokusu** `mum-oda-kokusu` — atanabilir yaprak; alias: kokulu mum, buhurdanlık, oda kokusu; risk: hazmat_review
  - **Banyo & Düzenleme** `banyo-duzenleme` — Alt Kategori
    - **Banyo Aksesuar Seti** `banyo-aksesuar-seti` — atanabilir yaprak; alias: sabunluk, diş fırçalık
    - **Duş Perdesi & Banyo Paspası** `dus-perdesi-banyo-paspasi` — atanabilir yaprak; alias: duş perdesi, banyo paspası
    - **Çamaşır Sepeti** `camasir-sepeti` — atanabilir yaprak; alias: kirli sepeti
    - **Saklama Kutusu & Sepet** `saklama-kutusu-sepet` — atanabilir yaprak; alias: hurç, organizer kutu
    - **Askı & Dolap Düzenleyici** `aski-dolap-duzenleyici` — atanabilir yaprak; alias: elbise askısı, dolap organizer
  - **Ev Temizlik & Tüketim Ürünleri** `ev-temizlik-tuketim-urunleri` — Alt Kategori
    - **Temizlik Deterjanı** `temizlik-deterjani` — atanabilir yaprak; alias: yüzey temizleyici, bulaşık deterjanı; risk: hazmat_review
    - **Çamaşır Bakım Ürünü** `camasir-bakim-urunu` — atanabilir yaprak; alias: çamaşır deterjanı, yumuşatıcı; risk: hazmat_review
    - **Süpürge, Mop & Temizlik Bezi** `supurge-mop-temizlik-bezi` — atanabilir yaprak; alias: mop, çekpas, mikrofiber bez
    - **Kağıt Ürünleri** `ev-kagit-urunleri` — atanabilir yaprak; alias: tuvalet kağıdı, kağıt havlu, peçete
    - **Çöp Torbası & Ev Eldiveni** `cop-torbasi-ev-eldiveni` — atanabilir yaprak; alias: çöp poşeti, temizlik eldiveni
- **Züccaciye & Mutfak** `zuccaciye-mutfak` — Ana Kategori; alias: züccaciye, zuccaciye, mutfak gereçleri
  - **Pişirme Gereçleri** `pisirme-gerecleri` — Alt Kategori
    - **Tencere & Tencere Seti** `tencere-seti` — atanabilir yaprak; alias: tencere, tencere takımı
    - **Tava & Sahan** `tava-sahan` — atanabilir yaprak; alias: tava, sahan
    - **Düdüklü Tencere** `duduklu-tencere` — atanabilir yaprak; alias: basınçlı tencere; risk: safety_critical
    - **Çaydanlık & Cezve** `caydanlik-cezve` — atanabilir yaprak; alias: çaydanlık, cezve
    - **Fırın Kabı & Tepsi** `firin-kabi-tepsi` — atanabilir yaprak; alias: borcam, fırın tepsisi
    - **Kek Kalıbı & Pişirme Kalıbı** `kek-kalibi-pisirme-kalibi` — atanabilir yaprak; alias: kek kalıbı, kurabiye kalıbı
  - **Hazırlık & Kesme Gereçleri** `hazirlik-kesme-gerecleri` — Alt Kategori
    - **Mutfak Bıçağı & Bıçak Seti** `mutfak-bicagi-bicak-seti` — atanabilir yaprak; alias: şef bıçağı, bıçak takımı; risk: safety_critical
    - **Kesme Tahtası** `kesme-tahtasi` — atanabilir yaprak; alias: doğrama tahtası
    - **Rende, Soyacak & Dilimleyici** `rende-soyacak-dilimleyici` — atanabilir yaprak; alias: rende, soyacak, mandolin
    - **Karıştırma Kabı & Ölçü Gereci** `karistirma-kabi-olcu-gereci` — atanabilir yaprak; alias: karıştırma kabı, ölçü kabı
    - **Mutfak El Aleti** `mutfak-el-aleti` — atanabilir yaprak; alias: spatula, maşa, kepçe, çırpıcı
  - **Sofra & Servis** `sofra-servis` — Alt Kategori
    - **Yemek Takımı** `yemek-takimi` — atanabilir yaprak; alias: porselen yemek takımı
    - **Tabak & Kase** `tabak-kase` — atanabilir yaprak; alias: servis tabağı, çorba kasesi
    - **Çatal, Kaşık & Bıçak Takımı** `catal-kasik-bicak-takimi` — atanabilir yaprak; alias: çatal kaşık takımı, çkb takımı
    - **Servis Tabağı & Sunum Gereci** `servis-tabagi-sunum-gereci` — atanabilir yaprak; alias: sunum tahtası, servis kasesi
    - **Tepsi** `tepsi` — atanabilir yaprak; alias: servis tepsisi
  - **Bardak & İçecek Servisi** `bardak-icecek-servisi` — Alt Kategori
    - **Su & Meşrubat Bardağı** `su-mesrubat-bardagi` — atanabilir yaprak; alias: su bardağı, meşrubat bardağı
    - **Çay Bardağı & Fincan** `cay-bardagi-fincan` — atanabilir yaprak; alias: çay bardağı, kahve fincanı
    - **Kupa** `kupa` — atanabilir yaprak; alias: mug, kupa bardak
    - **Sürahi & Karaf** `surahi-karaf` — atanabilir yaprak; alias: sürahi, karaf
    - **Termos & Matara** `termos-matara` — atanabilir yaprak; alias: termos, su matarası
  - **Mutfak Saklama & Düzenleme** `mutfak-saklama-duzenleme` — Alt Kategori
    - **Saklama Kabı** `saklama-kabi` — atanabilir yaprak; alias: erzak kabı, kavanoz
    - **Baharatlık & Yağlık** `baharatlik-yaglik` — atanabilir yaprak; alias: baharatlık, yağdanlık
    - **Beslenme Kutusu** `beslenme-kutusu` — atanabilir yaprak; alias: sefer tası, lunch box
    - **Mutfak Rafı & Düzenleyici** `mutfak-rafi-duzenleyici` — atanabilir yaprak; alias: mutfak organizer, tabaklık
    - **Buz Kalıbı & Soğutucu Çanta** `buz-kalibi-sogutucu-canta` — atanabilir yaprak; alias: buz kalıbı, termal çanta
- **Yapı & Hırdavat** `yapi-hirdavat` — Ana Kategori; alias: hırdavat, hirdavat, nalbur, yapı malzemesi
  - **El Aletleri** `el-aletleri` — Alt Kategori
    - **Tornavida & Anahtar** `tornavida-anahtar` — atanabilir yaprak; alias: tornavida, lokma anahtar, alyan
    - **Pense, Kerpeten & Kesici** `pense-kerpeten-kesici` — atanabilir yaprak; alias: pense, yan keski, kerpeten
    - **Çekiç & Tokmak** `cekic-tokmak` — atanabilir yaprak; alias: çekiç, tokmak
    - **Ölçüm & İşaretleme Aleti** `olcum-isaretleme-aleti` — atanabilir yaprak; alias: metre, su terazisi, şerit metre
    - **Testere & Eğeleme Aleti** `testere-egeleme-aleti` — atanabilir yaprak; alias: el testeresi, eğe
  - **Elektrikli El Aletleri** `elektrikli-el-aletleri` — Alt Kategori
    - **Matkap & Vidalama** `matkap-vidalama` — atanabilir yaprak; alias: matkap, şarjlı vidalama; risk: safety_critical
    - **Taşlama & Polisaj** `taslama-polisaj` — atanabilir yaprak; alias: spiral, avuç taşlama; risk: safety_critical
    - **Elektrikli Testere** `elektrikli-testere` — atanabilir yaprak; alias: dekupaj, daire testere; risk: safety_critical
    - **Zımpara Makinesi** `zimpara-makinesi` — atanabilir yaprak; alias: titreşimli zımpara; risk: safety_critical
    - **Kaynak & Lehim Ekipmanı** `kaynak-lehim-ekipmani` — atanabilir yaprak; alias: kaynak makinesi, havya; risk: safety_critical
  - **Bağlantı, Kilit & Yapı Sarfı** `baglanti-kilit-yapi-sarfi` — Alt Kategori
    - **Vida, Çivi & Dübel** `vida-civi-dubel` — atanabilir yaprak; alias: vida, çivi, dübel
    - **Somun, Civata & Rondela** `somun-civata-rondela` — atanabilir yaprak; alias: somun, cıvata, rondela
    - **Kapı Kilidi & Silindir** `kapi-kilidi-silindir` — atanabilir yaprak; alias: kilit göbeği, barel
    - **Menteşe, Ray & Mobilya Donanımı** `mentese-ray-mobilya-donanimi` — atanabilir yaprak; alias: menteşe, çekmece rayı, kulpsuz donanım
    - **Halat, Zincir & Kanca** `halat-zincir-kanca` — atanabilir yaprak; alias: ip halat, zincir, karabina
  - **Boya, Yapıştırıcı & Kimyasal** `boya-yapistirici-kimyasal` — Alt Kategori
    - **İç & Dış Cephe Boyası** `ic-dis-cephe-boyasi` — atanabilir yaprak; alias: duvar boyası, tavan boyası; risk: hazmat_review
    - **Ahşap & Metal Boyası** `ahsap-metal-boyasi` — atanabilir yaprak; alias: vernik, sentetik boya; risk: hazmat_review
    - **Boya Fırçası & Rulo** `boya-fircasi-rulo` — atanabilir yaprak; alias: boya fırçası, rulo
    - **Yapıştırıcı & Bant** `yapistirici-bant` — atanabilir yaprak; alias: silikon, montaj yapıştırıcısı, koli bandı; risk: hazmat_review
    - **Derz, Dolgu & Mastik** `derz-dolgu-mastik` — atanabilir yaprak; alias: derz dolgu, mastik, poliüretan köpük; risk: hazmat_review
  - **Tesisat & Elektrik Malzemeleri** `tesisat-elektrik-malzemeleri` — Alt Kategori
    - **Musluk, Batarya & Duş Sistemi** `musluk-batarya-dus-sistemi` — atanabilir yaprak; alias: lavabo bataryası, duş başlığı
    - **Boru, Hortum & Tesisat Bağlantısı** `boru-hortum-tesisat-baglantisi` — atanabilir yaprak; alias: PVC boru, tesisat rekoru
    - **Vana & Sifon** `vana-sifon` — atanabilir yaprak; alias: küresel vana, lavabo sifonu
    - **Priz, Anahtar & Fiş** `priz-anahtar-fis` — atanabilir yaprak; alias: elektrik prizi, duvar anahtarı, fiş; risk: safety_critical
    - **Kablo & Elektrik Bağlantı Elemanı** `kablo-elektrik-baglanti-elemani` — atanabilir yaprak; alias: elektrik kablosu, klemens; risk: safety_critical
    - **Sigorta & Elektrik Panosu** `sigorta-elektrik-panosu` — atanabilir yaprak; alias: otomatik sigorta, kaçak akım rölesi; risk: safety_critical
  - **Yapı Malzemesi & İş Güvenliği** `yapi-malzemesi-is-guvenligi` — Alt Kategori
    - **Çimento, Harç & Sıva** `cimento-harc-siva` — atanabilir yaprak; alias: çimento, hazır harç, alçı
    - **Seramik & Zemin Kaplama** `seramik-zemin-kaplama` — atanabilir yaprak; alias: fayans, laminat, parke
    - **Isı, Su & Ses Yalıtımı** `isi-su-ses-yalitimi` — atanabilir yaprak; alias: yalıtım malzemesi, membran
    - **Merdiven & İskele Ekipmanı** `merdiven-iskele-ekipmani` — atanabilir yaprak; alias: katlanır merdiven, platform; risk: safety_critical
    - **İş Eldiveni & Koruyucu Donanım** `is-eldiveni-koruyucu-donanim` — atanabilir yaprak; alias: baret, koruyucu gözlük, iş eldiveni; risk: safety_critical
- **Otomotiv & Motosiklet** `otomotiv-motosiklet` — Ana Kategori; alias: oto aksesuar, otomotiv, araba aksesuarı, motosiklet aksesuarı
  - **Araç İçi & Dış Aksesuar** `arac-ici-dis-aksesuar` — Alt Kategori
    - **Oto Paspas & Bagaj Havuzu** `oto-paspas-bagaj-havuzu` — atanabilir yaprak; alias: araba paspası, bagaj havuzu
    - **Koltuk Kılıfı & Direksiyon Kılıfı** `oto-koltuk-direksiyon-kilifi` — atanabilir yaprak; alias: oto koltuk kılıfı, direksiyon kılıfı
    - **Araç İçi Düzenleyici** `arac-ici-duzenleyici` — atanabilir yaprak; alias: bagaj organizer, koltuk arkası düzenleyici
    - **Silecek & Ayna** `silecek-ayna` — atanabilir yaprak; alias: silecek süpürgesi, dikiz aynası; risk: compatibility_critical
    - **Oto Dış Koruma & Kaplama** `oto-dis-koruma-kaplama` — atanabilir yaprak; alias: araç brandası, kapı koruyucu, folyo
    - **Araç Aydınlatması** `arac-aydinlatmasi` — atanabilir yaprak; alias: far ampulü, sinyal lambası; risk: safety_critical, compatibility_critical
  - **Oto Elektroniği & Bakım** `oto-elektronigi-bakim` — Alt Kategori
    - **Oto Multimedya & Ses** `oto-multimedya-ses` — atanabilir yaprak; alias: teyp, araç ekranı, oto hoparlör
    - **Araç Kamerası & Navigasyon** `arac-kamerasi-navigasyon` — atanabilir yaprak; alias: dashcam, yol kamerası, navigasyon
    - **Araç Şarj & Dönüştürücü** `arac-sarj-donusturucu` — atanabilir yaprak; alias: çakmaklık şarjı, inverter
    - **Oto Temizlik & Bakım Ürünü** `oto-temizlik-bakim-urunu` — atanabilir yaprak; alias: oto şampuanı, cila, torpido temizleyici; risk: hazmat_review
    - **Motor Yağı & Araç Sıvısı** `motor-yagi-arac-sivisi` — atanabilir yaprak; alias: motor yağı, antifriz, fren hidroliği; risk: hazmat_review, compatibility_critical
    - **Akü & Takviye Ekipmanı** `aku-takviye-ekipmani` — atanabilir yaprak; alias: oto aküsü, akü takviye kablosu; risk: hazmat_review, safety_critical, compatibility_critical
  - **Oto Yedek Parça** `oto-yedek-parca` — Alt Kategori; risk: compatibility_critical
    - **Motor Bakım Parçaları** `motor-bakim-parcalari` — Ürün Grubu
      - **Oto Filtreleri** `oto-filtreleri` — atanabilir yaprak; alias: yağ filtresi, hava filtresi, polen filtresi; risk: compatibility_critical
      - **Buji & Ateşleme Parçası** `buji-atesleme-parcasi` — atanabilir yaprak; alias: buji, ateşleme bobini; risk: compatibility_critical
      - **Kayış & Gergi Parçası** `kayis-gergi-parcasi` — atanabilir yaprak; alias: triger kayışı, V kayışı; risk: safety_critical, compatibility_critical
    - **Fren Parçaları** `fren-parcalari` — Ürün Grubu; risk: safety_critical
      - **Fren Balatası** `fren-balatasi` — atanabilir yaprak; alias: balata; risk: safety_critical, compatibility_critical
      - **Fren Diski & Kampana** `fren-diski-kampana` — atanabilir yaprak; alias: fren diski, kampana; risk: safety_critical, compatibility_critical
    - **Süspansiyon & Direksiyon Parçası** `suspansiyon-direksiyon-parcasi` — atanabilir yaprak; alias: amortisör, rot başı, salıncak; risk: safety_critical, compatibility_critical
    - **Debriyaj & Şanzıman Parçası** `debriyaj-sanziman-parcasi` — atanabilir yaprak; alias: debriyaj seti, şanzıman parçası; risk: safety_critical, compatibility_critical
    - **Egzoz & Emisyon Parçası** `egzoz-emisyon-parcasi` — atanabilir yaprak; alias: egzoz, katalizör; risk: compatibility_critical
    - **Kaporta & Tampon Parçası** `kaporta-tampon-parcasi` — atanabilir yaprak; alias: çamurluk, tampon, kapı parçası; risk: compatibility_critical
  - **Lastik, Jant & Yol Ekipmanı** `lastik-jant-yol-ekipmani` — Alt Kategori
    - **Otomobil Lastiği** `otomobil-lastigi` — atanabilir yaprak; alias: oto lastik, yaz lastiği, kış lastiği; risk: safety_critical, compatibility_critical
    - **Jant & Jant Kapağı** `jant-jant-kapagi` — atanabilir yaprak; alias: çelik jant, alaşım jant, jant kapağı; risk: compatibility_critical
    - **Kar Zinciri & Patinaj Önleyici** `kar-zinciri-patinaj-onleyici` — atanabilir yaprak; alias: kar zinciri, kar çorabı; risk: safety_critical, compatibility_critical
    - **Lastik Tamir & Şişirme** `lastik-tamir-sisirme` — atanabilir yaprak; alias: lastik tamir kiti, oto kompresörü
    - **Acil Yol & Çekme Ekipmanı** `acil-yol-cekme-ekipmani` — atanabilir yaprak; alias: reflektör, çekme halatı, takviye seti; risk: safety_critical
  - **Motosiklet Ekipmanı & Parçası** `motosiklet-ekipmani-parcasi` — Alt Kategori
    - **Motosiklet Kaskı** `motosiklet-kaski` — atanabilir yaprak; alias: motor kaskı, motosiklet kaskı; risk: safety_critical
    - **Motosiklet Koruma Giyimi** `motosiklet-koruma-giyimi` — atanabilir yaprak; alias: motosiklet montu, dizlik, koruma eldiveni; risk: safety_critical
    - **Motosiklet Çanta & Taşıma** `motosiklet-canta-tasima` — atanabilir yaprak; alias: topcase, yan çanta
    - **Motosiklet Aksesuarı** `motosiklet-aksesuari` — atanabilir yaprak; alias: telefon tutucu, ön cam, elcik
    - **Motosiklet Yedek Parçası** `motosiklet-yedek-parcasi` — atanabilir yaprak; alias: motor parçası, motosiklet balatası; risk: safety_critical, compatibility_critical
    - **Motosiklet Lastiği & Bakım Ürünü** `motosiklet-lastigi-bakim-urunu` — atanabilir yaprak; alias: motor lastiği, zincir yağı; risk: safety_critical, hazmat_review, compatibility_critical
- **Kişisel Bakım & Kozmetik** `kisisel-bakim-kozmetik` — Ana Kategori; alias: kozmetik, kişisel bakım, güzellik ürünleri
  - **Cilt Bakımı** `cilt-bakimi` — Alt Kategori
    - **Yüz Temizleyici** `yuz-temizleyici` — atanabilir yaprak; alias: yüz yıkama jeli, misel su
    - **Nemlendirici & Serum** `nemlendirici-serum` — atanabilir yaprak; alias: yüz kremi, cilt serumu
    - **Güneş Koruyucu** `gunes-koruyucu` — atanabilir yaprak; alias: güneş kremi, sun screen; risk: claim_sensitive
    - **Maske & Peeling** `maske-peeling` — atanabilir yaprak; alias: yüz maskesi, peeling
    - **Göz & Dudak Bakımı** `goz-dudak-bakimi` — atanabilir yaprak; alias: göz çevresi kremi, dudak balmı
  - **Makyaj** `makyaj` — Alt Kategori
    - **Ten Makyajı** `ten-makyaji` — atanabilir yaprak; alias: fondöten, kapatıcı, pudra
    - **Göz Makyajı** `goz-makyaji` — atanabilir yaprak; alias: maskara, eyeliner, far
    - **Dudak Makyajı** `dudak-makyaji` — atanabilir yaprak; alias: ruj, dudak kalemi, lip gloss
    - **Tırnak Ürünü** `tirnak-urunu` — atanabilir yaprak; alias: oje, tırnak bakım ürünü
    - **Makyaj Fırçası & Süngeri** `makyaj-fircasi-sungeri` — atanabilir yaprak; alias: makyaj fırçası, beauty blender
  - **Saç Bakımı & Şekillendirme** `sac-bakimi-sekillendirme` — Alt Kategori
    - **Şampuan** `sampuan` — atanabilir yaprak; alias: şampuan, sampuan
    - **Saç Kremi & Maske** `sac-kremi-maske` — atanabilir yaprak; alias: saç kremi, saç maskesi
    - **Saç Boyası & Açıcı** `sac-boyasi-acici` — atanabilir yaprak; alias: saç boyası, oksidan; risk: hazmat_review, claim_sensitive
    - **Saç Şekillendirici Ürün** `sac-sekillendirici-urun` — atanabilir yaprak; alias: jöle, wax, saç spreyi; risk: hazmat_review
    - **Tarak, Fırça & Saç Gereci** `tarak-firca-sac-gereci` — atanabilir yaprak; alias: tarak, saç fırçası, bigudi
  - **Banyo, Vücut & Hijyen** `banyo-vucut-hijyen` — Alt Kategori
    - **Sabun & Duş Ürünü** `sabun-dus-urunu` — atanabilir yaprak; alias: sabun, duş jeli, banyo köpüğü
    - **Deodorant & Ter Önleyici** `deodorant-ter-onleyici` — atanabilir yaprak; alias: deodorant, roll-on; risk: hazmat_review
    - **Vücut Bakımı** `vucut-bakimi` — atanabilir yaprak; alias: vücut losyonu, el kremi, ayak kremi
    - **Ağız Bakımı** `agiz-bakimi` — atanabilir yaprak; alias: diş macunu, diş fırçası, ağız gargarası
    - **Kadın Hijyen Ürünü** `kadin-hijyen-urunu` — atanabilir yaprak; alias: ped, tampon, menstrual kap
    - **Pamuk, Mendil & Bakım Sarfı** `pamuk-mendil-bakim-sarfi` — atanabilir yaprak; alias: makyaj pamuğu, ıslak mendil, kulak çubuğu
  - **Parfüm, Tıraş & El-Ayak Bakımı** `parfum-tiras-el-ayak-bakimi` — Alt Kategori
    - **Parfüm** `parfum` — atanabilir yaprak; alias: parfüm, parfum, EDP, EDT; risk: hazmat_review
    - **Kolonya & Vücut Spreyi** `kolonya-vucut-spreyi` — atanabilir yaprak; alias: kolonya, body mist; risk: hazmat_review
    - **Tıraş Ürünü** `tiras-urunu` — atanabilir yaprak; alias: tıraş köpüğü, jilet, tıraş sonrası
    - **Ağda & Tüy Alma Ürünü** `agda-tuy-alma-urunu` — atanabilir yaprak; alias: ağda, tüy dökücü
    - **Manikür & Pedikür Gereci** `manikur-pedikur-gereci` — atanabilir yaprak; alias: tırnak makası, manikür seti
- **Bebek & Çocuk** `bebek-cocuk` — Ana Kategori; alias: bebek ürünleri, çocuk ürünleri, anne bebek
  - **Bebek Bezi & Bakım** `bebek-bezi-bakim` — Alt Kategori
    - **Bebek Bezi** `bebek-bezi` — atanabilir yaprak; alias: çocuk bezi, yenidoğan bezi
    - **Bebek Islak Mendili** `bebek-islak-mendili` — atanabilir yaprak; alias: ıslak havlu, bebek mendili
    - **Bebek Cilt Bakımı** `bebek-cilt-bakimi` — atanabilir yaprak; alias: pişik kremi, bebek yağı, bebek losyonu; risk: claim_sensitive
    - **Bebek Banyo Ürünü** `bebek-banyo-urunu` — atanabilir yaprak; alias: bebek şampuanı, bebek sabunu
    - **Alt Değiştirme & Bakım Gereci** `alt-degistirme-bakim-gereci` — atanabilir yaprak; alias: alt açma minderi, bebek bakım seti
  - **Bebek Beslenme** `bebek-beslenme` — Alt Kategori
    - **Biberon & Biberon Aksesuarı** `biberon-biberon-aksesuari` — atanabilir yaprak; alias: biberon, biberon emziği; risk: age_sensitive, safety_critical
    - **Mama Sandalyesi** `mama-sandalyesi` — atanabilir yaprak; alias: bebek yemek sandalyesi; risk: safety_critical
    - **Bebek Tabak, Kaşık & Suluk** `bebek-tabak-kasik-suluk` — atanabilir yaprak; alias: bebek yemek seti, alıştırma bardağı
    - **Göğüs Pompası & Emzirme Ürünü** `gogus-pompasi-emzirme-urunu` — atanabilir yaprak; alias: süt pompası, emzirme minderi
    - **Bebek Maması & Ek Gıda** `bebek-mamasi-ek-gida` — atanabilir yaprak; alias: mama, bebek ek gıda; risk: regulated_review, claim_sensitive
  - **Bebek Taşıma & Güvenlik** `bebek-tasima-guvenlik` — Alt Kategori
    - **Bebek Arabası** `bebek-arabasi` — atanabilir yaprak; alias: puset, çocuk arabası; risk: safety_critical
    - **Oto Koltuğu & Yükseltici** `bebek-oto-koltugu-yukseltici` — atanabilir yaprak; alias: çocuk oto koltuğu, booster; risk: safety_critical, compatibility_critical
    - **Ana Kucağı & Bebek Taşıyıcı** `ana-kucagi-bebek-tasiyici` — atanabilir yaprak; alias: kanguru, sling, ana kucağı; risk: safety_critical
    - **Park Yatak & Seyahat Yatağı** `park-yatak-seyahat-yatagi` — atanabilir yaprak; alias: park yatak, oyun parkı; risk: safety_critical
    - **Ev İçi Bebek Güvenliği** `ev-ici-bebek-guvenligi` — atanabilir yaprak; alias: güvenlik kapısı, priz koruyucu, köşe koruyucu; risk: safety_critical
  - **Bebek Odası & Gelişim Gereçleri** `bebek-odasi-gelisim-gerecleri` — Alt Kategori
    - **Bebek Beşiği & Karyolası** `bebek-besigi-karyolasi` — atanabilir yaprak; alias: beşik, bebek karyolası; risk: safety_critical
    - **Bebek Yatağı & Uyku Tekstili** `bebek-yatagi-uyku-tekstili` — atanabilir yaprak; alias: bebek yatağı, bebek nevresimi; risk: safety_critical
    - **Bebek Odası Mobilyası** `bebek-odasi-mobilyasi` — atanabilir yaprak; alias: bebek dolabı, alt değiştirme ünitesi
    - **Lazımlık & Tuvalet Eğitimi** `lazimlik-tuvalet-egitimi` — atanabilir yaprak; alias: lazımlık, klozet adaptörü
    - **Emzik & Diş Kaşıyıcı** `emzik-dis-kasiyici` — atanabilir yaprak; alias: emzik, diş kaşıyıcı; risk: age_sensitive, safety_critical
- **Oyuncak, Hobi & Müzik** `oyuncak-hobi-muzik` — Ana Kategori; alias: oyuncak, hobi, müzik aleti, enstrüman
  - **Erken Yaş & Eğitici Oyuncak** `erken-yas-egitici-oyuncak` — Alt Kategori
    - **Bebek Oyuncağı** `bebek-oyuncagi` — atanabilir yaprak; alias: çıngırak, aktivite oyuncağı; risk: age_sensitive
    - **Eğitici Oyuncak** `egitici-oyuncak` — atanabilir yaprak; alias: öğretici oyuncak, Montessori oyuncak; risk: age_sensitive
    - **Ahşap Oyuncak** `ahsap-oyuncak` — atanabilir yaprak; alias: tahta oyuncak; risk: age_sensitive
    - **Bilim & Deney Seti** `bilim-deney-seti` — atanabilir yaprak; alias: STEM oyuncak, deney kiti; risk: age_sensitive, hazmat_review
  - **Figür, Bebek & Rol Oyunu** `figur-bebek-rol-oyunu` — Alt Kategori
    - **Oyuncak Bebek & Aksesuarı** `oyuncak-bebek-aksesuari` — atanabilir yaprak; alias: oyuncak bebek, bebek evi
    - **Aksiyon Figürü** `aksiyon-figuru` — atanabilir yaprak; alias: oyuncak figür, karakter figürü
    - **Peluş Oyuncak** `pelus-oyuncak` — atanabilir yaprak; alias: peluş, oyuncak ayı
    - **Mutfak, Doktor & Meslek Seti** `meslek-rol-oyunu-seti` — atanabilir yaprak; alias: oyuncak mutfak, doktor seti
    - **Kostüm & Rol Oyunu Aksesuarı** `kostum-rol-oyunu-aksesuari` — atanabilir yaprak; alias: çocuk kostümü, maske
  - **Araç, Yapı & Uzaktan Kumandalı Oyuncak** `arac-yapi-uzaktan-kumandali-oyuncak` — Alt Kategori
    - **Oyuncak Araba & Araç** `oyuncak-araba-arac` — atanabilir yaprak; alias: oyuncak araba, iş makinesi oyuncağı
    - **Yapı Bloku & İnşa Seti** `yapi-bloku-insa-seti` — atanabilir yaprak; alias: blok oyuncak, yapım seti
    - **Tren & Pist Seti** `tren-pist-seti` — atanabilir yaprak; alias: oyuncak tren, araba pisti
    - **Uzaktan Kumandalı Araç** `uzaktan-kumandali-arac` — atanabilir yaprak; alias: RC araba, kumandalı oyuncak; risk: age_sensitive
    - **Oyuncak Drone** `oyuncak-drone` — atanabilir yaprak; alias: mini drone, çocuk drone; risk: regulated_review, safety_critical, age_sensitive
  - **Oyun, Puzzle & Sanat Hobisi** `oyun-puzzle-sanat-hobisi` — Alt Kategori
    - **Kutu Oyunu** `kutu-oyunu` — atanabilir yaprak; alias: masa oyunu, board game
    - **Puzzle** `puzzle` — atanabilir yaprak; alias: yapboz
    - **Kart Oyunu** `kart-oyunu` — atanabilir yaprak; alias: oyun kartı
    - **Boyama & Çocuk Sanat Seti** `boyama-cocuk-sanat-seti` — atanabilir yaprak; alias: boyama seti, parmak boya
    - **Model, Maket & Koleksiyon Kiti** `model-maket-koleksiyon-kiti` — atanabilir yaprak; alias: maket, model kit, minyatür
  - **Müzik Enstrümanı & Ekipmanı** `muzik-enstrumani-ekipmani` — Alt Kategori
    - **Gitar & Telli Çalgı** `gitar-telli-calgi` — atanabilir yaprak; alias: gitar, bağlama, ukulele
    - **Klavye & Piyano** `klavye-piyano` — atanabilir yaprak; alias: org, dijital piyano
    - **Davul & Vurmalı Çalgı** `davul-vurmali-calgi` — atanabilir yaprak; alias: davul, darbuka, perküsyon
    - **Nefesli Çalgı** `nefesli-calgi` — atanabilir yaprak; alias: flüt, klarnet, saksafon
    - **Enstrüman Aksesuarı** `enstruman-aksesuari` — atanabilir yaprak; alias: gitar teli, nota sehpası, enstrüman çantası
- **Spor & Outdoor** `spor-outdoor` — Ana Kategori; alias: spor, outdoor, kamp, fitness
  - **Fitness & Antrenman** `fitness-antrenman` — Alt Kategori
    - **Ağırlık & Dambıl** `agirlik-dambil` — atanabilir yaprak; alias: dambıl, halter, ağırlık plakası
    - **Yoga & Pilates Ekipmanı** `yoga-pilates-ekipmani` — atanabilir yaprak; alias: yoga matı, pilates topu
    - **Kondisyon Aleti** `kondisyon-aleti` — atanabilir yaprak; alias: koşu bandı, eliptik bisiklet
    - **Direnç Bandı & Atlama İpi** `direnc-bandi-atlama-ipi` — atanabilir yaprak; alias: egzersiz bandı, ip atlama
    - **Spor Koruyucu & Destek** `spor-koruyucu-destek` — atanabilir yaprak; alias: dizlik, bileklik, spor bandajı; risk: claim_sensitive
  - **Takım & Raket Sporları** `takim-raket-sporlari` — Alt Kategori
    - **Futbol Ekipmanı** `futbol-ekipmani` — atanabilir yaprak; alias: futbol topu, kale, tekmelik
    - **Basketbol & Voleybol Ekipmanı** `basketbol-voleybol-ekipmani` — atanabilir yaprak; alias: basketbol topu, voleybol topu
    - **Tenis & Badminton Ekipmanı** `tenis-badminton-ekipmani` — atanabilir yaprak; alias: tenis raketi, badminton raketi
    - **Masa Tenisi Ekipmanı** `masa-tenisi-ekipmani` — atanabilir yaprak; alias: pinpon raketi, masa tenisi topu
    - **Kaleci & Takım Koruma Ekipmanı** `kaleci-takim-koruma-ekipmani` — atanabilir yaprak; alias: kaleci eldiveni, tekmelik; risk: safety_critical
  - **Bisiklet, Paten & Kaykay** `bisiklet-paten-kaykay` — Alt Kategori
    - **Bisiklet** `bisiklet` — atanabilir yaprak; alias: şehir bisikleti, dağ bisikleti
    - **Bisiklet Parçası & Aksesuarı** `bisiklet-parcasi-aksesuari` — atanabilir yaprak; alias: bisiklet lastiği, bisiklet lambası; risk: compatibility_critical
    - **Bisiklet Kaskı & Koruması** `bisiklet-kaski-korumasi` — atanabilir yaprak; alias: bisiklet kaskı, dirseklik; risk: safety_critical
    - **Paten** `paten` — atanabilir yaprak; alias: inline skate, roller skate
    - **Kaykay & Scooter** `kaykay-scooter` — atanabilir yaprak; alias: skateboard, scooter; risk: safety_critical
  - **Kamp, Yürüyüş & Outdoor** `kamp-yuruyus-outdoor` — Alt Kategori
    - **Çadır** `cadir` — atanabilir yaprak; alias: kamp çadırı
    - **Uyku Tulumu & Kamp Matı** `uyku-tulumu-kamp-mati` — atanabilir yaprak; alias: uyku tulumu, kamp matı
    - **Kamp Mobilyası** `kamp-mobilyasi` — atanabilir yaprak; alias: kamp sandalyesi, kamp masası
    - **Kamp Ocağı & Pişirme Ekipmanı** `kamp-ocagi-pisirme-ekipmani` — atanabilir yaprak; alias: kamp ocağı, kamp tenceresi; risk: hazmat_review, safety_critical
    - **Fener & Outdoor Aydınlatma** `fener-outdoor-aydinlatma` — atanabilir yaprak; alias: el feneri, kafa lambası
    - **Trekking Bastonu & Outdoor Aksesuarı** `trekking-bastonu-outdoor-aksesuari` — atanabilir yaprak; alias: yürüyüş baton, pusula
  - **Balıkçılık, Su & Kış Sporları** `balikcilik-su-kis-sporlari` — Alt Kategori
    - **Olta & Balıkçılık Takımı** `olta-balikcilik-takimi` — atanabilir yaprak; alias: olta, makara, misina
    - **Yüzme Ekipmanı** `yuzme-ekipmani` — atanabilir yaprak; alias: yüzücü gözlüğü, bone, palet
    - **Şnorkel & Dalış Ekipmanı** `snorkel-dalis-ekipmani` — atanabilir yaprak; alias: şnorkel, dalış maskesi; risk: safety_critical
    - **Şişme Deniz Ürünü** `sisme-deniz-urunu` — atanabilir yaprak; alias: deniz yatağı, şişme bot; risk: safety_critical
    - **Kayak & Snowboard Ekipmanı** `kayak-snowboard-ekipmani` — atanabilir yaprak; alias: kayak, snowboard, kayak gözlüğü; risk: safety_critical
- **Kitap & Kırtasiye** `kitap-kirtasiye` — Ana Kategori; alias: kitap, kırtasiye, kirtasiye, ofis malzemesi
  - **Kitaplar** `kitaplar` — Alt Kategori
    - **Roman & Öykü** `roman-oyku` — atanabilir yaprak; alias: roman, öykü, hikaye kitabı
    - **Şiir & Edebiyat İnceleme** `siir-edebiyat-inceleme` — atanabilir yaprak; alias: şiir kitabı, edebiyat incelemesi
    - **Çocuk Kitabı** `cocuk-kitabi` — atanabilir yaprak; alias: masal kitabı, resimli kitap
    - **Gençlik Kitabı** `genclik-kitabi` — atanabilir yaprak; alias: genç kurgu
    - **Eğitim & Sınav Kitabı** `egitim-sinav-kitabi` — atanabilir yaprak; alias: test kitabı, soru bankası, ders kitabı
    - **Akademik & Mesleki Kitap** `akademik-mesleki-kitap` — atanabilir yaprak; alias: üniversite kitabı, mesleki yayın
    - **Araştırma, Tarih & Toplum** `arastirma-tarih-toplum-kitabi` — atanabilir yaprak; alias: tarih kitabı, siyaset kitabı, sosyoloji
    - **Bilim, Teknoloji & Doğa** `bilim-teknoloji-doga-kitabi` — atanabilir yaprak; alias: bilim kitabı, teknoloji kitabı
    - **Kişisel Gelişim & İş Dünyası** `kisisel-gelisim-is-dunyasi-kitabi` — atanabilir yaprak; alias: kişisel gelişim, ekonomi kitabı
    - **Din, Felsefe & Düşünce** `din-felsefe-dusunce-kitabi` — atanabilir yaprak; alias: felsefe kitabı, dini kitap
    - **Sanat, Hobi & Yaşam Kitabı** `sanat-hobi-yasam-kitabi` — atanabilir yaprak; alias: yemek kitabı, sanat kitabı, gezi kitabı
    - **Çizgi Roman & Manga** `cizgi-roman-manga` — atanabilir yaprak; alias: çizgi roman, manga
    - **Sözlük, Atlas & Başvuru** `sozluk-atlas-basvuru-kitabi` — atanabilir yaprak; alias: sözlük, atlas, ansiklopedi
  - **Yazım & Okul Gereçleri** `yazim-okul-gerecleri` — Alt Kategori
    - **Kurşun Kalem & Uç** `kursun-kalem-uc` — atanabilir yaprak; alias: kurşun kalem, versatil kalem, kalem ucu
    - **Tükenmez, Jel & Roller Kalem** `tukenmez-jel-roller-kalem` — atanabilir yaprak; alias: tükenmez kalem, jel kalem, roller kalem
    - **Dolma Kalem & Mürekkep** `dolma-kalem-murekkep` — atanabilir yaprak; alias: dolma kalem, kartuş mürekkep
    - **Keçeli, Fosforlu & Tahta Kalemi** `keceli-fosforlu-tahta-kalemi` — atanabilir yaprak; alias: keçeli kalem, fosforlu kalem, tahta kalemi
    - **Silgi, Kalemtıraş & Cetvel** `silgi-kalemtiras-cetvel` — atanabilir yaprak; alias: silgi, kalemtıraş, cetvel
    - **Kalemlik** `kalemlik` — atanabilir yaprak; alias: kalem kutusu
    - **Okul Geometri & Matematik Seti** `okul-geometri-matematik-seti` — atanabilir yaprak; alias: pergel, iletki, geometri seti
  - **Defter, Kağıt & Sunum** `defter-kagit-sunum` — Alt Kategori
    - **Defter** `defter` — atanabilir yaprak; alias: okul defteri, spiral defter
    - **Ajanda & Planlayıcı** `ajanda-planlayici` — atanabilir yaprak; alias: ajanda, planner
    - **Not Kağıdı & Yapışkanlı Not** `not-kagidi-yapiskanli-not` — atanabilir yaprak; alias: post-it, not kağıdı
    - **Fotokopi & Yazıcı Kağıdı** `fotokopi-yazici-kagidi` — atanabilir yaprak; alias: A4 kağıt, fotokopi kağıdı
    - **Resim & Fon Kartonu** `resim-fon-kartonu` — atanabilir yaprak; alias: resim kağıdı, fon kartonu, mukavva
    - **Etiket & Sticker** `etiket-sticker` — atanabilir yaprak; alias: etiket, sticker, çıkartma
    - **Yazı Tahtası & Pano** `yazi-tahtasi-pano` — atanabilir yaprak; alias: beyaz tahta, mantar pano
  - **Ofis, Dosyalama & Masaüstü** `ofis-dosyalama-masaustu` — Alt Kategori
    - **Klasör & Dosya** `klasor-dosya` — atanabilir yaprak; alias: klasör, sunum dosyası, şeffaf dosya
    - **Zımba, Delgeç & Ataş** `zimba-delgec-atas` — atanabilir yaprak; alias: zımba, delgeç, ataş
    - **Makas & Maket Bıçağı** `makas-maket-bicagi` — atanabilir yaprak; alias: ofis makası, falçata; risk: safety_critical
    - **Masaüstü Düzenleyici** `masaustu-duzenleyici` — atanabilir yaprak; alias: evrak rafı, kalemlik organizer
    - **Hesap Makinesi** `hesap-makinesi` — atanabilir yaprak; alias: calculator
    - **Kaşe, Istampa & Numaratör** `kase-istampa-numarator` — atanabilir yaprak; alias: kaşe, ıstampa, numaratör
  - **Sanat, El İşi & Paketleme** `sanat-el-isi-paketleme` — Alt Kategori
    - **Boya & Çizim Malzemesi** `boya-cizim-malzemesi` — atanabilir yaprak; alias: akrilik boya, sulu boya, pastel boya
    - **Tuval & Çizim Yüzeyi** `tuval-cizim-yuzeyi` — atanabilir yaprak; alias: tuval, eskiz defteri
    - **Fırça & Sanat Aracı** `firca-sanat-araci` — atanabilir yaprak; alias: resim fırçası, palet
    - **Hobi Kağıdı & El İşi Malzemesi** `hobi-kagidi-el-isi-malzemesi` — atanabilir yaprak; alias: keçe, eva, origami kağıdı
    - **Yapıştırıcı & Hobi Bandı** `kirtasiye-yapistirici-hobi-bandi` — atanabilir yaprak; alias: stick yapıştırıcı, washi tape; risk: hazmat_review
    - **Kargo Poşeti, Zarf & Kutu** `kargo-poseti-zarf-kutu` — atanabilir yaprak; alias: kargo poşeti, zarf, karton kutu
    - **Hediye Kağıdı & Paketleme** `hediye-kagidi-paketleme` — atanabilir yaprak; alias: hediye paketi, kurdele, paket süsü
- **Pet Shop** `pet-shop` — Ana Kategori; alias: petshop, evcil hayvan ürünü, kedi köpek malzemesi
  - **Evcil Hayvan Mamaları** `evcil-hayvan-mamalari` — Alt Kategori
    - **Köpek Maması** `kopek-mamasi` — Ürün Grubu
      - **Kuru Köpek Maması** `kuru-kopek-mamasi` — atanabilir yaprak; alias: köpek kuru mama
      - **Yaş Köpek Maması** `yas-kopek-mamasi` — atanabilir yaprak; alias: köpek yaş mama, konserve köpek maması
      - **Köpek Ödülü** `kopek-odulu` — atanabilir yaprak; alias: köpek ödül maması, köpek kemiği
    - **Kedi Maması** `kedi-mamasi` — Ürün Grubu
      - **Kuru Kedi Maması** `kuru-kedi-mamasi` — atanabilir yaprak; alias: kedi kuru mama
      - **Yaş Kedi Maması** `yas-kedi-mamasi` — atanabilir yaprak; alias: kedi yaş mama, konserve kedi maması
      - **Kedi Ödülü** `kedi-odulu` — atanabilir yaprak; alias: kedi ödül maması, kedi maltı
    - **Kuş Yemi** `kus-yemi` — atanabilir yaprak; alias: muhabbet kuşu yemi, kanarya yemi
    - **Balık Yemi** `balik-yemi` — atanabilir yaprak; alias: akvaryum balık yemi
    - **Küçük Hayvan Yemi** `kucuk-hayvan-yemi` — atanabilir yaprak; alias: kemirgen yemi, tavşan yemi
  - **Kedi & Köpek Ekipmanları** `kedi-kopek-ekipmanlari` — Alt Kategori
    - **Mama & Su Kabı** `pet-mama-su-kabi` — atanabilir yaprak; alias: kedi mama kabı, köpek su kabı
    - **Tasma, Kayış & Göğüs Tasması** `tasma-kayis-gogus-tasmasi` — atanabilir yaprak; alias: kedi tasması, köpek tasması, gezdirme kayışı
    - **Pet Yatağı & Minderi** `pet-yatagi-minderi` — atanabilir yaprak; alias: kedi yatağı, köpek yatağı
    - **Pet Taşıma Çantası & Kafesi** `pet-tasima-cantasi-kafesi` — atanabilir yaprak; alias: kedi taşıma çantası, köpek taşıma kafesi
    - **Kedi & Köpek Oyuncağı** `kedi-kopek-oyuncagi` — atanabilir yaprak; alias: kedi oyuncağı, köpek oyuncağı
    - **Kedi Tırmalama & Mobilyası** `kedi-tirmalama-mobilyasi` — atanabilir yaprak; alias: tırmalama tahtası, kedi evi
  - **Akvaryum, Kuş & Küçük Hayvan** `akvaryum-kus-kucuk-hayvan` — Alt Kategori
    - **Akvaryum** `akvaryum` — atanabilir yaprak; alias: balık akvaryumu
    - **Akvaryum Filtre & Pompası** `akvaryum-filtre-pompasi` — atanabilir yaprak; alias: akvaryum filtresi, hava motoru
    - **Akvaryum Dekor & Bakım Gereci** `akvaryum-dekor-bakim-gereci` — atanabilir yaprak; alias: akvaryum kumu, akvaryum dekoru
    - **Kuş Kafesi & Aksesuarı** `kus-kafesi-aksesuari` — atanabilir yaprak; alias: kuş kafesi, tünek, kuş suluğu
    - **Kemirgen Kafesi & Ekipmanı** `kemirgen-kafesi-ekipmani` — atanabilir yaprak; alias: hamster kafesi, kemirgen talaşı
  - **Pet Bakım, Hijyen & Sağlık Desteği** `pet-bakim-hijyen-saglik-destegi` — Alt Kategori
    - **Kedi Kumu & Tuvaleti** `kedi-kumu-tuvaleti` — atanabilir yaprak; alias: kedi kumu, kedi tuvaleti
    - **Pet Şampuanı & Tüy Bakımı** `pet-sampuani-tuy-bakimi` — atanabilir yaprak; alias: kedi şampuanı, köpek şampuanı, tüy tarağı
    - **Pet Temizlik & Koku Ürünü** `pet-temizlik-koku-urunu` — atanabilir yaprak; alias: pati temizleme, koku giderici; risk: claim_sensitive
    - **Pet Eğitim & Tuvalet Ürünü** `pet-egitim-tuvalet-urunu` — atanabilir yaprak; alias: çiş pedi, eğitim spreyi; risk: claim_sensitive
    - **Pet Sağlık & Destek Ürünü** `pet-saglik-destek-urunu` — atanabilir yaprak; alias: pet vitamini, pire tasması; risk: regulated_review, claim_sensitive
- **Optik, Saat & Takı** `optik-saat-taki` — Ana Kategori; alias: optik, gözlük, saat, takı
  - **Gözlük & Optik Ürünler** `gozluk-optik-urunler` — Alt Kategori
    - **Optik Gözlük Çerçevesi** `optik-gozluk-cercevesi` — atanabilir yaprak; alias: numaralı gözlük çerçevesi, gözlük çerçevesi; risk: regulated_review
    - **Güneş Gözlüğü** `gunes-gozlugu` — atanabilir yaprak; alias: güneş gözlüğü, sun glasses
    - **Hazır Okuma Gözlüğü** `hazir-okuma-gozlugu` — atanabilir yaprak; alias: okuma gözlüğü, yakın gözlüğü; risk: regulated_review, claim_sensitive
    - **Kontakt Lens** `kontakt-lens` — atanabilir yaprak; alias: lens, kontak lens; risk: regulated_review, claim_sensitive
    - **Lens Solüsyonu & Kabı** `lens-solusyonu-kabi` — atanabilir yaprak; alias: lens suyu, lens kabı; risk: regulated_review
    - **Gözlük Kılıfı & Bakım Ürünü** `gozluk-kilifi-bakim-urunu` — atanabilir yaprak; alias: gözlük kabı, gözlük bezi, gözlük ipi
  - **Saat & Saat Aksesuarları** `saat-saat-aksesuarlari` — Alt Kategori
    - **Kol Saati** `kol-saati` — atanabilir yaprak; alias: analog saat, dijital saat
    - **Cep & Yaka Saati** `cep-yaka-saati` — atanabilir yaprak; alias: cep saati, hemşire saati
    - **Saat Kayışı** `saat-kayisi` — atanabilir yaprak; alias: kordon, watch band
    - **Saat Kutusu & Standı** `saat-kutusu-standi` — atanabilir yaprak; alias: saat kutusu, saat standı
    - **Saat Pili & Yedek Bileşeni** `saat-pili-yedek-bileseni` — atanabilir yaprak; alias: saat pili, saat camı; risk: hazmat_review, compatibility_critical
  - **Takı & Mücevher** `taki-mucevher` — Alt Kategori
    - **Kolye & Uç** `kolye-uc` — atanabilir yaprak; alias: kolye, kolye ucu
    - **Küpe** `kupe` — atanabilir yaprak; alias: küpe, kupe
    - **Yüzük** `yuzuk` — atanabilir yaprak; alias: yüzük, alyans
    - **Bileklik & Halhal** `bileklik-halhal` — atanabilir yaprak; alias: bileklik, halhal
    - **Broş, Rozet & Piercing Takısı** `bros-rozet-piercing-takisi` — atanabilir yaprak; alias: broş, rozet, piercing
    - **Takı Kutusu & Bakım Ürünü** `taki-kutusu-bakim-urunu` — atanabilir yaprak; alias: mücevher kutusu, takı temizleme bezi
- **Sağlık & Medikal** `saglik-medikal` — Ana Kategori; alias: medikal, sağlık ürünü, medikal malzeme; risk: regulated_review
  - **İlk Yardım & Koruyucu Ürün** `ilk-yardim-koruyucu-urun` — Alt Kategori
    - **İlk Yardım Seti** `ilk-yardim-seti` — atanabilir yaprak; alias: ilk yardım çantası; risk: regulated_review
    - **Bandaj, Gazlı Bez & Flaster** `bandaj-gazli-bez-flaster` — atanabilir yaprak; alias: sargı bezi, gazlı bez, yara bandı; risk: regulated_review
    - **Antiseptik & Dezenfeksiyon Ürünü** `antiseptik-dezenfeksiyon-urunu` — atanabilir yaprak; alias: el antiseptiği, yara antiseptiği; risk: regulated_review, claim_sensitive, hazmat_review
    - **Sıcak & Soğuk Uygulama Ürünü** `sicak-soguk-uygulama-urunu` — atanabilir yaprak; alias: sıcak su torbası, soğuk jel paketi
    - **Tıbbi Maske & Muayene Eldiveni** `tibbi-maske-muayene-eldiveni` — atanabilir yaprak; alias: cerrahi maske, nitril eldiven; risk: regulated_review
  - **Ölçüm & Takip Cihazları** `olcum-takip-cihazlari` — Alt Kategori
    - **Ateş Ölçer** `ates-olcer` — atanabilir yaprak; alias: termometre, temassız ateş ölçer; risk: regulated_review
    - **Tansiyon Aleti** `tansiyon-aleti` — atanabilir yaprak; alias: tansiyon ölçer; risk: regulated_review
    - **Kan Şekeri Ölçüm Cihazı** `kan-sekeri-olcum-cihazi` — atanabilir yaprak; alias: şeker ölçüm cihazı, glukometre; risk: regulated_review
    - **Nabız Oksimetre** `nabiz-oksimetre` — atanabilir yaprak; alias: pulse oksimetre, oksijen ölçer; risk: regulated_review
    - **Vücut Tartısı & Analiz Cihazı** `vucut-tartisi-analiz-cihazi` — atanabilir yaprak; alias: baskül, yağ ölçer tartı; risk: claim_sensitive
  - **Ortopedi, Hareket & Solunum Desteği** `ortopedi-hareket-solunum-destegi` — Alt Kategori
    - **Ortez & Eklem Desteği** `ortez-eklem-destegi` — atanabilir yaprak; alias: dizlik, boyunluk, bileklik; risk: regulated_review, claim_sensitive
    - **Medikal Korse & Varis Çorabı** `medikal-korse-varis-corabi` — atanabilir yaprak; alias: bel korsesi, varis çorabı; risk: regulated_review, claim_sensitive
    - **Baston, Koltuk Değneği & Yürüteç** `baston-koltuk-degnegi-yurutec` — atanabilir yaprak; alias: baston, koltuk değneği, walker; risk: regulated_review, safety_critical
    - **Tekerlekli Sandalye** `tekerlekli-sandalye` — atanabilir yaprak; alias: manuel sandalye, akülü sandalye; risk: regulated_review, safety_critical
    - **Nebulizatör & Solunum Cihazı** `nebulizator-solunum-cihazi` — atanabilir yaprak; alias: hava makinesi, nebülizatör; risk: regulated_review
    - **Solunum Maskesi & Cihaz Aksesuarı** `solunum-maskesi-cihaz-aksesuari` — atanabilir yaprak; alias: CPAP maskesi, nebülizatör maskesi; risk: regulated_review, compatibility_critical
  - **Medikal Bakım & Günlük Yaşam** `medikal-bakim-gunluk-yasam` — Alt Kategori
    - **Yetişkin Hasta Bezi** `yetiskin-hasta-bezi` — atanabilir yaprak; alias: yetişkin bezi, emici külot
    - **Yatak Koruyucu & Hasta Bakım Örtüsü** `yatak-koruyucu-hasta-bakim-ortusu` — atanabilir yaprak; alias: yatak koruyucu örtü, hasta alt bezi
    - **Medikal Kompresyon & Bakım Tekstili** `medikal-kompresyon-bakim-tekstili` — atanabilir yaprak; alias: kompresyon ürünü, hasta bakım tekstili; risk: regulated_review
    - **İlaç Kutusu & Günlük Takip Gereci** `ilac-kutusu-gunluk-takip-gereci` — atanabilir yaprak; alias: hap kutusu, ilaç düzenleyici
    - **Banyo & Tuvalet Destek Ürünü** `banyo-tuvalet-destek-urunu` — atanabilir yaprak; alias: duş taburesi, klozet yükseltici; risk: safety_critical
  - **Besin Desteği & Koruyucu Sağlık Ürünü** `besin-destegi-koruyucu-saglik-urunu` — Alt Kategori
    - **Vitamin & Mineral Desteği** `vitamin-mineral-destegi` — atanabilir yaprak; alias: vitamin, mineral takviyesi; risk: regulated_review, claim_sensitive
    - **Protein & Sporcu Desteği** `protein-sporcu-destegi` — atanabilir yaprak; alias: protein tozu, amino asit; risk: regulated_review, claim_sensitive
    - **Bitkisel & Fonksiyonel Destek** `bitkisel-fonksiyonel-destek` — atanabilir yaprak; alias: bitkisel takviye, gıda takviyesi; risk: regulated_review, claim_sensitive
    - **Prezervatif & Bariyer Ürünü** `prezervatif-bariyer-urunu` — atanabilir yaprak; alias: kondom, prezervatif; risk: regulated_review
    - **Uyku & Rahatlama Gereci** `uyku-rahatlama-gereci` — atanabilir yaprak; alias: uyku maskesi, kulak tıkacı; risk: claim_sensitive
- **Çiçek, Bahçe & Hediyelik** `cicek-bahce-hediyelik` — Ana Kategori; alias: çiçekçi, çiçek, bahçe, hediyelik eşya
  - **Canlı Bitki & Çiçek** `canli-bitki-cicek` — Alt Kategori
    - **Saksı Bitkisi** `saksi-bitkisi` — atanabilir yaprak; alias: salon bitkisi, ev bitkisi
    - **Kaktüs & Sukulent** `kaktus-sukulent` — atanabilir yaprak; alias: kaktüs, sukulent
    - **Bahçe Bitkisi & Fidan** `bahce-bitkisi-fidan` — atanabilir yaprak; alias: fidan, bahçe çiçeği
    - **Kesme Çiçek & Buket** `kesme-cicek-buket` — atanabilir yaprak; alias: buket, gül buketi, çiçek buketi
    - **Çelenk & Aranjman** `celenk-aranjman` — atanabilir yaprak; alias: çiçek aranjmanı, çelenk
  - **Bahçe Yetiştirme & Bakım** `bahce-yetistirme-bakim` — Alt Kategori
    - **Tohum & Çiçek Soğanı** `tohum-cicek-sogani` — atanabilir yaprak; alias: tohum, fide tohumu, çiçek soğanı
    - **Toprak & Yetiştirme Ortamı** `toprak-yetistirme-ortami` — atanabilir yaprak; alias: saksı toprağı, torf
    - **Gübre & Bitki Besini** `gubre-bitki-besini` — atanabilir yaprak; alias: gübre, çiçek besini; risk: regulated_review, hazmat_review
    - **Saksı & Bitki Kabı** `saksi-bitki-kabi` — atanabilir yaprak; alias: saksı, fide kabı
    - **Sulama Ekipmanı** `sulama-ekipmani` — atanabilir yaprak; alias: sulama hortumu, sulama tabancası, sulama kabı
    - **Bahçe El Aleti** `bahce-el-aleti` — atanabilir yaprak; alias: budama makası, kürek, tırmık; risk: safety_critical
  - **Hediye & Hatıra** `hediye-hatira` — Alt Kategori
    - **Hediyelik Obje** `hediyelik-obje` — atanabilir yaprak; alias: biblo, masaüstü hediyelik
    - **Kişiselleştirilebilir Hediye** `kisisellestirilebilir-hediye` — atanabilir yaprak; alias: isimli hediye, fotoğraflı hediye
    - **Magnet & Turistik Hatıra** `magnet-turistik-hatira` — atanabilir yaprak; alias: buzdolabı magneti, şehir hatırası
    - **Tespih & Manevi Hediyelik** `tespih-manevi-hediyelik` — atanabilir yaprak; alias: tespih, dua boncuğu
    - **Nikah, Nişan & Bebek Hatırası** `nikah-nisan-bebek-hatirasi` — atanabilir yaprak; alias: nikah şekeri, bebek şekeri, nişan hediyeliği
  - **Parti & Kutlama** `parti-kutlama` — Alt Kategori
    - **Balon** `balon` — atanabilir yaprak; alias: parti balonu, folyo balon; risk: age_sensitive
    - **Parti Süsleme Seti** `parti-susleme-seti` — atanabilir yaprak; alias: doğum günü süsü, banner, masa süsü
    - **Tek Kullanımlık Parti Sofrası** `tek-kullanimlik-parti-sofrasi` — atanabilir yaprak; alias: parti tabağı, karton bardak, peçete
    - **Pasta Mumu & Kutlama Aksesuarı** `pasta-mumu-kutlama-aksesuari` — atanabilir yaprak; alias: doğum günü mumu, pasta süsü; risk: safety_critical
    - **Kostüm Partisi Aksesuarı** `kostum-partisi-aksesuari` — atanabilir yaprak; alias: parti maskesi, parti şapkası
    - **Mevsimsel Süsleme** `mevsimsel-susleme` — atanabilir yaprak; alias: yılbaşı süsü, bayram süsü

## Değişiklik yönetimi

- Slug semantic kimliktir; görünür ad değişse de slug mümkün olduğunca değişmez.
- Düğüm taşıma, birleştirme ve emeklilik için gelecekte `replaced_by_slug`, `valid_from`, `valid_to` ve mapping tablosu gerekir.
- Yeni düğüm ancak mevcut yaprak merchant için yanlış/zorlayıcıysa veya filtreyle çözülemeyen ayrı ticari anlam taşıyorsa eklenir.
- Product owner onayı, merchant pilot örnekleri ve katalog coverage ölçümü olmadan bu dosya seed/migration girdisi değildir.
