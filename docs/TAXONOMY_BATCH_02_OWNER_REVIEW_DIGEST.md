# Wave 15 Batch 02 — Product Owner Review Digest

## Status and use

**DECISION DIGEST — NO FINALIZATION**

- Source scope: 8 canonical L1, 77 proposed L2.
- All L2 lists remain `PROPOSED FOR OWNER REVIEW`.
- This document compresses existing proposals; it does not introduce a new taxonomy design.
- No L3/L4 tree, owner-final state, runtime node, policy implementation or data change is created.

Decision priority:

- **P0:** The answer can change an L2 node, L1 ownership or the taxonomy tree.
- **P1:** The answer primarily shapes later L3/L4 boundaries or assignment schema.
- **P2:** The answer is mainly policy, facet, synonym or operational validation.

Shared decisions use the same ID in every affected L1 and count once in the final totals.

## Ayakkabı

### Proposed L2

1. Günlük Ayakkabılar
2. Spor Ayakkabıları
3. Klasik Ayakkabılar
4. Bot & Çizmeler
5. Sandalet & Terlikler
6. Çocuk & Bebek Ayakkabıları
7. İş & Güvenlik Ayakkabıları
8. Ayakkabı Bakım & Aksesuarları

### Recommend

Sekiz L2'yi mevcut haliyle koru. Ayakta giyilen gerçek ürünün primary sahibi Ayakkabı olsun; spor, yaş ve kullanım alanı facet veya sonraki L3 ayrımı olsun. Güvenlik ayakkabısı da ürün kimliği nedeniyle burada kalsın, fakat sertifika/iddia politikası taxonomy'den ayrı yürüsün.

### Owner decisions required

#### SHOE-01 — P1

- **QUESTION:** Trekking ayakkabıları gelecekte nasıl ayrılmalı?
- **OPTION A:** `Spor Ayakkabıları` altında `Outdoor/Trekking Ayakkabıları` L3'ü aç.
- **OPTION B:** Yeni bir L2 oluştur.
- **OPTION C:** Yalnız kullanım facet'i kullan; alt kategori açma.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Ürün kimliği ayakkabıdır; outdoor niyeti bulunabilirlik için anlamlıdır fakat L2 düzeyinde yeni bölüm gerektirmez.
- **CROSS-DOMAIN EFFECT:** Spor & Outdoor yalnız ayakkabı olmayan ekipmanı tutar.
- **POLICY-SENSITIVE:** NO.

#### SHOE-02 — P0

- **QUESTION:** İş & Güvenlik Ayakkabıları Ayakkabı altında mı kalmalı?
- **OPTION A:** Ayakkabı altında ayrı L2 olarak tut.
- **OPTION B:** Yapı, Hırdavat & Tesisat'a taşı.
- **OPTION C:** Her iki alanda da göster, ancak tek primary leaf Ayakkabı olsun.
- **RECOMMENDED OPTION:** **A**; gerekirse Hırdavat keşfinde filtrelenmiş projection kullan.
- **WHY:** Çelik burun veya kaymazlık ayakkabının koruyucu özelliğidir; ürünün fiziksel kimliği değişmez.
- **CROSS-DOMAIN EFFECT:** Yapı, Hırdavat & Tesisat PPE ekipmanını tutar fakat aynı ayakkabıyı duplicate etmez.
- **POLICY-SENSITIVE:** YES — sertifika ve koruma iddiaları doğrulanmalı.

#### SHOE-03 — P2

- **QUESTION:** Konfor tabanlığı ile medikal ortez sınırı nasıl kurulmalı?
- **OPTION A:** Tedavi/rehabilitasyon iddiası yoksa Ayakkabı; varsa Sağlık & Medikal.
- **OPTION B:** Tüm tabanlıkları Ayakkabı'da tut.
- **OPTION C:** Tüm ortopedik isimli ürünleri Sağlık & Medikal'e taşı.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Ürün adı değil, kanıt gerektiren medikal iddia policy ve sahipliği değiştirmelidir.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal claim/evidence şeması gerekir; normal konfor aksesuarı burada kalır.
- **POLICY-SENSITIVE:** YES — `REGULATED` / `LEGAL_REVIEW_REQUIRED`.

### Low-risk decisions

- Günlük, spor, klasik, bot/çizme ve sandalet/terlik ayrımını kabul etmek.
- Numara, cinsiyet, marka, malzeme, renk ve sezonu facet olarak tutmak.
- Çocuk/bebek ayakkabısını Anne & Bebek'e taşımamak.
- Normal giyilebilir ayakkabı ile yalnız kostüm aksesuarını primary-function kuralıyla ayırmak.

### High-impact decisions

- `SHOE-01` ve `SHOE-02`.

### Policy-sensitive decisions

- `SHOE-02`: güvenlik sertifikası/iddiası.
- `SHOE-03`: medikal ortez ve tedavi iddiası.

## Çanta & Aksesuar

### Proposed L2

1. El, Omuz & Bel Çantaları
2. Sırt Çantaları
3. Evrak, Laptop & Ekipman Çantaları
4. Valiz & Seyahat Çantaları
5. Cüzdan, Kartlık & Anahtarlık
6. Kemer, Pantolon Askısı & Kravat
7. Şapka, Bere & Saç Aksesuarları
8. Atkı, Şal & Eldiven
9. Şemsiyeler
10. Seyahat Aksesuarları

### Recommend

