# EsnaftaVar Canonical Category Taxonomy V1 FINAL

**Durum:** FINAL

**Sürüm:** `v1.0.0`

**Yayın tarihi:** 2026-08-25

**Makine kaynağı:** `docs/data/esnaftavar_category_taxonomy_v1_final.json`

**JSON SHA-256:** `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08`

## Final sözleşme

Bu belge Product Owner Decisions Round 1 ve Round 2 ile kesinleşen EsnaftaVar canonical ürün taxonomy V1 baselineıdır. Her canonical ürün tam olarak bir aktif atanabilir leaf kategoriye bağlanır. Marka, attribute, variant, offer, shop type, Home projection ve sponsorlu sıralama canonical node değildir.

Bu artefakt migration, seed, Flutter, Figma veya merchant uygulaması implementationı içermez.

## Final sayılar

| Seviye | Rol | Node |
|---|---|---:|
| L1 | Ana Kategori | 23 |
| L2 | Alt Kategori | 91 |
| L3 | Ürün Grubu | 505 |
| L4 | Ürün Tipi | 32 |
| **Toplam** |  | **651** |
| Tüm leaf node |  | 525 |
| **Atanabilir aktif leaf** |  | **524** |
| Inactive review leaf |  | 1 |

## 23 final L1

1. **Market & Gıda** `market-gida` — 4 L2, 28 atanabilir leaf
2. **Moda & Giyim** `moda-giyim` — 4 L2, 22 atanabilir leaf
3. **Ayakkabı** `ayakkabi` — 4 L2, 19 atanabilir leaf
4. **Çanta & Giyim Aksesuarı** `canta-giyim-aksesuari` — 4 L2, 21 atanabilir leaf
5. **Elektronik** `elektronik` — 6 L2, 38 atanabilir leaf
6. **Bilgisayar & Tablet** `bilgisayar-tablet` — 4 L2, 29 atanabilir leaf
7. **Beyaz Eşya & Ev Aletleri** `beyaz-esya-ev-aletleri` — 4 L2, 23 atanabilir leaf
8. **Ev & Yaşam** `ev-yasam` — 5 L2, 29 atanabilir leaf
9. **Züccaciye & Mutfak** `zuccaciye-mutfak` — 5 L2, 26 atanabilir leaf
10. **Yapı & Hırdavat** `yapi-hirdavat` — 6 L2, 31 atanabilir leaf
11. **Otomotiv & Motosiklet** `otomotiv-motosiklet` — 5 L2, 32 atanabilir leaf
12. **Kişisel Bakım & Kozmetik** `kisisel-bakim-kozmetik` — 5 L2, 28 atanabilir leaf
13. **Bebek & Çocuk** `bebek-cocuk` — 4 L2, 20 atanabilir leaf
14. **Oyuncak, Hobi & Müzik** `oyuncak-hobi-muzik` — 5 L2, 24 atanabilir leaf
15. **Spor & Outdoor** `spor-outdoor` — 5 L2, 27 atanabilir leaf
16. **Kitap** `kitap` — 1 L2, 13 atanabilir leaf
17. **Kırtasiye & Ofis** `kirtasiye-ofis` — 4 L2, 27 atanabilir leaf
18. **Pet Shop** `pet-shop` — 4 L2, 25 atanabilir leaf
19. **Optik** `optik` — 1 L2, 6 atanabilir leaf
20. **Saat & Takı** `saat-taki` — 2 L2, 11 atanabilir leaf
21. **Sağlık & Medikal** `saglik-medikal` — 5 L2, 26 atanabilir leaf
22. **Çiçek & Bahçe** `cicek-bahce` — 2 L2, 11 atanabilir leaf
23. **Hediyelik & Parti** `hediyelik-parti` — 2 L2, 8 atanabilir leaf

## Uygulanan L1 splitleri

| Eski draft L1 | Final L1 sonuçları | Durum |
|---|---|---|
| `kitap-kirtasiye` — Kitap & Kırtasiye | `kitap` — Kitap<br>`kirtasiye-ofis` — Kırtasiye & Ofis | APPLIED |
| `optik-saat-taki` — Optik, Saat & Takı | `optik` — Optik<br>`saat-taki` — Saat & Takı | APPLIED |
| `cicek-bahce-hediyelik` — Çiçek, Bahçe & Hediyelik | `cicek-bahce` — Çiçek & Bahçe<br>`hediyelik-parti` — Hediyelik & Parti | APPLIED |

## Uygulanan 24 branch kararı

| # | Action | Node | Final çözüm |
|---:|---|---|---|
| 1 | KEEP_WITH_ATTRIBUTE_CONTEXT | `telefon-tutucu` | Araç ve masa telefon tutucu tek leaf'te kaldı; kullanım bağlamı compatibility/mount context değeriyle ayrılacak. |
| 2 | MOVE | `tablet-giris-aksesuarlari`, `dokunmatik-kalem` | Dokunmatik Kalem, Bilgisayar & Tablet > Bilgisayar Çevre Birimleri > Tablet & Giriş Aksesuarları altına taşındı. |
| 3 | KEEP_SEPARATE | `akilli-saat`, `kol-saati` | Akıllı saat Elektronik, klasik kol saati Saat & Takı domaininde ayrı kaldı. |
| 4 | KEEP | `mikrofon` | Mikrofon Elektronik altında kaldı; müzik kullanım amacı attribute/keşif sinyalidir. |
| 5 | KEEP | `bebek-kamerasi-telsizi` | Bebek kamerası ve telsizi Elektronik altında kaldı; bebek bağlamı alias/collection sinyalidir. |
| 6 | KEEP | `fiziksel-video-oyunu` | Fiziksel video oyunu konsol uyumluluğu nedeniyle Elektronik altında kaldı. |
| 7 | KEEP_WITH_COMPATIBILITY | `laptop-cantasi`, `fotograf-makinesi-cantasi` | Cihaz çantaları Çanta & Giyim Aksesuarı altında kaldı ve compatibility filter family eklendi. |
| 8 | KEEP_WITH_SAFETY_COMPLIANCE | `is-kiyafeti-uniforma`, `is-guvenligi-ayakkabisi` | İş kıyafeti giyimde, iş güvenliği ayakkabısı ayakkabıda kaldı; safety riskleri korundu. |
| 9 | KEEP_WITH_MODERATION | `medikal-konfor-ayakkabisi` | Medikal ve konfor ayakkabısı Ayakkabı altında kaldı; regulated ve claim riskleri korundu. |
| 10 | MOVE | `sac-kurutma-sekillendirme-cihazi`, `tiras-epilasyon-cihazi` | Saç cihazları Saç Bakımı & Şekillendirme; tıraş ve epilasyon cihazları Parfüm, Tıraş & El-Ayak Bakımı altına taşındı. |
| 11 | KEEP | `temizlik-deterjani`, `camasir-bakim-urunu`, `ev-kagit-urunleri` | Ev temizlik ve tüketim ürünleri satış kanalına göre Market & Gıda'ya taşınmadı. |
| 12 | SPLIT | `termos`, `spor-matarasi` | Termos Züccaciye & Mutfakta kaldı; Spor Matarası Spor & Outdoor altına ayrıldı. |
| 13 | KEEP | `bahce-el-aleti` | Bahçe El Aleti kullanım amacına göre Çiçek & Bahçe altında kaldı. |
| 14 | KEEP | `saksi-bitki-kabi` | Saksı & Bitki Kabı yetiştirme işlevine göre Çiçek & Bahçe altında kaldı. |
| 15 | KEEP_SINGLE_PRIMARY_MODEL | `kitaplar` | Kitaplarda tek primary shelf ve çoklu book_genre attribute modeli korundu. |
| 16 | KEEP | `cocuk-kitabi`, `genclik-kitabi` | Çocuk ve gençlik kitapları Kitap altında kaldı; yaş grubu attribute olarak korundu. |
| 17 | KEEP_BOUNDARY | `sanat-el-isi-paketleme`, `boyama-cocuk-sanat-seti` | Tekil sanat sarfı Kırtasiye & Ofis; hazır çocuk sanat seti Oyuncak, Hobi & Müzik altında kaldı. |
| 18 | KEEP_WITH_MODERATION | `protein-sporcu-destegi` | Protein & Sporcu Desteği Sağlık & Medikal altında kaldı; regulated ve claim riskleri korundu. |
| 19 | KEEP_WITH_MODERATION | `pet-saglik-destek-urunu` | Pet sağlık desteği Pet Shop altında kaldı; veteriner ilaçları exclusion kapsamındadır. |
| 20 | KEEP_DOMAIN | `optik-gozluk-cercevesi`, `hazir-okuma-gozlugu`, `kontakt-lens` | Regüle optik ürünler ayrı Optik L1 altında kaldı ve fail-closed compliance gerektirir. |
| 21 | DEPRECATE_AND_RECLASSIFY | `kisisellestirilebilir-hediye` | Kişiselleştirilebilir Hediye aktif ağaçtan çıkarıldı; kişiselleştirme attribute/merchant capability oldu. |
| 22 | DEPRECATE_TO_COLLECTION | `mevsimsel-susleme` | Mevsimsel Süsleme aktif ağaçtan çıkarıldı; sezon collection/occasion attribute oldu. |
| 23 | INACTIVE_REVIEW | `hediyelik-obje` | Hediyelik Obje registry'de inactive_review ve non-assignable olarak tutuldu. |
| 24 | KEEP_WITH_SCOPE | `kostum-partisi-aksesuari` | Kostüm Partisi Aksesuarı yalnız parti amaçlı ürünlerle sınırlandırıldı. |

## Yayın ve domain politikaları

- **Riskli leaf:** Fail-closed. Risk flag yayın izni değildir; kategoriye özel policy, belge gereksinimi, moderasyon sahibi ve audit yolu olmadan yayın yapılamaz.
- **Excluded:** İlaçlar ve özel tıbbi amaçlı ürünler; tütün/nikotin/e-sigara; alkollü içki; ateşli silah/mühimmat/patlayıcı; yasa dışı madde/üretim ekipmanı; canlı hayvan; dijital-only ürün, hizmet ve klasik checkout/kargo domainleri V1 dışındadır.
- **İkinci el/yenilenmiş:** V1'de deferred; gelecekte ayrı category değil `condition` attribute'udur.
- **Shop type:** Ayrı future merchant-domain taxonomy kararıdır; product L1'leri shop type olarak kullanılmaz.
- **Home:** Availability-gated 8 organik kısayol; Tüm Kategoriler 23 canonical L1i gösterir, unavailable kategoriler açıklamalı non-dead state ile sona alınır.
- **Sponsored:** Ayrı ve etiketlidir; canonical veya organik kategori sırasını değiştirmez.

## Approved attribute/filter pilot

Pilot yalnız tasarım onayıdır; implementation değildir. Onaylı 8 leaf:

- Elektronik > Telefon & Giyilebilir Teknoloji > Akıllı Telefon (`akilli-telefon`)
- Ayakkabı > Spor Ayakkabı > Günlük Sneaker (`gunluk-sneaker`)
- Moda & Giyim > Üst Giyim > Tişört (`tisort`)
- Market & Gıda > Kahvaltılık & Süt Ürünleri > Peynir (`peynir`)
- Kırtasiye & Ofis > Defter, Kağıt & Sunum > Defter (`defter`)
- Otomotiv & Motosiklet > Oto Yedek Parça > Fren Parçaları > Fren Balatası (`fren-balatasi`)
- Sağlık & Medikal > Ölçüm & Takip Cihazları > Tansiyon Aleti (`tansiyon-aleti`)
- Züccaciye & Mutfak > Pişirme Gereçleri > Tencere & Tencere Seti (`tencere-seti`)

## Governance ve versioning

- Baseline `v1.0.0`; stable slug immutable ve hiçbir zaman yeniden kullanılmaz.
- PATCH: display/merchant label, alias, keyword veya copy değişikliği.
- MINOR: yeni node, parent move veya mappingli backward-compatible deprecation.
- MAJOR: geriye uyumsuz L1 sınırı veya semantic identity değişikliği.
- Move slug'ı korur; eski ve yeni path kaydedilir. Deprecation hard delete değildir; replacement strategy kalıcıdır.

## Deprecated ve replacement mappings

| Draft slug | Type | Replacement | Migration kuralı |
|---|---|---|---|
| `kitap-kirtasiye` | split | `kitap`, `kirtasiye-ofis` | Doğrudan L1 referansı ürünün mevcut descendant leaf slug'ına göre yeni L1 altında roll-up edilmelidir. |
| `optik-saat-taki` | split | `optik`, `saat-taki` | Doğrudan L1 referansı ürünün mevcut descendant leaf slug'ına göre yeni L1 altında roll-up edilmelidir. |
| `cicek-bahce-hediyelik` | split | `cicek-bahce`, `hediyelik-parti` | Doğrudan L1 referansı ürünün mevcut descendant leaf slug'ına göre yeni L1 altında roll-up edilmelidir. |
| `termos-matara` | split | `termos`, `spor-matarasi` | Termos ürünleri termos leafine; spor ve outdoor mataraları spor-matarasi leafine yeniden sınıflandırılmalıdır. |
| `kisisellestirilebilir-hediye` | manual_reclassification | manual reclassification | Ürün gerçek fiziksel ürün leafine atanmalı; kişiselleştirme merchant capability veya attribute olarak tutulmalıdır. |
| `mevsimsel-susleme` | manual_reclassification | manual reclassification | Ürün gerçek fiziksel ürün leafine atanmalı; sezon ve occasion collection veya attribute olarak tutulmalıdır. |

## Moved nodes

| Slug | Eski path | Final path |
|---|---|---|
| `dokunmatik-kalem` | elektronik > telefon-aksesuarlari > telefon-tutucu-giris-aksesuarlari > dokunmatik-kalem | bilgisayar-tablet > bilgisayar-cevre-birimleri > tablet-giris-aksesuarlari > dokunmatik-kalem |
| `sac-kurutma-sekillendirme-cihazi` | beyaz-esya-ev-aletleri > temizlik-iklimlendirme-kisisel-ev-aleti > sac-kurutma-sekillendirme-cihazi | kisisel-bakim-kozmetik > sac-bakimi-sekillendirme > sac-kurutma-sekillendirme-cihazi |
| `tiras-epilasyon-cihazi` | beyaz-esya-ev-aletleri > temizlik-iklimlendirme-kisisel-ev-aleti > tiras-epilasyon-cihazi | kisisel-bakim-kozmetik > parfum-tiras-el-ayak-bakimi > tiras-epilasyon-cihazi |

## Validation

