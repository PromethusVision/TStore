# Taxonomy Batch 01 — Product Owner Karar Özeti

**Durum:** Owner review hazırlığı — yalnız öneri
**Kapsam:** 6 L1, mevcut proposal belgelerindeki 70 L2
**Karar yetkisi:** Bu belge agent önerilerini ve owner karar noktalarını özetler; herhangi bir owner onayı kaydetmez.

Bu digest mevcut Batch 01 proposal'larını yeniden tasarlamaz. L2 adları ve sıraları kaynak belgelerden aynen korunmuştur. `REQUIRES GLOBAL CROSS-BATCH REVIEW` etiketi, komşu L1'in detaylı proposal'ı görülmeden ownership kararının kapatılmaması gerektiğini belirtir.

Öncelikler:

- `P0`: L2 canonical yapısını veya başka bir L1 ownership'ini değiştirebilir.
- `P1`: Gelecekteki L3/L4, primary leaf veya cross-domain boundary'yi etkiler.
- `P2`: Facet, synonym, policy metadata veya implementation detayıdır.

Policy sınıfları: `NORMAL`, `AGE_RESTRICTED`, `REGULATED`, `LEGAL_REVIEW_REQUIRED`, `EXCLUDED`.

## Gıda & İçecek

### Proposed L2

1. Taze Meyve & Sebze
2. Et, Tavuk, Balık & Şarküteri
3. Süt Ürünleri & Yumurta
4. Ekmek, Unlu Mamuller & Pastacılık
5. Bakliyat, Tahıl & Makarna
6. Un, Şeker & Pişirme Malzemeleri
7. Yağ & Sirke
8. Kahvaltılık
9. Atıştırmalık, Şekerleme & Kuruyemiş
10. Alkolsüz İçecekler
11. Sos, Baharat & Çeşni
12. Konserve & Kavanoz Ürünleri
13. Hazır & Pratik Gıda
14. Donuk Gıda

### Recommended owner position

14 L2'lik omurgayı ad ve sıra değişikliği olmadan kabul et; bebek gıdasını Anne & Bebek'e, supplement/medikal beslenmeyi Sağlık & Medikal'e bırak; alkolü V1 kapsamı dışında tut; restoran/hizmet sunumunu ürün taxonomy'sine alma; Konserve & Kavanoz ile Hazır & Pratik ayrımını koru. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-FOOD-P0-01

**DECISION ID:** `B01-FOOD-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 14 L2 adı ve sırası Batch 01 Gıda & İçecek omurgası olarak kabul edilsin mi?

**OPTION A:** 14 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından adı ve etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Liste ürün türü, saklama biçimi ve tüketim bağlamını yapay derinlik oluşturmadan dengeliyor.
**CROSS-DOMAIN EFFECT:** Aşağıdaki özel sınır kararları dışında komşu L1 ownership'ini değiştirmez.
**RISK IF DEFERRED:** Gıda L3/L4 ve seed mapping çalışması güvenilir bir üst omurga olmadan ilerler.

#### B01-FOOD-P0-02

**DECISION ID:** `B01-FOOD-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Bebek maması, devam sütü ve bebek atıştırmalıkları hangi L1'in primary ownership'inde olmalı?

**OPTION A:** Anne & Bebek primary owner olsun; Gıda & İçecek yalnız discovery alias/facet sağlasın.
**OPTION B:** Gıda & İçecek primary owner olsun; Anne & Bebek alias/facet sağlasın.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yaş evresi ve bakım bağlamı, normal gıda formundan daha güçlü bir satın alma amacı oluşturur.
**CROSS-DOMAIN EFFECT:** Anne & Bebek L2/L3 tasarımı ve tek-primary-leaf kuralı etkilenir.
**RISK IF DEFERRED:** Aynı ürün iki L1 altında bağımsız leaf olarak çoğalabilir ve regülasyon metadata'sı ayrışabilir.

#### B01-FOOD-P0-03

**DECISION ID:** `B01-FOOD-P0-03`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`, `LEGAL_REVIEW_REQUIRED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Takviye edici gıda ve medikal beslenme ürünleri Gıda & İçecek içinde mi, Sağlık & Medikal içinde mi sahiplenilmeli?

**OPTION A:** Sağlık & Medikal primary owner olsun; normal besinler Gıda & İçecek'te kalsın.
**OPTION B:** Ürün formuna göre Gıda & İçecek içinde ayrı L2 oluştur.

**RECOMMENDED OPTION:** Option A.
**WHY:** Kullanım amacı, sağlık beyanı ve düzenleyici çerçeve normal gıdadan farklıdır.
**CROSS-DOMAIN EFFECT:** Sağlık & Medikal proposal'ı, policy sınıfları ve claim kuralları etkilenir.
**RISK IF DEFERRED:** Medikal amaçlı ürünler normal gıda leaf'lerine sızar; policy ve search sonuçları belirsizleşir.

#### B01-FOOD-P0-04

**DECISION ID:** `B01-FOOD-P0-04`
**PRIORITY:** `P0`
**POLICY CLASS:** `AGE_RESTRICTED`, `LEGAL_REVIEW_REQUIRED`, `EXCLUDED`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Alkollü içecekler V1 ürün taxonomy ve ürün kapsamına alınmalı mı?

**OPTION A:** V1'de exclude et; yalnız açık bir sonraki ürün/policy kararıyla yeniden değerlendir.
**OPTION B:** Yaş kısıtı ve hukuki kontroller tamamlanmadan görünürlüğe açılmayan ayrı L2 tasarla.
**OPTION C:** Normal içecekler altında sınıflandır.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yaş doğrulama, satış/teslim bağlamı ve yerel mevzuat gereksinimleri mevcut ürün modelinde çözülmüş değildir.
**CROSS-DOMAIN EFFECT:** Auth/age gate, merchant eligibility, arama görünürlüğü ve moderation policy etkilenir.
**RISK IF DEFERRED:** Ürünler yanlışlıkla Alkolsüz İçecekler altında yayınlanabilir veya tutarsız şekilde engellenebilir.

#### B01-FOOD-P1-05