On L2'yi koru. Bağımsız satılan taşıma ürününü, içinde taşınan cihazdan bağımsız olarak Çanta & Aksesuar'da tut. Yalnız taşıma işlevinden daha güçlü, ürüne entegre teknik/güvenlik sistemi varsa uzman L1'e geçişe izin ver.

### Owner decisions required

#### BAG-01 — P0 — shared with Anne & Bebek

- **QUESTION:** Bebek bakım çantası hangi L1'in primary ürünü olmalı?
- **OPTION A:** Çanta & Aksesuar; bebek kullanımı facet.
- **OPTION B:** Anne & Bebek; bakım işlevi primary.
- **OPTION C:** Bağımsız çanta A, bebek arabasına entegre bakım modülü B.
- **RECOMMENDED OPTION:** **C**; normal bağımsız bakım çantasının varsayılanı **A**.
- **WHY:** Ana ürün taşıma çantasıdır; ancak başka bir anne-bebek ürününün sabit/işlevsel modülü olduğunda schema değişir.
- **CROSS-DOMAIN EFFECT:** Anne & Bebek ile duplicate primary leaf oluşmasını engeller.
- **POLICY-SENSITIVE:** NO.

#### BAG-02 — P0 — shared with Müzik & Enstrüman

- **QUESTION:** Enstrüman, kamera ve benzeri ekipman çantaları genel taşıma alanında mı kalmalı?
- **OPTION A:** Tüm bağımsız taşıma çantalarını `Evrak, Laptop & Ekipman Çantaları` altında tut.
- **OPTION B:** Her çantayı taşıdığı cihazın L1'ine yönlendir.
- **OPTION C:** Bağımsız taşıma ürünü A; cihazla ayrılmaz/bundled koruma modülü ilgili uzman L1.
- **RECOMMENDED OPTION:** **C**; standalone enstrüman gig bag ve kamera çantasının varsayılanı **A**.
- **WHY:** Uyumluluk category değildir; buna karşılık ayrılmaz cihaz bileşeni farklı bir ürün sözleşmesi taşıyabilir.
- **CROSS-DOMAIN EFFECT:** Müzik & Enstrüman, Elektronik/Fotoğraf ve Bilgisayar & Tablet ile tek sahiplik sağlar.
- **POLICY-SENSITIVE:** NO.

#### BAG-03 — P0 — shared with Spor & Outdoor

- **QUESTION:** Teknik spor/hidrasyon/bisiklet çantasını Spor & Outdoor'a taşıyan eşik nedir?
- **OPTION A:** Tüm sırt ve taşıma çantaları Çanta & Aksesuar'da kalır.
- **OPTION B:** Spor adı taşıyan tüm çantalar Spor & Outdoor'a gider.
- **OPTION C:** Entegre hidrasyon, bisiklete sabitleme veya sport-specific güvenlik sistemi varsa Spor & Outdoor; genel taşıma ürünü burada.
- **RECOMMENDED OPTION:** **C**.
- **WHY:** Pazarlama etiketi değil, entegre teknik işlev primary sahipliği belirlemelidir.
- **CROSS-DOMAIN EFFECT:** Spor & Outdoor ile ürün duplicate edilmez; kullanım senaryosu tek başına kategori olmaz.
- **POLICY-SENSITIVE:** NO.

#### BAG-04 — P2

- **QUESTION:** Silah/av ekipmanı taşıma kılıfları V1'e alınmalı mı?
- **OPTION A:** V1'de tamamen dışla.
- **OPTION B:** Yalnız `LEGAL_REVIEW_REQUIRED` sonrası exact allowlist ile kabul et.
- **OPTION C:** Normal ekipman çantası olarak kabul et.
- **RECOMMENDED OPTION:** **A**; ileride ayrı owner/legal kararıyla B değerlendirilebilir.
- **WHY:** Normal çanta ağacı riskli ürüne dolaylı erişim kanalı olmamalıdır.
- **CROSS-DOMAIN EFFECT:** Spor & Outdoor avcılık matrisiyle aynı fail-closed politika gerekir.
- **POLICY-SENSITIVE:** YES — `EXCLUDED` önerisi.

### Low-risk decisions

- Şemsiye ile seyahat aksesuarını ayrı L2 tutmak.
- Marka, malzeme, cinsiyet sunumu, hacim ve cihaz uyumluluğunu facet yapmak.
- Laptop/kamera modeli uyumluluğunu yeni kategoriye dönüştürmemek.
- Akıllı takip özellikli valizi Elektronik'e taşımamak.

### High-impact decisions

- `BAG-01`, `BAG-02`, `BAG-03`.

### Policy-sensitive decisions

- `BAG-04`: silah/av ekipmanı taşıma ürünü.

## Beyaz Eşya & Ev Aletleri

### Proposed L2

1. Soğutma & Gıda Saklama Cihazları
2. Çamaşır & Bulaşık Bakım Cihazları
3. Büyük Pişirme Cihazları
4. Küçük Mutfak Aletleri
5. Temizlik Cihazları
6. İklimlendirme & Hava Kalitesi
7. Su Isıtma & Sıcak Su Cihazları
8. Ütü & Tekstil Bakım Cihazları
9. Elektrikli Kişisel Bakım Cihazları
10. Ev Aleti Aksesuar, Filtre & Sarf Malzemeleri

### Recommend

