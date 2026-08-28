# Merchant App Multi-Shop Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP06

## Compared models

| Model | Strength | Risk |
|---|---|---|
| User owns one shop directly | En basit pilot | Şube ve personel büyümesinde veri modeli kırılır |
| Organization owns shops; user has membership | Güvenli büyüme ve yetki scope'u | Onboarding/authorization biraz daha fazla tasarım ister |
| Enterprise hierarchy | Bölge/marka/franchise esnekliği | V1 için gereksiz karmaşıklık |

## Recommendation

Veri/authorization kavramında `organization -> shops`, UX'te pilot için sade “Mağazam” yaklaşımı önerilir. Tek mağazalı merchant organization ayrıntısını görmeyebilir. Bu recommendation `OWNER_DECISION_REQUIRED` durumundadır.

## Operational rules

- Aktif shop context tüm listing, QR, metric ve staff işlemlerinde görünür.
- Canonical product paylaşılır; fiyat, availability, merchant SKU ve listing şubeye/mağazaya aittir.
- Bir listing'in diğer şubeye kopyalanması yeni branch-specific listing üretir; fiyat/availability otomatik ortaklaşmaz.
- Organization owner tüm shops'u görebilir; manager/staff yalnız explicit scope görür.
- Başka shop'a ait QR token yanlış shop olarak fail-closed olur.
- Shop switch yarım kalan formu sessizce başka shop'a taşımaz.

## V1 proposal

- Tek organization membership.
- Bir veya daha fazla shop teknik olarak desteklenebilir.
- Pilot UX önce tek aktif shop; shop switch yalnız çok-shop üyelikte.
- Bölge/franchise/department hierarchy deferred.

## Open decisions

- `SHOP-01 P0`: Pilot başlangıcında multi-shop activation var mı?
- `SHOP-02 P1`: Listing kopyalama V1 mi, sonra mı?
- `SHOP-03 P1`: Aynı organization altındaki mağazalarda staff inheritance var mı? Öneri: hayır, explicit scope.