| Kontrol | Sonuç |
|---|---|
| `json_required_final_contract` | PASS |
| `final_counts` | PASS |
| `expected_23_l1_names_and_order` | PASS |
| `duplicate_slugs` | PASS |
| `duplicate_sibling_names_tr_normalized` | PASS |
| `cycles_orphans_and_parent_level` | PASS |
| `maximum_depth_4` | PASS |
| `deterministic_paths_and_sort_order` | PASS |
| `node_status_and_assignable_leaf` | PASS |
| `duplicate_aliases_within_node` | PASS |
| `known_filter_family_references` | PASS |
| `known_risk_flag_references` | PASS |
| `turkish_display_naming` | PASS |
| `approved_moves_and_splits` | PASS |
| `approved_24_branch_decisions` | PASS |
| `deprecation_and_replacement_mappings` | PASS |
| `approved_policies` | PASS |
| `governance_v1_0_0` | PASS |

## Complete final tree

- **Market & Gıda** `market-gida` — Ana Kategori; alias: market, gıda, gida, bakkal, süpermarket
  - **Temel Gıda** `temel-gida` — Alt Kategori
    - **Bakliyat** `bakliyat` — Ürün Grubu; atanabilir yaprak; alias: kuru bakliyat, fasulye nohut mercimek
    - **Pirinç, Bulgur & Tahıl** `pirinc-bulgur-tahil` — Ürün Grubu; atanabilir yaprak; alias: pirinç, bulgur, tahıl, tahil
    - **Makarna & Erişte** `makarna-eriste` — Ürün Grubu; atanabilir yaprak; alias: makarna, erişte, eriste, noodle
    - **Un & Hamur İşi Malzemeleri** `un-hamur-isi-malzemeleri` — Ürün Grubu; atanabilir yaprak; alias: un, maya, kabartma tozu
    - **Şeker, Tuz & Baharat** `seker-tuz-baharat` — Ürün Grubu; atanabilir yaprak; alias: şeker, seker, tuz, baharat
    - **Sıvı Yağ, Sos & Sirke** `sivi-yag-sos-sirke` — Ürün Grubu; atanabilir yaprak; alias: yağ, yag, sos, sirke
  - **Kahvaltılık & Süt Ürünleri** `kahvaltilik-sut-urunleri` — Alt Kategori
    - **Süt & Yoğurt** `sut-yogurt` — Ürün Grubu; atanabilir yaprak; alias: süt, sut, yoğurt, yogurt; risk: cold_chain
    - **Peynir** `peynir` — Ürün Grubu; atanabilir yaprak; alias: beyaz peynir, kaşar, kasar; risk: cold_chain
    - **Tereyağı & Margarin** `tereyagi-margarin` — Ürün Grubu; atanabilir yaprak; alias: tereyağı, tereyagi, margarin; risk: cold_chain
    - **Yumurta** `yumurta` — Ürün Grubu; atanabilir yaprak; risk: cold_chain
    - **Zeytin** `zeytin` — Ürün Grubu; atanabilir yaprak; alias: siyah zeytin, yeşil zeytin
    - **Bal, Reçel & Sürülebilir Ürünler** `bal-recel-surulebilir-urunler` — Ürün Grubu; atanabilir yaprak; alias: bal, reçel, recel, fındık kreması, ezme
  - **İçecek & Atıştırmalık** `icecek-atistirmalik` — Alt Kategori
    - **Su & Maden Suyu** `su-maden-suyu` — Ürün Grubu; atanabilir yaprak; alias: su, soda, maden suyu
    - **Çay & Bitki Çayı** `cay-bitki-cayi` — Ürün Grubu; atanabilir yaprak; alias: çay, cay, bitki çayı
    - **Kahve & Kakao** `kahve-kakao` — Ürün Grubu; atanabilir yaprak; alias: kahve, Türk kahvesi, filtre kahve, kakao
    - **Gazlı İçecek & Meyve Suyu** `gazli-icecek-meyve-suyu` — Ürün Grubu; atanabilir yaprak; alias: kola, gazoz, meyve suyu, soğuk çay
    - **Çikolata & Şekerleme** `cikolata-sekerleme` — Ürün Grubu; atanabilir yaprak; alias: çikolata, cikolata, gofret, şekerleme, sakız
    - **Bisküvi, Kraker & Kek** `biskuvi-kraker-kek` — Ürün Grubu; atanabilir yaprak; alias: bisküvi, kraker, kek
    - **Cips & Patlamış Mısır** `cips-patlamis-misir` — Ürün Grubu; atanabilir yaprak; alias: cips, patlamış mısır, popcorn
    - **Kuruyemiş & Kuru Meyve** `kuruyemis-kuru-meyve` — Ürün Grubu; atanabilir yaprak; alias: kuruyemiş, kuruyemis, kuru meyve
  - **Taze, Donuk & Hazır Gıda** `taze-donuk-hazir-gida` — Alt Kategori
    - **Taze Meyve** `taze-meyve` — Ürün Grubu; atanabilir yaprak; alias: meyve, manav
    - **Taze Sebze** `taze-sebze` — Ürün Grubu; atanabilir yaprak; alias: sebze, manav
    - **Ekmek & Unlu Mamuller** `ekmek-unlu-mamuller` — Ürün Grubu; atanabilir yaprak; alias: ekmek, fırın, firin, simit, poğaça
    - **Et & Tavuk Ürünleri** `et-tavuk-urunleri` — Ürün Grubu; atanabilir yaprak; alias: kasap, kırmızı et, tavuk; risk: cold_chain
    - **Şarküteri** `sarkuteri` — Ürün Grubu; atanabilir yaprak; alias: şarküteri, sarkuteri, sucuk, salam; risk: cold_chain
    - **Balık & Deniz Ürünleri** `balik-deniz-urunleri` — Ürün Grubu; atanabilir yaprak; alias: balıkçı, balikci, deniz ürünü; risk: cold_chain
    - **Dondurulmuş Gıda** `dondurulmus-gida` — Ürün Grubu; atanabilir yaprak; alias: donuk gıda, dondurulmuş ürün; risk: cold_chain
    - **Hazır Yemek & Meze** `hazir-yemek-meze` — Ürün Grubu; atanabilir yaprak; alias: hazır yemek, meze, şarküteri mezesi; risk: cold_chain
- **Moda & Giyim** `moda-giyim` — Ana Kategori; alias: giyim, tekstil, konfeksiyon, moda
  - **Üst Giyim** `ust-giyim` — Alt Kategori
    - **Tişört** `tisort` — Ürün Grubu; atanabilir yaprak; alias: tişört, tisort, t-shirt
    - **Gömlek & Bluz** `gomlek-bluz` — Ürün Grubu; atanabilir yaprak; alias: gömlek, gomlek, bluz
    - **Kazak & Hırka** `kazak-hirka` — Ürün Grubu; atanabilir yaprak; alias: kazak, hırka, hirka
    - **Sweatshirt & Hoodie** `sweatshirt-hoodie` — Ürün Grubu; atanabilir yaprak; alias: sweat, kapüşonlu, hoodie
    - **Tunik** `tunik` — Ürün Grubu; atanabilir yaprak; alias: uzun tunik
  - **Alt Giyim** `alt-giyim` — Alt Kategori
    - **Pantolon** `pantolon` — Ürün Grubu; atanabilir yaprak; alias: kumaş pantolon
    - **Jean** `jean` — Ürün Grubu; atanabilir yaprak; alias: kot pantolon, denim
    - **Etek** `etek` — Ürün Grubu; atanabilir yaprak
    - **Şort** `sort` — Ürün Grubu; atanabilir yaprak; alias: şort, sort, bermuda
    - **Tayt & Eşofman Altı** `tayt-esofman-alti` — Ürün Grubu; atanabilir yaprak; alias: tayt, eşofman, esofman
  - **Dış Giyim & Tek Parça** `dis-giyim-tek-parca` — Alt Kategori
    - **Mont, Kaban & Parka** `mont-kaban-parka` — Ürün Grubu; atanabilir yaprak; alias: mont, kaban, parka
    - **Ceket & Blazer** `ceket-blazer` — Ürün Grubu; atanabilir yaprak; alias: ceket, blazer
    - **Yağmurluk & Rüzgarlık** `yagmurluk-ruzgarlik` — Ürün Grubu; atanabilir yaprak; alias: yağmurluk, yagmurluk, rüzgarlık
    - **Elbise** `elbise` — Ürün Grubu; atanabilir yaprak; alias: abiye, günlük elbise
    - **Tulum** `tulum-giyim` — Ürün Grubu; atanabilir yaprak; alias: giyim tulumu
    - **Takım Elbise** `takim-elbise` — Ürün Grubu; atanabilir yaprak; alias: takım, damatlık
  - **İç Giyim, Ev Giyimi & Fonksiyonel Giyim** `ic-giyim-ev-giyimi-fonksiyonel` — Alt Kategori
    - **İç Çamaşırı** `ic-camasiri` — Ürün Grubu; atanabilir yaprak; alias: iç giyim, atlet, külot, boxer
    - **Sütyen & Korse** `sutyen-korse` — Ürün Grubu; atanabilir yaprak; alias: sütyen, sutyen, korse
    - **Pijama & Gecelik** `pijama-gecelik` — Ürün Grubu; atanabilir yaprak; alias: pijama, gecelik, sabahlık
    - **Çorap & Külotlu Çorap** `corap-kulotlu-corap` — Ürün Grubu; atanabilir yaprak; alias: çorap, corap, külotlu çorap
    - **İş Kıyafeti & Üniforma** `is-kiyafeti-uniforma` — Ürün Grubu; atanabilir yaprak; alias: iş elbisesi, önlük, üniforma; risk: safety_critical
    - **Mayo & Plaj Giyimi** `mayo-plaj-giyimi` — Ürün Grubu; atanabilir yaprak; alias: mayo, bikini, deniz şortu
- **Ayakkabı** `ayakkabi` — Ana Kategori; alias: ayakkabı, ayakkabi, kundura
  - **Günlük & Klasik Ayakkabı** `gunluk-klasik-ayakkabi` — Alt Kategori
    - **Günlük Bağcıklı Ayakkabı** `gunluk-bagcikli-ayakkabi` — Ürün Grubu; atanabilir yaprak; alias: casual ayakkabı
    - **Mokasen & Loafer** `mokasen-loafer` — Ürün Grubu; atanabilir yaprak; alias: mokasen, loafer
    - **Babet & Düz Ayakkabı** `babet-duz-ayakkabi` — Ürün Grubu; atanabilir yaprak; alias: babet, düz ayakkabı
    - **Klasik Ayakkabı** `klasik-ayakkabi` — Ürün Grubu; atanabilir yaprak; alias: kundura, resmi ayakkabı
    - **Topuklu Ayakkabı** `topuklu-ayakkabi` — Ürün Grubu; atanabilir yaprak; alias: stiletto, dolgu topuk
  - **Spor Ayakkabı** `spor-ayakkabi` — Alt Kategori
    - **Koşu Ayakkabısı** `kosu-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: koşu ayakkabısı, running
    - **Yürüyüş Ayakkabısı** `yuruyus-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: yürüyüş, walking
    - **Günlük Sneaker** `gunluk-sneaker` — Ürün Grubu; atanabilir yaprak; alias: sneaker, spor ayakkabı, spor ayakkabi
    - **Salon & Antrenman Ayakkabısı** `salon-antrenman-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: fitness ayakkabısı, court ayakkabı
    - **Futbol Ayakkabısı** `futbol-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: krampon, halı saha ayakkabısı
  - **Bot & Çizme** `bot-cizme` — Alt Kategori
    - **Bot** `bot` — Ürün Grubu; atanabilir yaprak; alias: günlük bot
    - **Çizme** `cizme` — Ürün Grubu; atanabilir yaprak; alias: çizme, cizme
    - **Kar & Yağmur Botu** `kar-yagmur-botu` — Ürün Grubu; atanabilir yaprak; alias: kar botu, yağmur botu
    - **Trekking Ayakkabısı & Botu** `trekking-ayakkabisi-botu` — Ürün Grubu; atanabilir yaprak; alias: outdoor ayakkabı, hiking bot
  - **Sandalet, Terlik & Uzmanlık Ayakkabısı** `sandalet-terlik-uzmanlik-ayakkabisi` — Alt Kategori
    - **Sandalet** `sandalet` — Ürün Grubu; atanabilir yaprak
    - **Terlik** `terlik` — Ürün Grubu; atanabilir yaprak; alias: ev terliği, plaj terliği
    - **Deniz Ayakkabısı** `deniz-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: havuz ayakkabısı
    - **İş Güvenliği Ayakkabısı** `is-guvenligi-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: çelik burun ayakkabı, iş botu; risk: safety_critical
    - **Medikal & Konfor Ayakkabısı** `medikal-konfor-ayakkabisi` — Ürün Grubu; atanabilir yaprak; alias: ortopedik ayakkabı, sabo; risk: regulated_review, claim_sensitive
- **Çanta & Giyim Aksesuarı** `canta-giyim-aksesuari` — Ana Kategori; alias: çanta, canta, giyim aksesuarı
  - **Günlük Çantalar** `gunluk-cantalar` — Alt Kategori
    - **El Çantası** `el-cantasi` — Ürün Grubu; atanabilir yaprak; alias: kadın çantası, handbag
    - **Omuz & Çapraz Çanta** `omuz-capraz-canta` — Ürün Grubu; atanabilir yaprak; alias: omuz çantası, çapraz çanta
    - **Sırt Çantası** `sirt-cantasi` — Ürün Grubu; atanabilir yaprak; alias: backpack
    - **Bel Çantası** `bel-cantasi` — Ürün Grubu; atanabilir yaprak; alias: waist bag
    - **Alışveriş & Bez Çanta** `alisveris-bez-canta` — Ürün Grubu; atanabilir yaprak; alias: tote bag, bez çanta
  - **İş, Okul & Cihaz Çantaları** `is-okul-cihaz-cantalari` — Alt Kategori
    - **Laptop Çantası** `laptop-cantasi` — Ürün Grubu; atanabilir yaprak; alias: bilgisayar çantası
    - **Evrak Çantası** `evrak-cantasi` — Ürün Grubu; atanabilir yaprak; alias: briefcase, iş çantası
    - **Okul Çantası** `okul-cantasi` — Ürün Grubu; atanabilir yaprak; alias: öğrenci çantası
    - **Fotoğraf Makinesi Çantası** `fotograf-makinesi-cantasi` — Ürün Grubu; atanabilir yaprak; alias: kamera çantası
  - **Seyahat Çantaları** `seyahat-cantalari` — Alt Kategori
    - **Valiz** `valiz` — Ürün Grubu; atanabilir yaprak; alias: bavul
    - **Seyahat Çantası** `seyahat-cantasi` — Ürün Grubu; atanabilir yaprak; alias: duffel, spor seyahat çantası
    - **Kabin & El Bagajı** `kabin-el-bagaji` — Ürün Grubu; atanabilir yaprak; alias: kabin boy valiz, el bagajı
    - **Makyaj & Bakım Çantası** `makyaj-bakim-cantasi` — Ürün Grubu; atanabilir yaprak; alias: makyaj çantası, toiletry bag
  - **Küçük Deri Ürünleri & Giyim Tamamlayıcıları** `kucuk-deri-giyim-tamamlayicilari` — Alt Kategori
    - **Cüzdan & Kartlık** `cuzdan-kartlik` — Ürün Grubu; atanabilir yaprak; alias: cüzdan, cuzdan, kartlık
    - **Kemer** `kemer` — Ürün Grubu; atanabilir yaprak
    - **Şapka & Bere** `sapka-bere` — Ürün Grubu; atanabilir yaprak; alias: şapka, sapka, bere
    - **Atkı, Şal & Fular** `atki-sal-fular` — Ürün Grubu; atanabilir yaprak; alias: atkı, şal, fular
    - **Eldiven** `eldiven` — Ürün Grubu; atanabilir yaprak
    - **Kravat & Papyon** `kravat-papyon` — Ürün Grubu; atanabilir yaprak; alias: kravat, papyon
    - **Şemsiye** `semsiye` — Ürün Grubu; atanabilir yaprak; alias: şemsiye, semsiye
    - **Saç Aksesuarları** `sac-aksesuarlari` — Ürün Grubu; atanabilir yaprak; alias: toka, taç, saç bandı
