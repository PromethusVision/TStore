# NEXT_STEPS

Bu dosya kısa çalışma sırası notudur. Güncel kod gerçeği için
`docs/PROJECT_STATE.md`, onaylı/açık ürün işleri için `docs/PRODUCT_BACKLOG.md`
esas alınır.

## Hedef ürün sınırı

- Online ödeme, kargo, klasik checkout veya klasik sipariş akışı geliştirilmez.
- Müşteri yakındaki esnafta ürün keşfeder ve tek mağaza Sepet V2'yi hazırlar.
- Alışveriş fiziksel mağazada QR ile doğrulanır.
- Geçmiş ve puanlama, doğrulanmış fiziksel alışveriş modeline taşınır.

## Sıradaki doğrulamalar

1. QR release-hardening migration'ını önce gerçek PostgreSQL/test Supabase
   üzerinde doğrula; production uygulaması ayrı yetki ve güvenlik kapısıdır.
2. Müşteri QR oluşturma → esnaf okutma → esnaf onayı → müşteride tamamlanma
   akışını iki gerçek hesap ve iki fiziksel cihazla kabul et.
3. Ürün yorumu uygunluğunun legacy `orders/order_items` yerine QR ile
   doğrulanmış alışverişe taşınması için ürün kararını netleştir.
4. Integration aşamasında tüketicisi olmayan legacy order DI kayıtlarını
   kaldır; legacy dosya, tablo veya verileri bu işlem sırasında silme.

## Legacy order sınırı

`lib/features/orders/**` ile eski shipping/payment sözleşmeleri yalnız legacy
uyumluluk ve veri etkisi analizi için tutulur. Ana navigation, Sepet V2, ürün
detay ve mağaza profili bu alana bağlanmaz. Teknik ayrıntı ve regression kanıtı
için `docs/LEGACY_ORDER_ISOLATION.md` belgesine bakın.
