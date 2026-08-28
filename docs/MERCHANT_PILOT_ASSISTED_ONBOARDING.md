# Merchant Pilot Assisted Onboarding

State: `PROPOSED — TEMPORARY AND AUDITED`

## Amaç

Küçük cohorttaki esnafın ilk shop ve listing verisini hızla kurmasına yardım eder; merchant authority veya QR güvenliğini operatöre taşımaz.

## Aşamalar

1. Cohort eligibility ve regulated-domain ön kontrolü.
2. Merchant kimliği, shop existence/control ve sektör bilgisinin ayrı evidence olarak toplanması.
3. Merchant'ın kendi email/cihazıyla normal auth hesabını açması.
4. Yetkili süreçle exact shop owner association oluşturulması; destek hesabına owner yetkisi verilmemesi.
5. Minimum shop profile ve başlangıç canonical product/listing taslağı.
6. Merchant'ın alanları/batch'i açıkça doğrulaması.
7. QR verifier eğitimi, test QR'ı ve support kanalının gösterilmesi.
8. Handoff kaydı ve ilk freshness tarihi.

## Operatörün yapabilecekleri

- Form doldurma sırasında ekran paylaşmadan yönlendirme.
- Belge/işletme varlığı inceleme case'i açma.
- Canonical product eşleştirme önerisi ve candidate hazırlama.
- Merchant onaylı listing batch'ini bounded workflow ile yükleme.
- Hata/correction case'i açma ve status iletişimi.

## Yapamayacakları

- Şifre/OTP/session isteme veya merchant gibi giriş yapma.
- Shared admin account kullanma.
- RLS/RPC dışında direct SQL ile routine shop/listing yazma.
- Merchant attestation olmadan fiyat/availability uydurma.
- QR confirm, verified transaction veya review evidence yaratma/değiştirme.
- Regüle ürünü policy review olmadan aktif etme.

## Zaman kutusu ve çıkış

Assisted model her shop için ölçülür: onboarding dakika/temas sayısı, listing correction, freshness lapse ve QR support. Merchant temel listing doğruluğunu kendi sürdüremiyorsa Model C kalıcılaştırılmaz; capability veya cohort kararı yeniden incelenir. Operator path için kapatma hedefi owner gate'idir, takvim vaadi değildir.
