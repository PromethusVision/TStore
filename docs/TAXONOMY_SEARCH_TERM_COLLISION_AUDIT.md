# EsnaftaVar Search Term Collision Audit

**State:** `PROVISIONAL SEARCH AUDIT — NO RUNTIME RULES`
**Vocabulary:** `1,220` controlled expressions / `244` L2 targets
**Collision rows:** `40`

## Reading rule

A collision does not justify duplicating a product across categories or globally
pinning a term to the most common meaning. Longer phrase, canonical category,
product title, typed facet, compatibility target and customer clarification resolve
intent. Policy gates still apply after semantic resolution.

| ID | TERM | MEANING A | MEANING B | AFFECTED DOMAINS | DISAMBIGUATION SIGNAL | CATEGORY CONTEXT | FACET CONTEXT | USER QUERY STRATEGY | SEVERITY |
|---|---|---|---|---|---|---|---|---|---|
| SC-001 | mouse | computer pointing device | English animal word | Bilgisayar & Tablet / Evcil Hayvan | `wireless`, `gaming`, `kedi`, `kemirgen` | peripheral vs pet products | connection/DPI vs species | Prefer computer for product phrases; show pet cluster only with animal context. | MEDIUM |
| SC-002 | fare | Turkish animal | colloquial computer mouse | Evcil Hayvan / Bilgisayar & Tablet | `kapan`, `kemirgen`, `kablosuz`, `PC` | pet/pest product vs peripheral | species vs connection/DPI | Split result clusters on bare query; phrase match wins. | HIGH |
| SC-003 | ped | hygiene pad | cycling/pet/medical pad | Kozmetik / Anne & Bebek / Spor / Sağlık / Pet | `hijyen`, `lohusa`, `bisiklet`, `yatak` | product form plus domain | absorbency/body area vs sport/animal use | Never map bare term directly; ask/filter by use. | HIGH |
| SC-004 | lens | contact lens | camera lens | Gözlük & Optik / Elektronik | `kontakt`, `göz`, `kamera`, focal length | optics vs photo | prescription/base curve vs mount/focal length | Long phrase and facet units resolve; show both on bare term. | CRITICAL |
| SC-005 | kasa | computer chassis/system | box/cabinet/body shell | Bilgisayar / Ev & Yaşam / Otomotiv | `PC`, `hazır sistem`, `dolap`, `araç` | component/system/furniture/vehicle | form factor vs dimensions/fitment | Require adjacent product token; do not equate `kasa bilgisayar` and `bilgisayar kasası`. | HIGH |
| SC-006 | fan | computer cooling fan | household/vehicle ventilation fan | Bilgisayar / Beyaz Eşya / Otomotiv | `120 mm`, `kasa`, `vantilatör`, `radyatör` | component vs appliance/part | connector/RPM vs size/vehicle fit | Units and compatible target dominate. | HIGH |
| SC-007 | kart | electronics/PC card | stationery/gift/game card | Elektronik / Bilgisayar / Kırtasiye / Hediyelik / Oyuncak | `ekran`, `geliştirme`, `tebrik`, `oyun` | multiple product families | interface vs paper/occasion/player count | Exact phrase only; bare `kart` returns grouped intents. | HIGH |
| SC-008 | filtre | appliance replacement | vehicle/aquarium/medical filter | Beyaz Eşya / Otomotiv / Pet / Sağlık | target model, `hava`, `yağ`, `akvaryum`, `solunum` | accessory/sarf ownership | model/vehicle/device compatibility | Compatibility target is mandatory for exact fit claims. | CRITICAL |
| SC-009 | adaptör | electrical power adapter | interface/mechanical adapter | Elektronik / Bilgisayar / Müzik / Yapı | watts/voltage vs connector/thread/mount | power vs connection/accessory | electrical profile vs interface | Classify by function and units; bare term stays multi-intent. | HIGH |
| SC-010 | modül | electronic board/module | phone spare module or furniture module | Elektronik / Telefon / Ev & Yaşam | `sensör`, `ekran`, `kamera`, `dolap` | component/spare/furniture | interface/part model vs dimensions | Require product noun and domain context. | HIGH |
| SC-011 | yağ | edible oil | vehicle oil or cosmetic oil | Gıda / Otomotiv / Kozmetik | `zeytin`, `motor`, `saç`, `cilt` | three distinct primary owners | ingredient vs SAE approval vs body area | Bare query shows clusters; policy/ingestion rules remain separate. | HIGH |
| SC-012 | krem | cosmetic cream | food cream or medical-claim product | Kozmetik / Gıda / Sağlık | `yüz`, `şanti`, `tedavi`, ingredient | function/intended use | skin type vs ingredient vs medical claim | Medical wording invokes fail-closed review, not search promotion. | CRITICAL |
| SC-013 | pedal | instrument effect pedal | bicycle/vehicle pedal | Müzik / Spor / Otomotiv | `gitar`, `efekt`, `bisiklet`, `fren` | equipment ownership | interface vs fitment | Phrase and compatible target resolve. | HIGH |
| SC-014 | çerçeve | optical frame | picture/frame or bicycle frame | Optik / Ev & Yaşam / Spor | `gözlük`, `tablo`, `bisiklet` | product type differs | optical dimensions vs material/size | Bare result grouped; no shared canonical node. | HIGH |
| SC-015 | stand | phone stand | jewelry/display/music stand | Elektronik / Saat & Takı / Müzik / Ev | `telefon`, `takı`, `nota`, `mikrofon` | accessory families | target compatibility vs dimensions | Use head noun/target; merchant sector is weak prior only. | MEDIUM |
| SC-016 | mat | exercise mat | home/vehicle floor mat | Spor / Ev & Yaşam / Otomotiv | `yoga`, `kapı`, `araç`, dimensions | product use/placement | material/dimensions/fitment | Context token required; bare query grouped. | HIGH |
| SC-017 | batarya | plumbing faucet | electrical battery | Yapı & Tesisat / Elektronik / Araç | `lavabo`, `musluk`, `mAh`, `akü` | fixture vs power source | thread/installation vs voltage/chemistry | Units provide strong signal; never global alias. | CRITICAL |
| SC-018 | monitör | computer display | studio speaker or health monitor | Bilgisayar / Müzik / Sağlık | `ekran`, `stüdyo`, `hasta`, resolution | device type | display specs vs audio/measurement type | Canonical phrase/context wins; policy for health device. | HIGH |
| SC-019 | klavye | computer keyboard | musical keyboard | Bilgisayar / Müzik | `mouse`, `Q`, `piyano`, `org`, keys | peripheral vs instrument | layout/switch vs key count/tone | Bare query returns both families; query history must not hard-pin. | HIGH |
| SC-020 | motor | motorcycle colloquialism | vehicle/electrical motor | Otomotiv / Yapı / Beyaz Eşya | `motosiklet`, `yedek`, `elektrik`, `pompa` | vehicle vs part/component | vehicle fitment vs voltage/power | Require compound term; bare token is under-specified. | HIGH |
| SC-021 | fırın | bakery/retail context | cooking appliance | Gıda / Beyaz Eşya | `ekmek`, `pastane`, `ankastre`, `elektrikli` | product vs merchant/food intent | ingredient vs capacity/power | Merchant type does not become product; show food and appliance groups. | MEDIUM |
| SC-022 | pasta | cake/pastry | pasta/noodle loanword | Gıda & İçecek | `doğum günü`, `makarna`, `spagetti` | bakery vs dry-food L2 | ingredient/form/occasion | Turkish locale default is cake but keep query-context disambiguation. | HIGH |
| SC-023 | sarf | printer consumable | medical/office/tool consumable | Bilgisayar / Sağlık / Kırtasiye / Yapı | target device/tool; `medikal` | several accessory families | compatibility/pack count | Bare term too broad; require device/domain phrase. | MEDIUM |
| SC-024 | kılıf | phone case | glasses/instrument/tool carrying case | Elektronik / Optik / Müzik / Çanta | compatible target and `taşıma` | protection accessory vs carrying product | model fit vs dimensions/material | Primary function and target decide; no cross-domain duplication. | HIGH |
| SC-025 | koruyucu | phone/surface protector | PPE or baby/home safety guard | Elektronik / Yapı / Anne & Bebek | target noun, safety standard | accessory vs protective equipment | compatible model vs certification | Never treat safety adjective as product identity alone. | HIGH |
| SC-026 | bileklik | jewelry bracelet | smart wearable or medical support | Saat & Takı / Elektronik / Sağlık | `akıllı`, `altın`, `destek` | jewelry/device/support | material vs sensors vs body area | Medical claim and device signals override style. | HIGH |
| SC-027 | tulum | garment | baby sleepwear or protective workwear | Giyim / Anne & Bebek / Yapı | audience/age, safety standard | apparel forms and PPE boundary | size/material/age/certification | Keep apparel owner unless protective/safety evidence changes policy. | MEDIUM |
| SC-028 | mama | pet food | infant food | Pet / Anne & Bebek / Gıda | species, age months, formula | species/life-stage ownership | ingredient/dietary/age | Policy and life-stage evidence required; never rely on merchant type. | CRITICAL |
| SC-029 | astar | paint primer | garment lining | Yapı / Giyim | `boya`, `duvar`, `ceket`, material | coating vs garment attribute | substrate/hazard vs composition | Phrase and chemical/material facets resolve. | MEDIUM |
| SC-030 | bant | office adhesive tape | therapy/sport/electrical tape | Kırtasiye / Sağlık / Spor / Yapı | `koli`, `kinezyo`, `izole` | product intended use | adhesive/material vs medical intended use | Health claim invokes policy; bare term grouped. | HIGH |
| SC-031 | kalem | writing instrument | phone stylus or cosmetic pencil | Kırtasiye / Elektronik / Kozmetik | `tükenmez`, model name, `göz/dudak` | three product types | ink/nib vs model compatibility vs shade | Exact phrase and application area resolve. | HIGH |
| SC-032 | sünger | cleaning/kitchen sponge | makeup applicator or mattress foam | Ev/Mutfak / Kozmetik / Ev & Yaşam | `bulaşık`, `makyaj`, `yatak` | consumable/tool/material | body area vs material/dimensions | Treat material-only mention as weak signal. | MEDIUM |
| SC-033 | terazi | household/food scale | workshop measurement or health scale | Züccaciye / Yapı / Sağlık | `mutfak`, `hassas`, `vücut` | measurement device purpose | range/accuracy/intended use | Medical intended use requires evidence; group bare query. | HIGH |
| SC-034 | kamera | photo/video camera | security/vehicle/baby camera | Elektronik / Otomotiv / Anne & Bebek | `fotoğraf`, `IP`, `araç`, `bebek` | owner-final Electronics subfamilies plus vehicle context | mount/protocol/fitment | Prefer exact compound; bare query shows camera families. | HIGH |
| SC-035 | hoparlör | consumer audio speaker | studio monitor/vehicle speaker | Elektronik / Müzik / Otomotiv | `Bluetooth`, `stüdyo`, `oto` | audio ownership vs domain-specific equipment | power/interface/vehicle fit | Compatibility and usage context, not merchant sector, resolve. | MEDIUM |
| SC-036 | çanta | fashion/carrying product | equipment/accessory containment | Çanta / Electronics/Computer/Music context | primary carrying function, device dimensions | usually Çanta & Aksesuar | compatible size/model as facet | Carrying identity wins even when made for a device. | MEDIUM |
| SC-037 | yatak | mattress/sleep product | bed frame or baby travel bed | Ev & Yaşam / Anne & Bebek | `şilte`, `karyola`, `park`, age | mattress vs furniture/baby product | dimensions/material/age | Exact product-form tokens required. | MEDIUM |
| SC-038 | puset | stroller colloquialism | infant carrier/car-seat colloquialism | Anne & Bebek | wheels, vehicle/seat, carry form | stroller/transport vs safety seat | load/age/standard/vehicle fit | Do not auto-map; ask product form or use typed title signals. | HIGH |
| SC-039 | saat | classic watch | smart watch or timekeeping appliance/accessory | Saat & Takı / Elektronik | `akıllı`, `mekanik`, sensors | jewelry/watch vs wearable | movement/material vs OS/sensors | Bare `saat` favors classic but exposes smart cluster; exact phrase wins. | MEDIUM |
| SC-040 | şarj | charger/power product | charging feature/compatibility | Elektronik / Bilgisayar / Tools/Vehicle contexts | `cihazı`, watts, connector, target model | product type vs attribute/action | protocol/power/model compatibility | Verb/feature token alone cannot assign category; retrieve typed products. | MEDIUM |

