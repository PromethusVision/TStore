# Mevcut Resend / DNS / Development SMTP incelemesi

Tarih: 18 Ekim 2026, yaklaşık 22:33 İstanbul. Salt okunur inceleme.
Yeni hesap, servis, alan adı, anahtar, DNS kaydı, e-posta veya kullanıcı oluşturulmadı.
Supabase Production projesine erişilmedi. Anahtar değeri açılmadı/kopyalanmadı;
istemciye, dosyaya veya Git'e alınmadı. Aşağıdaki kayıt yalnız gizli olmayan ayar
durumlarını içerir. Bu rapor hiçbir ayar değişikliğine yetki vermez.

## Sonuç

**Mevcut Resend hizmeti var ve alan adı doğrulanmış. Eksik görünen bağlantı
Development test projesindedir. Yeni hizmet veya hesap kurulmasına gerek yok.**

Kullanıcının önceki “yalnız domain tescili” yanıtı sonraki açık düzeltmesiyle
geçersizdir. Mevcut gönderen `noreply@auth.esnaftavar.com` korunacak. Depodaki
[geçmiş kabul kaydı](PRODUCTION_AUTH_EMAIL_PRECHECK.md), 22 Ağustos'ta Production
Customer uygulamasında doğrulama/kurtarma teslimatını ve fiziksel kabulü kaydeder.
Bu tarihsel kayıt bugün Production'ın yeniden test edildiği anlamına gelmez.

## Doğrudan gözlenen durum

| Alan | Bulgu | Değerlendirme |
|---|---|---|
| Resend domain | `auth.esnaftavar.com`: **Verified**, gönderim ON | Yeniden ekleme gerekmez |
| Bölge | Tokyo / `ap-northeast-1` | Mevcut kayıt; değiştirilmedi |
| DKIM | Resend ekranında Verified; public DNS kaydı mevcut ve eşleşiyor | Eksik kayıt saptanmadı; public anahtar değeri rapora alınmadı |
| SPF | `send.auth.esnaftavar.com`, `v=spf1 include:amazonses.com ~all`; Verified | Mevcut |
| Return-path MX | `feedback-smtp.ap-northeast-1.amazonses.com`, öncelik 10; Verified | Mevcut |
| DMARC | Alt alan kaydı yok; kök `_dmarc.esnaftavar.com`: `v=DMARC1; p=none;` | Kök politika alt alan için de geçerli; “DMARC tamamen yok” denemez. Sıkı engelleme/raporlama yok |
| TLS | Resend: Opportunistic | SMTP istemci bağlantısının TLS ayarından ayrı, alıcı sunucuya teslim politikasıdır |
| Takip | Configuration, yeni takip alt alanı kurulumuna yönlendiriyor | Mevcut özel takip alt alanı görünmedi. Yeni formdaki seçili click tracking kutusu kaydedilmiş ayar değildir; oluşturulmadı |
| API key metadata | Tek kayıt: `EsnaftaVar Production SMTP`, **Sending access**, son kullanım yaklaşık 2 ay önce | Değer okunmadı; kayıt yaşı süre dolması kanıtı değildir. SMTP giriş geçerliliği denenmedi |
| Yakın gönderimler | Varsayılan son 15 gün listesinde kayıt yok | Eski başarılı gönderimlerin yokluğu/başarısızlığı çıkarılamaz; yeni ileti gönderilmedi |
| Development custom SMTP | **OFF** | Bu proje şu anda mevcut Resend SMTP'sine bağlı görünmüyor |
| Development email provider | ON; Confirm email **OFF** | Yeni kayıt için e-posta doğrulaması zorunlu değil; açılması ayrı ortak ürün/ayar değişikliğidir |
| Development Auth hooks | Boş | Alternatif Send Email hook yolu gözlenmedi |
| Site URL | `http://localhost:3000` | Eksik/uyuşmayan redirect için telefonda işe yaramayan varsayılan dönüş; geçerli dört mobil callback korunuyor |
| Callback allowlist | Önceki C kalemindeki dört exact Customer/Merchant adresi mevcut | Değişiklik gerekmiyor |
| OTP süresi | 3600 saniye | Bağlantı ömrü; hizmet/anahtar abonelik bitişi değildir |
| Minimum e-posta aralığı | 60 saniye; SMTP kapalıyken alan disabled | Yerel hızlı test ayarları buraya taşınmamalı |
| Saatlik e-posta limiti | Dashboard alanı disabled; değer gözlem aracında gizlendi | Sayısal değer bağımsız doğrulanmadı; doküman varsayılanı mevcut ayar gibi sunulmaz |

