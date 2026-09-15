# W52G — Product Owner ürün eşleme incelemesi

**İnceleme paketi hazır; gelecek Production adapter girdisi: `BLOCKED`.**
20 ürünün 18'i için birer mevcut terminal önerildi. Bot ve terlik için kanıt yetersiz;
iki satırın hedef UUID/yol/seviye/terminal alanları bilinçli olarak boş bırakıldı.
Hiçbir eşleme uygulanmadı; Product Owner onayı henüz alınmadı.

## Beklenen ürün kararları

1. **A grubundaki 16 kategori eşlemesini toplu inceleyip onayla.** Bu, yayınlama veya mevcut inceleme koşullarını kaldırma onayı değildir.
2. **B grubundaki 2 üründe “günlük spor ayakkabısı → Günlük Sneaker” yorumunu teyit et.** Günlük kullanım adında açık; model/açıklama ek doğrulama sağlamıyor. Ret halinde alternatif yaprak seçilmez, satır yeniden incelenir.
3. **C grubundaki botun kullanım türünü ve terliğin kullanım yeri/formunu belirt.** Bilgi gelene kadar hedef seçilmeyecek.

[Makine tarafından okunabilir 20 satırlık CSV](data/production_20_product_canonical_mapping.csv) ·
[Doğrulama ve güvenli kanıt kaydı](data/production_20_product_canonical_mapping_validation.json)

## A. HIGH CONFIDENCE — toplu onaya uygun 16 ürün

| Ürün | Eski kategori | Önerilen tam kanonik yol | Kısa gerekçe |
|---|---|---|---|
| Çocuk Spor Ayakkabı | Ayakkabı | Ayakkabı > Çocuk & Bebek Ayakkabıları > Çocuk Spor Ayakkabıları | Çocuk ve spor ayakkabısı türü adında açıkça belirtiliyor. Ayrı koşul: `PROFESSIONAL_REVIEW`. |
| 10.000 mAh Powerbank | Elektronik | Elektronik > Güç, Şarj & Bağlantı | Powerbank açık bir taşınabilir güç ürünü. W36 powerbank yönlendirmesi aynı terminali doğruluyor. |
| Bluetooth Kulaklık | Elektronik | Elektronik > Ses & Kulaklık | Kulaklık türü açık; mevcut ağaçta kulak içi/kulak üstü alt yaprağı yok. W36 kulaklık yönlendirmesi aynı terminali doğruluyor. |
| Kablosuz Mouse | Elektronik | Bilgisayar & Tablet > Klavye, Mouse & Çevre Birimleri | Mouse bir bilgisayar çevre birimi; kablosuz olması oyun kullanımı kanıtı değil. W36 mouse yönlendirmesi aynı terminali doğruluyor. |
| USB-C Şarj Adaptörü 20W | Elektronik | Elektronik > Güç, Şarj & Bağlantı | Genel USB-C şarj adaptörü; belirli bir telefon modeline özgü uyumluluk varsayılmadı. W36 şarj cihazı yönlendirmesi aynı terminali doğruluyor. |
| USB-C Şarj Kablosu 1 m | Elektronik | Elektronik > Güç, Şarj & Bağlantı | Şarj kablosu açık; konektör ve uzunluk model-özel telefon aksesuarı kanıtı değil. W36 şarj kablosu yönlendirmesi aynı terminali doğruluyor. |
| Ayçiçek Yağı 1 L | Gıda | Gıda & İçecek > Yağ & Sirke > Yemeklik Yağlar > Bitkisel Sıvı Yağlar | Ayçiçek yağı bitkisel sıvı yağdır; Yemeklik Yağlar L3 kapsayıcısında durulmadı. |
| Makarna 500 g | Gıda | Gıda & İçecek > Bakliyat, Tahıl & Makarna > Makarna & Erişte | Makarna açıkça belirtiliyor; şekil veya içerik varsayılmadı. |
| Pirinç 1 kg | Gıda | Gıda & İçecek > Bakliyat, Tahıl & Makarna > Pirinç & Bulgur | Pirinç doğrudan bu terminal kapsamına giriyor; çeşit varsayılmadı. |
| Toz Şeker 1 kg | Gıda | Gıda & İçecek > Un, Şeker & Pişirme Malzemeleri > Şeker & Tatlandırıcılar | Şeker türü açık; toz şeker için ayrı terminal bulunmuyor. |
| UHT Süt 1 L | Gıda | Gıda & İçecek > Süt Ürünleri & Yumurta > Süt | Süt açıkça belirtiliyor; yağ oranı veya hayvansal kaynak varsayılmadı. Ayrı koşul: `POLICY_BLOCKED`. |
| A4 Fotokopi Kağıdı 500 Yaprak | Kırtasiye | Kırtasiye & Ofis > Kağıt, Etiket & Baskı Sarfı > Fotokopi & Yazıcı Kağıtları | Fotokopi kağıdı açıkça belirtiliyor; ebat ve paket miktarı ayrı kategori gerektirmiyor. |
| A4 Kareli Defter | Kırtasiye | Kırtasiye & Ofis > Defter, Ajanda & Planlayıcılar > Defterler | Defter türü açık; mevcut kanonik ağaçta kareli/A4 için daha derin yaprak yok. |
| A5 Spiralli Defter | Kırtasiye | Kırtasiye & Ofis > Defter, Ajanda & Planlayıcılar > Defterler | Defter türü açık; mevcut kanonik ağaçta spiral/A5 için daha derin yaprak yok. |
| Kalem Kutusu | Kırtasiye | Kırtasiye & Ofis > Okul Kırtasiyesi & Eğitim Gereçleri > Kalem Kutuları | Ad kanonik kalem kutusu türüyle doğrudan örtüşüyor. Ayrı koşul: `POLICY_BLOCKED`. |
| Mavi Tükenmez Kalem 5'li | Kırtasiye | Kırtasiye & Ofis > Kalem & Yazım Gereçleri > Tükenmez & Roller Kalemler | Tükenmez kalem türü açık; renk ve paket miktarı alt tür uydurmayı gerektirmiyor. Ayrı koşul: `POLICY_BLOCKED`. |

