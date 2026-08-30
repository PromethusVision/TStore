# Wave 38E — Strict V2 Client Binding Result

## Sonuç

Development'ta deploy edilmiş strict V2 taxonomy sözleşmesi Flutter istemciye bağlandı. Bağlantı yalnız V2 RPC'leri kullanır; canonical yol üzerinde V1 fallback yoktur. Legacy runtime Development ve Production için varsayılan kalır.

Bu çalışma sırasında Development yalnız okunmuştur. Preview açılmamış, veritabanı/config değiştirilmemiş ve Production'a erişilmemiştir.

## Bağlanan sözleşme

| İşlem | RPC | Temel istemci davranışı |
|---|---|---|
| Capability | `taxonomy_capabilities_v2` | Tek satırlık 20 alanlı kanıtı doğrular |
| Roots | `taxonomy_roots_v2` | Strict node DTO |
| Children | `taxonomy_children_v2` | Parent UUID + strict node DTO |
| Descendants | `taxonomy_descendants_v2` | Server-owned recursive projection |
| Exact leaf | `taxonomy_exact_leaf_v2` | Server'ın döndürdüğü qualifying leaf'leri kullanır; boş sonuç geçerlidir |
| Breadcrumb | `taxonomy_breadcrumb_v2` | Server-owned canonical path |
| Alias | `taxonomy_resolve_alias_v2` | `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, `UNRESOLVED` açık durumları |
| Search | `taxonomy_search_context_v2` | Matched node, path, alias context ve version |

Her data RPC şu ortak parametreleri taşır: `p_client_contract_version=taxonomy-client-v1`, `p_taxonomy_version=canonical-v1.0.0`, açık `p_preview`. İstemci V2 hatasında V1 çağrısına dönmez.

## Capability kanıtı

Runtime kanıtı statik envanterden değil, `taxonomy_capabilities_v2` yanıtından kurulur. Aşağıdakilerin tümü zorunludur:

- client contract: `taxonomy-client-v1`
- taxonomy data: `canonical-v1.0.0`
- RPC contract: `taxonomy-rpc-v2`
- generation: `2`
- yedi feature ve yedi evidence değeri
- lifecycle, policy, alias-state ve path metadata
- preview support
- product scope contract: `exact-leaf-visible-assignable-policy-eligible`
- `product_scope_requires_assignable=true`
- `product_scope_policy_fail_closed=true`

Sadece RPC'nin başarılı cevap vermesi yeterli değildir. Eksik alan, sürüm uyuşmazlığı, generation uyuşmazlığı veya evidence eksikliği fail-closed sonuç üretir.

## Runtime durum modeli

- `unsupported`: V2 kanıtı tam uyumlu değil.
- `supportedPreviewOff`: Sözleşme uyumlu, preview kapalı.
- `supportedPreviewOn`: Sözleşme uyumlu, preview açık.

Canonical acceptance runtime ancak uyumlu kanıta ek olarak müşteri tarafından görülebilen public root veya etkin preview root bulunduğunda kurulabilir. Açık canonical seçimi preview-off/zero-root durumunda exception ile durur; sessiz legacy fallback yapmaz.

## Development opt-in

Development entrypoint'te `ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY` adlı açık opt-in seam'i vardır.

- Varsayılan: `false`.
- `false`: capability RPC dahil canonical remote çağrı yapılmaz; legacy runtime çalışır.
- `true`: Development client üzerinden canlı capability kanıtı okunur.
- Uyumlu preview-on/root projection yoksa başlangıç fail-closed olur.
- Production entrypoint bu define'ı, capability çağrısını veya canonical acceptance yolunu içermez.

Repo içinde Development project ref'i, service-role key veya Production URL sabitlenmemiştir.

## Exact-leaf ve product scope

Exact-leaf yeterliliği istemcide yeniden hesaplanmaz. `taxonomy_exact_leaf_v2` boş dönerse sonuç “qualifying product scope yok” olarak kabul edilir. Dönen category ID'ler ürün sorgusuna aktarılır. Descendant scope da yalnız server'ın döndürdüğü ID'leri kullanır.

## Alias, arama ve preview node'ları

- Alias row varsa durum/target-count ilişkisi doğrulanır; ambiguity için ilk eşleşme seçilmez.
- Backend'in boş alias cevabı client tarafından `UNRESOLVED` diye uydurulmaz.
- Arama path'i istemcide heuristik olarak kurulmaz.
- `preview_context=true` olan staged container'lar yalnız Development canonical preview bağlamında gezilebilir; aynı staged node preview context dışında erişilemez.
- Policy/review/assignability alanları strict DTO'nun zorunlu parçalarıdır.

## Development read-only kanıtı — 30 Ağustos 2026

Doğrulanan hedef: `https://tnipyxnvhgelwdpykyez.supabase.co` (`tnipyxnvhgelwdpykyez`).

- Capability contract/version/generation: beklenen değerlerle eşleşti.
- Feature/evidence: 7/7 ve 7/7.
- Preview support: `true`.
- Preview enabled: `false`.
- Public active roots: `0`.
- Pilot active roots: `0`.
- Preview roots: `0` (preview kapalıyken).
- Yedi V2 data RPC için anon/authenticated execute grant: mevcut.
- Public roots çağrısı: 0 satır.
- Nonexistent node children/descendants/breadcrumb: güvenli 0 satır.
- Unknown alias/search: güvenli 0 satır.
- Gerçek staged non-assignable leaf exact-leaf: 0 satır.
- Preview request: `P0001 / W38_PREVIEW_DISABLED` ile fail-closed.
- Invalid UUID: `22P02`.

Development write yapılmamıştır.

## Uyumluluk sonucu

Wave 38C-R'deki iki `ADAPTER_UPDATE_REQUIRED` kalemi kapatıldı:

1. concrete adapter strict V2 endpoints/DTO'lara bağlandı;
2. runtime proof canlı V2 capability evidence'a bağlandı.

Kalan adapter update: **0**. Backend blocker: **0**.

Gerçek 24-root kabulü bu görevde yapılmamıştır; local fixture sonucu gerçek kabul sayılmaz.
