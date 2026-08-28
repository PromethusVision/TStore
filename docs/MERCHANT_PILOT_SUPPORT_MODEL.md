# Merchant Pilot Support Model

State: `PROPOSED — CASE-BASED`

## Channels and minimum response

Pilot yüzeyi tek, açık bir support entry point ve fallback contact göstermelidir. Uygulama hatası correlation ID, app/build, shop ID, operation type ve safe status içerir; token, şifre, customer PII veya tüm payload göndermez.

## Case families

| Case | İlk işlem | Yetkili sonraki adım | Yasak kısa yol |
|---|---|---|---|
| Login/session | Güvenli auth yönlendirmesi | Auth recovery | Şifre/OTP isteme |
| Shop ownership | Evidence case | Verification/authority review | UI role değiştirme |
| Listing mismatch | Listing/candidate evidence | Merchant correction/catalog review | Direct SQL |
| Stale price/availability | Listing refresh | Scoped write/retry | Eski değeri doğru sayma |
| QR preview/confirm | Status reconciliation | QR fraud/incident | Manuel used/transaction |
| Review/report | Report evidence | Moderation | Yorumu/puanı merchant isteğiyle silme |
| Regulated item | Pause + policy review | Domain specialist | Varsayılan allow |
| Lost device | Session revoke | Identity verification | Shared account |

## Merchant notification minimum

Actionable notifications: verification/suspension change, ownership/capability change, stale listing, candidate decision, QR ambiguous/final result, support case update ve güvenlik olayı. Marketing, ads, rewards ve vanity summary pilot minimumu değildir.

## Load expectation

Model B'de yük ilk shop/listing bootstrap ve auth/QR eğitiminde yoğunlaşır; self-service freshness bunu azaltır. Model C'de her fiyat/availability değişimi operatöre akar, gecikme ile customer truth bozulur ve support ölçeklenmez. Support load pilot KPI'dır, başarıya makyaj yapılmaz.
