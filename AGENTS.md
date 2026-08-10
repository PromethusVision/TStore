# EsnaftaVar Proje Çalışma Kuralları

## 1. Doğru Çalışma Alanı ve Proje Sınırı

- Doğru ve yazılabilir repo: `E:\Esnaftavar\Esnaftavar_chatgpt\TStore_CLEAN`.
- Korunan eski repo: `E:\Esnaftavar\Esnaftavar_chatgpt\TStore`. Bu dizinde hiçbir işlem yapma ve hiçbir dosyaya dokunma.
- İşleme başlamadan önce gerçek çalışma dizininin ve Git kökünün doğru repo olduğunu doğrula.
- Mevcut EsnaftaVar mimarisine, ürün kararlarına ve görev kapsamına saygı göster; görevi ilgisiz modüllere genişletme.
- Kullanıcı yazılımcı olmayabilir. Teknik ayrıntıları ve rutin kod kararlarını kullanıcıya yükleme; mevcut durumu, kullanıcıya etkisini, riskleri ve gereken gerçek ürün kararlarını sade Türkçeyle anlat.
- Uzun terminal veya kod çıktılarını kullanıcıya aktarma; kısa ve anlaşılır sonuç özeti ver.

## 2. Görev Yetkisi ve Salt Okunur Çalışma

- Kullanıcı veya koordinatör tarafından verilen açık bir uygulama görevi, görevin rutin teknik adımlarını uçtan uca yürütmek için yeterli yetkidir.
- “Uygula”, “düzelt”, “tamamla”, “inşa et”, “refactor et”, “testleri ekle” ifadeleri veya doğrudan atanmış bir mühendislik hedefi uygulama yetkisi sayılır.
- Bu yetki; görev kapsamındaki dosya değişikliklerini, gerekli küçük/orta ölçekli refactor'ları, formatlamayı, analyzer/linter çalıştırmayı, mevcut testleri çalıştırmayı, hedefli test eklemeyi, test hatalarını düzeltmeyi, task branch/worktree oluşturmayı ve task branch üzerinde commit/push yapmayı kapsar. Bunlar için ayrıca kullanıcı onayı isteme.
- Kullanıcı açıkça “analiz et”, “incele”, “raporla” veya “değişiklik yapma” derse çalışma salt okunurdur. Dosya, branch, commit, remote, veritabanı veya dış sistem durumu değiştirilmez.
- Kullanıcının açık kapsam ve güvenlik sınırlamaları her zaman korunur.

## 3. Otonom Uçtan Uca Uygulama

Bir uygulama görevi verildiğinde:

1. İlgili mevcut mimariyi ve çalışma ağacını incele.
2. Görevin gerçek kapsamını belirle; gerektiğinde aynı problemin benzer tekrarlarını tara.
3. Tutarlı çözümü uygula.
4. Gerekli testleri ekle veya güncelle.
5. Analyzer ve ilgili statik kontrolleri çalıştır.
6. Başarısız kontrolleri görev kapsamında mümkün olduğunca düzelt ve kontrolleri yeniden çalıştır.
7. Son diff'i, beklenmeyen değişiklikleri ve görev kapsamını denetle.
8. Yalnız görev kapsamındaki ve bu agente ait değişiklikleri commit et.
9. Aşağıdaki branch modeline göre uygun remote branch'e push et.
10. Sonucu yapılandırılmış ve sade Türkçeyle raporla.

- Rutin ara aşamalarda kullanıcıdan onay isteme.
- Güvenli biçimde ilerlemek mümkünken görevi yarım bırakıp kullanıcıya rutin teknik adım devretme.

## 4. Tutarlı Mühendislik Görevi ve Mikro-Görev Yasağı

- Bir görev, dosya veya widget bazında gereksiz mikro-görevlere bölünmez; bir görev bir tutarlı mühendislik hedefidir.
- Aynı sorun görev kapsamındaki birden fazla yerde tekrarlanıyorsa ilgili kapsamı tara, ortak örüntüyü belirle, uygun noktalarda tutarlı çözüm uygula ve temsilî/gerekli testleri tamamla.
- “En küçük güvenli değişiklik” işi eksik bırakmak veya onlarca kullanıcı turuna bölmek anlamına gelmez.
- Buna karşılık görevi ilgisiz özelliklere, modüllere veya geniş mimari değişikliklere taşırma.

## 5. Multi-Agent ve Worktree Modeli

