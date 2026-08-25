# EsnaftaVar Category Taxonomy — Product Owner Review Pack

**Wave:** 15 / Phase B

**Kaynak sürüm:** `2026-08-25.v1-draft`

**Kaynak commit:** `52845b6bdeca4864ce49774c35f7c5dbe37d1a93`

**Durum:** Product owner kararı bekliyor

**Kapsam:** Karar paketi; taxonomy, JSON, migration, seed ve runtime değişikliği yoktur.

## Bu belge nasıl kullanılmalı?

Bu belge 648 node'u tekrar anlatmaz. Product owner'ın yalnız üç şeyi yapması beklenir:

1. L1 sınırları için önerilen varsayılanları kabul etmek veya değiştirmek.
2. Tartışmalı 24 dalda önerilen seçeneği kabul etmek ya da istisna belirtmek.
3. Belgenin sonundaki 15 kısa ürün kararını onaylamak.

**Önemli:** Aşağıdaki `SPLIT` ve dal taşıma önerileri açıkça işaretlenmiş alternatiflerdir; mevcut 20 L1 / 648 node taslağına uygulanmamıştır. Onaylanan değişiklikler ayrı bir taxonomy revizyonunda ele alınmalıdır.

## Karar özeti

| Konu | Önerilen varsayılan |
|---|---|
| Mevcut kaynak | 20 L1, 91 L2, 505 L3, 32 L4; toplam 648 node ve 526 atanabilir leaf korunur. |
| L1 sınırları | 17 L1 `KEEP`; `Kitap & Kırtasiye`, `Optik, Saat & Takı` ve `Çiçek, Bahçe & Hediyelik` için `SPLIT` alternatifi onaylansın. |
| Home görünürlüğü | Başlangıçta 8 organik kısayol; `Tüm Kategoriler` içinde canonical kapsamın tamamı. |
| Tartışmalı dallar | 24 karar noktası; tabloda her biri için önerilen varsayılan var. |
| Regüle ürünler | Policy ve moderasyon sahibi yoksa fail-closed/inactive. Risk flag yayın izni değildir. |
| İkinci el | V1'de `DEFER`; gelecekte ayrı kategori değil `condition` attribute'u. |
| Shop type | Product taxonomy'den ayrı, sonraki bir merchant-domain çalışması. |
| Attribute pilot | 8 temsilî leaf üzerinde required/facet/variant/compliance pilotu. |
| Governance | Immutable slug, sürümlü değişiklik, deprecation/replacement mapping ve ölçümlü alias yönetimi. |

## 1. L1 review

`Leaf` sayısı ilgili L1 altındaki atanabilir ürün yapraklarını gösterir. Recommendation mevcut taslağı otomatik değiştirmez.

