# Legacy Order Boundary

Bu klasör klasik online sipariş, ödeme ve kargo modelinden kalan kodu içerir.
EsnaftaVar'ın aktif müşteri ürünü bu modeli kullanmaz.

- Aktif akış: ürün keşfi → mağaza seçimi → tek mağaza Sepet V2 → mağazada
  QR doğrulama → doğrulanmış alışveriş geçmişi.
- Bu klasördeki repository, use-case ve Cubit müşteri navigation'ına, Sepet
  V2'ye veya ürün/mağaza akışına bağlanmamalıdır.
- Legacy tablolar ve kod bu görevde veri etkisi analiz edilmeden kaldırılmaz.
- Global DI import ve kayıtları Wave 2 entegrasyonunda kaldırılmıştır. Bu
  modüldeki sınıflar yalnız kendi legacy kodu ve unit testleri içinde birbirine
  bağlıdır; aktif uygulama koduna yeniden import edilmemelidir.
- Product review için canonical yön Option A'dır: yalnız server-authoritative
  doğrulanmış fiziksel/QR alışveriş eligibility sağlar. Bu kararın implementation'ı
  tamamlanmadan ve hesap-silme DB bağı ayrıştırılmadan legacy kod veya
  `orders/order_items` tabloları kaldırılmamalıdır.

Teknik sınır ve kaldırma ön koşulları için
[`docs/LEGACY_ORDER_ISOLATION.md`](../../../docs/LEGACY_ORDER_ISOLATION.md)
belgesine bakın.
