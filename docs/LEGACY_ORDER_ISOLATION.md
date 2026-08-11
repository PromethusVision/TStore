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

Ürün detayından açılan ürün yorumları ayrı ve bilinen bir veri bağı taşır:
yorum uygunluğu halen doğrudan legacy `orders/order_items` tablolarında
`delivered` kayıt arar. Bu bağlantı klasik checkout'a navigation sağlamaz;
QR-doğrulanmış alışveriş modeline taşınması ürün kararı ve ayrı görev gerektirir.

## Korunan legacy alanlar

- `lib/features/orders/**`
- `lib/features/shop/presentation/views/orders_view.dart`
- `lib/features/shop/presentation/widgets/orders_list.dart`
- Legacy `orders` / `order_items` tablo ve veri sözleşmeleri
- Legacy order unit testleri

Bu alanlar topluca silinmemiştir. Ürün yorumu uygunluğunun halen legacy
`orders/order_items` verisine dayanması nedeniyle tablo/veri kaldırma işi ayrı
bir veri etkisi ve migration analizi gerektirir.

## Integration required

`lib/core/dependency_injection/service_locator.dart` halen
`OrderRepositoryImpl`, order use-case'leri ve `OrdersCubit` kayıtlarını içerir.
Aktif kodda bu kayıtlardan tüketim bulunmamıştır; ancak dosya shared/hot-spot
olduğu için bu görevde değiştirilmemiştir. Integration agentı, birleşik branch
üzerinde tüketici olmadığını yeniden doğruladıktan sonra yalnız bu import ve
kayıtları kaldırmalıdır. Legacy dosya, tablo veya veriler bu wiring değişikliği
sırasında silinmemelidir.

## Yasak bağlantılar

- Sepet V2'den `CreateOrderUsecase` veya `OrdersCubit` çağırmak
- Müşteri navigation'ına legacy order ekranı eklemek
- Ürün/mağaza akışından klasik checkout, ödeme veya kargo ekranı açmak
- QR doğrulamasını legacy order kaydı üretmeye dönüştürmek