| Kategori | Kısa kapsam | L2 | Leaf | Neden ayrı L1 | Olası overlap | Recommendation |
|---|---|---:|---:|---|---|---|
| Market & Gıda | Temel gıda, kahvaltılık, içecek, taze/donuk ürün | 4 | 28 | Yüksek yerel sıklık; miktar, alerjen, menşei ve saklama sözleşmesi | Ev temizlik sarfı; sağlık destekleri | **KEEP** |
| Moda & Giyim | Üst/alt/dış/iç ve fonksiyonel giyim | 4 | 22 | Beden, kalıp, materyal ve varyant eksenleri kendine özgü | Ayakkabı; giyim aksesuarı; iş kıyafeti | **KEEP** |
| Ayakkabı | Günlük, spor, bot, terlik ve uzmanlık ayakkabısı | 4 | 19 | Numara, kalıp, kullanım ve güvenlik özellikleri ayrı | Spor; medikal; iş güvenliği | **KEEP** |
| Çanta & Giyim Aksesuarı | Günlük/cihaz/seyahat çantaları ve giyim tamamlayıcıları | 4 | 21 | Taşıma biçimi, kapasite, ölçü ve materyal odaklı ürün grubu | Bilgisayar/kamera; moda; seyahat | **KEEP** |
| Elektronik | Telefon, giyilebilir teknoloji, ses/görüntü, kamera, konsol, güç | 6 | 39 | Hızlı ürün döngüsü, cihaz uyumluluğu ve teknik özellikler | Bilgisayar; saat; bebek cihazı; müzik | **KEEP** |
| Bilgisayar & Tablet | Bilgisayar/tablet, bileşen, çevre birimi, ağ ve baskı | 4 | 28 | Bileşen uyumluluğu ve teknik şema elektronik genelden daha derin | Elektronik kablo/güç; kırtasiye baskı sarfı | **KEEP** |
| Beyaz Eşya & Ev Aletleri | Büyük/küçük elektrikli ev cihazları ve iklimlendirme | 4 | 25 | Enerji, güç, garanti, kurulum ve cihaz güvenliği | Ev & Yaşam; züccaciye; kişisel bakım cihazı | **KEEP** |
| Ev & Yaşam | Mobilya, tekstil, dekorasyon, banyo ve ev sarfı | 5 | 29 | Oda, ölçü, materyal ve kullanım bağlamı | Züccaciye; beyaz eşya; market sarfı; bahçe dekoru | **KEEP** |
| Züccaciye & Mutfak | Elektriksiz pişirme, hazırlık, sofra ve saklama gereçleri | 5 | 26 | Gıda temas materyali, kapasite ve set yapısı | Elektrikli mutfak cihazı; outdoor matara | **KEEP** |
| Yapı & Hırdavat | Alet, bağlantı, boya/kimyasal, tesisat, yapı ve İSG | 6 | 31 | Teknik ölçü, güvenlik ve profesyonel kullanım sözleşmesi | Bahçe aleti; oto aleti; iş kıyafeti/ayakkabısı | **KEEP** |
| Otomotiv & Motosiklet | Aksesuar, elektronik, bakım, yedek parça, lastik ve moto | 5 | 32 | Araç marka-model-yıl-motor fitment'i ve güvenlik kritik eşleşme | Elektronik; spor/outdoor koruyucu ekipman | **KEEP** |
| Kişisel Bakım & Kozmetik | Cilt, makyaj, saç, hijyen, parfüm ve tıraş bakımı | 5 | 26 | Cilt/saç tipi, renk tonu, içerik ve claim moderasyonu | Sağlık; elektrikli kişisel bakım cihazı | **KEEP** |
| Bebek & Çocuk | Bebek bakım, beslenme, taşıma, güvenlik ve gelişim gereçleri | 4 | 20 | Yaş/evre ve çocuk güvenliği ürün şemasının merkezidir | Oyuncak; çocuk kitabı; bebek kamerası; giyim | **KEEP** |
| Oyuncak, Hobi & Müzik | Oyuncak, oyun, sanat kiti, koleksiyon ve enstrüman | 5 | 24 | Yaş uygunluğu, aktivite ve enstrüman türüyle ayrışır | Kırtasiye sanat malzemesi; elektronik; spor | **KEEP** — V1 sonrası coverage ölçülmeli |
| Spor & Outdoor | Fitness, takım/raket, bisiklet, kamp ve su/kış sporları | 5 | 26 | Spor dalı, kullanım ortamı ve güvenlik özellikleri ortaktır | Spor ayakkabı/giyim; takviye; matara; balıkçılık | **KEEP** |
| Kitap & Kırtasiye | Kitap içeriği ile okul/ofis/sanat/paketleme ürünleri | 5 | 40 | Her iki alan da güçlü yerel talep taşır | Kitapta ISBN/yazar/yayınevi; kırtasiyede fiziksel ölçü/renk/uyumluluk tamamen farklıdır | **SPLIT** — açık alternatif: `Kitap` + `Kırtasiye & Ofis` |
| Pet Shop | Evcil hayvan maması, ekipmanı, bakım ve sağlık desteği | 4 | 25 | Tür, yaşam evresi, mama formu ve pet uyumluluğu kendine özgüdür | İnsan sağlığı; market gıda; canlı hayvan | **KEEP** |
| Optik, Saat & Takı | Regüle optik ürünler, saat ve mücevher | 3 | 17 | Üçü de güçlü fiziksel uzman perakende alanıdır | Optik ile sağlık; akıllı saat ile elektronik; takı ile moda | **SPLIT** — açık alternatif: `Optik` + `Saat & Takı` |
| Sağlık & Medikal | İlk yardım, ölçüm, ortopedi, günlük bakım ve destek ürünleri | 5 | 26 | Medikal cihaz sınıfı, belge, claim ve güvenlik kontrolü gerektirir | Optik; kişisel bakım; spor desteği; medikal ayakkabı | **KEEP** — yalnız fail-closed policy ile |
| Çiçek, Bahçe & Hediyelik | Bitki/çiçek, yetiştirme, hediyelik ve parti ürünleri | 4 | 22 | Yerel çiçekçi ve hediyelikçi arzını kapsar | Ev dekoru; hırdavat; oyuncak; occasion collection | **SPLIT** — açık alternatif: `Çiçek & Bahçe` + `Hediyelik & Parti` |

