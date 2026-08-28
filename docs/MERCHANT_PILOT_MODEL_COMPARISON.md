# Merchant Pilot Model Comparison

State: `OPTIONS — OWNER_DECISION_REQUIRED`

## Model A — Full Merchant App before pilot

Tam dashboard, staff, multi-branch, analytics, gelişmiş katalog ve itibar yüzeylerini pilot öncesi tamamlar.

- Güvenlik: doğru uygulandığında güçlü, fakat geniş saldırı/test yüzeyi.
- Kullanılabilirlik: uzun vadede en iyi; ilk cohort için öğrenme öncesi varsayım fazlası.
- Geliştirme süresi: en yüksek.
- Destek/operatör yükü: lansman sonrası düşük olabilir; lansman öncesi eğitim ve kabul yükü yüksek.
- Fraud/katalog/QR: çekirdeği çözebilir ama geniş kapsam bu kontrolleri geciktirir.
- Ticari öğrenme: geç başlar.

## Model B — Minimum safe Merchant App pilot slice

Tek-owner authority, temel listing truth, QR verifier, kritik notifications/support ve audit içerir. Dashboard, multi-staff ve gelişmiş fonksiyonlar ertelenir.

- Güvenlik: küçük yüzey, exact-shop/server authority korunur.
- Kullanılabilirlik: günlük kasa ihtiyacına odaklıdır.
- Geliştirme süresi: orta ve ölçülebilir.
- Destek/operatör yükü: başlangıçta orta; ürün association/candidate için destek gerekir.
- Fraud/katalog/QR: kritik güvenlik kuralları tam uygulanabilir.
- Ticari öğrenme: güvenilir merchant davranışı ve QR öğrenmesi sağlar.

## Model C — Operator-assisted pilot + tiny verifier

Merchant yalnız auth/QR verifier kullanır; shop/listing işlemlerini operatör bootstrap eder.

- Güvenlik: QR sunucu-authoritative kalırsa mümkün; manual listing/authority süreçleri büyük operasyon riski taşır.
- Kullanılabilirlik: merchant için en kolay başlangıç.
- Geliştirme süresi: en düşük.
- Destek/operatör yükü: en yüksek ve ölçeklenmez.
- Fraud/katalog/QR: QR güvenli kalabilir; freshness ve sahiplik darboğazı oluşur.
- Ticari öğrenme: verifier öğrenmesi güçlü, gerçek self-service operasyon öğrenmesi zayıf.

## Karşılaştırma

| Ölçüt | A | B | C |
|---|---|---|---|
| Güvenli minimuma erişim | Yavaş | Dengeli | Yalnız sert sınırlarla |
| Merchant kullanılabilirliği | Geniş/karmaşık | Odaklı | Dar/kolay |
| Geliştirme maliyeti | Yüksek | Orta | Düşük |
| Operatör yükü | Orta | Orta | Çok yüksek |
| Ölçeklenebilirlik | Yüksek | Yeterli | Düşük |
| Listing freshness | Güçlü | Güçlü | Operatöre bağımlı |
| QR güvenilirliği | Güçlü | Güçlü | Güçlü olabilir |
| Pilot öğrenme değeri | Geç | En dengeli | Dar |

## Non-final recommendation

Tek-owner shop cohortu için Model B önerilir. Model C yalnız zaman kutulu onboarding/bootstrap fallback'i olmalı; QR onayı, yetki ve verified history hiçbir zaman operatör yardımıyla taklit edilmemelidir. Model A, kanıtlanmış ihtiyaç oluştuğunda Model B'nin üzerine kademeli kurulmalıdır. Bu seçim Product Owner tarafından henüz onaylanmamıştır.
