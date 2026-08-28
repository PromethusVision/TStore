# EsnaftaVar Legacy Taxonomy Split / Merge Registry

**State:** ANALYSIS ONLY — NO PRODUCT REASSIGNMENT OR RUNTIME CHANGE

## 1. Registry result

| Measure | Count |
|---|---:|
| MERGE rows | 0 |
| SPLIT rows | 83 |
| CANONICAL_FINAL splits | 16 |
| PROVISIONAL_PROPOSAL splits | 67 |
| HIGH risk splits | 4 |
| MEDIUM risk splits | 79 |
| LOW risk splits | 0 |
| Splits still requiring owner decision | 69 |
| Assignable legacy leaf splits requiring reclassification logic/manual fallback | 2 |

No exact merge is asserted. Several legacy leaves may share a future proposed L2,
but without owner-final lower-level successors they may remain distinct L3/L4
nodes; treating them as merges now would discard identity prematurely.

## 2. Risk and migration interpretation

- **HIGH:** cross-domain split, L1 semantic split, or assignable leaf split that
  can affect products/history directly.
- **MEDIUM:** non-leaf umbrella split affecting navigation, filters, URLs, and
  future descendant placement.
- **LOW:** reserved for deterministic, non-impacting splits; none qualified.

For non-leaf umbrellas, descendant type provides the first classification rule,
but direct category links and saved filters still need successor-set handling. For
the two assignable legacy leaves:

1. `telefon-tutucu`: classify by intended installation/use case; if the product
   evidence does not distinguish desk/phone-primary from vehicle-primary, require
   manual review.
2. `bilgisayar-sogutma`: classify by verified product subtype into CPU cooler,
   case fan, liquid cooling, or thermal paste/pad; without reliable subtype data,
   require manual review.

## 3. Exhaustive split registry

The following table contains every CSV row whose action is `SPLIT`. Successors are
owner-final only when `TARGET_STATE=CANONICAL_FINAL`; all other successor sets are
proposal evidence and may change.