Beş elektronik ürünün hedefi L2'dir. Bunlar **mevcut ağacın gerçek terminal
yapraklarıdır**; altında onaylı L3/L4 düğüm yoktur. [W36 L2 kararı](TAXONOMY_W36_ANCHOR_L2_QUALIFICATION.md)
yapısal belirsizliği kapatmıştır. Kablosuz Mouse'un kanonik L1 ailesi
**Bilgisayar & Tablet** olur. USB-C ürünlerine telefon modeli uyumluluğu eklenmedi.

## B. NEEDS PRODUCT OWNER REVIEW — 2 ürün

Bu iki öneri `MEDIUM_CONFIDENCE` düzeyindedir: adın günlük kullanım kanıtı korunur,
“sneaker” terim normalizasyonu açıkça owner incelemesine sunulur.

| Ürün | Eski kategori | Önerilen tam kanonik yol | Kısa gerekçe |
|---|---|---|---|
| Erkek Günlük Spor Ayakkabı | Ayakkabı | Ayakkabı > Günlük Ayakkabılar > Günlük Sneaker | Ad günlük kullanımı açıkça belirtiyor; günlük spor ayakkabısı ifadesi günlük sneaker olarak yorumlandı. Erkek ayrı kanonik çocuk düğüm değil. |
| Kadın Günlük Spor Ayakkabı | Ayakkabı | Ayakkabı > Günlük Ayakkabılar > Günlük Sneaker | Ad günlük kullanımı açıkça belirtiyor; günlük spor ayakkabısı ifadesi günlük sneaker olarak yorumlandı. Kadın ayrı kanonik çocuk düğüm değil. |

`OWNER_REVIEW_REQUIRED` güven sınıfında ayrıca ürün yoktur (0). Bu, onay gerekmediği
anlamına gelmez: B/C satırlarında `OWNER_DECISION_REQUIRED=YES`; A satırlarında
`NO` yalnız **eşlemeye özel ek soru olmadığı** anlamındadır. Bütün öneriler owner
onayı bekler. Yayınlama koşulları bu sütunun dışında ayrıca aşağıda gösterilmiştir.

