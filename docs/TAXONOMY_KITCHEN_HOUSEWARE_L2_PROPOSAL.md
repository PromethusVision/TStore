# EsnaftaVar Züccaciye & Mutfak L2 Önerisi

## 1. Status

**PROPOSED FOR OWNER REVIEW — NOT CANONICAL / NOT RUNTIME.**

- Araştırma ve öneri tarihi: **2026-08-28**
- Kapsam: final L1 **Züccaciye & Mutfak** için L2 spine önerisi
- Bu belge owner-final karar, stable identity, slug/sort, full L3/L4, facet schema,
  policy implementation, runtime/JSON/DB veya remote mutation değildir.
- Canonical 24 L1 ve exactly-one-primary-leaf sözleşmesi korunur.

## 2. Scope

Kapsam; gıdayı elektrik kullanmadan hazırlamak, kesmek, pişirmek, servis etmek,
tüketmek, demlemek, saklamak veya taşımak için tasarlanan fiziksel mutfak/sofra
ürünleridir. Gıda ile temas amacı güçlü bir ownership sinyalidir; fakat elektrikli
appliance, sabit tesisat, mobilya ve consumable gıda kendi L1'lerinde kalır.

Materyal, renk, desen, kapasite, kişi sayısı, parça sayısı, ocak uyumu ve marka
category değil facet'tir. Set/bundle, yeni category üretmez; principal product
family veya controlled set rule ile tek leaf'e atanır.

## 3. Sources reviewed

Erişim tarihi **2026-08-28**:

