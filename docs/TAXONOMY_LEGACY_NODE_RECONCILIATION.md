# EsnaftaVar Legacy Taxonomy Node Reconciliation

**State:** ANALYSIS ONLY — NOT A RUNTIME MIGRATION

**Inventory:** `docs/TAXONOMY_LEGACY_NODE_RECONCILIATION.csv`

**Legacy source:** `docs/data/esnaftavar_category_taxonomy_v1_final.json`

**Legacy source SHA-256:** `182B8719E74EA889F5FC3B257D119C258C8750F8D24883D08AA6AFB88CCD2B08`

**Canonical base:** `origin/main@f092cf8fe7431f812a017d4cbc9b538775bb41e6`

## 1. Purpose and interpretation

The CSV gives every node in the 651-node legacy tree exactly one reconciliation
row. It is a design-time bridge, not a mutation plan that may be executed as-is.
It deliberately distinguishes three different kinds of knowledge:

1. the 24 owner-final L1 identities;
2. owner-final L2/L3/L4 targets in Electronics and Computer & Tablet;
3. the 22 other L1 domains whose current 224 L2 targets are only proposals.

`TARGET_L1` through `TARGET_L4` record only the deepest target currently supported
by evidence. A blank lower target is not a deletion. It means that the successor
at that depth has not been owner-finalized or that a split has more than one
successor and cannot be represented by a single target column.

For proposal domains, a legacy L3/L4 row may contain a provisional target L2 as a
container hint while its `RECONCILIATION_ACTION` remains `UNRESOLVED`. This is
intentional: a proposed L2 boundary does not define an exact future leaf.

## 2. Inventory contract

The CSV columns are:

| Column | Meaning |
|---|---|
| `LEGACY_NODE_ID` | Exact legacy locator. The legacy source has no opaque ID, so this is the existing slug; it is not a newly invented production ID. |
| `LEGACY_LEVEL` | Source depth, 1–4. |
| `LEGACY_PARENT_ID` | Parent legacy slug, blank only for L1. |
| `LEGACY_PATH` | Source Turkish display path. |
| `LEGACY_NAME` / `LEGACY_SLUG` | Source display name and slug. |
| `CURRENT_STATUS` | Source lifecycle state. |
| `TARGET_L1`…`TARGET_L4` | Deepest supported target path; blanks preserve uncertainty. |
| `TARGET_STATE` | Architectural maturity of the target. |
| `RECONCILIATION_ACTION` | Closed enum requested for this audit. |
| `CONFIDENCE` | `HIGH`, `MEDIUM`, or `LOW`. |
| `OWNER_DECISION_REQUIRED` | Whether the row still depends on owner/policy/lower-level design. |
| `POLICY_FLAG` | Legacy risk gates preserved independently from category placement. |
| `ALIAS_REQUIRED` | Whether a future migration should preserve the old locator/name. |
| `SUCCESSOR_COUNT` | Known number of direct successors for a split; zero when not determined. |
| `NOTES` | Candidate set, boundary reasoning, or remaining uncertainty. |

Only the allowed reconciliation actions and target states are used. Search
synonyms are not treated as legacy redirects.

## 3. Independently verified coverage

| Measure | Count |
|---|---:|
| Legacy L1 | 23 |
| Legacy L2 | 91 |
| Legacy L3 | 505 |
| Legacy L4 | 32 |
| **Total inventory rows** | **651** |
| Unique `LEGACY_NODE_ID` values | 651 |
| Active rows | 650 |
| `inactive_review` rows | 1 |
| Rows with at least one legacy policy/risk flag | 130 |

The historical `23 / 91 / 505 / 32` count is therefore exact for the
authoritative legacy JSON. No node was added for metadata-only deprecations that
are absent from `nodes`; doing so would falsely inflate the inventory.

## 4. L1 bridge

The new 24 L1 names are owner-final. Legacy names do not override them.