- **Elektronik** `elektronik` — Ana Kategori; alias: elektronik, teknoloji, elektronik eşya
  - **Telefon & Giyilebilir Teknoloji** `telefon-giyilebilir-teknoloji` — Alt Kategori
    - **Akıllı Telefon** `akilli-telefon` — Ürün Grubu; atanabilir yaprak; alias: cep telefonu, telefon, smartphone, akıllı cep telefonu
    - **Tuşlu Cep Telefonu** `tuslu-cep-telefonu` — Ürün Grubu; atanabilir yaprak; alias: tuşlu telefon, klasik telefon
    - **Akıllı Saat** `akilli-saat` — Ürün Grubu; atanabilir yaprak; alias: smart watch, smartwatch
    - **Akıllı Bileklik** `akilli-bileklik` — Ürün Grubu; atanabilir yaprak; alias: aktivite bilekliği, smart band
    - **GPS Takip Cihazı** `gps-takip-cihazi` — Ürün Grubu; atanabilir yaprak; alias: takip cihazı, çocuk takip saati
  - **Telefon Aksesuarları** `telefon-aksesuarlari` — Alt Kategori
    - **Telefon Koruma & Taşıma** `telefon-koruma-tasima` — Ürün Grubu
      - **Cep Telefonu Kılıfı** `cep-telefonu-kilifi` — Ürün Tipi; atanabilir yaprak; alias: telefon kılıfı, telefon kabı, case
      - **Ekran Koruyucu** `telefon-ekran-koruyucu` — Ürün Tipi; atanabilir yaprak; alias: kırılmaz cam, temperli cam, ekran filmi
    - **Telefon Şarj & Güç** `telefon-sarj-guc` — Ürün Grubu
      - **Telefon Şarj Cihazı** `telefon-sarj-cihazi` — Ürün Tipi; atanabilir yaprak; alias: şarj aleti, sarj aleti, adaptör
      - **Telefon Şarj Kablosu** `telefon-sarj-kablosu` — Ürün Tipi; atanabilir yaprak; alias: şarj kablosu, USB kablo
      - **Powerbank** `powerbank` — Ürün Tipi; atanabilir yaprak; alias: taşınabilir şarj, power bank
      - **Kablosuz Şarj Cihazı** `kablosuz-sarj-cihazi` — Ürün Tipi; atanabilir yaprak; alias: wireless şarj, şarj pedi
    - **Telefon Tutucu & Giriş Aksesuarları** `telefon-tutucu-giris-aksesuarlari` — Ürün Grubu
      - **Araç & Masa Telefon Tutucu** `telefon-tutucu` — Ürün Tipi; atanabilir yaprak; alias: telefon standı, araç içi telefon tutucu
      - **Selfie Çubuğu & Uzaktan Kumanda** `selfie-cubugu-uzaktan-kumanda` — Ürün Tipi; atanabilir yaprak; alias: selfie stick, bluetooth deklanşör
    - **Telefon Yedek Bileşenleri** `telefon-yedek-bilesenleri` — Ürün Grubu; risk: safety_critical, compatibility_critical
      - **Telefon Bataryası** `telefon-bataryasi` — Ürün Tipi; atanabilir yaprak; alias: cep telefonu pili; risk: safety_critical, hazmat_review, compatibility_critical
      - **Telefon Ekran Modülü** `telefon-ekran-modulu` — Ürün Tipi; atanabilir yaprak; alias: yedek telefon ekranı, LCD ekran; risk: compatibility_critical
  - **Ses & Görüntü Sistemleri** `ses-goruntu-sistemleri` — Alt Kategori
    - **Kulaklık** `kulaklik` — Ürün Grubu; atanabilir yaprak; alias: bluetooth kulaklık, kablosuz kulaklık, earbuds, headphone
    - **Taşınabilir Hoparlör** `tasinabilir-hoparlor` — Ürün Grubu; atanabilir yaprak; alias: bluetooth hoparlör
    - **Ev Ses Sistemi** `ev-ses-sistemi` — Ürün Grubu; atanabilir yaprak; alias: soundbar, ev sinema sistemi
    - **Mikrofon** `mikrofon` — Ürün Grubu; atanabilir yaprak; alias: kablosuz mikrofon, yaka mikrofonu
    - **Televizyon** `televizyon` — Ürün Grubu; atanabilir yaprak; alias: TV, smart TV
    - **Projeksiyon Cihazı** `projeksiyon-cihazi` — Ürün Grubu; atanabilir yaprak; alias: projektör, projeksiyon
    - **Medya Oynatıcı** `medya-oynatici` — Ürün Grubu; atanabilir yaprak; alias: TV box, streaming cihazı
    - **Uydu Alıcısı & Anten** `uydu-alicisi-anten` — Ürün Grubu; atanabilir yaprak; alias: uydu cihazı, çanak anten
  - **Kamera & Güvenlik Elektroniği** `kamera-guvenlik-elektronigi` — Alt Kategori
    - **Fotoğraf Makinesi** `fotograf-makinesi` — Ürün Grubu; atanabilir yaprak; alias: kamera, dijital fotoğraf makinesi
    - **Aksiyon Kamerası** `aksiyon-kamerasi` — Ürün Grubu; atanabilir yaprak; alias: action cam, aksiyon kamera
    - **Kamera Lensi & Fotoğraf Aksesuarı** `kamera-lensi-fotograf-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: objektif, tripod, fotoğraf aksesuarı
    - **Güvenlik Kamerası** `guvenlik-kamerasi` — Ürün Grubu; atanabilir yaprak; alias: IP kamera, CCTV
    - **Alarm & Akıllı Kapı Zili** `alarm-akilli-kapi-zili` — Ürün Grubu; atanabilir yaprak; alias: alarm sistemi, görüntülü kapı zili
    - **Bebek Kamerası & Telsizi** `bebek-kamerasi-telsizi` — Ürün Grubu; atanabilir yaprak; alias: baby monitor, bebek telsizi
  - **Oyun Konsolu & Aksesuarları** `oyun-konsolu-aksesuarlari` — Alt Kategori
    - **Oyun Konsolu** `oyun-konsolu` — Ürün Grubu; atanabilir yaprak; alias: konsol
    - **Oyun Kolu & Kontrolcü** `oyun-kolu-kontrolcu` — Ürün Grubu; atanabilir yaprak; alias: gamepad, joystick
    - **Konsol Aksesuarı** `konsol-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: konsol standı, şarj istasyonu
    - **Fiziksel Video Oyunu** `fiziksel-video-oyunu` — Ürün Grubu; atanabilir yaprak; alias: oyun diski, kutu oyun yazılımı
  - **Elektronik Güç, Kablo & Bileşen** `elektronik-guc-kablo-bilesen` — Alt Kategori
    - **Pil & Şarjlı Pil** `pil-sarjli-pil` — Ürün Grubu; atanabilir yaprak; alias: kalem pil, şarjlı pil; risk: hazmat_review
    - **Genel Adaptör & Güç Kaynağı** `genel-adaptor-guc-kaynagi` — Ürün Grubu; atanabilir yaprak; alias: AC adaptör, DC adaptör
    - **Ses, Görüntü & Veri Kablosu** `ses-goruntu-veri-kablosu` — Ürün Grubu; atanabilir yaprak; alias: HDMI kablo, AUX kablo, USB kablo
    - **Uzaktan Kumanda** `uzaktan-kumanda` — Ürün Grubu; atanabilir yaprak; alias: TV kumandası, akıllı kumanda
    - **Hobi Elektronik Bileşeni** `hobi-elektronik-bileseni` — Ürün Grubu; atanabilir yaprak; alias: devre elemanı, sensör, lehim bileşeni
- **Bilgisayar & Tablet** `bilgisayar-tablet` — Ana Kategori; alias: bilgisayar, computer, PC, tablet
  - **Bilgisayar, Tablet & Okuyucu** `bilgisayar-tablet-okuyucu` — Alt Kategori
    - **Dizüstü Bilgisayar** `dizustu-bilgisayar` — Ürün Grubu; atanabilir yaprak; alias: laptop, notebook
    - **Masaüstü Bilgisayar** `masaustu-bilgisayar` — Ürün Grubu; atanabilir yaprak; alias: desktop, kasa bilgisayar
    - **All-in-One & Mini Bilgisayar** `all-in-one-mini-bilgisayar` — Ürün Grubu; atanabilir yaprak; alias: hepsi bir arada bilgisayar, mini PC
    - **Tablet** `tablet` — Ürün Grubu; atanabilir yaprak; alias: tablet bilgisayar
    - **E-Kitap Okuyucu** `e-kitap-okuyucu` — Ürün Grubu; atanabilir yaprak; alias: e-reader, elektronik kitap okuyucu
  - **Bilgisayar Bileşenleri** `bilgisayar-bilesenleri` — Alt Kategori
    - **Ana Bilgisayar Bileşenleri** `ana-bilgisayar-bilesenleri` — Ürün Grubu
      - **İşlemci** `bilgisayar-islemcisi` — Ürün Tipi; atanabilir yaprak; alias: CPU, işlemci
      - **Anakart** `anakart` — Ürün Tipi; atanabilir yaprak; alias: motherboard
      - **RAM Bellek** `ram-bellek` — Ürün Tipi; atanabilir yaprak; alias: RAM, bellek
      - **Ekran Kartı** `ekran-karti` — Ürün Tipi; atanabilir yaprak; alias: GPU, grafik kartı
    - **Dahili Depolama Bileşenleri** `dahili-depolama-bilesenleri` — Ürün Grubu
      - **SSD** `ssd` — Ürün Tipi; atanabilir yaprak; alias: katı hal diski, NVMe SSD
      - **Dahili Sabit Disk** `dahili-sabit-disk` — Ürün Tipi; atanabilir yaprak; alias: HDD, hard disk
      - **Optik Sürücü** `optik-surucu` — Ürün Tipi; atanabilir yaprak; alias: DVD yazıcı, Blu-ray sürücü
    - **Kasa, Güç & Soğutma** `kasa-guc-sogutma` — Ürün Grubu
      - **Bilgisayar Kasası** `bilgisayar-kasasi` — Ürün Tipi; atanabilir yaprak; alias: PC kasa
      - **Bilgisayar Güç Kaynağı** `bilgisayar-guc-kaynagi` — Ürün Tipi; atanabilir yaprak; alias: PSU
      - **Bilgisayar Soğutma** `bilgisayar-sogutma` — Ürün Tipi; atanabilir yaprak; alias: işlemci soğutucu, kasa fanı
  - **Bilgisayar Çevre Birimleri** `bilgisayar-cevre-birimleri` — Alt Kategori
    - **Monitör** `monitor` — Ürün Grubu; atanabilir yaprak; alias: bilgisayar ekranı
    - **Klavye** `klavye` — Ürün Grubu; atanabilir yaprak; alias: keyboard
    - **Mouse & Mousepad** `mouse-mousepad` — Ürün Grubu; atanabilir yaprak; alias: fare, mouse, mouse pad
    - **Webcam** `webcam` — Ürün Grubu; atanabilir yaprak; alias: web kamera
    - **Grafik Tablet** `grafik-tablet` — Ürün Grubu; atanabilir yaprak; alias: çizim tableti
    - **USB Hub & Dock İstasyonu** `usb-hub-dock-istasyonu` — Ürün Grubu; atanabilir yaprak; alias: USB çoğaltıcı, dock
    - **Tablet & Giriş Aksesuarları** `tablet-giris-aksesuarlari` — Ürün Grubu; alias: tablet aksesuarı, tablet aksesuari, giriş aksesuarı, giris aksesuari
      - **Dokunmatik Kalem** `dokunmatik-kalem` — Ürün Tipi; atanabilir yaprak; alias: stylus, tablet kalemi
  - **Ağ, Harici Depolama & Baskı** `ag-harici-depolama-baski` — Alt Kategori
    - **Modem & Router** `modem-router` — Ürün Grubu; atanabilir yaprak; alias: modem, yönlendirici, router
    - **Ağ Cihazı & Adaptörü** `ag-cihazi-adaptoru` — Ürün Grubu; atanabilir yaprak; alias: switch, access point, Wi-Fi adaptör
    - **USB Bellek & Hafıza Kartı** `usb-bellek-hafiza-karti` — Ürün Grubu; atanabilir yaprak; alias: flash bellek, memory card
    - **Harici Disk & NAS** `harici-disk-nas` — Ürün Grubu; atanabilir yaprak; alias: external disk, taşınabilir disk, NAS
    - **Yazıcı** `yazici` — Ürün Grubu; atanabilir yaprak; alias: printer, lazer yazıcı, mürekkep püskürtmeli
    - **Tarayıcı** `tarayici` — Ürün Grubu; atanabilir yaprak; alias: scanner
    - **Kartuş & Toner** `kartus-toner` — Ürün Grubu; atanabilir yaprak; alias: mürekkep kartuşu, toner
