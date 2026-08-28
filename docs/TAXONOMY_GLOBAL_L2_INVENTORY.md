# EsnaftaVar Global L2 Inventory

**Wave:** 15 / Global L2 Cross-Batch Audit
**Audit date:** 28 August 2026
**State:** Audit inventory; no owner finalization
**Base:** `origin/main@f092cf8fe7431f812a017d4cbc9b538775bb41e6`

## Source contract

The audit branch was created directly from current `origin/main`. Proposal branches were read with `git show`; they were not merged, checked out, or rewritten.

| Source | Remote HEAD used | Scope |
|---|---|---|
| Canonical main | `origin/main@f092cf8fe7431f812a017d4cbc9b538775bb41e6` | Owner-final 24 L1, Electronics/Computer L2, two L3/L4 pilots and reusable method |
| Batch 01 | `origin/agent3/w15-overnight-taxonomy-batch-01@4b500a629e3ca6f388617c49aae16fe32538a378` | 6 proposed L1 / 70 proposed L2 |
| Batch 02 | `origin/agent1/w15-overnight-taxonomy-batch-02@bca5d57c359dc4f767972597551aa6616031b667` | 8 proposed L1 / 77 proposed L2 |
| Batch 03 | `origin/agent2/w15-overnight-taxonomy-batch-03@f1e766eeacbcbc1f1ed69ee18d040321645a6796` | 8 proposed L1 / 77 proposed L2 |

`Policy risk` is an audit signal, not listing permission. `Cross-domain dependency count` counts materially adjacent canonical L1s identified during this audit; it is not taxonomy depth or a product count.

## Global 24-L1 inventory

