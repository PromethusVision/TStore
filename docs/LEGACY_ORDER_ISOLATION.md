# Legacy Order / Checkout İzolasyonu

## Hedef ürün modeli

EsnaftaVar bir online e-ticaret checkout ürünü değildir. Online ödeme, kargo,
klasik checkout ve klasik sipariş akışı hedef modelin parçası değildir. Müşteri
ürünü yakındaki esnafta keşfeder; tek mağaza için sepet hazırlar; alışveriş
fiziksel mağazada QR ile doğrulanır. Geçmiş ekranı `verified_transactions`
tabanlı doğrulanmış alışverişleri gösterir.

## Aktif müşteri yolculuğu

- Ana navigation: Ana Sayfa, Yakındakiler, Sepet, Favoriler ve Profil.
- Ürün detay ve mağaza profili, mağaza ürünü seçimi ile Sepet V2'ye bağlanır.
- Sepet V2, `QrSessionCubit` ve `CartQrSessionBottomSheet` ile mağaza içi
  doğrulamayı başlatır.
- Başarılı doğrulama `PurchasesView` üzerinden doğrulanmış alışveriş geçmişine
  gider.

Bu aktif alanların hiçbiri `features/orders`, `OrdersCubit`,
`CreateOrderUsecase` veya legacy `orders_view.dart` ekranını import etmez.
`test/architecture/legacy_order_isolation_test.dart` bu sınırı regression testi
olarak korur.

Ürün detayından açılan ürün yorumları ayrı ve bilinen bir veri bağı taşır.
`ReviewRepositoryImpl.addReview`, legacy `orders/order_items` tablolarında
`delivered` kayıt arar; ancak bu sonuç yorum göndermeyi engellemez, yalnız
`reviews.is_verified_purchase` alanını belirler. Mevcut ürün yorumları ekranı
salt okunurdur ve submit UI içermez. Bu bağlantı klasik checkout'a navigation
sağlamaz; doğrulanmış etiketi/yorum uygunluğunun QR-doğrulanmış alışveriş
modeline taşınması için ürün sahibi **Option A** yönünü kesinleştirmiştir.
Server-authoritative eligibility ve durable verified item kanıtı henüz
uygulanmadığından mevcut legacy bağı bu audit wave'inde kaldırılmamıştır.

## Korunan legacy alanlar

- `lib/features/orders/**`
- `lib/features/shop/presentation/views/orders_view.dart`
- `lib/features/shop/presentation/widgets/orders_list.dart`
- Legacy `orders` / `order_items` tablo ve veri sözleşmeleri
- Legacy order unit testleri

Bu alanlar topluca silinmemiştir. Ürün yorumu doğrulanmış satın alma etiketinin
legacy `orders/order_items` sorgusuna, hesap silme RPC'sinin de `orders`
tablosuna dayanması nedeniyle tablo/veri kaldırma işi ayrı bir veri etkisi ve
migration analizi gerektirir.

## Güncel DI ve DB durumu

Wave 2 entegrasyonu sonrasında
`lib/core/dependency_injection/service_locator.dart` içinde
`OrderRepositoryImpl`, order use-case'leri veya `OrdersCubit` import/kaydı
bulunmaz. Legacy Dart sınıfları yalnız kendi modülleri ve testleri içinde
reachable durumdadır; architecture testi bunların aktif uygulama koduna yeniden
import edilmesini engeller.

Legacy DB bağı tamamen bitmemiştir. Review repository doğrulanmış satın alma
etiketi için tabloları doğrudan sorgular; ayrıca `delete_current_customer_account`
RPC'si cascade olmayan `orders.user_id` foreign key'i nedeniyle auth kullanıcısı
silinmeden önce legacy order kayıtlarını siler. Kesin dependency haritası ve
kaldırma sırası için
[`REVIEW_ELIGIBILITY_LEGACY_ORDER_AUDIT.md`](REVIEW_ELIGIBILITY_LEGACY_ORDER_AUDIT.md)
belgesine bakın.

Canonical ürün yönü Option A olsa da legacy `orders/order_items` drop'u bu
kararla otomatik olarak yetkilendirilmez. Önce review eligibility geçişi ve
account-delete bağı ayrı bir implementation ile tamamlanmalı; destructive drop
ancak sonraki, veri etkisi ayrıca onaylanmış migration aşamasında ele alınmalıdır.

## Yasak bağlantılar

- Sepet V2'den `CreateOrderUsecase` veya `OrdersCubit` çağırmak
- Müşteri navigation'ına legacy order ekranı eklemek
- Ürün/mağaza akışından klasik checkout, ödeme veya kargo ekranı açmak
- QR doğrulamasını legacy order kaydı üretmeye dönüştürmek