- EsnaftaVar paralel Codex agent'larıyla geliştirilebilir. Üretim agentları varsayılan olarak izole task worktree/branch üzerinde çalışır.
- Önceden yetkilendirilmiş bir üretim görevi için görevle ilişkili ve açık isimli yeni task branch/worktree oluşturmak ayrıca kullanıcı onayı gerektirmez. Mümkünse mevcut Codex worktree/thread mekanizmasını kullan.
- Üretim agentı doğrudan `origin/main` dalına push etmez; yalnız atanmış branch/worktree sınırında çalışır ve kendi task branch'ine push eder.
- Yalnız kendi görevine ait değişiklikleri commit eder. Başka agentların değişikliklerini sahiplenmez, commit kapsamına almaz, yeniden yazmaz veya sebepsiz değiştirmez.
- Başka agente ya da kullanıcıya ait beklenmeyen değişiklikleri silme, resetleme, revert etme veya ezme.
- Task branch'te commit/push rutin görev adımıdır; doğrulamalar başarılı ve kapsam temizse ayrıca onay isteme.

## 6. Ortak Dosya ve Çakışma Güvenliği

- Başka bir agentın aktif olarak değiştirdiği aynı dosya veya ortak mimari alanla çakışma tespit edilirse değişikliği körlemesine ezme.
- Özellikle routing/navigation, global provider/state, `pubspec.yaml` ve lockfile, ortak theme/design-system, Supabase migration zinciri, ortak schema/model, app bootstrap/main, global config ve feature merkezi servislerinde dikkatli ol.
- Görev bu alanlardan birine zorunlu olarak dokunuyorsa sonuç raporunda açıkça belirt.
- Beklenmeyen değişiklikleri güvenli biçimde ayırmak mümkün değilse commit/push yapma. Gerçek merge/conflict riski güvenli biçimde çözülemiyorsa dur ve raporla.

## 7. Integration/Release Agentı

- `origin/main` üzerinde entegrasyon yapma ve doğrudan push yetkisi varsayılan olarak yalnız açıkça integration/release görevi verilen agente aittir.
- Integration/release agentı tamamlanan task branch/worktree sonuçlarını inceler, güvenli birleşim sırasını belirler ve mevcut Git durumuna göre merge veya cherry-pick yöntemini seçer.
- Conflictleri yalnız anlamı açık ve doğrulanabilir olduğunda çözer; başka agentların kodunu sebepsiz yeniden yazmaz.
- Birleşik diff'i inceler, `flutter analyze --no-pub` ve ilgili testleri çalıştırır; risk gerektiriyorsa tam test paketini çalıştırır.
- Birleşik durum başarıyla doğrulanırsa `origin/main` dalına normal push yapabilir.
- Force push, destructive rebase veya başka bir history rewrite otomatik yapılmaz.

## 8. Commit ve Push Politikası

- Normal üretim görevi, tek agentla yürütülse bile varsayılan olarak task branch/worktree üzerinde tamamlanır. Testler ve analyzer başarılı, diff görev kapsamında ve beklenmeyen değişiklik yoksa commit ve task branch'e push otomatik yapılabilir.
- Multi-agent üretim agentı yalnız kendi task branch'ine commit/push yapabilir; `origin/main` dalına doğrudan push yapamaz.
- Integration/release agentı başarılı bütünleşik doğrulamadan sonra `origin/main` dalına commit/push yapabilir.
- Test veya analyzer başarısızsa, unresolved conflict varsa, beklenmeyen/ilgisiz dosya bulunuyorsa, değişikliğin güvenliği doğrulanamıyorsa ya da kullanıcı verisi/production güvenliği riski varsa otomatik commit/push yapma.
- Commit kapsamını açıkça kontrol et; çalışma ağacındaki başka görev veya kullanıcı değişikliklerini commit'e katma.
- Commit/push sonrasında commit kimliğini, branch'i, push sonucunu, geçen kontrolleri ve çalışma ağacı durumunu raporla.

## 9. Kullanıcıya Ne Zaman Sorulur

Yalnız aşağıdaki yüksek riskli durumlarda kullanıcı onayı veya gerçek ürün kararı iste:

- Geri dönüşü zor veya destructive veritabanı işlemi.
- Production/canlı veriyi silme ya da toplu değiştirme.
- Gizli anahtar, credential, parola veya secret gerektiren işlem ve `.env`/secret yönetimi.
- Ödeme, billing veya finansal akışta kritik değişiklik.
- Güvenlik izinlerinde kritik değişiklik.
- Büyük framework/dependency değişimi, major version upgrade veya geniş mimari refactor.
- Geri dönüşü zor migration.
- Açıkça korunmuş bir mimari kararın değiştirilmesi.
- Ürün davranışını maddi biçimde değiştiren ve mevcut kod/dokümandan çözülemeyen gerçek ürün belirsizliği.
- Force push, history rewrite veya güvenli biçimde çözülemeyen merge conflict.

