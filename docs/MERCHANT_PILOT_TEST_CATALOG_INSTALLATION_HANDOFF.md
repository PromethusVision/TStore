# J8 — Onaylı test katalog altyapısı kurulumu

Durum: **PASS — yalnız Development altyapısı kuruldu; ürün yayımlanmadı.**
Tarih: 2026-10-18. Hedef: **EsnaftaVar Development — `tnipyxnvhgelwdpykyez`**.
Görev dalı: `agent/merchant-pilot-catalog-installation`.

## Yetki ve başlangıç

Product Owner'ın “onaylıyorum” mesajı, J7 sonunda sunulan **altyapı kurulumu**
kapsamına uygulandı. Integration Agent'ın PASS sonucu ayrıca okundu; kaynak
`4baeaf499c8343b7fe276b915b26563630f755d5`, birleşmiş main
`50c1b16c6bd92d7b501fa96e807f218c7a425770` ve ağaç eşitliği doğrulandı.

Production'a erişilmedi. Gerçek ürün yayını, kategori açılışı, hesap/rol değişikliği,
Auth, bildirim, Storage ve önceki A/C/E işlemlerinin tekrarı bu onaya dahil değildir.
Kullanılan tarayıcı sayfasında proje kimliği ve Development adı doğrulandı.

## Uygulanan kapsam

- Bir özel kayıt tablosu: `catalog_publication_batches`.
- Üç istemcilere kapalı SECURITY INVOKER işlev: `_catalog_publication_immutable_v1`,
  `_catalog_price_contract_guard_v1`, `_publish_catalog_submission_v1`.
- İki koruma tetikleyicisi: `catalog_publication_immutable` ve
  `catalog_price_contract_guard`.
- Tek kurulum kaydı: `20261018003300 / 0033_pilot_catalog_publication`.

Değişmemiş J7 önerisi ve kaynak bağlı `schema.review.sql` kullanıldı. Editöre
aktarılan metin LF biçimine göre eksiksiz geri okundu. Onay belirteci yalnız aynı
işlem içinde `SET LOCAL` ile eklendi; kalıcı bir ayar yapılmadı. Başlangıç kontrolü,
kilitler ve geri alma sınırları korundu. İşlem **bir kez** çalıştı ve başarılı döndü.
Genel `db push` kullanılmadı; geçmiş migration veya kaynak dosyaları değişmedi.

## Bağımsız salt okunur doğrulama

**10 kontrol grubu PASS.** Kaynak/prova bağı 53 dosyada, inceleme paketi altı dosyada
tekrar doğrulandı. Bunlar yeni Flutter testleri değildir.

| Kontrol | Sonuç |
|---|---|
| Başlangıç yapısı | J7'nin beklediği `78f248b24aa67f7befcc7ccdb9ec97bd` ile tam eşleşme |
| Kurulum geçmişi | 14 eski kayıt ve SQL kaynak özeti aynı; tek yeni kayıtla toplam 15 |
| Yeni kayıt kaynağı | Onaylı önerinin SHA-256 LF özeti ile aynı |
| Public tablolar | 35 → 36; tamamında RLS açık |
| Yeni yardımcı işlevler | anon/authenticated/service_role çalıştırma izni yok |
| Yeni kayıt tablosu | RLS açık; 3 rol × 8 tablo izni kapalı |
| İş verisi | İzlenen 12 tablonun satır sayıları ve tam satır özetleri aynı |
| Kategoriler | 1.563 satır değişmedi; taksonomi özeti aynı |
| Ürün / başvuru / satış listesi / yayın paketi | Her biri 0; hiçbir gerçek ürün yayımlanmadı |
| Genel ürün onay anahtarı | Kapalı |

Profil, dükkân ve bildirim tabloları da boş kaldı. Giriş ayarları ekranındaki
Site URL ve dört callback önceki C kaydıyla aynıydı; bunlar yeniden kaydedilmedi.
Auth kullanıcı içerikleri/anahtarları okunmadı; hesap veya e-posta işlemi yapılmadı.

### Satır sonu farkı ve sonraki hazırlık sınırı

