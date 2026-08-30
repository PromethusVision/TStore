# Wave 38D Development strict backend contract apply sonucu

Tarih: `2026-08-30`

Durum: **PASS — corrected exact `0011` yalnız EsnaftaVar Development'a
uygulandı. Preview, taxonomy ve canonical Customer runtime aktive edilmedi.**

## Yetki ve güvenlik sınırı

- Product Owner yalnız `EsnaftaVar Development` / `tnipyxnvhgelwdpykyez` için,
  corrected candidate SHA'yı açıkça adlandıran controlled-write yetkisi verdi.
- Doğrulanan URL: `https://tnipyxnvhgelwdpykyez.supabase.co`.
- Production ref `mefhfvrgkwciubeajjeb` okunmadı, bağlanılmadı ve değiştirilmedi.
- Yetki yalnız iki JIT, exact `0011` apply ve kritik postcheck hatasında exact
  rehearsed rollback ile sınırlıydı. Preview enablement, taxonomy activation,
  runtime activation, Auth/Storage veya business-data mutation yetkili değildi.

## Git ve artefakt kimliği

- Başlangıç `origin/main`: `4d2a45debee790f9f645960a0d78c897d8a78a76`.
- Integration branch: `integration/wave-38d-development-contract-v2-apply`.
- Pre-apply main commit: `77cf9e62c407006b91963de79fa88c770e4de2dd`.
- Aktif migration:
  `supabase/migrations/20260830001100_0011_canonical_taxonomy_contract_v2.sql`.
- Candidate/aktif SQL SHA-256:
  `63552485c8b86cbc6bab3fe24dcd3b0783063464020c4ece00241c42f10f2bb5`.
- Artifact-set SHA-256:
  `781dd6351bc0daa7709725fbd4deb509fad63de8bda8e3d24e77be2a1049bda7`.
- Rollback SHA-256:
  `fdc79ff3586fe61c8336c68026fd564ebeaec6cb6e890bc93f28778499d9000d`.
- Eski `c4961f36f28dcc047d44716ae2de76c5c1828b592078e49293307064959e9353`
  candidate **SUPERSEDED — CONTRACT BUG** olarak kaldı ve uygulanmadı.
- Authorized candidate, local active dosya ve `origin/main` active dosya kimliği
  birebir doğrulandı. `0010`, frozen 1563-node payload veya UUID manifest değişmedi.

## Yerel kapılar

- Actual active file baseline/forward/rollback `3/3 / 3/3 / 3/3`, idempotency
  `2/2`, postcheck `3/3` ve failure/regression matrix `29/29` PASS.
- v1 `7/7`, strict v2 `8/8`, real non-assignable leaf negative ve transaction-local
  assignable positive fixture PASS.
- Canonical migration contract suite `18/18`; birleşik hedefli suite `42/42` PASS.
- Flutter analyzer `0` issue; migration SHA, diff check ve secret/PII scan PASS.

## İki JIT ve GO kararı

| Gate | İlk JIT | İkinci JIT |
|---|---:|---:|
| Snapshot UTC | `2026-08-30T17:29:07.796574Z` | `2026-08-30T17:33:04.209929Z` |
| Ledger | exact `10/10`, last `0010` | exact `10/10`, `0011` absent |
| Nodes / levels / leaves | `1563 / 24-244-1096-199 / 1245` | unchanged |
| UUID / staged-inactive | `1563 / 1563` | unchanged |
| Assignable / public / pilot / leakage | `0 / 0 / 0 / 0` | unchanged |
| Products / shops / listings | `0 / 0 / 0` | unchanged |
| Auth users / Storage objects | `0 / 0` | unchanged |
| Public RLS / policy | `28/28 / 52` | unchanged |
| v1 / v2 / config | `7/7 / 0 / absent` | unchanged |
| Competing migration client / advisory lock | `0 / 0` | `0 / 0` |

Target identity, operational health, ledger, schema, data, single-writer ve Git/
artifact identity kapıları iki kez geçti. `W38D_GO_DECISION = GO`.

## Resmî CLI dry-run ve apply

Supabase CLI `2.116.0` kullanıldı. Historical remote ledger sürümlerini değiştirmek
yerine, önceden doğrulanmış exact `(version,name)` çiftlerini repo dışında geçici
deployment görünümünde temsil eden aynı güvenli yöntem kullanıldı.

Final linked dry-run yalnız:

`20260830001100_0011_canonical_taxonomy_contract_v2.sql`

dosyasını pending gösterdi; seed ve role listeleri boştu. Exact migration tek
transaction ile başarıyla uygulandı. History repair, ad-hoc SQL düzeltmesi, ikinci
migration veya seed çalıştırılmadı. Apply sonrası linked dry-run `upToDate=true`,
pending migrations `[]` verdi.

## Post-apply veritabanı sonucu

