# Wave 37C Development staged bootstrap sonucu

Tarih: `2026-08-30`

Durum: **PASS — exact canonical taxonomy Development üzerinde staged/inactive
olarak kuruldu. Public veya Customer runtime aktivasyonu yapılmadı.**

## Yetki ve hedef

- Product Owner, yalnız boş `EsnaftaVar Development` ortamı için recreation riskini
  kabul etti ve bütün fresh JIT kapıları geçerse exact yeni executable artefaktın
  uygulanmasına açık yetki verdi.
- Hedef: `EsnaftaVar Development` / `tnipyxnvhgelwdpykyez` /
  `https://tnipyxnvhgelwdpykyez.supabase.co`.
- Production ref `mefhfvrgkwciubeajjeb` okunmadı ve değiştirilmedi.
- Bu yetki public/pilot taxonomy, canonical Customer runtime veya Production
  yetkisi değildir.

## Git ve executable kimliği

- Başlangıç `origin/main`: `a0ce3015c753dff22304d4a8f3f3a7b9a0a4e1e6`.
- Pre-apply main commit: `ffdecbffab7db3fa75dd944b111e1951d2123215`.
- Aktif migration:
  `supabase/migrations/20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql`.
- Ledger çifti: `20260829001000` /
  `0010_canonical_taxonomy_v1_staged_bootstrap`.
- Aktif SQL: `1,184,842` bayt; SHA-256
  `40fade490cde5f31b5c649ada301852b2abb40c0979a4f2e45bcd735b4f876b8`.

| Artefakt | SHA-256 |
|---|---|
| Frozen package | `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406` |
| Normalized package | `f73d6c0f432dd788a4f47a807280017fb068d3cdc21455e8d277a0767511f0a2` |
| Artifact set | `840ab06907f40ae938f22302b7aeebc0da46c04149d9d6f219f7559197f02341` |
| Authorized/active candidate | `40fade490cde5f31b5c649ada301852b2abb40c0979a4f2e45bcd735b4f876b8` |

Payload değişmedi; UUID üretilmedi veya yeniden sıralanmadı.

## Yerel replay ve iki JIT kapısı

- Exact aktif dosya fresh/forward/rollback `3/3`, idempotency `2/2`, postcheck
  `3/3`, failure matrix `27/27`, ledger fixture `11/11`, parser `13/13` ve
  canonical Flutter migration contract `18/18` PASS verdi.
- İlk JIT `2026-08-30T12:54:40.24412Z`, ikinci JIT
  `2026-08-30T13:09:52.234622Z` anında alındı.
- İki snapshot'ta da 23/23 application table mevcuttu; tümü boştu.
  `categories/products/shops/shop_products = 0/0/0/0`, Storage object `0`.
- Ledger exact dokuz `(version,name)` çiftidir; taxonomy schema/function yoktur.
  RLS `23/23`, policy `52`, aktif başka writer/session ve advisory lock `0`.
- İki snapshot arasında table, ledger, column, policy veya function drift'i yoktur.
- Pre-apply main commit ve `origin/main` SQL blobu exact candidate SHA ile eşleşti.

Sonuç: `W37C_GO_DECISION = GO`.

## Apply yolu

Resmî Supabase CLI `2.116.0` kullanıldı. Doğrudan repository workdir dry-run'ı,
ilk sekiz historical remote ledger sürümünün eski repository filename timestamp'leriyle
aynı olmaması nedeniyle fail-closed durdu. CLI'nin önerdiği `migration repair`
**çalıştırılmadı**.

Remote ledger'ın önceden doğrulanmış exact `(version,name)` çiftlerini yalnız geçici
deployment görünümünde temsil eden, remote history'yi değiştirmeyen bir projection
hazırlandı. Bu görünümde final dry-run yalnız:

`20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql`

dosyasını pending gösterdi. Exact dosya Development'a bir kez uygulandı; transaction
başarıyla tamamlandı. Apply sonrası aynı linked dry-run `Remote database is up to
date` verdi. History repair, ek migration veya ad-hoc canlı SQL düzeltmesi yoktur.

## Structural postcheck

| Kontrol | Sonuç |
|---|---:|
| Canonical node | `1563` |
| L1 / L2 / L3 / L4 | `24 / 244 / 1096 / 199` |
| Terminal leaf | `1245` |
| Unique category UUID / allocation | `1563 / 1563` |
| Allocation mismatch | `0` |
| Alias / alias target edge | `651 / 1000` |
| Relationship / successor edge | `1032 / 1000` |
| Split locator / split edge | `210 / 591` |
| Arbitrary product split assignment | `0` |
| Orphan / cycle-depth / L5 | `0 / 0 / 0` |
| Duplicate source key / slug | `0 / 0` |
| Staged + inactive | `1563` |
| Public active / pilot active | `0 / 0` |
| Policy leakage | `0` |

`deodorant-ter-onleyici` için frozen relationship evidence'ında tek successor edge
bulunması bir product assignment değildir. Development product sayısı `0` ve
compiler'ın arbitrary split assignment güvenlik sözleşmesi `false` olduğundan
arbitrary first-child product mapping sonucu exact `0`dır.

## RLS, anon görünürlük ve backend contract

- Public table RLS `28/28`; disabled tablo `0`.
- Existing policy count `52`; taxonomy admin tablolarında public policy `0`.
- Beş taxonomy admin tablosunda anon ve authenticated `SELECT` grant'i yoktur.
- `categories_read_active` yalnız `is_active = true` satırları açar; imported
  `1563` satırın tamamı `staged` ve `is_active=false` durumundadır.
- Yedi versioned RPC exact signature ile mevcuttur ve anon/authenticated execute
  contract'ı açıktır. Staged durumda roots/children/descendants/exact-leaf/
  breadcrumb/alias/search public-active projection toplamı `0`dır.
- Policy-sensitive active ve professional-review active sayıları `0/0`.
- Canonical trigger seti `25/25`; taxonomy hierarchy ve Storage media trigger'ları
  yerindedir.
- Migration ledger exact `10/10`; son çift yeni `0010` çiftidir.

## İlgisiz veri ve final durum

- `products/shops/shop_products = 0/0/0`; taxonomy dışındaki bütün application
  tabloları ilk JIT sıfır baseline'ında kaldı.
- Auth user/identity/session `0/0/0` ve Storage object `0`; bu alanlarda write yoktur.
- Development post-apply status: **Healthy**. Dashboard last migration exact
  `0010_canonical_taxonomy_v1_staged_bootstrap`.
- Kritik postcheck hatası yoktur; rollback gerekmedi ve çalıştırılmadı.
- Final durum: `CANONICAL_EXISTS=YES`, `STAGED=YES`, `PUBLIC_ACTIVE=NO`,
  `PILOT_ACTIVE=NO`, `CANONICAL_CUSTOMER_MODE=OFF`,
  `LEGACY_RUNTIME_DEFAULT=YES`.

Makine-okunur kanıt:
`docs/data/taxonomy_w37c_development_staged_bootstrap_result.json`.

## Sonraki sınır

Development backend client cutover için backend hazırdır. Ancak Customer canonical
mode, public/pilot activation, policy/professional-review aktivasyonu, demo mapping,
UI Kit ve Production migration ayrı task, doğrulama ve gerekli owner yetkilerini
bekler.