### L1 varsayılan kararı

Mevcut 20 L1, owner kararı verilene kadar kaynak taslak olarak kalmalıdır. Agent önerisi üç heterojen L1'i bir sonraki revizyonda ayırmak, diğer 17 L1'i korumaktır. Bu kabul edilirse yeni L1 sayısı ayrıca revizyonda yeniden hesaplanır; bu belge sayı veya node değişikliği yapmaz.

## 2. Home visibility

Canonical taxonomy ürün gerçeğidir; Home ise lokasyon ve kullanılabilirlik bağlamında oluşturulan bir projection'dır. Canonical node'un varlığı Home'da zorunlu görünürlük veya yüksek sıra hakkı vermez.

### Önerilen başlangıç

- **Canonical kapsam:** Mevcut 20 L1'in tamamı registry'de kalır.
- **Home:** İlk açılışta **8 organik kategori kısayolu** gösterilir.
- **Önerilen başlangıç kısayolları:** Market & Gıda; Kitap & Kırtasiye; Elektronik; Ayakkabı; Moda & Giyim; Ev & Yaşam; Kişisel Bakım & Kozmetik; Yapı & Hırdavat.
- **Eligibility:** Kısayol ancak kullanıcının keşif alanında aktif mağaza ve yayımlanabilir ürün/offer kapsamı varsa Home sıralamasına girer. Eksik olanın yerine sıradaki uygun L1 gelir.
- **Projection özgürlüğü:** Home kısayolu tek canonical L1'e veya açıkça tanımlanmış bir L1 grubuna gidebilir. Örneğin canonical kitap/kırtasiye ayrılırsa Home etiketi yine birleşik bir kısayol olabilir.

### “Tüm Kategoriler” davranışı

1. Mevcut sürümde 20 canonical L1'in tamamını, sponsor etkisi olmayan canonical sırayla listeler.
2. Yakında ürünü olanlar önce aktif gezinme öğesi olur; kapsamsız olanlar listenin sonunda “Bu bölgede henüz ürün yok” durumuyla görünür ve boş sonuç ekranına göndermez.
3. L1'e girildiğinde yalnız aktif ve bölgesel olarak anlamlı L2/L3 projection'ı gösterilir; canonical ağaç silinmez.
4. Search, Home'da görünmeyen fakat aktif/yayımlanabilir kategorileri bulabilir.

### Gelecekte organik sıralama

Organik Home sırası; yakındaki aktif mağaza sayısı, stoklu ürün kapsamı, son 28 günlük arama/tıklama/favori ve doğrulanmış fiziksel alışveriş sinyalleriyle haftalık ve stabil biçimde güncellenebilir. Yeni kategori keşfi için çeşitlilik sınırı bulunmalıdır. Sponsorlu alanlar ayrı, açıkça etiketli modüller olmalı; canonical `sort_order` veya organik kategori puanını değiştirmemelidir.

## 3. Questionable branches

Aşağıdaki 24 nokta, 648 node içindeki gerçek sınır veya sınıflandırma kararlarıdır. `Option B` içinde yeni bir ayrım öneriliyorsa “açık alternatif” olarak belirtilmiştir; mevcut taxonomy'ye uygulanmamıştır.

