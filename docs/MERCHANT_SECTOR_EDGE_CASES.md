# EsnaftaVar Mixed-Merchant Edge Cases

**State:** 100-CASE AUDIT — NO OWNER FINALIZATION

These cases are additional to `MERCHANT_SECTOR_STRESS_TEST.csv`. They challenge
primary/secondary identity, cross-domain inventory, retail/service separation and
policy gates. A suggested resolution is research guidance, not owner approval.

## Root boundary rules

1. **Identity over shelf stock:** a few products never create a second merchant
   sector.
2. **Durable business line:** a secondary needs a persistent, customer-facing line.
3. **One primary:** equal propositions require evidence; never assign two primaries.
4. **Products remain independent:** merchant classification never owns product
   placement.
5. **Retail/service separation:** labor and physical goods use different future
   catalogs/records.
6. **Mixed is operational metadata:** it does not require a new hybrid sector.
7. **Seasonality is not identity:** temporary holiday/school/garden stock does not
   rewrite the sector.
8. **Department threshold:** a staffed, signed, sustained department may be a
   secondary; an aisle is not.
9. **Regulation is orthogonal:** sector selection cannot prove authorization.
10. **Fail closed:** unclear optical, medical, precious-goods, animal, food,
    plant-protection or weapon-like scope routes to policy review.
11. **Generic vs specialist:** generic inventory stays under the merchant's real
    storefront identity; specialist compatibility affects Product Taxonomy/facets.
12. **Repair threshold:** free setup/warranty intake is not a repair-sector line; a
    customer-facing workshop can be.
13. **Branch-specific identity:** each public-facing branch classifies itself.
14. **No micro-sector inflation:** brands, single product types and audience labels
    remain aliases/facets/catalog signals.
15. **Unresolved means unresolved:** “other” free text is reviewed, not auto-published.
16. **Beauty subtree exactness:** only `Erkek Berberi`, `Kadın Kuaförü` and `Güzellik
    Salonu` are assignable confirmed leaves; no `Unisex Kuaför`.
17. **Gift is not product ownership:** flowers, books, food, jewellery and home goods
    keep their Product Taxonomy owners.
18. **Service price/booking out of scope:** sector resolution cannot finalize them.

## 100 difficult cases