| Legacy L1 | Owner-final successor | Action |
|---|---|---|
| Market & Gıda | Gıda & İçecek | RENAME |
| Moda & Giyim | Giyim & Moda | RENAME |
| Ayakkabı | Ayakkabı | KEEP |
| Çanta & Giyim Aksesuarı | Çanta & Aksesuar | RENAME |
| Elektronik | Elektronik | KEEP |
| Bilgisayar & Tablet | Bilgisayar & Tablet | KEEP |
| Beyaz Eşya & Ev Aletleri | Beyaz Eşya & Ev Aletleri | KEEP |
| Ev & Yaşam | Ev & Yaşam | KEEP |
| Züccaciye & Mutfak | Züccaciye & Mutfak | KEEP |
| Yapı & Hırdavat | Yapı, Hırdavat & Tesisat | RENAME |
| Otomotiv & Motosiklet | Otomotiv & Motosiklet | KEEP |
| Kişisel Bakım & Kozmetik | Kozmetik & Kişisel Bakım | RENAME |
| Bebek & Çocuk | Anne & Bebek | RENAME |
| Oyuncak, Hobi & Müzik | Oyuncak & Hobi **and** Müzik & Enstrüman | SPLIT |
| Spor & Outdoor | Spor & Outdoor | KEEP |
| Kitap | Kitap | KEEP |
| Kırtasiye & Ofis | Kırtasiye & Ofis | KEEP |
| Pet Shop | Evcil Hayvan Ürünleri | RENAME |
| Optik | Gözlük & Optik | RENAME |
| Saat & Takı | Saat & Takı | KEEP |
| Sağlık & Medikal | Sağlık & Medikal | KEEP |
| Çiçek & Bahçe | Çiçek & Bahçe | KEEP |
| Hediyelik & Parti | Hediyelik & Parti | KEEP |

The increase from 23 to 24 L1 nodes is explained by the owner-final split of
`Oyuncak, Hobi & Müzik`; it is not an unexplained new domain.

## 5. Final-domain bridge

### 5.1 Electronics

All 49 legacy Electronics rows use `CANONICAL_FINAL`. The old six L2 nodes are
coarse umbrellas and bridge to the owner-final nine L2 architecture:

- `Telefon & Giyilebilir Teknoloji` splits between `Telefon & Aksesuarları` and
  `Giyilebilir Teknoloji`.
- `Telefon Aksesuarları` splits between `Telefon & Aksesuarları` and
  `Güç, Şarj & Bağlantı`.
- `Ses & Görüntü Sistemleri` splits among `TV & Görüntü Sistemleri`,
  `Ses & Kulaklık`, and `Güç, Şarj & Bağlantı`.
- `Kamera & Güvenlik Elektroniği` splits between `Fotoğraf & Kamera` and
  `Akıllı Ev & Güvenlik`.
- `Oyun Konsolu & Aksesuarları` remains the same final L2.
- `Elektronik Güç, Kablo & Bileşen` splits between
  `Güç, Şarj & Bağlantı` and `Elektronik Bileşenler`.

The owner-final Phone & Accessories design allows exact successor paths for
smartphones, feature phones, cases, screen protectors, selfie/camera accessories,
phone batteries, and screen/touch modules. General chargers move to the final
power/connection L2. The legacy `Araç & Masa Telefon Tutucu` is an actual
use-case split: phone-primary holders remain in Electronics while vehicle-primary
holders move to Automotive. It must not be bulk-assigned to one arbitrary child.

### 5.2 Computer & Tablet

All 38 legacy Computer & Tablet rows use `CANONICAL_FINAL`. The old four L2
umbrellas split into the final eleven L2 boundaries. Notable results are:

- laptop, desktop/all-in-one/mini PC, tablet, and e-reader separate at L2;
- monitor separates from other peripherals;
- USB hub/dock and tablet input accessories move to Computer Accessories;
- network products, print/scan consumables, and data storage separate at L2;
- SSD, internal HDD, optical drive, USB memory/card, external disk, and NAS all
  move to `Veri Depolama`; storage duplication under Computer Components is zero;