- [Google Merchant Center — Google product category](https://support.google.com/merchants/answer/6324436?hl=tr):
  ürün başına tek external category ve full-path/ID yaklaşımı incelendi.
- [Google Product Taxonomy — Türkçe](https://www.google.com/basepages/producttype/taxonomy-with-ids.tr-TR.txt):
  cookware, bakeware, tableware, drinkware, food storage ve kitchen tool ayrımları
  cross-check edildi; hierarchy doğrudan kopyalanmadı.
- [n11 — Mutfak Gereçleri](https://www.n11.com/mutfak-gerecleri): sofra, yemek
  pişirme, saklama/düzenleme, pratik mutfak gereçleri, çay-kahve demleme ve termos
  yerel customer-intent sinyalleri incelendi.
- [Trendyol — Sofra & Mutfak](https://www.trendyol.com/sofra-mutfak-x-c1354):
  tencere/tava, hazırlık araçları, yemek/çatal-kaşık/bardak takımları ve saklama
  ürünlerinin güncel discovery görünümü cross-check edildi.
- [Amazon Türkiye — Mutfak](https://www.amazon.com.tr/b?node=26248552031): Mutfak'ın
  Ev & Yaşam ve elektrikli appliance kümelerinden ayrı üst discovery intent'i
  incelendi.
- [Amazon Türkiye — Mutfak Saklama & Düzenleme](https://www.amazon.com.tr/mutfak-saklama-duzenleme/b?node=13511259031):
  food storage, rack/holder ve taşıma kabı komşulukları cross-check edildi.
- [Tarım ve Orman Bakanlığı — Gıda ile temas eden madde ve malzemeler](https://www.tarimorman.gov.tr/GKGM/Sayfalar/Detay.aspx?TermId=23f6df2f-b835-4924-8e6c-97fc71cb8bee&UrlSuffix=67%2Fgida-ile-temas-eden-madde-ve-malzemeler-mevzuati-ve):
  tencere, tava, bardak/tabak, çatal/bıçak ve saklama kabının food-contact safety,
  uygunluk ve etiket katmanı gerektirdiği doğrulandı.
- [Ulusal Gıda Referans Laboratuvarı — temas malzemeleri](https://gidalab.tarimorman.gov.tr/gidareferans/Menu/71/Gida-Ile-Temasta-Bulunan-Madde-Ve-Malzemeler):
  migrasyon ve material safety'nin category değil doğrulanabilir policy verisi
  olması gerektiği için authoritative source olarak kullanıldı.

**SOURCE LIMITATION:** Marketplace menüleri dinamik, commercial ve farklı derinlikte;
tam seller taxonomy export'u olarak doğrulanmadı. Hepsiburada'nın güncel public full
tree export'u bulunamadı. Görünen product-family terimleri triangulation sinyalidir,
tek başına canonical kanıt değildir.

## 4. Recommended L2 count

**Önerilen L2 sayısı: 11.**

Bu sayı, mutfaktaki belirgin görev ve attribute profillerini ayırır; material/brand/
set count gibi facetleri L2'ye yükseltmez. Elektrikli cihaz ve sabit tesisat dışarıda
tutulduğu için `Mutfak Ürünleri` adlı gevşek catch-all gerekmez.

## 5. Exact recommended L2 list

| # | Recommended L2 | Primary customer intent |
|---:|---|---|
| 1 | Tencere, Tava & Pişirme Kapları | Ocak/ısı üzerinde yemek pişirme kabı bulmak |
| 2 | Fırınlama & Pişirme Gereçleri | Fırınlama ve ısıya dayanıklı pişirme aracı bulmak |
| 3 | Mutfak Hazırlık Gereçleri | Ölçme, karıştırma, rendeleme, süzme ve hazırlık aracı bulmak |
| 4 | Bıçak & Kesme Gereçleri | Gıdayı kesme/doğrama aracı bulmak |
| 5 | Sofra & Yemek Takımları | Yemeği sofrada sunma/tüketme kabı bulmak |
| 6 | Çatal, Kaşık & Servis Gereçleri | Yeme, servis ve sunum el gereci bulmak |
| 7 | Bardak, Kupa & İçecek Servisi | İçecek tüketme veya servis kabı bulmak |
| 8 | Çay & Kahve Demleme Gereçleri | Elektriksiz demleme/hazırlama gereci bulmak |
| 9 | Saklama & Mutfak Düzenleme | Gıda veya mutfak ekipmanını saklama/düzenleme ürünü bulmak |
| 10 | Termos, Matara & Yiyecek Taşıma | Sıcaklık koruma veya yiyecek/içecek taşıma kabı bulmak |
| 11 | Mutfak Tekstili | Mutfak/sofra görevine özgü textile ürün bulmak |

Normalized duplicate: **0**. Exact ad ve sıra owner approval'a kadar öneridir.

## 6. Why this granularity

- Cookware, bakeware, preparation, cutting ve table service farklı kullanım/safety/
  attribute şemaları oluşturur; tek `Mutfak Gereçleri` L2'sine sıkıştırılmamıştır.
- Sofra kapları, cutlery/service utensils ve drinkware ayrı güçlü customer intent'tir.
- Türkiye'deki çay/kahve demleme kültürü ayrı, kalıcı non-electric product family
  oluşturur; kettle/coffee machine bu dala sızmaz.
- Saklama ile termos/taşıma ayrılmıştır: leakproof, insulation ve portability şeması
  taşıma tarafında belirgindir.
- Mutfak tekstili, gıda hazırlama/servis task'ına özgü olduğu için Home Textile'a
  kopyalanmaz; oda değil ana kullanım ownership'i belirler.

## 7. Inclusions

| L2 | Dahil olan representative ürünler |
|---|---|
| Tencere, Tava & Pişirme Kapları | tencere, tava, sahan, wok, cezve, düdüklü tencere, ocak üstü pişirme seti |
| Fırınlama & Pişirme Gereçleri | fırın tepsisi, kek/ekmek kalıbı, borcam, ızgara, fırın matı |
| Mutfak Hazırlık Gereçleri | rende, süzgeç, karıştırma kabı, ölçü kabı/kaşığı, spatula, çırpıcı, açacak |
| Bıçak & Kesme Gereçleri | şef/ekmek/soyma bıçağı, makas, kesme tahtası, bıçak bileme aracı |
| Sofra & Yemek Takımları | tabak, kase, yemek/kahvaltı takımı, sosluk, servis tabağı, tek kullanımlık sofra kabı |
| Çatal, Kaşık & Servis Gereçleri | çatal, kaşık, yemek bıçağı, kepçe, maşa, servis kaşığı, tepsi/nihale |
| Bardak, Kupa & İçecek Servisi | su/çay/kahve bardağı, kupa, sürahi, karaf, içecek seti |
| Çay & Kahve Demleme Gereçleri | çaydanlık, french press, moka pot, pour-over dripper, manual coffee/tea brewer |
| Saklama & Mutfak Düzenleme | food container, kavanoz, baharatlık, ekmek kutusu, kaşıklık, dolap/tezgâh organizer |
| Termos, Matara & Yiyecek Taşıma | termos, termal kupa, matara, lunch box, sefer tası, yiyecek taşıma kabı |
| Mutfak Tekstili | mutfak önlüğü, kurulama bezi, fırın eldiveni/tutacak, masa örtüsü, runner, peçete |

## 8. Exclusions

- Gıda/içecek consumable: **Gıda & İçecek**.
- Blender, mikser, kettle, kahve makinesi, air fryer, tost makinesi ve elektrikli
  pişirme/hazırlama cihazı: **Beyaz Eşya & Ev Aletleri**.
- Mutfak dolabı/mobilyası: **Ev & Yaşam** veya fixed-installation review.
- Musluk, evye, boru, sabit tezgâh, gaz/elektrik bağlantısı ve montaj malzemesi:
  **Yapı, Hırdavat & Tesisat**.
- Genel ev storage box, havlu, perde ve dekorasyon: **Ev & Yaşam**.
- Kamp/yolculuk için teknik hydration/cook system: **Spor & Outdoor** ana kullanım
  review; normal consumer termos/matara burada.
- Bıçak bileme hizmeti, catering, mutfak montajı ve cooking class kapsam dışıdır.
- Endüstriyel sabit/profesyonel mutfak makinesi bu consumer V1 proposal'a dahil değildir.

## 9. Cross-domain boundaries

| Sınır | Kural |
|---|---|
| Züccaciye ↔ Gıda & İçecek | Tüketilen içerik Gıda; hazırlama/temas/servis kabı burada. Heterojen food+cup bundle principal rule kullanır. |
| Züccaciye ↔ Beyaz Eşya & Ev Aletleri | Ana işlevi elektrik/pil/motor/ısıtıcıyla çalışan cihaz appliance; pasif/manual gereç burada. |
| Züccaciye ↔ Ev & Yaşam | Gıda hazırlama/temas/servis/saklama görevi burada; genel household textile/storage/decor Ev & Yaşam'da. |
| Züccaciye ↔ Yapı/Hırdavat | Taşınabilir consumer kitchenware burada; fixed plumbing, surface, cabinet installation ve building connection ilgili L1'de. |
| Züccaciye ↔ Spor & Outdoor | Günlük kitchen/commute termos-matara burada; teknik kamp cooking/hydration system ana outdoor function ile Spor & Outdoor review'ünde. |
| Züccaciye ↔ Hediyelik & Parti | Normal tableware ürün tipine göre burada; party-only disposable decoration ilgili L1'de. Hediye/çeyiz seti category değildir. |

## 10. Category vs facet decisions

| Category değildir | Facet/policy hint |
|---|---|
| Materyal | cam, porselen, seramik, çelik, döküm, alüminyum, plastik, silikon, ahşap |
| Boyut/kapasite | çap, litre/ml, adet, kişi/parça sayısı |
| Uyumluluk | indüksiyon/gaz/elektrik ocak, fırın/mikrodalga/bulaşık makinesi uyumu |
| Kaplama | yapışmaz, emaye, seasoning; doğrulanabilir product data |
| Isı/taşıma | sıcak-soğuk koruma süresi, leakproof, insulation |
| Stil | günlük, çeyiz, klasik, modern, desen/renk |
| Set | takım/set sayısı ve included items; category node değildir |
| Ticari | marka, fiyat, stok, indirim, bestseller, featured, nearby |

## 11. Search synonyms

| L2 | Controlled search/synonym hints |
|---|---|
| Tencere, Tava & Pişirme Kapları | cookware, pişirme seti, düdüklü, sahan, wok |
| Fırınlama & Pişirme Gereçleri | bakeware, fırın kabı, kek kalıbı, tepsi, borcam |
| Mutfak Hazırlık Gereçleri | kitchen tools, hazırlık aparatı, rende, süzgeç, spatula |
| Bıçak & Kesme Gereçleri | kitchen knife, doğrama, kesme tahtası, bıçak seti |
| Sofra & Yemek Takımları | tableware, yemek takımı, tabak, kase, kahvaltı takımı |
| Çatal, Kaşık & Servis Gereçleri | cutlery, flatware, servis takımı, kepçe, maşa |
| Bardak, Kupa & İçecek Servisi | drinkware, glassware, kupa, sürahi, karaf |
| Çay & Kahve Demleme Gereçleri | brewer, french press, moka pot, çaydanlık, dripper |
| Saklama & Mutfak Düzenleme | food storage, erzak kabı, kavanoz, organizer |
| Termos, Matara & Yiyecek Taşıma | vacuum flask, thermal mug, lunch box, sefer tası |
| Mutfak Tekstili | kitchen textile, kurulama bezi, önlük, fırın eldiveni, masa örtüsü |

`Cezve` manual cookware'dır; elektrikli cezve appliance'tır. Search resolver güç kaynağı
ve product type bağlamını kullanmalıdır.

## 12. Policy/compliance notes

- Gıda ile temas uygunluğu, kullanım koşulu, işletme/üretici bilgisi ve gerekli
  işaretleme category'den ayrı doğrulanabilir policy alanlarıdır.
- Material, sıcaklık, asit/yağ teması ve migration restriction bilgileri güvenlik
  açısından serbest metinden türetilmemelidir.
- Basınçlı tencere, kesici alet, cam ürün ve sıcak sıvı kabı için usage warning,
  yaş/safety visibility ve applicable product standard gereksinimleri ayrı tutulur.
- `BPA içermez`, `gıda temasına uygundur`, `indüksiyon uyumlu`, `ısıyı N saat korur`
  gibi claim'ler evidence gerektirir; search synonym değildir.
- Tek kullanımlık product form category'de yer alabilir; material/environment claim
  policy ve facet olarak ayrıca doğrulanır.

## 13. Ambiguous products

| Ürün | Proposed primary placement / rule |
|---|---|
| Cezve | Manual ise Tencere/Tava; elektrikli ise appliance |
| Çaydanlık | Manual ocak üstü ise Çay & Kahve; elektrikli tea maker appliance |
| Moka pot | Çay & Kahve Demleme; electrical espresso machine appliance |
| Yemek bıçağı | Çatal, Kaşık & Servis; hazırlık/şef bıçağı Bıçak & Kesme |
| Karıştırma + saklama kabı | Marketed primary function ve lid/storage schema ile Saklama veya Hazırlık; duplicate yok |
| Fırın kabı/borcam | Fırınlama; servis edilebilmesi Sofra'ya kopyalamaz |
| Termos kupa | Termos, Matara & Yiyecek Taşıma; normal kupa Bardak/Kupa |
| Cam kavanoz | Gıda saklama ise Saklama; yalnız dekoratif vazo Ev & Yaşam |
| Masa örtüsü | Mutfak Tekstili; genel living-room decorative textile owner review gerekebilir |
| Mutfak makası | Bıçak & Kesme; genel household/tool makası ana kullanımına göre Kırtasiye veya Hırdavat review |
| Kamp tenceresi | Teknik outdoor system ise Spor & Outdoor; normal taşınabilir cookware burada |
| Çeyiz seti | Bundle category değildir; dominant product family veya component-level listing rule gerekir |

Adjudication: gıda-temas görevi → güç kaynağı → fixed/portable → primary product form
→ safety/attribute schema → tek leaf. Çözülemeyen SKU review'a gider.

## 14. Future L3/L4 examples

Yalnız feasibility örnekleri; full/final tree değildir:

| L2 | Olası variable-depth örneği | Guard |
|---|---|---|
| Tencere, Tava & Pişirme Kapları | Pişirme Kapları → Tencere | Materyal/çap/ocak uyumu facet'tir. |
| Fırınlama & Pişirme Gereçleri | Fırın Kapları → Kek Kalıbı | Şekil/ölçü facet'tir. |
| Bıçak & Kesme Gereçleri | Mutfak Bıçakları → Şef Bıçağı | Marka/bıçak uzunluğu facet'tir. |
| Sofra & Yemek Takımları | Yemek Servisi → Tabak | Materyal/kişi sayısı facet'tir. |
| Çay & Kahve Demleme Gereçleri | Kahve Demleme → French Press | Capacity/material facet'tir. |
| Saklama & Mutfak Düzenleme | Gıda Saklama → Saklama Kabı | Material/leakproof/freezer-safe facet'tir. |

## 15. Open owner decisions

1. **11 L2 exact adı ve sırası** kabul/ret/revise edilmelidir.
2. **Manual cezve/çaydanlık:** Tencere/Tava ile Çay/Kahve arasındaki önerilen
   customer-intent ayrımı owner tarafından gerçek SKU örnekleriyle challenge edilmelidir.
3. **Mutfak tekstili:** task-specific ownership önerisi Ev Tekstili ile birlikte
   owner-final yapılmalıdır; duplicate tree üretilmemelidir.
4. **Normal termos/matara ↔ teknik outdoor hydration:** ana kullanım kuralı Spor &
   Outdoor domain tasarımında doğrulanmalıdır.
5. **Endüstriyel/profesyonel mutfak ekipmanı:** consumer V1'e dahil edilmemiştir;
   gelecekte ölçülmüş merchant ihtiyacı ve policy ile ayrı review gerekir.

Bu kararlar açıkken agent `FINAL`, stable ID veya runtime mapping üretemez.

## 16. Validation summary

- Canonical L1 **Züccaciye & Mutfak**: **PASS — unchanged**
- Status **PROPOSED FOR OWNER REVIEW**: **PASS**
- Recommended L2 / duplicate: **11 / 0**
- Food-contact, appliance, fixed-installation boundaries: **PASS**
- Material/size/compatibility/set as category: **0**
- Product/Merchant/Service separation: **PASS**
- Full L3/L4 tree: **NOT PRODUCED**
- Flutter/Figma/JSON/DB/runtime/remote changes: **NONE**

`KITCHEN_HOUSEWARE_L2_PROPOSAL: READY_FOR_OWNER_REVIEW`

`KITCHEN_HOUSEWARE_L2_COUNT: 11`

`OWNER_APPROVAL: OPEN`
