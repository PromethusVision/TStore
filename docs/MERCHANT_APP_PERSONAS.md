# Merchant App Personas

Status: **RESEARCH — SYNTHETIC PERSONAS**
Wave: 17 / WP04

Tüm örnekler sentetiktir; gerçek kişi, iletişim bilgisi veya işletme kaydı içermez.

| ID | Persona | Primary jobs | Constraints | Product implication |
|---|---|---|---|---|
| P-01 | Tek dükkânlı kırtasiyeci | Fiyat/bulunabilirlik, QR | Az zaman, düşük teknik deneyim | Search-first, hızlı düzenleme |
| P-02 | Mahalle marketi | Çok sayıda listing, değişken fiyat | Sık fiyat değişimi, barkod yoğun | Barkod destekli bulma, güvenli toplu availability |
| P-03 | Telefoncu | Model uyumluluğu, yedek parça | Product/variant/facet ayrımı | Compatibility alanları, duplicate önleme |
| P-04 | Çok sektörlü küçük esnaf | Birincil/ikincil sektör | Merchant taxonomy ile product taxonomy karışabilir | Sektör yalnız keşif/operasyon sinyali |
| P-05 | Güzellik işletmesi | Hizmet görünürlüğü | Service catalog henüz final değil | Booking ve service price fail-closed/defer |
| P-06 | Düzenlemeye tabi merchant | Onboarding ve ürün uygunluğu | Belge/politika ihtiyacı | Uygunluk tamamlanmadan yayın yok |
| P-07 | Karma ürün+hizmet işletmesi | Listing ve hizmeti ayırmak | MIXED model öneri aşamasında | Operating model owner kararı |
| P-08 | İki şubeli işletme sahibi | Ortak ürün, şube fiyatı | Fiyat ve availability farklı | Canonical shared, listing branch-specific |
| P-09 | Şube yöneticisi | Kendi şubesini yönetmek | Organizasyonun diğer şubeleri gizli | Shop-scoped authorization |
| P-10 | QR kasiyeri | Yalnız QR doğrulama | Yanlışlıkla katalog erişmemeli | Dar QR_VERIFIER capability |
| P-11 | Katalog personeli | Ürün/listing güncelleme | QR veya staff yönetimi yetkisi yok | Least-privilege template |
| P-12 | Teknik olarak deneyimsiz owner | Günlük temel işler | Jargon, uzun form, belirsiz hata | Sade Türkçe, adım azaltma, açık sonuç |

## Cross-persona needs

- Her zaman hangi mağazada işlem yapıldığını göster.
- Tehlikeli veya yüksek etkili işlemlerde kapsam ve sonuç özeti göster.
- Başka shop/organization verisini cache, hata veya deep link üzerinden sızdırma.
- Regulated/mixed/service belirsizliğini otomatik yayınla çözme.
