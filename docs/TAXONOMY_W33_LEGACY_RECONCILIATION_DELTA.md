# Wave 33 — Legacy Reconciliation Delta

**Durum:** `DESIGN SIMULATION — NO RUNTIME`

**Base:** `origin/main@d54239c6de8b4637bd093ea1e849d19093bdce7a`

**Önceki reconciliation:**
`14ecb5a4aeb16946e7454cc20dbdf2c5f7b2711e`

**Wave 32 aday kaynakları:** Batch 01
`709695961e900db91861a4307f76d24c73267367`, Batch 02
`28c40a3ac026c8712c9de0964de5fde42ba829dc`, Batch 03
`3dd6df685c7e6a5ed672188e010992063ea9d720`.

Bu belge eski Wave 15 simülasyonu ile
[`TAXONOMY_W33_LEGACY_RECONCILIATION_SIMULATION.csv`](TAXONOMY_W33_LEGACY_RECONCILIATION_SIMULATION.csv)
arasındaki farkı açıklar. Kaynak branch'ler merge edilmedi; içerikleri exact commit
üzerinden salt okunur değerlendirildi.

## 1. Kaynak yeniden doğrulaması

Authoritative legacy JSON:
`docs/data/esnaftavar_category_taxonomy_v1_final.json`

| Kontrol | Sonuç |
|---|---:|
| Git blob | `919d6612393aeb696112fbddb210d477a7001227` |
| Byte | `630674` |
| SHA-256 | `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08` |
| Toplam node | **651** |
| L1 / L2 / L3 / L4 | **23 / 91 / 505 / 32** |
| Unique slug | **651** |
| Active / inactive_review | **650 / 1** |
| Leaf / assignable | **525 / 524** |

Hash ve sayımlar historical audit ile aynıdır; source-change blocker yoktur.

## 2. Action delta

| Action | Wave 15 | Wave 33 | Delta |
|---|---:|---:|---:|
| KEEP | 20 | 62 | +42 |
| RENAME | 17 | 223 | +206 |
| MOVE | 60 | 73 | +13 |
| RENAME_AND_MOVE | 9 | 44 | +35 |
| MERGE | 0 | 7 | +7 |
| SPLIT | 83 | 210 | +127 |
| RETIRE | 1 | 1 | 0 |
| ALIAS_ONLY | 0 | 0 | 0 |
| OUT_OF_PRODUCT_TAXONOMY | 0 | 7 | +7 |
| UNRESOLVED | 461 | 24 | **-437** |
| **Toplam** | **651** | **651** | **0** |

`UNRESOLVED` net delta `-437` iken **438** önceki unresolved kayıt aday
hedefe bağlandı. Farkın nedeni daha önce tek hedefi varmış gibi `RENAME` işaretlenen
`besin-destegi-koruyucu-saglik-urunu` düğümünün bu simülasyonda dürüstçe
`UNRESOLVED` yapılmasıdır: düğüm hem aday PPE alanını hem policy-excluded supplement
alanlarını kapsar.

## 3. Target-state delta

| Target state | Wave 15 | Wave 33 anlamı |
|---|---:|---|
| CANONICAL_FINAL | 106 | 23 owner-final L1 bridge ile saf Elektronik/Bilgisayar owner-final successor'ları |
| CANDIDATE_NOT_OWNER_FINAL | 535 | Wave 32 target veya kontrollü manual-review suggestion |
| MIXED_CANONICAL_FINAL_AND_CANDIDATE | 2 | Phone-primary final + vehicle-fitment Wave 32 candidate edge |
| OUT_OF_SCOPE | 7 | Aday ürün ağacı dışında; owner/legal policy kararı gerekir |
| NO_TARGET_YET | 1 | Inactive `hediyelik-obje` tombstone |

Saf final 106 satırın 23'ü mevcut owner-final L1 bridge, 83'ü lower
Elektronik/Bilgisayar successor'ıdır. İki telefon-tutucu split satırı final phone
target ile candidate Automotive edge'i birlikte taşıdığı için dürüstçe `MIXED`
durumdadır. Wave 32 satırları bu çalışma ile **FINAL yapılmamıştır**. Path eşleşmesi, owner
approval veya runtime assignment yetkisi değildir.

## 4. Artık çözülebilen eşleşmeler

- **438** önceki `UNRESOLVED` satır, Wave 32 ağacında bir veya daha çok controlled
  candidate successor buldu.
- **127** yeni split tanımlandı; mevcut **83** split korundu, kaldırılan split
  yoktur. Toplam 210 split, 591 successor edge üretir; en geniş split 10 target'tır.