On L2'yi koru. Bitmiş cihazın yaptığı ev işi primary sahipliği belirlesin; “akıllı” bağlantı facet olarak kalsın. Kullanıcı tarafından değiştirilebilir cihaz aksesuarı bu alanda, profesyonel onarım parçası ilgili teknik L1'de yönetilsin.

### Owner decisions required

#### HOME-01 — P0

- **QUESTION:** Şofben/termosifon gibi sabit bağlantılı bitmiş cihazların sahibi kim olmalı?
- **OPTION A:** Beyaz Eşya & Ev Aletleri; tesisat parçaları Yapı, Hırdavat & Tesisat.
- **OPTION B:** Cihaz ve tesisatın tamamı Yapı, Hırdavat & Tesisat.
- **OPTION C:** Elektrikli bitmiş cihaz burada, gazlı/sabit sistem Hırdavat'ta.
- **RECOMMENDED OPTION:** **A**, kurulum/enerji türünü facet ve policy olarak tut.
- **WHY:** Satılan nesne bitmiş sıcak su cihazıdır; boru, vana ve montaj donanımı değildir.
- **CROSS-DOMAIN EFFECT:** Yapı, Hırdavat & Tesisat yalnız kurulum malzemesini tutar.
- **POLICY-SENSITIVE:** YES — gaz, elektrik ve yetkili kurulum uyarıları.

#### HOME-02 — P0

- **QUESTION:** Masaj, oral bakım ve benzeri kişisel cihazlarda Ev Aletleri–Spor–Sağlık sınırı nasıl kurulmalı?
- **OPTION A:** Günlük bakım/rahatlama burada; performans ürünü Spor; tedavi/rehabilitasyon iddiası Sağlık & Medikal.
- **OPTION B:** Tüm bu cihazları Sağlık & Medikal'e taşı.
- **OPTION C:** Tüm tüketici modellerini burada tut, iddiayı yalnız policy ile yönet.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Ana işlev ve claim/evidence birlikte daha tutarlı tek-primary-leaf üretir.
- **CROSS-DOMAIN EFFECT:** Spor & Outdoor ve Sağlık & Medikal attribute/claim profilleri etkilenir.
- **POLICY-SENSITIVE:** YES — medikal/terapötik iddialar.

#### HOME-03 — P1

- **QUESTION:** Kullanıcı aksesuarı ile profesyonel onarım parçası eşiği nedir?
- **OPTION A:** Kullanım kılavuzunda kullanıcı değişimli filtre/torba/aparat burada; iç onarım parçası teknik L1'de.
- **OPTION B:** Cihaza özgü tüm parçaları burada tut.
- **OPTION C:** Tüm parça ve sarfları teknik L1'lere taşı.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Son kullanıcı alışverişi ile servis/onarım parçası farklı şema ve risk taşır.
- **CROSS-DOMAIN EFFECT:** Elektronik Bileşenler ile Yapı, Hırdavat & Tesisat sınırını belirler.
- **POLICY-SENSITIVE:** NO.

### Low-risk decisions

- Robot süpürge, akıllı klima ve kahve makinesini ev işi nedeniyle burada tutmak.
- Ankastre/solo, enerji sınıfı, kapasite, bağlantı ve renk bilgisini facet yapmak.
- Elektriksiz mutfak gerecini Züccaciye & Mutfak'ta tutmak.
- Büyük/küçük ayrımını ek kategori yerine gezinme/facet düzeyinde bırakmak.

### High-impact decisions

- `HOME-01`, `HOME-02`, `HOME-03`.

### Policy-sensitive decisions

- `HOME-01`: sabit kurulum, gaz ve elektrik güvenliği.
- `HOME-02`: terapötik/medikal iddia.

## Anne & Bebek

### Proposed L2

1. Bebek Beslenme
2. Emzirme & Anne Sütü Ürünleri
3. Bebek Bezi & Alt Bakım
4. Bebek Banyo, Bakım & Hijyen
5. Bebek Arabaları & Taşıma
6. Oto Koltukları & Seyahat Güvenliği
7. Bebek Odası & Uyku
8. Bebek Güvenlik & Ev İçi Koruma
9. Hamilelik & Lohusalık Ürünleri

### Recommend

Dokuz L2'yi koru. Bebek mamasını beslenme niyeti nedeniyle burada primary sınıflandır, fakat Gıda & İçecek ile ortak regülasyon/attribute profili kullan. Giyim, ayakkabı, oyuncak, bağlı monitör ve medikal cihazı kendi L1'lerinde tut.

### Owner decisions required

#### MOTHER-01 — P0

- **QUESTION:** Bebek maması/formül hangi L1'in primary ürünü olmalı?
- **OPTION A:** Anne & Bebek → Bebek Beslenme; gıda/regülasyon profili ilişkilendir.
- **OPTION B:** Gıda & İçecek; yaş/bebek kullanımı facet.
- **OPTION C:** Formül A, normal bebek atıştırmalıkları B.
- **RECOMMENDED OPTION:** **A**, ürün tipine göre policy alt ayrımıyla.
- **WHY:** Müşteri niyeti ve beslenme şeması bebeğe özgüdür; mevzuat sahipliği taxonomy ownership ile karıştırılmamalıdır.
- **CROSS-DOMAIN EFFECT:** Gıda & İçecek attribute, içerik ve yasal kontrol profilinin yeniden kullanılması gerekir.
- **POLICY-SENSITIVE:** YES — `REGULATED` / `LEGAL_REVIEW_REQUIRED`.

#### BAG-01 — P0 — shared decision reference

