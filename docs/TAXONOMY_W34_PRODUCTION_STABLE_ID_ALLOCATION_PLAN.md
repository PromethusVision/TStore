# Wave 34A — Production Stable-ID Allocation Plan

**State:** RECOMMENDED FOR SEPARATE PRODUCTION-ID DECISION — NO ID ALLOCATED

**Scope:** Canonical Product Taxonomy V1 için kimlik tahsis sözleşmesi. Bu belge
schema, migration, seed, runtime veya remote apply değildir.

## 1. Identity invariant

Production stable identity; Türkçe ad, slug, tam path, parent path, sort order veya
`CANONICAL-......` planning key'den türetilmez. Bu alanlar değişebilir. Stable ID:

- opaque ve immutable olur;
- bir kez tahsis edilir, silinince yeniden kullanılmaz;
- rename ve move sırasında aynı kalır;
- product/listing/analytics foreign key'lerinin tek identity kaynağı olur;
- display path ve slug için kalıcı alias/redirect kaydıyla birlikte yaşar.

`CANONICAL-000001` biçimindeki değerler yalnız bu Wave 34A manifestinde review,
eşleme ve migration planlama anahtarıdır. Production ID değildir ve runtime'a
kopyalanmamalıdır.

## 2. Mechanism comparison

| Seçenek | Güçlü yanı | Riski / maliyeti | Taxonomy uygunluğu |
|---|---|---|---|
| UUIDv4 | Standard 128-bit UUID; rastgele/pseudorastgele, path ve zaman anlamı taşımaz; PostgreSQL `uuid` tipi ve yaygın araçlarla uyumludur | Random insert locality, yüksek yazma hacimli indekslerde UUIDv7'den zayıf olabilir | **En düşük bağımlılık ve en güçlü opacity; önerilen** |
| UUIDv7 | Standard 128-bit UUID; milisaniye timestamp'i nedeniyle sıralı ekleme ve indeks locality avantajı sağlar | Tahsis zamanını açığa çıkarır; generator desteği kullanılan PostgreSQL/runtime sürümünde ayrıca doğrulanmalıdır; taxonomy yazma hacmi düşüktür | Uygun ama V1 taxonomy için ek faydası sınırlı |
| Başka opaque random ID | CSPRNG ile yeterli entropy sağlanabilir; özel metin formatı seçilebilir | Özel parser/validator, collation, case ve interoperabilite yükü; UUID ekosistemi dışında gereksiz özel sözleşme | Tavsiye edilmez |

Standart tanımlar için [RFC 9562](https://www.rfc-editor.org/rfc/rfc9562.html);
PostgreSQL `uuid` tipi ve güncel generator seçenekleri için
[PostgreSQL UUID documentation](https://www.postgresql.org/docs/current/datatype-uuid.html)
esas alınmıştır. Actual Supabase/PostgreSQL sürümü remote'a bağlanmadan bilinmediği
için native UUIDv7 fonksiyonu bu planda varsayılmaz.

## 3. Recommendation

**UUIDv4, trusted server-side allocation registry üzerinden tahsis edilsin.**

Gerekçe:

1. taxonomy node creation çok düşük hacimli bir yönetim işlemidir; UUIDv7'nin write
   locality avantajı burada kritik değildir;
2. UUIDv4 ad/path ve creation-time anlamı taşımaz;
3. mevcut PostgreSQL `uuid` tipi ve backend araçlarıyla geniş uyumluluk sağlar;
4. client tarafından tahsis zorunluluğu yaratmaz;
5. name/path-derived deterministic UUID riskini tamamen kaldırır.

Bu recommendation owner veya migration onayı değildir. Actual generator,
PostgreSQL sürümü ve trusted-writer mekanizması Development preflight'ta yeniden
doğrulanır.

## 4. Allocation sequence

1. Owner-final manifest blob/checksum ve exact `1563` node freeze edilir.
2. Planning key başına trusted migration tooling ile bir UUIDv4 üretilir.
3. `planning_key -> production_uuid` allocation ledger'ı tek-writer işleminde
   oluşturulur; uniqueness ve completeness transaction öncesi/sonrası doğrulanır.
4. Aynı planning key için retry yeni UUID üretmez; mevcut ledger sonucu döner.
5. Parent production UUID'leri yalnız allocation ledger üzerinden bağlanır.
6. Alias/successor registry production UUID'lerine çevrilir; slug veya path join
   anahtarı olarak kullanılmaz.
7. Development dry-run; duplicate, orphan, rollback, idempotency, client backward
   compatibility ve demo mapping kontrollerini geçmeden Production planlanmaz.
8. Production allocation/apply ayrı açık yetki, backup ve single-writer gate ister.

## 5. Lifecycle rules

### Rename

ID değişmez. `display_name_tr` ve türetilmiş current slug/path değişebilir; eski
slug/name historical alias olarak korunur.

### Move

ID değişmez. `parent_id` ve türetilmiş path değişir. Eski breadcrumb/path alias'ı
geçiş süresince redirect/lookup kanıtı olarak saklanır.

### Merge

Kazanan canonical semantic node kendi ID'sini korur. Birleştirilen node'lar retired
olur, ID'leri yeniden kullanılmaz ve `many-to-one` successor kaydı taşır. Historical
facts sessizce yeniden yazılmaz; current read projection successor üzerinden
çözebilir.

### Split

Eski node retired olur. Yeni, farklı anlamdaki her successor yeni opaque ID alır.
Eski ID birden fazla successor'a yönelir; blind redirect yasaktır. Mevcut products
product-level discriminator veya manual exception queue ile tam olarak bir yeni
leaf'e reclassify edilir.

### Retire

ID tombstone olarak korunur, active/assignable olmaz ve yeniden kullanılmaz. Active
successor varsa explicit registry; yoksa açık `NO_ACTIVE_SUCCESSOR` durumu tutulur.

### Alias

Alias identity değildir. Tek canonical ID'ye historical lookup/redirect sağlar.
Search synonym yalnız semantik eşdeğerlik ayrıca doğrulanmışsa kullanılabilir;
redirect alias'ı otomatik search synonym sayılmaz.

## 6. Fail-closed controls

- Production UUID client/Flutter tarafından üretilmez.
- Service-role veya server secret manifestte, source'ta ya da client asset'inde olmaz.
- `REGULATED`, `LEGAL_REVIEW_REQUIRED` veya professional-review bekleyen node'un
  canonical ID alması onu assignable/active yapmaz.
- Allocation, runtime assignability ve pilot activation ayrı onay/event olarak
  tutulur.
- Planning key sırası ürün anlamı, ranking veya lifecycle garantisi değildir.
- Collision, missing parent, missing allocation veya ambiguous split tüm apply'i
  fail-closed durdurur.

## 7. Decision gate

Production ID allocation'a geçmeden önce yalnız şu karar gerekir:

> **Opaque production taxonomy ID mechanism = trusted-writer UUIDv4 registry mi?**

Recommendation: **YES**. Bu seçim yapıldıktan sonra bile Development migration
design/apply ve Production apply ayrı görev ve yetkilerdir.

`PRODUCTION_IDS_ALLOCATED: NO`

`NAME_OR_PATH_DERIVED_ID: NO`

`RECOMMENDED_ID_MECHANISM: UUIDv4`

`RUNTIME_IMPLEMENTATION: NO`
