# Merchant App Role Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP07

## Principle

Roller kullanıcıya görev şablonu sunar; authorization nihai olarak server-side capability + organization/shop scope ile yapılır.

## Candidate roles

| Role | Intended use | Default capabilities |
|---|---|---|
| OWNER | İşletme sahibi | Shop, listing, QR, analytics, staff; yüksek riskli işler |
| MANAGER | Mağaza yöneticisi | Shop operasyonu, listing, QR, analytics; owner transferi yok |
| STAFF | Genel operasyon personeli | Atanan katalog/QR görevleri; staff management yok |
| QR_VERIFIER | Kasiyer/doğrulayıcı | QR scan/confirm ve kendi sonuç geçmişi |
| CATALOG_EDITOR | Katalog görevlisi | Listing, fiyat ve availability; QR/staff yok |

## Minimal V1 recommendation

- Kullanıcıya iki ana şablon göster: `OWNER` ve `STAFF`.
- STAFF oluşturulurken hazır görev presetleri: “QR doğrulama”, “Katalog düzenleme” veya ikisi.
- `MANAGER` ancak multi-staff pilot ihtiyacı doğrulanırsa etkinleştirilsin.
- Backend capability isimleri role adından bağımsız, versioned ve deny-by-default olsun.

Bu sadeleştirme owner onayı bekler; candidate role listesi final değildir.

## Escalation rules

- Kullanıcı kendi role/capability veya shop scope'unu değiştiremez.
- Son owner kaldırılamaz; ownership transfer ayrı güçlü doğrulama ister.
- Membership disable/revoke mevcut token yeniden doğrulamasında etkili olmalıdır.
- UI'da gizli buton authorization kontrolü yerine geçmez.

## Open decisions

- `ROLE-01 P0`: V1 staff yönetimi açılacak mı?
- `ROLE-02 P1`: Manager ayrı rol mü, owner tarafından seçilen capability seti mi?
- `ROLE-03 P1`: Personel daveti hangi doğrulama/expiry akışını kullanır?
