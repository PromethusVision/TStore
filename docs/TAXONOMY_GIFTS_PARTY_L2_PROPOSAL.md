# Hediyelik & Parti L2 Taksonomi Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW**

- Canonical L1: `Hediyelik & Parti`
- Önerilen L2 sayısı: **9**
- Owner-final karar veya runtime implementasyonu değildir.
- L3/L4 örnekleri tam alt ağaç değildir.

## 2. Scope

Bu alan ürün kimliği kutlama, parti düzenleme, hediye sunumu veya hatıra niteliğindeki obje olan fiziksel ürünleri kapsar. “Hediye” bir kullanım amacı veya kutlama facet'i olduğunda ürün burada duplicate edilmez: hediye edilen oyuncak Oyuncak & Hobi, takı Saat & Takı, çikolata Gıda & İçecek ve kitap Kitap altında kalır.

## 3. Sources reviewed

| Kaynak | Kullanılan sinyal | Sınırlama |
|---|---|---|
| [Google Product Taxonomy](https://www.google.com/basepages/producttype/taxonomy-with-ids.en-US.txt) | Gift wrapping/cards, balon, banner, mum, konfeti, parti kiti/oyunu/şapkası ve davetiye ayrımları | Kamu sürümü 2021-09-21; havai fişek gibi dallar EsnaftaVar satış izni değildir |
| [Google Merchant Center kategori rehberi](https://support.google.com/merchants/answer/6324436?hl=tr) | Ürünün tek ve en spesifik ürün kimliğiyle sınıflandırılması | Gezinme ağacı değildir |
| [Hepsiburada Baby Shower rehberi](https://www.hepsiburada.com/hayatburada/baby-shower-partilerinin-olmazsa-olmazlari/) | Balon, süs, masa ve oyun ürünlerinin kutlama bağlamı | İçerik rehberi; tam kategori ağacı değil |
| [Hepsiburada evde parti önerileri](https://www.hepsiburada.com/hayatburada/evde-yilbasi-partisi-yapmak-isteyenlere-ozel-oneriler/) | Mekân süsleme, sofra ve parti aksesuarı müşteri dili | Occasion odaklı içerik canonical sınır değildir |
| [Hepsiburada ev hediyesi fikirleri](https://www.hepsiburada.com/hayatburada/ev-hediyesi-ne-alinir-ev-hediyesi-fikirleri/) | “Hediye” amacının farklı ürün L1'lerine yayıldığını gösteren negatif sinyal | Kategori kaynağı değil; duplicate riskini gösterir |

## 4. Recommended L2 count

**9 L2** önerilir. Hediye sunumu, kutlama iletişimi, balon, dekor, sofra, kostüm, pasta kutlaması ve eğlence/fotoğraf ürünleri farklı alışveriş görevleridir. Buna karşılık doğum günü, düğün veya yılbaşı gibi her occasion L2 yapılmaz.

## 5. Exact L2 list

1. Hatıra & Hediyelik Objeler
2. Hediye Paketleme & Sunum
3. Tebrik Kartları, Davetiyeler & Kutlama Yazıları
4. Balon & Balon Aksesuarları
5. Parti Süsleri & Mekân Dekorasyonu
6. Parti Sofrası & Servis Ürünleri
7. Kostüm, Maske & Parti Aksesuarları
8. Pasta Süsleme & Kutlama Aksesuarları
9. Parti Eğlence & Fotoğraf Aksesuarları

## 6. Granularity rationale

- `Hediyeler` adı altında diğer L1'lerin ürünleri kopyalanmaz; yalnız intrinsik hatıra/hediyelik objeler ayrılır.
- Paketleme ile kart/davetiye farklı üretim ve müşteri görevleridir.
- Balonlar kurulum, aksesuar ve güvenlik ihtiyaçları nedeniyle genel dekordan ayrılır.
- Parti sofrası, kostüm ve pasta kutlaması ayrı alışveriş sepetleri oluşturur.
- Occasion, tema, yaş ve kişiselleştirme facet'tir; kategori çoğaltmaz.

## 7. Inclusions

1. **Hatıra & Hediyelik Objeler:** hatıra plaketi, dekoratif souvenir, anı kutusu ve ürün kimliği anma/hatıra olan fiziksel obje.
2. **Hediye Paketleme & Sunum:** hediye kutusu/çantası, paket kâğıdı, kurdele, fiyonk, pelür ve sunum dolgusu.
3. **Tebrik Kartları, Davetiyeler & Kutlama Yazıları:** fiziksel tebrik kartı, davetiye, masa isimliği ve kutlama yazısı/pankart harfleri.
4. **Balon & Balon Aksesuarları:** normal parti balonu, balon pompası, bağlama aparatı, ağırlık ve stand; gaz tüpü hariç.
5. **Parti Süsleri & Mekân Dekorasyonu:** banner, girland, konfeti (piroteknik olmayan), perde, masa/duvar süsü ve parti dekor kiti.
6. **Parti Sofrası & Servis Ürünleri:** etkinliğe özgü tek kullanımlık veya koordineli tabak, bardak, peçete, masa örtüsü ve servis seti.
7. **Kostüm, Maske & Parti Aksesuarları:** kostüm, parti maskesi, parti şapkası, peruk ve yalnız kutlama/rol amaçlı giyilebilir aksesuar.
8. **Pasta Süsleme & Kutlama Aksesuarları:** pasta mumu, topper, doğum günü rakamı ve kutlamaya özgü pasta süsü.
9. **Parti Eğlence & Fotoğraf Aksesuarları:** photo booth aksesuarı, pinyata, piroteknik olmayan parti üflemelisi ve fiziksel kutlama oyun aksesuarı.

## 8. Exclusions

- Hediye edilen oyuncak → `Oyuncak & Hobi`; kitap → `Kitap`; çikolata/gıda sepeti → `Gıda & İçecek`.
- Takı ve saat → `Saat & Takı`; çiçek ve canlı bitki → `Çiçek & Bahçe`.
- Genel ev dekoru, çerçeve ve yeniden kullanılabilir ev eşyası → `Ev & Yaşam`.
- Genel yeniden kullanılabilir tabak/servis gereci ve pişirme aparatı → `Züccaciye & Mutfak`.
- Normal giyim/ayakkabı → ilgili L1; yalnız parti/kostüm işlevi baskın ürün burada.
- Kutu oyunu ve oyun kartı → `Oyuncak & Hobi`.
- Havai fişek, maytap, patlayıcı ve piroteknik ürün → `EXCLUDED` önerisi.
- Helyum/gaz tüpü ve endüstriyel basınçlı kap → normal parti ağacına dahil değildir.
- Etkinlik organizasyonu, animatör, kiralama, catering, baskı/tasarım ve kişiselleştirme hizmeti → ürün taksonomisi dışında.

## 9. Cross-domain boundaries

| Sınır | Canonical yönlendirme kuralı |
|---|---|
| Hediyelik & Parti vs tüm ürün L1'leri | “Hediye” kullanım amacı ürünü buraya taşımaz; ürün kendi kimliğinin L1'inde kalır. |
| Hediyelik & Parti vs Ev & Yaşam | Kutlamaya özgü geçici parti dekoru burada; genel/kalıcı ev dekoru Ev & Yaşam'da. |
| Hediyelik & Parti vs Züccaciye & Mutfak | Parti temalı tek kullanımlık/koordineli sofra ürünü burada; genel yeniden kullanılabilir servis/pişirme ürünü Züccaciye & Mutfak'ta. |
| Hediyelik & Parti vs Oyuncak & Hobi | Kutu oyunu/oyuncak Oyuncak & Hobi'de; pinyata ve kutlamanın sahne/fotoğraf aksesuarı burada. |
| Hediyelik & Parti vs Giyim & Moda/Ayakkabı | Gerçek günlük ürün kendi L1'inde; yalnız kostüm/parti kimliği baskın ürün burada. |
| Hediyelik & Parti vs Çiçek & Bahçe | Canlı/kesme çiçek ve bitki Çiçek & Bahçe alanında; hediye sunum paketi burada olabilir. |
| Hediyelik & Parti vs Hizmet | Fiziksel kişiselleştirilmiş ürün temel ürün kimliğinde kalır; tasarım/baskı/organizasyon emeği ayrı hizmet olarak bu ağaca girmez. |

## 10. Category vs facet

Facet/attribute: occasion (doğum günü, düğün, nişan, baby shower, yılbaşı), yaş/rakam, tema, karakter, renk, malzeme, kişiselleştirilebilirlik, paket adedi, iç/dış mekân, tek kullanımlık/yeniden kullanılabilir ve alıcı ilişkisi.

`Sevgiliye hediye`, `anneye hediye`, `yılbaşı hediyesi`, marka veya renk L2 değildir.

## 11. Search synonyms

| Canonical terim | Arama ipuçları |
|---|---|
| Hatıra & Hediyelik Objeler | souvenir, hatıra, anı objesi, hatıra plaketi |
| Hediye Paketleme & Sunum | hediye paketi, hediye kutusu, paket kâğıdı, kurdele, fiyonk |
| Tebrik Kartları & Davetiyeler | tebrik kartı, davetiye, invitation, masa kartı |
| Balon & Balon Aksesuarları | parti balonu, folyo balon, balon standı, balon pompası |
| Parti Süsleri & Mekân Dekorasyonu | parti süsü, banner, girland, fon perde, konfeti |
| Parti Sofrası & Servis | parti tabağı, karton bardak, peçete, masa örtüsü |
| Kostüm, Maske & Parti Aksesuarları | kostüm, parti maskesi, peruk, parti şapkası |
| Pasta Süsleme & Kutlama Aksesuarları | pasta mumu, cake topper, rakam mum |
| Parti Eğlence & Fotoğraf Aksesuarları | photo booth, fotoğraf çubuğu, pinyata, parti düdüğü |

## 12. Policy notes

- Normal paketleme/dekor/kart ürünleri: `NORMAL`.
- Havai fişek, maytap ve patlayıcı/piroteknik ürünler: V1 için `EXCLUDED` önerilir; kategori kaynağında görünmesi satış izni değildir.
- Balonlarda küçük parça/boğulma uyarısı; helyum ve basınçlı tüplerde ayrı tehlikeli madde politikası gerekir.
- Yanıcı dekor, mum ve elektrikli ışık ürünlerinde güvenlik/uygunluk bilgisi gerekir.
- Lisanslı karakter, marka ve kişiye ait görsel/metinlerde fikrî mülkiyet ve kişisel veri kuralları geçerlidir.
- Kişiselleştirme hizmeti değil, fiziksel ürün attribute'u olarak sınırlandırılmalıdır.

## 13. Ambiguous products

| Ürün | Önerilen yer | Gerekçe / owner konusu |
|---|---|---|
| Hediye edilen kahve makinesi | Beyaz Eşya & Ev Aletleri | Hediye olması kutlama/alıcı facet'idir. |
| Kişiselleştirilmiş kupa | Züccaciye & Mutfak | Temel ürün kupadır; kişiselleştirme facet. Hatıra objesi olarak kullanılmayan normal ürün duplicate edilmez. |
| Hatıra plaketi | Hatıra & Hediyelik Objeler | Ürün kimliği anma/hatıra nesnesidir. |
| Yeniden kullanılabilir servis tabağı | Züccaciye & Mutfak | Genel sofra ürünü; tek kullanımlık parti seti burada. |
| Kostüm ayakkabısı | Hediyelik & Parti veya Ayakkabı | Yalnız kostüm işlevi varsa burada; gerçek giyilebilir ayakkabı Ayakkabı. |
| Parti kutu oyunu | Oyuncak & Hobi | Oyun kimliği baskın; kutlama facet'i. |
| Pasta kalıbı | Züccaciye & Mutfak | Pişirme aracı; event-specific topper/mum burada. |
| Helyum tüpü | Normal sınıflandırma yok | Basınçlı gaz policy ve muhtemel endüstriyel sahiplik gerekir. |

## 14. Future L3/L4 examples

- `Hediye Paketleme & Sunum → Hediye Kutuları → Manyetik Kapaklı Hediye Kutuları`
- `Balon & Balon Aksesuarları → Balonlar → Folyo Balonlar`
- `Parti Süsleri & Mekân Dekorasyonu → Asma Süsler → Parti Bannerları`
- `Kostüm, Maske & Parti Aksesuarları → Parti Kostümleri`
- `Pasta Süsleme & Kutlama Aksesuarları → Pasta Mumları → Rakam Mumlar`

Örnekler final değildir; maksimum gelecek derinlik L4'tür.

## 15. Open owner decisions

1. `Hatıra & Hediyelik Objeler` için fiziksel ürünün kendi L1'inden ayrılmasını sağlayan exact intrinsic-keepsake kriteri nedir?
2. Kişiselleştirilmiş kupa, tişört ve takı her zaman temel ürün L1'inde mi kalmalı?
3. Parti sofrasında tek kullanımlık/occasion-specific kriteri operasyonel olarak hangi alanlarla uygulanmalı?
4. Havai fişek, maytap ve tüm piroteknikler V1'de topluca `EXCLUDED` olarak mı kilitlenmeli?
5. Helyum/gaz tüpü bu L1'den tamamen dışlanmalı mı?

## 16. Validation summary

- Canonical L1 adı değişmedi: **PASS**
- L2 sayısı 9, duplicate yok: **PASS**
- “Hediye” amacı diğer L1 ürünlerini duplicate etmedi: **PASS**
- Ev & Yaşam, Züccaciye & Mutfak, Oyuncak & Hobi, Giyim & Moda, Çiçek & Bahçe ve hizmet sınırları yazıldı: **PASS**
- Occasion, tema ve kişiselleştirme facet olarak korundu: **PASS**
- Piroteknik/patlayıcı ve basınçlı gaz riski fail-closed: **PASS**
- Hizmetler dışlandı, full L3/L4 finalize edilmedi: **PASS**
- Runtime/Figma/backend değişikliği: **NONE**

`GIFTS_PARTY_L2_STATE: PROPOSED FOR OWNER REVIEW`

`GIFTS_PARTY_L2_COUNT: 9`

`MAX_FUTURE_DEPTH: 4`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`

`GIFTS_PARTY_READY_FOR_OWNER_REVIEW: YES`
