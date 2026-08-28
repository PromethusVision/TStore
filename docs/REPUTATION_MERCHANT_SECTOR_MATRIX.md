# Merchant Reputation Sector Matrix

**State:** PROPOSED FOR OWNER REVIEW

**Scope:** Workstream BA — proposed 67 assignable merchant-sector leaves

**Read-only source:** `origin/agent2/w16-merchant-sector-taxonomy-foundation`

## Interpretation

The wider merchant taxonomy is proposed, not canonical. The three beauty leaves marked `CONFIRMED_SUBTREE` preserve their source status without finalizing any other leaf. Sector controls may tune evidence freshness, confidence labels and policy review; they must not create paid reputation, hide ratings or treat a new merchant as untrusted.

| # | Proposed assignable leaf | Source state | Sector posture | Reputation notes |
|---:|---|---|---|---|
| 1 | Market, Bakkal & Süpermarket | PROPOSED | STANDARD | Listing accuracy and verified-purchase reliability; policy-sensitive goods excluded from positive volume signals. |
| 2 | Kasap | PROPOSED | STANDARD | Freshness complaints need verified, appealable operational evidence. |
| 3 | Şarküteri | PROPOSED | STANDARD | Availability/listing accuracy; regulated-goods boundary applies. |
| 4 | Manav | PROPOSED | STANDARD | Volatile availability should use recency windows. |
| 5 | Fırın | PROPOSED | STANDARD | Volatile availability should use recency windows. |
| 6 | Pastane & Tatlıcı | PROPOSED | STANDARD | Rating remains separate; verified activity is confidence, not quality proof. |
| 7 | Kuruyemişçi | PROPOSED | STANDARD | Normal verified evidence. |
| 8 | Aktar | PROPOSED | POLICY_REVIEW | Health claims/supplement-like inventory cannot create medical-quality reputation. |
| 9 | İçecek & Su Bayii | PROPOSED | POLICY_REVIEW | Alcohol-related events fail closed and never earn trust badges. |
| 10 | Giyim Mağazası | PROPOSED | STANDARD | Returns/corrections excluded from positive settled counts. |
| 11 | Ayakkabı Mağazası | PROPOSED | STANDARD | Exchanges are corrections, not extra positive events. |
| 12 | Çanta & Aksesuar Mağazası | PROPOSED | STANDARD | Normal verified evidence. |
| 13 | İç Giyim Mağazası | PROPOSED | PRIVACY_SENSITIVE | Never disclose purchase-category behavior at customer level. |
| 14 | Telefoncu & GSM Mağazası | PROPOSED | HIGH_VALUE | High-value/identity fraud controls; service/line activation excluded. |
| 15 | Elektronik Mağazası | PROPOSED | HIGH_VALUE | Return and serial-fraud monitoring; no spend-weighted trust. |
| 16 | Bilgisayarcı | PROPOSED | HIGH_VALUE | Product/service events must be separated. |
| 17 | Beyaz Eşya & Ev Aletleri Mağazası | PROPOSED | HIGH_VALUE | Delivery/cancellation settlement and branch attribution matter. |
| 18 | Mobilya Mağazası | PROPOSED | DELAYED_SETTLEMENT | Delivery/cancellation evidence precedes durable positive signals. |
| 19 | Ev Tekstili Mağazası | PROPOSED | STANDARD | Normal verified evidence. |
| 20 | Züccaciye & Mutfak Gereçleri Mağazası | PROPOSED | STANDARD | Normal verified evidence. |
| 21 | Halı & Kilim Mağazası | PROPOSED | DELAYED_SETTLEMENT | Delivery/return correction handling. |
| 22 | Perdeci | PROPOSED | MIXED_SERVICE | Product and measurement/installation service evidence stay distinct. |
| 23 | Nalbur & Hırdavatçı | PROPOSED | STANDARD | Restricted items fail closed at product-policy layer. |
| 24 | Yapı Malzemeleri Satıcısı | PROPOSED | DELAYED_SETTLEMENT | Bulk delivery and correction evidence require maturity. |
| 25 | Elektrik Malzemeleri Satıcısı | PROPOSED | STANDARD | Safety claims must not be inferred from volume. |
| 26 | Tesisat Malzemeleri Satıcısı | PROPOSED | STANDARD | Product accuracy signals only. |
| 27 | Boya & Dekorasyon Malzemeleri Satıcısı | PROPOSED | POLICY_REVIEW | Chemical/restricted product events fail closed. |
| 28 | Oto Yedek Parçacı | PROPOSED | FITMENT_SENSITIVE | Compatibility/listing accuracy must use disputeable verified corrections. |
| 29 | Oto Aksesuar Mağazası | PROPOSED | FITMENT_SENSITIVE | Fitment accuracy is product-specific, not whole-merchant truth. |
| 30 | Lastikçi | PROPOSED | MIXED_SERVICE | Product sale and installation/service evidence stay distinct. |
| 31 | Motosiklet Mağazası | PROPOSED | HIGH_VALUE | Settlement and regulated-product controls. |
| 32 | Motosiklet Yedek Parça & Aksesuar Mağazası | PROPOSED | FITMENT_SENSITIVE | Compatibility corrections must not become hidden penalties. |
| 33 | Bisiklet Mağazası | PROPOSED | MIXED_SERVICE | Separate product and service evidence. |
| 34 | Kozmetik & Kişisel Bakım Mağazası | PROPOSED | POLICY_REVIEW | Health claims do not create reputation; customer privacy applies. |
| 35 | Parfümeri | PROPOSED | STANDARD | Counterfeit disputes need human review; purchase volume is not authenticity proof. |
| 36 | Erkek Berberi | CONFIRMED_SUBTREE | SERVICE_SENSITIVE | Future service completion evidence differs from product purchase evidence. |
| 37 | Kadın Kuaförü | CONFIRMED_SUBTREE | SERVICE_SENSITIVE | Avoid sensitive customer-level disclosure and beauty-outcome inference. |
| 38 | Güzellik Salonu | CONFIRMED_SUBTREE | POLICY_REVIEW | Health-service boundary and advertising rules need review. |
| 39 | Anne & Bebek Mağazası | PROPOSED | POLICY_REVIEW | Infant/safety product incentives and reputation signals fail closed. |
| 40 | Oyuncakçı | PROPOSED | POLICY_REVIEW | Age/restricted product events excluded; normal items may qualify later. |
| 41 | Hobi & El Sanatları Mağazası | PROPOSED | STANDARD | Restricted chemicals/tools fail closed at product layer. |
| 42 | Müzik & Enstrüman Mağazası | PROPOSED | STANDARD | Product and lesson/repair services remain separate. |
| 43 | Kitapçı | PROPOSED | STANDARD | Normal verified evidence. |
| 44 | Kırtasiye | PROPOSED | STANDARD | Normal verified evidence. |
| 45 | Ofis Malzemeleri Mağazası | PROPOSED | STANDARD | Normal verified evidence. |
| 46 | Spor Malzemeleri Mağazası | PROPOSED | POLICY_REVIEW | Supplements and restricted goods excluded from positive signals. |
| 47 | Outdoor & Kamp Mağazası | PROPOSED | POLICY_REVIEW | Weapons/hunting/restricted equipment fail closed. |
| 48 | Balıkçılık & Av Malzemeleri Mağazası | PROPOSED | POLICY_REVIEW | Weapon/hunting regulation requires explicit approval. |
| 49 | Pet Shop | PROPOSED | POLICY_REVIEW | Live-animal/veterinary boundaries require review. |
| 50 | Akvaryumcu | PROPOSED | POLICY_REVIEW | Live-animal welfare and veterinary claims require review. |
| 51 | Pet Kuaförü | PROPOSED | SERVICE_SENSITIVE | Service completion and welfare disputes require distinct evidence. |
| 52 | Optik Mağazası | PROPOSED | POLICY_REVIEW | Medical-device/prescription boundaries; no health-outcome score. |
| 53 | Kuyumcu | PROPOSED | HIGH_VALUE | High-value fraud/AML-adjacent review; no spend-weighted reputation. |
| 54 | Saatçi | PROPOSED | MIXED_SERVICE | Product and repair evidence separate. |
| 55 | Medikal Ürün Mağazası | PROPOSED | POLICY_REVIEW | Medical product rules; reward/reputation fail closed. |
| 56 | Çiçekçi | PROPOSED | STANDARD | Volatile availability and substitution corrections need recency. |
| 57 | Bahçe & Yetiştirme Ürünleri Mağazası | PROPOSED | POLICY_REVIEW | Pesticide/chemical/regulated-input events fail closed. |
| 58 | Hediyelik Eşya Mağazası | PROPOSED | STANDARD | Ordinary goods only; regulated subproducts excluded. |
| 59 | Parti Malzemeleri Mağazası | PROPOSED | POLICY_REVIEW | Pyrotechnic/alcohol-linked goods fail closed. |
| 60 | Telefon & Elektronik Teknik Servisi | PROPOSED | SERVICE_SENSITIVE | Purchase QR is insufficient for repair-quality reputation; future service evidence needed. |
| 61 | Bilgisayar Teknik Servisi | PROPOSED | SERVICE_SENSITIVE | Future service completion, warranty and dispute evidence needed. |
| 62 | Beyaz Eşya Teknik Servisi | PROPOSED | SERVICE_SENSITIVE | Branch/technician/service completion and revisit signals need design. |
| 63 | Terzi & Giyim Tadilatı | PROPOSED | SERVICE_SENSITIVE | Product purchase evidence cannot stand in for service quality. |
| 64 | Ayakkabı Tamircisi | PROPOSED | SERVICE_SENSITIVE | Future service evidence needed. |
| 65 | Anahtarcı | PROPOSED | PRIVACY_SENSITIVE | Location/security details must never become public evidence. |
| 66 | Kuru Temizleme & Çamaşırhane | PROPOSED | PRIVACY_SENSITIVE | Service evidence must minimize item/customer disclosure. |
| 67 | Bisiklet Servisi | PROPOSED | SERVICE_SENSITIVE | Future service completion and correction evidence needed. |

## Cross-sector conclusions

- `verified_purchase_count` can provide activity confidence for product retailers, but not universal quality proof.
- The 12 service and 2 mixed source classifications need a future service-completion contract; the existing physical product purchase event must not be stretched into service reputation.
- Shop-versus-merchant aggregation remains an owner decision. Until then, branch evidence stays branch-scoped and portable merchant claims remain uncomputed.
- Policy-sensitive sectors are ineligible for positive reward/reputation derivation until legal/policy review and item-level classification are complete.
- Every sector preserves insufficient-history fairness, merchant appeal, human fraud review and visible independent customer ratings.