- **QUESTION:** Bebek bakım çantası hangi L1'in primary ürünü olmalı?
- **OPTION A:** Çanta & Aksesuar.
- **OPTION B:** Anne & Bebek.
- **OPTION C:** Standalone çanta A; entegre bakım/taşıma modülü B.
- **RECOMMENDED OPTION:** **C**, standalone ürün için A.
- **WHY:** Ürün kimliği ile başka ürüne entegre işlev ayrılmalıdır.
- **CROSS-DOMAIN EFFECT:** Çanta & Aksesuar bölümündeki `BAG-01` ile aynıdır ve toplamda bir kez sayılır.
- **POLICY-SENSITIVE:** NO.

#### MOTHER-02 — P2

- **QUESTION:** Burun aspiratörü ve hamile destek ürününde normal bakım ile medikal ürün eşiği nedir?
- **OPTION A:** Tanı/tedavi/rehabilitasyon iddiası yoksa burada; varsa Sağlık & Medikal.
- **OPTION B:** Bu ürün ailelerinin tamamını Sağlık & Medikal'e taşı.
- **OPTION C:** Tamamını Anne & Bebek'te tut.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Claim/evidence ana işlevi değiştiren eşiktir; “anne/bebek” etiketi tek başına yeterli değildir.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal policy ve attribute profili gerekir.
- **POLICY-SENSITIVE:** YES.

#### MOTHER-03 — P2

- **QUESTION:** Kullanılmış oto koltuğu, uyku ve hijyen ürünleri için satış kuralı ne olmalı?
- **OPTION A:** Güvenlik/hijyen kritik exact ürünleri V1'de kullanılmış satışa kapat.
- **OPTION B:** Durum ve geçmiş kanıtıyla legal review sonrası kabul et.
- **OPTION C:** Normal ikinci-el ürün gibi kabul et.
- **RECOMMENDED OPTION:** **A**; gelecekte kanıtlı dar allowlist değerlendirilebilir.
- **WHY:** Kaza geçmişi, geri çağırma, hijyen ve görünmeyen hasar tüketici riskini artırır.
- **CROSS-DOMAIN EFFECT:** Condition facet'i ve platform-wide ikinci-el politika katmanı etkilenir.
- **POLICY-SENSITIVE:** YES — ürün güvenliği/hijyen.

### Low-risk decisions

- Emzirme ile genel bebek beslenmesini ayrı L2 tutmak.
- Oto koltuğunu Otomotiv yerine çocuk güvenliği sözleşmesiyle burada tutmak.
- Bebek monitörünü Elektronik → Akıllı Ev & Güvenlik'e yönlendirmek.
- Bebek giyimi, ayakkabısı ve oyuncaklarını kendi L1'lerinde tutmak.

### High-impact decisions

- `MOTHER-01` ve shared `BAG-01`.

### Policy-sensitive decisions

- `MOTHER-01`: bebek maması/formül.
- `MOTHER-02`: medikal claim sınırı.
- `MOTHER-03`: kullanılmış güvenlik ve hijyen ürünü.

## Oyuncak & Hobi

### Proposed L2

1. Bebek & Okul Öncesi Oyuncaklar
2. Eğitici, Bilim & Keşif Oyuncakları
3. Figür, Bebek & Rol Oyunları
4. Yapı & İnşa Oyuncakları
5. Oyuncak Araçlar & Uzaktan Kumandalı Oyuncaklar
6. Kutu Oyunları & Oyun Takımları
7. Puzzle & Zeka Oyunları
8. Model, Maket & Minyatür
9. Koleksiyon Ürünleri
10. Sanat, El İşi & Hobi Kitleri
11. Açık Hava & Aktivite Oyuncakları

### Recommend

On bir L2'yi koru. `Bebek & Okul Öncesi` dalını yaş facet'inin kontrollü istisnası kabul et; çünkü gelişim ve güvenlik şeması farklıdır. Gerçek cihaz, spor ekipmanı, enstrüman ve genel sanat sarfını oyuncak/hobi ağacına sızdırma.

### Owner decisions required

#### TOY-01 — P0

- **QUESTION:** `Bebek & Okul Öncesi Oyuncaklar` ayrı L2 olarak kalmalı mı?
- **OPTION A:** Ayrı L2 olarak koru.
- **OPTION B:** Ürün türlerine dağıt; yaş yalnız facet olsun.
- **OPTION C:** Yalnız bebek oyuncaklarını ayır, okul öncesini facet yap.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Gelişim seviyesi, küçük parça ve güvenlik profili sıradan yaş filtresinden daha güçlü ortak şema oluşturur.
- **CROSS-DOMAIN EFFECT:** Anne & Bebek bakım ürünlerinden açık ayrım korunur.
- **POLICY-SENSITIVE:** NO; güvenlik kuralları ayrıca zorunludur.

#### TOY-02 — P1

- **QUESTION:** Oynanabilir figür ile koleksiyon figürü nasıl ayrılmalı?
- **OPTION A:** Oynama amacı L2 3; sergileme/edinme amacı L2 9.
- **OPTION B:** Tüm figürleri tek dalda tut, koleksiyon durumunu facet yap.
- **OPTION C:** Yaş ve ambalaj durumuna göre ayır.
- **RECOMMENDED OPTION:** **A**, yaş/ambalajı tek başına belirleyici yapmadan intent/schema alanlarıyla.
- **WHY:** Play pattern ile koleksiyon/condition şeması farklıdır.
- **CROSS-DOMAIN EFFECT:** Saat & Takı'daki değerli koleksiyon nesneleri ve Hediyelik & Parti hatıraları duplicate edilmez.
- **POLICY-SENSITIVE:** NO.

