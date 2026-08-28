# Taxonomy Product-Placement Root Fix Opportunities

## Status

**OWNER RULE CANDIDATES — NOT FINALIZED**

Counts are test-case impacts and may overlap across root rules. The final estimated auto-resolution count is deduplicated.

| Root rule | Current failure count | Affected domains | Recommended owner rule | Failures auto-resolved | Remaining manual cases |
|---|---:|---|---|---|---|
| MEDICAL INTENDED USE AND REGULATORY STATUS | 26 | Gıda; Anne & Bebek; Kozmetik; Sağlık; Pet | Let authoritative legal status and intended use gate sale; cosmetic/food/pet claims remain facets unless a regulated status overrides or blocks. | EDGE-0001, EDGE-0002, EDGE-0003, EDGE-0008, EDGE-0009, EDGE-0010, EDGE-0011, EDGE-0013, EDGE-0014, EDGE-0015, EDGE-0019, EDGE-0021, EDGE-0023, EDGE-0024, EDGE-0123, EDGE-0125, EDGE-0130, EDGE-0132, EDGE-0133 | EDGE-0004, EDGE-0005, EDGE-0006, EDGE-0016, EDGE-0020, EDGE-0124, EDGE-0127 |
| BABY-SPECIFIC PRODUCT OVERRIDE | 5 | Anne & Bebek; Gıda; Kozmetik; Çanta | Use Anne & Bebek only when formulation, safety, feeding or dedicated care/transport design is baby-specific; age alone remains a facet. | EDGE-0001, EDGE-0002, EDGE-0003, EDGE-0021, EDGE-0037 | — |
| PPE AND TECHNICAL SPORTS PRECEDENCE | 17 | Giyim; Ayakkabı; Spor; Hırdavat; Sağlık; Optik; Otomotiv | Certified protective intended use overrides fashion form; otherwise apparel/footwear owns wearable products and sport stays a facet. | EDGE-0025, EDGE-0026, EDGE-0027, EDGE-0028, EDGE-0029, EDGE-0030, EDGE-0031, EDGE-0032, EDGE-0033, EDGE-0034, EDGE-0036, EDGE-0113, EDGE-0114, EDGE-0115, EDGE-0117, EDGE-0119, EDGE-0120 | — |
| GENERIC VS DOMAIN-SPECIFIC ACCESSORY | 25 | Çanta; Elektronik/Fotoğraf; Bilgisayar; Müzik; Hırdavat | Generic multi-device/general-purpose accessories stay in their generic owner; intrinsic compatibility/protective fit sends them to the target domain. | EDGE-0037, EDGE-0038, EDGE-0039, EDGE-0040, EDGE-0041, EDGE-0042, EDGE-0044, EDGE-0045, EDGE-0046, EDGE-0047, EDGE-0048, EDGE-0062, EDGE-0063, EDGE-0064, EDGE-0066, EDGE-0070, EDGE-0098, EDGE-0099, EDGE-0100, EDGE-0104, EDGE-0105, EDGE-0106, EDGE-0107, EDGE-0108, EDGE-0109 | — |
| VEHICLE FITMENT | 12 | Otomotiv; Elektronik; Telefon; Çanta | Require model/vehicle installation or vehicle-system integration for Automotive ownership; an in-car use occasion alone is insufficient. | EDGE-0074, EDGE-0075, EDGE-0076, EDGE-0077, EDGE-0078, EDGE-0079, EDGE-0080, EDGE-0081, EDGE-0082, EDGE-0083, EDGE-0084, EDGE-0085 | — |
| POWERED VS MANUAL / MOVABLE VS FIXED | 6 | Ev; Züccaciye; Beyaz Eşya; Hırdavat; Elektronik | Powered finished appliance follows appliance owner; manual utensil follows houseware; fixed structural component follows hardware while movable furnishing follows home. | EDGE-0053, EDGE-0054, EDGE-0055, EDGE-0056, EDGE-0057, EDGE-0061 | — |
| TOY-GRADE VS FUNCTIONAL PRODUCT | 9 | Oyuncak; Elektronik; Müzik; Kırtasiye | Use functional capability, age/safety design and primary play intent together; product shape or an age label alone cannot decide. | EDGE-0086, EDGE-0087, EDGE-0090, EDGE-0092, EDGE-0093, EDGE-0094, EDGE-0095 | EDGE-0096, EDGE-0097 |
| PROFESSIONAL WORKFLOW VS CONSUMER DEVICE | 9 | Müzik; Elektronik; Bilgisayar; Fotoğraf | Production/recording/live-sound workflow owns specialized pro equipment; consumer playback and PC-first peripherals keep their device owner. | EDGE-0098, EDGE-0099, EDGE-0100, EDGE-0104, EDGE-0105, EDGE-0106, EDGE-0107, EDGE-0108, EDGE-0109 | — |
| OPTICAL CORRECTION VS SPORT/PPE | 6 | Optik; Spor; Hırdavat; Sağlık | Optical correction/lens care stays Optics; certified protection goes PPE; sport-only protective equipment follows the sport domain. | EDGE-0113, EDGE-0114, EDGE-0115, EDGE-0117, EDGE-0119, EDGE-0120 | — |
| SPECIES-SPECIFIC VS SHARED PET PRODUCT | 7 | Pet; Sağlık; Gıda; Çanta | Species is a facet for truly shared products; intrinsic species formulation/fit may select a species branch; veterinary status remains policy-gated. | EDGE-0123, EDGE-0125, EDGE-0130, EDGE-0132, EDGE-0133 | EDGE-0124, EDGE-0127 |
| GIFT INTENT, PERSONALIZATION AND BUNDLE | 10 | Hediyelik; Gıda; Çiçek; Takı; Oyuncak; Giyim; Züccaciye | Gift/personalized are collection/fulfillment signals; each physical bundle line item retains its product owner. | EDGE-0146, EDGE-0147, EDGE-0148, EDGE-0149, EDGE-0150, EDGE-0151, EDGE-0155, EDGE-0156 | EDGE-0154, EDGE-0157 |
| PHYSICAL PRODUCT VS SERVICE/DIGITAL/RESTRICTED SCOPE | 7 | All domains / future service-policy scope | Exclude labor, digital licenses, stored value, weapons and pyrotechnics from physical product taxonomy until separately authorized. | EDGE-0162, EDGE-0163, EDGE-0164, EDGE-0165 | EDGE-0166, EDGE-0167, EDGE-0169 |
| FINISHED DOMAIN EQUIPMENT VS COMPONENT | 13 | Elektronik; Bilgisayar; Hırdavat; Bahçe | A ready-to-use domain instrument follows its use domain; a bare maker/computer component follows the owner-final component boundary. | EDGE-0062, EDGE-0063, EDGE-0064, EDGE-0066, EDGE-0070, EDGE-0136, EDGE-0138, EDGE-0139, EDGE-0140, EDGE-0143, EDGE-0144, EDGE-0145 | EDGE-0141 |
| ATTRIBUTE/FACET SEPARATION | 14 | All audited domains | Gender, age, style, material, protocol, dietary claim, gift, condition and personalization stay facets/collections/policy unless product function changes. | EDGE-0008, EDGE-0009, EDGE-0010, EDGE-0013, EDGE-0015, EDGE-0019, EDGE-0047, EDGE-0133, EDGE-0146, EDGE-0148, EDGE-0149, EDGE-0150, EDGE-0151, EDGE-0168 | — |

## Leverage summary

- Root fixes identified: **14**.
- Estimated edge failures auto-resolved after owner-approved root rules (deduplicated): **106**.
- Edge failure cases still requiring explicit structure/policy analysis: **18**.
- Counts are estimates for owner review support, not an automatic proposal mutation plan.

`ROOT_FIX_OPPORTUNITIES: PASS`

`ROOT_RULES_FINALIZED: NO`
