# EsnaftaVar Global L2 Naming and Discoverability Audit

**Wave:** 15 / Global L2 Cross-Batch Audit

**Scope:** 224 proposed L2 display names across 22 L1 proposals.

**State:** Naming recommendations only. Source proposals remain unchanged and no suggested name is approved.

## Method

The audit checked Turkish naturalness, singular/plural consistency, `&` and comma use, relative L2 granularity, customer language versus merchant/technical jargon, English leakage, length, ambiguity, marketing/collection language, age/gender misuse and duplicated intent. A naming suggestion may expose a structural concern; it does not silently change node scope.

Severity:

- `HIGH`: wording can materially mislead ownership, policy scope or L2 architecture.
- `MEDIUM`: owner should review before canonical lock to avoid ambiguous discovery or inconsistent terminology.
- `LOW`: editorial consistency; scope is otherwise reasonably clear.

## Naming findings

| CURRENT NAME | L1 | ISSUE | SUGGESTED NAME | SEVERITY | OWNER DECISION NEEDED | REASON |
|---|---|---|---|:---:|:---:|---|
| NAM-001 — Et, Tavuk, Balık & Şarküteri | Gıda & İçecek | Uneven granularity: meat types and prepared-food channel term are mixed | Et, Şarküteri & Su Ürünleri | HIGH | YES | Any rename must confirm whether poultry remains a facet/lower family and whether fish scope is truly seafood. |
| NAM-002 — Balıkçılık & Avcılık | Spor & Outdoor | Customer wording makes a policy-sensitive hunting scope appear ordinary | Balıkçılık | HIGH | YES | Batch 02 already recommends narrowing V1 pending legal review. |
| NAM-003 — Geleneksel Türk Müziği Enstrümanları | Müzik & Enstrüman | Cultural collection overlaps structural instrument families | Geleneksel Türk Müziği Çalgıları | HIGH | YES | Wording improves Turkish naturalness but does not solve the required exact non-overlap registry. |
| NAM-004 — Hatıra & Hediyelik Objeler | Hediyelik & Parti | “Hediyelik” can absorb arbitrary products and “obje” is vague | Hatıra & Anı Objeleri | HIGH | YES | Intrinsic-keepsake scope must be approved with any label. |
| NAM-005 — Kedi Ürünleri | Evcil Hayvan Ürünleri | Species-first label is extremely broad and hides product intent | Kedi Bakım & Yaşam Ürünleri | HIGH | YES | Rename alone cannot replace the required species-first L3 architecture review. |
| NAM-006 — Köpek Ürünleri | Evcil Hayvan Ürünleri | Species-first label is extremely broad and hides product intent | Köpek Bakım & Yaşam Ürünleri | HIGH | YES | Must stay parallel with the Kedi decision. |
| NAM-007 — Atıştırmalık, Şekerleme & Kuruyemiş | Gıda & İçecek | Three large product families in one long L2 | Atıştırmalıklar, Şekerlemeler & Kuruyemişler | MEDIUM | YES | Plural parallelism improves reading; owner should confirm combined granularity. |
| NAM-008 — Hazır & Pratik Gıda | Gıda & İçecek | “Pratik” is marketing language and overlaps canned/frozen products | Hazır Yemek & Pratik Gıdalar | MEDIUM | YES | A clearer label still needs the existing primary-intent boundary. |
| NAM-009 — Takım & Kombinler | Giyim & Moda | “Kombin” is merchandising rather than stable product identity | Takım Giyim | MEDIUM | YES | Coordinated look should usually be a collection/facet; physical sets need a clear definition. |
| NAM-010 — Spor & Performans Giyimi | Giyim & Moda | “Performans” is technical marketing language | Spor & Teknik Giyim | MEDIUM | YES | Owner should ensure ordinary sportswear and certified PPE remain separate. |
| NAM-011 — Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri | Beyaz Eşya & Ev Aletleri | Missing possession/plural agreement and very long phrasing | Ev Aleti Aksesuarları, Filtreleri & Sarfları | MEDIUM | YES | Shorter parallel nouns improve customer scanning. |
| NAM-012 — Su Isıtma & Sıcak Su Cihazları | Beyaz Eşya & Ev Aletleri | Repeats the same intent and may mix kettles with fixed systems | Su Isıtma Cihazları | MEDIUM | YES | Scope/boundary notes must keep fixed gas/plumbing systems separate. |
| NAM-013 — Bebek Güvenlik & Ev İçi Koruma | Anne & Bebek | Unnatural noun construction | Bebek Güvenliği & Ev İçi Koruma | MEDIUM | YES | Turkish possessive form is clearer without changing proposed scope. |
| NAM-014 — Puzzle & Zeka Oyunları | Oyuncak & Hobi | English leakage where a common Turkish equivalent exists | Yapboz & Zeka Oyunları | MEDIUM | YES | `puzzle` can remain a search synonym. |
| NAM-015 — Figür, Bebek & Rol Oyunları | Oyuncak & Hobi | “Bebek” is ambiguous with real baby/life-stage products | Figür, Oyuncak Bebek & Rol Oyunları | MEDIUM | YES | Explicit product wording prevents Anne & Bebek confusion. |
| NAM-016 — Stüdyo, Kayıt & Canlı Ses Ekipmanları | Müzik & Enstrüman | Broad contexts and possible overlap with general Electronics audio | Kayıt Stüdyosu & Canlı Ses Ekipmanları | MEDIUM | YES | Owner should retain instrument/performance-purpose boundary. |
| NAM-017 — Enstrüman Aksesuar, Bakım & Sarf Malzemeleri | Müzik & Enstrüman | Missing plural/possessive parallelism | Enstrüman Aksesuarları, Bakım Ürünleri & Sarfları | MEDIUM | YES | Clearer grammar; standalone carrying cases remain outside under the proposed rule. |
| NAM-018 — Outdoor, Kamp & Trekking | Spor & Outdoor | Two English borrowings and mixed activity/context nouns | Doğa Sporları, Kamp & Yürüyüş | MEDIUM | YES | `outdoor` and `trekking` can remain search aliases. |
| NAM-019 — Araştırma, İnceleme & Düşünce | Kitap | Abstract terms overlap many nonfiction shelves | Araştırma, İnceleme & Düşünce Kitapları | MEDIUM | YES | Adding the product noun improves discoverability but genre boundaries still need lower-level rules. |
| NAM-020 — Kağıt, Etiket & Baskı Sarfı | Kırtasiye & Ofis | Singular “sarfı” is grammatically inconsistent | Kağıt, Etiket & Baskı Sarf Malzemeleri | MEDIUM | YES | Keeps the owner-final computer toner/cartuş boundary intact. |
| NAM-021 — Masaüstü Ofis Gereçleri | Kırtasiye & Ofis | “Masaüstü” can be confused with desktop computers | Masa Düzenleme & Ofis Gereçleri | MEDIUM | YES | Customer phrasing separates stationery from Bilgisayar & Tablet. |
| NAM-022 — Ortak Pet Bakım & Aksesuarları | Evcil Hayvan Ürünleri | English “pet”, “ortak” and catch-all wording are vague | Ortak Evcil Hayvan Bakım Ürünleri & Aksesuarları | MEDIUM | YES | Owner must still define the strict multi-species threshold. |
| NAM-023 — Kişisel Koruyucu Medikal Ürünler | Sağlık & Medikal | Word order obscures the medical/PPE relationship | Medikal Kişisel Koruyucu Ürünler | MEDIUM | YES | The label must not imply ordinary PPE belongs in Health. |
| NAM-024 — Kesme Çiçek & Fiziksel Aranjmanlar | Çiçek & Bahçe | “Fiziksel” is implementation/legal wording, not customer language | Kesme Çiçek & Aranjmanlar | MEDIUM | YES | Service exclusion belongs in boundary text, not display name. |
| NAM-025 — Toprak, Gübre & Bitki Besleme | Çiçek & Bahçe | “Bitki besleme” describes an activity rather than product family | Toprak, Gübre & Bitki Besinleri | MEDIUM | YES | Policy distinction from plant-protection products must remain explicit. |
| NAM-026 — Bitki Bakım & Yetiştirme Ürünleri | Çiçek & Bahçe | Missing possessive form | Bitki Bakımı & Yetiştirme Ürünleri | MEDIUM | YES | Editorial correction improves natural Turkish. |
| NAM-027 — Tebrik Kartları, Davetiyeler & Kutlama Yazıları | Hediyelik & Parti | Long and “kutlama yazıları” is ambiguous | Tebrik Kartları, Davetiyeler & Kutlama Mesajları | MEDIUM | YES | Owner should clarify whether physical signs/banners or only written cards are included. |
| NAM-028 — Parti Eğlence & Fotoğraf Aksesuarları | Hediyelik & Parti | Missing possessive and unclear grouping | Parti Eğlencesi & Fotoğraf Aksesuarları | MEDIUM | YES | Physical props remain distinct from event/photography service. |
| NAM-029 — Ayakkabı Bakım & Aksesuarları | Ayakkabı | Missing possessive form | Ayakkabı Bakımı & Aksesuarları | LOW | YES | Editorial consistency only. |
| NAM-030 — El, Omuz & Bel Çantaları | Çanta & Aksesuar | Mixed body-position enumeration can be read as one hybrid item | El Çantaları, Omuz Çantaları & Bel Çantaları | LOW | YES | Longer but clearer parallel family names. |
| NAM-031 — Kemer, Pantolon Askısı & Kravat | Çanta & Aksesuar | Singular family names conflict with plural neighbors | Kemerler, Pantolon Askıları & Kravatlar | LOW | YES | Editorial consistency; no scope change intended. |
| NAM-032 — Çamaşır & Bulaşık Bakım Cihazları | Beyaz Eşya & Ev Aletleri | “Bakım cihazları” is less direct than the primary washing function | Çamaşır & Bulaşık Yıkama Cihazları | LOW | YES | Dryer/dishwasher boundaries remain in future L3. |
| NAM-033 — İklimlendirme & Hava Kalitesi | Beyaz Eşya & Ev Aletleri | Omits product noun while most appliance siblings include it | İklimlendirme & Hava Kalitesi Cihazları | LOW | YES | Improves parallelism. |
| NAM-034 — Araç Bakım & Temizlik | Otomotiv & Motosiklet | Missing possessive forms | Araç Bakımı & Temizliği | LOW | YES | Editorial consistency only. |
| NAM-035 — Motor Yağı, Sıvı & Katkılar | Otomotiv & Motosiklet | Singular/plural mismatch | Motor Yağları, Sıvılar & Katkılar | LOW | YES | Does not change hazardous-goods policy. |
| NAM-036 — Motosiklet Kask & Koruma Ekipmanları | Otomotiv & Motosiklet | Missing plural/possessive construction | Motosiklet Kaskları & Koruma Ekipmanları | LOW | YES | Certification rules remain separate. |
| NAM-037 — Ölçüm, Test & İşaretleme | Yapı, Hırdavat & Tesisat | Activity nouns omit the product-family cue | Ölçüm, Test & İşaretleme Ürünleri | LOW | YES | Avoids service interpretation. |
| NAM-038 — Kaynak, Lehim & Metal İşleme | Yapı, Hırdavat & Tesisat | Can read as services rather than physical products | Kaynak, Lehim & Metal İşleme Ekipmanları | LOW | YES | Explicit product noun reinforces service exclusion. |
| NAM-039 — Parfüm & Deodorant | Kozmetik & Kişisel Bakım | Singular family wording differs from list style | Parfümler & Deodorantlar | LOW | YES | Editorial consistency only. |
| NAM-040 — Tıraş, Ağda & Epilasyon | Kozmetik & Kişisel Bakım | Activity/service nouns omit physical-product scope | Tıraş, Ağda & Epilasyon Ürünleri | LOW | YES | Electric devices still route to Home Appliances under the proposed rule. |