- **Beyaz Eşya & Ev Aletleri** `beyaz-esya-ev-aletleri` — Ana Kategori; alias: beyaz eşya, beyaz esya, elektrikli ev aleti
  - **Soğutma Cihazları** `sogutma-cihazlari` — Alt Kategori
    - **Buzdolabı** `buzdolabi` — Ürün Grubu; atanabilir yaprak; alias: buz dolabı
    - **Derin Dondurucu** `derin-dondurucu` — Ürün Grubu; atanabilir yaprak; alias: dondurucu
    - **Mini Buzdolabı** `mini-buzdolabi` — Ürün Grubu; atanabilir yaprak; alias: mini bar
    - **Su Sebili** `su-sebili` — Ürün Grubu; atanabilir yaprak; alias: sıcak soğuk su sebili
  - **Çamaşır & Bulaşık Cihazları** `camasir-bulasik-cihazlari` — Alt Kategori
    - **Çamaşır Makinesi** `camasir-makinesi` — Ürün Grubu; atanabilir yaprak; alias: çamaşır makinası
    - **Kurutma Makinesi** `kurutma-makinesi` — Ürün Grubu; atanabilir yaprak; alias: çamaşır kurutma
    - **Bulaşık Makinesi** `bulasik-makinesi` — Ürün Grubu; atanabilir yaprak; alias: bulaşık makinası
    - **Ütü** `utu` — Ürün Grubu; atanabilir yaprak; alias: buharlı ütü, ütü
    - **Dikiş Makinesi** `dikis-makinesi` — Ürün Grubu; atanabilir yaprak; alias: dikiş makinası
  - **Pişirme & Mutfak Cihazları** `pisirme-mutfak-cihazlari` — Alt Kategori
    - **Fırın** `firin-cihazi` — Ürün Grubu; atanabilir yaprak; alias: ankastre fırın, mini fırın
    - **Ocak** `ocak-cihazi` — Ürün Grubu; atanabilir yaprak; alias: ankastre ocak, set üstü ocak
    - **Davlumbaz & Aspiratör** `davlumbaz-aspirator` — Ürün Grubu; atanabilir yaprak; alias: davlumbaz, mutfak aspiratörü
    - **Mikrodalga Fırın** `mikrodalga-firin` — Ürün Grubu; atanabilir yaprak; alias: mikrodalga
    - **Çay & Kahve Makinesi** `cay-kahve-makinesi` — Ürün Grubu; atanabilir yaprak; alias: çaycı, kahve makinesi, Türk kahvesi makinesi
    - **Blender, Mikser & Doğrayıcı** `blender-mikser-dograyici` — Ürün Grubu; atanabilir yaprak; alias: blender, mikser, rondo
    - **Tost, Izgara & Airfryer** `tost-izgara-airfryer` — Ürün Grubu; atanabilir yaprak; alias: tost makinesi, elektrikli ızgara, air fryer
    - **Su Isıtıcı & Elektrikli Pişirici** `su-isitici-elektrikli-pisirici` — Ürün Grubu; atanabilir yaprak; alias: kettle, elektrikli tencere, pirinç pişirici
  - **Temizlik, İklimlendirme & Kişisel Ev Aleti** `temizlik-iklimlendirme-kisisel-ev-aleti` — Alt Kategori
    - **Elektrikli Süpürge** `elektrikli-supurge` — Ürün Grubu; atanabilir yaprak; alias: robot süpürge, dikey süpürge
    - **Buharlı Temizleyici** `buharli-temizleyici` — Ürün Grubu; atanabilir yaprak; alias: buhar makinesi
    - **Klima** `klima` — Ürün Grubu; atanabilir yaprak; alias: split klima, portatif klima
    - **Vantilatör & Hava Soğutucu** `vantilator-hava-sogutucu` — Ürün Grubu; atanabilir yaprak; alias: fan, vantilatör
    - **Isıtıcı & Soba** `isitici-soba` — Ürün Grubu; atanabilir yaprak; alias: elektrikli ısıtıcı, infrared soba; risk: safety_critical
    - **Hava Temizleyici & Nem Cihazı** `hava-temizleyici-nem-cihazi` — Ürün Grubu; atanabilir yaprak; alias: hava temizleyici, nemlendirici
- **Ev & Yaşam** `ev-yasam` — Ana Kategori; alias: ev yaşam, ev & yaşam, ev dekorasyon
  - **Mobilya** `mobilya` — Alt Kategori
    - **Koltuk & Kanepe** `koltuk-kanepe` — Ürün Grubu; atanabilir yaprak; alias: koltuk, kanepe, çekyat
    - **Masa & Sandalye** `masa-sandalye` — Ürün Grubu; atanabilir yaprak; alias: yemek masası, sandalye
    - **Yatak, Baza & Başlık** `yatak-baza-baslik` — Ürün Grubu; atanabilir yaprak; alias: yatak, baza, yatak başlığı
    - **Dolap & Şifonyer** `dolap-sifonyer` — Ürün Grubu; atanabilir yaprak; alias: gardırop, şifonyer
    - **Raf, Kitaplık & TV Ünitesi** `raf-kitaplik-tv-unitesi` — Ürün Grubu; atanabilir yaprak; alias: kitaplık, duvar rafı, TV sehpası
    - **Çalışma Mobilyası** `calisma-mobilyasi` — Ürün Grubu; atanabilir yaprak; alias: çalışma masası, ofis sandalyesi
  - **Ev Tekstili** `ev-tekstili` — Alt Kategori
    - **Nevresim & Yatak Örtüsü** `nevresim-yatak-ortusu` — Ürün Grubu; atanabilir yaprak; alias: nevresim takımı, yatak örtüsü
    - **Yastık & Yorgan** `yastik-yorgan` — Ürün Grubu; atanabilir yaprak; alias: yastık, yorgan
    - **Havlu & Bornoz** `havlu-bornoz` — Ürün Grubu; atanabilir yaprak; alias: banyo havlusu, bornoz
    - **Perde & Stor** `perde-stor` — Ürün Grubu; atanabilir yaprak; alias: tül perde, stor perde
    - **Halı & Kilim** `hali-kilim` — Ürün Grubu; atanabilir yaprak; alias: halı, kilim, yolluk
    - **Battaniye, Örtü & Kırlent** `battaniye-ortu-kirlent` — Ürün Grubu; atanabilir yaprak; alias: battaniye, koltuk örtüsü, kırlent
  - **Dekorasyon & Aydınlatma** `dekorasyon-aydinlatma` — Alt Kategori
    - **Avize & Tavan Aydınlatması** `avize-tavan-aydinlatmasi` — Ürün Grubu; atanabilir yaprak; alias: avize, plafonyer
    - **Masa, Lambader & Gece Lambası** `masa-lambader-gece-lambasi` — Ürün Grubu; atanabilir yaprak; alias: abajur, lambader, gece lambası
    - **Ampul & Dekoratif Işık** `ampul-dekoratif-isik` — Ürün Grubu; atanabilir yaprak; alias: ampul, LED şerit, ışık zinciri
    - **Ayna** `ayna` — Ürün Grubu; atanabilir yaprak; alias: duvar aynası, boy aynası
    - **Çerçeve & Duvar Dekoru** `cerceve-duvar-dekoru` — Ürün Grubu; atanabilir yaprak; alias: resim çerçevesi, tablo, duvar süsü
    - **Duvar & Masa Saati** `duvar-masa-saati` — Ürün Grubu; atanabilir yaprak; alias: duvar saati, masa saati
    - **Mum & Oda Kokusu** `mum-oda-kokusu` — Ürün Grubu; atanabilir yaprak; alias: kokulu mum, buhurdanlık, oda kokusu; risk: hazmat_review
  - **Banyo & Düzenleme** `banyo-duzenleme` — Alt Kategori
    - **Banyo Aksesuar Seti** `banyo-aksesuar-seti` — Ürün Grubu; atanabilir yaprak; alias: sabunluk, diş fırçalık
    - **Duş Perdesi & Banyo Paspası** `dus-perdesi-banyo-paspasi` — Ürün Grubu; atanabilir yaprak; alias: duş perdesi, banyo paspası
    - **Çamaşır Sepeti** `camasir-sepeti` — Ürün Grubu; atanabilir yaprak; alias: kirli sepeti
    - **Saklama Kutusu & Sepet** `saklama-kutusu-sepet` — Ürün Grubu; atanabilir yaprak; alias: hurç, organizer kutu
    - **Askı & Dolap Düzenleyici** `aski-dolap-duzenleyici` — Ürün Grubu; atanabilir yaprak; alias: elbise askısı, dolap organizer
  - **Ev Temizlik & Tüketim Ürünleri** `ev-temizlik-tuketim-urunleri` — Alt Kategori
    - **Temizlik Deterjanı** `temizlik-deterjani` — Ürün Grubu; atanabilir yaprak; alias: yüzey temizleyici, bulaşık deterjanı; risk: hazmat_review
    - **Çamaşır Bakım Ürünü** `camasir-bakim-urunu` — Ürün Grubu; atanabilir yaprak; alias: çamaşır deterjanı, yumuşatıcı; risk: hazmat_review
    - **Süpürge, Mop & Temizlik Bezi** `supurge-mop-temizlik-bezi` — Ürün Grubu; atanabilir yaprak; alias: mop, çekpas, mikrofiber bez
    - **Kağıt Ürünleri** `ev-kagit-urunleri` — Ürün Grubu; atanabilir yaprak; alias: tuvalet kağıdı, kağıt havlu, peçete
    - **Çöp Torbası & Ev Eldiveni** `cop-torbasi-ev-eldiveni` — Ürün Grubu; atanabilir yaprak; alias: çöp poşeti, temizlik eldiveni
- **Züccaciye & Mutfak** `zuccaciye-mutfak` — Ana Kategori; alias: züccaciye, zuccaciye, mutfak gereçleri
  - **Pişirme Gereçleri** `pisirme-gerecleri` — Alt Kategori
    - **Tencere & Tencere Seti** `tencere-seti` — Ürün Grubu; atanabilir yaprak; alias: tencere, tencere takımı
    - **Tava & Sahan** `tava-sahan` — Ürün Grubu; atanabilir yaprak; alias: tava, sahan
    - **Düdüklü Tencere** `duduklu-tencere` — Ürün Grubu; atanabilir yaprak; alias: basınçlı tencere; risk: safety_critical
    - **Çaydanlık & Cezve** `caydanlik-cezve` — Ürün Grubu; atanabilir yaprak; alias: çaydanlık, cezve
    - **Fırın Kabı & Tepsi** `firin-kabi-tepsi` — Ürün Grubu; atanabilir yaprak; alias: borcam, fırın tepsisi
    - **Kek Kalıbı & Pişirme Kalıbı** `kek-kalibi-pisirme-kalibi` — Ürün Grubu; atanabilir yaprak; alias: kek kalıbı, kurabiye kalıbı
  - **Hazırlık & Kesme Gereçleri** `hazirlik-kesme-gerecleri` — Alt Kategori
    - **Mutfak Bıçağı & Bıçak Seti** `mutfak-bicagi-bicak-seti` — Ürün Grubu; atanabilir yaprak; alias: şef bıçağı, bıçak takımı; risk: safety_critical
    - **Kesme Tahtası** `kesme-tahtasi` — Ürün Grubu; atanabilir yaprak; alias: doğrama tahtası
    - **Rende, Soyacak & Dilimleyici** `rende-soyacak-dilimleyici` — Ürün Grubu; atanabilir yaprak; alias: rende, soyacak, mandolin
    - **Karıştırma Kabı & Ölçü Gereci** `karistirma-kabi-olcu-gereci` — Ürün Grubu; atanabilir yaprak; alias: karıştırma kabı, ölçü kabı
    - **Mutfak El Aleti** `mutfak-el-aleti` — Ürün Grubu; atanabilir yaprak; alias: spatula, maşa, kepçe, çırpıcı
  - **Sofra & Servis** `sofra-servis` — Alt Kategori
    - **Yemek Takımı** `yemek-takimi` — Ürün Grubu; atanabilir yaprak; alias: porselen yemek takımı
    - **Tabak & Kase** `tabak-kase` — Ürün Grubu; atanabilir yaprak; alias: servis tabağı, çorba kasesi
    - **Çatal, Kaşık & Bıçak Takımı** `catal-kasik-bicak-takimi` — Ürün Grubu; atanabilir yaprak; alias: çatal kaşık takımı, çkb takımı
    - **Servis Tabağı & Sunum Gereci** `servis-tabagi-sunum-gereci` — Ürün Grubu; atanabilir yaprak; alias: sunum tahtası, servis kasesi
    - **Tepsi** `tepsi` — Ürün Grubu; atanabilir yaprak; alias: servis tepsisi
  - **Bardak & İçecek Servisi** `bardak-icecek-servisi` — Alt Kategori
    - **Su & Meşrubat Bardağı** `su-mesrubat-bardagi` — Ürün Grubu; atanabilir yaprak; alias: su bardağı, meşrubat bardağı
    - **Çay Bardağı & Fincan** `cay-bardagi-fincan` — Ürün Grubu; atanabilir yaprak; alias: çay bardağı, kahve fincanı
    - **Kupa** `kupa` — Ürün Grubu; atanabilir yaprak; alias: mug, kupa bardak
    - **Sürahi & Karaf** `surahi-karaf` — Ürün Grubu; atanabilir yaprak; alias: sürahi, karaf
    - **Termos** `termos` — Ürün Grubu; atanabilir yaprak; alias: termos, vakumlu termos
  - **Mutfak Saklama & Düzenleme** `mutfak-saklama-duzenleme` — Alt Kategori
    - **Saklama Kabı** `saklama-kabi` — Ürün Grubu; atanabilir yaprak; alias: erzak kabı, kavanoz
    - **Baharatlık & Yağlık** `baharatlik-yaglik` — Ürün Grubu; atanabilir yaprak; alias: baharatlık, yağdanlık
    - **Beslenme Kutusu** `beslenme-kutusu` — Ürün Grubu; atanabilir yaprak; alias: sefer tası, lunch box
    - **Mutfak Rafı & Düzenleyici** `mutfak-rafi-duzenleyici` — Ürün Grubu; atanabilir yaprak; alias: mutfak organizer, tabaklık
    - **Buz Kalıbı & Soğutucu Çanta** `buz-kalibi-sogutucu-canta` — Ürün Grubu; atanabilir yaprak; alias: buz kalıbı, termal çanta