## Severity summary

| Severity | Count | Meaning |
|---|---:|---|
| `CRITICAL` | 5 | Safety/policy or high-risk wrong-domain result; fail closed/explicit context. |
| `HIGH` | 23 | Likely materially wrong product family without context. |
| `MEDIUM` | 12 | Grouping/phrase matching normally resolves; monitor quality. |
| **Total** | **40** | — |

## Global safeguards

- Longest exact semantic phrase wins over isolated token.
- Structured category/facet/compatibility evidence outranks merchant type.
- Bare ambiguous terms may produce labeled result groups or clarification.
- Search expansion cannot authorize medical, hazardous, age-restricted or excluded goods.
- A collision fix does not rename/finalize any proposed category.

## Vocabulary exact multi-target checkpoint

The generated 1,220-row vocabulary contains eight exact case-insensitive terms that
legitimately target more than one L2: `bileklik`, `disk`, `fırın`, `keyboard`,
`monitör`, `notebook`, `organizer` and `önlük`. All `19` rows in these eight groups
are marked `AMBIGUOUS=YES` with the other target(s). This checkpoint is a mechanical
subset/cross-check of the 40 semantic collision rows, not eight extra canonical
collision decisions. Together with seven single-target terms that carry known wider
semantic risk, the vocabulary has `26` ambiguous rows across `15` unique terms.

`SEARCH_COLLISION_COUNT: 40`

`GLOBAL_ONE_TO_ONE_MAPPING_FOR_AMBIGUOUS_TERMS: FORBIDDEN`