## Findings that should not trigger an automatic rename

The following examples are strong, customer-readable and structurally aligned. They should remain unchanged unless the owner has a broader domain reason:

| L1 | Strong current names |
|---|---|
| Gıda & İçecek | Taze Meyve & Sebze; Süt Ürünleri & Yumurta; Yağ & Sirke; Alkolsüz İçecekler |
| Giyim & Moda | Üst Giyim; Alt Giyim; Dış Giyim; İç Giyim; Mayo & Plaj Giyimi |
| Ayakkabı | Günlük Ayakkabılar; Spor Ayakkabıları; Bot & Çizmeler; Sandalet & Terlikler |
| Çanta & Aksesuar | Sırt Çantaları; Valiz & Seyahat Çantaları; Şemsiyeler; Seyahat Aksesuarları |
| Beyaz Eşya & Ev Aletleri | Küçük Mutfak Aletleri; Temizlik Cihazları; Elektrikli Kişisel Bakım Cihazları |
| Ev & Yaşam | Mobilya; Ev Tekstili; Aydınlatma; Düzenleme & Saklama; Banyo Aksesuarları |
| Züccaciye & Mutfak | Bıçak & Kesme Gereçleri; Sofra & Yemek Takımları; Çay & Kahve Demleme Gereçleri; Mutfak Tekstili |
| Yapı, Hırdavat & Tesisat | Elektrikli & Akülü El Aletleri; Yapı Malzemeleri; Su Tesisatı & Armatürler; Elektrik Tesisatı Malzemeleri |
| Otomotiv & Motosiklet | Otomobil Yedek Parçaları; Motosiklet Yedek Parçaları; Araç Elektroniği |
| Kozmetik & Kişisel Bakım | Makyaj; Cilt Bakımı; Güneş Bakımı; Ağız & Diş Bakımı; Kişisel Hijyen |
| Anne & Bebek | Bebek Beslenme; Emzirme & Anne Sütü Ürünleri; Bebek Arabaları & Taşıma; Oto Koltukları & Seyahat Güvenliği |
| Oyuncak & Hobi | Yapı & İnşa Oyuncakları; Kutu Oyunları & Oyun Takımları; Model, Maket & Minyatür |
| Müzik & Enstrüman | Gitar & Bas; Nefesli Çalgılar; Vurmalı Çalgılar; Enstrüman Amfi & Efektleri |
| Spor & Outdoor | Takım Sporları; Raket Sporları; Dövüş Sporları; Bisiklet; Su Sporları; Kış Sporları |
| Kitap | Edebiyat & Kurgu; Çocuk & Gençlik Kitapları; Sınav Hazırlık Kitapları; Çizgi Roman & Manga |
| Kırtasiye & Ofis | Kalem & Yazım Gereçleri; Defter, Ajanda & Planlayıcılar; Dosyalama & Arşivleme |
| Gözlük & Optik | Optik Gözlük Çerçeveleri; Güneş Gözlükleri; Gözlük Camları; Kontakt Lensler |
| Saat & Takı | Klasik Kol Saatleri; Küpeler; Yüzükler; Vücut Takıları |
| Sağlık & Medikal | İlk Yardım & Yara Bakımı; Evde Sağlık Ölçüm Cihazları; Hareket & Mobilite Yardımcıları |
| Çiçek & Bahçe | Canlı Saksı Bitkileri; Sulama Ürünleri; Bahçe El Aletleri; Sera & Yetiştirme Ekipmanları |
| Hediyelik & Parti | Hediye Paketleme & Sunum; Balon & Balon Aksesuarları; Parti Süsleri & Mekân Dekorasyonu |

## Metrics

| Metric | Count |
|---|---:|
| Proposed L2 names reviewed | 224 |
| Actionable naming findings | 40 |
| High severity | 6 |
| Medium severity | 22 |
| Low severity | 12 |
| Suggested renames | 40 |
| Names with no actionable issue in this pass | 184 |

Borrowed words such as `outdoor`, `trekking`, `puzzle`, `DJ` and `laptop` should remain search aliases even if the owner chooses a more Turkish display name. No alias, slug, stable ID or runtime mapping is created by this audit.