**DECISION ID:** `B01-FOOD-P1-05`
**PRIORITY:** `P1`
**POLICY CLASS:** `EXCLUDED`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Sıcak hazırlanmış restoran yemeği ve siparişe göre hazırlanan servis, Hazır & Pratik Gıda kapsamına girmeli mi?

**OPTION A:** Paketli/perakende ürünleri dahil et; restoran yemeği ve hizmet sunumunu exclude et.
**OPTION B:** Hazırlanmış her yiyeceği aynı leaf ailesinde topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Canonical taxonomy satılabilir ürünleri kapsar; hizmet, rezervasyon ve klasik sipariş modeli bu kapsamda değildir.
**CROSS-DOMAIN EFFECT:** Merchant/Sector Taxonomy ile Product Taxonomy ayrımını korur.
**RISK IF DEFERRED:** Ürün leaf'leri restoran hizmeti ve teslimat beklentisiyle karışır.

#### B01-FOOD-P1-06

**DECISION ID:** `B01-FOOD-P1-06`
**PRIORITY:** `P1`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Konserve & Kavanoz Ürünleri ile Hazır & Pratik Gıda arasındaki primary leaf kuralı nasıl kurulmalı?

**OPTION A:** Ambalaj/saklama tekniği baskınsa Konserve & Kavanoz; tüketim kolaylığı/öğün amacı baskınsa Hazır & Pratik kullan.
**OPTION B:** İki L2'yi tek L2 altında birleştir.

**RECOMMENDED OPTION:** Option A.
**WHY:** İki ayrı alışveriş niyetini korurken L3/L4 için deterministik bir ayrım sağlar.
**CROSS-DOMAIN EFFECT:** Yalnız Gıda içi leaf ve facet tasarımını etkiler.
**RISK IF DEFERRED:** Hazır konserve yemekler birden çok primary leaf'e atanabilir.

### Low-risk decisions

- Taze ürünler, temel kuru gıda, pişirme malzemeleri ve kahvaltılık omurgası topluca kabul edilebilir.
- `B01-FOOD-P1-06`, açık primary-intent kuralıyla düşük uygulama riski taşır.

### High-impact decisions

- `B01-FOOD-P0-02`, `B01-FOOD-P0-03` ve `B01-FOOD-P0-04` başka ürün alanlarını veya platform policy'sini etkiler.
- `B01-FOOD-P1-05` Product Taxonomy ile hizmet modelinin ayrımını korur.

### Policy-sensitive decisions

- `B01-FOOD-P0-02` — `REGULATED`
- `B01-FOOD-P0-03` — `REGULATED`, `LEGAL_REVIEW_REQUIRED`
- `B01-FOOD-P0-04` — `AGE_RESTRICTED`, `LEGAL_REVIEW_REQUIRED`, `EXCLUDED`
- `B01-FOOD-P1-05` — `EXCLUDED`

## Giyim & Moda

### Proposed L2

1. Üst Giyim
2. Alt Giyim
3. Elbise & Tulum
4. Takım & Kombinler
5. Dış Giyim
6. İç Giyim
7. Ev & Uyku Giyimi
8. Spor & Performans Giyimi
9. Mayo & Plaj Giyimi
10. İş Giyimi & Üniforma

### Recommended owner position

10 L2'lik form/işlev omurgasını koru; tesettürü facet ve kontrollü koleksiyon olarak ele al; feraceyi fiziksel forma göre ileride Elbise & Tulum veya Dış Giyim leaf'ine yerleştir; özel anne işlevi taşımayan maternity giysiyi Giyim'de tut; teknik performans kullanımını Spor & Performans'a, sertifikalı PPE'yi Yapı, Hırdavat & Tesisat'a bırak. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-CLOTHING-P0-01

**DECISION ID:** `B01-CLOTHING-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 10 L2 adı ve sırası Giyim & Moda omurgası olarak kabul edilsin mi?

**OPTION A:** 10 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yapı cinsiyet/yaş yerine kalıcı ürün formu ve kullanım amacına dayanır.
**CROSS-DOMAIN EFFECT:** Özel boundary kararları hariç komşu L1'leri değiştirmez.
**RISK IF DEFERRED:** Ferace, spor giyim ve iş güvenliği sınırları için ortak üst yapı kurulamaz.

#### B01-CLOTHING-P0-02

**DECISION ID:** `B01-CLOTHING-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Tesettür bağımsız bir L2 mi, yoksa facet/kontrollü koleksiyon mu olmalı?

**OPTION A:** L2 ekleme; modest/tesettür facet'i ve kontrollü koleksiyon kullan.
**OPTION B:** Bağımsız Tesettür Giyim L2'si ekle.

**RECOMMENDED OPTION:** Option A.
**WHY:** Tesettür birçok ürün formunu keser; bağımsız L2 aynı ürünü iki primary leaf'e itebilir.
**CROSS-DOMAIN EFFECT:** Çanta & Aksesuar gibi tamamlayıcı ürünler koleksiyonda gösterilebilir, fakat ownership değişmez.
**RISK IF DEFERRED:** Üst giyim, dış giyim ve elbise ürünleri duplicate taxonomy yollarına ayrılır.

#### B01-CLOTHING-P1-03

**DECISION ID:** `B01-CLOTHING-P1-03`
**PRIORITY:** `P1`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Ferace ürünleri hangi primary leaf kuralıyla yerleştirilmeli?

**OPTION A:** Fiziksel forma göre elbise karakterindeyse Elbise & Tulum, dış katman karakterindeyse Dış Giyim; `ferace` synonym/facet olsun.
**OPTION B:** Tüm feraceleri tek bir gelecekteki leaf altında topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Ürün adı tek başına formu ve kullanım bağlamını güvenilir biçimde belirlemez.
**CROSS-DOMAIN EFFECT:** Giyim içi L3/L4 ve synonym sözlüğünü etkiler.
**RISK IF DEFERRED:** Aynı formdaki ürünler satıcı adlandırmasına göre farklı primary leaf'lere düşer.

#### B01-CLOTHING-P0-04

**DECISION ID:** `B01-CLOTHING-P0-04`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Hamile ve emzirme giyiminin primary ownership'i Giyim & Moda mı, Anne & Bebek mi olmalı?

