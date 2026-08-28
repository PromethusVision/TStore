# Reward Product Domain Matrix

**State:** PROPOSED FOR OWNER REVIEW

**Scope:** Workstream AZ — 24 canonical product L1 reward compatibility

**Canonical source:** `docs/ESNAFTAVAR_CANONICAL_CATEGORY_TAXONOMY.md`

## Rule

Taxonomy membership never grants a reward by itself. An eligible reward event must trace to one server-authoritative, merchant-confirmed physical purchase. Product-domain policy is evaluated at the most specific known product/variant policy; an unknown or regulated state fails closed. Quantity, repeat purchase and reward treatment remain independent of the lifetime review right.

`STANDARD_CANDIDATE` means technically compatible, not Product Owner approval. `CONDITIONAL` requires product-policy controls. `EXCLUDE_PENDING_REVIEW` cannot earn or redeem a purchase-linked incentive until the stated review closes.

## Canonical 24-L1 matrix

| # | Canonical L1 | Proposed reward posture | Conditions / risk boundary |
|---:|---|---|---|
| 1 | Gıda & İçecek | CONDITIONAL | Ordinary groceries may be candidates; alcohol, tobacco-like inventory, infant formula, supplements and health-claim products require item-level fail-closed rules. |
| 2 | Giyim & Moda | STANDARD_CANDIDATE | Returns/corrections must reverse economic reward without altering review evidence. |
| 3 | Ayakkabı | STANDARD_CANDIDATE | Size exchanges are corrections, not new earning events. |
| 4 | Çanta & Aksesuar | STANDARD_CANDIDATE | No domain exception; counterfeit/fraud policy remains external. |
| 5 | Elektronik | CONDITIONAL | High-value fraud, serial/return abuse and warranty corrections require controls; amount weighting is not assumed. |
| 6 | Bilgisayar & Tablet | CONDITIONAL | Same high-value/return controls as electronics; verified item identity must survive catalog corrections. |
| 7 | Beyaz Eşya & Ev Aletleri | CONDITIONAL | Delivery, cancellation and return timing make pending-to-final settlement preferable. |
| 8 | Ev & Yaşam | STANDARD_CANDIDATE | Normal return/correction rules apply. |
| 9 | Züccaciye & Mutfak | STANDARD_CANDIDATE | Normal return/correction rules apply. |
| 10 | Yapı, Hırdavat & Tesisat | CONDITIONAL | Restricted chemicals/tools and professional-use items require item-policy evaluation. |
| 11 | Otomotiv & Motosiklet | CONDITIONAL | Fitment, returns, regulated/safety items and installation/service boundaries require item-policy evaluation. |
| 12 | Kozmetik & Kişisel Bakım | CONDITIONAL | Health claims, age-sensitive goods and hygiene-return constraints require policy review; do not gamify medical outcomes. |
| 13 | Anne & Bebek | EXCLUDE_PENDING_REVIEW | Infant formula, feeding and safety products need legal/policy review before any economic incentive. |
| 14 | Oyuncak & Hobi | CONDITIONAL | Age-restricted, weapon-like, hunting or pyrotechnic items fail closed; ordinary toys/hobbies may qualify. |
| 15 | Müzik & Enstrüman | STANDARD_CANDIDATE | Physical product only; lessons/services are outside product reward scope. |
| 16 | Spor & Outdoor | CONDITIONAL | Hunting/weapons, supplements and regulated equipment fail closed. |
| 17 | Kitap | STANDARD_CANDIDATE | No purchase-value assumption; normal correction rules apply. |
| 18 | Kırtasiye & Ofis | STANDARD_CANDIDATE | Normal correction rules apply. |
| 19 | Evcil Hayvan Ürünleri | CONDITIONAL | Veterinary medicinal/health products require policy review; ordinary supplies may qualify. |
| 20 | Gözlük & Optik | CONDITIONAL | Medical-device/prescription boundaries require item-level review; ordinary accessories may qualify. |
| 21 | Saat & Takı | CONDITIONAL | High-value fraud and returns require delayed settlement; amount weighting is not assumed. |
| 22 | Sağlık & Medikal | EXCLUDE_PENDING_REVIEW | Medicines, medical devices, health services and claims require legal/policy approval before rewards. |
| 23 | Çiçek & Bahçe | CONDITIONAL | Pesticides, chemicals and regulated plant inputs require item-level review; ordinary plants/accessories may qualify. |
| 24 | Hediyelik & Parti | CONDITIONAL | Alcohol-linked, pyrotechnic or age-restricted items fail closed; ordinary gifts/party goods may qualify. |

## Cross-domain controls

- Eligibility uses stable product and variant identity, never a mutable category name/path.
- A category move does not retroactively earn, revoke or duplicate reward. Historical policy snapshots remain auditable.
- Mixed baskets evaluate each verified item independently. An excluded item cannot be hidden inside an otherwise eligible basket.
- `unknown_policy`, missing product identity, legacy boolean verification, unconfirmed QR or client-only evidence earns nothing.
- Sponsored placement does not change eligibility or reward value.
- Product merges deduplicate identity; product splits do not fan one historical purchase into multiple earning events.

## Recommended owner posture

Start any later shadow-mode evaluation with ordinary `STANDARD_CANDIDATE` goods only. Keep all `CONDITIONAL` and `EXCLUDE_PENDING_REVIEW` items economically inactive until policy rules, reversal handling and owner scope are approved. This is a recommendation, not a final decision.
