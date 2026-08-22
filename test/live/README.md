# Live integration tests

Bu klasordeki testler explicit opt-in olmadan remote istek yapmaz. Normal
`flutter test` calismasinda live testler skip edilir ve gercek credential
degerleri repo disinda tutulur.

## Production read-only demo smoke

`production_readonly_integration_test.dart` ve
`production_demo_functional_smoke_test.dart` yalniz canonical EsnaftaVar
Production ref'ini kabul eder. Development ref'i ve diger tum URL'ler credential
kullanilmadan once reddedilir. Harness'lar anonymous katalog/Storage read
contract'iyla sinirlidir; Auth, database veya Storage mutation operasyonu
icermez.

Yerel ve Git tarafindan ignore edilen bir define dosyasinda su adlari kullanin:

```text
RUN_PRODUCTION_READONLY_SMOKE=true
RUN_PRODUCTION_DEMO_FUNCTIONAL_SMOKE=true
SUPABASE_PRODUCTION_URL=<canonical-production-url>
SUPABASE_PRODUCTION_ANON_KEY=<client-safe-publishable-key>
```

Ardindan hedefli testleri calistirin:

```text
flutter test --no-pub \
  test/live/production_readonly_integration_test.dart \
  test/live/production_demo_functional_smoke_test.dart \
  --dart-define-from-file=<git-ignored-define-file>
```

## Development live tests

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
