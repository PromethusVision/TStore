# Minimum Merchant Pilot Contract

State: `PROPOSED FOR OWNER REVIEW — NON-FINAL`

## Amaç

İlk kontrollü Esenler pilotunda merchant'ın liste doğruluğunu sürdürebildiği ve müşterinin fiziksel alışverişini güvenilir biçimde doğrulayabildiği en küçük güvenli yüzeyi tanımlar. Bu, tam Merchant App kapsamını iptal etmez; veri oluşmadan önce dashboard ve organizasyon özellikleri geliştirilmesini erteler.

## Güvenli minimum

Pilot merchant yüzeyi şu kritik yolculuğu kesintisiz sağlamalıdır:

1. Merchant kendi hesabıyla giriş yapar.
2. Sunucu aktif üyelik/owner durumunu ve exact shop kapsamını doğrular.
3. Merchant doğrulanmış/aktif mağaza özetini ve pilot durumunu görür.
4. Kendisine atanmış canonical ürün/listinglerini görür.
5. Fiyat, bulunabilirlik ve doğruluk zamanını güvenli biçimde günceller.
6. Müşteri QR'ını tarar; mağaza, ürün, adet ve snapshot toplamını görür.
7. Açık onay verir; sunucu tek atomik işlemle exact-shop ve single-use koşullarını uygular.
8. Belirsiz ağ sonucunda işlem durumu sunucudan uzlaştırılır.
9. Merchant yalnız kendi mağazasının doğrulama geçmişini sınırlı, PII-minimized biçimde görür.
10. Kritik sorun için case/correlation kimliğiyle destek ister.

## MUST

- Email/password auth, güvenli session değişimi ve logout.
- `user + active membership/owner + exact shop + capability + lifecycle/policy` bileşik yetki kontrolü.
- Tek mağazalı pilot için `OWNER` yetkisi; UI rolü değil sunucu kanıtı.
- Minimum shop profile: ad, adres/konum özeti, çalışma/aktiflik durumu, destek için doğrulanmış iletişim.
- Listing okuma; price, availability/unknown, active state ve `last_verified_at` yazma.
- Existing-first canonical product association; bilinmeyen ürünün sessizce yayınlanmaması.
- Exact-shop QR preview, açık confirm, replay/wrong-shop/expiry/concurrency reddi ve belirsiz sonuç reconciliation.
- Append-only audit/correlation kanıtı; verified history'nin sessizce silinememesi.
- Regüle/şüpheli ürün ve merchant durumda fail-closed.
- Kamera/izin, yavaş ağ, timeout, background/resume ve session switch güvenliği.
- Kritik bildirim: yetki/verification/listing/QR sonucu ve destek eskalasyonu.

## SHOULD

- Basit catalog candidate gönderimi; operatör incelemesine düşer.
- Son QR doğrulamaları için PII-minimized read-only geçmiş.
- Verified product review ve structured shop evaluation için read-only görünürlük.
- Review/report oluşturma; merchant cevap verme pilot sonrası olabilir.
- Basit health/freshness uyarıları; chartsız action-first özet.

## DEFER

- Gelişmiş dashboard ve analytics görselleştirmeleri.
- Çok katmanlı staff hierarchy, davet, vardiya ve cihaz yönetimi.
- Multi-branch yönetimi ve cross-branch transfer.
- Ads, reward/gamification ve reputation/badge yönetimi.
- Bulk import, gelişmiş inventory, medya stüdyosu ve ML catalog eşleştirme.
- Review response kampanyaları ve composite badge yüzeyleri.

## Asla manuel olmaması gerekenler

- Merchant şifresi/session'ı yönetmek.
- Yetkiyi yalnız UI rolü veya spreadsheet ile vermek.
- QR'ı SQL/operatör ile used yapmak.
- Verified purchase oluşturmak, fiyat snapshot'ını değiştirmek veya geçmişi silmek.
- RLS/RPC'yi bypass ederek listing güncellemek.
- Candidate ürünü incelemesiz canonical olarak yayınlamak.

## Ticari ifade sınırı

QR doğrulaması ödeme, mali fiş, teslimat, gelir veya denetlenmiş satış kanıtı değildir. Merchant history ve analytics yüzeyleri bu iddiayı üretmemelidir.

