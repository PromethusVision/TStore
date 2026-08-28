# EsnaftaVar Current Local Merchant Sector Research Inventory

**State:** RESEARCH INVENTORY — NO OWNER FINALIZATION

**Research date:** 2026-08-28

This inventory records current Turkish local-business terminology. A row is a
candidate signal, not automatically a canonical sector. Regulatory notes are
taxonomy-risk indicators, not legal advice or trading authorization.

## Sources and interpretation

- **TÜİK:** [NACE Rev.2.1 classification server](https://siniflama.tuik.gov.tr/Classifications/ClassificationsSatir?ad=Avrupa+Toplulu%C4%9Funda+Ekonomik+Faaliyetlerin+%C4%B0statistiki+S%C4%B1n%C4%B1flamas%C4%B1+%2C+NACE+Rev.2.1&surumId=1438). Formal economic-activity structure; not copied as UX.
- **TİCARET:** [20 May 2026 profession/NACE list](https://ticaret.gov.tr/esnaf-sanatkarlar/esnaf-ve-sanatkar-meslek-kollari/sektor-meslek-nace-listeleri/guncel-liste). Current Turkish official profession mapping.
- **TESK:** [Esnaf ve Sanatkâr Meslek Kolları](https://www.tesk.org.tr/resimler/915ced612016049.pdf) and [January 2026 statistics](https://www.tesk.org.tr/resimler/soneko/ayl%C4%B1kesnaf.pdf). Local profession vocabulary and scale: 184 professions and 2,542,099 workplaces as of 31 January 2026.
- **GBP:** [Google Business Profile category guidance](https://support.google.com/business/answer/7249669?hl=en) and [representation rules](https://support.google.com/business/answer/3038177?hl=en). Primary category plus few additional categories; describe what a business is, not everything it has.
- **GIDA:** [Ministry of Agriculture food-business registration/approval](https://www.tarimorman.gov.tr/Konular/Gida-Ve-Yem-Hizmetleri/Gida-Hizmetleri/Kayit-Onay). Retail, storage and production can carry registration/approval obligations.
- **OPTİK:** [Ministry of Health Opticianry Law](https://shgmsmdb.saglik.gov.tr/TR-102383/optisyenlik-hakkinda-kanun.html) and [Optical Establishments Regulation](https://www.saglik.gov.tr/TR%2C10467/optisyenlik-muesseseleri-hakkinda-yonetmelik.html).
- **MEDİKAL:** [Medical Device Sales, Advertising and Promotion Regulation amendment](https://resmigazete.gov.tr/eskiler/2023/05/20230526-9.htm). Device/sales-centre and registration duties vary by exact product.
- **KUYUM:** [Ministry of Trade jewellery commerce](https://ticaret.gov.tr/ic-ticaret/kuyum-ticareti). Jewellery commerce includes an authorization-certificate framework.
- **BİTKİ:** [Ministry of Agriculture plant-protection product portal](https://www.tarimorman.gov.tr/Konular/Bitki-Sagligi-Hizmetleri/Bitki-Koruma-Urunleri-Ve-Makinalari/Bitki-Koruma-Urunleri). Dealer authorization, traceability and exact merchant eligibility must fail closed.
- **HİJYEN:** [Hygiene Training Regulation](https://uzunkoprusm.saglik.gov.tr/TR-38602/hijyen-egitimi-yonetmeligi.html). Covers food retail and body-contact businesses including barbers, hairdressers and beauty salons.
- **PRODUCT:** EsnaftaVar owner-final 24 Product L1s, final Electronics/Computer L2s, 224 proposed L2s, and prior 46-archetype merchant-catalog audit.

Frequency is a qualitative acquisition/discovery signal (`HIGH`, `MEDIUM`,
`LOW`) rather than a statistical prevalence claim.

## Candidate inventory

| TERM | COMMON TURKISH USAGE | FORMAL / INDUSTRY TERM | TYPICAL PRODUCTS | TYPICAL SERVICES | REGULATORY SIGNAL | LOCAL RETAIL FREQUENCY | POSSIBLE PARENT | OVERLAP | SOURCE NOTES |
|---|---|---|---|---|---|:---:|---|---|---|
| Market, Bakkal & Süpermarket | market, bakkal | Belirli bir mala tahsis edilmemiş gıda ağırlıklı perakende | Gıda; içecek; hijyen; temizlik; kırtasiye; pet ürünü | Paketleme/teslimat olabilir | Food registration; exact goods policy separate | HIGH | Gıda & Günlük Tüketim | Şarküteri; fırın; kuruyemiş | TÜİK, TİCARET, GBP, GIDA, PRODUCT |
| Kasap | kasap | Et ve et ürünleri perakendesi/işleme | Kırmızı et; kanatlı; hazırlanmış et | Kesim/hazırlama | Food approval/registration and hygiene signal | HIGH | Gıda & Günlük Tüketim | Şarküteri | TESK, GIDA, PRODUCT |
| Şarküteri | şarküteri | İşlenmiş et ve kahvaltılık ürün perakendesi | Sucuk; salam; peynir; zeytin | Dilimleme/paketleme | Food registration/cold-chain signal | HIGH | Gıda & Günlük Tüketim | Kasap; market | TESK, GIDA, PRODUCT |
| Manav | manav | Meyve ve sebze perakendesi | Taze meyve/sebze; ot | Ayıklama/paketleme | Food traceability/registration signal | HIGH | Gıda & Günlük Tüketim | Market; bahçe/canlı bitki | TESK, GIDA, PRODUCT |
| Fırın | fırın | Ekmek ve unlu mamul üretim/perakendesi | Ekmek; simit; pide; unlu mamul | Yerinde üretim | Food registration; premises licence evidence | HIGH | Gıda & Günlük Tüketim | Pastane | TİCARET, GIDA, PRODUCT |
| Pastane & Tatlıcı | pastane, tatlıcı | Pastacılık/tatlı üretim ve satış | Pasta; tatlı; börek; unlu mamul | Siparişe hazırlama | Food registration/hygiene; service boundary | HIGH | Gıda & Günlük Tüketim | Fırın; organizasyon service | TÜİK special-case note, GIDA, PRODUCT |
| Kuruyemişçi | kuruyemişçi | Kuruyemiş ve atıştırmalık perakendesi | Kuruyemiş; kuru meyve; lokum | Kavurma/paketleme olabilir | Food registration/label signal | HIGH | Gıda & Günlük Tüketim | Aktar; market | TESK, GIDA, PRODUCT |
| Aktar | aktar, baharatçı | Baharat/bitkisel ürün perakendesi | Baharat; bitki çayı; doğal bakım ürünleri | Karışım/paketleme olabilir | Ingestible/claim/product-status review | MEDIUM | Gıda & Günlük Tüketim | Kuruyemiş; kozmetik; medikal | TESK, GIDA, PRODUCT |
| İçecek & Su Bayii | sucu, içecek bayii | Alkolsüz içecek/su perakendesi | Su; alkolsüz içecek | Damacana teslimatı | Food registration; alcohol excluded from inference | MEDIUM | Gıda & Günlük Tüketim | Market | TİCARET, GIDA, PRODUCT |
| Giyim Mağazası | butik, giyimci, konfeksiyon | Giyim perakendesi | Üst/alt/dış/ev giyimi | Tadilat olabilir | Normal; textile labeling still applies | HIGH | Giyim, Ayakkabı & Aksesuar | Terzi; çanta; ayakkabı | TESK, PRODUCT |
| Ayakkabı Mağazası | ayakkabıcı | Ayakkabı perakendesi | Günlük; spor; klasik ayakkabı | Küçük bakım olabilir | PPE/medical claims separate | HIGH | Giyim, Ayakkabı & Aksesuar | Ayakkabı tamircisi; spor | TESK, PRODUCT |
| Çanta & Aksesuar Mağazası | çantacı, aksesuarcı | Çanta, valiz ve moda aksesuarı perakendesi | Çanta; valiz; cüzdan; kemer | Basit bakım olabilir | Normal; protected material review possible | HIGH | Giyim, Ayakkabı & Aksesuar | Bijuteri; giyim | TESK, PRODUCT |
| İç Giyim Mağazası | iç giyimci | İç giyim perakendesi | İç giyim; çorap; ev giyimi | Yok/az | Normal | MEDIUM | Giyim, Ayakkabı & Aksesuar | Genel giyim | TESK, PRODUCT |
| Telefoncu & GSM Mağazası | telefoncu, cep telefoncu, GSM mağazası | İletişim cihazı ve aksesuarı perakendesi | Telefon; kılıf; şarj; kulaklık; smartwatch | Kurulum/veri aktarımı; bazen onarım | IMEI/second-hand/repair and product policy may apply | HIGH | Teknoloji & Elektronik | Teknik servis; elektronik; bilgisayar | TESK, PRODUCT |
| Elektronik Mağazası | elektronikçi | Tüketici elektroniği perakendesi | TV; ses; kamera; akıllı ev; bağlantı | Kurulum olabilir | Electrical conformity; installation separate | HIGH | Teknoloji & Elektronik | Telefoncu; beyaz eşya | TÜİK, TESK, PRODUCT |
| Bilgisayarcı | bilgisayarcı | Bilgisayar ve çevre birimi perakendesi | PC; tablet; bileşen; depolama; ağ | Kurulum/toplama; bazen onarım | Data/repair and electrical policy | HIGH | Teknoloji & Elektronik | Telefoncu; teknik servis | TESK, PRODUCT |
| Beyaz Eşya & Ev Aletleri Mağazası | beyaz eşyacı | Ev cihazları perakendesi | Büyük/küçük ev aleti | Teslimat/kurulum coordination | Electrical/gas/installation evidence | HIGH | Teknoloji & Elektronik | Elektronik; teknik servis | TÜİK, PRODUCT |
| Mobilya Mağazası | mobilyacı | Mobilya perakendesi/imalatı | Oturma; yatak; masa; dolap | Ölçü/kurulum olabilir | Custom manufacture/install boundary | HIGH | Ev, Mutfak & Mobilya | Yapı; marangoz service | TESK, PRODUCT |
| Ev Tekstili Mağazası | ev tekstilci | Ev tekstili perakendesi | Nevresim; havlu; örtü | Ölçü/dikim olabilir | Normal | HIGH | Ev, Mutfak & Mobilya | Perdeci; halı | TESK, PRODUCT |
| Züccaciye & Mutfak Gereçleri Mağazası | züccaciye | Ev/mutfak gereçleri perakendesi | Tencere; sofra; bardak; saklama | Yok/az | Food-contact/electrical product evidence | HIGH | Ev, Mutfak & Mobilya | Küçük ev aleti; hediyelik | TESK, PRODUCT |
| Halı & Kilim Mağazası | halıcı | Halı/kilim perakendesi | Halı; kilim; paspas | Ölçü/serim olabilir | Normal | MEDIUM | Ev, Mutfak & Mobilya | Ev tekstili | TESK, PRODUCT |
| Perdeci | perdeci | Perde ve pencere tekstili perakendesi/imalatı | Perde; stor; aksesuar | Ölçü, dikim, montaj | Mixed custom-service signal | HIGH | Ev, Mutfak & Mobilya | Ev tekstili; yapı | TESK, PRODUCT |
| Nalbur & Hırdavatçı | nalbur, hırdavatçı | Hırdavat/nalburiye perakendesi | Alet; bağlantı; kilit; boya; tesisat | Anahtar kesim/ufak hizmet olabilir | Chemicals/electrical/PPE policy | HIGH | Yapı, Hırdavat & Tesisat | Elektrik; tesisat; boya; bahçe | TESK, PRODUCT |
| Yapı Malzemeleri Satıcısı | yapı market, yapı malzemecisi | İnşaat/yapı malzemesi perakendesi | Yapı malzemesi; kaplama; izolasyon | Sevkiyat; project service separate | Installer-only/high-risk goods review | HIGH | Yapı, Hırdavat & Tesisat | Nalbur; tesisat | TİCARET, PRODUCT |
| Elektrik Malzemeleri Satıcısı | elektrikçi, elektrik malzemecisi | Elektrik tesisatı malzemesi perakendesi | Kablo; sigorta; priz; ölçüm | Kurulum may be separate business | Electrical safety/licensed service boundary | HIGH | Yapı, Hırdavat & Tesisat | Elektronik; teknik servis | TESK, PRODUCT |
| Tesisat Malzemeleri Satıcısı | tesisatçı dükkânı, tesisat malzemecisi | Sıhhi tesisat/armatür perakendesi | Boru; vana; armatür; ısıtma parçaları | Kurulum sometimes | Gas/water/install policy | HIGH | Yapı, Hırdavat & Tesisat | Yapı; banyo accessory | TESK, PRODUCT |
| Boya & Dekorasyon Malzemeleri Satıcısı | boyacı, boya bayii | Boya/kaplama perakendesi | Boya; fırça; yüzey hazırlama | Renk karıştırma | Chemical labeling/storage | MEDIUM | Yapı, Hırdavat & Tesisat | Nalbur; ev dekor | TESK, PRODUCT |
| Oto Yedek Parçacı | oto parçacı | Motorlu araç parça perakendesi | Mekanik/elektrik yedek parça | Parça tespiti | Fitment/safety/second-hand policy | HIGH | Otomotiv, Motosiklet & Mobilite | Oto aksesuar; servis | TESK, PRODUCT |
| Oto Aksesuar Mağazası | oto aksesuarcı | Araç aksesuarı perakendesi | İç/dış aksesuar; elektronik; bakım | Montaj olabilir | Fitment/electrical/chemical policy | HIGH | Otomotiv, Motosiklet & Mobilite | Elektronik; yedek parça | TESK, PRODUCT |
| Lastikçi | lastikçi | Lastik/jant perakende ve servis | Lastik; jant; valf | Sökme-takma; balans; repair | Safety/product-service evidence | HIGH | Otomotiv, Motosiklet & Mobilite | Oto parça; vehicle service | TESK, PRODUCT |
| Motosiklet Mağazası | motosikletçi | Motosiklet ve ekipman perakendesi | Motosiklet; kask; koruma; aksesuar | Teslim/kurulum; service may coexist | Vehicle/registration/safety | MEDIUM | Otomotiv, Motosiklet & Mobilite | Motosiklet parça/servis | TESK, PRODUCT |
| Motosiklet Yedek Parça & Aksesuar Mağazası | motosiklet parçacı | Motosiklet parça/aksesuar perakendesi | Parça; aksesuar; elektronik | Montaj olabilir | Fitment/safety | MEDIUM | Otomotiv, Motosiklet & Mobilite | Motosiklet mağazası | TESK, PRODUCT |
| Bisiklet Mağazası | bisikletçi | Bisiklet ve parça perakendesi | Bisiklet; parça; aksesuar | Ayar/onarım often | Product safety; service separation | HIGH | Otomotiv, Motosiklet & Mobilite | Spor; bisiklet servisi | TESK, PRODUCT |
| Kozmetik & Kişisel Bakım Mağazası | kozmetikçi | Kozmetik ve bakım perakendesi | Makyaj; cilt; saç; hijyen | Danışmanlık may occur | Claims/ingredients/product status | HIGH | Kozmetik, Bakım & Güzellik | Parfümeri; güzellik salonu | TESK, PRODUCT |
| Parfümeri | parfümeri | Parfüm/kozmetik perakendesi | Parfüm; deodorant; bakım | Yok/az | Authenticity/claims | MEDIUM | Kozmetik, Bakım & Güzellik | Kozmetik mağazası | TESK, PRODUCT |
| Berber, Kuaför & Güzellik Salonu | common umbrella | Berber, kuaför ve kişisel bakım meslek kolu | Limited retail cosmetics possible | Personal-care services | Hygiene; exact service scope may vary | HIGH | Kozmetik, Bakım & Güzellik (placement proposed) | Children are owner-confirmed | TESK, HİJYEN, OWNER FINAL |
| Erkek Berberi | berber, erkek kuaförü | Erkek berber ve kuaför işletmeciliği | Grooming products incidental | Hair/beard grooming | Hygiene | HIGH | Confirmed beauty subtree | Kadın Kuaförü | TESK, HİJYEN, OWNER FINAL |
| Kadın Kuaförü | kadın kuaförü | Kadın kuaför işletmeciliği | Hair products incidental | Hair care/styling | Hygiene | HIGH | Confirmed beauty subtree | Erkek Berberi; salon | TESK, HİJYEN, OWNER FINAL |
| Güzellik Salonu | güzellik salonu | Güzellik salonları işletmeciliği | Cosmetics incidental | Beauty/personal-care services | Hygiene; treatment boundary review | HIGH | Confirmed beauty subtree | Medikal/health service claims | TESK, HİJYEN, OWNER FINAL |
| Anne & Bebek Mağazası | bebe mağazası, anne-bebek | Baby/maternity specialty retail | Feeding; care; travel; clothing; toys | Product guidance | Baby safety/food/product policy | HIGH | Anne, Bebek, Oyuncak & Hobi | Giyim; toy; food | TESK, PRODUCT |
| Oyuncakçı | oyuncakçı | Toy retail | Toy; games; puzzles | Yok/az | Age/product safety | HIGH | Anne, Bebek, Oyuncak & Hobi | Hobi; kitap; kırtasiye | TESK, PRODUCT |
| Hobi & El Sanatları Mağazası | hobi mağazası, el işi dükkânı | Hobby/craft material retail | Kits; model; craft; art supplies | Workshop may be separate | Chemical/tool/age policy | MEDIUM | Anne, Bebek, Oyuncak & Hobi | Kırtasiye; music | TESK, PRODUCT |
| Müzik & Enstrüman Mağazası | müzik mağazası, enstrümancı | Musical instrument/equipment retail | Instrument; amplifier; accessory | Repair/course may coexist | Protected material and service boundary | MEDIUM | Anne, Bebek, Oyuncak & Hobi | Electronics; technical service | TESK, PRODUCT |
| Kitapçı | kitapçı, kitabevi | Book retail | Physical books | Order/reservation not booking engine | Copyright/content policy | HIGH | Kitap, Kırtasiye & Ofis | Kırtasiye; toy | TESK, PRODUCT |
| Kırtasiye | kırtasiyeci | Stationery retail | Pen; notebook; art; school supply | Copy/print may coexist | Cutter/chemical and service boundary | HIGH | Kitap, Kırtasiye & Ofis | Kitap; toy; office | TESK, PRODUCT |
| Ofis Malzemeleri Mağazası | ofis malzemecisi | Office equipment/supply retail | Filing; desk; paper; machine | Setup/delivery may occur | Toner/printer product boundary | MEDIUM | Kitap, Kırtasiye & Ofis | Kırtasiye; computer | TESK, PRODUCT |
| Spor Malzemeleri Mağazası | spor mağazası | Sports-goods retail | Fitness; team; racket equipment | Setup may occur | PPE/restricted goods | HIGH | Spor & Outdoor | Clothing; shoes | TESK, PRODUCT |
| Outdoor & Kamp Mağazası | outdoor, kampçı | Outdoor/camping goods retail | Tent; sleep; technical gear | Rental may be separate | Safety/fuel/knife policy | MEDIUM | Spor & Outdoor | Hardware; bags | TESK, PRODUCT |
| Balıkçılık & Av Malzemeleri Mağazası | balıkçı malzemecisi, av bayii | Fishing/hunting equipment retail | Fishing tackle; outdoor gear | Repair/advice | Weapon-like/restricted goods legal review | MEDIUM | Spor & Outdoor | Outdoor; hardware | TESK, PRODUCT |
| Pet Shop | pet shop, evcil hayvan mağazası | Pet supplies retail | Food; habitat; hygiene; accessory | Guidance | Live animal/veterinary/product policy | HIGH | Evcil Hayvan | Akvaryumcu; pet kuaförü | TESK, PRODUCT |
| Akvaryumcu | akvaryumcu | Aquarium/fish supplies retail | Aquarium; feed; pump; decor | Setup/maintenance may coexist | Live-animal and electrical policy | MEDIUM | Evcil Hayvan | Pet shop; technical service | TESK, PRODUCT |
| Pet Kuaförü | pet kuaförü | Companion-animal grooming service | Grooming supplies incidental | Grooming | Animal welfare/hygiene review | MEDIUM | Evcil Hayvan | Pet shop; veterinary service excluded | TESK, PRODUCT |
| Optik Mağazası | optikçi | Optisyenlik müessesesi | Frame; lens; sunglasses; contact lens | Measurement/fitting within lawful scope | Explicit regulated establishment signal | HIGH | Optik, Saat, Takı & Medikal | Health; sport/PPE eyewear | OPTİK, PRODUCT |
| Kuyumcu | kuyumcu | Kuyum işletmesi | Precious jewellery; finished goods | Repair/personalization may coexist | Authorization certificate; high-value controls | HIGH | Optik, Saat, Takı & Medikal | Saatçi; bijuteri | KUYUM, PRODUCT |
| Saatçi | saatçi | Watch retail/repair | Classic watch; strap; accessory | Watch repair | High-value/authenticity; smart watches excluded | HIGH | Optik, Saat, Takı & Medikal | Kuyumcu; electronics | TESK, PRODUCT |
| Medikal Ürün Mağazası | medikalci | Tıbbi cihaz satış merkezi / health goods retail | Measurement; orthopaedic; mobility; care | Fitting/guidance may occur | Device/sales-centre verification by exact scope | HIGH | Optik, Saat, Takı & Medikal | Optik; pharmacy excluded | MEDİKAL, PRODUCT |
| Çiçekçi | çiçekçi | Cut flower/arrangement retail | Cut flower; arrangement; plant; pot | Arrangement/delivery | Live plant/fulfilment; service boundary | HIGH | Çiçek, Bahçe, Hediyelik & Parti | Gift shop; garden | TESK, PRODUCT |
| Bahçe & Yetiştirme Ürünleri Mağazası | bahçe malzemecisi, fideci | Garden/growing supply retail | Plant; seed; soil; irrigation; tool | Guidance | Plant protection products require separate authorization | MEDIUM | Çiçek, Bahçe, Hediyelik & Parti | Hardware; flower | BİTKİ, PRODUCT |
| Hediyelik Eşya Mağazası | hediyelikçi | Gift/souvenir retail | Souvenir; gift supply; cross-domain goods | Personalization may occur | Underlying product policies remain | HIGH | Çiçek, Bahçe, Hediyelik & Parti | Flowers; jewellery; home | TESK, PRODUCT |
| Parti Malzemeleri Mağazası | parti malzemecisi | Celebration supply retail | Balloon; decor; tableware; costume | Balloon filling may occur | Pyrotechnics/pressurized gas excluded/review | MEDIUM | Çiçek, Bahçe, Hediyelik & Parti | Toy; stationery; gift | TESK, PRODUCT |
| Telefon & Elektronik Teknik Servisi | telefon tamircisi, elektronik servis | Communication/consumer-electronics repair | Replacement parts incidental | Diagnosis/repair | Data privacy, warranty, authorized-service claims | HIGH | Tamir, Bakım & Yerel Hizmetler | Telefoncu; electronics retail | TÜİK, TESK |
| Bilgisayar Teknik Servisi | bilgisayar servisi | Computer repair/maintenance | Parts incidental | Diagnosis, repair, setup | Data privacy and authorized-service claims | HIGH | Tamir, Bakım & Yerel Hizmetler | Bilgisayarcı | TÜİK, TESK |
| Beyaz Eşya Teknik Servisi | beyaz eşya servisi | Household-appliance repair | Parts incidental | Repair/maintenance | Electrical/gas and authorization claims | HIGH | Tamir, Bakım & Yerel Hizmetler | Appliance retail | TÜİK, TESK |
| Terzi & Giyim Tadilatı | terzi | Clothing manufacture/alteration | Fabric/notions incidental | Tailoring/alteration | Normal workplace obligations | HIGH | Tamir, Bakım & Yerel Hizmetler | Giyim retail | TESK |
| Ayakkabı Tamircisi | kundura tamircisi, ayakkabı tamircisi | Footwear/leather repair | Care parts incidental | Repair | Normal workplace obligations | HIGH | Tamir, Bakım & Yerel Hizmetler | Ayakkabı retail | TÜİK, TESK |
| Anahtarcı | anahtarcı, çilingir | Key cutting/lock service | Keys/locks incidental | Key cutting; locksmith work | Security/service-scope review | HIGH | Tamir, Bakım & Yerel Hizmetler | Nalbur; emergency mobile service | TESK |
| Kuru Temizleme & Çamaşırhane | kuru temizlemeci, çamaşırhane | Textile cleaning service | Care products incidental | Cleaning/pressing | Chemical/hygiene/workplace signal | HIGH | Tamir, Bakım & Yerel Hizmetler | Home cleaning products | TÜİK, TESK |
| Bisiklet Servisi | bisiklet tamircisi | Bicycle repair/maintenance | Parts incidental | Repair/adjustment | Product safety/service evidence | MEDIUM | Tamir, Bakım & Yerel Hizmetler | Bisiklet retail | TÜİK, TESK |

## Research conclusions

1. Formal activity codes are substantially more detailed than a sensible customer
   onboarding tree. They should be linked as verification evidence, not exposed as
   navigation labels.
2. The strongest local identities are storefront nouns: `bakkal`, `kasap`,
   `manav`, `telefoncu`, `bilgisayarcı`, `nalbur`, `kırtasiye`, `pet shop`,
   `optikçi`, `kuyumcu` and `çiçekçi`.
3. Product/service mixtures are normal. The taxonomy needs an operating-model
   dimension and primary/secondary sectors rather than duplicated hybrid nodes.
4. Optik, medikal, kuyum, food handling and plant-protection-adjacent businesses
   require policy metadata. A sector label cannot prove eligibility.
5. The owner-confirmed beauty subtree exactly matches both local language and TESK's
   separated profession signals. Its wider parent placement remains proposed.

`RESEARCH_INVENTORY_STATUS: COMPLETE_FOR_PROPOSAL`