#### TOY-03 — P2

- **QUESTION:** Airsoft/paintball ve gerçekçi silah-benzeri oyuncaklar V1'de ne olmalı?
- **OPTION A:** Tamamen `EXCLUDED`.
- **OPTION B:** `LEGAL_REVIEW_REQUIRED` ve exact allowlist.
- **OPTION C:** Yaş kısıtlı normal oyuncak.
- **RECOMMENDED OPTION:** **A**; sonraki hukuki kararda dar B değerlendirilebilir.
- **WHY:** Oyuncak görünümü güvenlik ve yasal riski ortadan kaldırmaz.
- **CROSS-DOMAIN EFFECT:** Spor & Outdoor riskli ürün matrisiyle uyum gerekir.
- **POLICY-SENSITIVE:** YES.

#### TOY-04 — P1

- **QUESTION:** Çocuk ürünü ne zaman oyuncak enstrüman yerine gerçek enstrümandır?
- **OPTION A:** Akort edilebilir, nota/performance amaçlı ürün Müzik & Enstrüman; rol oyuncağı burada.
- **OPTION B:** Çocuk hedefli tüm ürünleri Oyuncak & Hobi'de tut.
- **OPTION C:** Fiyat/yaşa göre ayır.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Ürünün yapabildiği iş yaş veya fiyat etiketinden daha güvenilir sınırdır.
- **CROSS-DOMAIN EFFECT:** Müzik & Enstrüman ile tek primary leaf sağlar.
- **POLICY-SENSITIVE:** NO.

#### TOY-05 — P2

- **QUESTION:** Rastgele içerikli koleksiyon kartı/paketlerinde ödül-kumar benzeri mekanik nasıl yönetilmeli?
- **OPTION A:** Policy review olmadan yayımlama.
- **OPTION B:** Normal koleksiyon ürünü kabul et.
- **OPTION C:** Tüm koleksiyon kartlarını dışla.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Fiziksel ürün kategorisi, satın alma mekaniğinin tüketici/çocuk riskini çözmez.
- **CROSS-DOMAIN EFFECT:** Platform-wide çocuk koruma ve promosyon politikası gerekir.
- **POLICY-SENSITIVE:** YES — owner/legal review.

### Low-risk decisions

- Kamera drone'unu Elektronik, oyuncak drone'u burada tutmak.
- Genel boya/kalemi Kırtasiye & Ofis, complete hobi kitini burada tutmak.
- Gerçek futbol topunu Spor & Outdoor, oyun ölçekli yumuşak topu burada tutmak.
- Marka, karakter, yaş, parça sayısı ve zorluğu facet yapmak.

### High-impact decisions

- `TOY-01`, `TOY-02`, `TOY-04`.

### Policy-sensitive decisions

- `TOY-03`: silah-benzeri ürünler.
- `TOY-05`: rastgele ödül/koleksiyon paketleri.

## Müzik & Enstrüman

### Proposed L2

1. Gitar & Bas
2. Piyano, Org & Klavyeli Çalgılar
3. Telli & Yaylı Çalgılar
4. Nefesli Çalgılar
5. Vurmalı Çalgılar
6. Geleneksel Türk Müziği Enstrümanları
7. Elektronik Müzik & DJ Ekipmanları
8. Stüdyo, Kayıt & Canlı Ses Ekipmanları
9. Enstrüman Amfi & Efektleri
10. Enstrüman Aksesuar, Bakım & Sarf Malzemeleri

### Recommend

On L2'yi koru ve `Geleneksel Türk Müziği Enstrümanları` dalını yerel keşif için kullan. Duplicate oluşmaması için owner-onaylı exact registry, yapısal telli/nefesli/vurmalı ailelerden öncelikli tek-primary-leaf kuralı taşısın.

### Owner decisions required

#### MUSIC-01 — P0

- **QUESTION:** `Geleneksel Türk Müziği Enstrümanları` ayrı L2 olarak kalmalı mı?
- **OPTION A:** Yerel keşif için ayrı L2 olarak koru.
- **OPTION B:** Enstrümanları telli/nefesli/vurmalı ailelere dağıt; geleneksel niteliği facet yap.
- **OPTION C:** Browse projection kullan, canonical primary leaf yapısal ailede kalsın.
- **RECOMMENDED OPTION:** **A**, exact registry şartıyla.
- **WHY:** Bağlama, ud, kanun, kemençe, ney ve zurna Türkiye'deki müşteri dilinde güçlü ortak raf oluşturur.
- **CROSS-DOMAIN EFFECT:** Music içindeki yapısal ailelerde duplicate assignment engellenmelidir.
- **POLICY-SENSITIVE:** NO.

#### MUSIC-02 — P1

- **QUESTION:** Ayrı L2 kabul edilirse traditional registry nasıl çalışmalı?
- **OPTION A:** Owner-approved exact isim listesi; listedeki ürün yalnız geleneksel L2'ye gider.
- **OPTION B:** Serbest metin/merchant seçimi.
- **OPTION C:** Bir ürün hem geleneksel hem yapısal leaf alabilir.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Deterministic registry, exactly-one primary leaf sözleşmesini korur.
- **CROSS-DOMAIN EFFECT:** Search synonymleri iki aileyi bulabilir; analytics yalnız tek canonical leaf kullanır.
- **POLICY-SENSITIVE:** NO.