**OPTION A:** Normal moda/beden varyantı Giyim'de; açık hamilelik/emzirme işlevli ürün Anne & Bebek'te olsun.
**OPTION B:** Tüm maternity ürünleri Anne & Bebek'e taşı.
**OPTION C:** Tüm maternity ürünleri Giyim & Moda'da tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Primary satın alma amacı, standart moda ile özel yaşam-evresi işlevini ayırır.
**CROSS-DOMAIN EFFECT:** Anne & Bebek L2/L3 yapısı ve maternity facet'i etkilenir.
**RISK IF DEFERRED:** Aynı ürün iki L1 altında çoğalır veya özel işlevli ürünler bulunamaz.

#### B01-CLOTHING-P1-05

**DECISION ID:** `B01-CLOTHING-P1-05`
**PRIORITY:** `P1`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Spor sütyeni ve benzeri performans iç katmanları İç Giyim mi, Spor & Performans Giyimi mi sahiplenmeli?

**OPTION A:** Teknik spor kullanımı ve performans özelliği baskınsa Spor & Performans; aksi halde İç Giyim kullan.
**OPTION B:** Tüm spor sütyenlerini İç Giyim'e yerleştir.
**OPTION C:** Tümünü Spor & Performans'a yerleştir.

**RECOMMENDED OPTION:** Option A.
**WHY:** Primary intent kuralı form ile teknik performans amacını birlikte değerlendirir.
**CROSS-DOMAIN EFFECT:** Spor & Outdoor discovery facet'leri ve gelecekteki leaf mapping'i etkilenir.
**RISK IF DEFERRED:** Aynı SKU iç giyim ve spor ağacında duplicate leaf kazanabilir.

#### B01-CLOTHING-P0-06

**DECISION ID:** `B01-CLOTHING-P0-06`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Koruyucu iş kıyafeti ve sertifikalı PPE giysilerin ownership'i nerede olmalı?

**OPTION A:** Sertifikalı/koruyucu PPE Yapı, Hırdavat & Tesisat'ta; normal üniforma ve görünürlük iddiası olmayan iş kıyafeti Giyim'de olsun.
**OPTION B:** Tüm giyilebilir iş ürünlerini Giyim & Moda'da tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Koruyucu işlev, uygunluk ve güvenlik standardı normal giyim formundan daha belirleyicidir.
**CROSS-DOMAIN EFFECT:** İş Güvenliği & Koruyucu Donanım L2'siyle tek-primary-leaf sınırı kurulmalıdır.
**RISK IF DEFERRED:** Güvenlik ekipmanı normal üniformayla karışır ve compliance metadata'sı kaybolur.

### Low-risk decisions

- Üst/Alt Giyim, Elbise & Tulum, Dış Giyim, Ev & Uyku ve Mayo & Plaj omurgası topluca kabul edilebilir.
- `B01-CLOTHING-P1-03`, fiziksel form kuralı kabul edildiğinde düşük operasyon riski taşır.

### High-impact decisions

- `B01-CLOTHING-P0-02` L2 ile facet ayrımını belirler.
- `B01-CLOTHING-P0-04`, `B01-CLOTHING-P1-05` ve `B01-CLOTHING-P0-06` komşu L1 ownership'lerini etkiler.

### Policy-sensitive decisions

- `B01-CLOTHING-P0-06` — `REGULATED`

## Ev & Yaşam

### Proposed L2

1. Mobilya
2. Yatak & Uyku Ürünleri
3. Ev Tekstili
4. Perde & Pencere Tekstili
5. Halı, Kilim & Paspas
6. Dekorasyon & Duvar Aksesuarları
7. Aydınlatma
8. Düzenleme & Saklama
9. Banyo Aksesuarları
10. Ev Temizliği & Çamaşır Bakımı

### Recommended owner position

10 L2'yi koru; Aydınlatma'yı taşınabilir/standart ev ürünleriyle sınırla, sabit elektrik tesisatını Yapı, Hırdavat & Tesisat'a ve akıllı kontrol cihazlarını Elektronik'e bırak; bahçe mobilyasını Çiçek & Bahçe'ye bırak; standalone mobilya/dolabı Ev'de tutup özel yapım hizmetini exclude et; temizlik kimyasallarını policy metadata ile Ev'de tut; hareketli banyo aksesuarını tesisat ürününden ayır. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-HOME-P0-01

**DECISION ID:** `B01-HOME-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 10 L2 adı ve sırası Ev & Yaşam omurgası olarak kabul edilsin mi?

**OPTION A:** 10 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yaşam alanı, tekstil, dekorasyon ve bakım ihtiyaçlarını ürün odaklı ayrıştırır.
**CROSS-DOMAIN EFFECT:** Özel sınır kararları dışında diğer L1'lere etkisi düşüktür.
**RISK IF DEFERRED:** Ev ürünlerinde L3/L4 leaf tasarımı ve demo mapping'i bekler.

#### B01-HOME-P0-02

**DECISION ID:** `B01-HOME-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Standart ev aydınlatması ile sabit elektrik tesisatı ve akıllı aydınlatma nasıl ayrılmalı?

**OPTION A:** Taşınabilir/dekoratif normal aydınlatma Ev'de; sabit tesisat bileşenleri Yapı, Hırdavat & Tesisat'ta; akıllı kontrol/bağlantılı ürün Elektronik'te olsun.
**OPTION B:** Tüm aydınlatma ürünlerini Ev & Yaşam'da topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Kurulum/güvenlik gereksinimi ve akıllı cihaz işlevi ayrı satın alma amaçlarıdır.
**CROSS-DOMAIN EFFECT:** Yapı, Hırdavat & Tesisat ve Elektronik leaf sınırlarını doğrudan etkiler.
**RISK IF DEFERRED:** Ampul, armatür, anahtar ve akıllı kontrolörler birden fazla primary leaf kazanır.

#### B01-HOME-P0-03

**DECISION ID:** `B01-HOME-P0-03`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Bahçe ve balkon için tasarlanmış mobilyaların primary ownership'i nerede olmalı?