| CASE_ID | SCENARIO | CANDIDATES | RECOMMENDED RESOLUTION | ROOT RULE | REVIEW |
|---|---|---|---|---|---|
| MEC-001 | Tabelada Market, Bakkal & Süpermarket yazıyor; pet maması ve bakım ürünü içindeki ikinci alan yalnız küçük raf/tezgâh. | Market, Bakkal & Süpermarket ↔ Pet Shop | Market, Bakkal & Süpermarket primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-002 | Market, Bakkal & Süpermarket ve Pet Shop tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Market, Bakkal & Süpermarket ↔ Pet Shop | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-003 | Market, Bakkal & Süpermarket içinde ayrı personel, tabela ve sürekli alanla Pet Shop bölümü çalışıyor. | Market, Bakkal & Süpermarket ↔ Pet Shop | Market, Bakkal & Süpermarket primary; Pet Shop secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-004 | Market, Bakkal & Süpermarket, yalnız sezon/kampanya döneminde pet maması ve bakım ürünü ekliyor ve sonra kaldırıyor. | Market, Bakkal & Süpermarket ↔ Pet Shop | Market, Bakkal & Süpermarket primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-005 | Tabelada Kırtasiye yazıyor; oyuncak ve eğitim kiti içindeki ikinci alan yalnız küçük raf/tezgâh. | Kırtasiye ↔ Oyuncakçı | Kırtasiye primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-006 | Kırtasiye ve Oyuncakçı tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Kırtasiye ↔ Oyuncakçı | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-007 | Kırtasiye içinde ayrı personel, tabela ve sürekli alanla Oyuncakçı bölümü çalışıyor. | Kırtasiye ↔ Oyuncakçı | Kırtasiye primary; Oyuncakçı secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-008 | Kırtasiye, yalnız sezon/kampanya döneminde oyuncak ve eğitim kiti ekliyor ve sonra kaldırıyor. | Kırtasiye ↔ Oyuncakçı | Kırtasiye primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-009 | Tabelada Kitapçı yazıyor; defter, kalem ve sınav kitabı içindeki ikinci alan yalnız küçük raf/tezgâh. | Kitapçı ↔ Kırtasiye | Kitapçı primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-010 | Kitapçı ve Kırtasiye tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Kitapçı ↔ Kırtasiye | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-011 | Kitapçı içinde ayrı personel, tabela ve sürekli alanla Kırtasiye bölümü çalışıyor. | Kitapçı ↔ Kırtasiye | Kitapçı primary; Kırtasiye secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-012 | Kitapçı, yalnız sezon/kampanya döneminde defter, kalem ve sınav kitabı ekliyor ve sonra kaldırıyor. | Kitapçı ↔ Kırtasiye | Kitapçı primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-013 | Tabelada Telefoncu & GSM Mağazası yazıyor; telefon satışı ve onarım içindeki ikinci alan yalnız küçük raf/tezgâh. | Telefoncu & GSM Mağazası ↔ Telefon & Elektronik Teknik Servisi | Telefoncu & GSM Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | OWNER_REVIEW |
| MEC-014 | Telefoncu & GSM Mağazası ve Telefon & Elektronik Teknik Servisi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Telefoncu & GSM Mağazası ↔ Telefon & Elektronik Teknik Servisi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-015 | Telefoncu & GSM Mağazası içinde ayrı personel, tabela ve sürekli alanla Telefon & Elektronik Teknik Servisi bölümü çalışıyor. | Telefoncu & GSM Mağazası ↔ Telefon & Elektronik Teknik Servisi | Telefoncu & GSM Mağazası primary; Telefon & Elektronik Teknik Servisi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | OWNER_REVIEW |
| MEC-016 | Telefoncu & GSM Mağazası, yalnız sezon/kampanya döneminde telefon satışı ve onarım ekliyor ve sonra kaldırıyor. | Telefoncu & GSM Mağazası ↔ Telefon & Elektronik Teknik Servisi | Telefoncu & GSM Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | OWNER_REVIEW |
| MEC-017 | Tabelada Bilgisayarcı yazıyor; bilgisayar satışı, kurulum ve onarım içindeki ikinci alan yalnız küçük raf/tezgâh. | Bilgisayarcı ↔ Bilgisayar Teknik Servisi | Bilgisayarcı primary; secondary yok. | IDENTITY_OVER_STOCK | OWNER_REVIEW |
| MEC-018 | Bilgisayarcı ve Bilgisayar Teknik Servisi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Bilgisayarcı ↔ Bilgisayar Teknik Servisi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-019 | Bilgisayarcı içinde ayrı personel, tabela ve sürekli alanla Bilgisayar Teknik Servisi bölümü çalışıyor. | Bilgisayarcı ↔ Bilgisayar Teknik Servisi | Bilgisayarcı primary; Bilgisayar Teknik Servisi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | OWNER_REVIEW |
| MEC-020 | Bilgisayarcı, yalnız sezon/kampanya döneminde bilgisayar satışı, kurulum ve onarım ekliyor ve sonra kaldırıyor. | Bilgisayarcı ↔ Bilgisayar Teknik Servisi | Bilgisayarcı primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | OWNER_REVIEW |
| MEC-021 | Tabelada Çiçekçi yazıyor; çiçek, kart ve hediyelik içindeki ikinci alan yalnız küçük raf/tezgâh. | Çiçekçi ↔ Hediyelik Eşya Mağazası | Çiçekçi primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-022 | Çiçekçi ve Hediyelik Eşya Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Çiçekçi ↔ Hediyelik Eşya Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-023 | Çiçekçi içinde ayrı personel, tabela ve sürekli alanla Hediyelik Eşya Mağazası bölümü çalışıyor. | Çiçekçi ↔ Hediyelik Eşya Mağazası | Çiçekçi primary; Hediyelik Eşya Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-024 | Çiçekçi, yalnız sezon/kampanya döneminde çiçek, kart ve hediyelik ekliyor ve sonra kaldırıyor. | Çiçekçi ↔ Hediyelik Eşya Mağazası | Çiçekçi primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-025 | Tabelada Kuyumcu yazıyor; takı, klasik saat ve onarım içindeki ikinci alan yalnız küçük raf/tezgâh. | Kuyumcu ↔ Saatçi | Kuyumcu primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-026 | Kuyumcu ve Saatçi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Kuyumcu ↔ Saatçi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-027 | Kuyumcu içinde ayrı personel, tabela ve sürekli alanla Saatçi bölümü çalışıyor. | Kuyumcu ↔ Saatçi | Kuyumcu primary; Saatçi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-028 | Kuyumcu, yalnız sezon/kampanya döneminde takı, klasik saat ve onarım ekliyor ve sonra kaldırıyor. | Kuyumcu ↔ Saatçi | Kuyumcu primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-029 | Tabelada Spor Malzemeleri Mağazası yazıyor; spor ekipmanı ve kamp ürünü içindeki ikinci alan yalnız küçük raf/tezgâh. | Spor Malzemeleri Mağazası ↔ Outdoor & Kamp Mağazası | Spor Malzemeleri Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-030 | Spor Malzemeleri Mağazası ve Outdoor & Kamp Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Spor Malzemeleri Mağazası ↔ Outdoor & Kamp Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-031 | Spor Malzemeleri Mağazası içinde ayrı personel, tabela ve sürekli alanla Outdoor & Kamp Mağazası bölümü çalışıyor. | Spor Malzemeleri Mağazası ↔ Outdoor & Kamp Mağazası | Spor Malzemeleri Mağazası primary; Outdoor & Kamp Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-032 | Spor Malzemeleri Mağazası, yalnız sezon/kampanya döneminde spor ekipmanı ve kamp ürünü ekliyor ve sonra kaldırıyor. | Spor Malzemeleri Mağazası ↔ Outdoor & Kamp Mağazası | Spor Malzemeleri Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-033 | Tabelada Nalbur & Hırdavatçı yazıyor; nalburiye ve sabit elektrik ürünü içindeki ikinci alan yalnız küçük raf/tezgâh. | Nalbur & Hırdavatçı ↔ Elektrik Malzemeleri Satıcısı | Nalbur & Hırdavatçı primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-034 | Nalbur & Hırdavatçı ve Elektrik Malzemeleri Satıcısı tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Nalbur & Hırdavatçı ↔ Elektrik Malzemeleri Satıcısı | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-035 | Nalbur & Hırdavatçı içinde ayrı personel, tabela ve sürekli alanla Elektrik Malzemeleri Satıcısı bölümü çalışıyor. | Nalbur & Hırdavatçı ↔ Elektrik Malzemeleri Satıcısı | Nalbur & Hırdavatçı primary; Elektrik Malzemeleri Satıcısı secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-036 | Nalbur & Hırdavatçı, yalnız sezon/kampanya döneminde nalburiye ve sabit elektrik ürünü ekliyor ve sonra kaldırıyor. | Nalbur & Hırdavatçı ↔ Elektrik Malzemeleri Satıcısı | Nalbur & Hırdavatçı primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-037 | Tabelada Kozmetik & Kişisel Bakım Mağazası yazıyor; kozmetik satışı ve güzellik hizmeti içindeki ikinci alan yalnız küçük raf/tezgâh. | Kozmetik & Kişisel Bakım Mağazası ↔ Güzellik Salonu | Kozmetik & Kişisel Bakım Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-038 | Kozmetik & Kişisel Bakım Mağazası ve Güzellik Salonu tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Kozmetik & Kişisel Bakım Mağazası ↔ Güzellik Salonu | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-039 | Kozmetik & Kişisel Bakım Mağazası içinde ayrı personel, tabela ve sürekli alanla Güzellik Salonu bölümü çalışıyor. | Kozmetik & Kişisel Bakım Mağazası ↔ Güzellik Salonu | Kozmetik & Kişisel Bakım Mağazası primary; Güzellik Salonu secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-040 | Kozmetik & Kişisel Bakım Mağazası, yalnız sezon/kampanya döneminde kozmetik satışı ve güzellik hizmeti ekliyor ve sonra kaldırıyor. | Kozmetik & Kişisel Bakım Mağazası ↔ Güzellik Salonu | Kozmetik & Kişisel Bakım Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-041 | Tabelada Optik Mağazası yazıyor; optik ürün, ölçüm ve evde sağlık cihazı içindeki ikinci alan yalnız küçük raf/tezgâh. | Optik Mağazası ↔ Medikal Ürün Mağazası | Optik Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-042 | Optik Mağazası ve Medikal Ürün Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Optik Mağazası ↔ Medikal Ürün Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-043 | Optik Mağazası içinde ayrı personel, tabela ve sürekli alanla Medikal Ürün Mağazası bölümü çalışıyor. | Optik Mağazası ↔ Medikal Ürün Mağazası | Optik Mağazası primary; Medikal Ürün Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-044 | Optik Mağazası, yalnız sezon/kampanya döneminde optik ürün, ölçüm ve evde sağlık cihazı ekliyor ve sonra kaldırıyor. | Optik Mağazası ↔ Medikal Ürün Mağazası | Optik Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-045 | Tabelada Anne & Bebek Mağazası yazıyor; bebek bakım ürünü ve çocuk giyimi içindeki ikinci alan yalnız küçük raf/tezgâh. | Anne & Bebek Mağazası ↔ Giyim Mağazası | Anne & Bebek Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-046 | Anne & Bebek Mağazası ve Giyim Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Anne & Bebek Mağazası ↔ Giyim Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-047 | Anne & Bebek Mağazası içinde ayrı personel, tabela ve sürekli alanla Giyim Mağazası bölümü çalışıyor. | Anne & Bebek Mağazası ↔ Giyim Mağazası | Anne & Bebek Mağazası primary; Giyim Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-048 | Anne & Bebek Mağazası, yalnız sezon/kampanya döneminde bebek bakım ürünü ve çocuk giyimi ekliyor ve sonra kaldırıyor. | Anne & Bebek Mağazası ↔ Giyim Mağazası | Anne & Bebek Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-049 | Tabelada Pet Shop yazıyor; pet ürünü ve grooming hizmeti içindeki ikinci alan yalnız küçük raf/tezgâh. | Pet Shop ↔ Pet Kuaförü | Pet Shop primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-050 | Pet Shop ve Pet Kuaförü tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Pet Shop ↔ Pet Kuaförü | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-051 | Pet Shop içinde ayrı personel, tabela ve sürekli alanla Pet Kuaförü bölümü çalışıyor. | Pet Shop ↔ Pet Kuaförü | Pet Shop primary; Pet Kuaförü secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-052 | Pet Shop, yalnız sezon/kampanya döneminde pet ürünü ve grooming hizmeti ekliyor ve sonra kaldırıyor. | Pet Shop ↔ Pet Kuaförü | Pet Shop primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-053 | Tabelada Bisiklet Mağazası yazıyor; bisiklet, parça ve onarım içindeki ikinci alan yalnız küçük raf/tezgâh. | Bisiklet Mağazası ↔ Bisiklet Servisi | Bisiklet Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | OWNER_REVIEW |
| MEC-054 | Bisiklet Mağazası ve Bisiklet Servisi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Bisiklet Mağazası ↔ Bisiklet Servisi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-055 | Bisiklet Mağazası içinde ayrı personel, tabela ve sürekli alanla Bisiklet Servisi bölümü çalışıyor. | Bisiklet Mağazası ↔ Bisiklet Servisi | Bisiklet Mağazası primary; Bisiklet Servisi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | OWNER_REVIEW |
| MEC-056 | Bisiklet Mağazası, yalnız sezon/kampanya döneminde bisiklet, parça ve onarım ekliyor ve sonra kaldırıyor. | Bisiklet Mağazası ↔ Bisiklet Servisi | Bisiklet Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | OWNER_REVIEW |
| MEC-057 | Tabelada Müzik & Enstrüman Mağazası yazıyor; enstrüman satışı, onarım ve ders içindeki ikinci alan yalnız küçük raf/tezgâh. | Müzik & Enstrüman Mağazası ↔ UNRESOLVED Müzik Teknik Servisi | Müzik & Enstrüman Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | OWNER_REVIEW |
| MEC-058 | Müzik & Enstrüman Mağazası ve UNRESOLVED Müzik Teknik Servisi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Müzik & Enstrüman Mağazası ↔ UNRESOLVED Müzik Teknik Servisi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-059 | Müzik & Enstrüman Mağazası içinde ayrı personel, tabela ve sürekli alanla UNRESOLVED Müzik Teknik Servisi bölümü çalışıyor. | Müzik & Enstrüman Mağazası ↔ UNRESOLVED Müzik Teknik Servisi | Müzik & Enstrüman Mağazası primary; UNRESOLVED Müzik Teknik Servisi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | OWNER_REVIEW |
| MEC-060 | Müzik & Enstrüman Mağazası, yalnız sezon/kampanya döneminde enstrüman satışı, onarım ve ders ekliyor ve sonra kaldırıyor. | Müzik & Enstrüman Mağazası ↔ UNRESOLVED Müzik Teknik Servisi | Müzik & Enstrüman Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | OWNER_REVIEW |
| MEC-061 | Tabelada Mobilya Mağazası yazıyor; hazır mobilya ve sabit özel dolap projesi içindeki ikinci alan yalnız küçük raf/tezgâh. | Mobilya Mağazası ↔ Yapı Malzemeleri Satıcısı | Mobilya Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | OWNER_REVIEW |
| MEC-062 | Mobilya Mağazası ve Yapı Malzemeleri Satıcısı tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Mobilya Mağazası ↔ Yapı Malzemeleri Satıcısı | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-063 | Mobilya Mağazası içinde ayrı personel, tabela ve sürekli alanla Yapı Malzemeleri Satıcısı bölümü çalışıyor. | Mobilya Mağazası ↔ Yapı Malzemeleri Satıcısı | Mobilya Mağazası primary; Yapı Malzemeleri Satıcısı secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | OWNER_REVIEW |
| MEC-064 | Mobilya Mağazası, yalnız sezon/kampanya döneminde hazır mobilya ve sabit özel dolap projesi ekliyor ve sonra kaldırıyor. | Mobilya Mağazası ↔ Yapı Malzemeleri Satıcısı | Mobilya Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | OWNER_REVIEW |
| MEC-065 | Tabelada Perdeci yazıyor; perde dikimi ve genel ev tekstili içindeki ikinci alan yalnız küçük raf/tezgâh. | Perdeci ↔ Ev Tekstili Mağazası | Perdeci primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-066 | Perdeci ve Ev Tekstili Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Perdeci ↔ Ev Tekstili Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-067 | Perdeci içinde ayrı personel, tabela ve sürekli alanla Ev Tekstili Mağazası bölümü çalışıyor. | Perdeci ↔ Ev Tekstili Mağazası | Perdeci primary; Ev Tekstili Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-068 | Perdeci, yalnız sezon/kampanya döneminde perde dikimi ve genel ev tekstili ekliyor ve sonra kaldırıyor. | Perdeci ↔ Ev Tekstili Mağazası | Perdeci primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-069 | Tabelada Fırın yazıyor; ekmek, unlu mamul ve sipariş pasta içindeki ikinci alan yalnız küçük raf/tezgâh. | Fırın ↔ Pastane & Tatlıcı | Fırın primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-070 | Fırın ve Pastane & Tatlıcı tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Fırın ↔ Pastane & Tatlıcı | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-071 | Fırın içinde ayrı personel, tabela ve sürekli alanla Pastane & Tatlıcı bölümü çalışıyor. | Fırın ↔ Pastane & Tatlıcı | Fırın primary; Pastane & Tatlıcı secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-072 | Fırın, yalnız sezon/kampanya döneminde ekmek, unlu mamul ve sipariş pasta ekliyor ve sonra kaldırıyor. | Fırın ↔ Pastane & Tatlıcı | Fırın primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-073 | Tabelada Kasap yazıyor; taze et ve işlenmiş/kahvaltılık ürün içindeki ikinci alan yalnız küçük raf/tezgâh. | Kasap ↔ Şarküteri | Kasap primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-074 | Kasap ve Şarküteri tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Kasap ↔ Şarküteri | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-075 | Kasap içinde ayrı personel, tabela ve sürekli alanla Şarküteri bölümü çalışıyor. | Kasap ↔ Şarküteri | Kasap primary; Şarküteri secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-076 | Kasap, yalnız sezon/kampanya döneminde taze et ve işlenmiş/kahvaltılık ürün ekliyor ve sonra kaldırıyor. | Kasap ↔ Şarküteri | Kasap primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-077 | Tabelada Elektronik Mağazası yazıyor; tüketici elektroniği ve ev cihazı içindeki ikinci alan yalnız küçük raf/tezgâh. | Elektronik Mağazası ↔ Beyaz Eşya & Ev Aletleri Mağazası | Elektronik Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-078 | Elektronik Mağazası ve Beyaz Eşya & Ev Aletleri Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Elektronik Mağazası ↔ Beyaz Eşya & Ev Aletleri Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-079 | Elektronik Mağazası içinde ayrı personel, tabela ve sürekli alanla Beyaz Eşya & Ev Aletleri Mağazası bölümü çalışıyor. | Elektronik Mağazası ↔ Beyaz Eşya & Ev Aletleri Mağazası | Elektronik Mağazası primary; Beyaz Eşya & Ev Aletleri Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-080 | Elektronik Mağazası, yalnız sezon/kampanya döneminde tüketici elektroniği ve ev cihazı ekliyor ve sonra kaldırıyor. | Elektronik Mağazası ↔ Beyaz Eşya & Ev Aletleri Mağazası | Elektronik Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-081 | Tabelada Oto Yedek Parçacı yazıyor; yedek parça, fitment ve aksesuar içindeki ikinci alan yalnız küçük raf/tezgâh. | Oto Yedek Parçacı ↔ Oto Aksesuar Mağazası | Oto Yedek Parçacı primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-082 | Oto Yedek Parçacı ve Oto Aksesuar Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Oto Yedek Parçacı ↔ Oto Aksesuar Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-083 | Oto Yedek Parçacı içinde ayrı personel, tabela ve sürekli alanla Oto Aksesuar Mağazası bölümü çalışıyor. | Oto Yedek Parçacı ↔ Oto Aksesuar Mağazası | Oto Yedek Parçacı primary; Oto Aksesuar Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-084 | Oto Yedek Parçacı, yalnız sezon/kampanya döneminde yedek parça, fitment ve aksesuar ekliyor ve sonra kaldırıyor. | Oto Yedek Parçacı ↔ Oto Aksesuar Mağazası | Oto Yedek Parçacı primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-085 | Tabelada Motosiklet Mağazası yazıyor; motosiklet, koruma ekipmanı ve parça içindeki ikinci alan yalnız küçük raf/tezgâh. | Motosiklet Mağazası ↔ Motosiklet Yedek Parça & Aksesuar Mağazası | Motosiklet Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-086 | Motosiklet Mağazası ve Motosiklet Yedek Parça & Aksesuar Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Motosiklet Mağazası ↔ Motosiklet Yedek Parça & Aksesuar Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-087 | Motosiklet Mağazası içinde ayrı personel, tabela ve sürekli alanla Motosiklet Yedek Parça & Aksesuar Mağazası bölümü çalışıyor. | Motosiklet Mağazası ↔ Motosiklet Yedek Parça & Aksesuar Mağazası | Motosiklet Mağazası primary; Motosiklet Yedek Parça & Aksesuar Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-088 | Motosiklet Mağazası, yalnız sezon/kampanya döneminde motosiklet, koruma ekipmanı ve parça ekliyor ve sonra kaldırıyor. | Motosiklet Mağazası ↔ Motosiklet Yedek Parça & Aksesuar Mağazası | Motosiklet Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-089 | Tabelada Bahçe & Yetiştirme Ürünleri Mağazası yazıyor; fide, toprak, canlı bitki ve kesme çiçek içindeki ikinci alan yalnız küçük raf/tezgâh. | Bahçe & Yetiştirme Ürünleri Mağazası ↔ Çiçekçi | Bahçe & Yetiştirme Ürünleri Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-090 | Bahçe & Yetiştirme Ürünleri Mağazası ve Çiçekçi tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Bahçe & Yetiştirme Ürünleri Mağazası ↔ Çiçekçi | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-091 | Bahçe & Yetiştirme Ürünleri Mağazası içinde ayrı personel, tabela ve sürekli alanla Çiçekçi bölümü çalışıyor. | Bahçe & Yetiştirme Ürünleri Mağazası ↔ Çiçekçi | Bahçe & Yetiştirme Ürünleri Mağazası primary; Çiçekçi secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-092 | Bahçe & Yetiştirme Ürünleri Mağazası, yalnız sezon/kampanya döneminde fide, toprak, canlı bitki ve kesme çiçek ekliyor ve sonra kaldırıyor. | Bahçe & Yetiştirme Ürünleri Mağazası ↔ Çiçekçi | Bahçe & Yetiştirme Ürünleri Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |
| MEC-093 | Tabelada Hediyelik Eşya Mağazası yazıyor; hediyelik, balon ve kutlama stoğu içindeki ikinci alan yalnız küçük raf/tezgâh. | Hediyelik Eşya Mağazası ↔ Parti Malzemeleri Mağazası | Hediyelik Eşya Mağazası primary; secondary yok. | IDENTITY_OVER_STOCK | NONE |
| MEC-094 | Hediyelik Eşya Mağazası ve Parti Malzemeleri Mağazası tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Hediyelik Eşya Mağazası ↔ Parti Malzemeleri Mağazası | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-095 | Hediyelik Eşya Mağazası içinde ayrı personel, tabela ve sürekli alanla Parti Malzemeleri Mağazası bölümü çalışıyor. | Hediyelik Eşya Mağazası ↔ Parti Malzemeleri Mağazası | Hediyelik Eşya Mağazası primary; Parti Malzemeleri Mağazası secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | NONE |
| MEC-096 | Hediyelik Eşya Mağazası, yalnız sezon/kampanya döneminde hediyelik, balon ve kutlama stoğu ekliyor ve sonra kaldırıyor. | Hediyelik Eşya Mağazası ↔ Parti Malzemeleri Mağazası | Hediyelik Eşya Mağazası primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | NONE |
| MEC-097 | Tabelada Nalbur & Hırdavatçı yazıyor; kilit ürünü, anahtar kesim ve çilingir hizmeti içindeki ikinci alan yalnız küçük raf/tezgâh. | Nalbur & Hırdavatçı ↔ Anahtarcı | Nalbur & Hırdavatçı primary; secondary yok. | IDENTITY_OVER_STOCK | POLICY_REVIEW |
| MEC-098 | Nalbur & Hırdavatçı ve Anahtarcı tabelada, ciroda ve müşteri geliş nedeninde eşit görünüyor. | Nalbur & Hırdavatçı ↔ Anahtarcı | Tek primary için kanıt iste; diğeri gerçek iş koluysa secondary. Otomatik karar verme. | ONE_PRIMARY | OWNER_REVIEW |
| MEC-099 | Nalbur & Hırdavatçı içinde ayrı personel, tabela ve sürekli alanla Anahtarcı bölümü çalışıyor. | Nalbur & Hırdavatçı ↔ Anahtarcı | Nalbur & Hırdavatçı primary; Anahtarcı secondary adayı; ürünler kendi Product Taxonomy leaf'lerinde. | DEPARTMENT_THRESHOLD | POLICY_REVIEW |
| MEC-100 | Nalbur & Hırdavatçı, yalnız sezon/kampanya döneminde kilit ürünü, anahtar kesim ve çilingir hizmeti ekliyor ve sonra kaldırıyor. | Nalbur & Hırdavatçı ↔ Anahtarcı | Nalbur & Hırdavatçı primary; geçici stok secondary veya sector change üretmez. | SEASONAL_NOT_IDENTITY | POLICY_REVIEW |

## Audit result

- Difficult cases: **100**
- Root boundary rules: **18**
- Owner-final state introduced: **0**
- Booking/reservation/service-price decision: **0 / TBD preserved**
- Confirmed beauty subtree changed: **NO**

`MERCHANT_EDGE_CASE_AUDIT: PASS`