#### MUSIC-03 — P1

- **QUESTION:** MIDI klavye ne zaman klavyeli çalgı, ne zaman elektronik müzik kontrolcüsüdür?
- **OPTION A:** Bağımsız ses/nota performansı varsa L2 2; salt kontrol yüzeyiyse L2 7.
- **OPTION B:** Tüm MIDI ürünlerini L2 7'ye koy.
- **OPTION C:** Tüm klavye formunu L2 2'ye koy.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Ana işlev, bağlantı tipinden daha güvenilir ürün sınırıdır.
- **CROSS-DOMAIN EFFECT:** Bilgisayar & Tablet'teki genel kontrol/çevre birimleriyle sızıntıyı engeller.
- **POLICY-SENSITIVE:** NO.

#### BAG-02 — P0 — shared decision reference

- **QUESTION:** Standalone enstrüman çantası Müzik & Enstrüman mı, Çanta & Aksesuar mı olmalı?
- **OPTION A:** Çanta & Aksesuar.
- **OPTION B:** Müzik & Enstrüman.
- **OPTION C:** Standalone çanta A; enstrümanla ayrılmaz/bundled modül B.
- **RECOMMENDED OPTION:** **C**, standalone gig bag için A.
- **WHY:** Uyumluluk category değildir; bağımsız çantanın primary işi taşımadır.
- **CROSS-DOMAIN EFFECT:** Çanta & Aksesuar bölümündeki `BAG-02` ile aynıdır ve toplamda bir kez sayılır.
- **POLICY-SENSITIVE:** NO.

#### MUSIC-04 — P2

- **QUESTION:** Korunan hayvan/bitki materyali iddialı enstrümanlar hangi policy ile yönetilmeli?
- **OPTION A:** Provenance/uygunluk kanıtı olmadan yayımlama; `LEGAL_REVIEW_REQUIRED`.
- **OPTION B:** Materyali yalnız facet kabul edip normal yayımla.
- **OPTION C:** Bu materyal iddialı tüm ürünleri kalıcı dışla.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Kategori normal olsa da materyal ticareti ve yanlış beyan ayrı risk taşır.
- **CROSS-DOMAIN EFFECT:** Platform-wide materyal provenance ve ilan kanıtı alanları gerekir.
- **POLICY-SENSITIVE:** YES.

### Low-risk decisions

- Genel tüketici kulaklık/hoparlörünü Elektronik'te tutmak.
- Kayıt amaçlı audio interface, stüdyo mikrofonu ve monitörü burada tutmak.
- Oyuncak enstrümanı primary-function kuralıyla Oyuncak & Hobi'ye yönlendirmek.
- Marka, seviye, bağlantı, sağ/sol el ve gövde malzemesini facet yapmak.

### High-impact decisions

- `MUSIC-01`, `MUSIC-02`, `MUSIC-03` ve shared `BAG-02`.

### Policy-sensitive decisions

- `MUSIC-04`: korunan materyal/provenance.

## Spor & Outdoor

### Proposed L2

1. Fitness & Kondisyon
2. Takım Sporları
3. Raket Sporları
4. Bireysel Sporlar & Jimnastik
5. Dövüş Sporları
6. Outdoor, Kamp & Trekking
7. Bisiklet
8. Su Sporları
9. Kış Sporları
10. Balıkçılık & Avcılık

### Recommend

İlk dokuz L2'yi koru. Onuncu L2'yi V1 için `Balıkçılık` adıyla sınırlandırmayı; avcılık ürünlerini taxonomy'ye eklemeden önce ayrı legal/owner allowlist kararı vermeyi öner. Bu değişiklik öneridir, finalizasyon değildir.

### Owner decisions required

#### SPORT-01 — P0

- **QUESTION:** V1 L2 adı `Balıkçılık & Avcılık` olarak kalmalı mı?
- **OPTION A:** Mevcut birleşik adı koru, avcılığı policy-gate et.
- **OPTION B:** V1'de yalnız `Balıkçılık`; avcılığı sonraki legal karar sonrasına ertele.
- **OPTION C:** Balıkçılık ve Avcılığı iki L2'ye ayır.
- **RECOMMENDED OPTION:** **B**.
- **WHY:** Bir kategori başlığı riskli ürünlerin normal katalog ürünü olduğu izlenimini vermemelidir; balıkçılık tek başına güçlü müşteri rafıdır.
- **CROSS-DOMAIN EFFECT:** Oyuncak silahlar, taşıma kılıfları ve Hırdavat'taki kesici/donanım sınırları daha güvenli kalır.
- **POLICY-SENSITIVE:** YES — V1 legal risk.

#### SPORT-02 — P2

- **QUESTION:** Airsoft/paintball, okçuluk, av bıçağı ve silah-benzeri ürün matrisi nasıl olmalı?
- **OPTION A:** Ateşli silah/mühimmat/patlayıcı `EXCLUDED`; diğer riskli aileler `LEGAL_REVIEW_REQUIRED` ve exact allowlist.
- **OPTION B:** Tümünü `EXCLUDED`.
- **OPTION C:** Yaş kısıtlı normal spor ürünü.
- **RECOMMENDED OPTION:** **A**, fakat legal review tamamlanana kadar fiilî sonuç fail-closed.
- **WHY:** Risk düzeyi ürün ailesine göre değişebilir; doğrulanmamış ürün normal yayınlanmamalıdır.
- **CROSS-DOMAIN EFFECT:** Oyuncak & Hobi `TOY-03` ve Çanta `BAG-04` kararlarıyla uyum gerekir.
- **POLICY-SENSITIVE:** YES.

