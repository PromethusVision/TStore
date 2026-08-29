# Wave 33 — Esenler Demo Mapping Simulation

**Durum:** `STATIC SIMULATION — DATA UNCHANGED`

Kaynak: `tool/demo_seed/esenler_demo_v1.json`.

Dataset sentetiktir ve **4 kategori, 20 product, 57 shop, 285 shop_product** taşır.
Bu çalışma JSON, seed, Development veya Production verisini değiştirmedi.

## 1. L1 conceptual bridge

| Demo category | Canonical L1 | Durum | Shop | Product | Listing |
|---|---|---|---:|---:|---:|
| Elektronik | Elektronik | `CANONICAL_FINAL` L1/L2 anchors | 14 | 5 | 70 |
| Kırtasiye | Kırtasiye & Ofis | `CANDIDATE_NOT_OWNER_FINAL` below final L1 | 14 | 5 | 70 |
| Gıda | Gıda & İçecek | `CANDIDATE_NOT_OWNER_FINAL` below final L1 | 14 | 5 | 70 |
| Ayakkabı | Ayakkabı | `CANDIDATE_NOT_OWNER_FINAL` below final L1 | 15 | 5 | 75 |
| **Toplam** |  |  | **57** | **20** | **285** |

Bu 4/4 conceptual mapping Phase A owner kararını korur. Demo category UUID'leri
deterministic demo identity'dir; future taxonomy stable ID olarak reuse edilmez.

## 2. Product-level static mapping

| Demo product | Candidate/final target | State | Runtime öncesi not |
|---|---|---|---|
| A5 Spiralli Defter | Kırtasiye & Ofis > Defter, Ajanda & Planlayıcılar > Defterler | CANDIDATE_NOT_OWNER_FINAL | Ebat/spiral facet |
| A4 Kareli Defter | Kırtasiye & Ofis > Defter, Ajanda & Planlayıcılar > Defterler | CANDIDATE_NOT_OWNER_FINAL | Ebat/sayfa düzeni facet |
| Mavi Tükenmez Kalem 5'li | Kırtasiye & Ofis > Kalem & Yazım Gereçleri > Tükenmez & Roller Kalemler | CANDIDATE_NOT_OWNER_FINAL | Renk/adet facet/listing data |
| A4 Fotokopi Kağıdı 500 Yaprak | Kırtasiye & Ofis > Kağıt, Etiket & Baskı Sarfı > Fotokopi & Yazıcı Kağıtları | CANDIDATE_NOT_OWNER_FINAL | Ebat/adet facet/listing data |
| Kalem Kutusu | Kırtasiye & Ofis > Okul Kırtasiyesi & Eğitim Gereçleri > Kalem Kutuları | CANDIDATE_NOT_OWNER_FINAL | Direct product type |
| USB-C Şarj Adaptörü 20W | Elektronik > Güç, Şarj & Bağlantı | CANONICAL_FINAL L2 ANCHOR | Generic/cross-device; exact leaf tasarımı gerekir |
| USB-C Şarj Kablosu 1 m | Elektronik > Güç, Şarj & Bağlantı | CANONICAL_FINAL L2 ANCHOR | Connector/length facet; exact leaf tasarımı gerekir |
| Kablosuz Mouse | Bilgisayar & Tablet > Klavye, Mouse & Çevre Birimleri | CANONICAL_FINAL L2 ANCHOR | Wireless facet; exact lower node gerekir |
| 10.000 mAh Powerbank | Elektronik > Güç, Şarj & Bağlantı | CANONICAL_FINAL L2 ANCHOR | Capacity facet; exact leaf tasarımı gerekir |
| Bluetooth Kulaklık | Elektronik > Ses & Kulaklık | CANONICAL_FINAL L2 ANCHOR | Bluetooth facet; exact lower node gerekir |
| UHT Süt 1 L | Gıda & İçecek > Süt Ürünleri & Yumurta > Süt | CANDIDATE_NOT_OWNER_FINAL | UHT/volume facet/listing data |
| Ayçiçek Yağı 1 L | Gıda & İçecek > Yağ & Sirke > Yemeklik Yağlar > Bitkisel Sıvı Yağlar | CANDIDATE_NOT_OWNER_FINAL | Oil type/volume facet |
| Makarna 500 g | Gıda & İçecek > Bakliyat, Tahıl & Makarna > Makarna & Erişte | CANDIDATE_NOT_OWNER_FINAL | Form/weight facet |
| Pirinç 1 kg | Gıda & İçecek > Bakliyat, Tahıl & Makarna > Pirinç & Bulgur | CANDIDATE_NOT_OWNER_FINAL | Rice/bulgur child granularity owner-final sonrası kontrol |
| Toz Şeker 1 kg | Gıda & İçecek > Un, Şeker & Pişirme Malzemeleri > Şeker & Tatlandırıcılar | CANDIDATE_NOT_OWNER_FINAL | Sugar type/weight facet |
| Erkek Günlük Spor Ayakkabı | Ayakkabı > Günlük Ayakkabılar > Günlük Sneaker | CANDIDATE_NOT_OWNER_FINAL | Gender facet; title'daki “spor” merchandising signal |
| Kadın Günlük Spor Ayakkabı | Ayakkabı > Günlük Ayakkabılar > Günlük Sneaker | CANDIDATE_NOT_OWNER_FINAL | Gender facet |
| Çocuk Spor Ayakkabı | Ayakkabı > Çocuk & Bebek Ayakkabıları > Çocuk Spor Ayakkabıları | CANDIDATE_NOT_OWNER_FINAL | Age group/product type candidate |
| Günlük Terlik | Ayakkabı > Sandalet & Terlikler | CANDIDATE_NOT_OWNER_FINAL / MANUAL LOWER NODE | Ev terliği mi sabo/mule mı ürün kanıtıyla ayrılmalı |
| Su Geçirmez Bot | Ayakkabı > Bot & Çizmeler > Yağmur Botları | CANDIDATE_NOT_OWNER_FINAL / MANUAL VERIFY | Waterproof claim tek başına rain-boot formunu kanıtlamaz |

## 3. Listing etkisi

285 listing, 20 canonical/demo product'a relation ile bağlıdır. Future migration:

- listing başına taxonomy kopyalamamalı;
- price, availability, shop ve merchant SKU'yu listing-owned tutmalı;
- product taxonomy target'ını product relation üzerinden yansıtmalı;
- 5 Elektronik product için owner-final L2 anchor'ı final leaf gibi yazmamalı;
- iki Ayakkabı ürünündeki manual lower-node kontrolünü sessiz default'a çevirmemeli.

## 4. Static readiness

- Conceptual L1 bridge: **4/4**.
- Product records assessed: **20/20**.
- Listing propagation accounted: **285/285**.
- Exact candidate/final anchor bulunabilen: **18/20**.
- Product-evidence ile lower-node doğrulaması gereken: **2/20**.
- Owner-final olmayan target taşıyan product: **15/20**.
- Final L2 anchor taşıyıp lower-node bekleyen Elektronik/Bilgisayar product: **5/20**.

Bu sayılar migration PASS değildir. Owner finalization, stable ID ve executable
bridge tamamlanınca deterministic seed artefaktı ayrıca güncellenmelidir.

`DEMO_CATEGORIES_MAPPED: 4/4`

`DEMO_PRODUCTS_ASSESSED: 20/20`

`DEMO_LISTINGS_ACCOUNTED: 285/285`

`DEMO_DATA_CHANGED: NO`

`DEVELOPMENT_TOUCHED: NO`

`PRODUCTION_TOUCHED: NO`