- **Yapı & Hırdavat** `yapi-hirdavat` — Ana Kategori; alias: hırdavat, hirdavat, nalbur, yapı malzemesi
  - **El Aletleri** `el-aletleri` — Alt Kategori
    - **Tornavida & Anahtar** `tornavida-anahtar` — Ürün Grubu; atanabilir yaprak; alias: tornavida, lokma anahtar, alyan
    - **Pense, Kerpeten & Kesici** `pense-kerpeten-kesici` — Ürün Grubu; atanabilir yaprak; alias: pense, yan keski, kerpeten
    - **Çekiç & Tokmak** `cekic-tokmak` — Ürün Grubu; atanabilir yaprak; alias: çekiç, tokmak
    - **Ölçüm & İşaretleme Aleti** `olcum-isaretleme-aleti` — Ürün Grubu; atanabilir yaprak; alias: metre, su terazisi, şerit metre
    - **Testere & Eğeleme Aleti** `testere-egeleme-aleti` — Ürün Grubu; atanabilir yaprak; alias: el testeresi, eğe
  - **Elektrikli El Aletleri** `elektrikli-el-aletleri` — Alt Kategori
    - **Matkap & Vidalama** `matkap-vidalama` — Ürün Grubu; atanabilir yaprak; alias: matkap, şarjlı vidalama; risk: safety_critical
    - **Taşlama & Polisaj** `taslama-polisaj` — Ürün Grubu; atanabilir yaprak; alias: spiral, avuç taşlama; risk: safety_critical
    - **Elektrikli Testere** `elektrikli-testere` — Ürün Grubu; atanabilir yaprak; alias: dekupaj, daire testere; risk: safety_critical
    - **Zımpara Makinesi** `zimpara-makinesi` — Ürün Grubu; atanabilir yaprak; alias: titreşimli zımpara; risk: safety_critical
    - **Kaynak & Lehim Ekipmanı** `kaynak-lehim-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: kaynak makinesi, havya; risk: safety_critical
  - **Bağlantı, Kilit & Yapı Sarfı** `baglanti-kilit-yapi-sarfi` — Alt Kategori
    - **Vida, Çivi & Dübel** `vida-civi-dubel` — Ürün Grubu; atanabilir yaprak; alias: vida, çivi, dübel
    - **Somun, Civata & Rondela** `somun-civata-rondela` — Ürün Grubu; atanabilir yaprak; alias: somun, cıvata, rondela
    - **Kapı Kilidi & Silindir** `kapi-kilidi-silindir` — Ürün Grubu; atanabilir yaprak; alias: kilit göbeği, barel
    - **Menteşe, Ray & Mobilya Donanımı** `mentese-ray-mobilya-donanimi` — Ürün Grubu; atanabilir yaprak; alias: menteşe, çekmece rayı, kulpsuz donanım
    - **Halat, Zincir & Kanca** `halat-zincir-kanca` — Ürün Grubu; atanabilir yaprak; alias: ip halat, zincir, karabina
  - **Boya, Yapıştırıcı & Kimyasal** `boya-yapistirici-kimyasal` — Alt Kategori
    - **İç & Dış Cephe Boyası** `ic-dis-cephe-boyasi` — Ürün Grubu; atanabilir yaprak; alias: duvar boyası, tavan boyası; risk: hazmat_review
    - **Ahşap & Metal Boyası** `ahsap-metal-boyasi` — Ürün Grubu; atanabilir yaprak; alias: vernik, sentetik boya; risk: hazmat_review
    - **Boya Fırçası & Rulo** `boya-fircasi-rulo` — Ürün Grubu; atanabilir yaprak; alias: boya fırçası, rulo
    - **Yapıştırıcı & Bant** `yapistirici-bant` — Ürün Grubu; atanabilir yaprak; alias: silikon, montaj yapıştırıcısı, koli bandı; risk: hazmat_review
    - **Derz, Dolgu & Mastik** `derz-dolgu-mastik` — Ürün Grubu; atanabilir yaprak; alias: derz dolgu, mastik, poliüretan köpük; risk: hazmat_review
  - **Tesisat & Elektrik Malzemeleri** `tesisat-elektrik-malzemeleri` — Alt Kategori
    - **Musluk, Batarya & Duş Sistemi** `musluk-batarya-dus-sistemi` — Ürün Grubu; atanabilir yaprak; alias: lavabo bataryası, duş başlığı
    - **Boru, Hortum & Tesisat Bağlantısı** `boru-hortum-tesisat-baglantisi` — Ürün Grubu; atanabilir yaprak; alias: PVC boru, tesisat rekoru
    - **Vana & Sifon** `vana-sifon` — Ürün Grubu; atanabilir yaprak; alias: küresel vana, lavabo sifonu
    - **Priz, Anahtar & Fiş** `priz-anahtar-fis` — Ürün Grubu; atanabilir yaprak; alias: elektrik prizi, duvar anahtarı, fiş; risk: safety_critical
    - **Kablo & Elektrik Bağlantı Elemanı** `kablo-elektrik-baglanti-elemani` — Ürün Grubu; atanabilir yaprak; alias: elektrik kablosu, klemens; risk: safety_critical
    - **Sigorta & Elektrik Panosu** `sigorta-elektrik-panosu` — Ürün Grubu; atanabilir yaprak; alias: otomatik sigorta, kaçak akım rölesi; risk: safety_critical
  - **Yapı Malzemesi & İş Güvenliği** `yapi-malzemesi-is-guvenligi` — Alt Kategori
    - **Çimento, Harç & Sıva** `cimento-harc-siva` — Ürün Grubu; atanabilir yaprak; alias: çimento, hazır harç, alçı
    - **Seramik & Zemin Kaplama** `seramik-zemin-kaplama` — Ürün Grubu; atanabilir yaprak; alias: fayans, laminat, parke
    - **Isı, Su & Ses Yalıtımı** `isi-su-ses-yalitimi` — Ürün Grubu; atanabilir yaprak; alias: yalıtım malzemesi, membran
    - **Merdiven & İskele Ekipmanı** `merdiven-iskele-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: katlanır merdiven, platform; risk: safety_critical
    - **İş Eldiveni & Koruyucu Donanım** `is-eldiveni-koruyucu-donanim` — Ürün Grubu; atanabilir yaprak; alias: baret, koruyucu gözlük, iş eldiveni; risk: safety_critical
- **Otomotiv & Motosiklet** `otomotiv-motosiklet` — Ana Kategori; alias: oto aksesuar, otomotiv, araba aksesuarı, motosiklet aksesuarı
  - **Araç İçi & Dış Aksesuar** `arac-ici-dis-aksesuar` — Alt Kategori
    - **Oto Paspas & Bagaj Havuzu** `oto-paspas-bagaj-havuzu` — Ürün Grubu; atanabilir yaprak; alias: araba paspası, bagaj havuzu
    - **Koltuk Kılıfı & Direksiyon Kılıfı** `oto-koltuk-direksiyon-kilifi` — Ürün Grubu; atanabilir yaprak; alias: oto koltuk kılıfı, direksiyon kılıfı
    - **Araç İçi Düzenleyici** `arac-ici-duzenleyici` — Ürün Grubu; atanabilir yaprak; alias: bagaj organizer, koltuk arkası düzenleyici
    - **Silecek & Ayna** `silecek-ayna` — Ürün Grubu; atanabilir yaprak; alias: silecek süpürgesi, dikiz aynası; risk: compatibility_critical
    - **Oto Dış Koruma & Kaplama** `oto-dis-koruma-kaplama` — Ürün Grubu; atanabilir yaprak; alias: araç brandası, kapı koruyucu, folyo
    - **Araç Aydınlatması** `arac-aydinlatmasi` — Ürün Grubu; atanabilir yaprak; alias: far ampulü, sinyal lambası; risk: safety_critical, compatibility_critical
  - **Oto Elektroniği & Bakım** `oto-elektronigi-bakim` — Alt Kategori
    - **Oto Multimedya & Ses** `oto-multimedya-ses` — Ürün Grubu; atanabilir yaprak; alias: teyp, araç ekranı, oto hoparlör
    - **Araç Kamerası & Navigasyon** `arac-kamerasi-navigasyon` — Ürün Grubu; atanabilir yaprak; alias: dashcam, yol kamerası, navigasyon
    - **Araç Şarj & Dönüştürücü** `arac-sarj-donusturucu` — Ürün Grubu; atanabilir yaprak; alias: çakmaklık şarjı, inverter
    - **Oto Temizlik & Bakım Ürünü** `oto-temizlik-bakim-urunu` — Ürün Grubu; atanabilir yaprak; alias: oto şampuanı, cila, torpido temizleyici; risk: hazmat_review
    - **Motor Yağı & Araç Sıvısı** `motor-yagi-arac-sivisi` — Ürün Grubu; atanabilir yaprak; alias: motor yağı, antifriz, fren hidroliği; risk: hazmat_review, compatibility_critical
    - **Akü & Takviye Ekipmanı** `aku-takviye-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: oto aküsü, akü takviye kablosu; risk: hazmat_review, safety_critical, compatibility_critical
  - **Oto Yedek Parça** `oto-yedek-parca` — Alt Kategori; risk: compatibility_critical
    - **Motor Bakım Parçaları** `motor-bakim-parcalari` — Ürün Grubu
      - **Oto Filtreleri** `oto-filtreleri` — Ürün Tipi; atanabilir yaprak; alias: yağ filtresi, hava filtresi, polen filtresi; risk: compatibility_critical
      - **Buji & Ateşleme Parçası** `buji-atesleme-parcasi` — Ürün Tipi; atanabilir yaprak; alias: buji, ateşleme bobini; risk: compatibility_critical
      - **Kayış & Gergi Parçası** `kayis-gergi-parcasi` — Ürün Tipi; atanabilir yaprak; alias: triger kayışı, V kayışı; risk: safety_critical, compatibility_critical
    - **Fren Parçaları** `fren-parcalari` — Ürün Grubu; risk: safety_critical
      - **Fren Balatası** `fren-balatasi` — Ürün Tipi; atanabilir yaprak; alias: balata; risk: safety_critical, compatibility_critical
      - **Fren Diski & Kampana** `fren-diski-kampana` — Ürün Tipi; atanabilir yaprak; alias: fren diski, kampana; risk: safety_critical, compatibility_critical
    - **Süspansiyon & Direksiyon Parçası** `suspansiyon-direksiyon-parcasi` — Ürün Grubu; atanabilir yaprak; alias: amortisör, rot başı, salıncak; risk: safety_critical, compatibility_critical
    - **Debriyaj & Şanzıman Parçası** `debriyaj-sanziman-parcasi` — Ürün Grubu; atanabilir yaprak; alias: debriyaj seti, şanzıman parçası; risk: safety_critical, compatibility_critical
    - **Egzoz & Emisyon Parçası** `egzoz-emisyon-parcasi` — Ürün Grubu; atanabilir yaprak; alias: egzoz, katalizör; risk: compatibility_critical
    - **Kaporta & Tampon Parçası** `kaporta-tampon-parcasi` — Ürün Grubu; atanabilir yaprak; alias: çamurluk, tampon, kapı parçası; risk: compatibility_critical
  - **Lastik, Jant & Yol Ekipmanı** `lastik-jant-yol-ekipmani` — Alt Kategori
    - **Otomobil Lastiği** `otomobil-lastigi` — Ürün Grubu; atanabilir yaprak; alias: oto lastik, yaz lastiği, kış lastiği; risk: safety_critical, compatibility_critical
    - **Jant & Jant Kapağı** `jant-jant-kapagi` — Ürün Grubu; atanabilir yaprak; alias: çelik jant, alaşım jant, jant kapağı; risk: compatibility_critical
    - **Kar Zinciri & Patinaj Önleyici** `kar-zinciri-patinaj-onleyici` — Ürün Grubu; atanabilir yaprak; alias: kar zinciri, kar çorabı; risk: safety_critical, compatibility_critical
    - **Lastik Tamir & Şişirme** `lastik-tamir-sisirme` — Ürün Grubu; atanabilir yaprak; alias: lastik tamir kiti, oto kompresörü
    - **Acil Yol & Çekme Ekipmanı** `acil-yol-cekme-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: reflektör, çekme halatı, takviye seti; risk: safety_critical
  - **Motosiklet Ekipmanı & Parçası** `motosiklet-ekipmani-parcasi` — Alt Kategori
    - **Motosiklet Kaskı** `motosiklet-kaski` — Ürün Grubu; atanabilir yaprak; alias: motor kaskı, motosiklet kaskı; risk: safety_critical
    - **Motosiklet Koruma Giyimi** `motosiklet-koruma-giyimi` — Ürün Grubu; atanabilir yaprak; alias: motosiklet montu, dizlik, koruma eldiveni; risk: safety_critical
    - **Motosiklet Çanta & Taşıma** `motosiklet-canta-tasima` — Ürün Grubu; atanabilir yaprak; alias: topcase, yan çanta
    - **Motosiklet Aksesuarı** `motosiklet-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: telefon tutucu, ön cam, elcik
    - **Motosiklet Yedek Parçası** `motosiklet-yedek-parcasi` — Ürün Grubu; atanabilir yaprak; alias: motor parçası, motosiklet balatası; risk: safety_critical, compatibility_critical
    - **Motosiklet Lastiği & Bakım Ürünü** `motosiklet-lastigi-bakim-urunu` — Ürün Grubu; atanabilir yaprak; alias: motor lastiği, zincir yağı; risk: safety_critical, hazmat_review, compatibility_critical
- **Kişisel Bakım & Kozmetik** `kisisel-bakim-kozmetik` — Ana Kategori; alias: kozmetik, kişisel bakım, güzellik ürünleri
  - **Cilt Bakımı** `cilt-bakimi` — Alt Kategori
    - **Yüz Temizleyici** `yuz-temizleyici` — Ürün Grubu; atanabilir yaprak; alias: yüz yıkama jeli, misel su
    - **Nemlendirici & Serum** `nemlendirici-serum` — Ürün Grubu; atanabilir yaprak; alias: yüz kremi, cilt serumu
    - **Güneş Koruyucu** `gunes-koruyucu` — Ürün Grubu; atanabilir yaprak; alias: güneş kremi, sun screen; risk: claim_sensitive
    - **Maske & Peeling** `maske-peeling` — Ürün Grubu; atanabilir yaprak; alias: yüz maskesi, peeling
    - **Göz & Dudak Bakımı** `goz-dudak-bakimi` — Ürün Grubu; atanabilir yaprak; alias: göz çevresi kremi, dudak balmı
  - **Makyaj** `makyaj` — Alt Kategori
    - **Ten Makyajı** `ten-makyaji` — Ürün Grubu; atanabilir yaprak; alias: fondöten, kapatıcı, pudra
    - **Göz Makyajı** `goz-makyaji` — Ürün Grubu; atanabilir yaprak; alias: maskara, eyeliner, far
    - **Dudak Makyajı** `dudak-makyaji` — Ürün Grubu; atanabilir yaprak; alias: ruj, dudak kalemi, lip gloss
    - **Tırnak Ürünü** `tirnak-urunu` — Ürün Grubu; atanabilir yaprak; alias: oje, tırnak bakım ürünü
    - **Makyaj Fırçası & Süngeri** `makyaj-fircasi-sungeri` — Ürün Grubu; atanabilir yaprak; alias: makyaj fırçası, beauty blender
  - **Saç Bakımı & Şekillendirme** `sac-bakimi-sekillendirme` — Alt Kategori
    - **Şampuan** `sampuan` — Ürün Grubu; atanabilir yaprak; alias: şampuan, sampuan
    - **Saç Kremi & Maske** `sac-kremi-maske` — Ürün Grubu; atanabilir yaprak; alias: saç kremi, saç maskesi
    - **Saç Boyası & Açıcı** `sac-boyasi-acici` — Ürün Grubu; atanabilir yaprak; alias: saç boyası, oksidan; risk: hazmat_review, claim_sensitive
    - **Saç Şekillendirici Ürün** `sac-sekillendirici-urun` — Ürün Grubu; atanabilir yaprak; alias: jöle, wax, saç spreyi; risk: hazmat_review
    - **Tarak, Fırça & Saç Gereci** `tarak-firca-sac-gereci` — Ürün Grubu; atanabilir yaprak; alias: tarak, saç fırçası, bigudi
    - **Saç Kurutma & Şekillendirme Cihazı** `sac-kurutma-sekillendirme-cihazi` — Ürün Grubu; atanabilir yaprak; alias: saç kurutma makinesi, saç düzleştirici
  - **Banyo, Vücut & Hijyen** `banyo-vucut-hijyen` — Alt Kategori
    - **Sabun & Duş Ürünü** `sabun-dus-urunu` — Ürün Grubu; atanabilir yaprak; alias: sabun, duş jeli, banyo köpüğü
    - **Deodorant & Ter Önleyici** `deodorant-ter-onleyici` — Ürün Grubu; atanabilir yaprak; alias: deodorant, roll-on; risk: hazmat_review
    - **Vücut Bakımı** `vucut-bakimi` — Ürün Grubu; atanabilir yaprak; alias: vücut losyonu, el kremi, ayak kremi
    - **Ağız Bakımı** `agiz-bakimi` — Ürün Grubu; atanabilir yaprak; alias: diş macunu, diş fırçası, ağız gargarası
    - **Kadın Hijyen Ürünü** `kadin-hijyen-urunu` — Ürün Grubu; atanabilir yaprak; alias: ped, tampon, menstrual kap
    - **Pamuk, Mendil & Bakım Sarfı** `pamuk-mendil-bakim-sarfi` — Ürün Grubu; atanabilir yaprak; alias: makyaj pamuğu, ıslak mendil, kulak çubuğu
  - **Parfüm, Tıraş & El-Ayak Bakımı** `parfum-tiras-el-ayak-bakimi` — Alt Kategori
    - **Parfüm** `parfum` — Ürün Grubu; atanabilir yaprak; alias: parfüm, parfum, EDP, EDT; risk: hazmat_review
    - **Kolonya & Vücut Spreyi** `kolonya-vucut-spreyi` — Ürün Grubu; atanabilir yaprak; alias: kolonya, body mist; risk: hazmat_review
    - **Tıraş Ürünü** `tiras-urunu` — Ürün Grubu; atanabilir yaprak; alias: tıraş köpüğü, jilet, tıraş sonrası
    - **Ağda & Tüy Alma Ürünü** `agda-tuy-alma-urunu` — Ürün Grubu; atanabilir yaprak; alias: ağda, tüy dökücü
    - **Manikür & Pedikür Gereci** `manikur-pedikur-gereci` — Ürün Grubu; atanabilir yaprak; alias: tırnak makası, manikür seti
    - **Tıraş & Epilasyon Cihazı** `tiras-epilasyon-cihazi` — Ürün Grubu; atanabilir yaprak; alias: tıraş makinesi, epilatör
- **Bebek & Çocuk** `bebek-cocuk` — Ana Kategori; alias: bebek ürünleri, çocuk ürünleri, anne bebek
  - **Bebek Bezi & Bakım** `bebek-bezi-bakim` — Alt Kategori
    - **Bebek Bezi** `bebek-bezi` — Ürün Grubu; atanabilir yaprak; alias: çocuk bezi, yenidoğan bezi
    - **Bebek Islak Mendili** `bebek-islak-mendili` — Ürün Grubu; atanabilir yaprak; alias: ıslak havlu, bebek mendili
    - **Bebek Cilt Bakımı** `bebek-cilt-bakimi` — Ürün Grubu; atanabilir yaprak; alias: pişik kremi, bebek yağı, bebek losyonu; risk: claim_sensitive
    - **Bebek Banyo Ürünü** `bebek-banyo-urunu` — Ürün Grubu; atanabilir yaprak; alias: bebek şampuanı, bebek sabunu
    - **Alt Değiştirme & Bakım Gereci** `alt-degistirme-bakim-gereci` — Ürün Grubu; atanabilir yaprak; alias: alt açma minderi, bebek bakım seti
  - **Bebek Beslenme** `bebek-beslenme` — Alt Kategori
    - **Biberon & Biberon Aksesuarı** `biberon-biberon-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: biberon, biberon emziği; risk: age_sensitive, safety_critical
    - **Mama Sandalyesi** `mama-sandalyesi` — Ürün Grubu; atanabilir yaprak; alias: bebek yemek sandalyesi; risk: safety_critical
    - **Bebek Tabak, Kaşık & Suluk** `bebek-tabak-kasik-suluk` — Ürün Grubu; atanabilir yaprak; alias: bebek yemek seti, alıştırma bardağı
    - **Göğüs Pompası & Emzirme Ürünü** `gogus-pompasi-emzirme-urunu` — Ürün Grubu; atanabilir yaprak; alias: süt pompası, emzirme minderi
    - **Bebek Maması & Ek Gıda** `bebek-mamasi-ek-gida` — Ürün Grubu; atanabilir yaprak; alias: mama, bebek ek gıda; risk: regulated_review, claim_sensitive
  - **Bebek Taşıma & Güvenlik** `bebek-tasima-guvenlik` — Alt Kategori
    - **Bebek Arabası** `bebek-arabasi` — Ürün Grubu; atanabilir yaprak; alias: puset, çocuk arabası; risk: safety_critical
    - **Oto Koltuğu & Yükseltici** `bebek-oto-koltugu-yukseltici` — Ürün Grubu; atanabilir yaprak; alias: çocuk oto koltuğu, booster; risk: safety_critical, compatibility_critical
    - **Ana Kucağı & Bebek Taşıyıcı** `ana-kucagi-bebek-tasiyici` — Ürün Grubu; atanabilir yaprak; alias: kanguru, sling, ana kucağı; risk: safety_critical
    - **Park Yatak & Seyahat Yatağı** `park-yatak-seyahat-yatagi` — Ürün Grubu; atanabilir yaprak; alias: park yatak, oyun parkı; risk: safety_critical
    - **Ev İçi Bebek Güvenliği** `ev-ici-bebek-guvenligi` — Ürün Grubu; atanabilir yaprak; alias: güvenlik kapısı, priz koruyucu, köşe koruyucu; risk: safety_critical
  - **Bebek Odası & Gelişim Gereçleri** `bebek-odasi-gelisim-gerecleri` — Alt Kategori
    - **Bebek Beşiği & Karyolası** `bebek-besigi-karyolasi` — Ürün Grubu; atanabilir yaprak; alias: beşik, bebek karyolası; risk: safety_critical
    - **Bebek Yatağı & Uyku Tekstili** `bebek-yatagi-uyku-tekstili` — Ürün Grubu; atanabilir yaprak; alias: bebek yatağı, bebek nevresimi; risk: safety_critical
    - **Bebek Odası Mobilyası** `bebek-odasi-mobilyasi` — Ürün Grubu; atanabilir yaprak; alias: bebek dolabı, alt değiştirme ünitesi
    - **Lazımlık & Tuvalet Eğitimi** `lazimlik-tuvalet-egitimi` — Ürün Grubu; atanabilir yaprak; alias: lazımlık, klozet adaptörü
    - **Emzik & Diş Kaşıyıcı** `emzik-dis-kasiyici` — Ürün Grubu; atanabilir yaprak; alias: emzik, diş kaşıyıcı; risk: age_sensitive, safety_critical