#### SPORT-03 — P0

- **QUESTION:** E-bike ve e-scooter hangi L1'e ait olmalı?
- **OPTION A:** Spor & Outdoor → Bisiklet.
- **OPTION B:** Otomotiv & Motosiklet.
- **OPTION C:** Pedal-assist bisiklet A; throttle/araç niteliği baskın ürün B.
- **RECOMMENDED OPTION:** **C**, exact teknik ve yasal eşik owner/legal review ile tanımlanmalı.
- **WHY:** “Elektrikli” tek başına kategori değildir; araç formu ve kullanım sözleşmesi değişebilir.
- **CROSS-DOMAIN EFFECT:** Otomotiv fitment, güvenlik ve parça ağacı etkilenir.
- **POLICY-SENSITIVE:** NO; yasal eşik ayrıca doğrulanmalıdır.

#### BAG-03 — P0 — shared decision reference

- **QUESTION:** Hidrasyon/teknik bisiklet çantası hangi L1'e ait olmalı?
- **OPTION A:** Çanta & Aksesuar.
- **OPTION B:** Spor & Outdoor.
- **OPTION C:** Entegre teknik/sabitleme sistemi varsa B; genel taşıma çantası A.
- **RECOMMENDED OPTION:** **C**.
- **WHY:** Sportif pazarlama yerine teknik işlev primary sahipliği belirler.
- **CROSS-DOMAIN EFFECT:** Çanta & Aksesuar bölümündeki `BAG-03` ile aynıdır ve toplamda bir kez sayılır.
- **POLICY-SENSITIVE:** NO.

#### SPORT-04 — P2

- **QUESTION:** Spor koruması ile medikal ortez sınırı nedir?
- **OPTION A:** Darbe/performance koruması burada; tedavi/rehabilitasyon iddiası Sağlık & Medikal.
- **OPTION B:** Tüm dizlik/bileklikleri burada tut.
- **OPTION C:** Tüm destek ürünlerini Sağlık & Medikal'e taşı.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Claim/evidence, benzer fiziksel formdaki ürünlerin asıl farkıdır.
- **CROSS-DOMAIN EFFECT:** Sağlık & Medikal attribute ve policy profili gerekir.
- **POLICY-SENSITIVE:** YES.

### Low-risk decisions

- Spor ayakkabısı ve spor giyimini kendi L1'lerinde tutmak.
- Akıllı saati Elektronik → Giyilebilir Teknoloji'ye yönlendirmek.
- Oyuncak çadır/top ile gerçek ekipmanı primary-function kuralıyla ayırmak.
- Uzman kamp ocağını Outdoor, Kamp & Trekking altında tutmak.

### High-impact decisions

- `SPORT-01`, `SPORT-03` ve shared `BAG-03`.

### Policy-sensitive decisions

- `SPORT-01`: Avcılık L2 görünürlüğü.
- `SPORT-02`: silah/av/airsoft/okçuluk matrisi.
- `SPORT-04`: medikal claim sınırı.

## Hediyelik & Parti

### Proposed L2

1. Hatıra & Hediyelik Objeler
2. Hediye Paketleme & Sunum
3. Tebrik Kartları, Davetiyeler & Kutlama Yazıları
4. Balon & Balon Aksesuarları
5. Parti Süsleri & Mekân Dekorasyonu
6. Parti Sofrası & Servis Ürünleri
7. Kostüm, Maske & Parti Aksesuarları
8. Pasta Süsleme & Kutlama Aksesuarları
9. Parti Eğlence & Fotoğraf Aksesuarları

### Recommend

Dokuz L2'yi koru; “hediye”yi kategori değil kullanım amacı kabul et. `Hatıra & Hediyelik Objeler` yalnız asıl kimliği anma/hatıra olan fiziksel nesneleri kapsasın. Piroteknik ve basınçlı gaz ürünlerini V1 normal party kataloğuna alma.

### Owner decisions required

#### GIFT-01 — P1

- **QUESTION:** Bir ürünü `Hatıra & Hediyelik Objeler` L2'sine sokan intrinsic-keepsake kriteri nedir?
- **OPTION A:** Ürünün ana işlevi anma/hatıra/commemorative sunum ise burada; sıradan ürün kendi L1'inde.
- **OPTION B:** Hediye edilen veya kişiselleştirilen her ürün burada.
- **OPTION C:** Bu L2'yi kaldır; tüm ürünleri temel L1'e dağıt.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** “Hediye” kullanım amacı duplicate taxonomy üretmemelidir; hatıra plaketi gibi intrinsik nesneler yine bulunabilir olmalıdır.
- **CROSS-DOMAIN EFFECT:** Tüm 24 L1'de duplicate ürün riskini kontrol eder.
- **POLICY-SENSITIVE:** NO.

#### GIFT-02 — P2