| Legacy node | Level | Target state | Successor candidates | Confidence | Owner decision | Risk |
|---|---:|---|---|---|---|---|
| `temel-gida` | L2 | PROVISIONAL_PROPOSAL | Bakliyat, Tahıl & Makarna <br> Un, Şeker & Pişirme Malzemeleri <br> Yağ & Sirke <br> Sos, Baharat & Çeşni <br> Konserve & Kavanoz Ürünleri | MEDIUM | YES | MEDIUM |
| `kahvaltilik-sut-urunleri` | L2 | PROVISIONAL_PROPOSAL | Süt Ürünleri & Yumurta <br> Kahvaltılık | MEDIUM | YES | MEDIUM |
| `icecek-atistirmalik` | L2 | PROVISIONAL_PROPOSAL | Atıştırmalık, Şekerleme & Kuruyemiş <br> Alkolsüz İçecekler | MEDIUM | YES | MEDIUM |
| `taze-donuk-hazir-gida` | L2 | PROVISIONAL_PROPOSAL | Taze Meyve & Sebze <br> Et, Tavuk, Balık & Şarküteri <br> Ekmek, Unlu Mamuller & Pastacılık <br> Hazır & Pratik Gıda <br> Donuk Gıda | MEDIUM | YES | MEDIUM |
| `dis-giyim-tek-parca` | L2 | PROVISIONAL_PROPOSAL | Elbise & Tulum <br> Takım & Kombinler <br> Dış Giyim | MEDIUM | YES | MEDIUM |
| `ic-giyim-ev-giyimi-fonksiyonel` | L2 | PROVISIONAL_PROPOSAL | İç Giyim <br> Ev & Uyku Giyimi <br> Spor & Performans Giyimi <br> Mayo & Plaj Giyimi <br> İş Giyimi & Üniforma | MEDIUM | YES | MEDIUM |
| `gunluk-klasik-ayakkabi` | L2 | PROVISIONAL_PROPOSAL | Günlük Ayakkabılar <br> Klasik Ayakkabılar | MEDIUM | YES | MEDIUM |
| `sandalet-terlik-uzmanlik-ayakkabisi` | L2 | PROVISIONAL_PROPOSAL | Sandalet & Terlikler <br> Çocuk & Bebek Ayakkabıları <br> İş & Güvenlik Ayakkabıları <br> Ayakkabı Bakım & Aksesuarları | MEDIUM | YES | MEDIUM |
| `gunluk-cantalar` | L2 | PROVISIONAL_PROPOSAL | El, Omuz & Bel Çantaları <br> Sırt Çantaları | MEDIUM | YES | MEDIUM |
| `is-okul-cihaz-cantalari` | L2 | PROVISIONAL_PROPOSAL | Sırt Çantaları <br> Evrak, Laptop & Ekipman Çantaları | MEDIUM | YES | MEDIUM |
| `seyahat-cantalari` | L2 | PROVISIONAL_PROPOSAL | Valiz & Seyahat Çantaları <br> Seyahat Aksesuarları | MEDIUM | YES | MEDIUM |
| `kucuk-deri-giyim-tamamlayicilari` | L2 | PROVISIONAL_PROPOSAL | Cüzdan, Kartlık & Anahtarlık <br> Kemer, Pantolon Askısı & Kravat <br> Şapka, Bere & Saç Aksesuarları <br> Atkı, Şal & Eldiven <br> Şemsiyeler <br> Seyahat Aksesuarları | MEDIUM | YES | MEDIUM |
| `telefon-giyilebilir-teknoloji` | L2 | CANONICAL_FINAL | Telefon & Aksesuarları <br> Giyilebilir Teknoloji | HIGH | NO | MEDIUM |
| `telefon-aksesuarlari` | L2 | CANONICAL_FINAL | Telefon & Aksesuarları <br> Güç, Şarj & Bağlantı | HIGH | NO | MEDIUM |
| `telefon-koruma-tasima` | L3 | CANONICAL_FINAL | Telefon Kılıfları <br> Ekran Koruyucular | HIGH | NO | MEDIUM |
| `telefon-tutucu-giris-aksesuarlari` | L3 | CANONICAL_FINAL | Successor families: Telefon Tutucu & Standları <br> Telefon Kamera & Çekim Aksesuarları <br> vehicle-primary holders under Otomotiv & Motosiklet. | HIGH | YES | HIGH |
| `telefon-tutucu` | L4 | CANONICAL_FINAL | Use-case split: phone-primary holder remains under Telefon & Aksesuarları; vehicle-primary holder moves to Otomotiv & Motosiklet > Araç İçi Aksesuarları. | HIGH | YES | HIGH |
| `ses-goruntu-sistemleri` | L2 | CANONICAL_FINAL | TV & Görüntü Sistemleri <br> Ses & Kulaklık <br> Güç, Şarj & Bağlantı | HIGH | NO | MEDIUM |
| `kamera-guvenlik-elektronigi` | L2 | CANONICAL_FINAL | Fotoğraf & Kamera <br> Akıllı Ev & Güvenlik | HIGH | NO | MEDIUM |
| `elektronik-guc-kablo-bilesen` | L2 | CANONICAL_FINAL | Güç, Şarj & Bağlantı <br> Elektronik Bileşenler | HIGH | NO | MEDIUM |
| `bilgisayar-tablet-okuyucu` | L2 | CANONICAL_FINAL | Dizüstü Bilgisayar <br> Masaüstü Bilgisayar <br> Tablet <br> E-Kitap Okuyucu | HIGH | NO | MEDIUM |
| `bilgisayar-bilesenleri` | L2 | CANONICAL_FINAL | Bilgisayar Bileşenleri <br> Veri Depolama | HIGH | NO | MEDIUM |
| `ana-bilgisayar-bilesenleri` | L3 | CANONICAL_FINAL | İşlemci <br> Ekran Kartı <br> Anakart <br> RAM Bellek | HIGH | NO | MEDIUM |
| `kasa-guc-sogutma` | L3 | CANONICAL_FINAL | Güç Kaynağı <br> Bilgisayar Kasası <br> Soğutma | HIGH | NO | MEDIUM |
| `bilgisayar-sogutma` | L4 | CANONICAL_FINAL | İşlemci Soğutucu <br> Kasa Fanı <br> Sıvı Soğutma <br> Termal Macun & Ped | HIGH | NO | HIGH |
| `bilgisayar-cevre-birimleri` | L2 | CANONICAL_FINAL | Monitör <br> Klavye, Mouse & Çevre Birimleri <br> Bilgisayar Aksesuarları | HIGH | NO | MEDIUM |
| `ag-harici-depolama-baski` | L2 | CANONICAL_FINAL | Veri Depolama <br> Yazıcı, Tarayıcı & Sarf Malzemeleri <br> Ağ & İnternet Ürünleri | HIGH | NO | MEDIUM |
| `pisirme-mutfak-cihazlari` | L2 | PROVISIONAL_PROPOSAL | Büyük Pişirme Cihazları <br> Küçük Mutfak Aletleri <br> Su Isıtma & Sıcak Su Cihazları | MEDIUM | YES | MEDIUM |
| `temizlik-iklimlendirme-kisisel-ev-aleti` | L2 | PROVISIONAL_PROPOSAL | Temizlik Cihazları <br> İklimlendirme & Hava Kalitesi <br> Ütü & Tekstil Bakım Cihazları <br> Elektrikli Kişisel Bakım Cihazları <br> Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri | MEDIUM | YES | MEDIUM |
| `ev-tekstili` | L2 | PROVISIONAL_PROPOSAL | Yatak & Uyku Ürünleri <br> Ev Tekstili <br> Perde & Pencere Tekstili <br> Halı, Kilim & Paspas | MEDIUM | YES | MEDIUM |
| `dekorasyon-aydinlatma` | L2 | PROVISIONAL_PROPOSAL | Dekorasyon & Duvar Aksesuarları <br> Aydınlatma <br> Halı, Kilim & Paspas | MEDIUM | YES | MEDIUM |
| `banyo-duzenleme` | L2 | PROVISIONAL_PROPOSAL | Düzenleme & Saklama <br> Banyo Aksesuarları | MEDIUM | YES | MEDIUM |
| `pisirme-gerecleri` | L2 | PROVISIONAL_PROPOSAL | Tencere, Tava & Pişirme Kapları <br> Fırınlama & Pişirme Gereçleri | MEDIUM | YES | MEDIUM |
| `hazirlik-kesme-gerecleri` | L2 | PROVISIONAL_PROPOSAL | Mutfak Hazırlık Gereçleri <br> Bıçak & Kesme Gereçleri | MEDIUM | YES | MEDIUM |
| `sofra-servis` | L2 | PROVISIONAL_PROPOSAL | Sofra & Yemek Takımları <br> Çatal, Kaşık & Servis Gereçleri <br> Mutfak Tekstili | MEDIUM | YES | MEDIUM |
| `bardak-icecek-servisi` | L2 | PROVISIONAL_PROPOSAL | Bardak, Kupa & İçecek Servisi <br> Çay & Kahve Demleme Gereçleri | MEDIUM | YES | MEDIUM |
| `mutfak-saklama-duzenleme` | L2 | PROVISIONAL_PROPOSAL | Saklama & Mutfak Düzenleme <br> Termos, Matara & Yiyecek Taşıma | MEDIUM | YES | MEDIUM |
| `el-aletleri` | L2 | PROVISIONAL_PROPOSAL | El Aletleri & Atölye Ekipmanları <br> Ölçüm, Test & İşaretleme | MEDIUM | YES | MEDIUM |
| `elektrikli-el-aletleri` | L2 | PROVISIONAL_PROPOSAL | Elektrikli & Akülü El Aletleri <br> Alet Uçları, Aksesuarları & Sarfları | MEDIUM | YES | MEDIUM |
| `baglanti-kilit-yapi-sarfi` | L2 | PROVISIONAL_PROPOSAL | Alet Uçları, Aksesuarları & Sarfları <br> Bağlantı Elemanları & Nalburiye <br> Kilit, Kapı & Pencere Donanımları | MEDIUM | YES | MEDIUM |
| `boya-yapistirici-kimyasal` | L2 | PROVISIONAL_PROPOSAL | Boya, Kaplama & Yüzey Hazırlama <br> Yapıştırıcı, Dolgu & Yapı Kimyasalları | MEDIUM | YES | MEDIUM |
| `tesisat-elektrik-malzemeleri` | L2 | PROVISIONAL_PROPOSAL | Su Tesisatı & Armatürler <br> Elektrik Tesisatı Malzemeleri <br> Isıtma, Gaz & Havalandırma Tesisatı | MEDIUM | YES | MEDIUM |
| `yapi-malzemesi-is-guvenligi` | L2 | PROVISIONAL_PROPOSAL | Yapı Malzemeleri <br> Kaynak, Lehim & Metal İşleme <br> İş Güvenliği & Koruyucu Donanım | MEDIUM | YES | MEDIUM |
| `arac-ici-dis-aksesuar` | L2 | PROVISIONAL_PROPOSAL | Araç İçi Aksesuarları <br> Araç Dış Aksesuarları | MEDIUM | YES | MEDIUM |
| `oto-elektronigi-bakim` | L2 | PROVISIONAL_PROPOSAL | Akü & Araç Elektriği <br> Araç Elektroniği <br> Araç Bakım & Temizlik <br> Motor Yağı, Sıvı & Katkılar <br> Araç Güvenlik & Acil Durum Ürünleri | MEDIUM | YES | MEDIUM |
| `lastik-jant-yol-ekipmani` | L2 | PROVISIONAL_PROPOSAL | Lastik, Jant & Tekerlek Ürünleri <br> Araç Güvenlik & Acil Durum Ürünleri | MEDIUM | YES | MEDIUM |
| `motosiklet-ekipmani-parcasi` | L2 | PROVISIONAL_PROPOSAL | Motosiklet Yedek Parçaları <br> Motosiklet Kask & Koruma Ekipmanları <br> Araç Elektroniği | MEDIUM | YES | MEDIUM |
| `cilt-bakimi` | L2 | PROVISIONAL_PROPOSAL | Cilt Bakımı <br> Güneş Bakımı | MEDIUM | YES | MEDIUM |
| `banyo-vucut-hijyen` | L2 | PROVISIONAL_PROPOSAL | Banyo & Vücut Bakımı <br> Ağız & Diş Bakımı <br> Kişisel Hijyen | MEDIUM | YES | MEDIUM |
| `parfum-tiras-el-ayak-bakimi` | L2 | PROVISIONAL_PROPOSAL | Parfüm & Deodorant <br> El, Ayak & Tırnak Bakımı <br> Tıraş, Ağda & Epilasyon <br> Kozmetik & Bakım Aksesuarları | MEDIUM | YES | MEDIUM |
| `bebek-bezi-bakim` | L2 | PROVISIONAL_PROPOSAL | Bebek Bezi & Alt Bakım <br> Bebek Banyo, Bakım & Hijyen | MEDIUM | YES | MEDIUM |
| `bebek-beslenme` | L2 | PROVISIONAL_PROPOSAL | Bebek Beslenme <br> Emzirme & Anne Sütü Ürünleri | MEDIUM | YES | MEDIUM |
| `bebek-tasima-guvenlik` | L2 | PROVISIONAL_PROPOSAL | Bebek Arabaları & Taşıma <br> Oto Koltukları & Seyahat Güvenliği <br> Bebek Güvenlik & Ev İçi Koruma | MEDIUM | YES | MEDIUM |
| `bebek-odasi-gelisim-gerecleri` | L2 | PROVISIONAL_PROPOSAL | Bebek Odası & Uyku <br> Bebek Güvenlik & Ev İçi Koruma <br> Hamilelik & Lohusalık Ürünleri | MEDIUM | YES | MEDIUM |
| `oyuncak-hobi-muzik` | L1 | CANONICAL_FINAL | Oyuncak & Hobi <br> Müzik & Enstrüman | HIGH | NO | HIGH |
| `erken-yas-egitici-oyuncak` | L2 | PROVISIONAL_PROPOSAL | Bebek & Okul Öncesi Oyuncaklar <br> Eğitici, Bilim & Keşif Oyuncakları | MEDIUM | YES | MEDIUM |
| `figur-bebek-rol-oyunu` | L2 | PROVISIONAL_PROPOSAL | Figür, Bebek & Rol Oyunları <br> Koleksiyon Ürünleri | MEDIUM | YES | MEDIUM |
| `arac-yapi-uzaktan-kumandali-oyuncak` | L2 | PROVISIONAL_PROPOSAL | Yapı & İnşa Oyuncakları <br> Oyuncak Araçlar & Uzaktan Kumandalı Oyuncaklar <br> Açık Hava & Aktivite Oyuncakları | MEDIUM | YES | MEDIUM |
| `oyun-puzzle-sanat-hobisi` | L2 | PROVISIONAL_PROPOSAL | Kutu Oyunları & Oyun Takımları <br> Puzzle & Zeka Oyunları <br> Model, Maket & Minyatür <br> Koleksiyon Ürünleri <br> Sanat, El İşi & Hobi Kitleri | MEDIUM | YES | MEDIUM |
| `muzik-enstrumani-ekipmani` | L2 | PROVISIONAL_PROPOSAL | Gitar & Bas <br> Piyano, Org & Klavyeli Çalgılar <br> Telli & Yaylı Çalgılar <br> Nefesli Çalgılar <br> Vurmalı Çalgılar <br> Geleneksel Türk Müziği Enstrümanları <br> Elektronik Müzik & DJ Ekipmanları <br> Stüdyo, Kayıt & Canlı Ses Ekipmanları <br> Enstrüman Amfi & Efektleri <br> Enstrüman Aksesuar, Bakım & Sarf Malzemeleri | MEDIUM | YES | MEDIUM |
| `fitness-antrenman` | L2 | PROVISIONAL_PROPOSAL | Fitness & Kondisyon <br> Bireysel Sporlar & Jimnastik <br> Dövüş Sporları | MEDIUM | YES | MEDIUM |
| `takim-raket-sporlari` | L2 | PROVISIONAL_PROPOSAL | Takım Sporları <br> Raket Sporları | MEDIUM | YES | MEDIUM |
| `bisiklet-paten-kaykay` | L2 | PROVISIONAL_PROPOSAL | Bisiklet <br> Bireysel Sporlar & Jimnastik | MEDIUM | YES | MEDIUM |
| `balikcilik-su-kis-sporlari` | L2 | PROVISIONAL_PROPOSAL | Balıkçılık & Avcılık <br> Su Sporları <br> Kış Sporları | MEDIUM | YES | MEDIUM |
| `kitaplar` | L2 | PROVISIONAL_PROPOSAL | Edebiyat & Kurgu <br> Çocuk & Gençlik Kitapları <br> Eğitim & Ders Kitapları <br> Sınav Hazırlık Kitapları <br> Akademik & Mesleki Kitaplar <br> Araştırma, İnceleme & Düşünce <br> Kişisel Gelişim & Yaşam <br> Sanat, Kültür & Hobi Kitapları <br> Çizgi Roman & Manga <br> Dil Öğrenimi & Sözlükler | MEDIUM | YES | MEDIUM |
| `yazim-okul-gerecleri` | L2 | PROVISIONAL_PROPOSAL | Kalem & Yazım Gereçleri <br> Yapıştırıcı, Bant & Kesim Gereçleri <br> Okul Kırtasiyesi & Eğitim Gereçleri | MEDIUM | YES | MEDIUM |
| `defter-kagit-sunum` | L2 | PROVISIONAL_PROPOSAL | Defter, Ajanda & Planlayıcılar <br> Kağıt, Etiket & Baskı Sarfı <br> Sunum, Pano & Yazı Tahtası Ürünleri | MEDIUM | YES | MEDIUM |
| `ofis-dosyalama-masaustu` | L2 | PROVISIONAL_PROPOSAL | Dosyalama & Arşivleme <br> Masaüstü Ofis Gereçleri <br> Ofis Makineleri & Ciltleme Ekipmanları | MEDIUM | YES | MEDIUM |
| `sanat-el-isi-paketleme` | L2 | PROVISIONAL_PROPOSAL | Sanat & Çizim Malzemeleri <br> Paketleme & Postalama Ürünleri | MEDIUM | YES | MEDIUM |
| `evcil-hayvan-mamalari` | L2 | PROVISIONAL_PROPOSAL | Kedi Ürünleri <br> Köpek Ürünleri <br> Akvaryum & Balık Ürünleri <br> Kuş Ürünleri <br> Küçük Hayvan Ürünleri <br> Sürüngen & Egzotik Pet Ürünleri | MEDIUM | YES | MEDIUM |
| `kedi-kopek-ekipmanlari` | L2 | PROVISIONAL_PROPOSAL | Kedi Ürünleri <br> Köpek Ürünleri | MEDIUM | YES | MEDIUM |
| `akvaryum-kus-kucuk-hayvan` | L2 | PROVISIONAL_PROPOSAL | Akvaryum & Balık Ürünleri <br> Kuş Ürünleri <br> Küçük Hayvan Ürünleri <br> Sürüngen & Egzotik Pet Ürünleri | MEDIUM | YES | MEDIUM |
| `pet-bakim-hijyen-saglik-destegi` | L2 | PROVISIONAL_PROPOSAL | Kedi Ürünleri <br> Köpek Ürünleri <br> Ortak Pet Bakım & Aksesuarları | MEDIUM | YES | MEDIUM |
| `gozluk-optik-urunler` | L2 | PROVISIONAL_PROPOSAL | Optik Gözlük Çerçeveleri <br> Güneş Gözlükleri <br> Hazır Okuma Gözlükleri <br> Gözlük Camları <br> Kontakt Lensler <br> Kontakt Lens Bakım Ürünleri <br> Gözlük & Optik Aksesuarları | MEDIUM | YES | MEDIUM |
| `saat-saat-aksesuarlari` | L2 | PROVISIONAL_PROPOSAL | Klasik Kol Saatleri <br> Cep Saatleri <br> Saat Kayışları & Aksesuarları | MEDIUM | YES | MEDIUM |
| `taki-mucevher` | L2 | PROVISIONAL_PROPOSAL | Kolyeler & Takı Uçları <br> Küpeler <br> Yüzükler <br> Bileklik, Bilezik & Halhallar <br> Broş & Giyim Takıları <br> Vücut Takıları <br> Takı Aksesuarları & Saklama <br> Takı Yapım Malzemeleri | MEDIUM | YES | MEDIUM |
| `ilk-yardim-koruyucu-urun` | L2 | PROVISIONAL_PROPOSAL | İlk Yardım & Yara Bakımı <br> Kişisel Koruyucu Medikal Ürünler | MEDIUM | YES | MEDIUM |
| `ortopedi-hareket-solunum-destegi` | L2 | PROVISIONAL_PROPOSAL | Ortopedik Destekler & Kompresyon <br> Hareket & Mobilite Yardımcıları <br> Rehabilitasyon & Fizik Tedavi Ürünleri <br> Solunum & Evde Bakım Cihazları | MEDIUM | YES | MEDIUM |
| `medikal-bakim-gunluk-yasam` | L2 | PROVISIONAL_PROPOSAL | Medikal Sarf & Hasta Bakım Ürünleri <br> Günlük Yaşam & Erişilebilirlik Yardımcıları | MEDIUM | YES | MEDIUM |
| `canli-bitki-cicek` | L2 | PROVISIONAL_PROPOSAL | Canlı Saksı Bitkileri <br> Kesme Çiçek & Fiziksel Aranjmanlar <br> Tohum, Fide & Bitki Soğanları | MEDIUM | YES | MEDIUM |
| `bahce-yetistirme-bakim` | L2 | PROVISIONAL_PROPOSAL | Saksı, Saksılık & Bitki Kapları <br> Toprak, Gübre & Bitki Besleme <br> Sulama Ürünleri <br> Bahçe El Aletleri <br> Bitki Bakım & Yetiştirme Ürünleri <br> Sera & Yetiştirme Ekipmanları <br> Bahçe Dekorasyonu & Peyzaj Aksesuarları | MEDIUM | YES | MEDIUM |
| `hediye-hatira` | L2 | PROVISIONAL_PROPOSAL | Hatıra & Hediyelik Objeler <br> Hediye Paketleme & Sunum <br> Tebrik Kartları, Davetiyeler & Kutlama Yazıları | MEDIUM | YES | MEDIUM |
| `parti-kutlama` | L2 | PROVISIONAL_PROPOSAL | Balon & Balon Aksesuarları <br> Parti Süsleri & Mekân Dekorasyonu <br> Parti Sofrası & Servis Ürünleri <br> Kostüm, Maske & Parti Aksesuarları <br> Pasta Süsleme & Kutlama Aksesuarları <br> Parti Eğlence & Fotoğraf Aksesuarları | MEDIUM | YES | MEDIUM |

