# Wave 38E — Preview Acceptance Readiness

## Mevcut kapı durumu

| Kapı | Durum | Kanıt / açıklama |
|---|---|---|
| Strict V2 backend contract | PASS | 8/8 RPC ve canlı capability evidence doğrulandı |
| Flutter V2 adapter | PASS | V2-only endpoint/parameter/DTO bağlaması |
| Capability proof | PASS | Sürüm, generation, feature/evidence ve metadata fail-closed |
| Legacy default | PASS | Development ve Production legacy |
| Development opt-in | PREPARED / OFF | Açık Dart define, varsayılan false |
| Preview support | PASS | Canlı değer `true` |
| Preview enabled | BLOCKED | Canlı değer `false` |
| Public active roots | BLOCKED | Canlı değer `0` |
| Real 24-root Flutter acceptance | NOT RUN | Preview kapalı |

## Kalan tek dış blokaj

`PREVIEW REMOTE ENABLEMENT ONLY`

Bu ifade preview açma yetkisi vermez. Preview yalnız ayrı ve açık backend/operator göreviyle Development'ta etkinleştirilmelidir. Flutter istemci service-role veya preview setter içermez.

## Kontrollü kabul için exact sıra

1. Yetkili backend/operator ayrı görevde yalnız Development preview'ı etkinleştirir.
2. Read-only `taxonomy_capabilities_v2` ile `preview_enabled=true` ve `preview_root_count=24` doğrulanır.
3. Development build açık opt-in ile başlatılır:
   `--dart-define=ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY=true`
4. İstemci canlı capability proof'ü yeniden okur; statik envantere güvenmez.
5. Home projection tam 24 discoverable L1 root doğrular.
6. Temsilî L2, L3 ve L4 container/leaf yollarında recursive browse ve back navigation çalıştırılır.
7. Breadcrumb ve server-owned search path doğrulanır.
8. Exact-leaf boş sonucu ve ileride qualifying leaf sonucu server-authoritative olarak doğrulanır.
9. Cart V2, QR, wishlist, reviews, seller comparison ve auth regresyonları çalıştırılır.
10. Sorun halinde build canonical opt-in olmadan yeniden başlatılır; legacy varsayılan korunur. Bu bir veri/config rollback'i değildir.

## PASS ölçütleri

- Capability: tam V2 uyumlu ve preview on.
- Root projection: tam 24, duplicate yok, sürüm tekil.
- L2/L3/L4: server path ve children ilişkileri tutarlı.
- Alias: dört açık durum korunur; ambiguity redirect edilmez.
- Search: matched node/path/version/alias context tutarlı.
- Product scope: yalnız exact-leaf/descendants V2 sonucuna dayanır.
- Explicit canonical seçiminde hata olduğunda legacy'ye sessiz fallback olmaz.
- Production entrypoint ve Production remote etkilenmez.

## STOP ölçütleri

- Preview root count 24 değil.
- Contract/taxonomy/RPC version veya generation uyuşmuyor.
- Required evidence/metadata eksik.
- Preview açık görünmesine rağmen preview data RPC `W38_PREVIEW_DISABLED` döndürüyor.
- Root/path/parent/version tutarsızlığı var.
- V2 error sonrasında V1 çağrısı gözleniyor.
- Canonical hata sessizce legacy data ile maskeleniyor.
- Production'a ait URL/ref/credential veya service-role ihtiyacı doğuyor.

## Bu görevde yapılmayanlar

- Preview enable edilmedi.
- Real 24-root acceptance yapılmadı.
- Canonical runtime varsayılan yapılmadı.
- Public/pilot lifecycle değiştirilmedi.
- Development write yapılmadı.
- Production'a erişilmedi.

`READY_FOR_CONTROLLED_DEVELOPMENT_PREVIEW_ACCEPTANCE: YES`

Bu “YES”, yalnız istemci mimarisi ve test hazırlığının hazır olduğunu belirtir; gerçek kabul PASS anlamına gelmez.