- **Oyuncak, Hobi & Müzik** `oyuncak-hobi-muzik` — Ana Kategori; alias: oyuncak, hobi, müzik aleti, enstrüman
  - **Erken Yaş & Eğitici Oyuncak** `erken-yas-egitici-oyuncak` — Alt Kategori
    - **Bebek Oyuncağı** `bebek-oyuncagi` — Ürün Grubu; atanabilir yaprak; alias: çıngırak, aktivite oyuncağı; risk: age_sensitive
    - **Eğitici Oyuncak** `egitici-oyuncak` — Ürün Grubu; atanabilir yaprak; alias: öğretici oyuncak, Montessori oyuncak; risk: age_sensitive
    - **Ahşap Oyuncak** `ahsap-oyuncak` — Ürün Grubu; atanabilir yaprak; alias: tahta oyuncak; risk: age_sensitive
    - **Bilim & Deney Seti** `bilim-deney-seti` — Ürün Grubu; atanabilir yaprak; alias: STEM oyuncak, deney kiti; risk: age_sensitive, hazmat_review
  - **Figür, Bebek & Rol Oyunu** `figur-bebek-rol-oyunu` — Alt Kategori
    - **Oyuncak Bebek & Aksesuarı** `oyuncak-bebek-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: oyuncak bebek, bebek evi
    - **Aksiyon Figürü** `aksiyon-figuru` — Ürün Grubu; atanabilir yaprak; alias: oyuncak figür, karakter figürü
    - **Peluş Oyuncak** `pelus-oyuncak` — Ürün Grubu; atanabilir yaprak; alias: peluş, oyuncak ayı
    - **Mutfak, Doktor & Meslek Seti** `meslek-rol-oyunu-seti` — Ürün Grubu; atanabilir yaprak; alias: oyuncak mutfak, doktor seti
    - **Kostüm & Rol Oyunu Aksesuarı** `kostum-rol-oyunu-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: çocuk kostümü, maske
  - **Araç, Yapı & Uzaktan Kumandalı Oyuncak** `arac-yapi-uzaktan-kumandali-oyuncak` — Alt Kategori
    - **Oyuncak Araba & Araç** `oyuncak-araba-arac` — Ürün Grubu; atanabilir yaprak; alias: oyuncak araba, iş makinesi oyuncağı
    - **Yapı Bloku & İnşa Seti** `yapi-bloku-insa-seti` — Ürün Grubu; atanabilir yaprak; alias: blok oyuncak, yapım seti
    - **Tren & Pist Seti** `tren-pist-seti` — Ürün Grubu; atanabilir yaprak; alias: oyuncak tren, araba pisti
    - **Uzaktan Kumandalı Araç** `uzaktan-kumandali-arac` — Ürün Grubu; atanabilir yaprak; alias: RC araba, kumandalı oyuncak; risk: age_sensitive
    - **Oyuncak Drone** `oyuncak-drone` — Ürün Grubu; atanabilir yaprak; alias: mini drone, çocuk drone; risk: regulated_review, safety_critical, age_sensitive
  - **Oyun, Puzzle & Sanat Hobisi** `oyun-puzzle-sanat-hobisi` — Alt Kategori
    - **Kutu Oyunu** `kutu-oyunu` — Ürün Grubu; atanabilir yaprak; alias: masa oyunu, board game
    - **Puzzle** `puzzle` — Ürün Grubu; atanabilir yaprak; alias: yapboz
    - **Kart Oyunu** `kart-oyunu` — Ürün Grubu; atanabilir yaprak; alias: oyun kartı
    - **Boyama & Çocuk Sanat Seti** `boyama-cocuk-sanat-seti` — Ürün Grubu; atanabilir yaprak; alias: boyama seti, parmak boya
    - **Model, Maket & Koleksiyon Kiti** `model-maket-koleksiyon-kiti` — Ürün Grubu; atanabilir yaprak; alias: maket, model kit, minyatür
  - **Müzik Enstrümanı & Ekipmanı** `muzik-enstrumani-ekipmani` — Alt Kategori
    - **Gitar & Telli Çalgı** `gitar-telli-calgi` — Ürün Grubu; atanabilir yaprak; alias: gitar, bağlama, ukulele
    - **Klavye & Piyano** `klavye-piyano` — Ürün Grubu; atanabilir yaprak; alias: org, dijital piyano
    - **Davul & Vurmalı Çalgı** `davul-vurmali-calgi` — Ürün Grubu; atanabilir yaprak; alias: davul, darbuka, perküsyon
    - **Nefesli Çalgı** `nefesli-calgi` — Ürün Grubu; atanabilir yaprak; alias: flüt, klarnet, saksafon
    - **Enstrüman Aksesuarı** `enstruman-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: gitar teli, nota sehpası, enstrüman çantası
- **Spor & Outdoor** `spor-outdoor` — Ana Kategori; alias: spor, outdoor, kamp, fitness
  - **Fitness & Antrenman** `fitness-antrenman` — Alt Kategori
    - **Ağırlık & Dambıl** `agirlik-dambil` — Ürün Grubu; atanabilir yaprak; alias: dambıl, halter, ağırlık plakası
    - **Yoga & Pilates Ekipmanı** `yoga-pilates-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: yoga matı, pilates topu
    - **Kondisyon Aleti** `kondisyon-aleti` — Ürün Grubu; atanabilir yaprak; alias: koşu bandı, eliptik bisiklet
    - **Direnç Bandı & Atlama İpi** `direnc-bandi-atlama-ipi` — Ürün Grubu; atanabilir yaprak; alias: egzersiz bandı, ip atlama
    - **Spor Koruyucu & Destek** `spor-koruyucu-destek` — Ürün Grubu; atanabilir yaprak; alias: dizlik, bileklik, spor bandajı; risk: claim_sensitive
  - **Takım & Raket Sporları** `takim-raket-sporlari` — Alt Kategori
    - **Futbol Ekipmanı** `futbol-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: futbol topu, kale, tekmelik
    - **Basketbol & Voleybol Ekipmanı** `basketbol-voleybol-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: basketbol topu, voleybol topu
    - **Tenis & Badminton Ekipmanı** `tenis-badminton-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: tenis raketi, badminton raketi
    - **Masa Tenisi Ekipmanı** `masa-tenisi-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: pinpon raketi, masa tenisi topu
    - **Kaleci & Takım Koruma Ekipmanı** `kaleci-takim-koruma-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: kaleci eldiveni, tekmelik; risk: safety_critical
  - **Bisiklet, Paten & Kaykay** `bisiklet-paten-kaykay` — Alt Kategori
    - **Bisiklet** `bisiklet` — Ürün Grubu; atanabilir yaprak; alias: şehir bisikleti, dağ bisikleti
    - **Bisiklet Parçası & Aksesuarı** `bisiklet-parcasi-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: bisiklet lastiği, bisiklet lambası; risk: compatibility_critical
    - **Bisiklet Kaskı & Koruması** `bisiklet-kaski-korumasi` — Ürün Grubu; atanabilir yaprak; alias: bisiklet kaskı, dirseklik; risk: safety_critical
    - **Paten** `paten` — Ürün Grubu; atanabilir yaprak; alias: inline skate, roller skate
    - **Kaykay & Scooter** `kaykay-scooter` — Ürün Grubu; atanabilir yaprak; alias: skateboard, scooter; risk: safety_critical
  - **Kamp, Yürüyüş & Outdoor** `kamp-yuruyus-outdoor` — Alt Kategori
    - **Çadır** `cadir` — Ürün Grubu; atanabilir yaprak; alias: kamp çadırı
    - **Uyku Tulumu & Kamp Matı** `uyku-tulumu-kamp-mati` — Ürün Grubu; atanabilir yaprak; alias: uyku tulumu, kamp matı
    - **Kamp Mobilyası** `kamp-mobilyasi` — Ürün Grubu; atanabilir yaprak; alias: kamp sandalyesi, kamp masası
    - **Kamp Ocağı & Pişirme Ekipmanı** `kamp-ocagi-pisirme-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: kamp ocağı, kamp tenceresi; risk: hazmat_review, safety_critical
    - **Fener & Outdoor Aydınlatma** `fener-outdoor-aydinlatma` — Ürün Grubu; atanabilir yaprak; alias: el feneri, kafa lambası
    - **Trekking Bastonu & Outdoor Aksesuarı** `trekking-bastonu-outdoor-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: yürüyüş baton, pusula
    - **Spor Matarası** `spor-matarasi` — Ürün Grubu; atanabilir yaprak; alias: spor matarası, su matarası, matara
  - **Balıkçılık, Su & Kış Sporları** `balikcilik-su-kis-sporlari` — Alt Kategori
    - **Olta & Balıkçılık Takımı** `olta-balikcilik-takimi` — Ürün Grubu; atanabilir yaprak; alias: olta, makara, misina
    - **Yüzme Ekipmanı** `yuzme-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: yüzücü gözlüğü, bone, palet
    - **Şnorkel & Dalış Ekipmanı** `snorkel-dalis-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: şnorkel, dalış maskesi; risk: safety_critical
    - **Şişme Deniz Ürünü** `sisme-deniz-urunu` — Ürün Grubu; atanabilir yaprak; alias: deniz yatağı, şişme bot; risk: safety_critical
    - **Kayak & Snowboard Ekipmanı** `kayak-snowboard-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: kayak, snowboard, kayak gözlüğü; risk: safety_critical
- **Kitap** `kitap` — Ana Kategori; alias: kitap, kitapçı, kitapci, yayın, yayin
  - **Kitaplar** `kitaplar` — Alt Kategori
    - **Roman & Öykü** `roman-oyku` — Ürün Grubu; atanabilir yaprak; alias: roman, öykü, hikaye kitabı
    - **Şiir & Edebiyat İnceleme** `siir-edebiyat-inceleme` — Ürün Grubu; atanabilir yaprak; alias: şiir kitabı, edebiyat incelemesi
    - **Çocuk Kitabı** `cocuk-kitabi` — Ürün Grubu; atanabilir yaprak; alias: masal kitabı, resimli kitap
    - **Gençlik Kitabı** `genclik-kitabi` — Ürün Grubu; atanabilir yaprak; alias: genç kurgu
    - **Eğitim & Sınav Kitabı** `egitim-sinav-kitabi` — Ürün Grubu; atanabilir yaprak; alias: test kitabı, soru bankası, ders kitabı
    - **Akademik & Mesleki Kitap** `akademik-mesleki-kitap` — Ürün Grubu; atanabilir yaprak; alias: üniversite kitabı, mesleki yayın
    - **Araştırma, Tarih & Toplum** `arastirma-tarih-toplum-kitabi` — Ürün Grubu; atanabilir yaprak; alias: tarih kitabı, siyaset kitabı, sosyoloji
    - **Bilim, Teknoloji & Doğa** `bilim-teknoloji-doga-kitabi` — Ürün Grubu; atanabilir yaprak; alias: bilim kitabı, teknoloji kitabı
    - **Kişisel Gelişim & İş Dünyası** `kisisel-gelisim-is-dunyasi-kitabi` — Ürün Grubu; atanabilir yaprak; alias: kişisel gelişim, ekonomi kitabı
    - **Din, Felsefe & Düşünce** `din-felsefe-dusunce-kitabi` — Ürün Grubu; atanabilir yaprak; alias: felsefe kitabı, dini kitap
    - **Sanat, Hobi & Yaşam Kitabı** `sanat-hobi-yasam-kitabi` — Ürün Grubu; atanabilir yaprak; alias: yemek kitabı, sanat kitabı, gezi kitabı
    - **Çizgi Roman & Manga** `cizgi-roman-manga` — Ürün Grubu; atanabilir yaprak; alias: çizgi roman, manga
    - **Sözlük, Atlas & Başvuru** `sozluk-atlas-basvuru-kitabi` — Ürün Grubu; atanabilir yaprak; alias: sözlük, atlas, ansiklopedi
- **Kırtasiye & Ofis** `kirtasiye-ofis` — Ana Kategori; alias: kırtasiye, kirtasiye, ofis malzemesi, okul malzemesi
  - **Yazım & Okul Gereçleri** `yazim-okul-gerecleri` — Alt Kategori
    - **Kurşun Kalem & Uç** `kursun-kalem-uc` — Ürün Grubu; atanabilir yaprak; alias: kurşun kalem, versatil kalem, kalem ucu
    - **Tükenmez, Jel & Roller Kalem** `tukenmez-jel-roller-kalem` — Ürün Grubu; atanabilir yaprak; alias: tükenmez kalem, jel kalem, roller kalem
    - **Dolma Kalem & Mürekkep** `dolma-kalem-murekkep` — Ürün Grubu; atanabilir yaprak; alias: dolma kalem, kartuş mürekkep
    - **Keçeli, Fosforlu & Tahta Kalemi** `keceli-fosforlu-tahta-kalemi` — Ürün Grubu; atanabilir yaprak; alias: keçeli kalem, fosforlu kalem, tahta kalemi
    - **Silgi, Kalemtıraş & Cetvel** `silgi-kalemtiras-cetvel` — Ürün Grubu; atanabilir yaprak; alias: silgi, kalemtıraş, cetvel
    - **Kalemlik** `kalemlik` — Ürün Grubu; atanabilir yaprak; alias: kalem kutusu
    - **Okul Geometri & Matematik Seti** `okul-geometri-matematik-seti` — Ürün Grubu; atanabilir yaprak; alias: pergel, iletki, geometri seti
  - **Defter, Kağıt & Sunum** `defter-kagit-sunum` — Alt Kategori
    - **Defter** `defter` — Ürün Grubu; atanabilir yaprak; alias: okul defteri, spiral defter
    - **Ajanda & Planlayıcı** `ajanda-planlayici` — Ürün Grubu; atanabilir yaprak; alias: ajanda, planner
    - **Not Kağıdı & Yapışkanlı Not** `not-kagidi-yapiskanli-not` — Ürün Grubu; atanabilir yaprak; alias: post-it, not kağıdı
    - **Fotokopi & Yazıcı Kağıdı** `fotokopi-yazici-kagidi` — Ürün Grubu; atanabilir yaprak; alias: A4 kağıt, fotokopi kağıdı
    - **Resim & Fon Kartonu** `resim-fon-kartonu` — Ürün Grubu; atanabilir yaprak; alias: resim kağıdı, fon kartonu, mukavva
    - **Etiket & Sticker** `etiket-sticker` — Ürün Grubu; atanabilir yaprak; alias: etiket, sticker, çıkartma
    - **Yazı Tahtası & Pano** `yazi-tahtasi-pano` — Ürün Grubu; atanabilir yaprak; alias: beyaz tahta, mantar pano
  - **Ofis, Dosyalama & Masaüstü** `ofis-dosyalama-masaustu` — Alt Kategori
    - **Klasör & Dosya** `klasor-dosya` — Ürün Grubu; atanabilir yaprak; alias: klasör, sunum dosyası, şeffaf dosya
    - **Zımba, Delgeç & Ataş** `zimba-delgec-atas` — Ürün Grubu; atanabilir yaprak; alias: zımba, delgeç, ataş
    - **Makas & Maket Bıçağı** `makas-maket-bicagi` — Ürün Grubu; atanabilir yaprak; alias: ofis makası, falçata; risk: safety_critical
    - **Masaüstü Düzenleyici** `masaustu-duzenleyici` — Ürün Grubu; atanabilir yaprak; alias: evrak rafı, kalemlik organizer
    - **Hesap Makinesi** `hesap-makinesi` — Ürün Grubu; atanabilir yaprak; alias: calculator
    - **Kaşe, Istampa & Numaratör** `kase-istampa-numarator` — Ürün Grubu; atanabilir yaprak; alias: kaşe, ıstampa, numaratör
  - **Sanat, El İşi & Paketleme** `sanat-el-isi-paketleme` — Alt Kategori
    - **Boya & Çizim Malzemesi** `boya-cizim-malzemesi` — Ürün Grubu; atanabilir yaprak; alias: akrilik boya, sulu boya, pastel boya
    - **Tuval & Çizim Yüzeyi** `tuval-cizim-yuzeyi` — Ürün Grubu; atanabilir yaprak; alias: tuval, eskiz defteri
    - **Fırça & Sanat Aracı** `firca-sanat-araci` — Ürün Grubu; atanabilir yaprak; alias: resim fırçası, palet
    - **Hobi Kağıdı & El İşi Malzemesi** `hobi-kagidi-el-isi-malzemesi` — Ürün Grubu; atanabilir yaprak; alias: keçe, eva, origami kağıdı
    - **Yapıştırıcı & Hobi Bandı** `kirtasiye-yapistirici-hobi-bandi` — Ürün Grubu; atanabilir yaprak; alias: stick yapıştırıcı, washi tape; risk: hazmat_review
    - **Kargo Poşeti, Zarf & Kutu** `kargo-poseti-zarf-kutu` — Ürün Grubu; atanabilir yaprak; alias: kargo poşeti, zarf, karton kutu
    - **Hediye Kağıdı & Paketleme** `hediye-kagidi-paketleme` — Ürün Grubu; atanabilir yaprak; alias: hediye paketi, kurdele, paket süsü
- **Pet Shop** `pet-shop` — Ana Kategori; alias: petshop, evcil hayvan ürünü, kedi köpek malzemesi
  - **Evcil Hayvan Mamaları** `evcil-hayvan-mamalari` — Alt Kategori
    - **Köpek Maması** `kopek-mamasi` — Ürün Grubu
      - **Kuru Köpek Maması** `kuru-kopek-mamasi` — Ürün Tipi; atanabilir yaprak; alias: köpek kuru mama
      - **Yaş Köpek Maması** `yas-kopek-mamasi` — Ürün Tipi; atanabilir yaprak; alias: köpek yaş mama, konserve köpek maması
      - **Köpek Ödülü** `kopek-odulu` — Ürün Tipi; atanabilir yaprak; alias: köpek ödül maması, köpek kemiği
    - **Kedi Maması** `kedi-mamasi` — Ürün Grubu
      - **Kuru Kedi Maması** `kuru-kedi-mamasi` — Ürün Tipi; atanabilir yaprak; alias: kedi kuru mama
      - **Yaş Kedi Maması** `yas-kedi-mamasi` — Ürün Tipi; atanabilir yaprak; alias: kedi yaş mama, konserve kedi maması
      - **Kedi Ödülü** `kedi-odulu` — Ürün Tipi; atanabilir yaprak; alias: kedi ödül maması, kedi maltı
    - **Kuş Yemi** `kus-yemi` — Ürün Grubu; atanabilir yaprak; alias: muhabbet kuşu yemi, kanarya yemi
    - **Balık Yemi** `balik-yemi` — Ürün Grubu; atanabilir yaprak; alias: akvaryum balık yemi
    - **Küçük Hayvan Yemi** `kucuk-hayvan-yemi` — Ürün Grubu; atanabilir yaprak; alias: kemirgen yemi, tavşan yemi
  - **Kedi & Köpek Ekipmanları** `kedi-kopek-ekipmanlari` — Alt Kategori
    - **Mama & Su Kabı** `pet-mama-su-kabi` — Ürün Grubu; atanabilir yaprak; alias: kedi mama kabı, köpek su kabı
    - **Tasma, Kayış & Göğüs Tasması** `tasma-kayis-gogus-tasmasi` — Ürün Grubu; atanabilir yaprak; alias: kedi tasması, köpek tasması, gezdirme kayışı
    - **Pet Yatağı & Minderi** `pet-yatagi-minderi` — Ürün Grubu; atanabilir yaprak; alias: kedi yatağı, köpek yatağı
    - **Pet Taşıma Çantası & Kafesi** `pet-tasima-cantasi-kafesi` — Ürün Grubu; atanabilir yaprak; alias: kedi taşıma çantası, köpek taşıma kafesi
    - **Kedi & Köpek Oyuncağı** `kedi-kopek-oyuncagi` — Ürün Grubu; atanabilir yaprak; alias: kedi oyuncağı, köpek oyuncağı
    - **Kedi Tırmalama & Mobilyası** `kedi-tirmalama-mobilyasi` — Ürün Grubu; atanabilir yaprak; alias: tırmalama tahtası, kedi evi
  - **Akvaryum, Kuş & Küçük Hayvan** `akvaryum-kus-kucuk-hayvan` — Alt Kategori
    - **Akvaryum** `akvaryum` — Ürün Grubu; atanabilir yaprak; alias: balık akvaryumu
    - **Akvaryum Filtre & Pompası** `akvaryum-filtre-pompasi` — Ürün Grubu; atanabilir yaprak; alias: akvaryum filtresi, hava motoru
    - **Akvaryum Dekor & Bakım Gereci** `akvaryum-dekor-bakim-gereci` — Ürün Grubu; atanabilir yaprak; alias: akvaryum kumu, akvaryum dekoru
    - **Kuş Kafesi & Aksesuarı** `kus-kafesi-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: kuş kafesi, tünek, kuş suluğu
    - **Kemirgen Kafesi & Ekipmanı** `kemirgen-kafesi-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: hamster kafesi, kemirgen talaşı
  - **Pet Bakım, Hijyen & Sağlık Desteği** `pet-bakim-hijyen-saglik-destegi` — Alt Kategori
    - **Kedi Kumu & Tuvaleti** `kedi-kumu-tuvaleti` — Ürün Grubu; atanabilir yaprak; alias: kedi kumu, kedi tuvaleti
    - **Pet Şampuanı & Tüy Bakımı** `pet-sampuani-tuy-bakimi` — Ürün Grubu; atanabilir yaprak; alias: kedi şampuanı, köpek şampuanı, tüy tarağı
    - **Pet Temizlik & Koku Ürünü** `pet-temizlik-koku-urunu` — Ürün Grubu; atanabilir yaprak; alias: pati temizleme, koku giderici; risk: claim_sensitive
    - **Pet Eğitim & Tuvalet Ürünü** `pet-egitim-tuvalet-urunu` — Ürün Grubu; atanabilir yaprak; alias: çiş pedi, eğitim spreyi; risk: claim_sensitive
    - **Pet Sağlık & Destek Ürünü** `pet-saglik-destek-urunu` — Ürün Grubu; atanabilir yaprak; alias: pet vitamini, pire tasması; risk: regulated_review, claim_sensitive
- **Optik** `optik` — Ana Kategori; alias: optik, gözlük, gozluk, optikçi, optikci
  - **Gözlük & Optik Ürünler** `gozluk-optik-urunler` — Alt Kategori
    - **Optik Gözlük Çerçevesi** `optik-gozluk-cercevesi` — Ürün Grubu; atanabilir yaprak; alias: numaralı gözlük çerçevesi, gözlük çerçevesi; risk: regulated_review
    - **Güneş Gözlüğü** `gunes-gozlugu` — Ürün Grubu; atanabilir yaprak; alias: güneş gözlüğü, sun glasses
    - **Hazır Okuma Gözlüğü** `hazir-okuma-gozlugu` — Ürün Grubu; atanabilir yaprak; alias: okuma gözlüğü, yakın gözlüğü; risk: regulated_review, claim_sensitive
    - **Kontakt Lens** `kontakt-lens` — Ürün Grubu; atanabilir yaprak; alias: lens, kontak lens; risk: regulated_review, claim_sensitive
    - **Lens Solüsyonu & Kabı** `lens-solusyonu-kabi` — Ürün Grubu; atanabilir yaprak; alias: lens suyu, lens kabı; risk: regulated_review
    - **Gözlük Kılıfı & Bakım Ürünü** `gozluk-kilifi-bakim-urunu` — Ürün Grubu; atanabilir yaprak; alias: gözlük kabı, gözlük bezi, gözlük ipi
- **Saat & Takı** `saat-taki` — Ana Kategori; alias: saat, takı, taki, mücevher, mucevher
  - **Saat & Saat Aksesuarları** `saat-saat-aksesuarlari` — Alt Kategori
    - **Kol Saati** `kol-saati` — Ürün Grubu; atanabilir yaprak; alias: analog saat, dijital saat
    - **Cep & Yaka Saati** `cep-yaka-saati` — Ürün Grubu; atanabilir yaprak; alias: cep saati, hemşire saati
    - **Saat Kayışı** `saat-kayisi` — Ürün Grubu; atanabilir yaprak; alias: kordon, watch band
    - **Saat Kutusu & Standı** `saat-kutusu-standi` — Ürün Grubu; atanabilir yaprak; alias: saat kutusu, saat standı
    - **Saat Pili & Yedek Bileşeni** `saat-pili-yedek-bileseni` — Ürün Grubu; atanabilir yaprak; alias: saat pili, saat camı; risk: hazmat_review, compatibility_critical
  - **Takı & Mücevher** `taki-mucevher` — Alt Kategori
    - **Kolye & Uç** `kolye-uc` — Ürün Grubu; atanabilir yaprak; alias: kolye, kolye ucu
    - **Küpe** `kupe` — Ürün Grubu; atanabilir yaprak; alias: küpe, kupe
    - **Yüzük** `yuzuk` — Ürün Grubu; atanabilir yaprak; alias: yüzük, alyans
    - **Bileklik & Halhal** `bileklik-halhal` — Ürün Grubu; atanabilir yaprak; alias: bileklik, halhal
    - **Broş, Rozet & Piercing Takısı** `bros-rozet-piercing-takisi` — Ürün Grubu; atanabilir yaprak; alias: broş, rozet, piercing
    - **Takı Kutusu & Bakım Ürünü** `taki-kutusu-bakim-urunu` — Ürün Grubu; atanabilir yaprak; alias: mücevher kutusu, takı temizleme bezi
- **Sağlık & Medikal** `saglik-medikal` — Ana Kategori; alias: medikal, sağlık ürünü, medikal malzeme; risk: regulated_review
  - **İlk Yardım & Koruyucu Ürün** `ilk-yardim-koruyucu-urun` — Alt Kategori
    - **İlk Yardım Seti** `ilk-yardim-seti` — Ürün Grubu; atanabilir yaprak; alias: ilk yardım çantası; risk: regulated_review
    - **Bandaj, Gazlı Bez & Flaster** `bandaj-gazli-bez-flaster` — Ürün Grubu; atanabilir yaprak; alias: sargı bezi, gazlı bez, yara bandı; risk: regulated_review
    - **Antiseptik & Dezenfeksiyon Ürünü** `antiseptik-dezenfeksiyon-urunu` — Ürün Grubu; atanabilir yaprak; alias: el antiseptiği, yara antiseptiği; risk: regulated_review, claim_sensitive, hazmat_review
    - **Sıcak & Soğuk Uygulama Ürünü** `sicak-soguk-uygulama-urunu` — Ürün Grubu; atanabilir yaprak; alias: sıcak su torbası, soğuk jel paketi
    - **Tıbbi Maske & Muayene Eldiveni** `tibbi-maske-muayene-eldiveni` — Ürün Grubu; atanabilir yaprak; alias: cerrahi maske, nitril eldiven; risk: regulated_review
  - **Ölçüm & Takip Cihazları** `olcum-takip-cihazlari` — Alt Kategori
    - **Ateş Ölçer** `ates-olcer` — Ürün Grubu; atanabilir yaprak; alias: termometre, temassız ateş ölçer; risk: regulated_review
    - **Tansiyon Aleti** `tansiyon-aleti` — Ürün Grubu; atanabilir yaprak; alias: tansiyon ölçer; risk: regulated_review
    - **Kan Şekeri Ölçüm Cihazı** `kan-sekeri-olcum-cihazi` — Ürün Grubu; atanabilir yaprak; alias: şeker ölçüm cihazı, glukometre; risk: regulated_review
    - **Nabız Oksimetre** `nabiz-oksimetre` — Ürün Grubu; atanabilir yaprak; alias: pulse oksimetre, oksijen ölçer; risk: regulated_review
    - **Vücut Tartısı & Analiz Cihazı** `vucut-tartisi-analiz-cihazi` — Ürün Grubu; atanabilir yaprak; alias: baskül, yağ ölçer tartı; risk: claim_sensitive
  - **Ortopedi, Hareket & Solunum Desteği** `ortopedi-hareket-solunum-destegi` — Alt Kategori
    - **Ortez & Eklem Desteği** `ortez-eklem-destegi` — Ürün Grubu; atanabilir yaprak; alias: dizlik, boyunluk, bileklik; risk: regulated_review, claim_sensitive
    - **Medikal Korse & Varis Çorabı** `medikal-korse-varis-corabi` — Ürün Grubu; atanabilir yaprak; alias: bel korsesi, varis çorabı; risk: regulated_review, claim_sensitive
    - **Baston, Koltuk Değneği & Yürüteç** `baston-koltuk-degnegi-yurutec` — Ürün Grubu; atanabilir yaprak; alias: baston, koltuk değneği, walker; risk: regulated_review, safety_critical
    - **Tekerlekli Sandalye** `tekerlekli-sandalye` — Ürün Grubu; atanabilir yaprak; alias: manuel sandalye, akülü sandalye; risk: regulated_review, safety_critical
    - **Nebulizatör & Solunum Cihazı** `nebulizator-solunum-cihazi` — Ürün Grubu; atanabilir yaprak; alias: hava makinesi, nebülizatör; risk: regulated_review
    - **Solunum Maskesi & Cihaz Aksesuarı** `solunum-maskesi-cihaz-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: CPAP maskesi, nebülizatör maskesi; risk: regulated_review, compatibility_critical
  - **Medikal Bakım & Günlük Yaşam** `medikal-bakim-gunluk-yasam` — Alt Kategori
    - **Yetişkin Hasta Bezi** `yetiskin-hasta-bezi` — Ürün Grubu; atanabilir yaprak; alias: yetişkin bezi, emici külot
    - **Yatak Koruyucu & Hasta Bakım Örtüsü** `yatak-koruyucu-hasta-bakim-ortusu` — Ürün Grubu; atanabilir yaprak; alias: yatak koruyucu örtü, hasta alt bezi
    - **Medikal Kompresyon & Bakım Tekstili** `medikal-kompresyon-bakim-tekstili` — Ürün Grubu; atanabilir yaprak; alias: kompresyon ürünü, hasta bakım tekstili; risk: regulated_review
    - **İlaç Kutusu & Günlük Takip Gereci** `ilac-kutusu-gunluk-takip-gereci` — Ürün Grubu; atanabilir yaprak; alias: hap kutusu, ilaç düzenleyici
    - **Banyo & Tuvalet Destek Ürünü** `banyo-tuvalet-destek-urunu` — Ürün Grubu; atanabilir yaprak; alias: duş taburesi, klozet yükseltici; risk: safety_critical
  - **Besin Desteği & Koruyucu Sağlık Ürünü** `besin-destegi-koruyucu-saglik-urunu` — Alt Kategori
    - **Vitamin & Mineral Desteği** `vitamin-mineral-destegi` — Ürün Grubu; atanabilir yaprak; alias: vitamin, mineral takviyesi; risk: regulated_review, claim_sensitive
    - **Protein & Sporcu Desteği** `protein-sporcu-destegi` — Ürün Grubu; atanabilir yaprak; alias: protein tozu, amino asit; risk: regulated_review, claim_sensitive
    - **Bitkisel & Fonksiyonel Destek** `bitkisel-fonksiyonel-destek` — Ürün Grubu; atanabilir yaprak; alias: bitkisel takviye, gıda takviyesi; risk: regulated_review, claim_sensitive
    - **Prezervatif & Bariyer Ürünü** `prezervatif-bariyer-urunu` — Ürün Grubu; atanabilir yaprak; alias: kondom, prezervatif; risk: regulated_review
    - **Uyku & Rahatlama Gereci** `uyku-rahatlama-gereci` — Ürün Grubu; atanabilir yaprak; alias: uyku maskesi, kulak tıkacı; risk: claim_sensitive
