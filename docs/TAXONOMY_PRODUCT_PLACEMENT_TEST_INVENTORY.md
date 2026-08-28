# Global Taxonomy Product-Placement Test Inventory

## Status

**AUDIT INVENTORY — NO OWNER FINALIZATION / NO RUNTIME**

- Canonical L1 registry: 24 owner-final L1.
- This inventory covers the other 22 L1 and their proposed L2 nodes.
- Batch 01: 70; Batch 02: 77; Batch 03: 77; total: 224.
- Source branches were read with `git show`; they were not merged.

## Source heads

- Batch 01: `origin/agent3/w15-overnight-taxonomy-batch-01@4b500a629e3ca6f388617c49aae16fe32538a378`
- Batch 02: `origin/agent1/w15-overnight-taxonomy-batch-02@bca5d57c359dc4f767972597551aa6616031b667`
- Batch 03: `origin/agent2/w15-overnight-taxonomy-batch-03@f1e766eeacbcbc1f1ed69ee18d040321645a6796`

## Reconciliation

| Batch | L1 count | Proposed L2 count | Expected | Result |
|---|---:|---:|---:|---|
| 01 | 6 | 70 | 70 | PASS |
| 02 | 8 | 77 | 77 | PASS |
| 03 | 8 | 77 | 77 | PASS |
| **Total** | **22** | **224** | **224** | **PASS** |

Normalized exact-name duplicate across proposed L2: **0**.

## Full inventory

