# Merchant V1 — kapsam, mimari ve ekran envanteri

Yetki: 2026-09-29 tarihli Product Owner mesajı. Customer V1 FROZEN.
Taban: `79fc1adc9ef48ef12607cf4cac7fd7d4db6d5463`.
Çalışma dalı: `agent/merchant-v1`. Main entegrasyonu Integration Agent'a aittir.

## Kodlamadan önce yapılan envanter

| Alan | Mevcut sözleşme | Merchant V1 kararı |
|---|---|---|
| Auth | AuthRepositoryImpl, profiles.role, sunucu role guard | Ortak kimlik doğrulama; her workspace yüklemesinde sunucu rolü ve exact-owner kontrolü |
| Mağaza | shops, owner başına tek mağaza, owner RLS; ShopEntity/ShopModel | Mevcut modele bağlı kurulum ve profil; owner/role/rating yazılmaz |
| Katalog | products ortak kimlik; shop_products esnaf fiyatı/açıklaması/görseli | Ortak ürünü mağazaya ekle; ortak ürün adını/kategorisini değiştirme |
| Ürün kaldırma | unique(shop_id,product_id); tarihsel referanslar | Soft-deactivate; tekrar aktifleştir; hard delete yok |
| Stok | shop_products.is_available ve is_active; adet alanı yok | Var/yok ile pasif ayrımı; global products.stock kullanılmaz |
| QR | get_qr_session_for_verification, confirm_qr_session; QrVerificationCubit | Mevcut port ve durum makinesi; exact-shop bağlama; kamera/onay kabuğu |
| Bildirim | NotificationRepositoryImpl, NotificationsCubit, notifications + Realtime | Aynı repository/cubit; Merchant sunumu, rol/hesap sınırı ve yerel tercihler |
| Push | PushCoordinator, NotificationAppRole.merchant, unconfigured provider | Aynı arayüzler; ikinci sistem yok; Firebase/APNs PENDING |
| Tasarım | EsnaftaVarTheme ve ortak tokenlar | Ayrı Merchant navigasyonu; Customer ekranları değiştirilmez; FIG geldiğinde yerel kaynak kabul edilir |

## Uygulama sınırı

Merchant giriş noktası ve composition root ayrı; `lib/features/merchant/` içinde
domain/data/presentation katmanları bulunur. Customer bootstrap, global DI,
navigation, runtime ve tema kaynakları değiştirilmez. Flutter Bloc ve mevcut
bağımlılıklar yeterlidir.

Onaylı merchant hesabı olmayan kullanıcıya erişim durumu açıklanır. Kayıt olmak
veya mağaza oluşturmak rol onayı sayılmaz. V1 onboarding, yetkilendirilmiş tek
mağaza sahibinin mağaza kurulumudur; otomatik rol yükseltme veya müşteri hesabını
esnafa çevirme uygulanmaz. Askıya alınmış mağaza uygulamadan aktifleştirilemez.

Formlar doğrulama, çift gönderim önleme, güvenli hata, yeniden deneme ve başarılı
kayıt geri bildirimi içerir. Eski oturumun sonucu yeni hesaba taşınmaz.
Yazmalarda exact shop/owner koşulu ve güncelleme zamanı ile çakışma kontrolü
bulunur. Başarısız/çevrimdışı yazma başarılı gösterilmez veya kuyruklanmaz.

## Ekran envanteri

1. Merchant giriş; yükleniyor/oturum yok/erişim yok/yeniden dene.
2. Onboarding: yetkili hesap için mağaza adı, açıklama, iletişim, adres ve saatler.
3. Dashboard: gerçek mağaza ve ürün bulunabilirlik özeti; ürün/QR/profil kısayolları.
4. Mağaza profili: mevcut bilgileri düzenleme.
5. Ürünler: arama, sayfalama, aktif/bulunmayan/pasif durumları.
6. Katalog seçimi: mevcut ortak ürünü bulma ve mağazaya ekleme.
7. Ürün düzenleme: fiyat, mağazaya özel açıklama, bulunabilirlik, pasife alma.
8. QR: tarayıcı, hata/izin, sunucu özeti, açık onay ve sonuç.
9. Bildirim merkezi: okundu işareti, yenileme, sayfalama; ortak durum makinesi.
10. Ayarlar/hesap: kimlik, yerel bildirim tercihleri, oturumu kapat.

Dashboard gelir, puan veya ödül uydurmaz. Bildirim içeriği müşteri/Reward/Trust
ekranlarına otomatik geçiş sağlamaz. Merchant V1 fiziksel QR E2E tamamlandı veya
gerçek push teslimatı aktif iddiası taşımaz.

## Backend ve dış yetki ayrımı

Mevcut onaylı merchant + mağaza/listing akışları için yeni migration zorunlu değil.
Uygulanmış migration dosyaları ve mevcut proposal 0016 değiştirilmeyecek.

Gelecekte ayrı backend sözleşmesi gerektiren konular:

- Başvuru, sektör allowlist incelemesi ve operator onay kuyruğu; istemci rol veremez.
- Ortak katalogda bulunmayan ürünün aday olarak gönderilmesi ve yayınlanması.
- AVAILABLE/OUT/UNKNOWN/TEMP, freshness ve adet stoku: mevcut boolean'ın anlamı
  sessizce değiştirilmez; Customer FROZEN nedeniyle iki uygulama uyumu ayrıca incelenir.
- Merchant hesap silme: customer-only silme RPC'si merchant için çağrılmaz.
- Mevcut push proposal'ının gözden geçirilmesi, provider kurulumu ve deployment.

Bu konular için otomatik migration numarası ayrılmadı ve mevcut güvenlik
politikaları genişletilmedi. Öneriler runtime'da varmış gibi gösterilmez.

Yerel test, sentetik önizleme, unit/widget testleri ve compilation bu görev
kapsamındadır. Production write, migration apply, gerçek hesap provision,
Firebase/APNs credentials, signed release ve iki cihazlı fiziksel QR için ayrı
yetki/entegrasyon gerekir. Bu çalışma hiçbir remote backend'e bağlanmaz.

Reviews, ratings, badges, reward economics/eligibility, reputation, advanced
campaign/ads ve final Trust & Engagement entegrasyonu kapsam dışıdır.