| # | L1 | State | L2 count | Exact L2 list | Source batch | Source commit / remote HEAD | Policy risk | Cross-domain dependency count |
|---:|---|---|---:|---|---|---|---|---:|
| 1 | Gıda & İçecek | PROPOSED FOR OWNER REVIEW | 14 | Taze Meyve & Sebze<br>Et, Tavuk, Balık & Şarküteri<br>Süt Ürünleri & Yumurta<br>Ekmek, Unlu Mamuller & Pastacılık<br>Bakliyat, Tahıl & Makarna<br>Un, Şeker & Pişirme Malzemeleri<br>Yağ & Sirke<br>Kahvaltılık<br>Atıştırmalık, Şekerleme & Kuruyemiş<br>Alkolsüz İçecekler<br>Sos, Baharat & Çeşni<br>Konserve & Kavanoz Ürünleri<br>Hazır & Pratik Gıda<br>Donuk Gıda | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | HIGH — infant formula, supplement, alcohol and prepared-food scope | 4 |
| 2 | Giyim & Moda | PROPOSED FOR OWNER REVIEW | 10 | Üst Giyim<br>Alt Giyim<br>Elbise & Tulum<br>Takım & Kombinler<br>Dış Giyim<br>İç Giyim<br>Ev & Uyku Giyimi<br>Spor & Performans Giyimi<br>Mayo & Plaj Giyimi<br>İş Giyimi & Üniforma | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | MEDIUM — PPE claims and specialized life-stage products | 4 |
| 3 | Ayakkabı | PROPOSED FOR OWNER REVIEW | 8 | Günlük Ayakkabılar<br>Spor Ayakkabıları<br>Klasik Ayakkabılar<br>Bot & Çizmeler<br>Sandalet & Terlikler<br>Çocuk & Bebek Ayakkabıları<br>İş & Güvenlik Ayakkabıları<br>Ayakkabı Bakım & Aksesuarları | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | MEDIUM — PPE certification and medical-claim boundary | 4 |
| 4 | Çanta & Aksesuar | PROPOSED FOR OWNER REVIEW | 10 | El, Omuz & Bel Çantaları<br>Sırt Çantaları<br>Evrak, Laptop & Ekipman Çantaları<br>Valiz & Seyahat Çantaları<br>Cüzdan, Kartlık & Anahtarlık<br>Kemer, Pantolon Askısı & Kravat<br>Şapka, Bere & Saç Aksesuarları<br>Atkı, Şal & Eldiven<br>Şemsiyeler<br>Seyahat Aksesuarları | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | MEDIUM — weapon-carrying goods and counterfeit claims | 5 |
| 5 | Elektronik | OWNER FINAL L2 | 9 | Telefon & Aksesuarları<br>TV & Görüntü Sistemleri<br>Ses & Kulaklık<br>Fotoğraf & Kamera<br>Oyun Konsolu & Aksesuarları<br>Giyilebilir Teknoloji<br>Akıllı Ev & Güvenlik<br>Güç, Şarj & Bağlantı<br>Elektronik Bileşenler | Canonical main | `f092cf8fe7431f812a017d4cbc9b538775bb41e6` | MEDIUM — batteries, mains voltage, radio and connected-device claims | 12 |
| 6 | Bilgisayar & Tablet | OWNER FINAL L2 | 11 | Dizüstü Bilgisayar<br>Masaüstü Bilgisayar<br>Tablet<br>E-Kitap Okuyucu<br>Monitör<br>Bilgisayar Bileşenleri<br>Veri Depolama<br>Klavye, Mouse & Çevre Birimleri<br>Bilgisayar Aksesuarları<br>Yazıcı, Tarayıcı & Sarf Malzemeleri<br>Ağ & İnternet Ürünleri | Canonical main | `f092cf8fe7431f812a017d4cbc9b538775bb41e6` | LOW/MEDIUM — electrical, battery and network-equipment compliance | 7 |
| 7 | Beyaz Eşya & Ev Aletleri | PROPOSED FOR OWNER REVIEW | 10 | Soğutma & Gıda Saklama Cihazları<br>Çamaşır & Bulaşık Bakım Cihazları<br>Büyük Pişirme Cihazları<br>Küçük Mutfak Aletleri<br>Temizlik Cihazları<br>İklimlendirme & Hava Kalitesi<br>Su Isıtma & Sıcak Su Cihazları<br>Ütü & Tekstil Bakım Cihazları<br>Elektrikli Kişisel Bakım Cihazları<br>Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | HIGH — gas/fixed installation, sterilization and electrical safety | 5 |
| 8 | Ev & Yaşam | PROPOSED FOR OWNER REVIEW | 10 | Mobilya<br>Yatak & Uyku Ürünleri<br>Ev Tekstili<br>Perde & Pencere Tekstili<br>Halı, Kilim & Paspas<br>Dekorasyon & Duvar Aksesuarları<br>Aydınlatma<br>Düzenleme & Saklama<br>Banyo Aksesuarları<br>Ev Temizliği & Çamaşır Bakımı | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | MEDIUM — cleaning chemicals, electrical installation and custom-service leakage | 5 |
| 9 | Züccaciye & Mutfak | PROPOSED FOR OWNER REVIEW | 11 | Tencere, Tava & Pişirme Kapları<br>Fırınlama & Pişirme Gereçleri<br>Mutfak Hazırlık Gereçleri<br>Bıçak & Kesme Gereçleri<br>Sofra & Yemek Takımları<br>Çatal, Kaşık & Servis Gereçleri<br>Bardak, Kupa & İçecek Servisi<br>Çay & Kahve Demleme Gereçleri<br>Saklama & Mutfak Düzenleme<br>Termos, Matara & Yiyecek Taşıma<br>Mutfak Tekstili | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | MEDIUM — food-contact materials, blades and professional systems | 5 |
| 10 | Yapı, Hırdavat & Tesisat | PROPOSED FOR OWNER REVIEW | 14 | El Aletleri & Atölye Ekipmanları<br>Elektrikli & Akülü El Aletleri<br>Alet Uçları, Aksesuarları & Sarfları<br>Bağlantı Elemanları & Nalburiye<br>Ölçüm, Test & İşaretleme<br>Boya, Kaplama & Yüzey Hazırlama<br>Yapıştırıcı, Dolgu & Yapı Kimyasalları<br>Yapı Malzemeleri<br>Su Tesisatı & Armatürler<br>Elektrik Tesisatı Malzemeleri<br>Isıtma, Gaz & Havalandırma Tesisatı<br>Kilit, Kapı & Pencere Donanımları<br>Kaynak, Lehim & Metal İşleme<br>İş Güvenliği & Koruyucu Donanım | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | HIGH — mains/gas, hazardous chemicals, PPE and installer-only products | 7 |
| 11 | Otomotiv & Motosiklet | PROPOSED FOR OWNER REVIEW | 11 | Otomobil Yedek Parçaları<br>Motosiklet Yedek Parçaları<br>Araç İçi Aksesuarları<br>Araç Dış Aksesuarları<br>Lastik, Jant & Tekerlek Ürünleri<br>Akü & Araç Elektriği<br>Araç Elektroniği<br>Araç Bakım & Temizlik<br>Motor Yağı, Sıvı & Katkılar<br>Motosiklet Kask & Koruma Ekipmanları<br>Araç Güvenlik & Acil Durum Ürünleri | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | HIGH — batteries, fluids, aerosols, extinguishers and fitment safety | 5 |
| 12 | Kozmetik & Kişisel Bakım | PROPOSED FOR OWNER REVIEW | 11 | Makyaj<br>Cilt Bakımı<br>Güneş Bakımı<br>Saç Bakımı & Şekillendirme<br>Parfüm & Deodorant<br>Banyo & Vücut Bakımı<br>El, Ayak & Tırnak Bakımı<br>Ağız & Diş Bakımı<br>Kişisel Hijyen<br>Tıraş, Ağda & Epilasyon<br>Kozmetik & Bakım Aksesuarları | Batch 01 | `4b500a629e3ca6f388617c49aae16fe32538a378` | HIGH — medical/biosidal intended use, baby products and claims | 4 |
| 13 | Anne & Bebek | PROPOSED FOR OWNER REVIEW | 9 | Bebek Beslenme<br>Emzirme & Anne Sütü Ürünleri<br>Bebek Bezi & Alt Bakım<br>Bebek Banyo, Bakım & Hijyen<br>Bebek Arabaları & Taşıma<br>Oto Koltukları & Seyahat Güvenliği<br>Bebek Odası & Uyku<br>Bebek Güvenlik & Ev İçi Koruma<br>Hamilelik & Lohusalık Ürünleri | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | HIGH — formula, child restraint, sleep claims, hygiene and used safety goods | 5 |
| 14 | Oyuncak & Hobi | PROPOSED FOR OWNER REVIEW | 11 | Bebek & Okul Öncesi Oyuncaklar<br>Eğitici, Bilim & Keşif Oyuncakları<br>Figür, Bebek & Rol Oyunları<br>Yapı & İnşa Oyuncakları<br>Oyuncak Araçlar & Uzaktan Kumandalı Oyuncaklar<br>Kutu Oyunları & Oyun Takımları<br>Puzzle & Zeka Oyunları<br>Model, Maket & Minyatür<br>Koleksiyon Ürünleri<br>Sanat, El İşi & Hobi Kitleri<br>Açık Hava & Aktivite Oyuncakları | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | HIGH — child safety, magnets/batteries, chemistry and weapon-like products | 5 |
| 15 | Müzik & Enstrüman | PROPOSED FOR OWNER REVIEW | 10 | Gitar & Bas<br>Piyano, Org & Klavyeli Çalgılar<br>Telli & Yaylı Çalgılar<br>Nefesli Çalgılar<br>Vurmalı Çalgılar<br>Geleneksel Türk Müziği Enstrümanları<br>Elektronik Müzik & DJ Ekipmanları<br>Stüdyo, Kayıt & Canlı Ses Ekipmanları<br>Enstrüman Amfi & Efektleri<br>Enstrüman Aksesuar, Bakım & Sarf Malzemeleri | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | MEDIUM/HIGH — protected materials, radio and high-power equipment | 4 |
| 16 | Spor & Outdoor | PROPOSED FOR OWNER REVIEW | 10 | Fitness & Kondisyon<br>Takım Sporları<br>Raket Sporları<br>Bireysel Sporlar & Jimnastik<br>Dövüş Sporları<br>Outdoor, Kamp & Trekking<br>Bisiklet<br>Su Sporları<br>Kış Sporları<br>Balıkçılık & Avcılık | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | HIGH — hunting/weapon-like goods, climbing/diving and compressed fuel | 7 |
| 17 | Kitap | PROPOSED FOR OWNER REVIEW | 10 | Edebiyat & Kurgu<br>Çocuk & Gençlik Kitapları<br>Eğitim & Ders Kitapları<br>Sınav Hazırlık Kitapları<br>Akademik & Mesleki Kitaplar<br>Araştırma, İnceleme & Düşünce<br>Kişisel Gelişim & Yaşam<br>Sanat, Kültür & Hobi Kitapları<br>Çizgi Roman & Manga<br>Dil Öğrenimi & Sözlükler | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | LOW/MEDIUM — illegal copies and content restrictions | 2 |
| 18 | Kırtasiye & Ofis | PROPOSED FOR OWNER REVIEW | 11 | Kalem & Yazım Gereçleri<br>Defter, Ajanda & Planlayıcılar<br>Kağıt, Etiket & Baskı Sarfı<br>Dosyalama & Arşivleme<br>Masaüstü Ofis Gereçleri<br>Yapıştırıcı, Bant & Kesim Gereçleri<br>Okul Kırtasiyesi & Eğitim Gereçleri<br>Sanat & Çizim Malzemeleri<br>Sunum, Pano & Yazı Tahtası Ürünleri<br>Ofis Makineleri & Ciltleme Ekipmanları<br>Paketleme & Postalama Ürünleri | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | MEDIUM — cutters, solvents, adhesives and art chemicals | 4 |
| 19 | Evcil Hayvan Ürünleri | PROPOSED FOR OWNER REVIEW | 7 | Kedi Ürünleri<br>Köpek Ürünleri<br>Akvaryum & Balık Ürünleri<br>Kuş Ürünleri<br>Küçük Hayvan Ürünleri<br>Sürüngen & Egzotik Pet Ürünleri<br>Ortak Pet Bakım & Aksesuarları | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | HIGH — live animals, veterinary medicine, supplements and hygiene claims | 4 |
| 20 | Gözlük & Optik | PROPOSED FOR OWNER REVIEW | 7 | Optik Gözlük Çerçeveleri<br>Güneş Gözlükleri<br>Hazır Okuma Gözlükleri<br>Gözlük Camları<br>Kontakt Lensler<br>Kontakt Lens Bakım Ürünleri<br>Gözlük & Optik Aksesuarları | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | HIGH — prescription/custom optics, contacts and merchant eligibility | 4 |
| 21 | Saat & Takı | PROPOSED FOR OWNER REVIEW | 11 | Klasik Kol Saatleri<br>Cep Saatleri<br>Saat Kayışları & Aksesuarları<br>Kolyeler & Takı Uçları<br>Küpeler<br>Yüzükler<br>Bileklik, Bilezik & Halhallar<br>Broş & Giyim Takıları<br>Vücut Takıları<br>Takı Aksesuarları & Saklama<br>Takı Yapım Malzemeleri | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | HIGH — precious/high-value goods, authenticity and body jewelry | 3 |
| 22 | Sağlık & Medikal | PROPOSED FOR OWNER REVIEW | 9 | İlk Yardım & Yara Bakımı<br>Evde Sağlık Ölçüm Cihazları<br>Ortopedik Destekler & Kompresyon<br>Hareket & Mobilite Yardımcıları<br>Rehabilitasyon & Fizik Tedavi Ürünleri<br>Solunum & Evde Bakım Cihazları<br>Medikal Sarf & Hasta Bakım Ürünleri<br>Kişisel Koruyucu Medikal Ürünler<br>Günlük Yaşam & Erişilebilirlik Yardımcıları | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | CRITICAL — medicine exclusion, medical device eligibility and professional-only goods | 8 |
| 23 | Çiçek & Bahçe | PROPOSED FOR OWNER REVIEW | 11 | Canlı Saksı Bitkileri<br>Kesme Çiçek & Fiziksel Aranjmanlar<br>Tohum, Fide & Bitki Soğanları<br>Yapay Çiçek & Yapay Bitkiler<br>Saksı, Saksılık & Bitki Kapları<br>Toprak, Gübre & Bitki Besleme<br>Sulama Ürünleri<br>Bahçe El Aletleri<br>Bitki Bakım & Yetiştirme Ürünleri<br>Sera & Yetiştirme Ekipmanları<br>Bahçe Dekorasyonu & Peyzaj Aksesuarları | Batch 03 | `f1e766eeacbcbc1f1ed69ee18d040321645a6796` | HIGH — live goods, seed/fertilizer controls and plant-protection exclusion | 5 |
| 24 | Hediyelik & Parti | PROPOSED FOR OWNER REVIEW | 9 | Hatıra & Hediyelik Objeler<br>Hediye Paketleme & Sunum<br>Tebrik Kartları, Davetiyeler & Kutlama Yazıları<br>Balon & Balon Aksesuarları<br>Parti Süsleri & Mekân Dekorasyonu<br>Parti Sofrası & Servis Ürünleri<br>Kostüm, Maske & Parti Aksesuarları<br>Pasta Süsleme & Kutlama Aksesuarları<br>Parti Eğlence & Fotoğraf Aksesuarları | Batch 02 | `bca5d57c359dc4f767972597551aa6616031b667` | HIGH — pyrotechnics, pressurized gas, flame/electrical and child safety | 7 |

