# Wave 38F Preview Acceptance Freeze Gate

Tarih: 2026-08-30

Bu belge strict V2 backend ile Flutter istemci bağının yerel integration sonucunu
dondurur. Development veya Production'a remote erişim yapılmamış; preview,
canonical runtime, migration veya taxonomy lifecycle durumu değiştirilmemiştir.

## Dondurulan durum

| Gate | Sonuç |
| --- | --- |
| Wave 38D strict V2 backend | DEPLOYED / PASS |
| Wave 38E strict V2 client | INTEGRATED / PASS |
| Development backend/client compatibility | PASS |
| Adapter updates remaining | 0 |
| Backend blockers remaining | 0 |
| Development preview | OFF |
| Development canonical opt-in | OFF / default |
| Development runtime | LEGACY_RUNTIME / default |
| Production runtime | LEGACY_RUNTIME / untouched |
| Real 24-root acceptance | NOT RUN |

Authoritative Development backend state Wave 38D kanıtından korunur: ledger
`11/11`, strict V2 endpoint/capability contract `8/8`, preview support `YES`,
`preview_enabled=false`, `1563` staged node ve assignable/public/pilot
`0/0/0`. Bu integration bu durumu remote olarak yeniden okumamış veya
değiştirmemiştir.

## İstemci sözleşmesi

- Concrete adapter yalnız yedi strict `*_v2` read RPC'sini ve
  `taxonomy_capabilities_v2` proof çağrısını kullanır; canonical yolda V1 fallback
  yoktur.
- Proof; `taxonomy-client-v1`, `canonical-v1.0.0`, `taxonomy-rpc-v2`, generation
  `2`, preview desteği ve product-scope assignability/policy fail-closed kanıtını
  doğrular.
- Runtime readiness `UNSUPPORTED`, `SUPPORTED_PREVIEW_OFF` ve
  `SUPPORTED_PREVIEW_ON` durumlarını birbirinden ayırır. Preview OFF, backend
  uyumsuzluğu olarak sınıflandırılmaz; canonical runtime eligibility sağlamaz.
- Exact-leaf ve descendant scope yalnız server-authoritative V2 sonucunu kullanır.
  Exact-leaf için sıfır sonuç geçerli boş product scope'tur; structural leaf istemci
  tarafından product-scope leaf'e çevrilmez.
- Alias durumları `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, `UNRESOLVED` olarak açıkça
  korunur. Boş sonuçtan state tahmini veya first-match seçimi yapılmaz.
- Development opt-in seam'i
  `ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY=false` varsayılanıyla kapalıdır.
  Explicit canonical istek hem opt-in hem uyumlu canlı proof ister; başarısızlıkta
  legacy'ye sessiz fallback yoktur.
- Production entrypoint aynı opt-in'i tüketmez ve yalnız `LEGACY_RUNTIME` kurar.
  İstemcide service-role materyali veya preview setter yoktur.

## Yerel doğrulama

- Wave 38F taxonomy/client hedefli paket: `75/75 PASS`.
- Taxonomy-independent Cart V2, QR, reviews, wishlist, seller comparison ve Auth
  paketi: `245/245 PASS`.
- Full Flutter suite: `1293 PASS / 0 FAIL / 6` mevcut ve belgeli opt-in/live skip.
  Yeni skip veya zayıflatılmış test yoktur.
- `flutter analyze --no-pub`: `0 issues`.
- `git diff --check`: final integration diff üzerinde zorunlu PASS gate'idir.
- Secret/PII taraması: final integration diff üzerinde zorunlu PASS gate'idir.

## Gerçek Development preview kabulünün kalan adımları

Bu sıra yeni ve açık Product Owner/operatör yetkisi olmadan başlatılamaz:

1. Product Owner kontrollü Development preview enable yetkisi verir.
2. Preview yalnız Development üzerinde açılır.
3. Capability state'in `SUPPORTED_PREVIEW_ON` olduğu doğrulanır.
4. Development canonical opt-in istemci kabulü çalıştırılır.
5. Gerçek `24` root doğrulanır.
6. Recursive L2/L3/L4 gezinme doğrulanır.
7. Breadcrumb, search ve alias davranışı doğrulanır.
8. Mevcut assignable sayısı `0` iken product-scope fail-closed davranışı doğrulanır.
9. Preview yeniden kapatılır.
10. İstemci canonical opt-in OFF/default durumuna döndürülür.
11. Development final safe state doğrulanır.

Final UI Kit çalışması bu gerçek Development taxonomy/client kabulünden sonra
başlatılabilir. Bu gate kendi başına preview enablement, canonical activation,
Production erişimi veya herhangi bir remote write yetkisi değildir.
