# UI C1 Closure Evidence Checklist

Bu kontrol Wave 27 Git belgelerini kullanır. Wave 29 Figma'yı değiştirmedi ve canlı
Figma artifact'ını yeniden doğrulamadı. Kanıt olmayan madde kapalı sayılmaz.

| C1 ITEM | CURRENT EVIDENCE | FIGMA_REVIEW_REQUIRED | FLUTTER_EFFECT | STATUS |
|---|---|---|---|---|
| Home placeholder/developer copy | Phase C Home sözleşmesi var; satır/screenshot bazlı customer-copy kapanışı yok | YES | Home copy, text fixtures ve golden'lar gelecekte etkilenir | OPEN |
| Customer-frame annotation removal | Phase C screen inventory/render PASS kaydı var; annotation kaldırma kapanışı açıkça kayıtlı değil | YES | Normalde runtime etkisi yok; müşteri copy'sine sızan annotation varsa kaldırılmalı | OPEN |
| SellerPriceRow compact mobile treatment | Phase C üç Mobile varyantı ve node ID'leri belgeliyor; güncel render Wave 29'da görülmedi | YES | `product_sellers_section.dart` ve future SellerPriceRow mobile widget/golden | UNCLEAR |
| Shop Details CTA hierarchy | Phase C fiziksel mağaza ziyaretini primary olarak tarif ediyor; güncel board/tek-el görünümü görülmedi | YES | `shop_profile_view.dart` header/action sırası ve golden baseline | UNCLEAR |
| Esenler representative sample context | Phase C temsili yerel ürün/esnaf sayıları kullanıyor; örneklerin Esenler temsil yeterliliğine dair kapanış kanıtı yok | YES | Yalnız sentetik fixture/copy/golden; demo veya Production verisi bu taskta değişmez | UNCLEAR |
| Cart V2 arithmetic sample | Cart semantics belgelenmiş; line total ile displayed total'ın aynı fixture'dan yeniden hesaplandığına dair kanıt yok | YES | Önce Figma/sample fixture düzeltilir; gerçek domain arithmetic ancak ayrı regression kanıtı sorun bulursa etkilenir | OPEN |

## Counts

| STATUS | COUNT |
|---|---:|
| CONFIRMED_CLOSED | 0 |
| OPEN | 3 |
| UNCLEAR | 3 |
| **TOTAL** | **6** |

## Closure evidence required

1. Current Figma file version and exact frame/node IDs.
2. Customer-visible export with no developer copy or annotation.
3. SellerPriceRow at 390 px with long shop name, large price, best-price and
   unavailable states.
4. Shop Details export showing primary/secondary CTA order and one-hand reach.
5. Esenler-representative synthetic sample context, clearly marked non-production.
6. Cart sample inputs, each line total and displayed total in one reproducible
   arithmetic record.

`C1_CONFIRMED_CLOSED: 0`

`C1_OPEN: 3`

`C1_UNCLEAR: 3`
