# Merchant Pilot QR Verifier Model

State: `PROPOSED — NON-NEGOTIABLE TRUST PATH`

## Yolculuk

`scan opaque token → server preview → merchant reviews exact shop/items/snapshot → explicit confirm → atomic consume → server result → local reconciliation`.

QR payload müşteri PII, fiyat veya yetki kararı taşımaz. Preview sunucudan gelir ve shop adı, ürün adları, adet, birim snapshot fiyatı, toplam, expiry ve status gibi minimum bağlamı gösterir.

## Sunucu invariantları

- Authenticated caller exact shop için aktif `QR_VERIFY` yetkisine sahip olmalıdır.
- QR active, unexpired, unused ve aynı shop'a bağlı olmalıdır.
- Listing/shop/policy eligibility confirm anında yeniden kontrol edilir.
- Snapshot immutable'dır; güncel fiyat geçmiş snapshot'ı değiştirmez.
- Consume ve verified transaction/item yazımı tek atomik transaction'dır.
- Bir QR için tek kazanan vardır; replay ve gerçek concurrent confirm reddedilir.
- Aynı idempotency intent belirsiz ağ sonucunu tekrar side effect üretmeden uzlaştırır.
- Customer veya yanlış shop merchant confirm edemez.

## Client davranışı

- Scan sırasında duplicate detection ve tek in-flight load.
- Confirm sırasında buton kilitli; çift tap ikinci RPC üretmez.
- App background olduğunda kamera durur; resume'da stale preview yeniden doğrulanır.
- Auth/shop değişirse preview iptal edilir.
- Timeout sonucu `FAILED` varsayılmaz; server status okunarak success/active/used/expired ayrıştırılır.
- Offline confirm yoktur; token queue edilmez. Bağlantı geldiğinde yeniden preview gerekir.
- Success ekranı payment/receipt/revenue iddiası içermez.

## History ve düzeltme

Merchant son işlemlerde time, item summary, total snapshot ve status görür; customer email/telefon gösterilmez. Düzeltme sessiz update/delete değildir: case + append-only correction/reversal evidence. Şüpheli işlem fraud review'e alınabilir; operator keyfi purchase yaratamaz.

## Fiziksel gate

Gerçek customer ve merchant cihazı, gerçek kamera, signed exact artifact, yavaş/ağ değişimi, background/resume, replay, wrong shop, expiry ve concurrent confirm görülmeden pilot QR gate PASS değildir.