| Kontrol | Sonuç |
|---|---:|
| Ledger | exact `11/11`; last `20260830001100 / 0011_canonical_taxonomy_contract_v2` |
| Canonical nodes | `1563` |
| L1 / L2 / L3 / L4 | `24 / 244 / 1096 / 199` |
| Leaves / unique UUID | `1245 / 1563` |
| Staged-inactive / assignable | `1563 / 0` |
| Public active / pilot active / policy leakage | `0 / 0 / 0` |
| Allocation / alias / alias target | `1563 / 651 / 1000` |
| Relationship / import run | `1032 / 1` |
| Products / shops / listings | `0 / 0 / 0` |
| Profiles / legal consents / carts / QR / verified / reviews | tümü `0` |
| Auth users / Storage objects | `0 / 0` |
| Public tables with RLS | `29/29`; disabled `0` |
| Existing policies | `52` |
| Canonical triggers | public `24` + auth `1` = `25` |

## Strict contract ve capability

- Existing v1 signatures ve anon/authenticated grants: `7/7 PASS`.
- Strict public v2 family: yedi data RPC + `taxonomy_capabilities_v2` = `8/8 PASS`.
- Sekiz public v2 RPC'nin tamamı exact signature/response ile, hardened
  `search_path = pg_catalog, public` ve beklenen anon/authenticated execute grant'iyle
  mevcuttur.
- Versions: `taxonomy-client-v1` / `canonical-v1.0.0` /
  `taxonomy-rpc-v2`; generation `2`.
- Capability hierarchy, lifecycle, policy, alias, path/search ve product-scope
  semantics'i raporladı. `product_scope_requires_assignable=true` ve
  `product_scope_policy_fail_closed=true`.
- `taxonomy_contract_config` RLS açık, row `1`, public policy `0`; anon/authenticated
  direct `SELECT/UPDATE` yoktur. Preview setter anon/authenticated için kapalı,
  yalnız `service_role` execute yetkilidir. Hiçbir service-role secret okunmadı veya
  çıktıya yazılmadı.

## Preview ve exact-leaf fail-closed kanıtı

- `preview_supported=true`; `preview_enabled=false`.
- Preview-OFF roots sonucu `0`; public-active roots `0`.
- Preview isteyen read çağrısı beklenen `W38_PREVIEW_DISABLED` hatasıyla fail-closed
  durdu. Trusted setter çağrılmadı; ON/OFF provası yapılmadı.
- Real staged non-assignable leaf
  `00084e98-e0ba-494a-8c19-8fa57272abd3`, preview OFF iken
  `taxonomy_exact_leaf_v2` tarafından `0` satırla reddedildi.
- Capability product-scope kanıtı bu sonuçla tutarlıdır. Remote positive fixture veya
  assignability/lifecycle değişikliği yapılmadı.

## Sağlık, advisor ve rollback

- Development URL/DB sorguları, migration, postchecks ve final dry-run başarılıdır;
  operational status **Healthy** olarak doğrulandı.
- Apply penceresinde unexpected Postgres error log `0`.
- Security advisor `6 INFO / 33 WARN`, performance advisor `51 INFO / 47 WARN`
  raporladı; `ERROR` seviyesi yoktur. Config tablosunun policy'siz deny-all RLS'i ve
  anon-read strict RPC'lerin SECURITY DEFINER uyarıları bu reviewed contract'ın
  bilinçli yüzeyidir; sekiz v2 RPC'nin hardened search path ve grants'i ayrıca
  doğrulandı. Existing unrelated advisor maddeleri bu task'ta değiştirilmedi.
- Kritik postcheck hatası yoktur. Rollback gerekmedi ve çalıştırılmadı.

## Final durum ve sonraki sınır

- Development ledger `11/11`; strict v2 backend ve capability v2 deployed.
- Taxonomy hâlâ yalnız `STAGED`; preview `OFF`; public/pilot `0/0`.
- `LEGACY_RUNTIME` default ve `CANONICAL_CUSTOMER_MODE=OFF` korunur.
- Sonraki iş yalnız iki bounded, sıralı client değişikliğidir: yedi strict read'in
  v2 family'ye atomik binding'i ve capability/runtime proof'un
  `taxonomy_capabilities_v2` + strict DTO'ya bağlanması. Bu belge runtime, preview,
  public/pilot veya Production aktivasyonu yetkisi vermez.

Makine-okunur kanıt:
`docs/data/taxonomy_w38d_development_contract_v2_apply_result.json`.

`W38D_LOCAL_ACTIVE_0011: PASS`

`W38D_FIRST_JIT: PASS`

`W38D_SECOND_JIT: PASS`

`W38D_GO_DECISION: GO`

`DEVELOPMENT_0011_APPLY: PASS`

`EXACT_CORRECTED_0011_APPLIED: YES`

`STRICT_V2_DEPLOYED: PASS`

`CAPABILITY_V2_DEPLOYED: PASS`

`PREVIEW_DEFAULT_OFF: PASS`

`EXACT_LEAF_REMOTE_FAIL_CLOSED: PASS`

`V1_BACKWARD_COMPATIBILITY: PASS`

`TAXONOMY_PRESERVED: PASS`

`ROLLBACK_REQUIRED: NO`

`ROLLBACK_RESULT: NOT_RUN`

`DEVELOPMENT_PROJECT_HEALTHY: YES`

`CANONICAL_CUSTOMER_MODE_ACTIVE: NO`

`PREVIEW_REMOTE_ENABLED: NO`

`PUBLIC_TAXONOMY_ACTIVE: NO`

`PRODUCTION_ACCESSED: NO`

`PRODUCTION_TOUCHED: NO`

`READY_FOR_BOUNDED_V2_CLIENT_UPDATE: YES`
