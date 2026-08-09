# Proje Çalışma Kuralları

## Teknik Bilgisi Olmayan Ürün Sahibiyle Çalışma

- Kullanıcı yazılımcı değildir; ürün fikirlerini günlük dille anlatır.
- Kullanıcıdan teknik analiz yapması, dosya adı, mimari, veritabanı yapısı, test komutu veya başka bir yazılım terimi kullanması beklenmez.
- Kullanıcı yeni bir fikir söylediğinde ve “önce analiz et” dediğinde kodu değiştirmeden mevcut uygulamayı incele.
- İlgili ekranları, kodu, veri yapısını, riskleri ve en küçük güvenli ilk sürümü kendin belirle.
- Teknik kararları mevcut mimariye göre kendin ver.
- Kullanıcıya yalnızca sade Türkçeyle mevcut durumu, önerilen çözümü, kullanıcıya etkisini, riskleri ve gereken ürün kararlarını anlat.
- Yalnızca gerçek bir ürün kararı gerekiyorsa soru sor; teknik kararları kullanıcıya yükleme.
- Kullanıcı “uygula” demeden kodu değiştirme.
- Kullanıcı “uygula ve test et” dediğinde güvenli geliştirme adımlarını, biçimlendirmeyi, analizi ve testleri kendin yürüt.
- SQL, migration, `.env`, dependency, büyük refactor, kritik akış, commit, push veya merge gerektiğinde önce ne yapılacağını ve riskini sade Türkçeyle anlatıp kullanıcıdan onay iste.
- Uzun terminal ve kod çıktılarını gösterme; yalnızca sonuç özeti ver.
- Görev tamamlandığında sıradaki en küçük güvenli işi öner.

## Güvenli Çalışmalarda Otomatik Commit ve Push

- Yukarıdaki commit ve push onayı kuralının istisnası olarak; küçük, güvenli ve geri alınabilir bir müşteri uygulaması çalışması tamamlandığında, bütün ilgili otomatik testler geçtiğinde, manuel ürün veya görsel kabulü gerekmediğinde ve çalışma ağacında ilgisiz dosya bulunmadığında kullanıcıdan yeniden onay istemeden commit oluştur ve mevcut onaylı `origin/main` dalına push et.
- Kullanıcı manuel kontrolün başarılı olduğunu bildirdiyse ve başka bir engel yoksa aynı otomatik commit ve push yetkisi geçerlidir.
- Görsel veya nihai kullanıcı kabulü bekleniyorsa, testlerden biri başarısızsa, beklenmeyen ya da ilgisiz dosya varsa, Git çakışması oluşursa veya çalışma SQL, migration, `.env`, dependency, büyük refactor, kritik akış, veri kaybı riski ya da geri dönüşü zor bir işlem içeriyorsa otomatik commit veya push yapma; durumu sade Türkçeyle anlat ve kullanıcıdan onay iste.
- Otomatik push yetkisi yalnızca mevcut onaylı `origin/main` akışı içindir. Yeni branch, merge, pull request, force push, rebase veya geçmiş değiştiren Git işlemleri için ayrıca onay iste.
- Commit ve push sonrasında commit kimliğini, hedef dalı, geçen testleri ve çalışma ağacının temiz olup olmadığını kısa bir sonuç özetiyle bildir.

## Kodlama Sonrası Otomatik Doğrulama

- Kodlama tamamlandığında kullanıcıyı doğrudan manuel kontrol listesine yönlendirme; önce mümkün olan bütün kontrolleri kendin gerçekleştir.
- Değişen dosyalarda `flutter analyze --no-pub` çalıştır.
- Mevcut ilgili unit, widget ve integration testlerini çalıştır.
- Değişen akışın yeterli testi yoksa hedefli test oluştur ve çalıştır.
- Flutter uygulamasını Chrome üzerinde başlat.
- Codex masaüstü Browser veya Computer Use erişimi varsa ilgili kullanıcı akışını görsel olarak kendin çalıştır.
- Loading, empty, error ve success durumlarını kontrol et.
- Navigation, form validation ve double-submit davranışını doğrula.
- Browser console ve terminal çıktısında hata olup olmadığını kontrol et.
- Kritik ekranların ekran görüntüsünü al ve sonucu raporla.
- Test sırasında canlı veriyi silme veya kalıcı riskli değişiklik yapma.
- Test hesabı veya parola gerekiyorsa parolayı sohbet içinde isteme; güvenli giriş ekranını aç ve kullanıcının kendisinin girmesini bekle.
- Yalnızca öznel görsel değerlendirme, gerçek telefon donanımı, kamera, GPS, bildirim ve platform izinleri, canlı veritabanında riskli işlem veya nihai kullanıcı kabulü gibi Codex tarafından doğrulanamayan kontrolleri kullanıcıya bırak.
- Kullanıcıya bırakılan manuel kontrolleri en fazla 1–3 kritik maddeyle sınırla.
- Sonuç raporunda otomatik geçen testleri, başarısız testleri, Browser üzerinden doğrulanan akışları, ekran görüntüsü alınan durumları ve kullanıcıya bırakılan kritik kontrolleri ayrı ayrı belirt.