## C. UNRESOLVED / eksik kanıt — 2 ürün

| Ürün | Eski kategori | Önerilen tam kanonik yol | Kısa gerekçe |
|---|---|---|---|
| Günlük Terlik | Ayakkabı | ATANMADI | Günlük ifadesi ev/plaj veya sabo/mule ayrımını açıklamıyor; açıklama adı tekrar ediyor, model/kullanım/tür alanları boş. |
| Su Geçirmez Bot | Ayakkabı | ATANMADI | Su geçirmezlik tek başına botun kullanım türünü belirtmiyor; açıklama adı tekrar ediyor, model/kullanım/tür alanları boş. |

- **Su Geçirmez Bot:** günlük, yağmur, kar/kış veya outdoor/trekking kullanımını ayırt eden ürün tipi/kullanım bilgisi gerekli. Örnek mevcut yollar: `Ayakkabı > Bot & Çizmeler > Günlük Botlar`, `Ayakkabı > Bot & Çizmeler > Yağmur Botları`, `Ayakkabı > Bot & Çizmeler > Kar & Kış Botları`. Bunlar seçenek örnekleridir; hiçbirine otomatik eşleme yapılmadı.
- **Günlük Terlik:** kullanım yeri ve form gerekli. Mevcut seçenek örnekleri: `Ayakkabı > Sandalet & Terlikler > Ev Terlikleri`, `Ayakkabı > Sandalet & Terlikler > Plaj & Havuz Terlikleri`, `Ayakkabı > Sandalet & Terlikler > Sabo & Mule`. “Günlük” ifadesinden “ev” sonucu çıkarılmadı.

## Eşleme onayından ayrı mevcut koşullar

[W36 qualification kaydı](TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv) şu dört
ürünün hedefini kullanım/yayınlama açısından kapalı tutuyor:

| Ürün | Mevcut kaynak koşulu | Etki |
|---|---|---|
| UHT Süt 1 L | `POLICY_BLOCKED`; politika ve profesyonel inceleme zinciri | Süt yaprağı ve üst kategorisindeki koşullar korunur. |
| Mavi Tükenmez Kalem 5'li | `POLICY_BLOCKED`; üst kategoride politika/profesyonel inceleme | Kalem & Yazım Gereçleri koşulları korunur. |
| Kalem Kutusu | `POLICY_BLOCKED`; üst kategoride politika/profesyonel inceleme | Okul Kırtasiyesi & Eğitim Gereçleri koşulları korunur. |
| Çocuk Spor Ayakkabı | `PROFESSIONAL_REVIEW`; bekleyen inceleme zinciri | Çocuk ayakkabısı inceleme koşulları korunur. |

Bunlar mevcut kaynak verisinin koşullarıdır; yeni bir hukuki değerlendirme veya
yeni yasak eklenmedi. Yüksek eşleme güveni, kullanım/yayınlama izni değildir.
W36 import paketindeki bütün hedefler halen yerel `staged`, `is_active=FALSE`,
`is_assignable=FALSE` kayıtlarıdır. Production'a aktarılmadılar.

## Sayımlar ve kontroller

| Güven sınıfı | Sayı |
|---|---:|
| HIGH_CONFIDENCE | 16 |
| MEDIUM_CONFIDENCE | 2 |
| OWNER_REVIEW_REQUIRED | 0 |
| UNRESOLVED | 2 |

| Eski kategori | Ürün | Kanonik hedef ailesi | Önerilmiş ürün |
|---|---:|---|---:|
| Kırtasiye | 5 | Kırtasiye & Ofis | 5 |
| Elektronik | 5 | Elektronik | 4 |
| Gıda | 5 | Gıda & İçecek | 5 |
| Ayakkabı | 5 | Ayakkabı | 3 |
| — | — | Bilgisayar & Tablet | 1 |
| — | — | Hedefi açık kalan | 2 |
| **Toplam** | **20** | **Toplam** | **20** |

