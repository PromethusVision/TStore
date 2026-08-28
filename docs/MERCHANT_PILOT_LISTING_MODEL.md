# Merchant Pilot Listing and Catalog Model

State: `PROPOSED — LISTING TRUTH MINIMUM`

## Katmanlar

- Canonical product: ortak ürün kimliği; merchant sahibi değildir.
- Variant: boyut/renk/ölçü gibi kimlik farklılığı; doğrulanmış catalog katmanı.
- Shop listing: merchant'ın shop-specific price, availability ve freshness beyanı.
- Candidate: canonical eşleşme bulunamadığında incelemeye sunulan kayıt; otomatik satışa açılmaz.

## Pilot listing alanları

MUST read: listing ID, shop ID, product/variant ID ve adı, price, availability state, active/policy state, `updated_at`, `last_verified_at`, review/candidate warning.

MUST write: nonnegative price, `AVAILABLE | OUT_OF_STOCK | UNKNOWN | TEMPORARILY_UNAVAILABLE`, active/deactivate ve freshness acknowledgement. `UNKNOWN`, yanlış biçimde `OUT_OF_STOCK` veya available sayılmaz.

Optional later: merchant SKU, quantity, promo price, media, tags ve bulk metadata.

## Yazma sözleşmesi

- Mutation exact listing + exact shop + expected revision/idempotency key içerir.
- Server owner/capability/policy ve value invariantlarını tekrar doğrular.
- Concurrent edit stale revision ile reddedilir; last-write-wins sessizce kullanılmaz.
- Her değişiklik actor, before/after, source (`MERCHANT_SELF_SERVICE | ASSISTED_ONBOARDING | CATALOG_REVIEW`), time ve correlation ile audit edilir.
- Public projection yalnız eligible/active listingleri gösterir; stale availability politikasına göre `UNKNOWN` olabilir.

## Existing-first akış

1. Barcode/name ile canonical arama.
2. Doğru product/variant seçimi ve özet doğrulama.
3. Shop listing oluşturma veya mevcut listingi güncelleme.
4. Eşleşme yoksa sınırlı candidate formu.
5. Candidate `PENDING_REVIEW`; merchant ürün gerçeği uyduramaz, otomatik publish yoktur.

## Assisted bootstrap

Operatör kaynak belge/foto/barcode ile başlangıç listingi hazırlayabilir; merchant açık batch attestation verir. Spreadsheet authority değildir, Production'a doğrudan import yoktur, hatalı eşleşme correction case açar. Merchant ilk girişte yüksek-riskli veya eski kayıtları doğrular.

## Freshness

Fiyat ve uygunluk ayrı ayrı doğrulanabilir. Freshness süresi owner kararıdır; sistem süresi geçmiş beyanı doğruymuş gibi parlatmamalı, notification üretmeli ve gerekirse availability'yi bilinmeyene indirmelidir.
