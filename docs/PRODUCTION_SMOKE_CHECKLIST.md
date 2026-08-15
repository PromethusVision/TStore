# Production Smoke Checklist

Bu liste **Production'a otomatik apply veya write yetkisi vermez**. Wave 7 audit'i
hesap oluşturmadı, migration uygulamadı ve Production'a bağlanmadı. Gerçek çalışmada
her write önceden onaylı disposable principal/veriyle sınırlı tutulmalıdır.

## 1. Başlatma kapıları

Smoke başlamadan önce tamamı işaretlenmelidir:

- [ ] `PRODUCTION_READINESS_AUDIT.md` içindeki BLOCKER'lar kapatıldı.
- [ ] Production project ref ve HTTPS URL iki kişi/iki bağımsız kaynakla doğrulandı.
- [ ] Artifact, `main_production.dart` ile güvenli CI secret injection kullanılarak
      üretildi; commit, version/build number ve artifact hash kaydedildi.
- [ ] Mevcut `iconsax 0.0.8` korunuyorsa release komutu `--no-tree-shake-icons`
      içeriyor; aksi halde dependency remediation'ın temiz default build kanıtı var.
- [ ] Artifact/service-role, DB password, JWT secret veya signing secret içermiyor.
- [ ] 0001–0009 remote ledger ve schema diff'i PASS; backup/restore kanıtı mevcut.
- [ ] Production RLS/RPC/Storage/Realtime/Auth postflight PASS.
- [ ] Android/iOS kullanılıyorsa gerçek application/bundle id ve release signing PASS.
- [ ] Web kullanılıyorsa HTTPS origin, allowed origins ve Auth redirect allowlist PASS.
- [ ] Production owner iki bağımsız disposable müşteri principal'ı ve gerekiyorsa ayrı
      merchant principal'ı onaylı güvenli yöntemle hazırladı.
- [ ] Test verisi prefix'i, TTL/cleanup sahibi ve gerçek müşteri verisine dokunmama
      kuralı kayıtlı.
- [ ] Log/monitor erişimi, stop kriteri ve incident sorumlusu hazır.

**Kanıt başlığı**

- Production project ref (değer loga secret olarak yazılmamalı):
- Commit / artifact hash:
- Platform / sürüm:
- Tarih-saat / tester:
- Test principal referansları (parola/token yazılmaz):
- Cleanup sahibi:

## 2. Salt-okunur başlangıç kontrolleri

| # | Kontrol | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| R1 | Production migration ledger | Exact 0001–0009 sırası ve beklenen checksum/dosya eşleşmesi | |
| R2 | Public schema / RLS | Canonical 23 tablo, 23/23 RLS; beklenmeyen açık tablo yok | |
| R3 | RPC / grant / trigger | Exact signature, revoke/grant, search path ve trigger contract'ı | |
| R4 | Storage inventory | Yalnız aktif üç bucket zorunlu; deferred bucket'lar beklenmez | |
| R5 | Realtime publication | `chat_messages` ve `notifications` üyedir; beklenmeyen tablo yok | |
| R6 | Auth config | Email/SMTP, redirect URL, allowed origin ve rate-limit ayarları onaylı | |

Herhangi bir remote drift, yanlış project ref veya restore edilemeyen backup görülürse
smoke durdurulur; düzeltme bu checklist içinde doğaçlanmaz.

## 3. Customer akış matrisi

Her satır için PASS/FAIL, zaman damgası, cihaz/tarayıcı ve mümkünse kişisel veri
içermeyen ekran/log kanıtı eklenir.

