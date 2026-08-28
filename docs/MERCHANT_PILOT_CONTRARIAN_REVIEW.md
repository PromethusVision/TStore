# Merchant Pilot Contrarian Review

State: `CHALLENGE COMPLETE — NON-FINAL`

## Merchant App gerçekten gerekli mi?

Tam Merchant App gerekli değildir. Fakat “hiç merchant yüzeyi yok” modeli trustworthy pilot öğrenmesini zayıflatır. Merchant'ın kendi identity/shop bağlamında QR preview/confirm görmesi ve listing truth'u sahiplenmesi, operatör simülasyonuyla ikame edilemez.

## QR ilk merchant feature olabilir mi?

Evet, en küçük fiziksel surface QR verifier olabilir; ancak öncesinde auth, exact-shop authority, shop active/policy state ve listing snapshot doğruluğu vardır. Tek başına kamera ekranı güvenli ürün değildir.

## Operatör listing bootstrap edebilir mi?

Evet; küçük cohortta hız kazandırır. Fakat merchant attestation, provenance, bounded workflow ve hızlı self-service handoff yoksa support kuyruğu catalog truth'un otoritesine dönüşür. Spreadsheet/direct SQL kabul edilemez.

## Dashboard erken mi?

Evet. İlk değer action queue ve critical status'tur. Henüz anlamlı örneklem yokken analytics/reputation dashboard geliştirmek yanlış öncelik ve yanlış gelir/satış algısı üretir.

## Multi-staff erken mi?

Tek-owner shops ilk cohortu karşılayabiliyorsa evet. Ancak çözüm shared password değildir. Gerçek bir shop birden çok kasiyer gerektiriyorsa shop ya cohort dışı kalmalı ya da scoped staff capability öne çekilmelidir.

## Assisted onboarding destek yükünü azaltır mı?

İlk kurulumda azaltabilir; sürekli price/availability değişiminde artırır. Bu nedenle assisted onboarding zaman kutulu, ölçümlü ve handoff odaklı olmalıdır.

## En küçük trustworthy surface

Auth + exact shop status + listing truth + QR verifier/reconciliation + support. Reviews read/report ve candidate SHOULD; dashboard/staff/multi-branch/ads/rewards/reputation DEFER.

## Karşı bulguların öneriye etkisi

Model B non-final önerisi korunur. Model C'nin pilotun tamamı değil, ilk bootstrap fallback'i olduğu daha sert tanımlanmıştır. Model A'nın ön yatırımı ticari öğrenmeyi geciktirdiği için pilot önkoşulu sayılmamıştır.