**OPTION A:** Açık alan/bahçe amacı baskın ürünleri Çiçek & Bahçe'ye; genel iç/dış mekan mobilyasını Ev & Yaşam'a ata.
**OPTION B:** Tüm mobilyaları Ev & Yaşam'da tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Açık alan bakımı ve bahçe alışveriş bağlamı discovery için daha güçlüdür.
**CROSS-DOMAIN EFFECT:** Çiçek & Bahçe L2/L3 kapsamı belirlenmeden kesin ownership kapatılamaz.
**RISK IF DEFERRED:** Bahçe mobilyası iki L1'de duplicate leaf olur veya bahçe keşfinde kaybolur.

#### B01-HOME-P1-04

**DECISION ID:** `B01-HOME-P1-04`
**PRIORITY:** `P1`
**POLICY CLASS:** `EXCLUDED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Sabit dolap ve cabinetry ürün/hizmet sınırı nasıl kurulmalı?

**OPTION A:** SKU olarak satılan modüler/standalone dolabı Mobilya'da tut; ölçü-alma, üretim ve montaj hizmetini exclude et.
**OPTION B:** Sabit veya özel yapım tüm cabinetry'yi Ev & Yaşam ürünü say.

**RECOMMENDED OPTION:** Option A.
**WHY:** Ürün taxonomy'si hizmet sözleşmesi ve proje teslim kapsamını taşımamalıdır.
**CROSS-DOMAIN EFFECT:** Yapı ürünleri ile Merchant/Sector hizmet sınırı etkilenir.
**RISK IF DEFERRED:** Ürün listeleri keşif modelinin desteklemediği özel yapım hizmet tekliflerine dönüşebilir.

#### B01-HOME-P1-05

**DECISION ID:** `B01-HOME-P1-05`
**PRIORITY:** `P1`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Ev tipi temizlik kimyasalları Ev Temizliği & Çamaşır Bakımı altında kalmalı mı?

**OPTION A:** Ev'de tut; tehlike/uyarı ve kısıt metadata'sını policy katmanında yönet.
**OPTION B:** Kimyasal ürünleri ayrı bir L1/L2 alanına taşı.

**RECOMMENDED OPTION:** Option A.
**WHY:** Primary alışveriş amacı ev bakımıdır; düzenleyici özellik taxonomy'den çok policy metadata'sıdır.
**CROSS-DOMAIN EFFECT:** Policy schema ve merchant eligibility kontrolü etkilenir, L1 ownership'i değişmez.
**RISK IF DEFERRED:** Temizlik ürünleri taxonomy dışında kalır veya güvenlik gereksinimleri görünmez olur.

#### B01-HOME-P0-06

**DECISION ID:** `B01-HOME-P0-06`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Banyo aksesuarı ile su tesisatı/armatür ürünü arasındaki ownership kuralı ne olmalı?

**OPTION A:** Hareketli/dekoratif aksesuar Ev'de; su hattına bağlanan armatür ve tesisat bileşeni Yapı, Hırdavat & Tesisat'ta olsun.
**OPTION B:** Banyoda kullanılan tüm ürünleri Ev & Yaşam'da topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Sabit bağlantı ve tesisat işlevi, oda bağlamından daha belirleyici bir primary intent'tir.
**CROSS-DOMAIN EFFECT:** Su Tesisatı & Armatürler L2'siyle kesin boundary gerekir.
**RISK IF DEFERRED:** Duş başlığı, musluk ve hareketli organizer gibi ürünler tutarsız atanır.

### Low-risk decisions

- Mobilya, uyku, ev tekstili, perde, halı ve dekorasyon L2'leri topluca kabul edilebilir.
- Temizlik ürünlerinin Ev'de kalması, policy metadata koşuluyla düşük taxonomy riski taşır.

### High-impact decisions

- `B01-HOME-P0-02`, `B01-HOME-P0-03` ve `B01-HOME-P0-06` komşu L1 ownership'lerini etkiler.
- `B01-HOME-P1-04` ürün/hizmet ayrımını korur.

### Policy-sensitive decisions

- `B01-HOME-P0-02` — `REGULATED`
- `B01-HOME-P1-04` — `EXCLUDED`
- `B01-HOME-P1-05` — `REGULATED`

## Züccaciye & Mutfak

### Proposed L2

1. Tencere, Tava & Pişirme Kapları
2. Fırınlama & Pişirme Gereçleri
3. Mutfak Hazırlık Gereçleri
4. Bıçak & Kesme Gereçleri
5. Sofra & Yemek Takımları
6. Çatal, Kaşık & Servis Gereçleri
7. Bardak, Kupa & İçecek Servisi
8. Çay & Kahve Demleme Gereçleri
9. Saklama & Mutfak Düzenleme
10. Termos, Matara & Yiyecek Taşıma
11. Mutfak Tekstili

### Recommended owner position

11 L2'yi koru; manuel çay/kahve demlemeyi Züccaciye'de, elektrikli cihazı Beyaz Eşya & Ev Aletleri'nde tut; mutfak tekstilini kullanım bağlamına göre burada; teknik outdoor termosu Spor & Outdoor'da sahiplen; gıda temaslı saklamayı genel ev düzenlemeden ayır; endüstriyel/profesyonel mutfak ekipmanını V1 perakende kapsamı dışında tut. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-KITCHEN-P0-01

**DECISION ID:** `B01-KITCHEN-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 11 L2 adı ve sırası Züccaciye & Mutfak omurgası olarak kabul edilsin mi?

**OPTION A:** 11 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Pişirme, hazırlık, sofra, saklama ve taşıma ihtiyaçlarını elektrikli cihazlardan ayırır.
**CROSS-DOMAIN EFFECT:** Aşağıdaki boundary kararları dışında komşu L1'lere etkisi düşüktür.
**RISK IF DEFERRED:** Ürün leaf'leri ve mutfak discovery akışı üst kategori kararı olmadan bekler.

#### B01-KITCHEN-P0-02