DNS TTL 3600 saniye önbellek süresidir; “domain/anahtar süresi dolmuş” anlamına
gelmez. Görülen kayıtlarda süresi dolmuş bir yapılandırma kanıtı bulunmadı. Domain
tescil bitiş tarihi veya SMTP kimlik doğrulaması bu incelemede doğrulanmadı.

## Önerilen sonraki adım ve yetki sınırı

1. **Development'a mevcut Resend hizmetinin bağlanması:** ayrı onaydan sonra yalnız
   `tnipyxnvhgelwdpykyez` hedefi. İncelenecek değerler `smtp.resend.com`, TLS/465,
   kullanıcı `resend`, gönderen adı EsnaftaVar ve
   `noreply@auth.esnaftavar.com`. Parola/anahtar alanını Product Owner güvenli
   Supabase ekranında kendisi doldurur. Mevcut Production adlı anahtarı ajan
   çıkarmaz, kopyalamaz veya değiştirmez. Teste ayrı dar yetkili anahtar ayrılması
   bir öneridir; bu inceleme onu oluşturma yetkisi değildir.
2. **Doğrulama/şablon/fallback kararı:** her biri ayrı açık kapsam olmalı. J11'in
   Türkçe confirmation/recovery şablonları yalnız adaydır. Confirm email açılması
   her iki uygulamanın yeni kayıt davranışını değiştirir; SMTP bağlantısı onayına
   kendiliğinden dahil edilmez. Yeni web sitesi varmış gibi `esnaftavar.com` Site
   URL yapılmaz. İki uygulama için geçerli mevcut exact redirect'ler korunur.
3. **Kontrollü gerçek teslimat:** onaylı test alıcısı/hesabı ve iki uygulama ile
   az sayıda gerçek confirmation/recovery e-postası; teslimat, bağlantı,
   yanlış/eskimiş bağlantı ve yeni parola ile giriş kabulü. Şu an yapılmadı.

DMARC raporlama/sıkı politika ve enforced TLS ayrıca değerlendirilebilir. Aynı
Resend alan adı Production tarafından kullanıldığından DNS/TLS/tracking değişimi
“yalnız test projesi” onayına sığmaz. Mevcut çalışan gönderimi bozabilecek ani
`p=reject` veya TLS değişikliği önerilmez; önce teslimat/uyumluluk kanıtı gerekir.
Yeni sağlayıcı, ikinci hesap, anahtar rotasyonu veya domain yeniden doğrulaması
gerektiğine dair bir bulgu yoktur.

## Kaynaklar ve doğrulama sınırı

- Auth Dashboard: Development SMTP, Providers/Email, URL Configuration, Hooks,
  Rate Limits ekranları; yalnız navigasyon/okuma.
- Resend: Domains/Records/Configuration, yeni tracking formunun boş durumu,
  API keys metadata tablosu ve son 15 gün Emails görünümü; hiçbir form kaydedilmedi.
- Public DNS: DKIM/SPF/MX/DMARC sorguları; registrar paneline giriş veya DNS yazımı yok.
- [Resend SMTP ayarları](https://resend.com/docs/send-with-smtp): resmi host,
  kullanıcı ve TLS portu; API anahtarı yalnız sunucu SMTP parolası olarak kullanılır.
- [Resend API key yönetimi](https://resend.com/docs/dashboard/api-keys/introduction):
  metadata ile secret değeri ayrıdır; gönderim kapsamı ve son kullanım bilgisi.
- [Resend DMARC rehberi](https://resend.com/docs/dashboard/domains/dmarc):
  sıkılaştırmadan önce gerçek teslimat ve raporlama doğrulanır.
- [Supabase SMTP sınırları](https://supabase.com/docs/guides/auth/auth-smtp):
  varsayılan gönderici gerçek pilot için yeterli teslimat altyapısı değildir.

Sonuç: **READ-ONLY AUDIT COMPLETE / DEVELOPMENT EMAIL ACCEPTANCE OPEN**.