- **Çiçek & Bahçe** `cicek-bahce` — Ana Kategori; alias: çiçekçi, cicekci, çiçek, cicek, bahçe, bahce
  - **Canlı Bitki & Çiçek** `canli-bitki-cicek` — Alt Kategori
    - **Saksı Bitkisi** `saksi-bitkisi` — Ürün Grubu; atanabilir yaprak; alias: salon bitkisi, ev bitkisi
    - **Kaktüs & Sukulent** `kaktus-sukulent` — Ürün Grubu; atanabilir yaprak; alias: kaktüs, sukulent
    - **Bahçe Bitkisi & Fidan** `bahce-bitkisi-fidan` — Ürün Grubu; atanabilir yaprak; alias: fidan, bahçe çiçeği
    - **Kesme Çiçek & Buket** `kesme-cicek-buket` — Ürün Grubu; atanabilir yaprak; alias: buket, gül buketi, çiçek buketi
    - **Çelenk & Aranjman** `celenk-aranjman` — Ürün Grubu; atanabilir yaprak; alias: çiçek aranjmanı, çelenk
  - **Bahçe Yetiştirme & Bakım** `bahce-yetistirme-bakim` — Alt Kategori
    - **Tohum & Çiçek Soğanı** `tohum-cicek-sogani` — Ürün Grubu; atanabilir yaprak; alias: tohum, fide tohumu, çiçek soğanı
    - **Toprak & Yetiştirme Ortamı** `toprak-yetistirme-ortami` — Ürün Grubu; atanabilir yaprak; alias: saksı toprağı, torf
    - **Gübre & Bitki Besini** `gubre-bitki-besini` — Ürün Grubu; atanabilir yaprak; alias: gübre, çiçek besini; risk: regulated_review, hazmat_review
    - **Saksı & Bitki Kabı** `saksi-bitki-kabi` — Ürün Grubu; atanabilir yaprak; alias: saksı, fide kabı
    - **Sulama Ekipmanı** `sulama-ekipmani` — Ürün Grubu; atanabilir yaprak; alias: sulama hortumu, sulama tabancası, sulama kabı
    - **Bahçe El Aleti** `bahce-el-aleti` — Ürün Grubu; atanabilir yaprak; alias: budama makası, kürek, tırmık; risk: safety_critical