- toner/cartridge remains under `Yazıcı, Tarayıcı & Sarf Malzemeleri`;
- CPU, GPU, motherboard, RAM, PSU, and case map to owner-final component L3s;
- the broad legacy `Bilgisayar Soğutma` leaf splits to four final cooling L4s:
  CPU cooler, case fan, liquid cooling, and thermal paste/pad.

The final component architecture contains additional nodes absent from the legacy
tree, such as `Genişleme Kartları` and `Tek Kart Bilgisayar (SBC)`. Their absence
does not create synthetic legacy rows.

## 6. Provisional 22-domain bridge

All non-Electronics/non-Computer rows below L1 are based on the 22 branch-sourced
L2 proposals and are marked `PROVISIONAL_PROPOSAL`. No proposal branch was merged.
The source commits are:

- Batch 01: `4b500a629e3ca6f388617c49aae16fe32538a378`
- Batch 02: `bca5d57c359dc4f767972597551aa6616031b667`
- Batch 03: `f1e766eeacbcbc1f1ed69ee18d040321645a6796`

The proposal bridge covers 542 rows. Coarse legacy L2s are marked `SPLIT` where
they span several proposed L2s. Descendants receive a provisional L2 container
only when the legacy label, aliases, and keywords support a unique placement.
They remain `UNRESOLVED` until owner-final L2 plus future L3/L4 design establishes
an exact successor.

Policy-sensitive rows retain their legacy `risk_flags` in `POLICY_FLAG`; this does
not convert a proposed target into a final target. Examples include health claims,
medical regulation, cold chain, hazardous materials, safety-critical equipment,
and age-sensitive products.

## 7. Reconciliation counts

| Action | Count |
|---|---:|
| KEEP | 20 |
| RENAME | 17 |
| MOVE | 60 |
| RENAME_AND_MOVE | 9 |
| MERGE | 0 |
| SPLIT | 83 |
| RETIRE | 1 |
| ALIAS_ONLY | 0 |
| OUT_OF_PRODUCT_TAXONOMY | 0 |
| UNRESOLVED | 461 |
| **Total** | **651** |

Zero counts are findings, not omitted enum values. Multiple legacy nodes sharing
a future container do not automatically constitute a semantic merge; without an
owner-final exact successor, those rows remain unresolved.

| Target state | Count |
|---|---:|
| CANONICAL_FINAL | 108 |
| PROVISIONAL_PROPOSAL | 542 |
| NO_TARGET_YET | 1 |
| POLICY_REVIEW | 0 |
| OUT_OF_SCOPE | 0 |
| **Total** | **651** |

`POLICY_REVIEW` is zero in the target-state column because every active policy-
sensitive legacy node still has at least a taxonomy placement candidate. The 130
policy gates are recorded separately in `POLICY_FLAG`; placement never authorizes
sale or suppresses policy review.

Additional review signals:

- 109 rows are high confidence, 462 medium, and 80 low.
- 545 rows require an owner, policy, or future lower-level decision.
- 93 rows are marked for future legacy alias/redirect preservation.
- The one `inactive_review` legacy node, `hediyelik-obje`, is marked `RETIRE` with
  historical identity retention; its apparent proposal container is not an
  activation decision.

## 8. Known limitations and owner-review posture

- The CSV is node-level, but the 22 proposal domains currently define only L2.
  Exact L3/L4 reconciliation is impossible until those designs are approved.
- A `SPLIT` row lists successor candidates in `NOTES`; the single target columns
  remain blank where choosing one would be arbitrary.
- No merge is asserted merely from name similarity or shared target container.
- No product reassignment is inferred from taxonomy labels alone.
- No opaque production IDs, database records, aliases, redirects, or runtime
  taxonomy files were created.
- This inventory must be regenerated or reviewed after any proposal finalization;
  `PROVISIONAL_PROPOSAL` rows are not migration instructions.
