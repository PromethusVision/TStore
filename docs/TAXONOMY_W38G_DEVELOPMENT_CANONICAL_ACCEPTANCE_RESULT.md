# Wave 38G Development Canonical Taxonomy Acceptance Result

## Sonuç

`W38G_DEVELOPMENT_CANONICAL_ACCEPTANCE: PASS`

EsnaftaVar Development (`tnipyxnvhgelwdpykyez`) üzerinde server-controlled preview
geçici olarak açıldı. Gerçek Flutter Development entrypoint, concrete Supabase V2
adapter, capability proof, canonical repository, Cubit, navigation ve product-scope
use-case zinciriyle kabul tamamlandı. Preview her iki kontrollü turdan sonra da
zorunlu olarak kapatıldı. Production'a erişilmedi.

## Kapsam ve hedef kilidi

- Project: `EsnaftaVar Development`
- Ref: `tnipyxnvhgelwdpykyez`
- URL: `https://tnipyxnvhgelwdpykyez.supabase.co`
- Başlangıç main: `02c72cdebfa3c7dbfb74b15e7b844e1a12c67d3f`
- Branch: `integration/wave-38g-real-development-taxonomy-acceptance`
- Production ref `mefhfvrgkwciubeajjeb`: erişim `0`
- Migration apply, taxonomy-row DML, Auth/Storage write: `0`

## Local precheck

- Development ve Production default: `LEGACY_RUNTIME`
- Development process opt-in default: `false`
- Production canonical opt-in exposure: yok
- Client preview setter/service-role yolu: yok
- Capability/adapter/runtime targeted gate: `34/34 PASS`
- İlk remote işlemden önce working tree ve target kimliği doğrulandı.

## JIT ve before-state

İlk Development JIT ve read-only snapshot:

- Health/reachability: `Healthy / PASS`
- Ledger: exact `11/11`, son migration `0011_canonical_taxonomy_contract_v2`
- V1 / strict V2: `7/7` / `8/8`
- Preview support/enabled: `true / false`
- Capability: `SUPPORTED_PREVIEW_OFF`
- Taxonomy: `1563`; L1/L2/L3/L4 `24/244/1096/199`; leaf `1245`
- Lifecycle: `staged=1563`
- Assignable/public/pilot: `0/0/0`
- Product/shop/listing: `0/0/0`
- Auth users/identities/sessions: `0/0/0`
- Storage objects: `0`
- UUID/allocation: `1563/1563`, mismatch `0`
- Duplicate path/orphan/cycle/L5: `0/0/0/0`

Trusted setter `SECURITY DEFINER` ve fixed
`search_path=pg_catalog, public` olarak doğrulandı. `anon` ve `authenticated`
execute yetkisi yoktur; yalnız `service_role` execute yetkilidir. Setter yalnız
version-guarded `preview_enabled` ve `updated_at` alanlarını değiştirir.

## Preview lifecycle

İlk kontrollü tur:

- ON: `2026-08-30 19:48:41.125904 UTC`
- Capability/config ON snapshot: PASS; `24` preview root, taxonomy/business state
  unchanged.
- İlk Flutter koşusu backend çağrısından önce test process'inde eksik
  `shared_preferences` platform channel nedeniyle durdu.
- OFF: `2026-08-30 19:49:54.721720 UTC`
- OFF safe-state: PASS.

Bu ilk harness problemi Development'a ad-hoc müdahale edilmeden yalnız test
başlatma katmanında düzeltildi. Local compile gate yeniden PASS olduktan sonra ikinci
kontrollü tur çalıştırıldı:

- ON: `2026-08-30 19:51:22.005563 UTC`
- Capability ON proof: `2026-08-30 19:51:29.458137 UTC`
- Real Flutter acceptance: PASS
- OFF: `2026-08-30 19:51:58.634928 UTC`
- Başarılı preview penceresi: yaklaşık `36.63 saniye`
- Nihai preview: `false`

Her iki turda da yalnız deployed
`taxonomy_set_preview_v2(boolean, 'canonical-v1.0.0')` trusted control path'i
kullanıldı. Taxonomy satırı, lifecycle, assignability, policy, review, public/pilot,
RLS, RPC veya ledger değiştirilmedi.

## Capability during preview

- Client contract: `taxonomy-client-v1`
- Taxonomy data: `canonical-v1.0.0`
- RPC contract/generation: `taxonomy-rpc-v2 / 2`
- Preview support/enabled/root count: `true / true / 24`
- Public/pilot active root count: `0/0`
- Required seven features: PASS
- Required seven evidence fields: PASS
- Lifecycle/policy/alias/path metadata: PASS
- Product scope requires assignable: `true`
- Product scope policy fail-closed: `true`
- Runtime readiness: `SUPPORTED_PREVIEW_ON`

## Real Flutter acceptance

Live test yalnız process-time şu opt-in'lerle çalıştı; değerler persistent config'e
yazılmadı:

- `ESNAFTAVAR_RUN_W38G_TAXONOMY_ACCEPTANCE=true`
- `ESNAFTAVAR_DEVELOPMENT_CANONICAL_TAXONOMY=true`

Gerçek Development istemci yolu `canonicalV1Runtime` seçti ve legacy fallback
üretmedi. Live root yanıtı exact canonical UUID/name setiyle eşleşti:

