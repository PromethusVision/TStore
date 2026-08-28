# Ecosystem Owner Review Sequence

**State:** OPTIMIZED REVIEW ORDER — NO DECISION SELECTED

| Order | Root | Why now | What it unlocks | What can wait | Estimated owner complexity |
|---:|---|---|---|---|---|
| 1 | R01 | Release iddiasının platform ve kanıt sınırını önce belirler. | Signed artifact, physical acceptance ve CI/release gate’leri. | iOS açılışı kanıt hazır olana kadar bekleyebilir. | EASY |
| 2 | R04 | Catalog kimliği QR, review, search ve Ads object’ini belirler. | Product/Variant/Listing, barcode ve downstream snapshot tasarımı. | Universal variant kapsamı bekleyebilir. | MODERATE |
| 3 | R07 | Merchant’ın kim olduğu ve hangi shop’ta ne yapabildiği temel güvenlik kararıdır. | Listing writes, verifier, RLS ve Merchant App seam’i. | Enterprise rol ve multi-branch otomasyonu bekleyebilir. | EASY |
| 4 | R11 | Catalog ve merchant kimliği sonrası fiziksel kanıt zincirini kilitler. | Exact-shop QR, quantity snapshot ve review evidence. | Variable-measure aktivasyonu ROOT-05’e kadar bekleyebilir. | MODERATE |
| 5 | R09 | Pilotta hangi arzın güvenle açılacağını belirler. | Merchant/product activation, Ops queue ve ekonomik sistem allowlistleri. | Booking ve regulated self-service bekleyebilir. | MODERATE |
| 6 | R10 | Customer’a gösterilen listing doğruluğu ve minimum merchant iletişimini netleştirir. | Freshness, review interaction ve notification scope. | Full replies ve multichannel iletişim bekleyebilir. | EASY |
| 7 | R03 | Catalog identity netleşmeden taxonomy runtime değişimi güvenli değildir. | Taxonomy migration, facets, legacy reconciliation ve demo retirement. | Advanced facets ve legacy toplu geçiş bekleyebilir. | EASY |
| 8 | R05 | Public catalog’a merchant katkısının güven sınırını belirler. | Candidate workflow, media promotion ve variable measure gate’i. | Measure/media activation pilot ihtiyacı yoksa bekleyebilir. | MODERATE |
| 9 | R06 | Catalog correction sırasında verified history kaybını önler. | Merge/split ve review-collision implementation planı. | Nadir split UX’i implementasyona kadar bekleyebilir. | MODERATE |
| 10 | R08 | Merchant authority ve policy sonrası sector dilini güvenle final review’a taşır. | Onboarding vocabulary, secondary sector ve branch override. | Full 67-leaf runtime bekleyebilir. | MODERATE |
| 11 | R17 | Policy kararlarının uygulanması için minimum accountability gerekir. | Case, audit, containment, second review ve retention review. | Enterprise otomasyon bekleyebilir. | EASY |
| 12 | R18 | Release ve policy sınırları sonrası hangi pilot kanıtının toplanacağını belirler. | KPI registry, monitoring ve privacy budget. | Broad funnels ve profiling bekleyebilir. | EASY |
| 13 | R12 | Minimum merchant operating contract netleşince teslim kabı seçilebilir. | Controlled path ile full app sequencing. | Full ayrı app, pilot evidence sonrasına kalabilir. | VERY_EASY |
| 14 | R13 | Core pilot hazır olduğunda Ads’in gerekli olup olmadığı ayrıştırılır. | Ads workstream go/no-go ve object/surface sınırı. | Tüm Ads implementation/billing bekleyebilir. | VERY_EASY |
| 15 | R15 | Verified evidence mevcut olsa da ekonomi/lability ayrı karardır. | Reward workstream go/no-go ve shadow-ledger ihtiyacı. | Canlı points/redemption sistemi bekleyebilir. | VERY_EASY |
| 16 | R02 | Ana güvenlik/commerce kararlarını bloklamayan bağımsız privacy/UX kararıdır. | Nearby guest UX ve device-local retention. | Account personalization bekleyebilir. | EASY |
| 17 | R14 | Yalnız ROOT-13 Ads’e izin verirse anlamlıdır. | Pricing, targeting, attribution ve dispute modeli. | ROOT-13=A ise tamamı bekler. | HARD |
| 18 | R16 | Yeterli verified data olmadan public badge/reputation kararı erken olur. | Badge/signal/display roadmap’i. | Levels, challenges ve composite score bekleyebilir. | VERY_EASY |

Complexity counts: VERY_EASY=4; EASY=7; MODERATE=6; HARD=1.
OWNER_SELECTIONS: 0