## Count reconciliation

| Inventory slice | L1 count | L2 count | State |
|---|---:|---:|---|
| Batch 01 | 6 | 70 | PROPOSED FOR OWNER REVIEW |
| Batch 02 | 8 | 77 | PROPOSED FOR OWNER REVIEW |
| Batch 03 | 8 | 77 | PROPOSED FOR OWNER REVIEW |
| **All non-final proposals** | **22** | **224** | **PROPOSED FOR OWNER REVIEW** |
| Elektronik | 1 | 9 | OWNER FINAL L2 |
| Bilgisayar & Tablet | 1 | 11 | OWNER FINAL L2 |
| **Global 24-L1 view** | **24** | **244** | Mixed state; runtime not started |

## Independent integrity checks

- Canonical L1 names represented: **24/24**.
- Proposal domains represented once: **22/22**.
- Proposal counts: **70 + 77 + 77 = 224**.
- Exact proposed L2 names reproduced in source order: **224/224**.
- Exact or normalized duplicate L2 display names across the 224 proposals: **0**.
- Existing canonical final domains reopened: **NO**.
- Proposal branches merged: **NO**.
- Runtime taxonomy or stable IDs created: **NO**.

The absence of exact duplicate L2 display names does not mean the taxonomy is collision-free. Semantic overlaps, ownership ambiguity, facet leakage and policy boundaries are audited in the following global documents.
