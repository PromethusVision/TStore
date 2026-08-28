# Canonical Product Policy Matrix — 24 L1

**State:** PROPOSED FOR PROFESSIONAL/OWNER REVIEW — NOT A SALES ALLOWLIST
**Canonical taxonomy:** exact 24 owner-final L1 names are preserved.

Policy is evaluated at exact product/variant/listing/claim/channel, not inherited
blindly from an L1. A single L1 can contain `NORMAL`, `AGE_RESTRICTED`, `REGULATED`,
`LEGAL_REVIEW_REQUIRED` and `EXCLUDED` products. Taxonomy eligibility is not legal
permission; catalog eligibility is not ad or reward eligibility.

## Matrix

| # | Canonical L1 | Ordinary candidate lane | Sensitive candidates | Proposed V1 gate |
|---:|---|---|---|---|
| 1 | Gıda & İçecek | ordinary registered packaged/fresh food with truthful label | alcohol; supplements; special medical nutrition; infant formula; health claims | ordinary `NORMAL` after merchant/listing checks; named groups use dossier; alcohol ads/rewards `EXCLUDED` |
| 2 | Giyim & Moda | ordinary apparel/textiles | protective clothing marketed as PPE; health/therapeutic claims | ordinary `NORMAL`; PPE/claim `REGULATED` |
| 3 | Ayakkabı | ordinary footwear | safety/protective footwear; therapeutic/orthopedic claims | ordinary `NORMAL`; PPE/medical claim `REGULATED` |
| 4 | Çanta & Aksesuar | ordinary bags/wallets/fashion accessories | precious-metal components, counterfeit claims, hidden weapon-like function | ordinary `NORMAL`; exact risky item escalates |
| 5 | Elektronik | ordinary consumer electronics with conformity/safety evidence | nicotine/e-cigarette devices; surveillance/privacy; medical intended use; high-power lasers | ordinary `NORMAL`; nicotine `EXCLUDED`; exact safety/privacy/medical use reviewed |
| 6 | Bilgisayar & Tablet | ordinary computers/components/accessories | professional medical/diagnostic use claims; batteries/laser/network surveillance | ordinary `NORMAL`; claim/hazard review where signalled |
| 7 | Beyaz Eşya & Ev Aletleri | ordinary compliant appliances | gas/installer-only equipment; medical/sterilization claims; high-risk heating | ordinary `NORMAL`; fixed-installation/claim `REGULATED` |
| 8 | Ev & Yaşam | ordinary furniture/textiles/decor/storage | biocides, corrosive cleaners, hazardous aerosols, flame/safety claims | ordinary `NORMAL`; hazardous/biocidal `REGULATED` |
| 9 | Züccaciye & Mutfak | ordinary kitchenware/food-contact goods | pressure/gas products, sharp weapon-like items, health claims | ordinary `NORMAL`; safety/intended-use review |
| 10 | Yapı, Hırdavat & Tesisat | ordinary tools/fittings/materials | hazardous chemicals, gas/fixed installation, PPE, weapon-like tools | item-level `REGULATED` allowlist; unresolved weapon/chemical items fail closed |
| 11 | Otomotiv & Motosiklet | ordinary fitment-verified part/accessory | oils/chemicals; batteries; tyres/brakes/restraints/helmets; registration/security devices | safety/chemical/PPE signals `REGULATED`; no sector-only approval |
| 12 | Kozmetik & Kişisel Bakım | ordinary correctly classified cosmetic/personal-care good | biocidal/disinfectant, health/treatment claim, ingestible, device, professional procedure | exact classification and claim; ambiguous `LEGAL_REVIEW_REQUIRED` |
| 13 | Anne & Bebek | ordinary feeding/accessory/diaper/baby-care goods | infant formula/young-child food; restraints/sleep safety; medicine/device/health claim | formula/promotion and medical/safety groups fail closed pending specialist rule |
| 14 | Oyuncak & Hobi | ordinary age-appropriate toy/hobby material | pyrotechnics; weapon replicas; hazardous chemical kits; high-power lasers/magnets | pyrotechnics `EXCLUDED`; other risky items `AGE_RESTRICTED` or `REGULATED` after rule |
| 15 | Müzik & Enstrüman | ordinary instruments/accessories | high-output lasers, hazardous stage effects, hearing/medical claims | ordinary `NORMAL`; exact risky device reviewed |
| 16 | Spor & Outdoor | ordinary sporting/camping goods | firearms/ammunition/hunting weapons; knives; climbing/PPE; pyrotechnics; supplements | weapons/pyro `EXCLUDED`; PPE/supplement `REGULATED` |
| 17 | Kitap | ordinary physical books | illegal content/rights complaints; age-appropriate presentation | `NORMAL` product lane; UGC/content notice policy separate; digital service out of current physical taxonomy |
| 18 | Kırtasiye & Ofis | ordinary paper/writing/filing/office supplies | solvents/adhesives/toner chemical warnings; lasers; sharp tools | ordinary `NORMAL`; exact chemical/device safety reviewed |
| 19 | Evcil Hayvan Ürünleri | ordinary food/accessory/grooming goods | veterinary medicines/health products; live animals; pesticide-like parasite control | live animals current `EXCLUDED`; veterinary products specialist fail closed |
| 20 | Gözlük & Optik | ordinary non-prescription accessories after exact classification | prescription/custom optics; contact lenses; medical claims/devices | `LEGAL_REVIEW_REQUIRED`/`REGULATED`; licensed establishment/evidence required |
| 21 | Saat & Takı | ordinary watches/costume jewellery | precious metal/stones, high-value authenticity, regulated merchant claims | precious/high-value `REGULATED`; merchant authorization/authenticity review |
| 22 | Sağlık & Medikal | no broad ordinary presumption | medicines, devices, diagnostics, professional/invasive products, supplements, PPE, health claims | medicines current `EXCLUDED`; every other SKU exact specialist classification |
| 23 | Çiçek & Bahçe | ordinary live plants/cut flowers/tools/soil/fertilizer where allowed | pesticides/plant-protection; biocides; toxic chemicals; invasive/protected species | plant-protection `EXCLUDED` for internet listing/sale candidate; other regulated item review |
| 24 | Hediyelik & Parti | ordinary decorations/gifts/party supplies | pyrotechnics/explosives; alcohol/tobacco gift sets; food/cosmetic/laser components | component-wise strictest rule; pyro `EXCLUDED`; bundle never bypasses policy |

## Cross-cutting rules

1. Intended use and claim can change class without changing taxonomy identity.
2. `UNKNOWN` never defaults to `NORMAL` in a policy-signalled rule.
3. Bundle/kit class is at least as restrictive as each component; assign to the
   principal taxonomy leaf but evaluate every component.
4. Used/renewed condition, recall, seller authorization, expiry and fulfilment are
   separate eligibility inputs.
5. Merchant approval does not authorize every SKU; SKU approval does not authorize
   every advertisement or reward.
6. Policy version changes append impact decisions; historical QR/review/catalog
   evidence is not silently rewritten.

## Count integrity

- Canonical L1 represented: **24/24**.
- Duplicate L1 names: **0**.
- L1 renamed/reordered: **0**.
- Whole L1 declared legally sellable: **0**.
- Owner/legal finalization performed: **0**.

`PRODUCT_POLICY_MATRIX_FINAL: NO`
