# Reward Bar Architecture Options

Status: **PROPOSED — NO FORMULA FINALIZED**
Wave: 18 / Workstream B

## Compared models

| Model | Evidence need | Benefit | Primary risk | Posture |
|---|---|---|---|---|
| Purchase-count progress | One eligible verified purchase event | Basit, miktar/fiyat güvenine az bağımlı | Split-purchase ve collusion | RECOMMENDED STARTING HYPOTHESIS |
| Verified-spend-like progress | Authoritative monetary amount/currency/correction | Değerle orantılı olabilir | Amount trust, refund, liability, incentive risk | BLOCKED/TBD |
| Points | Versioned earning and redemption formula | Esnek | Kullanıcı anlamı, accounting ve devaluation | FUTURE |
| Merchant-specific bar | Merchant/shop scoped earning/redemption | Funding ve value sınırı anlaşılır | Portability düşük, merchant closure | RECOMMENDED SCOPE HYPOTHESIS |
| Platform-wide bar | Cross-merchant earning/redemption | Tek müşteri deneyimi | Clearing, liability, fairness, policy | MAJOR OWNER DECISION |
| Hybrid | Program rules by merchant/category/platform | Esnek | Çoklu bakiye ve açıklanabilirlik | DEFER |

## Representation vs economic unit

“Ödül çubuğu” yalnız görsel progress olabilir; arkasındaki hak stamp, event count, points veya credit olabilir. Yüzde göstermek ekonomik formula belirlemek anlamına gelmez ve threshold değişirse mevcut ilerlemeyi sessizce yeniden değerleyemez.

## Guardrails

- Yalnız reward ledger sonucu çubuğu ilerletir; QR ekranı veya client event'i değil.
- Duplicate/reversed/ineligible events ilerleme yaratmaz veya reversible event üretir.
- Quantity/repeat reward kararı review hakkını değiştirmez.
- Sponsored journey aynı organic purchase ile eşit reward değerlendirmesi görür.
- Expiry ve merchant/program scope her yüzeyde görünür.

## Recommendation

Owner research için merchant-specific purchase-count/stamp ile platform-wide spend/points seçeneklerini ayrı simüle et. Amount trust kanıtlanmadan spend-weighted model önerilmez.