| Akış | Uygulama adımı | Beklenen sonuç | Sonuç / kanıt |
| --- | --- | --- | --- |
| App startup | Production artifact'ı temiz kurulum/oturumla aç | Splash tamamlanır; yanlış environment/fallback, config exception veya secret görünmez | |
| Guest Home/discovery | Oturum açmadan Home'u aç, yenile ve listeyi kaydır | Public katalog açılır; loading/empty/error durumu kontrollüdür | |
| Categories | Kategori listesi ve bir kategori detayı aç | Doğru ürünler ve kategori görseli gelir; çapraz/bozuk veri crash üretmez | |
| Search | Var olan, olmayan ve özel karakterli sorgu dene | Sonuç/empty state doğru; duplicate ve beklenmeyen private veri yok | |
| ProductDetails | Guest olarak ürün detayına gir | Ürün, fiyat ve satıcılar doğru; legacy HTTPS/canonical product image güvenli görüntülenir | |
| Sellers | Aynı ürünün satıcılarını ve mağaza detayını aç | Yalnız aktif/görünür satıcılar, konum/mesafe izin akışı ve fallback doğru | |
| Login/signup | Disposable User A ile signup/email confirmation/login/logout yap | SMTP/link/session/profile/legal consent çalışır; yanlış veya kullanılmış link reddedilir | |
| Password recovery | Web ve/veya mobile recovery linkini aç | Allowlist'teki origin/scheme uygulamaya döner; token bir kez kullanılır, loga sızmaz | |
| CartV2 | User A bir shop-product ekler, miktar değiştirir/siler; başka mağaza eklemeyi dener | Tek-mağaza kuralı, stok/fiyat revalidation ve duplicate tap koruması çalışır; legacy checkout açılmaz | |
| Favorites | User A ekler/çıkarır; User B ile izolasyonu kontrol et | Own CRUD çalışır; B, A'nın favorisini okuyamaz/değiştiremez | |
| Chat | A ve B aynı conversation'da mesajlaşır; üçüncü conversation ile izolasyonu dene | Real event bir kez gelir; RLS, unread/summary, unsubscribe/reconnect/dedup doğru | |
| Notifications | Canonical ürün trigger'ı ile A için bildirim üret; B'yi gözle | Yalnız A alır; direct authenticated INSERT reddedilir; unread/mark-read/reconnect/dedup doğru | |
| QR create | User A'nın CartV2 verisiyle QR oluştur | Server-authoritative kısa ömürlü session ve immutable item snapshot oluşur | |
| QR physical confirm | Ayrı gerçek merchant cihazında okut/onayla | Doğru mağaza onaylar; yanlış mağaza, expired/cancelled/used token ve double confirm reddedilir | |
| Verified purchase | User A cihazında polling/tamamlanma ve geçmişi aç | İşlem bir kez tamamlanır; doğru ürün snapshot'ları görünür; legacy order akışı açılmaz | |
| Shop rating | Doğrulanmış işlem sonrası mağaza puanı oluştur/güncelle | Eligibility server-derived; yetkisiz, başka kullanıcı ve duplicate davranışı kontrollü | |
| Product review | Yalnız doğrulanmış transaction item ürünü için create/read/update/delete/recreate yap | RPC-only eligibility, server-derived verified flag, idempotent duplicate ve aggregate tutarlılığı çalışır | |
| Profile | Profil görüntüle/düzenle; adres/konum izin reddi ve kabulünü dene | Own data çalışır; cross-user RLS reddeder; izin reddi kontrollü fallback verir | |
| Account deletion | Ayrı disposable hesapta uyarıyı kabul edip sil | Auth/profile ilişkili veri canonical sözleşmeye göre temizlenir; tekrar login olmaz; başka principal etkilenmez | |
| Storage images | Product/category/banner için controlled path ve legacy HTTPS örneği aç; malformed kaynak dene | Public GET çalışır; doğru ortam URL'si kullanılır; malformed/unsupported kaynak fallback verir; list/write/update/delete yoktur | |

## 4. Negatif güvenlik ve yaşam döngüsü

- [ ] Anonymous kullanıcı private profile/cart/favorite/chat/notification/review mutation
      yapamaz.
- [ ] User B, User A'nın private satırlarını okuyamaz veya değiştiremez.
- [ ] Müşteri merchant/admin rolüne client payload ile yükselemez.
- [ ] Direct notification INSERT ve client Storage write/update/delete/list reddedilir.
- [ ] QR token, Auth token, e-posta, parola ve kişisel veri uygulama/edge/CI logunda yoktur.
- [ ] Offline/timeout sonrası retry aynı QR, mesaj, bildirim, rating veya review kaydını
      iki kez oluşturmaz.
- [ ] Logout/login ve Realtime reconnect sonrasında eski kullanıcı kanalı açık kalmaz;
      duplicate subscription/event yoktur.
- [ ] Uygulama yanlış/eksik Production define ile başka ortama fallback yapmadan güvenli
      şekilde durur.

## 5. Storage ve media kabulü

- [ ] `product-images`: `catalog/<product_id>/...` public read.
- [ ] `product-images`: `shops/<shop_id>/<shop_product_id>/...` public read.
- [ ] `category-images`: controlled category path public read.
- [ ] `banner-images`: controlled banner path public read.
- [ ] Existing valid HTTPS media geriye uyumlu okunur.
- [ ] `javascript:`, `data:`, local file, malformed ve unknown bucket/path güvenli fallback.
- [ ] Anonymous object GET çalışırken object listesi ve tüm client mutation'ları reddedilir.
- [ ] `brand-logos`, `avatars`, `review-images` bulunmaması FAIL değildir.

## 6. Stop, rollback ve cleanup

Şunlardan biri görülürse smoke hemen durur:

- yanlış Supabase project ref/origin;
- secret/service-role/DB credential sızıntısı;
- RLS ile başka kullanıcı verisine erişim;
- beklenmeyen migration drift veya veri kaybı;
- duplicate financial/verified purchase kanıtı ya da tekrar kullanılabilir QR;
- hesap silmenin başka kullanıcıya etkisi;
- crash loop veya kontrolsüz hata logu.

Smoke sonunda:

- [ ] Yalnız onaylı test prefix'li chat/notification/cart/QR/rating/review verisi canonical
      cleanup yoluyla temizlendi; gerçek müşteri verisine dokunulmadı.
- [ ] Account-deletion testi dışındaki disposable principal cleanup'ını Auth sahibi yaptı.
- [ ] Residual sayımları kaydedildi; beklenmeyen residual varsa release durduruldu.
- [ ] Log ve ekran kanıtları secret/PII açısından redakte edildi.
- [ ] PASS/FAIL ve açık incidentler release sahibi tarafından imzalandı.

**Final karar**

- [ ] PASS — Production release kapısı açılabilir.
- [ ] FAIL — Release durduruldu; incident/owner/takip işi kayıtlı.
