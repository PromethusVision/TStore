# Wave 34C — Variable-Depth Client Audit

**Canonical kural:** `L1 -> L2 -> L3 -> optional L4`; assignable leaf L2, L3 veya
L4 olabilir. Leaf olmak yapısal, assignable olmak lifecycle/policy kontrollüdür.
Depth tek başına ürün atanabilirliği kanıtlamaz.

## Mevcut traversal gerçeği

```text
Home/getCategories (all active rows)
  -> her satır için SubCategoryView
      -> products.category_id == selected category id
```

Repository'de root ve one-hop child sorguları bulunmasına rağmen aktif Home/Cubit
wiring'i bunları kullanmaz. `SubCategoryView` child node okumaz. Sonuç olarak mevcut
client gerçekte tree traversal yapmaz; flat ID filtreleme yapar.

## Sabit-depth ve leaf varsayımı bulguları

| Konum | Bulgu | Örnek sonuç | Sınıf |
|---|---|---|---|
| `CategoryEntity.isParent` | `parentId == null` ifadesi “has children” değil “is root”tur. | Child taşıyan L2 false döner; leaf L2 de false döner. | `MUST_CHANGE_WITH_MIGRATION` |
| `CategoryRepository.getSubCategories` | Yalnız one-hop API vardır; path/ancestor yoktur. | L4'e ilerlemek caller recursion ve ayrı state ister; mevcut caller yoktur. | `SAFE_PRE_MIGRATION` contract |
| `GetCategoriesUsecase` / `CategoriesCubit` | All-active flat result. | 1487-row owner-final detailed design ve anchor node'ları root kart gibi ele alınabilir. | `MUST_CHANGE_WITH_MIGRATION` |
| `HomeCategories` | Her node'yu doğrudan product destination sayar. | L1 `Ev & Yaşam` exact ürün sorgusu çoğunlukla boş olur. | `MUST_CHANGE_WITH_MIGRATION` |
| `SubCategoryView` | Child/leaf kontrolü yok; exact product query. | Branch boş state ile gerçek “ürün yok” aynı görünür. | `MUST_CHANGE_WITH_MIGRATION` |
| `ProductRepositoryImpl` | Exact equality only. | L2/L3 branch altındaki leaf ürünleri görünmez. | `MUST_CHANGE_WITH_MIGRATION` |
| Search category selection | İlk match ID'si exact product query. | Non-leaf match ürün katkısı vermez; diğer matched branch'ler yok sayılır. | `MUST_CHANGE_WITH_MIGRATION` |
| AppBar/list summary | Yalnız current `title`. | Ancestor path yok; aynı adlı leaf disambiguation yok. | `MUST_CHANGE_WITH_MIGRATION` correctness, `UI_KIT_PHASE` polish |
| Navigator stack | Material route ile tek ekran push/pop. | Path yeniden yükleme, stale/retired ancestor veya link restore yok. | `MUST_CHANGE_WITH_MIGRATION` |
| Product category join | Tek `categories(name)`. | Breadcrumb ve historical path kurulamaz. | `MUST_CHANGE_WITH_MIGRATION` |

## Node davranış matrisi

| Node | Canonical expected behavior | Current client behavior | Gate |
|---|---|---|---|
| Active L1 with children | Ordered L2 children; optional server-defined discovery summary. | Exact product list. | BLOCKER |
| Active L2 branch | Ordered L3 children; optional explicit descendant roll-up. | Exact product list. | BLOCKER |
| Active assignable L2 leaf | Exact leaf products. | Exact product list; tesadüfen doğru. | Contract needed |
| Active L3 branch | Ordered L4 children. | Exact product list. | BLOCKER |
| Active assignable L3 leaf | Exact leaf products. | Exact product list; leaf doğrulanmaz. | Contract needed |
| Active assignable L4 leaf | Exact leaf products. | Exact product list; leaf doğrulanmaz. | Contract needed |
| Structural leaf, non-assignable | Policy/lifecycle message; ürün ataması ve normal discovery kapalı. | Normal exact product screen. | BLOCKER |
| Inactive/retired node | Canonical successor redirect veya safe unavailable state. | `getCategoryById` active filtresiz; navigation elindeki ad/ID ile sorgular. | BLOCKER |
| Unknown/stale ID | Safe not-found; no sibling/root fallback. | Empty products ile “ürün yok” ayrımı yapılamaz. | BLOCKER |

## Minimum client contract

Bu audit schema önermeden client'ın ihtiyaç duyduğu minimum semantiği tanımlar:

- stable opaque `nodeId` (display name/slug identity değildir);
- `parentId`, `depth`, `isLeaf`, `isAssignable`, `isActive` ve lifecycle/successor;
- owner-approved display label ve deterministic `sortOrder`;
- path/ancestor projection veya tek bounded path read;
- taxonomy manifest/version;
- root, child ve search için bounded queries;
- product query için typed `EXACT_LEAF` / `DESCENDANTS` scope;
- retired/moved node için alias/successor çözümünün tek authoritative yeri.

`hasChildren` client'ta yalnız `!isLeaf` tahminiyle veya `depth < 4` ile
üretilmemeli; response veya child query sonucu authoritative olmalıdır.

## Güvenli implementation sırası

1. Versioned backend response ve lifecycle sözleşmesini dondur.
2. Geriye uyumlu node/path domain modelini ve fixture factory'sini ekle.
3. Root/children/path repository metotlarını test doubles ile hazırla.
4. Generic browse state machine'i L1–L4 table tests ile kanıtla.
5. Descendant product query server contract'ını ekle ve sibling leakage testini geçir.
6. Home/search destinations'ı yeni state machine'e geçir.
7. Inactive/retired/unknown ve back-stack testlerini tamamla.
8. Yalnız bundan sonra final UI Kit breadcrumb/label polish yap.

## Kesin test hazırlığı

- L2 leaf, L2 branch, L3 leaf, L3 branch ve L4 leaf fixture'ları;
- depth değeri ile leaf bilgisinin çeliştiği malformed response fail-closed testi;
- her parent altında deterministic order ve sibling isolation;
- branch'te empty children ile backend error ayrımı;
- route push/pop sonrası aynı node/path state'i;
- stale first request'in yeni seçili branch'i ezmemesi;
- 24 root dışında node'un Home root projection'a sızmaması;
- 1,000+ node payload'da all-tree Home fetch yapılmadığının repository testi.

`VARIABLE_DEPTH_AUDIT: PASS`

`REMOTE_RUNTIME_TOUCHED: NO`