- Teknik ayrıntılar, dosya seçimleri ve rutin kod kararları mümkün olduğunca kullanıcıya yüklenmez.
- Test hesabı veya parola gerekiyorsa parolayı sohbet içinde isteme; güvenli giriş ekranını aç ve kullanıcının kendisinin girmesini bekle.

## 10. Veritabanı ve Migration Güvenliği

- Yeni migration dosyası hazırlamak ile migration'ı canlı/production veritabanına uygulamak birbirinden ayrıdır.
- Görev açıkça migration geliştirmeyi gerektiriyorsa güvenli migration dosyası oluşturulabilir ve local/test ortamında doğrulanabilir.
- Canlı/production migration uygulaması yalnız görevin bunu açıkça yetkilendirmesiyle yapılır. Veri kaybı, toplu veri değişikliği veya geri dönüşü zor operasyon riski varsa ayrıca kullanıcı onayı olmadan çalıştırma.
- Test amacıyla canlı veriyi silme veya kalıcı riskli biçimde değiştirme.
- Mevcut migration zincirini, sıra bütünlüğünü ve daha önce uygulanmış migration'ları koru; geçmişi yeniden yazma.

## 11. Dependency Politikası

- Mevcut dependency'lerin rutin ve düşük riskli kullanımı onay gerektirmez.
- Görev için gerekli, küçük, iyi gerekçelendirilmiş ve düşük riskli yeni dependency görev kapsamında eklenebilir; gerekçesini ve etkisini sonuçta raporla.
- Büyük framework değişimi, major version upgrade veya mimari bağımlılık değişimi kullanıcı onayı gerektirir.
- `pubspec.yaml` ve lockfile ortak/çakışma riski taşıyan alanlardır; başka agent değişikliklerini ezme.

## 12. Test ve Doğrulama Politikası

- Kod değişikliğinden sonra kapsamla orantılı otomatik doğrulama zorunludur.
- İlgili unit, widget ve integration testlerini; Flutter/Dart değişikliklerinde `flutter analyze --no-pub` veya proje için geçerli statik kontrolleri çalıştır.
- Kritik davranış yeterince test edilmiyorsa hedefli test ekle. Başarısız kontrolleri görev kapsamında düzelt ve yeniden çalıştır.
- UI değişikliği yoksa Chrome başlatmak, ekran görüntüsü almak veya manuel görsel kabul zorunlu değildir.
- UI/UX değişikliği varsa ilgili render, navigation ve state davranışını mümkün olduğunca otomatik widget/golden/screenshot yöntemleriyle ve erişim varsa Browser/Computer Use üzerinden doğrula.
- Uygun olduğunda loading, empty, error, success, navigation, validation, duplicate-submit/double-tap ve offline/slow-network durumlarını kontrol et.
- Browser console ve ilgili terminal çıktılarında hata olup olmadığını denetle.
- Yalnız öznel görsel değerlendirme, gerçek cihaz donanımı, kamera, GPS, bildirim, platform izinleri, canlı veritabanında riskli işlem veya nihai ürün kabulü gibi otomatik doğrulanamayan kontrolleri kullanıcıya bırak.
- Kullanıcıya bırakılan manuel kontrolleri yalnız gerçekten gerekli olan en fazla 1–3 kritik maddeyle sınırla.

## 13. Proje Durumu ve Paralel Çalışma Dokümanları

- `docs/PROJECT_STATE.md`, `docs/PARALLEL_WORK_MAP.md` ve `docs/PRODUCT_BACKLOG.md` gibi merkezi koordinasyon dosyaları kullanılabilir.
- Üretim agentları bu dosyaları kendi başlarına geniş çapta yeniden yazmaz.
- Bu dosyaların merkezi güncellemesi analiz/koordinasyon görevi verilen agent veya integration/release agentı tarafından yapılır.

## 14. Görev Sonuç Raporu

Her üretim agentı görevin sonunda şu yapıda kısa ve anlaşılır rapor verir:

```text
TASK_RESULT

Görev:
- ...

Tamamlanan:
- ...

Ana değiştirilen alanlar:
- ...

Yeni/önemli mimari kararlar:
- ...

Testler:
- ...

Analyzer:
- ...

Commit:
- ...

Branch:
- ...

Push:
- ...

Ortak/çakışma riski olan alanlar:
- ...

Kalan veya bloke iş:
- ...

Manuel kontrol gerekiyorsa:
- Yalnız gerçekten gerekli maddeler
```

- Sonuç raporunda başarısız kontrolleri veya doğrulanamayan riskleri gizleme.