Ham sunucu şeması: `d9607df877e9115eb811d984e561b4e7`.
Yerel prova şeması: `590f31a8d4e3485d6b23434e17bd9d40`.

İlk ham karşılaştırma eşleşmedi. Salt okunur tanı, editörün **yalnız üç yeni işlevin
gövdesinde CRLF satır sonları** sakladığını gösterdi. Yalnız bu üç tanımın özeti LF
üzerinden hesaplandığında **bütün şema** yerel provayla tam eşleşti. Eski işlevler,
izinler, tetikleyiciler ve diğer şema bileşenleri normalleştirilmedi. Kalıcı
işlevler değiştirilmedi ve kurulum yeniden çalıştırılmadı. Ham ve LF özetleri
kanıt dosyasında ayrı tutulur; ham eşitlik sağlanmış gibi raporlanmaz.

**J7'nin eski üretilmiş doğrulama sorgusu ve hazırlık araçları ham LF prova
özetini bekler.** Bu sunucuyu henüz kabul etmemeleri güvenli davranıştır.
Gerçek kategori/hesap/yayın planından önce, mevcut post-A prova örüntüsünde bu
üç işlevin tam gözlenmiş biçimini yerelde yeniden üreten ve tüm yapı/izinleri
kanıtlayan bir hazırlık uyarlaması tamamlanmalıdır. Eski kanıtın özetini elle
değiştirme, genel normalleştirme ekleme veya korumaları gevşetme. Bu kurulumun
başarısı, sonraki veri hazırlık araçlarının hazır olduğu anlamına gelmez.

## Kanıt ve yeniden denetim

- [Kişisel veri içermeyen kurulum kaydı](data/merchant_pilot_test_catalog_installation.json)
  başlangıç/son gözlemlerini, kaynak/plan/gönderim özetlerini ve izinleri içerir.
- [Salt okunur doğrulama SQL'i](data/merchant_pilot_catalog_installation_verification.sql)
  **yalnız aynı Development hedefinde** kullanılabilir. İlk sonuç ham şema/veri
  özetidir, ikinci sonuç üç yeni işlevin sınırlı satır sonu karşılaştırmasıdır.
  İki bölüm de `BEGIN READ ONLY` ve `ROLLBACK` kullanır.
- [J7 yerel prova ve kurulum kaynağı](MERCHANT_PILOT_CATALOG_PUBLICATION_HANDOFF.md)
  tarihsel kanıttır; dosyaları veya 53 kaynak parmak izi yeniden yazılmadı.

Öneri kaynağı SHA-256 LF:
`f3f2ed01ee2222c6835bfc296a41eb090972372cd3d30e2837c5e0cd8dded182`.
Plan SHA-256:
`8282368cb50babbb726545dd4603aca146e25bfabe047f0ec62bc05d6ce46e5c`.
İşlem içi belirteç eklenmiş gönderim SHA-256 LF:
`8f0cf2900bea576888430431bff847071354d2ece841ca5b483165f91eca2e65`.

## Integration ve kalan işler

Bu dal belge, arındırılmış gözlem ve salt okunur SQL içerir. Uygulama kodu,
dependency, routing, bootstrap, global config veya migration zinciri değişmedi.
Flutter testleri/analyzer/derlemeler bu belgeler için tekrar çalıştırılmadı.
J7'nin Integration sonucundaki 2.970 PASS ve derleme/analyzer başarısı tarihsel
kanıttır; bu görevin yeni test sonucu olarak sunulmaz. Main merge yalnız
Integration Agent'a aittir. **Entegrasyon sırasında kurulumu tekrar çalıştırma.**

Sonraki yerel iş, yukarıdaki sunucu biçimiyle hazırlık araçlarını eşleştirmektir.
Gerçek esnaf/ürünler seçildiğinde kategori, hesap ve her yayın paketinin tam
listesi ayrı onaya sunulur. Uyumlu Customer/Merchant sürüm çifti, gerçek e-posta ve
provider kurulumu, imzalı dağıtım, fiziksel iki cihazlı QR ve pilot açılış kabulü
açıktır. Bu görev için kullanıcıya bırakılan ek manuel kontrol yoktur.