| # | Current path | Problem | Option A | Option B | Agent recommendation |
|---:|---|---|---|---|---|
| 1 | Elektronik > Telefon Aksesuarları > Telefon Tutucu & Giriş Aksesuarları > Araç & Masa Telefon Tutucu | Araç ve masa kullanım bağlamı tek leaf'te birleşiyor. | Tek leaf + kontrollü `mount_context`/uyumluluk değeri | Açık alternatif: araç ve masa tutucuyu ayrı leaf'lere böl | **A — KEEP**; fiziksel ürün çoğu zaman aynı formdur. |
| 2 | Elektronik > Telefon Aksesuarları > Telefon Tutucu & Giriş Aksesuarları > Dokunmatik Kalem | Tablet kullanımında telefon L1'i yanıltıcı olabilir. | Telefon aksesuarında tut, compatibility ile çöz | Bilgisayar & Tablet > Bilgisayar Çevre Birimleri altına taşı | **B — MOVE**; ana kullanım tablet/giriş aygıtıdır. |
| 3 | Elektronik > Telefon & Giyilebilir Teknoloji > Akıllı Saat ↔ Optik, Saat & Takı > Saat & Saat Aksesuarları > Kol Saati | “Saat” aramasında iki L1 vardır. | Bağlantılı cihazı Elektronik, klasik zaman ölçeri Saat altında tut | Tüm saatleri tek dalda birleştir | **A — KEEP**; teknik şema ve merchant verisi farklıdır. |
| 4 | Elektronik > Ses & Görüntü Sistemleri > Mikrofon ↔ Oyuncak, Hobi & Müzik > Müzik Enstrümanı & Ekipmanı | Mikrofon müzik ekipmanı da olabilir; toplantı/yayın ürünü de olabilir. | Elektronik altında tut, kullanım amacı ve bağlantıyı attribute yap | Müzik ekipmanı altına taşı | **A — KEEP**; ana fonksiyon ses yakalamadır, kullanım alanı çokludur. |
| 5 | Elektronik > Kamera & Güvenlik Elektroniği > Bebek Kamerası & Telsizi | Bebek ürünleriyle güçlü browse bağı var. | Elektronik altında tut, Bebek'ten alias/collection ile keşfet | Bebek & Çocuk altına taşı | **A — KEEP**; cihaz teknik şeması önceliklidir. |
| 6 | Elektronik > Oyun Konsolu & Aksesuarları > Fiziksel Video Oyunu | Oyun/hobi dalıyla içerik overlap'i var. | Konsol uyumluluğu nedeniyle Elektronik'te tut | Oyuncak, Hobi & Müzik'e taşı | **A — KEEP**; platform/format doğrulaması belirleyicidir. |
| 7 | Çanta & Giyim Aksesuarı > İş, Okul & Cihaz Çantaları > Laptop Çantası / Fotoğraf Makinesi Çantası | Cihaz L1'lerinde de aranır. | Taşıma işlevi nedeniyle çanta taxonomy'sinde tut | İlgili cihaz L1'lerine taşı | **A — KEEP**; cihaz uyumluluğunu attribute/alias yap. |
| 8 | Moda & Giyim > İç Giyim, Ev Giyimi & Fonksiyonel Giyim > İş Kıyafeti & Üniforma; Ayakkabı > ... > İş Güvenliği Ayakkabısı | Hırdavat'taki İş Eldiveni & Koruyucu Donanım ile sınır karışabilir. | Ürün formuna göre giyim/ayakkabıda tut; safety compliance ekle | Tüm İSG giyilebilirlerini Yapı & Hırdavat'a taşı | **A — KEEP**; form, beden ve varyant şeması daha güçlüdür. |
| 9 | Ayakkabı > Sandalet, Terlik & Uzmanlık Ayakkabısı > Medikal & Konfor Ayakkabısı | Sağlık/medikal claim'i ile ayakkabı formu yarışıyor. | Ayakkabı altında tut ve moderasyon uygula | Sağlık & Medikal'e taşı | **A — KEEP**; leaf adı/claim ve belge politikası ayrıca daraltılmalı. |
| 10 | Beyaz Eşya & Ev Aletleri > Temizlik, İklimlendirme & Kişisel Ev Aleti > Saç Kurutma & Şekillendirme Cihazı / Tıraş & Epilasyon Cihazı | Müşteri ve merchant bunları kişisel bakım altında bekleyebilir. | Elektrikli cihaz oldukları için mevcut yerde tut | Kişisel Bakım & Kozmetik'e taşı | **B — MOVE**; kullanım amacı cihaz türünden daha anlaşılır sınırdır. |
| 11 | Ev & Yaşam > Ev Temizlik & Tüketim Ürünleri > Temizlik Deterjanı / Çamaşır Bakım Ürünü / Kağıt Ürünleri | Market kanalı da bu ürünleri satar. | Ev işlevine göre Ev & Yaşam'da tut | Satış kanalına göre Market & Gıda'ya taşı | **A — KEEP**; shop kanalı canonical ürün sınıfı değildir. |
| 12 | Züccaciye & Mutfak > Bardak & İçecek Servisi > Termos & Matara | Matara spor/outdoor; termos mutfak/seyahat kullanımı taşır. | Tek leaf + kullanım amacı/kapasite attribute'u | Açık alternatif: termosu burada tut, spor matarasını Spor & Outdoor'a ayır | **B — SPLIT ALTERNATIVE**; merchant şeması ve browse amacı ayrışır. |
| 13 | Çiçek, Bahçe & Hediyelik > Bahçe Yetiştirme & Bakım > Bahçe El Aleti | Yapı & Hırdavat > El Aletleri ile overlap vardır. | Kullanım amacına göre bahçe dalında tut | Tüm el aletlerini hırdavatta birleştir | **A — KEEP**; bahçe kullanım şeması ve merchant dili belirgindir. |
| 14 | Çiçek, Bahçe & Hediyelik > Bahçe Yetiştirme & Bakım > Saksı & Bitki Kabı | Ev dekorasyonunda da aranabilir. | Yetiştirme işlevi nedeniyle bahçede tut | Ev & Yaşam > Dekorasyon'a taşı | **A — KEEP**; dekoratif stil facet/collection olabilir. |
| 15 | Kitap & Kırtasiye > Kitaplar > tür leaf'leri | Bir kitap birden fazla türe ait olabilir; çoklu category analitiği bozar. | Tek primary shelf + çoklu `book_genre` attribute'u | Aynı kitabı birden çok canonical leaf'e ata | **A — KEEP MODEL**; tek primary leaf kuralı korunmalı. |
| 16 | Kitap & Kırtasiye > Kitaplar > Çocuk Kitabı / Gençlik Kitabı | Bebek & Çocuk altında da beklenebilir. | İçerik ürünü olarak Kitaplar'da tut; yaş grubunu attribute yap | Yaşa göre Bebek & Çocuk'a taşı | **A — KEEP**; yayıncı/ISBN şeması belirleyicidir. |
| 17 | Kitap & Kırtasiye > Sanat, El İşi & Paketleme ↔ Oyuncak, Hobi & Müzik > ... > Boyama & Çocuk Sanat Seti | Tekil sanat malzemesi ile hazır çocuk seti karışabilir. | Tekil sarf/araç kırtasiyede, tamamlanmış çocuk kiti oyuncakta kalsın | Tüm sanat ürünlerini tek L1'e taşı | **A — KEEP**; merchant label örnekleriyle sınır netleştirilmeli. |
| 18 | Sağlık & Medikal > Besin Desteği & Koruyucu Sağlık Ürünü > Protein & Sporcu Desteği | Spor & Outdoor ile güçlü kullanım bağı var. | Yenilebilir destek olduğu için Sağlık & Medikal'de tut | Spor & Outdoor'a taşı | **A — KEEP**; regülasyon ve claim şeması önceliklidir. |
| 19 | Pet Shop > Pet Bakım, Hijyen & Sağlık Desteği > Pet Sağlık & Destek Ürünü | İnsan sağlığıyla karışabilir ve veteriner ilaç sınırı belirsizleşebilir. | Pet altında tut; veteriner ilaçlarını yasakla, claim/moderasyon uygula | Sağlık & Medikal'e taşı | **A — KEEP**; tür ve yaşam evresi şeması belirleyicidir. |
| 20 | Optik, Saat & Takı > Gözlük & Optik Ürünler > Optik Gözlük Çerçevesi / Hazır Okuma Gözlüğü / Kontakt Lens | Regüle optik ürünler Sağlık & Medikal ile overlap taşır. | Ayrı Optik domaininde tut, aynı compliance altyapısını kullan | Sağlık & Medikal'e taşı | **A — KEEP DOMAIN**; önerilen L1 split'iyle Optik ayrıca görünür olmalı. |
| 21 | Çiçek, Bahçe & Hediyelik > Hediye & Hatıra > Kişiselleştirilebilir Hediye | “Kişiselleştirilebilir” ürünün ne olduğunu değil bir kabiliyeti anlatır. | Ayrı primary leaf olarak tut | Gerçek ürün leaf'ine ata; kişiselleştirmeyi attribute/merchant capability yap | **B — DEPRECATE ALTERNATIVE**; attribute-as-category oluşmamalı. |
| 22 | Çiçek, Bahçe & Hediyelik > Parti & Kutlama > Mevsimsel Süsleme | Mevsim, ürün fonksiyonu değil collection/occasion sinyalidir. | Sezon leaf'i olarak tut | Fiziksel ürün tipine ata; sezonu collection/attribute yap | **B — DEPRECATE ALTERNATIVE**; canonical analitik sezonla parçalanmamalı. |
| 23 | Çiçek, Bahçe & Hediyelik > Hediye & Hatıra > Hediyelik Obje | Çok geniş fallback, merchant'ın yanlış leaf seçmesine açık. | Zorunlu ürün tipi/materyal alanıyla fallback olarak tut | Pilot tamamlanana kadar non-assignable yap; gerçek SKU'lara göre replacement öner | **B — REVIEW/INACTIVE ALTERNATIVE**; kör catch-all olmamalı. |
| 24 | Çiçek, Bahçe & Hediyelik > Parti & Kutlama > Kostüm Partisi Aksesuarı | Moda aksesuarı, oyuncak rol oyunu ve occasion sinyali kesişir. | Yalnız tek kullanımlık/parti amaçlı aksesuarı burada tut | Fiziksel forma göre moda veya oyuncağa taşı | **A — KEEP WITH SCOPE**; kalıcı giyim ve oyuncak ürünleri kabul edilmemeli. |

