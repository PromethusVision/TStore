# Development live tests

Bu klasordeki testler gercek EsnaftaVar Development Supabase projesine baglanir.
Normal `flutter test` calismalarinda remote istek yapmazlar; test grubu varsayilan
olarak skip edilir.

Yalniz `tnipyxnvhgelwdpykyez` Development projesi icin yerel ve Git tarafindan
ignore edilen `.env` dosyasina su Dart define adlarini koyun:

```text
ESNAFTAVAR_RUN_DEVELOPMENT_LIVE_TESTS=true
SUPABASE_DEVELOPMENT_URL=<development-project-url>
SUPABASE_DEVELOPMENT_ANON_KEY=<development-anon-or-publishable-key>
```

Ardindan hedefli testi calistirin:

```text
flutter test test/live/development_realtime_integration_test.dart --dart-define-from-file=.env
```

Test, signup'tan once Auth settings endpoint'ini salt okunur denetler. E-posta
autoconfirm kapaliysa oturum acamayan ve istemci tarafindan temizlenemeyen test
hesabi birakmamak icin `AUTH_BLOCKER` ile durur. Uygun ortamda iki `w4a3_`
musteri hesabi olusturur, yalniz bu hesaplara ait chat ve notification verisini
kullanir ve sonunda iki hesabi uygulamanin mevcut hesap silme RPC'siyle
temizler. URL ref kontrolu credential kullanilmadan once yapilir; Production
URL'si veya baska bir Supabase projesi kabul edilmez.
