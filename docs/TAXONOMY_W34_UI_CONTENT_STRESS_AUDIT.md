# Wave 34C — Final Category Name UI Content Stress Audit

**Yöntem:** Static source/code audit. Owner-final 24 L1 adları ve
`TAXONOMY_W33_RESOLVED_UNIFIED_CANDIDATE_TREE.csv` içindeki 22 detaylı domainin
1487 L2–L4 satırı incelendi. Flutter widget/golden değiştirilmedi; sonuç pixel-perfect
visual acceptance değildir.

## 24 final L1 label

| # | Final label | Karakter |
|---:|---|---:|
| 1 | Gıda & İçecek | 13 |
| 2 | Giyim & Moda | 12 |
| 3 | Ayakkabı | 8 |
| 4 | Çanta & Aksesuar | 16 |
| 5 | Elektronik | 10 |
| 6 | Bilgisayar & Tablet | 19 |
| 7 | Beyaz Eşya & Ev Aletleri | 24 |
| 8 | Ev & Yaşam | 10 |
| 9 | Züccaciye & Mutfak | 18 |
| 10 | Yapı, Hırdavat & Tesisat | 24 |
| 11 | Otomotiv & Motosiklet | 21 |
| 12 | Kozmetik & Kişisel Bakım | 24 |
| 13 | Anne & Bebek | 12 |
| 14 | Oyuncak & Hobi | 14 |
| 15 | Müzik & Enstrüman | 17 |
| 16 | Spor & Outdoor | 14 |
| 17 | Kitap | 5 |
| 18 | Kırtasiye & Ofis | 16 |
| 19 | Evcil Hayvan Ürünleri | 21 |
| 20 | Gözlük & Optik | 14 |
| 21 | Saat & Takı | 11 |
| 22 | Sağlık & Medikal | 16 |
| 23 | Çiçek & Bahçe | 13 |
| 24 | Hediyelik & Parti | 17 |

17/24 label 12 karakterden uzundur. Bu eşik pixel fit garantisi değildir; mevcut
52 px, 8.5 pt, tek satır Home category kartında yüksek bilgi-kesilmesi riskini
göstermek için statik uyarıdır. Widget `ellipsis` kullandığı için render overflow
yerine anlaşılmaz/truncated ad üretmesi daha olasıdır.

## Gerçek uzun lower-node örnekleri

En uzun tek segmentler:

| Karakter | Final node label |
|---:|---|
| 48 | Sürpriz & Rastgele İçerikli Koleksiyon Paketleri |
| 47 | Tebrik Kartları, Davetiyeler & Kutlama Yazıları |
| 46 | Oyuncak Araçlar & Uzaktan Kumandalı Oyuncaklar |
| 44 | Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri |
| 44 | Enstrüman Aksesuar, Bakım & Sarf Malzemeleri |
| 43 | Günlük Yaşam & Erişilebilirlik Yardımcıları |
| 43 | Bebek Sofra Ürünleri & Alıştırma Bardakları |
| 42 | Biberon Temizleme & Hazırlama Aksesuarları |
| 41 | Elektronik Alarm & İmmobilizer Sistemleri |
| 40 | Kamp Ocağı & Outdoor Pişirme Ekipmanları |

En uzun full paths 122 karaktere ulaşır. İki temsilî örnek:

- `Beyaz Eşya & Ev Aletleri > Elektrikli Kişisel Bakım Cihazları > Saç Bakım Cihazları > Saç Düzleştirici & Şekillendiriciler`
- `Beyaz Eşya & Ev Aletleri > Elektrikli Kişisel Bakım Cihazları > Elektrikli Ağız Bakım Cihazları > Elektrikli Diş Fırçaları`

Bu path'ler tek satır breadcrumb olarak gösterilmemeli; compact/collapsible path
tasarımı UI Kit phase'inde görsel kabul almalıdır. Stable node ID hiçbir zaman
truncated label/path'ten türetilmemelidir.

## Surface audit

| Surface | Current constraint | Finding | Classification |
|---|---|---|---|
| Home category rail | 52 px item, title `maxLines: 1`, 8.5 pt ellipsis | 24 L1'in okunabilir biçimde ayrışması kanıtlanmıyor; old five-category test 1400 px viewport kullanıyor. | Data source `MUST_CHANGE_WITH_MIGRATION`; visual layout `UI_KIT_PHASE` |
| Home category image | 46×46 circle, fallback icon old demo names/index | Canonical L1 icon/media map yoksa aynı döngüsel icon farklı domainlere atanır. | `UI_KIT_PHASE`; media identity migration-coordinated |
| Home search suggestions | Title/subtitle each one line; subtitle sabit “Kategori” | Long/same-name leaf path görünmez. | Correctness `MUST_CHANGE_WITH_MIGRATION`; visual `UI_KIT_PHASE` |
| All search category chips | `Wrap` + `ActionChip` full name | Wrap taşmayı azaltır fakat 48-char leaf mobile width'te çok satır/density sorunu yaratabilir; path yok. | `UI_KIT_PHASE` after path contract |
| Category AppBar | One line, 18 pt ellipsis | Long current node kesilir; ancestor görünmez. | `UI_KIT_PHASE`; breadcrumb correctness migration-coordinated |
| Category summary | One-line title ellipsis | Uzun node adı ürün sayısının önüne geçebilir. | `UI_KIT_PHASE` |
| Product cards | Brand yoksa category name, one line ellipsis | Leaf label secondary metadata olarak kesilebilir; product function bozulmaz. | `UI_KIT_PHASE` / pilot-deferable if accessible elsewhere |
| Product Details | Category/breadcrumb göstermez | Overflow yok; taxonomy context de yok. | `SAFE_PRE_MIGRATION` decision, then `UI_KIT_PHASE` |
| Breadcrumb | Aktif widget yok | 3–4 level path için henüz layout/semantics yok. | `MUST_CHANGE_WITH_MIGRATION` correctness + `UI_KIT_PHASE` visuals |

## Acceptance preparation

UI rollout başlamadan aşağıdaki widget/golden matrisi hazırlanmalıdır:

- widths: 320, 360, 390, 430 logical px;
- text scale: 1.0, 1.3, 1.5, 2.0;
- 24 L1'in tamamı, 48-char leaf ve 122-char L4 path;
- Turkish glyphs: `İ`, `ı`, `Ğ`, `ğ`, `Ş`, `ş`, `Ç`, `ç`, `Ü`, `ü`, `Ö`, `ö`;
- Home horizontal scroll/focus order, touch target ve screen-reader full label;
- search chip/suggestion, AppBar, empty/error/loading ve breadcrumb states;
- visual ellipsis varsa semantics/full accessible label ve yanlış-node seçimini önleyen path;
- no `RenderFlex overflow`, clipped tap target veya label-as-ID behavior.

Cosmetic redesign bu görevde yapılmadı. Exact breakpoint, two-line vs compact-label,
breadcrumb collapse ve icon direction final UI Kit owner review konusudur.

`FINAL_CATEGORY_NAME_UI_STRESS: PASS`

`REMOTE_RUNTIME_TOUCHED: NO`