## 4. Regulated / excluded

Risk flag yalnız review routing sinyalidir; `allowed` veya `published` anlamına gelmez. Moderasyon policy'si bulunmayan riskli leaf varsayılan olarak inactive olmalıdır.

| Durum | V1 kapsamı | Yayın varsayılanı |
|---|---|---|
| **V1 allowed** | Risk flag taşımayan olağan gıda dışı ürünler; raf ömürlü gıda; standart giyim/ayakkabı; genel elektronik; ev, kırtasiye, oyuncak dışı hobi ve pet bakım ürünleri | Standart catalog validation sonrası yayınlanabilir. Marka zorunlu değildir; ürün güvenliği genel yükümlülükleri sürer. |
| **Allowed with moderation** | Soğuk zincir/taze gıda; yaş hassas oyuncak/bebek ürünü; güvenlik kritik oto/İSG ürünleri; pil, akü, aerosol, boya/kimyasal; optik ürün; tıbbi cihaz/sarf; supplement ve sağlık/kozmetik claim'i | Belge, uyarı, kayıt, saklama, uyumluluk veya claim kontrolü tamamlanmadan yayın yok. Kategoriye göre `regulated_review`, `safety_critical`, `hazmat_review`, `age_sensitive`, `claim_sensitive`, `cold_chain`, `compatibility_critical` uygulanır. |
| **Deferred** | İkinci el/yenilenmiş ürünler; ayrıca gerekli policy/moderasyon sahibi henüz tanımlanmamış tüm riskli leaf'ler | V1 merchant yayını kapalı; canonical node var olabilir fakat inactive kalır. |
| **Prohibited / excluded** | Reçeteli/reçetesiz ilaç ve özel tıbbi amaçlı ürün; tütün/nikotin/e-sigara; alkollü içki; ateşli silah/mühimmat/patlayıcı; yasa dışı madde/üretim ekipmanı; canlı hayvan; dijital-only ürün, hizmet ve klasik checkout/kargo domainleri | Taxonomy'ye eklenmez ve yayınlanmaz. Değişiklik ancak ayrı hukuk incelemesi ve açık owner kararıyla değerlendirilir. |