- Birleşik legacy adların tek hedefe yanlış bağlanmaması için gıda, giyim, ev,
  züccaciye, yapı, kozmetik, anne-bebek, oyuncak, spor, pet, optik, sağlık,
  kırtasiye ve otomotivde explicit one-to-many successor tasarlandı.
- Fitment electronics generic Elektronik'e taşınmadı; araç ampulü ve motor parçaları
  Otomotiv'de tutuldu. Vehicle-only şarj/dönüştürücü ise aday boşluğu olarak kaldı.
- Species pet identity'nin category/facet sınırı korundu; veterinary health ve
  supplement iddiaları normal pet accessory'ye düşürülmedi.
- Kontakt lens bakım, prescription/custom optics ve regulated medical alanlarında
  candidate policy flag'leri successor kaydına taşındı.

## 5. Target değişiklikleri

**21** kayıt önceki suggestion/path'ten farklı, daha dürüst bir suggestion veya
boş target aldı. Bunların tamamı halen `UNRESOLVED` kalmıştır; değişiklik owner-final
bir seçim değildir. Öne çıkanlar:

- `ampul-dekoratif-isik`: dekoratif obje yerine Standart Ampuller yalnız partial
  suggestion; dekoratif ışık boşluğu açık.
- `duvar-masa-saati`: Duvar Saati partial suggestion; masa saati boşluğu açık.
- `buz-kalibi-sogutucu-canta`: soğutucu çanta partial suggestion; buz kalıbı yok.
- `arac-sarj-donusturucu`: generic Elektronik fallback reddedildi.
- `motosiklet-lastigi-bakim-urunu`: lastik ile kimyasal bakım tek successor yapılmadı.
- `not-kagidi-yapiskanli-not`: Bloknot yalnız partial suggestion; yapışkanlı not yok.
- `ilac-kutusu-gunluk-takip-gereci`: eksik candidate açık bırakıldı.

**1** daha önce resolved görünen action yeniden açıldı:
`besin-destegi-koruyucu-saglik-urunu` artık `UNRESOLVED`.

## 6. Policy exclusion delta

Yeni `OUT_OF_PRODUCT_TAXONOMY` kayıtları:

1. `pet-saglik-destek-urunu`
2. `antiseptik-dezenfeksiyon-urunu`
3. `vitamin-mineral-destegi`
4. `protein-sporcu-destegi`
5. `bitkisel-fonksiyonel-destek`
6. `prezervatif-bariyer-urunu`
7. `uyku-rahatlama-gereci`

Bu sınıflandırma ürünlerin hukuken yasak olduğunu iddia etmez. Yalnız Wave 32
candidate tree içinde güvenli bir normal-product successor bulunmadığını ve owner /
legal / domain review olmadan aktive edilmemeleri gerektiğini belirtir.

## 7. Alias değişikliği

Önceki simülasyonda 93 alias sinyali vardı. Wave 33'te 589 satır alias gerektirir;
**496** satır `NO` → `YES` oldu. Bunun temel nedeni artık görünür olan rename, move,
merge ve split successor'larının historical locator/search continuity gerektirmesidir.
Alias, primary identity değildir; stable target'a versioned historical lookup sağlar.

## 8. Açık 24 kayıt

Kalan `UNRESOLVED` kayıtlar bir otomasyon hatası olarak kapatılmadı. Dört kök neden
taşırlar:

- **candidate gap:** merdiven/iskele, araç şarjı, silecek/ayna, motosiklet taşıma,
  lazımlık, ilaç kutusu, tespih;
- **combined identity:** duvar+masa saati, buz kalıbı+soğutucu çanta, lastik+bakım;
- **facet/product-type çatışması:** ahşap oyuncak, bez çanta;
- **policy/cross-domain:** medikal konfor ayakkabısı, spor koruma ve supplement+PPE
  umbrella.

Bu 24 kayıt owner-final tree sonrasında target-add / split / retire / out-of-scope
kararı almadan Development migration kapsamına giremez.

## 9. Sonuç

Wave 32 ağacı önceki belirsizliğin büyük kısmını teknik olarak bridge edilebilir
hale getirmiştir. Ancak bu raporun çıktısı bir **candidate graph**'tır; taxonomy
finalization, stable ID tahsisi, product-row mutation veya runtime activation
değildir.

`PREVIOUS_UNRESOLVED_NOW_CANDIDATE_RESOLVED: 438`

`NEW_SPLITS: 127`

`REMOVED_SPLITS: 0`

`POLICY_EXCLUSIONS: 7`

`REMAINING_UNRESOLVED: 24`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
