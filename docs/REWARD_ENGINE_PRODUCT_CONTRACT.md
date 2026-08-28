# Reward Engine Product Contract

Status: **PROPOSED — OWNER REVIEW REQUIRED; NO RUNTIME**
Wave: 18 / Workstream A

## Definition

Reward Engine, Product Owner tarafından onaylanmış uygun bir olaydan sonra müşteriye ekonomik veya kullanım değeri taşıyabilecek ayrı bir fayda hakkını değerlendirir, kaydeder ve gerektiğinde geri alır. Kaynak olayın doğruluğunu üretmez; güvenilir event'i tüketir.

## Why EsnaftaVar may need it

- Müşterinin yerel mağazaya tekrar dönmesi için anlaşılır bir fayda sunmak.
- Esnafın dijital görünürlükten doğrulanmış fiziksel alışverişe uzanan değerini güçlendirmek.
- Platform genelinde değilse bile merchant-specific sadakat deneyimini düzenli ve denetlenebilir yapmak.

Bu değer hipotezdir. İlk Esenler ticari pilotunun Reward Engine'e ihtiyaç duyduğu henüz kanıtlanmamıştır.

## Customer value

- Kazanma koşulu, ilerleme, değer, expiry ve redemption önceden anlaşılır.
- Aynı kanıt iki kez ödüllendirilmez.
- Merchant/program şartı sonradan geriye dönük ve haksız biçimde değişmez.
- İtiraz ve düzeltme sonucu açıklanabilir.

## Merchant value

- Uygun, doğrulanmış yerel alışveriş davranışını destekleyen kontrollü loyalty aracı.
- Finansman ve yükümlülük açıkça merchant/program scope'unda tutulabilir.
- Reward hiçbir zaman rating, review hakkı, reputation veya organic ranking satın almaz.

## It is not

- Review eligibility, verified purchase veya QR motoru değildir.
- Ödeme, cüzdan, para, muhasebe, kampanya veya kupon motoru değildir.
- Ad view/click ödülü, sosyal kredi veya zorunlu harcama teşviki değildir.
- Client tap, QR render veya mutable local state'ten hak üretmez.

## Main risks

Fake QR, merchant/customer collusion, duplicate event, multi-account, self-purchase, quantity/amount inflation, expiry/dispute, unfunded liability ve policy-sensitive ürün teşviki. Bu riskler çözülmeden ekonomik reward fail-closed kalır.

## Recommended posture

Architecture ve shadow evaluation önce; ekonomik reward pilot kararı daha sonra. En düşük karmaşıklıklı aday merchant-specific, verified-purchase-count tabanlı, açık şartlı bir stamp/progress modelidir. Formula, funding, threshold ve redemption `OWNER_DECISION_REQUIRED` durumundadır.