## 5. Second-hand

**Öneri: DEFER.** V1 merchant yayını yeni ürünlerle başlamalıdır. İkinci el ve yenilenmiş ürün; kondisyon derecesi, ayıp/aşınma beyanı, seri numarası, garanti, iade/itiraz ve sahte ürün kontrolü gibi taxonomy'den bağımsız operasyonel gereksinimler doğurur.

Gelecekte ayrı bir “İkinci El” category domaini açılmamalıdır. Aynı canonical leaf üzerinde versiyonlu `condition` (`new`, `refurbished`, `used` gibi) ve condition'a özel merchant policy kullanılmalıdır. Böylece telefon, kitap veya mobilya analitiği kondisyon nedeniyle ayrı ağaçlara bölünmez.

## 6. Shop type taxonomy

**Öneri: Product taxonomy'den ayrı tutulması doğrudur; fakat bu phase'de tasarlanmamalıdır.**

- Product taxonomy “ürün nedir?” sorusunu cevaplar; shop type “merchant hangi işletme kimliği ve operasyon modeliyle çalışır?” sorusunu cevaplar.
- Bir market kırtasiye ürünü, bir telefoncu küçük bilgisayar aksesuarı, bir çiçekçi hediyelik satabilir. Bu nedenle shop type ↔ product L1 ilişkisi many-to-many olmalıdır.
- Shop type; merchant onboarding, belge/izin, mağaza profili, önerilen kategori seti ve arama filtresi için kullanılabilir; canonical ürün kimliği veya yayın izni olmamalıdır.
- Ayrı çalışma ancak merchant app akışı, gerçek esnaf örnekleri ve compliance sahipliği netleşince açılmalıdır.

