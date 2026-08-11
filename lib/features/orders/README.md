# Legacy Order Boundary

Bu klasör klasik online sipariş, ödeme ve kargo modelinden kalan kodu içerir.
EsnaftaVar'ın aktif müşteri ürünü bu modeli kullanmaz.

- Aktif akış: ürün keşfi → mağaza seçimi → tek mağaza Sepet V2 → mağazada
  QR doğrulama → doğrulanmış alışveriş geçmişi.
- Bu klasördeki repository, use-case ve Cubit müşteri navigation'ına, Sepet
  V2'ye veya ürün/mağaza akışına bağlanmamalıdır.
- Legacy tablolar ve kod bu görevde veri etkisi analiz edilmeden kaldırılmaz.
- Global DI kayıtlarının kaldırılması shared wiring değişikliği olduğu için
  integration agentına bırakılmıştır.

Teknik sınır ve kaldırma ön koşulları için
[`docs/LEGACY_ORDER_ISOLATION.md`](../../../docs/LEGACY_ORDER_ISOLATION.md)
belgesine bakın.
