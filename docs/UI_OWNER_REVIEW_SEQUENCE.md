# UI Owner Review Sequence

Bu sıra telefondan hızlı karar vermek için bağımlılıkları öne alır. Kararların
kimliği ve seçenekleri Wave 27 ile aynıdır; yalnız sıra optimize edilmiştir.

| SIRA | ROOT_ID | WHY_NOW | WHAT_IT_UNLOCKS | WHAT_CAN_WAIT | OWNER_COMPLEXITY |
|---:|---|---|---|---|---|
| 1 | UI-R01 | Bütün görsel tokenlar bu role bağlı | Semantic renkler ve component screenshot'ları | İnce gölge ve dekorasyon | MODERATE |
| 2 | UI-R02 | Mevcut uygulama sistem dark mode'a geçebiliyor | Desteklenen tema matrisi ve golden kapsamı | Tam dark polish seçeneği A ise bekler | EASY |
| 3 | UI-R03 | Ana vitrin yönü ekran rollout'unu açar | Home, listing, product/seller Waves 3–5 | Secondary ekran polish'i | HARD |
| 4 | UI-R06 | AuthGuard foundation/navigation dalgasındadır | Login gate ve korunan tab/component sözleşmesi | Secondary auth dekorasyonu | EASY |
| 5 | UI-R04 | Shop CTA product/seller yolculuğunu tamamlar | Shop header/action golden baseline | Chat görsel detayları | MODERATE |
| 6 | UI-R05 | Cart ve QR ekranları yanlış checkout anlamı taşımamalı | Cart V2/QR Wave 7 | QR dekoratif polish | MODERATE |
| 7 | UI-R07 | Kart ölçüleri Home ve listing'i birlikte belirler | ProductCard, CategoryCard/Row ve grid metrikleri | Secondary card varyantları | MODERATE |
| 8 | UI-R10 | Kritik ekran metinleri screenshot ve overflow'u etkiler | Copy review ve final golden içerikleri | Legal/help tone polish | EASY |
| 9 | UI-R08 | Home/product media ilk vitrinde görünür | MediaFrame, fallback ve icon acceptance | Özel illüstrasyonlar | EASY |
| 10 | UI-R11 | Review/purchase trust dalgasından önce gerekli | VerifiedBadge ve dormant signal politikası | Ads/Reward görsel sistemi | VERY_EASY |
| 11 | UI-R14 | Component paylaşım sınırını netleştirir | Customer/Merchant foundation paylaşımı | Merchant ekran polish'i | EASY |
| 12 | UI-R12 | Pilot kapsamının büyümesini sınırlar | Wave 9/10 ve deferment ledger | V3 kozmetik işler | EASY |
| 13 | UI-R15 | Uygulamaya başlamadan kabul kanıtı bilinmeli | Golden manifest ve visual freeze | V2/V3 kabul ayrıntıları | MODERATE |
| 14 | UI-R09 | Temel layout motion olmadan başlayabilir | Motion token ve reduced-motion davranışı | Hero/dekoratif animasyon | VERY_EASY |
| 15 | UI-R13 | Telefon rollout'u max-width varsayımıyla ilerleyebilir | Büyük ekran acceptance sınırı | Bespoke tablet tasarımı | VERY_EASY |

## Complexity totals

| OWNER_COMPLEXITY | COUNT |
|---|---:|
| VERY_EASY | 3 |
| EASY | 6 |
| MODERATE | 5 |
| HARD | 1 |
| **TOTAL** | **15** |

Önerilen mobil cevap sırası:

`UI-R01`, `UI-R02`, `UI-R03`, `UI-R06`, `UI-R04`, `UI-R05`, `UI-R07`,
`UI-R10`, `UI-R08`, `UI-R11`, `UI-R14`, `UI-R12`, `UI-R15`, `UI-R09`,
`UI-R13`.