## 7. Attribute / filter pilot

Product owner 62 filter family'yi tek seferde onaylamamalıdır. Aşağıdaki 8 leaf; teknik spec, varyant, gıda, kırtasiye, fitment ve regülasyon davranışlarını temsil eder.

| Pilot leaf | Temsil ettiği karar | İncelenecek mevcut family'ler | Pilot notu |
|---|---|---|---|
| Elektronik > Telefon & Giyilebilir Teknoloji > Akıllı Telefon | Teknik spec + facet + ürün/varyant sınırı | brand, color, screen_size, storage_capacity, memory_capacity, connectivity, operating_system, warranty | Storage/color'ın variant mı canonical product alanı mı olduğu SKU örnekleriyle kararlaştırılmalı. |
| Ayakkabı > Spor Ayakkabı > Günlük Sneaker | Numara ve renk varyantı + hedef kullanıcı filtresi | brand, color, material, gender, age_group, shoe_size, heel_height, closure_type | Numara değer sözlüğü, unisex ve EU/TR ölçü gösterimi test edilmeli. |
| Moda & Giyim > Üst Giyim > Tişört | Beden/renk varyantı + materyal/kalıp facet'i | brand, color, material, gender, age_group, apparel_size, fit | Merchant beden girişi ve beden tablosu sorumluluğu netleşmeli. |
| Market & Gıda > Kahvaltılık & Süt Ürünleri > Peynir | Miktar, alerjen, menşei ve soğuk zincir | brand, food_quantity, dietary_preference, allergen, origin, flavor, storage_condition | Barkodsuz/açık ürün, satış birimi ve tarih bilgisinin product mı offer mı olduğu ayrılmalı. |
| Kitap & Kırtasiye > Defter, Kağıt & Sunum > Defter | Basit merchant formu + ölçü/format/material | brand, color, material, paper_format, tip_size, piece_count | `tip_size` family'sinin bu leaf'e uygulanabilirliği özellikle doğrulanmalı; gereksiz alan pilotta elenmeli. |
| Otomotiv & Motosiklet > Oto Yedek Parça > Fren Parçaları > Fren Balatası | Çok boyutlu araç fitment'i + güvenlik | brand, vehicle_compatibility, part_position, material, power, warranty, safety_standard | Marka-model-yıl-motor eşleşmesi serbest metin olmamalı; `power` family uygunluğu test edilmeli. |
| Sağlık & Medikal > Ölçüm & Takip Cihazları > Tansiyon Aleti | Belge, cihaz sınıfı ve fail-closed yayın | brand, dimensions, medical_use, medical_device_class, safety_standard | Moderasyon sahibi ve gerekli belge seti yoksa pilot yayına çıkmamalı. |
| Züccaciye & Mutfak > Pişirme Gereçleri > Tencere & Tencere Seti | Materyal, kapasite, ölçü ve set cardinality | brand, color, material, dimensions, capacity, piece_count | Tek ürün/set ayrımı ve çoklu ölçülerin merchant tarafından anlaşılması test edilmeli. |

Pilot; leaf başına 20–30 gerçek SKU ve toplam 6–10 yerel merchant örneğiyle şu çıktıları üretmelidir: required/recommended/optional alan seti, facet/variant/search rolleri, kontrollü değer sözlükleri, validation hataları ve merchant'ın alanı doğru doldurma oranı. Pilot onayı migration veya merchant UI implementation izni değildir.

## 8. Governance

### Basit versioning modeli

Onaylanan ilk baseline `v1.0.0` olarak dondurulmalıdır.

| Değişiklik | Sürüm | Kural |
|---|---|---|
| Display/merchant label, açıklama, alias veya keyword düzeltmesi | PATCH | Stable slug ve parent değişmez; release note ve değişiklik gerekçesi tutulur. |
| Yeni node, parent move veya replacement mapping'li deprecation | MINOR | Eski slug çözülmeye devam eder; move'da slug korunur, eski path sürüm bilgisiyle izlenebilir. |
| L1 sınırı veya node anlamını geriye uyumsuz değiştiren revizyon | MAJOR | Etki analizi, product owner onayı ve açık migration/mapping planı gerekir. |

### Kimlik ve backward compatibility