| # | UUID | L1 adı |
|---:|---|---|
| 1 | `714f42ff-37ee-466c-9726-796097910936` | Gıda & İçecek |
| 2 | `737eb7ae-eb06-442b-83e0-f02834950be7` | Giyim & Moda |
| 3 | `3767cb95-6117-49cc-9298-4f0e8eb5dbb3` | Ayakkabı |
| 4 | `ea3a65e3-02c1-4e3a-a281-cd4205243cba` | Çanta & Aksesuar |
| 5 | `dae0270c-90ac-4248-919b-05531cf7c0e8` | Elektronik |
| 6 | `7d59f4a3-8828-4231-9502-ac91b7b0baa0` | Bilgisayar & Tablet |
| 7 | `49b1fa71-f885-4e5f-86dc-66f32f7687a5` | Beyaz Eşya & Ev Aletleri |
| 8 | `8ff9e12d-e19b-4fc9-8a42-b3ddbd8b7c5a` | Ev & Yaşam |
| 9 | `4ad28c36-e233-461d-9c28-87accfc43adb` | Züccaciye & Mutfak |
| 10 | `27523f6b-a340-418b-985a-c806b5d59eb4` | Yapı, Hırdavat & Tesisat |
| 11 | `8b7bf2c6-fb37-4bc3-9826-564ba9c021f5` | Otomotiv & Motosiklet |
| 12 | `18a06d0f-4e85-4f02-8ca3-90070c5e506d` | Kozmetik & Kişisel Bakım |
| 13 | `8d28867d-0ee1-43e3-8027-22b428b55f3d` | Anne & Bebek |
| 14 | `52adad9e-8fcf-48e0-9418-33ee5d51abc4` | Oyuncak & Hobi |
| 15 | `6de8a72c-5c18-4aed-9ddd-41ec87c6af08` | Müzik & Enstrüman |
| 16 | `7de86dff-38db-41b3-803a-9163af5e55a5` | Spor & Outdoor |
| 17 | `a6dc7c8c-d0ad-4347-b3f8-db4a7a5d5ea7` | Kitap |
| 18 | `b4a582c3-9e08-446f-a15c-6ee06316b14d` | Kırtasiye & Ofis |
| 19 | `b5c2618f-4c71-42d5-aa80-d443377ee469` | Evcil Hayvan Ürünleri |
| 20 | `78aa2d4d-c9dd-4baf-8816-3ec4d8a6e120` | Gözlük & Optik |
| 21 | `d8f58e32-2a1e-4f8e-a630-ca5e84dea554` | Saat & Takı |
| 22 | `315cd0bc-ec9c-4452-825a-3122937d663e` | Sağlık & Medikal |
| 23 | `47b0a29e-19bb-4a92-9a2e-ad4ccf42ff28` | Çiçek & Bahçe |
| 24 | `5c661f4e-ac89-4737-a2d8-911811fabe5c` | Hediyelik & Parti |

Acceptance kanıtı:

- Root count/name/UUID/duplicate/orphan: PASS, exact `24`
- Full real traversal: `1563`; `24/244/1096/199`; structural leaf `1245`
- L2 leaf: `TV & Görüntü Sistemleri`
- L3 leaf: `Ekmekler`
- L4 leaf: `Mercimek`
- Multi-level container: `Bakliyat, Tahıl & Makarna`
- Deep server breadcrumb:
  `Gıda & İçecek > Bakliyat, Tahıl & Makarna > Bakliyat > Mercimek`
- L1→L2 children, recursive descendants, back-stack/breadcrumb order: PASS
- Server-authoritative search for root/container/L4 leaf: PASS
- Search matched node/path/leaf-container/version truth: PASS
- RESOLVED `acil-yol-cekme-ekipmani`: PASS
- AMBIGUOUS `ag-harici-depolama-baski`: PASS
- TOMBSTONE `antiseptik-dezenfeksiyon-urunu`: PASS
- UNRESOLVED `ahsap-oyuncak`: PASS
- L2/L3/L4 structural leaf exact-scope qualification: empty/PASS
- Empty product scope: valid empty result; runtime error veya client conversion yok
- Policy distribution: `NORMAL 770 / REGULATED 553 /
  LEGAL_REVIEW_REQUIRED 240`
- Review distribution: `not_required 486 / pending 1077`
- Lifecycle/assignability/version/preview metadata preservation: PASS
- Silent legacy fallback: `NO`

## Final safe state

- Preview: `OFF`
- Capability: `SUPPORTED_PREVIEW_OFF`
- Canonical process opt-in: `OFF/default false`
- Development default: `LEGACY_RUNTIME`
- Production default: `LEGACY_RUNTIME`
- Public/pilot/assignable: `0/0/0`
- Taxonomy/lifecycle: `1563 / staged=1563`
- L1/L2/L3/L4/leaf: `24/244/1096/199/1245`
- Unique UUID/allocation/mismatch: `1563/1563/0`
- Reachable/duplicate path/orphan-level mismatch/L5: `1563/0/0/0`
- Ledger: exact `11/11`
- V1 / strict V2: `7/7` / `8/8`
- Product/shop/listing: `0/0/0`
- Auth users/identities/sessions: `0/0/0`
- Storage objects: `0`
- Development health/reachability: `Healthy / PASS`

## Local validation

- Live real-client acceptance: `1/1 PASS`
- Post-preview targeted taxonomy + Cart V2/QR/reviews/wishlist/seller/Auth:
  `480/480 PASS`
- Full Flutter: `1294 PASS / 0 FAIL / 6` existing explicit live skips
- New skip: `0`
- Flutter analyzer: `0 issues`
- Test harness normal/default run: PASS without remote access and without skip

## Safety conclusion

- Development read: `YES — authorized`
- Development config write: `YES — two bounded ON/OFF cycles via trusted setter`
- Taxonomy-row write: `NO`
- Migration/RLS/RPC write: `NO`
- Auth/Storage write: `NO`
- Production access: `NO`
- Service-role material in Flutter/repo/docs/output: `NO`
- Temporary publishable-key process reference: cleared; key never printed

Canonical taxonomy Development implementation/acceptance is complete. This result
does not authorize public/pilot activation or any Production rollout.
