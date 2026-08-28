# Merchant App Product Mission

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP01

## Mission

EsnaftaVar Merchant App, yerel esnafın müşteri uygulamasında görünen mağaza ve tekliflerini güvenli biçimde işletmesini, fiziksel alışverişi QR ile doğrulamasını ve operasyon sonucunu anlaşılır ölçülerle izlemesini sağlayan ayrı bir operasyon uygulamasıdır.

## Users

- Tek mağazalı yerel işletme sahibi.
- Bir veya daha çok şubeyi yöneten işletme sahibi/yönetici.
- Fiyat ve bulunabilirlik güncelleyen yetkili personel.
- Yalnız fiziksel satın alma QR'ını doğrulayan personel.
- Politika incelemesi gerektiren düzenlemeye tabi işletme; uygunluk tamamlanana kadar fail-closed.

## Core problems

1. Canonical ürünü yeniden yaratmadan mağazaya özgü teklif oluşturmak.
2. Fiyatı, bulunabilirliği ve mağaza bilgisini güncel tutmak.
3. Kısa ömürlü müşteri QR'ını doğru mağazada, server-authoritative biçimde doğrulamak.
4. Doğrulanmış satın alma, görünürlük ve liste sağlığı gibi operasyon sinyallerini yanıltıcı olmayan metriklerle göstermek.
5. Personeli en az yetki ilkesiyle mağaza/şube kapsamında çalıştırmak.

## Deliberate non-goals

- Online ödeme, sipariş tamamlama, kargo veya teslimat motoru değildir.
- ERP, muhasebe, bordro, depo/WMS veya gelişmiş CRM değildir.
- Merchant'ın canonical ürün, müşteri yorumu, doğrulanmış satın alma veya organik sıralama gerçeğini değiştirebildiği bir yönetim paneli değildir.
- QR bir ödeme veya sipariş kanıtı değildir; yalnız fiziksel satın alma doğrulamasıdır.
- Reklam, ödül, rozet ve gamification motorlarını V1 içinde sahiplenmez.

## Customer App complement

Customer App keşif, karşılaştırma, mağaza/ürün görüntüleme, yerel sepet ve müşteri QR'ı üretir. Merchant App mağaza/listing güncelliğini ve QR doğrulama tarafını sağlar. İki uygulama aynı server-authoritative sözleşmeleri kullanır; navigation ve feature state paylaşmaz.

## Success principles

- Mahalle esnafı için birkaç dokunuş, sade Türkçe ve güvenli varsayılanlar.
- Canonical ürün, variant, shop listing, merchant identity ve shop/branch sınırları ayrı.
- Hassas müşteri verisi ve başka merchant'a ait özel veri gösterilmez.
- Güvenlik ve politika kontrolleri istemci görünürlüğüne bırakılmaz.
- Belirsiz veya riskli işlem sessizce başarıya düşmez.