**DECISION ID:** `B01-KITCHEN-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Manuel çay/kahve demleme ekipmanı ile elektrikli demleme cihazı nasıl ayrılmalı?

**OPTION A:** Cezve, dripper, French press ve manuel ekipman burada; elektrikli cihaz Beyaz Eşya & Ev Aletleri'nde olsun.
**OPTION B:** Tüm demleme ekipmanını Züccaciye & Mutfak'ta topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Enerji kaynağı ve cihaz niteliği belirgin, sürdürülebilir bir boundary sağlar.
**CROSS-DOMAIN EFFECT:** Beyaz Eşya & Ev Aletleri proposal'ıyla ownership eşleştirilmelidir.
**RISK IF DEFERRED:** Elektrikli kahve makineleri manuel gereçlerle duplicate leaf kazanabilir.

#### B01-KITCHEN-P0-03

**DECISION ID:** `B01-KITCHEN-P0-03`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Mutfak tekstili Ev Tekstili mi, Züccaciye & Mutfak mı sahiplenmeli?

**OPTION A:** Mutfakta işlevsel kullanılan önlük, kurulama bezi, fırın eldiveni ve masa-mutfak tekstili burada; genel dekoratif ev tekstili Ev & Yaşam'da olsun.
**OPTION B:** Tüm tekstil ürünlerini Ev & Yaşam'a taşı.

**RECOMMENDED OPTION:** Option A.
**WHY:** Mutfak işlevi ürün materyalinden daha güçlü discovery niyeti oluşturur.
**CROSS-DOMAIN EFFECT:** Ev Tekstili L2'siyle tek-primary-leaf kuralı gerekir.
**RISK IF DEFERRED:** Mutfak havlusu ve masa tekstili iki L1 altında çoğalır.

#### B01-KITCHEN-P0-04

**DECISION ID:** `B01-KITCHEN-P0-04`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Outdoor/teknik termos ve mataraların ownership'i nerede olmalı?

**OPTION A:** Günlük gıda/içecek taşıma ürünü burada; teknik outdoor performansı baskın ürün Spor & Outdoor'da olsun.
**OPTION B:** Tüm termos ve mataraları Züccaciye & Mutfak'ta tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** İzolasyon/taşıma formu ortak olsa da teknik outdoor kullanımı farklı bir primary intent yaratır.
**CROSS-DOMAIN EFFECT:** Spor & Outdoor leaf/facet yapısıyla ortak boundary tanımı gerekir.
**RISK IF DEFERRED:** Teknik ürünler genel mutfak ürünleri arasında kaybolur veya duplicate olur.

#### B01-KITCHEN-P0-05

**DECISION ID:** `B01-KITCHEN-P0-05`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Mutfak saklama ile genel ev düzenleme arasındaki primary ownership kuralı ne olmalı?

**OPTION A:** Gıda teması/saklama amacı baskınsa Züccaciye & Mutfak; genel eşya düzenleme amacı baskınsa Ev & Yaşam kullan.
**OPTION B:** Tüm saklama ve organizer ürünlerini Ev & Yaşam'da topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Gıda teması kullanım, malzeme ve güvenlik niteliklerini değiştirir.
**CROSS-DOMAIN EFFECT:** Düzenleme & Saklama L2'si ve food-contact policy metadata'sı etkilenir.
**RISK IF DEFERRED:** Saklama kabı, organizer ve erzak kutuları tutarsız leaf'lere atanır.

#### B01-KITCHEN-P1-06

**DECISION ID:** `B01-KITCHEN-P1-06`
**PRIORITY:** `P1`
**POLICY CLASS:** `EXCLUDED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Endüstriyel/profesyonel mutfak ekipmanı V1 kapsamına alınmalı mı?

**OPTION A:** Ev/perakende ölçeğindeki ürünleri dahil et; endüstriyel kurulum ve profesyonel sistemleri exclude/defer et.
**OPTION B:** Profesyonel mutfak ekipmanını aynı L2'lere dahil et.

**RECOMMENDED OPTION:** Option A.
**WHY:** Endüstriyel ürünler kurulum, servis ve B2B satın alma beklentisi taşır.
**CROSS-DOMAIN EFFECT:** Beyaz Eşya & Ev Aletleri ve merchant service kapsamıyla birlikte değerlendirilmelidir.
**RISK IF DEFERRED:** Tüketici discovery'si proje/kurulum ürünleriyle karışır.

### Low-risk decisions

- Pişirme kapları, hazırlık, bıçak, sofra ve servis L2'leri topluca kabul edilebilir.
- Manuel/elektrikli ayrımı netleştiğinde mevcut L2 adı düşük risklidir.

### High-impact decisions

- `B01-KITCHEN-P0-02`–`B01-KITCHEN-P0-05` komşu L1'lerle primary ownership sınırı kurar.
- `B01-KITCHEN-P1-06` tüketici ürünü ile profesyonel sistem kapsamını ayırır.

### Policy-sensitive decisions

- `B01-KITCHEN-P0-05` — `REGULATED`
- `B01-KITCHEN-P1-06` — `EXCLUDED`

## Yapı, Hırdavat & Tesisat

### Proposed L2

1. El Aletleri & Atölye Ekipmanları
2. Elektrikli & Akülü El Aletleri
3. Alet Uçları, Aksesuarları & Sarfları
4. Bağlantı Elemanları & Nalburiye
5. Ölçüm, Test & İşaretleme
6. Boya, Kaplama & Yüzey Hazırlama
7. Yapıştırıcı, Dolgu & Yapı Kimyasalları
8. Yapı Malzemeleri
9. Su Tesisatı & Armatürler
10. Elektrik Tesisatı Malzemeleri
11. Isıtma, Gaz & Havalandırma Tesisatı
12. Kilit, Kapı & Pencere Donanımları
13. Kaynak, Lehim & Metal İşleme
14. İş Güvenliği & Koruyucu Donanım

### Recommended owner position

14 L2'yi koru; sertifikalı occupational PPE'yi burada sahiplen; normal taşınabilir aydınlatmayı Ev'e, sabit elektrik malzemesini buraya, akıllı ürünü Elektronik'e ata; cihaza özel tool batarya/şarjını burada, generic charging ürününü Elektronik'te tut; installer-only gaz/HVAC ürünlerine sıkı policy uygula; mekanik kilidi burada, smart lock'u Elektronik'te sahiplen; maker/circuit bileşenlerini Elektronik'e bırak. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-HARDWARE-P0-01