- **Hediyelik & Parti** `hediyelik-parti` — Ana Kategori; alias: hediyelik eşya, hediyelik, parti malzemesi, kutlama
  - **Hediye & Hatıra** `hediye-hatira` — Alt Kategori
    - **Hediyelik Obje** `hediyelik-obje` — Ürün Grubu; inactive_review; atanamaz; alias: biblo, masaüstü hediyelik
    - **Magnet & Turistik Hatıra** `magnet-turistik-hatira` — Ürün Grubu; atanabilir yaprak; alias: buzdolabı magneti, şehir hatırası
    - **Tespih & Manevi Hediyelik** `tespih-manevi-hediyelik` — Ürün Grubu; atanabilir yaprak; alias: tespih, dua boncuğu
    - **Nikah, Nişan & Bebek Hatırası** `nikah-nisan-bebek-hatirasi` — Ürün Grubu; atanabilir yaprak; alias: nikah şekeri, bebek şekeri, nişan hediyeliği
  - **Parti & Kutlama** `parti-kutlama` — Alt Kategori
    - **Balon** `balon` — Ürün Grubu; atanabilir yaprak; alias: parti balonu, folyo balon; risk: age_sensitive
    - **Parti Süsleme Seti** `parti-susleme-seti` — Ürün Grubu; atanabilir yaprak; alias: doğum günü süsü, banner, masa süsü
    - **Tek Kullanımlık Parti Sofrası** `tek-kullanimlik-parti-sofrasi` — Ürün Grubu; atanabilir yaprak; alias: parti tabağı, karton bardak, peçete
    - **Pasta Mumu & Kutlama Aksesuarı** `pasta-mumu-kutlama-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: doğum günü mumu, pasta süsü; risk: safety_critical
    - **Kostüm Partisi Aksesuarı** `kostum-partisi-aksesuari` — Ürün Grubu; atanabilir yaprak; alias: parti maskesi, parti şapkası

`CATEGORY_TAXONOMY_V1_FINAL: PASS`

`READY_FOR_TAXONOMY_INTEGRATION: YES`