## 4. Merge registry

There are no `MERGE` rows in this audit. This zero result is reconciled with the
CSV and is intentional. A future owner-final L3/L4 design may establish true
many-to-one identity merges; any such change must add predecessor IDs, one
successor, analytics implications, product reassignment rules, and owner approval
to a versioned successor graph.

## 5. Common implications

### Analytics

Historical facts should retain predecessor identity. Reports may aggregate through
versioned successor edges but must distinguish original observations from
reclassified current taxonomy. Splits must not rewrite old data as though the
successor had existed historically.

### Product reassignment

Non-leaf split rows usually route through existing descendants. Assignable leaf
splits require deterministic evidence or a manual queue. A product must never be
duplicated across multiple primary categories to avoid choosing a successor.

### URLs, saved filters, and aliases

Old split slugs resolve to an explicit successor set or disambiguation state, not
one arbitrary child. Saved filters must be version-aware and indicate when the
meaning broadened or narrowed.

### Policy

None of the 83 split rows itself carries a legacy `risk_flag`, but descendants may
be policy-gated. Taxonomy successor selection does not authorize listing or sale.

## 6. Registry acceptance

- CSV split rows represented: 83/83.
- CSV merge rows represented: 0/0.
- Known successor counts preserved: yes.
- Owner-final/provisional state separated: yes.
- Production product counts/reassignments: unknown; Production was not queried.
- Runtime implementation: none.
