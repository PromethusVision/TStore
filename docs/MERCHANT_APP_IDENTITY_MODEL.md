# Merchant App Identity Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 17 / WP05

## Entities

| Entity | Meaning | Does not mean |
|---|---|---|
| AUTH_USER | Kimliği doğrulanmış insan hesabı | Merchant yetkisi veya shop sahipliği |
| MERCHANT_ORGANIZATION | Ticari/operasyonel üst sınır | Tek başına customer-visible mağaza |
| SHOP | Müşteriye görünen işletme birimi | Her zaman fiziksel branch ile eş olmak zorunda değil |
| BRANCH | Fiziksel operasyon/konum birimi | Canonical product veya ayrı auth user |
| MERCHANT_USER | Auth user'ın organizasyon üyeliği | Global app role |
| ROLE/CAPABILITY | Belirli org/shop operasyonuna izin | UI'da sekmenin görünmesiyle kazanılan yetki |

## Recommended relationship

```text
AUTH_USER
  -> MERCHANT_MEMBERSHIP -> MERCHANT_ORGANIZATION
                              -> SHOP
                                  -> BRANCH/LOCATION
                                  -> SHOP_LISTING
```

- Bir auth user birden çok organization üyeliğine ileride sahip olabilir; V1 bunun UI'sını sınırlayabilir.
- Membership role/capability org ve gerektiğinde shop scope taşır.
- Shop ownership müşteri profilindeki `role` metniyle çıkarılmaz.
- Merchant sector sınıflandırması kimlik veya yetki vermez.
- QR confirmation yapan actor hem membership hem target shop capability ile server tarafında doğrulanır.

## Invariants

1. `auth user != merchant organization != shop`.
2. Client tarafından gönderilen owner/role iddiası authoritative değildir.
3. Her write actor, organization, shop/branch ve permission scope ile denetlenir.
4. Membership askıya alınırsa cached context write yetkisi vermez.
5. Organization/shop geçişinde state ve cache scope değiştirilir; önceki shop özel verisi gösterilmez.

## Open decisions

- `ID-01 P0`: V1 organizasyon tüzel/gerçek kişi doğrulama seviyesi.
- `ID-02 P0`: Bir kullanıcı birden çok organization yönetebilir mi?
- `ID-03 P1`: `SHOP` ve `BRANCH` pilotta ayrı entity mi, yoksa tek fiziksel shop modeliyle mi başlanır?