- **QUESTION:** Kişiselleştirilmiş kupa, tişört veya takı primary kategorisini değiştirmeli mi?
- **OPTION A:** Temel ürün L1'inde kalır; kişiselleştirme facet/üretim capability'sidir.
- **OPTION B:** Hediyelik & Parti'ye taşınır.
- **OPTION C:** Yalnız sipariş üzerine üretimde Hediyelik & Parti'ye taşınır.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Baskı/yazı işlemi fiziksel ürünün ne olduğunu değiştirmez; hizmet sızıntısını da önler.
- **CROSS-DOMAIN EFFECT:** Züccaciye & Mutfak, Giyim & Moda ve Saat & Takı sahipliği korunur.
- **POLICY-SENSITIVE:** NO.

#### GIFT-03 — P1

- **QUESTION:** Parti sofrası ile genel Züccaciye sınırı nedir?
- **OPTION A:** Occasion-specific koordineli/tek kullanımlık set burada; genel yeniden kullanılabilir servis ürünü Züccaciye & Mutfak.
- **OPTION B:** Tüm sofra ürünleri Züccaciye & Mutfak.
- **OPTION C:** Parti temalı tüm sofra ürünleri burada, yeniden kullanılabilir olsa da.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Kutlama kiti ile genel ev sofrası farklı müşteri niyetidir; tema tek başına normal ürünü taşımamalıdır.
- **CROSS-DOMAIN EFFECT:** Züccaciye & Mutfak ile tek sahiplik sağlar.
- **POLICY-SENSITIVE:** NO.

#### GIFT-04 — P2

- **QUESTION:** Piroteknik ürünler ve helyum/basınçlı gaz V1'de nasıl yönetilmeli?
- **OPTION A:** Havai fişek, maytap ve tüm piroteknikler `EXCLUDED`; helyum/gaz tüpü normal party taxonomy'sinden dışarıda.
- **OPTION B:** Tamamı `LEGAL_REVIEW_REQUIRED` allowlist ile.
- **OPTION C:** Parti aksesuarı olarak normal kabul.
- **RECOMMENDED OPTION:** **A**.
- **WHY:** Patlayıcı, yanıcı ve basınçlı ürün riski normal kutlama ürünüyle aynı değildir.
- **CROSS-DOMAIN EFFECT:** Yapı, Hırdavat & Tesisat/industrial sahipliği ve platform-wide tehlikeli ürün politikası etkilenir.
- **POLICY-SENSITIVE:** YES — `EXCLUDED` önerisi.

### Low-risk decisions

- Hediye edilen kahve makinesi, oyuncak, kitap, takı veya gıdayı temel L1'inde tutmak.
- Pasta kalıbını Züccaciye & Mutfak; topper/mumu burada tutmak.
- Parti kutu oyununu Oyuncak & Hobi'de tutmak.
- Occasion, tema, alıcı ilişkisi, renk ve kişiselleştirilebilirliği facet yapmak.

### High-impact decisions

- `GIFT-01` ve `GIFT-03`.

### Policy-sensitive decisions

- `GIFT-04`: piroteknik ve basınçlı gaz.

## Final summary

### Counts

| Metric | Count |
|---|---:|
| Total L1 reviewed | 8 |
| Total proposed L2 | 77 |
| Unique owner decisions | 30 |
| P0 decisions | 11 |
| P1 decisions | 8 |
| P2 decisions | 11 |
| Policy-sensitive decisions | 15 |

Shared `BAG-01`, `BAG-02` and `BAG-03` entries appear in both affected L1 sections but are counted once. `11 + 8 + 11 = 30`.

### Proposals that can likely be approved as-is

The following L2 lists have a strong research-backed architecture and their remaining questions can mostly be resolved as boundary/policy rules without redesigning the list:

1. Ayakkabı
2. Çanta & Aksesuar
3. Beyaz Eşya & Ev Aletleri
4. Anne & Bebek
5. Hediyelik & Parti

“Likely” is not owner approval. All five remain `PROPOSED FOR OWNER REVIEW`.

### Proposals needing substantive owner review

1. **Oyuncak & Hobi:** `Bebek & Okul Öncesi` yaş-facet istisnası ve koleksiyon ayrımı.
2. **Müzik & Enstrüman:** Geleneksel Türk Müziği L2 carve-out'u ve exact registry.
3. **Spor & Outdoor:** `Balıkçılık & Avcılık` L2 adı/kapsamı ile riskli ürün matrisi.

### Fastest owner review order

1. P0: `MUSIC-01`, `SPORT-01`, `TOY-01` — L2 listesini doğrudan etkileyebilir.
2. P0: `BAG-01`, `BAG-02`, `BAG-03`, `HOME-01`, `HOME-02`, `MOTHER-01`, `SHOE-02`, `SPORT-03` — cross-L1 sahipliği kilitler.
3. P1: sonraki L3/L4 ve assignment schema kararları.
4. P2: policy/facet/operasyon kararları; riskli ürünler runtime öncesi ayrıca kapatılmalıdır.

## Digest validation

- Existing eight proposal lists reproduced exactly: **PASS**
- L1 count 8 / L2 count 77: **PASS**
- Unique decision IDs and shared-count rule: **PASS**
- Priority sum `P0 11 + P1 8 + P2 11 = 30`: **PASS**
- No owner decision silently finalized: **PASS**
- No new L3/L4 or runtime design: **PASS**
- Proposal documents modified: **NO**

`BATCH_02_OWNER_REVIEW_DIGEST: PASS`

`L1_REVIEWED: 8`

`OWNER_DECISION_COUNT: 30`

`P0_DECISIONS: 11`

`P1_DECISIONS: 8`

`P2_DECISIONS: 11`

`READY_FOR_FAST_OWNER_REVIEW: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
