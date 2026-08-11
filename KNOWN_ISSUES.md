# KNOWN_ISSUES

Bu dosya kısa operasyon notudur. Ayrıntılı güncel durum için
`docs/PROJECT_STATE.md`, açık işler için `docs/PRODUCT_BACKLOG.md` esas alınır.

## Bilinen açık konular

1. QR release-hardening migration'ı gerçek PostgreSQL/test Supabase üzerinde
   doğrulanmadı ve production ortamına uygulanmadı.
2. Müşteri QR → esnaf okutma → esnaf onayı → müşteri tamamlanma akışı iki
   gerçek cihazla kabul edilmedi.
3. Legacy order/shipping/payment kodu repoda ve global DI kayıtlarında duruyor;
   aktif müşteri navigation'ına bağlı değil. Bu kod Sepet V2, ürün detay veya
   mağaza akışına bağlanmamalıdır.
4. Ürün yorumu uygunluğu halen legacy `orders/order_items` modeline bakıyor;
   mağaza puanı ise QR ile doğrulanmış alışveriş modelini kullanıyor.
5. `main_development.dart` ve `main_production.dart` halen aynı davranıyor.
6. Sosyal giriş düğmeleri görünür olsa da backend giriş metoduna bağlı değil.
7. `.env` içine özel/service-role secret konmamalı ve dosya commit edilmemeli.

Legacy sınırı için `docs/LEGACY_ORDER_ISOLATION.md` belgesine bakın.
