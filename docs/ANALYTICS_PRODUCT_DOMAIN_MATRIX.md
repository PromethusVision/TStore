# EsnaftaVar 24-L1 Product Analytics Coverage Matrix

**State:** `AUDIT — 24 OWNER-FINAL L1 NAMES; METRICS PROPOSED`

All domains use the same identity/authority model. Policy-sensitive domains may
restrict dimensions but do not change event meaning.

| # | Canonical L1 | Discovery/intent | Authoritative outcome | Main caveat |
|---:|---|---|---|---|
| 1 | Gıda & İçecek | Search/view/shop/directions | Verified purchase | Fresh/regulated attributes need policy |
| 2 | Giyim & Moda | Search/view/compare/wishlist/cart | Verified purchase | Size/variant normalization |
| 3 | Ayakkabı | Search/view/compare/wishlist/cart | Verified purchase | Size system/fit |
| 4 | Çanta & Aksesuar | Search/view/compare/wishlist/cart | Verified purchase | Product vs variant dimensions |
| 5 | Elektronik | Search/view/compare/wishlist/cart | Verified purchase | Model/compatibility identity |
| 6 | Bilgisayar & Tablet | Search/view/compare/wishlist/cart | Verified purchase | Component/compatibility identity |
| 7 | Beyaz Eşya & Ev Aletleri | Search/view/compare/directions | Verified purchase | Model/revision/service boundary |
| 8 | Ev & Yaşam | Search/view/compare/wishlist | Verified purchase | Dimension/material normalization |
| 9 | Züccaciye & Mutfak | Search/view/compare/wishlist | Verified purchase | Material/safe-use claims |
| 10 | Yapı, Hırdavat & Tesisat | Search/view/compare/directions | Verified purchase | Safety/compatibility/policy |
| 11 | Otomotiv & Motosiklet | Search/view/compare/directions | Verified purchase | Vehicle fitment/policy |
| 12 | Kozmetik & Kişisel Bakım | Search/view/wishlist/shop | Verified purchase | Claims/privacy/policy |
| 13 | Anne & Bebek | Search/view/compare/wishlist | Verified purchase | Safety/age suitability |
| 14 | Oyuncak & Hobi | Search/view/compare/wishlist | Verified purchase | Age/safety/split history |
| 15 | Müzik & Enstrüman | Search/view/compare/shop | Verified purchase | Variant/compatibility |
| 16 | Spor & Outdoor | Search/view/compare/directions | Verified purchase | Fit/safety/policy |
| 17 | Kitap | Search/view/wishlist/cart | Verified purchase | Edition/language identity |
| 18 | Kırtasiye & Ofis | Search/view/compare/cart | Verified purchase | Pack/variant identity |
| 19 | Evcil Hayvan Ürünleri | Search/view/compare/shop | Verified purchase | Species/health claims |
| 20 | Gözlük & Optik | Search/view/compare/shop | Verified purchase | Regulated/prescription privacy |
| 21 | Saat & Takı | Search/view/compare/wishlist | Verified purchase | High-value/fraud/policy |
| 22 | Sağlık & Medikal | Search/view/shop/directions | Verified purchase | Strict policy; sensitive intent |
| 23 | Çiçek & Bahçe | Search/view/shop/directions | Verified purchase | Live/regulated plant policy |
| 24 | Hediyelik & Parti | Search/view/wishlist/shop | Verified purchase | Occasion inference minimization |

Coverage is coherent at L1: soft discovery remains soft and verified purchase
retains one authority meaning. L2 proposal gaps and facet/policy owner decisions
remain runtime blockers.

`PRODUCT_L1_METRIC_COVERAGE: 24/24`