**DECISION ID:** `B01-HARDWARE-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 14 L2 adı ve sırası Yapı, Hırdavat & Tesisat omurgası olarak kabul edilsin mi?

**OPTION A:** 14 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Perakende yapı ürünlerini araç, sarf, tesisat, yüzey ve güvenlik amaçlarıyla ayrıştırır.
**CROSS-DOMAIN EFFECT:** Özel elektronik, ev ve giyim sınırları ayrıca kapatılmalıdır.
**RISK IF DEFERRED:** En fazla cross-domain bağımlılığı olan Batch 01 alanında diğer owner kararları bekler.

#### B01-HARDWARE-P0-02

**DECISION ID:** `B01-HARDWARE-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Occupational PPE'nin primary ownership'i burada mı, Giyim & Moda'da mı olmalı?

**OPTION A:** Sertifikalı/koruyucu PPE burada; normal üniforma Giyim & Moda'da olsun.
**OPTION B:** Giyilebilir tüm ürünleri Giyim & Moda'da tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Koruyucu performans ve uygunluk standardı ürün formundan daha belirleyicidir.
**CROSS-DOMAIN EFFECT:** Giyim & Moda `B01-CLOTHING-P0-06` kararıyla birlikte kapatılmalıdır.
**RISK IF DEFERRED:** Aynı güvenlik ürünü iki L1'de görünür ve compliance alanları ayrışır.

#### B01-HARDWARE-P0-03

**DECISION ID:** `B01-HARDWARE-P0-03`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Normal aydınlatma, elektrik tesisatı ve smart lighting ownership'i nasıl ayrılmalı?

**OPTION A:** Taşınabilir/dekoratif normal aydınlatma Ev'de; sabit tesisat/armatür burada; bağlantılı kontrol/akıllı ürün Elektronik'te olsun.
**OPTION B:** Elektrikle ilgili tüm ürünleri bu L1'de topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Kullanım ortamı, kurulum riski ve bağlantılı cihaz işlevi ayrı primary intent'lerdir.
**CROSS-DOMAIN EFFECT:** Ev & Yaşam ve Elektronik proposal'larıyla üçlü boundary gerekir.
**RISK IF DEFERRED:** Ampul, anahtar, armatür ve smart hub sınıfları çakışır.

#### B01-HARDWARE-P0-04

**DECISION ID:** `B01-HARDWARE-P0-04`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Tool battery ve charger ürünleri Hırdavat mı, Elektronik mi sahiplenmeli?

**OPTION A:** Belirli alet platformuna özel batarya/şarj burada; generic güç/şarj ürünleri Elektronik'te olsun.
**OPTION B:** Tüm batarya ve şarj ürünlerini Elektronik'e taşı.
**OPTION C:** Tümünü Hırdavat'ta tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Cihaz ekosistemi uyumluluğu primary satın alma amacını belirler.
**CROSS-DOMAIN EFFECT:** Elektronik aksesuarları ve ilerideki compatibility facet'i etkilenir.
**RISK IF DEFERRED:** Alete özel batarya generic şarj ürünleri arasında kaybolur veya duplicate olur.

#### B01-HARDWARE-P1-05

