# W51A — Owner için kalan girdi

**Production projesi ve uygulama kimliği belirli. Yeni ürün yönü kararı gerekmiyor.**
Bu görevde doğruladığınız `mefhfvrgkwciubeajjeb` projesi, Production URL ve mevcut
Android mobile callback sözleşmesi korunuyor.

Kalan tek Production yapılandırma onayı: bu projeye ait **güncel client-safe
publishable/anon anahtarın** aday için kullanılacağının doğrulanması. Onaylı altı
alanlı JSON güvenli repo-dışı dosyada sağlanmalı; anahtarı sohbete veya repo'ya
yazmayın. Eski artifact'taki anahtar otomatik olarak güncel onay sayılmadı.

İmzalama için ayrıca mevcut parola yöneticisi kaydının repo dışındaki properties
dosyasına yeniden bağlanması gerekiyor. Bu bir yeni anahtar/sertifika seçimi
değildir; mevcut upload key korunur. Yerel properties yolunu bulamadığınızı
bildirdiğiniz için bu girdi açık kaldı.

Girdiler tamamlandığında önce yerel imza ve config kontrolleri, ardından signed
adayın kimlik/hash denetimi yapılabilir. Production'a salt okunur erişim ve cihazda
kurulum/başlatma ayrı görev yetkisidir; bu paket bunları gerçekleştirmedi.

İmzalama adımları: [Signing envanteri](RELEASE_W51_SIGNING_CONFIG_INVENTORY.md).
Altı alan ve güvenli şablon: [Production sözleşmesi](RELEASE_W51_PRODUCTION_CONFIG_CONTRACT.md).