- **Stable slug:** Onaydan sonra immutable kimliktir; silinmez, başka anlam için tekrar kullanılmaz.
- **Display-name edit:** Slug değişmeden PATCH release ile yapılır. Arama ihtiyacı varsa eski ad alias olarak korunur.
- **Move:** Node slug'ı korunur; parent/path değişimi MINOR release ve release note ile yayımlanır. Analytics event'i slug + taxonomy version taşır.
- **Deprecate/merge:** Hard delete yapılmaz. `deprecated`, `effective_at`, `replaced_by_slug` ve gerekirse one-to-many manual review kaydı tutulur.
- **Backward compatibility:** Eski slug lookup ve replacement mapping kalıcıdır; mevcut ürünler kontrollü yeniden sınıflandırılana kadar çözümsüz bırakılmaz.
- **Alias management:** Alias ekleme/çıkarma owner'ı, gerekçesi ve ölçüm sinyali bulunur. Marka, typo listesi veya promotional copy alias registry'ye eklenmez. Zero-result ve yanlış tıklama verisiyle periyodik review yapılır.

### Hafif yönetim akışı

1. Tek bir taxonomy owner değişiklik talebini ve örnek SKU'ları kaydeder.
2. Search, merchant, analytics ve gerekiyorsa compliance etkisi kısa checklist ile değerlendirilir.
3. Product owner semantik değişiklikleri; compliance sahibi riskli domain değişikliklerini onaylar.
4. Sürüm, changelog ve replacement mapping yayımlanmadan değişiklik production'a alınmaz.

## RECOMMENDED OWNER DECISIONS

1. **Default: APPROVE** — Her canonical ürün tek primary assignable leaf'e bağlansın; brand, attribute, variant ve offer ayrı kalsın.
2. **Default: APPROVE** — L1 tablosundaki 17 `KEEP` kararı kabul edilsin.
3. **Default: SPLIT** — `Kitap & Kırtasiye`, sonraki taxonomy revizyonunda `Kitap` ve `Kırtasiye & Ofis` olarak ayrı değerlendirilsin.
4. **Default: SPLIT** — `Optik, Saat & Takı`, regüle `Optik` ile `Saat & Takı` olarak ayrı değerlendirilsin.
5. **Default: SPLIT** — `Çiçek, Bahçe & Hediyelik`, `Çiçek & Bahçe` ile `Hediyelik & Parti` olarak ayrı değerlendirilsin.
6. **Default: 8 HOME SHORTCUTS** — Home başlangıçta availability-gated 8 organik kategori kısayolu göstersin.
7. **Default: ALL CANONICAL** — `Tüm Kategoriler` canonical kapsamın tamamını availability durumuyla göstersin; boş kategoriye dead-end oluşturmasın.
8. **Default: SEPARATE SPONSORED** — Sponsorlu yerleşim canonical veya organik kategori sırasını değiştirmesin.
9. **Default: ACCEPT RECOMMENDATIONS** — 24 questionable-branch satırındaki agent recommendation'ları, belirtilen alternatif revizyonlar uygulanmadan önce tek tek veto edilebilir varsayılan set olarak kabul edilsin.
10. **Default: FAIL-CLOSED** — Riskli leaf, gerekli moderasyon policy'si ve sahibi yoksa inactive kalsın.
11. **Default: KEEP EXCLUSIONS** — İlaç, tütün/nikotin, alkol, silah/mühimmat/patlayıcı, yasa dışı madde, canlı hayvan ve dijital-only/hizmet domainleri V1 dışında kalsın.
12. **Default: DEFER SECOND-HAND** — İkinci el/yenilenmiş ürün V1'e alınmasın; gelecekte ayrı category değil `condition` attribute'u olarak ele alınsın.
13. **Default: SEPARATE SHOP TYPE** — Shop type taxonomy ayrı merchant-domain çalışması olsun; product L1'leri shop type olarak tekrar kullanılmasın.
14. **Default: APPROVE 8-LEAF PILOT** — Attribute registry kararı, tabloda önerilen 8 leaf ve gerçek SKU/merchant örnekleriyle pilotlansın.
15. **Default: APPROVE GOVERNANCE** — `v1.0.0` baseline, immutable slug, PATCH/MINOR/MAJOR değişiklik sınıfları ve kalıcı replacement mapping kabul edilsin.

Owner bu 15 kararı kabul ettiğinde bir sonraki çalışma taxonomy revizyon önerisini hazırlayabilir. Bu belge tek başına mevcut 648-node kaynağı, runtime'ı veya yayın politikasını değiştirmez.