**DECISION ID:** `B01-HARDWARE-P1-05`
**PRIORITY:** `P1`
**POLICY CLASS:** `REGULATED`, `LEGAL_REVIEW_REQUIRED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Installer-only HVAC/gaz ürünleri müşteri discovery kapsamına nasıl alınmalı?

**OPTION A:** Perakende satışı ve bağımsız ürün olarak kullanımı uygun parçaları policy ile dahil et; lisanslı kurulum/proje gerektiren sistemleri görünür perakende kapsamından exclude et.
**OPTION B:** Tüm HVAC/gaz ürünlerini normal şekilde listele.
**OPTION C:** Tüm alanı V1'den çıkar.

**RECOMMENDED OPTION:** Option A, hukuki ve operasyonel doğrulama koşuluyla.
**WHY:** Bazı parçalar normal perakende ürünü iken bazıları ciddi kurulum ve güvenlik riski taşır.
**CROSS-DOMAIN EFFECT:** Beyaz Eşya & Ev Aletleri, merchant service kapsamı ve eligibility policy birlikte incelenmelidir.
**RISK IF DEFERRED:** Yetkisiz kurulum gerektiren ürünler normal kullanıcı ürünü gibi sunulabilir.

#### B01-HARDWARE-P0-06

**DECISION ID:** `B01-HARDWARE-P0-06`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Smart lock ile mechanical lock hangi L1'lerde sahiplenilmeli?

**OPTION A:** Mekanik kilit ve kapı donanımı burada; bağlantılı/smart lock Elektronik'te olsun.
**OPTION B:** Tüm kilitleri Yapı, Hırdavat & Tesisat'ta tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Bağlantı, yazılım ve elektronik ekosistem smart lock'un ana ürün deneyimidir.
**CROSS-DOMAIN EFFECT:** Elektronik güvenlik/akıllı ev leaf'leriyle ownership eşleştirilmelidir.
**RISK IF DEFERRED:** Smart lock ürünleri mekanik donanım ve elektronik altında duplicate olur.

#### B01-HARDWARE-P0-07

**DECISION ID:** `B01-HARDWARE-P0-07`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Direnç, sensör, geliştirme kartı ve benzeri electronic components burada mı, Elektronik'te mi olmalı?

**OPTION A:** Devre/maker elektronik bileşenleri Elektronik'te; elektrik tesisat ve metal işleme sarfları burada olsun.
**OPTION B:** Atölyede kullanılabilen tüm bileşenleri Hırdavat'a dahil et.

**RECOMMENDED OPTION:** Option A.
**WHY:** Devre işlevi ve elektronik uyumluluk, atölye kullanım bağlamından daha kalıcıdır.
**CROSS-DOMAIN EFFECT:** Owner-onaylı Elektronik L2/L3 yapısıyla kesin mapping gerekir.
**RISK IF DEFERRED:** Maker ürünleri lehim sarfları ve elektrik tesisat parçalarıyla karışır.

### Low-risk decisions

- El aletleri, elektrikli el aletleri, uç/sarf, bağlantı elemanları ve ölçüm omurgası topluca kabul edilebilir.
- Boya/yüzey, yapı kimyasalı ve yapı malzemesi ayrımı proposal haliyle düşük yapısal risk taşır.

### High-impact decisions

- `B01-HARDWARE-P0-02`–`B01-HARDWARE-P0-07` komşu alanlar veya güvenlik policy'siyle birlikte kapatılmalıdır.
- Bu alan Batch 01 içinde global review bağımlılığı en yüksek olan alandır.

### Policy-sensitive decisions

- `B01-HARDWARE-P0-02` — `REGULATED`
- `B01-HARDWARE-P0-03` — `REGULATED`
- `B01-HARDWARE-P1-05` — `REGULATED`, `LEGAL_REVIEW_REQUIRED`

## Kozmetik & Kişisel Bakım

### Proposed L2

1. Makyaj
2. Cilt Bakımı
3. Güneş Bakımı
4. Saç Bakımı & Şekillendirme
5. Parfüm & Deodorant
6. Banyo & Vücut Bakımı
7. El, Ayak & Tırnak Bakımı
8. Ağız & Diş Bakımı
9. Kişisel Hijyen
10. Tıraş, Ağda & Epilasyon
11. Kozmetik & Bakım Aksesuarları

### Recommended owner position

11 L2'yi ve Güneş Bakımı'nın ayrı L2 olmasını koru; bebek bakım ürünlerini Anne & Bebek'e bırak; elektrikli grooming cihazlarını Beyaz Eşya & Ev Aletleri'nde, cihaza özel replacement aksesuarını cihazın domain'inde sahiplen; medikal/biyosidal intended-use ürünleri Sağlık & Medikal ve hukuki review'a yönlendir; claim-sensitive ürünleri policy metadata ile yönet. Bu öneriler owner kararı değildir.

### Owner decisions required

#### B01-COSMETICS-P0-01

**DECISION ID:** `B01-COSMETICS-P0-01`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Önerilen 11 L2 adı ve sırası Kozmetik & Kişisel Bakım omurgası olarak kabul edilsin mi?

**OPTION A:** 11 L2'yi aynen kabul et.
**OPTION B:** Owner tarafından etkisi açıkça belirtilen L2 revizyonlarını iste.
**OPTION C:** Omurga kararını ertele.

**RECOMMENDED OPTION:** Option A.
**WHY:** Gündelik bakım görevlerini ürün formundan bağımsız, kullanıcı niyetiyle ayrıştırır.
**CROSS-DOMAIN EFFECT:** Yaş, cihaz ve medikal kullanım sınırları ayrıca kapatılmalıdır.
**RISK IF DEFERRED:** Policy-sensitive ürünler için L3/L4 çalışması ortak omurga olmadan ilerler.

#### B01-COSMETICS-P0-02

**DECISION ID:** `B01-COSMETICS-P0-02`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `NOT REQUIRED`

**QUESTION:** Güneş Bakımı ayrı L2 olarak mı kalmalı, Cilt Bakımı altında mı olmalı?

**OPTION A:** Ayrı Güneş Bakımı L2'sini koru.
**OPTION B:** Cilt Bakımı altına gelecekteki L3 olarak taşı.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yüksek discovery önemi, mevsimsellik, SPF/claim metadata'sı ve ayrı ürün ailesi bağımsız L2'yi destekler.
**CROSS-DOMAIN EFFECT:** Kozmetik içi L3 derinliği ve policy filtering etkilenir.
**RISK IF DEFERRED:** 11 L2'lik omurga onaylanamaz ve güneş ürünleri cilt bakımında görünmezleşebilir.

#### B01-COSMETICS-P0-03

**DECISION ID:** `B01-COSMETICS-P0-03`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Bebek kozmetiği ve kişisel bakım ürünlerinin primary ownership'i nerede olmalı?

**OPTION A:** Açıkça bebek kullanımına yönelik ürünler Anne & Bebek'te; genel aile/erişkin ürünleri burada olsun.
**OPTION B:** Tüm kozmetik ve kişisel bakım ürünlerini bu L1'de tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Yaş evresi, içerik beklentisi ve bakım bağlamı primary intent'i değiştirir.
**CROSS-DOMAIN EFFECT:** Anne & Bebek L2/L3 yapısı ve yaş facet'i etkilenir.
**RISK IF DEFERRED:** Bebek ürünleri iki L1 altında çoğalır veya yaşa özel policy bilgisi kaybolur.

#### B01-COSMETICS-P0-04

**DECISION ID:** `B01-COSMETICS-P0-04`
**PRIORITY:** `P0`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Elektrikli tıraş, epilasyon ve grooming cihazlarının primary ownership'i nerede olmalı?

**OPTION A:** Elektrikli cihazlar Beyaz Eşya & Ev Aletleri'nde; manuel/kozmetik tüketim ürünleri burada olsun.
**OPTION B:** Kullanım amacı nedeniyle tüm grooming cihazlarını Kozmetik & Kişisel Bakım'da tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Elektrikli cihaz yaşam döngüsü, teknik özellik ve servis beklentisi tüketim ürününden farklıdır.
**CROSS-DOMAIN EFFECT:** Beyaz Eşya & Ev Aletleri personal-care appliance leaf'leriyle mapping gerekir.
**RISK IF DEFERRED:** Tıraş makinesi hem appliance hem bakım leaf'inde duplicate olur.

#### B01-COSMETICS-P1-05

**DECISION ID:** `B01-COSMETICS-P1-05`
**PRIORITY:** `P1`
**POLICY CLASS:** `NORMAL`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Grooming cihazlarının replacement başlık, bıçak ve benzeri aksesuarları nerede sahiplenilmeli?

**OPTION A:** Cihaza özel replacement aksesuarı cihazın L1/leaf ailesinde; generic manuel bakım aksesuarı burada olsun.
**OPTION B:** Tüm replacement aksesuarları Kozmetik & Bakım Aksesuarları'nda topla.

**RECOMMENDED OPTION:** Option A.
**WHY:** Uyumluluk, cihaz ekosistemi ve satın alma amacı en güvenilir primary leaf sinyalidir.
**CROSS-DOMAIN EFFECT:** Beyaz Eşya & Ev Aletleri compatibility facet'i etkilenir.
**RISK IF DEFERRED:** Uyumlu başlıklar cihaz discovery'sinden kopar veya iki L1'de listelenir.

#### B01-COSMETICS-P0-06

**DECISION ID:** `B01-COSMETICS-P0-06`
**PRIORITY:** `P0`
**POLICY CLASS:** `REGULATED`, `LEGAL_REVIEW_REQUIRED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Dermokozmetik, medikal veya biyosidal intended-use taşıyan ürünler hangi L1'de olmalı?

