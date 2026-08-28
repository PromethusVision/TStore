# Merchant App V1 Anti-Scope

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP03

## Explicit exclusions

| Area | V1 decision | Why |
|---|---|---|
| Online checkout/payment | EXCLUDED | Fiziksel keşif ve doğrulama misyonunu ödeme kuruluşu kapsamına taşır |
| Shipping/delivery | EXCLUDED | Sipariş, adres, kurye ve SLA motoru gerektirir |
| Full ERP/accounting/payroll | EXCLUDED | Yerel mağaza operasyon kapsamını aşar |
| Warehouse/WMS | EXCLUDED | V1 availability tam stok defteri değildir |
| Sophisticated CRM | EXCLUDED | Müşteri profilleme ve privacy riskini büyütür |
| Booking/reservation | OWNER_DECISION_REQUIRED / DEFER | Service merchant için değerli olabilir; ayrı ürün sözleşmesi gerekir |
| Campaign manager | DEFER | Ads engine ve disclosure kararı olmadan yapılamaz |
| Advanced gamification/reward | DEFER | Manipülasyon ve finansal teşvik politikası çözülmeli |
| Order management | EXCLUDED | QR fiziksel satın alma kanıtıdır, order completion değildir |
| Customer review editing/deletion | FORBIDDEN | Müşteri güvenini ve immutable evidence zincirini bozar |

## Guardrails

- “Satış” ifadesi yalnız kanıt kapsamı açık doğrulanmış fiziksel satın alma metriği için kullanılabilir; ödeme geliri iddiası değildir.
- Availability, merchant'ın bilgi seviyesi olarak tutulur; kusursuz gerçek zamanlı stok sözü verilmez.
- Merchant sector, product taxonomy yerine geçmez ve authorization sağlamaz.
- Bir future-engine alanı için yalnız extension point tanımlanabilir; V1 ekran/iş kuralı üretilemez.

## Scope challenge questions

Yeni bir özellik V1'e alınmadan önce şu soruların tamamı yanıtlanmalıdır:

1. Esenler pilotunda QR, mağaza veya listing operasyonunu doğrudan tamamlıyor mu?
2. Güvenli server contract mevcut mu?
3. Mahalle esnafının eğitim yükü kabul edilebilir mi?
4. Customer trust veya policy etkisi çözüldü mü?
5. Aynı değer daha küçük bir akışla üretilebilir mi?