- Production okuma sonucu / CSV: **20/20**; her ürün bir kez; eksik **0**, tekrar **0**, mevcut NULL kategori **0**.
- Önerilmiş hedefler: **18/18** mevcut UUID, tam yol ve terminal doğrulaması **PASS**; açık **2** satır başarı sayılmadı.
- 14 farklı terminal; seviye dağılımı **L2: 5, L3: 12, L4: 1** ürün.
- Kanonik kaynak: **1563** düğüm; **24 / 244 / 1096 / 199** seviye dağılımı; **1245** terminal. Ebeveyn zinciri ve gerçek çocuk yokluğu çapraz doğrulandı.
- Mapping validator, UUID/yol, CSV tutarlılığı, secret/PII taraması ve `git diff --check`: **PASS**. Rastgele split/ilk çocuk seçimi: **0** (ürün bazlı gerekçe incelemesi).
- Flutter/analyzer/client build: **NOT_REQUIRED — DOCS_ONLY**. Runtime, migration ve taxonomy kaynaklarında değişiklik yok.

## Kaynak ve erişim sınırı

- Taban: `79528e17e5f8ca2a6f7947acf7a421e34254cb15`; başlangıç fetch sonucunda `origin/main` bu HEAD ile aynıydı.
- Branch: `astra-release/w52g-production-product-canonical-mapping`.
- Production: `mefhfvrgkwciubeajjeb`; 2026-09-15T22:43:24.9770101Z ve 2026-09-15T22:46:13.6478275Z UTC anlık okumaları. Her iki ürün okuması `GET`, sonuç `0-19/20`.
- Yalnız kamusal katalog okuyucusuna görünür 20 ürün incelendi; bu sayı verilen 20 ürünlük kapsamla örtüşüyor. RLS dışındaki/gizli kayıtlar için yönetici düzeyinde bir sayım iddiası yok.
- Marka ve model alanları boş. Açıklamalar yalnız “EsnaftaVar demonstrasyon kataloğu için sentetik [ürün adı].” biçiminde adı tekrar ediyor. Okunan 18 model/sınıflandırma alanının tamamı boş; ek ürün özelliği uydurulmadı.
- Satıcı, müşteri, Auth ve Storage verisi okunmadı; secret/PII çıktı veya pakete alınmadı. Production yazısı ve Development erişimi **yok**.
- Kanonik UUID'ler mevcut [W36 UUID allocation](TAXONOMY_W36_DEVELOPMENT_UUID_ALLOCATION.csv), [W36 import](TAXONOMY_W36_CATEGORY_IMPORT.csv) ve [W34 manifest](TAXONOMY_W34_CANONICAL_RUNTIME_MANIFEST.csv) yerel kaynaklarından alınmıştır. Dosya adındaki “Development” bir uzak erişim değildir. Bunlar gerçek, önceden ayrılmış kanonik kaynak UUID'leridir; Production'da mevcut kategori UUID'si oldukları iddia edilmez.

## Gelecek adapter girdisi

**`BLOCKED`** — iki ürünün hedefi henüz belirlenemiyor. Eksik kanıt tamamlanıp
terminal eşlemeleri doğrulanmalı ve owner eşleme onayı alınmalı. Dört mevcut
qualification koşulu gelecekteki kullanım/yayınlama tasarımında ayrıca korunmalı
veya yetkili ayrı kararla çözülmeli; bu paket koşulları atlayan bir adapter girdisi değildir.
Production UUID kullanımı, taxonomy deployment ve aktivasyon ayrıca yetkilendirilmelidir.
Bu dalgada migration üretilmedi/uygulanmadı, main birleştirmesi yapılmadı.

```text
PRODUCTS_TOTAL: 20
HIGH_CONFIDENCE: 16
MEDIUM_CONFIDENCE: 2
OWNER_REVIEW_REQUIRED: 0
UNRESOLVED: 2
MAPPING_ROWS: 20/20
TERMINAL_LEAF_TARGETS_VALID: PASS
CANONICAL_UUID_VALIDATION: PASS
ARBITRARY_SPLIT_MAPPING: 0
OWNER_REVIEW_PACK_READY: YES
PRODUCTION_WRITE_PERFORMED: NO
DEVELOPMENT_ACCESSED: NO
READY_FOR_PRODUCT_OWNER_MAPPING_APPROVAL: YES
READY_FOR_PRODUCTION_ADAPTER_MIGRATION_DESIGN: NO
```
