# Merchant Pilot Source Registry

State: `READ-ONLY INPUTS — NOT MERGED`

Bu çalışma 28 Ağustos 2026 tarihinde `origin/main@fca935fdbe3053d2d9aa4bbb7a10b1f928007b63` tabanından hazırlanmıştır. Aşağıdaki dallar yalnız `git show` ile okunmuş, hiçbir kaynak dal merge edilmemiştir.

| Alan | Kaynak | Sabitlenen HEAD | Bu çalışmaya taşınan sözleşme |
|---|---|---|---|
| Merchant App | `origin/agent1/w17-merchant-app-master-foundation` | `2946e49194a29ddb247a47fd077110d2d681b84a` | ayrı merchant yüzeyi, sunucu yetkisi, listing ve QR sınırları |
| Esenler pilot | `origin/agent3/w26-esenler-commercial-pilot-foundation` | `aaccff79561c7f10eed9038add590d9ea5d993f9` | kontrollü cohort, assisted onboarding, fiziksel kabul |
| Backend | `origin/agent1/w21-platform-backend-contract-foundation` | `bbcb5f34b535c3ed910f0291d1125c8dd012389e` | capability/RLS/RPC, idempotency ve N/N-1 |
| Operations | `origin/agent2/w19-platform-operations-trust-safety-foundation` | `f015bb94bae6a4bf6dd6f02fffb419322d08d596` | case/audit, operatör sınırı, düzeltme modeli |
| QA / Release | `origin/agent2/w22-platform-qa-release-engineering-foundation` | `fc86f11d5d1896b497d3e4ada58ffd31105e3d54` | exact artifact, iki cihaz, manuel/Production gate ayrımı |
| Compliance | `origin/agent2/w24-turkiye-platform-compliance-foundation` | `57bb5734d8e1770d56b3437046b43ea10e6774b2` | merchant doğrulama, regüle ürün fail-closed, doğru beyan |
| Catalog | `origin/agent3/w16-canonical-product-catalog-foundation` | `b654e680ca72a79c109a098a237b9813b24516cc` | canonical product / variant / listing ayrımı, aday akışı |
| Merchant taxonomy | `origin/agent2/w16-merchant-sector-taxonomy-foundation` | `b60254d4d666a860e02989b617ea649cbb8b91dd` | sektör etiketi izin değildir; policy review ayrıdır |
| Analytics | `origin/agent3/w20-platform-event-analytics-observability-foundation` | `1045301e90440903481300bec27b6fea11da1655` | pilot sağlık sinyalleri, satış/gelir iddiası yasağı |
| Unified review | `origin/agent2/w28-unified-review-reputation-algorithm-foundation` | `4404ac338d145662b7751704c2d6df9c679d31f4` | product review ile structured shop evaluation ayrımı |
| Customer closeout | `origin/agent1/w16-customer-app-commercialization-closeout` | `1f1812cf9d65cd9ea4c8053f98f9a3c1342caeaa` | Customer App bağımlılıkları ve açık manuel gate'ler |
| Verified review backend | `origin/agent1/w6-verified-review-storage-backend` | `203ac8164c51b4c5bfe6c95f0952858502208eaa` | merchant-confirmed evidence ve tek aktif product review |
| Live QR | `origin/agent2/w4-live-qr-integration` | `15778f5ddcb2d024f05294df23f60ed24c36bf25` | canlı concurrency, replay, wrong-merchant ve snapshot kanıtı |

## Geçerlilik sınırı

- Bu kayıt bir entegrasyon veya owner onayı değildir.
- Kaynaklardaki gelecek mimarileri mevcut runtime gerçeği gibi sunmaz.
- Güncel runtime yalnız statik incelenmiştir; Development/Production'a erişilmemiştir.
- Uygulama anında kaynak HEAD'ler yeniden doğrulanmalı, çatışan owner-final karar varsa bu öneri güncellenmelidir.
