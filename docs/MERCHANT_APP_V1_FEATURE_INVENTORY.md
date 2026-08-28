# Merchant App V1 Feature Inventory

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP02

Bu envanter 31 capability tanımlar: 16 `MUST_HAVE_V1`, 7 `SHOULD_HAVE`, 5 `DEFER`, 3 `FUTURE_ENGINE`.

## MUST_HAVE_V1 — 16

| ID | Capability | V1 outcome |
|---|---|---|
| V1-01 | Secure auth/session | Güvenli giriş, çıkış ve session yenileme |
| V1-02 | Merchant organization/shop identity | Kullanıcı, organizasyon ve mağaza ilişkisi ayrılır |
| V1-03 | Active shop context | İşlem yapılacak mağaza açıkça seçilir |
| V1-04 | Server-side authorization | Rol gizleme değil gerçek yetki kontrolü |
| V1-05 | Guided onboarding | Kimlik, mağaza, sektör, konum ve gerekli doğrulama |
| V1-06 | Shop profile/location/status | Müşteriye görünen temel mağaza gerçeği yönetilir |
| V1-07 | Canonical catalog search | Var olan ürün/variant önce bulunur |
| V1-08 | Listing create/edit | Seçilen ürün için mağaza teklifi yönetilir |
| V1-09 | Price editing | Doğrulanan, zaman damgalı mağaza fiyatı |
| V1-10 | Availability semantics | In stock/out/unknown/temporary state |
| V1-11 | Missing/custom product candidate | İnceleme kuyruğuna idempotent aday gönderimi |
| V1-12 | Barcode-assisted find | Barkod arama sinyali; kör identity yaratmaz |
| V1-13 | QR scan and confirm | Kamera, doğrulama özeti, server sonucu |
| V1-14 | QR failure/reconciliation | Expiry, wrong shop, replay, timeout ve belirsiz sonuç |
| V1-15 | Security/audit activity | Kritik değişikliklerde actor, scope ve sonuç |
| V1-16 | Critical notifications | Politika, QR ve katalog sonucu gibi eylem gerektiren olaylar |

## SHOULD_HAVE — 7

| ID | Capability | Boundary |
|---|---|---|
| V1-17 | Operational dashboard | Vanity yerine eyleme dönük özet |
| V1-18 | Basic analytics | Doğrulanmış satın alma, görünüm, yön tarifi, listing sağlığı |
| V1-19 | Review read view | Merchant müşteri yorumunu değiştiremez/silemez |
| V1-20 | Listing health filters | Eksik fiyat, bilinmeyen availability ve inceleme durumu |
| V1-21 | Bulk availability | Aynı shop scope'unda güvenli çoklu güncelleme |
| V1-22 | Minimal staff management | Davet/iptal ve güvenli görev şablonları |
| V1-23 | Read cache and recovery UX | Güvenli cache; server-write gerektiren iş offline tamamlanmaz |

## DEFER — 5

| ID | Capability | Reason |
|---|---|---|
| V1-24 | Merchant review reply | Moderasyon, bildirim ve misilleme politikası gerekir |
| V1-25 | Advanced multi-branch templates | Pilot için operasyon karmaşıklığı yüksek |
| V1-26 | Bulk price editing | Yanlış fiyat blast radius'u yüksek |
| V1-27 | Custom analytics/report export | Temel metrik semantiği önce kanıtlanmalı |
| V1-28 | Listing-media-to-canonical promotion | Moderasyon ve hak sahipliği kararı gerekir |

## FUTURE_ENGINE — 3

| ID | Engine | Constraint |
|---|---|---|
| V1-29 | Sponsored advertising | Organik sonuç ve paid disclosure ayrı kalır |
| V1-30 | Reputation/gamification | Ödeme ile rozet satın alınamaz; final model ayrı |
| V1-31 | Rewards | Doğrulanmış satın alma aday kanıttır; formül yok |

## Gate

Sınıflandırma Product Owner tarafından onaylanana kadar kapsam `PROPOSED` kalır. `SHOULD_HAVE` maddeler pilot öncesi kapasiteye göre azaltılabilir; QR güvenliği ve authorization azaltılamaz.