**OPTION A:** Kozmetik amaçlı ürün burada; tedavi/medikal/biyosidal intended-use Sağlık & Medikal veya exclude/legal review yolunda olsun.
**OPTION B:** Ürün formu kozmetikse tüm intended-use türlerini burada tut.

**RECOMMENDED OPTION:** Option A.
**WHY:** Ürünün iddiası ve hukuki sınıfı, ambalaj/form benzerliğinden daha önemlidir.
**CROSS-DOMAIN EFFECT:** Sağlık & Medikal ownership'i, merchant eligibility ve moderation policy etkilenir.
**RISK IF DEFERRED:** Medikal iddialı ürünler normal kozmetik gibi yayınlanabilir.

#### B01-COSMETICS-P2-07

**DECISION ID:** `B01-COSMETICS-P2-07`
**PRIORITY:** `P2`
**POLICY CLASS:** `REGULATED`, `LEGAL_REVIEW_REQUIRED`
**GLOBAL REVIEW:** `REQUIRES GLOBAL CROSS-BATCH REVIEW`

**QUESTION:** Claim-sensitive ürünler taxonomy leaf'iyle mi, policy metadata ve moderation ile mi yönetilmeli?

**OPTION A:** Taxonomy'yi ürün amacına göre koru; claim/risk sınıfını ayrı policy metadata ve moderation ile yönet.
**OPTION B:** Her claim türü için ayrı taxonomy leaf'i oluştur.

**RECOMMENDED OPTION:** Option A.
**WHY:** Claim değişebilir; ürünün kalıcı taxonomy identity'si pazarlama iddiasına bağlanmamalıdır.
**CROSS-DOMAIN EFFECT:** Sağlık & Medikal ile ortak claim sözlüğü ve review süreci gerekir.
**RISK IF DEFERRED:** Leaf ağacı hukuki/pazarlama terimleriyle büyür ve tutarsız enforcement oluşur.

### Low-risk decisions

- Makyaj, saç, parfüm, vücut, el/ayak/tırnak, ağız/diş ve hijyen omurgası topluca kabul edilebilir.
- Cihaza özgü aksesuarlar için compatibility-first kuralı teknik olarak düşük risklidir; owner boundary onayı yine gereklidir.

### High-impact decisions

- `B01-COSMETICS-P0-02` L2 sayısını doğrudan etkiler.
- `B01-COSMETICS-P0-03`, `B01-COSMETICS-P0-04` ve `B01-COSMETICS-P0-06` komşu L1 ownership'lerini etkiler.

### Policy-sensitive decisions

- `B01-COSMETICS-P0-02` — `REGULATED`
- `B01-COSMETICS-P0-03` — `REGULATED`
- `B01-COSMETICS-P0-06` — `REGULATED`, `LEGAL_REVIEW_REQUIRED`
- `B01-COSMETICS-P2-07` — `REGULATED`, `LEGAL_REVIEW_REQUIRED`

## Batch 01 summary

`Likely approve-as-is`, yalnız mevcut L2 adları ve sırasının toplu kabul olasılığını ifade eder; boundary/policy kararlarının kapandığı anlamına gelmez.

| L1 | Proposed L2 count | Owner decision count | P0 | P1 | P2 | Policy-sensitive | Likely approve-as-is | Requires global cross-batch review |
|---|---:|---:|---:|---:|---:|---:|:---:|:---:|
| Gıda & İçecek | 14 | 6 | 4 | 2 | 0 | 4 | YES | YES |
| Giyim & Moda | 10 | 6 | 4 | 2 | 0 | 1 | NO | YES |
| Ev & Yaşam | 10 | 6 | 4 | 2 | 0 | 3 | YES | YES |
| Züccaciye & Mutfak | 11 | 6 | 5 | 1 | 0 | 2 | YES | YES |
| Yapı, Hırdavat & Tesisat | 14 | 7 | 6 | 1 | 0 | 3 | NO | YES |
| Kozmetik & Kişisel Bakım | 11 | 7 | 5 | 1 | 1 | 4 | NO | YES |
| **TOTAL** | **70** | **38** | **28** | **9** | **1** | **17** | — | — |

- `TOTAL L1 = 6`
- `TOTAL PROPOSED L2 = 70`
- `TOTAL OWNER DECISIONS = 38`
- `P0 COUNT = 28`
- `P1 COUNT = 9`
- `P2 COUNT = 1`
- `POLICY-SENSITIVE COUNT = 17`
- `GLOBAL-REVIEW-REQUIRED COUNT = 25`

## Suggested owner-review order

1. **Yapı, Hırdavat & Tesisat** — en fazla komşu L1 ve güvenlik/policy bağımlılığına sahip.
2. **Kozmetik & Kişisel Bakım** — medikal intended-use, claim ve cihaz sınırları birlikte kapanmalı.
3. **Gıda & İçecek** — bebek, supplement ve alkol kapsamı yüksek etkili owner/policy kararı gerektiriyor.
4. **Giyim & Moda** — tesettür facet kararı ile maternity, spor ve PPE ownership'i netleşmeli.
5. **Ev & Yaşam** — aydınlatma, bahçe, cabinetry ve tesisat boundary'leri önceki kararlarla hizalanabilir.
6. **Züccaciye & Mutfak** — omurga düşük riskli; cihaz, tekstil, outdoor ve saklama sınırları önceki kararları kullanabilir.

Bu sıra karar bağımlılıklarını azaltmak için önerilmiştir. Owner farklı sırayla inceleyebilir; bu belge hiçbir kararı owner adına kapatmaz.
