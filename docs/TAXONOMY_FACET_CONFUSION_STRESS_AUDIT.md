# Global Taxonomy Facet-Confusion Stress Audit

## Status

**AUDIT FINDINGS — NO OWNER FINALIZATION / NO RUNTIME**

A category answers “what physical product is this?” A facet describes the product, compatibility, audience or use. A collection groups products temporarily for discovery. Policy determines whether and how an offer may be sold. The signals below are the recurring places where those layers could be confused.

## Signal audit

| Current category signal | Should be | Why | Impact if encoded as category | Evidence |
|---|---|---|---|---|
| Kadın / erkek | FACET | Gender does not change most physical product forms. | Parallel duplicate trees and mixed inventory. | Clothing, shoes, watches representative tests |
| Çocuk / bebek age labels | FACET by default; CATEGORY only when safety/formulation changes | Age may alter safety, fit or formulation, but sometimes only sizing. | Leakage between Anne & Bebek, Ayakkabı, Giyim and Oyuncak. | EDGE-0001–0003, EDGE-0021, EDGE-0071 |
| Günlük / klasik | STYLE / OCCASION FACET | Same shoe form can be styled differently. | “Günlük Ayakkabılar” and “Klasik Ayakkabılar” compete. | Granularity INV-071/073 |
| Spor türü | FACET below product form unless equipment taxonomy requires it | A shirt or shoe remains apparel/footwear; a racket remains sport equipment. | Duplicate sports apparel and shoes under Spor & Outdoor. | EDGE-0025–0029 |
| Teknik / profesyonel | INTENDED-USE FACET plus root boundary | Marketing adjective alone is insufficient; functional standards may change owner. | Consumer/pro-audio and generic/tool products split inconsistently. | EDGE-0097–0106 |
| PPE / koruma standardı | POLICY + TECHNICAL FACET; category when primary intended use is PPE | Certification and intended use are stronger than garment shape. | Safety products leak into Giyim, Optik or Health. | EDGE-0026, EDGE-0030, EDGE-0032, EDGE-0113 |
| Malzeme (deri, çelik, pamuk) | FACET | Material is orthogonal to product form. | One product appears in several material branches. | Bags, clothing, kitchen tests |
| Renk | FACET | Color never establishes primary physical ownership. | Unbounded duplicate leaves. | All domains |
| Beden / ölçü | FACET | Variant dimension, not product family. | Variant explosion and poor merchant onboarding. | Apparel, shoes, optics, home tests |
| Kapasite / hacim | FACET | Differentiates variants of the same product. | Duplicated bottle, bag, appliance and storage nodes. | EDGE-0037–0048 |
| Watt / voltaj / güç | FACET + safety metadata | Technical rating does not make a new product family. | Charging/appliance/tool trees fragment. | EDGE-0064–0072 |
| USB-C / Lightning / HDMI | COMPATIBILITY FACET | Connector type is not owner; primary function and domain specificity decide. | Generic charging and computer/phone accessories duplicate. | EDGE-0066, EDGE-0070–0072 |
| Bluetooth / Wi-Fi / 5G | PROTOCOL FACET | Connectivity is an attribute except where owner-final connected-device boundary applies. | Everything “smart” moves to Elektronik regardless of product function. | EDGE-0056, EDGE-0075, EDGE-0084 |
| Smart / connected | FACET plus owner-final device rule | Connected bulb/lock is Elektronik, but “smart” is not a universal L2 axis. | Smart garden/appliance/vehicle products duplicate. | EDGE-0056, EDGE-0064, EDGE-0141/0149 |
| Model uyumluluğu | COMPATIBILITY FACET | Compatibility narrows a domain-specific accessory; it is not a brand/model category. | Thousands of model-named nodes. | Phone final boundary; EDGE-0038, EDGE-0044 |
| Araç fitment | COMPATIBILITY FACET + ROOT OWNERSHIP RULE | Physical installation to a vehicle can change the primary domain. | Vehicle accessories leak into Electronics/Bags/Phone. | EDGE-0073–0083 |
| Marka | FACET | Brand is not canonical product taxonomy. | Commercial catalog structure replaces neutral taxonomy. | All representative tests |
| Organik | CERTIFICATION/CLAIM FACET | Certification describes production method. | Organic duplicate food/baby branches. | EDGE-0011 |
| Vegan | CLAIM/INGREDIENT FACET | Ingredient/lifestyle claim does not change the physical product. | Cosmetics and food duplicate by lifestyle claim. | Food/cosmetics representative tests |
| Glutensiz | CLAIM/INGREDIENT FACET | Pasta remains pasta; label eligibility is policy. | Health-style duplicate foods. | EDGE-0010 |
| Şekersiz / diyabetik | CLAIM FACET + POLICY | Nutrition claim does not make a medical device/product. | Food leaks into Sağlık. | EDGE-0009 |
| Dermokozmetik | COLLECTION/CLAIM, not automatic category | Retail channel/claim does not itself establish medical intended use. | Cilt bakım products duplicate under Health. | EDGE-0013 |
| Medikal / tedavi iddiası | POLICY + INTENDED-USE RULE | Legal product status can block sale; category must not authorize it. | Unsafe medicine/biosidal leakage. | EDGE-0014–0016, EDGE-0018 |
| Species (kedi, köpek, kuş) | FACET in shared products; CATEGORY where assortment is species-specific | Species-wide L2 proposals are convenient but broad; shared products need one owner. | Duplicate pet shampoo, carriers and grooming tools. | EDGE-0131–0140 |
| Değerli maden / ayar | MATERIAL + POLICY FACET | Gold/silver/karat affects disclosure and price, not basic jewelry form. | Parallel jewelry trees and compliance gaps. | EDGE-0151/0157 |
| Hediye niyeti | COLLECTION/OCCASION | Chocolate, flower, toy, jewelry and mug retain product ownership. | Hediyelik becomes a duplicate marketplace. | EDGE-0150–0156 |
| Kişiselleştirilmiş | FULFILLMENT FACET/COLLECTION | Printing/engraving modifies fulfillment, not product form. | Duplicate mug, shirt, jewelry and stationery nodes. | EDGE-0154/0155 |
| Yenilenmiş / ikinci el | CONDITION FACET + POLICY | Condition does not change smartphone ownership. | Full duplicate taxonomy by condition. | EDGE-0168 |
| Set / bundle | BUNDLE STRUCTURE, not category | Each physical line item needs ownership; the bundle needs a presentation rule. | Multi-owner packages break one-leaf principle. | EDGE-0151/0157 |
| Hobi / başlangıç seviyesi | AUDIENCE/SKILL FACET | Skill level does not alone make product a toy. | Instruments, tools and craft kits leak into Oyuncak. | EDGE-0091–0093, EDGE-0160 |
| Indoor / outdoor | USAGE-ENVIRONMENT FACET | Environment does not replace furniture/lighting/product form. | Garden furniture and lighting duplicate. | EDGE-0144/0146 |
| Reçeteli / dioptri | TECHNICAL FACET + POLICY | Optical power/status applies to lens product variants. | Optics leaks into generic Health. | EDGE-0107–0117 |

## Structural consequences

- Attribute-first navigation may expose facets, but persisted canonical ownership must remain one leaf.
- A facet may trigger policy validation without becoming a category; examples include SPF, medical claims, precious material, battery safety and optical power.
- Domain-specific compatibility can participate in a root ownership rule (phone model, vehicle fitment, instrument fit) while the exact brand/model remains a facet.
- Gift, personalized, featured and seasonal are discovery collections, not permanent ownership branches.

## Validation

- Required signals covered: gender, age, style, occasion, material, compatibility, size, technical rating, dietary claims, sport, species, precious material, professional/consumer, smart/non-smart, gift/personalized.
- Source proposals modified: NO.
- Owner-final rule changed: NO.
- Runtime facet implementation: NO.

`FACET_CONFUSION_AUDIT: PASS`