| Inventory ID | Batch | Canonical L1 | L2 order | Exact proposed L2 | Source proposal |
|---|---:|---|---:|---|---|
| INV-001 | 01 | Gıda & İçecek | 1 | Taze Meyve & Sebze | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-002 | 01 | Gıda & İçecek | 2 | Et, Tavuk, Balık & Şarküteri | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-003 | 01 | Gıda & İçecek | 3 | Süt Ürünleri & Yumurta | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-004 | 01 | Gıda & İçecek | 4 | Ekmek, Unlu Mamuller & Pastacılık | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-005 | 01 | Gıda & İçecek | 5 | Bakliyat, Tahıl & Makarna | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-006 | 01 | Gıda & İçecek | 6 | Un, Şeker & Pişirme Malzemeleri | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-007 | 01 | Gıda & İçecek | 7 | Yağ & Sirke | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-008 | 01 | Gıda & İçecek | 8 | Kahvaltılık | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-009 | 01 | Gıda & İçecek | 9 | Atıştırmalık, Şekerleme & Kuruyemiş | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-010 | 01 | Gıda & İçecek | 10 | Alkolsüz İçecekler | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-011 | 01 | Gıda & İçecek | 11 | Sos, Baharat & Çeşni | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-012 | 01 | Gıda & İçecek | 12 | Konserve & Kavanoz Ürünleri | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-013 | 01 | Gıda & İçecek | 13 | Hazır & Pratik Gıda | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-014 | 01 | Gıda & İçecek | 14 | Donuk Gıda | `docs/TAXONOMY_FOOD_BEVERAGE_L2_PROPOSAL.md` |
| INV-015 | 01 | Giyim & Moda | 1 | Üst Giyim | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-016 | 01 | Giyim & Moda | 2 | Alt Giyim | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-017 | 01 | Giyim & Moda | 3 | Elbise & Tulum | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-018 | 01 | Giyim & Moda | 4 | Takım & Kombinler | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-019 | 01 | Giyim & Moda | 5 | Dış Giyim | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-020 | 01 | Giyim & Moda | 6 | İç Giyim | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-021 | 01 | Giyim & Moda | 7 | Ev & Uyku Giyimi | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-022 | 01 | Giyim & Moda | 8 | Spor & Performans Giyimi | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-023 | 01 | Giyim & Moda | 9 | Mayo & Plaj Giyimi | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-024 | 01 | Giyim & Moda | 10 | İş Giyimi & Üniforma | `docs/TAXONOMY_CLOTHING_FASHION_L2_PROPOSAL.md` |
| INV-025 | 01 | Ev & Yaşam | 1 | Mobilya | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-026 | 01 | Ev & Yaşam | 2 | Yatak & Uyku Ürünleri | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-027 | 01 | Ev & Yaşam | 3 | Ev Tekstili | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-028 | 01 | Ev & Yaşam | 4 | Perde & Pencere Tekstili | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-029 | 01 | Ev & Yaşam | 5 | Halı, Kilim & Paspas | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-030 | 01 | Ev & Yaşam | 6 | Dekorasyon & Duvar Aksesuarları | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-031 | 01 | Ev & Yaşam | 7 | Aydınlatma | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-032 | 01 | Ev & Yaşam | 8 | Düzenleme & Saklama | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-033 | 01 | Ev & Yaşam | 9 | Banyo Aksesuarları | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-034 | 01 | Ev & Yaşam | 10 | Ev Temizliği & Çamaşır Bakımı | `docs/TAXONOMY_HOME_LIVING_L2_PROPOSAL.md` |
| INV-035 | 01 | Züccaciye & Mutfak | 1 | Tencere, Tava & Pişirme Kapları | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-036 | 01 | Züccaciye & Mutfak | 2 | Fırınlama & Pişirme Gereçleri | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-037 | 01 | Züccaciye & Mutfak | 3 | Mutfak Hazırlık Gereçleri | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-038 | 01 | Züccaciye & Mutfak | 4 | Bıçak & Kesme Gereçleri | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-039 | 01 | Züccaciye & Mutfak | 5 | Sofra & Yemek Takımları | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-040 | 01 | Züccaciye & Mutfak | 6 | Çatal, Kaşık & Servis Gereçleri | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-041 | 01 | Züccaciye & Mutfak | 7 | Bardak, Kupa & İçecek Servisi | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-042 | 01 | Züccaciye & Mutfak | 8 | Çay & Kahve Demleme Gereçleri | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-043 | 01 | Züccaciye & Mutfak | 9 | Saklama & Mutfak Düzenleme | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-044 | 01 | Züccaciye & Mutfak | 10 | Termos, Matara & Yiyecek Taşıma | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-045 | 01 | Züccaciye & Mutfak | 11 | Mutfak Tekstili | `docs/TAXONOMY_KITCHEN_HOUSEWARE_L2_PROPOSAL.md` |
| INV-046 | 01 | Yapı, Hırdavat & Tesisat | 1 | El Aletleri & Atölye Ekipmanları | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-047 | 01 | Yapı, Hırdavat & Tesisat | 2 | Elektrikli & Akülü El Aletleri | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-048 | 01 | Yapı, Hırdavat & Tesisat | 3 | Alet Uçları, Aksesuarları & Sarfları | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-049 | 01 | Yapı, Hırdavat & Tesisat | 4 | Bağlantı Elemanları & Nalburiye | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-050 | 01 | Yapı, Hırdavat & Tesisat | 5 | Ölçüm, Test & İşaretleme | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-051 | 01 | Yapı, Hırdavat & Tesisat | 6 | Boya, Kaplama & Yüzey Hazırlama | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-052 | 01 | Yapı, Hırdavat & Tesisat | 7 | Yapıştırıcı, Dolgu & Yapı Kimyasalları | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-053 | 01 | Yapı, Hırdavat & Tesisat | 8 | Yapı Malzemeleri | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-054 | 01 | Yapı, Hırdavat & Tesisat | 9 | Su Tesisatı & Armatürler | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-055 | 01 | Yapı, Hırdavat & Tesisat | 10 | Elektrik Tesisatı Malzemeleri | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-056 | 01 | Yapı, Hırdavat & Tesisat | 11 | Isıtma, Gaz & Havalandırma Tesisatı | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-057 | 01 | Yapı, Hırdavat & Tesisat | 12 | Kilit, Kapı & Pencere Donanımları | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-058 | 01 | Yapı, Hırdavat & Tesisat | 13 | Kaynak, Lehim & Metal İşleme | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-059 | 01 | Yapı, Hırdavat & Tesisat | 14 | İş Güvenliği & Koruyucu Donanım | `docs/TAXONOMY_HARDWARE_PLUMBING_L2_PROPOSAL.md` |
| INV-060 | 01 | Kozmetik & Kişisel Bakım | 1 | Makyaj | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-061 | 01 | Kozmetik & Kişisel Bakım | 2 | Cilt Bakımı | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-062 | 01 | Kozmetik & Kişisel Bakım | 3 | Güneş Bakımı | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-063 | 01 | Kozmetik & Kişisel Bakım | 4 | Saç Bakımı & Şekillendirme | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-064 | 01 | Kozmetik & Kişisel Bakım | 5 | Parfüm & Deodorant | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-065 | 01 | Kozmetik & Kişisel Bakım | 6 | Banyo & Vücut Bakımı | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-066 | 01 | Kozmetik & Kişisel Bakım | 7 | El, Ayak & Tırnak Bakımı | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-067 | 01 | Kozmetik & Kişisel Bakım | 8 | Ağız & Diş Bakımı | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-068 | 01 | Kozmetik & Kişisel Bakım | 9 | Kişisel Hijyen | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-069 | 01 | Kozmetik & Kişisel Bakım | 10 | Tıraş, Ağda & Epilasyon | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-070 | 01 | Kozmetik & Kişisel Bakım | 11 | Kozmetik & Bakım Aksesuarları | `docs/TAXONOMY_COSMETICS_PERSONAL_CARE_L2_PROPOSAL.md` |
| INV-071 | 02 | Ayakkabı | 1 | Günlük Ayakkabılar | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-072 | 02 | Ayakkabı | 2 | Spor Ayakkabıları | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-073 | 02 | Ayakkabı | 3 | Klasik Ayakkabılar | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-074 | 02 | Ayakkabı | 4 | Bot & Çizmeler | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-075 | 02 | Ayakkabı | 5 | Sandalet & Terlikler | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-076 | 02 | Ayakkabı | 6 | Çocuk & Bebek Ayakkabıları | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-077 | 02 | Ayakkabı | 7 | İş & Güvenlik Ayakkabıları | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-078 | 02 | Ayakkabı | 8 | Ayakkabı Bakım & Aksesuarları | `docs/TAXONOMY_SHOES_L2_PROPOSAL.md` |
| INV-079 | 02 | Çanta & Aksesuar | 1 | El, Omuz & Bel Çantaları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-080 | 02 | Çanta & Aksesuar | 2 | Sırt Çantaları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-081 | 02 | Çanta & Aksesuar | 3 | Evrak, Laptop & Ekipman Çantaları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-082 | 02 | Çanta & Aksesuar | 4 | Valiz & Seyahat Çantaları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-083 | 02 | Çanta & Aksesuar | 5 | Cüzdan, Kartlık & Anahtarlık | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-084 | 02 | Çanta & Aksesuar | 6 | Kemer, Pantolon Askısı & Kravat | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-085 | 02 | Çanta & Aksesuar | 7 | Şapka, Bere & Saç Aksesuarları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-086 | 02 | Çanta & Aksesuar | 8 | Atkı, Şal & Eldiven | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-087 | 02 | Çanta & Aksesuar | 9 | Şemsiyeler | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-088 | 02 | Çanta & Aksesuar | 10 | Seyahat Aksesuarları | `docs/TAXONOMY_BAGS_ACCESSORIES_L2_PROPOSAL.md` |
| INV-089 | 02 | Beyaz Eşya & Ev Aletleri | 1 | Soğutma & Gıda Saklama Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-090 | 02 | Beyaz Eşya & Ev Aletleri | 2 | Çamaşır & Bulaşık Bakım Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-091 | 02 | Beyaz Eşya & Ev Aletleri | 3 | Büyük Pişirme Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-092 | 02 | Beyaz Eşya & Ev Aletleri | 4 | Küçük Mutfak Aletleri | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-093 | 02 | Beyaz Eşya & Ev Aletleri | 5 | Temizlik Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-094 | 02 | Beyaz Eşya & Ev Aletleri | 6 | İklimlendirme & Hava Kalitesi | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-095 | 02 | Beyaz Eşya & Ev Aletleri | 7 | Su Isıtma & Sıcak Su Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-096 | 02 | Beyaz Eşya & Ev Aletleri | 8 | Ütü & Tekstil Bakım Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-097 | 02 | Beyaz Eşya & Ev Aletleri | 9 | Elektrikli Kişisel Bakım Cihazları | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-098 | 02 | Beyaz Eşya & Ev Aletleri | 10 | Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri | `docs/TAXONOMY_HOME_APPLIANCES_L2_PROPOSAL.md` |
| INV-099 | 02 | Anne & Bebek | 1 | Bebek Beslenme | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-100 | 02 | Anne & Bebek | 2 | Emzirme & Anne Sütü Ürünleri | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-101 | 02 | Anne & Bebek | 3 | Bebek Bezi & Alt Bakım | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-102 | 02 | Anne & Bebek | 4 | Bebek Banyo, Bakım & Hijyen | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-103 | 02 | Anne & Bebek | 5 | Bebek Arabaları & Taşıma | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-104 | 02 | Anne & Bebek | 6 | Oto Koltukları & Seyahat Güvenliği | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-105 | 02 | Anne & Bebek | 7 | Bebek Odası & Uyku | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-106 | 02 | Anne & Bebek | 8 | Bebek Güvenlik & Ev İçi Koruma | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-107 | 02 | Anne & Bebek | 9 | Hamilelik & Lohusalık Ürünleri | `docs/TAXONOMY_MOTHER_BABY_L2_PROPOSAL.md` |
| INV-108 | 02 | Oyuncak & Hobi | 1 | Bebek & Okul Öncesi Oyuncaklar | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-109 | 02 | Oyuncak & Hobi | 2 | Eğitici, Bilim & Keşif Oyuncakları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-110 | 02 | Oyuncak & Hobi | 3 | Figür, Bebek & Rol Oyunları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-111 | 02 | Oyuncak & Hobi | 4 | Yapı & İnşa Oyuncakları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-112 | 02 | Oyuncak & Hobi | 5 | Oyuncak Araçlar & Uzaktan Kumandalı Oyuncaklar | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-113 | 02 | Oyuncak & Hobi | 6 | Kutu Oyunları & Oyun Takımları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-114 | 02 | Oyuncak & Hobi | 7 | Puzzle & Zeka Oyunları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-115 | 02 | Oyuncak & Hobi | 8 | Model, Maket & Minyatür | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-116 | 02 | Oyuncak & Hobi | 9 | Koleksiyon Ürünleri | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-117 | 02 | Oyuncak & Hobi | 10 | Sanat, El İşi & Hobi Kitleri | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-118 | 02 | Oyuncak & Hobi | 11 | Açık Hava & Aktivite Oyuncakları | `docs/TAXONOMY_TOYS_HOBBY_L2_PROPOSAL.md` |
| INV-119 | 02 | Müzik & Enstrüman | 1 | Gitar & Bas | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-120 | 02 | Müzik & Enstrüman | 2 | Piyano, Org & Klavyeli Çalgılar | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-121 | 02 | Müzik & Enstrüman | 3 | Telli & Yaylı Çalgılar | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-122 | 02 | Müzik & Enstrüman | 4 | Nefesli Çalgılar | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-123 | 02 | Müzik & Enstrüman | 5 | Vurmalı Çalgılar | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-124 | 02 | Müzik & Enstrüman | 6 | Geleneksel Türk Müziği Enstrümanları | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-125 | 02 | Müzik & Enstrüman | 7 | Elektronik Müzik & DJ Ekipmanları | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-126 | 02 | Müzik & Enstrüman | 8 | Stüdyo, Kayıt & Canlı Ses Ekipmanları | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-127 | 02 | Müzik & Enstrüman | 9 | Enstrüman Amfi & Efektleri | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-128 | 02 | Müzik & Enstrüman | 10 | Enstrüman Aksesuar, Bakım & Sarf Malzemeleri | `docs/TAXONOMY_MUSIC_INSTRUMENTS_L2_PROPOSAL.md` |
| INV-129 | 02 | Spor & Outdoor | 1 | Fitness & Kondisyon | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-130 | 02 | Spor & Outdoor | 2 | Takım Sporları | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-131 | 02 | Spor & Outdoor | 3 | Raket Sporları | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-132 | 02 | Spor & Outdoor | 4 | Bireysel Sporlar & Jimnastik | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-133 | 02 | Spor & Outdoor | 5 | Dövüş Sporları | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-134 | 02 | Spor & Outdoor | 6 | Outdoor, Kamp & Trekking | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-135 | 02 | Spor & Outdoor | 7 | Bisiklet | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-136 | 02 | Spor & Outdoor | 8 | Su Sporları | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-137 | 02 | Spor & Outdoor | 9 | Kış Sporları | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-138 | 02 | Spor & Outdoor | 10 | Balıkçılık & Avcılık | `docs/TAXONOMY_SPORTS_OUTDOOR_L2_PROPOSAL.md` |
| INV-139 | 02 | Hediyelik & Parti | 1 | Hatıra & Hediyelik Objeler | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-140 | 02 | Hediyelik & Parti | 2 | Hediye Paketleme & Sunum | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-141 | 02 | Hediyelik & Parti | 3 | Tebrik Kartları, Davetiyeler & Kutlama Yazıları | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-142 | 02 | Hediyelik & Parti | 4 | Balon & Balon Aksesuarları | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-143 | 02 | Hediyelik & Parti | 5 | Parti Süsleri & Mekân Dekorasyonu | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-144 | 02 | Hediyelik & Parti | 6 | Parti Sofrası & Servis Ürünleri | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-145 | 02 | Hediyelik & Parti | 7 | Kostüm, Maske & Parti Aksesuarları | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-146 | 02 | Hediyelik & Parti | 8 | Pasta Süsleme & Kutlama Aksesuarları | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-147 | 02 | Hediyelik & Parti | 9 | Parti Eğlence & Fotoğraf Aksesuarları | `docs/TAXONOMY_GIFTS_PARTY_L2_PROPOSAL.md` |
| INV-148 | 03 | Otomotiv & Motosiklet | 1 | Otomobil Yedek Parçaları | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-149 | 03 | Otomotiv & Motosiklet | 2 | Motosiklet Yedek Parçaları | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-150 | 03 | Otomotiv & Motosiklet | 3 | Araç İçi Aksesuarları | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-151 | 03 | Otomotiv & Motosiklet | 4 | Araç Dış Aksesuarları | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-152 | 03 | Otomotiv & Motosiklet | 5 | Lastik, Jant & Tekerlek Ürünleri | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-153 | 03 | Otomotiv & Motosiklet | 6 | Akü & Araç Elektriği | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-154 | 03 | Otomotiv & Motosiklet | 7 | Araç Elektroniği | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-155 | 03 | Otomotiv & Motosiklet | 8 | Araç Bakım & Temizlik | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-156 | 03 | Otomotiv & Motosiklet | 9 | Motor Yağı, Sıvı & Katkılar | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-157 | 03 | Otomotiv & Motosiklet | 10 | Motosiklet Kask & Koruma Ekipmanları | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-158 | 03 | Otomotiv & Motosiklet | 11 | Araç Güvenlik & Acil Durum Ürünleri | `docs/TAXONOMY_AUTOMOTIVE_MOTORCYCLE_L2_PROPOSAL.md` |
| INV-159 | 03 | Kitap | 1 | Edebiyat & Kurgu | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-160 | 03 | Kitap | 2 | Çocuk & Gençlik Kitapları | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-161 | 03 | Kitap | 3 | Eğitim & Ders Kitapları | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-162 | 03 | Kitap | 4 | Sınav Hazırlık Kitapları | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-163 | 03 | Kitap | 5 | Akademik & Mesleki Kitaplar | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-164 | 03 | Kitap | 6 | Araştırma, İnceleme & Düşünce | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-165 | 03 | Kitap | 7 | Kişisel Gelişim & Yaşam | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-166 | 03 | Kitap | 8 | Sanat, Kültür & Hobi Kitapları | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-167 | 03 | Kitap | 9 | Çizgi Roman & Manga | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-168 | 03 | Kitap | 10 | Dil Öğrenimi & Sözlükler | `docs/TAXONOMY_BOOKS_L2_PROPOSAL.md` |
| INV-169 | 03 | Çiçek & Bahçe | 1 | Canlı Saksı Bitkileri | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-170 | 03 | Çiçek & Bahçe | 2 | Kesme Çiçek & Fiziksel Aranjmanlar | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-171 | 03 | Çiçek & Bahçe | 3 | Tohum, Fide & Bitki Soğanları | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-172 | 03 | Çiçek & Bahçe | 4 | Yapay Çiçek & Yapay Bitkiler | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-173 | 03 | Çiçek & Bahçe | 5 | Saksı, Saksılık & Bitki Kapları | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-174 | 03 | Çiçek & Bahçe | 6 | Toprak, Gübre & Bitki Besleme | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-175 | 03 | Çiçek & Bahçe | 7 | Sulama Ürünleri | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-176 | 03 | Çiçek & Bahçe | 8 | Bahçe El Aletleri | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-177 | 03 | Çiçek & Bahçe | 9 | Bitki Bakım & Yetiştirme Ürünleri | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-178 | 03 | Çiçek & Bahçe | 10 | Sera & Yetiştirme Ekipmanları | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-179 | 03 | Çiçek & Bahçe | 11 | Bahçe Dekorasyonu & Peyzaj Aksesuarları | `docs/TAXONOMY_FLOWERS_GARDEN_L2_PROPOSAL.md` |
| INV-180 | 03 | Sağlık & Medikal | 1 | İlk Yardım & Yara Bakımı | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-181 | 03 | Sağlık & Medikal | 2 | Evde Sağlık Ölçüm Cihazları | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-182 | 03 | Sağlık & Medikal | 3 | Ortopedik Destekler & Kompresyon | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-183 | 03 | Sağlık & Medikal | 4 | Hareket & Mobilite Yardımcıları | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-184 | 03 | Sağlık & Medikal | 5 | Rehabilitasyon & Fizik Tedavi Ürünleri | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-185 | 03 | Sağlık & Medikal | 6 | Solunum & Evde Bakım Cihazları | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-186 | 03 | Sağlık & Medikal | 7 | Medikal Sarf & Hasta Bakım Ürünleri | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-187 | 03 | Sağlık & Medikal | 8 | Kişisel Koruyucu Medikal Ürünler | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-188 | 03 | Sağlık & Medikal | 9 | Günlük Yaşam & Erişilebilirlik Yardımcıları | `docs/TAXONOMY_HEALTH_MEDICAL_L2_PROPOSAL.md` |
| INV-189 | 03 | Gözlük & Optik | 1 | Optik Gözlük Çerçeveleri | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-190 | 03 | Gözlük & Optik | 2 | Güneş Gözlükleri | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-191 | 03 | Gözlük & Optik | 3 | Hazır Okuma Gözlükleri | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-192 | 03 | Gözlük & Optik | 4 | Gözlük Camları | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-193 | 03 | Gözlük & Optik | 5 | Kontakt Lensler | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-194 | 03 | Gözlük & Optik | 6 | Kontakt Lens Bakım Ürünleri | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-195 | 03 | Gözlük & Optik | 7 | Gözlük & Optik Aksesuarları | `docs/TAXONOMY_OPTICS_L2_PROPOSAL.md` |
| INV-196 | 03 | Evcil Hayvan Ürünleri | 1 | Kedi Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-197 | 03 | Evcil Hayvan Ürünleri | 2 | Köpek Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-198 | 03 | Evcil Hayvan Ürünleri | 3 | Akvaryum & Balık Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-199 | 03 | Evcil Hayvan Ürünleri | 4 | Kuş Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-200 | 03 | Evcil Hayvan Ürünleri | 5 | Küçük Hayvan Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-201 | 03 | Evcil Hayvan Ürünleri | 6 | Sürüngen & Egzotik Pet Ürünleri | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-202 | 03 | Evcil Hayvan Ürünleri | 7 | Ortak Pet Bakım & Aksesuarları | `docs/TAXONOMY_PET_PRODUCTS_L2_PROPOSAL.md` |
| INV-203 | 03 | Kırtasiye & Ofis | 1 | Kalem & Yazım Gereçleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-204 | 03 | Kırtasiye & Ofis | 2 | Defter, Ajanda & Planlayıcılar | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-205 | 03 | Kırtasiye & Ofis | 3 | Kağıt, Etiket & Baskı Sarfı | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-206 | 03 | Kırtasiye & Ofis | 4 | Dosyalama & Arşivleme | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-207 | 03 | Kırtasiye & Ofis | 5 | Masaüstü Ofis Gereçleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-208 | 03 | Kırtasiye & Ofis | 6 | Yapıştırıcı, Bant & Kesim Gereçleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-209 | 03 | Kırtasiye & Ofis | 7 | Okul Kırtasiyesi & Eğitim Gereçleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-210 | 03 | Kırtasiye & Ofis | 8 | Sanat & Çizim Malzemeleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-211 | 03 | Kırtasiye & Ofis | 9 | Sunum, Pano & Yazı Tahtası Ürünleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-212 | 03 | Kırtasiye & Ofis | 10 | Ofis Makineleri & Ciltleme Ekipmanları | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-213 | 03 | Kırtasiye & Ofis | 11 | Paketleme & Postalama Ürünleri | `docs/TAXONOMY_STATIONERY_OFFICE_L2_PROPOSAL.md` |
| INV-214 | 03 | Saat & Takı | 1 | Klasik Kol Saatleri | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-215 | 03 | Saat & Takı | 2 | Cep Saatleri | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-216 | 03 | Saat & Takı | 3 | Saat Kayışları & Aksesuarları | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-217 | 03 | Saat & Takı | 4 | Kolyeler & Takı Uçları | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-218 | 03 | Saat & Takı | 5 | Küpeler | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-219 | 03 | Saat & Takı | 6 | Yüzükler | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-220 | 03 | Saat & Takı | 7 | Bileklik, Bilezik & Halhallar | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-221 | 03 | Saat & Takı | 8 | Broş & Giyim Takıları | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-222 | 03 | Saat & Takı | 9 | Vücut Takıları | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-223 | 03 | Saat & Takı | 10 | Takı Aksesuarları & Saklama | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |
| INV-224 | 03 | Saat & Takı | 11 | Takı Yapım Malzemeleri | `docs/TAXONOMY_WATCHES_JEWELRY_L2_PROPOSAL.md` |

## Validation

- Source batch count: 3/3 PASS.
- Proposed L1 coverage: 22/22 PASS.
- Proposed L2 coverage: 224/224 PASS.
- Missing source proposal: 0.
- Source proposal mutation: NO.
- Owner finalization: NO.
- Runtime implementation: NO.

`PRODUCT_PLACEMENT_INVENTORY: PASS`

`PROPOSED_L2_INVENTORIED: 224/224`
