# Structured Shop Evaluation Dimensions

**State:** CANDIDATE SET — OWNER REVIEW REQUIRED

## Design boundary

Questions describe the exact shop interaction, not product quality. Responses use a labeled 1–5
scale, allow `Yanıtlamak istemiyorum` and `Uygun değil`, and never default to a midpoint.

| Candidate | Customer wording hypothesis | Includes | Excludes | V1 candidate |
|---|---|---|---|---|
| Friendliness | `Esnafın yaklaşımı nasıldı?` | respectful, welcoming interaction | product quality, shop decor | Yes |
| Helpfulness | `İhtiyacınız olduğunda yardımcı oldu mu?` | useful assistance and effort | guaranteed resolution, speed alone | Yes |
| Product-information accuracy | `Ürün hakkında verilen bilgi ne kadar doğru ve açıktı?` | merchant communication known at interaction | later-discovered product defect; medical/legal truth | Yes, with N/A |
| Overall shop experience | `Genel mağaza deneyiminizi nasıl değerlendirirsiniz?` | holistic shop interaction | product stars; platform guarantee | 4-question variant |
| Speed/ease | `İşleminiz ne kadar kolay ilerledi?` | queue/checkout ease | payment proof, delivery speed | Later candidate |
| Product as described | — | — | belongs to product/listing-truth review and moderation | Reject as merchant dimension |

## Scale anchors

Use semantic endpoints and a midpoint, not bare numbers: `Çok kötü`, `Kötü`, `Orta`, `İyi`,
`Çok iyi`. Dimension-specific microcopy may clarify intent without changing scale meaning.

## Separation and edge cases

- A low product rating and high shop responses are valid in one submission.
- Self-service or minimal-contact purchases may skip friendliness/helpfulness as not applicable.
- A customer complaint about a prohibited product is policy evidence, not a low dimension value.
- Merchant sector must not silently change the meaning or weight of a common dimension.
- Free text remains product-scoped; structured values cannot be reconstructed from sentiment.

## Candidate primary badge mapping

Friendliness may support `Güler Yüzlü Esnaf`; helpfulness may support `Yardımsever Esnaf`; accurate
product information may support `Ürün Bilgisi Güçlü`. Names, thresholds and public launch remain
unapproved. Overall experience is a cross-check, not a prerequisite badge by itself.

`CANDIDATE_DIMENSIONS: 4`
`PRODUCT_AS_DESCRIBED_MERCHANT_DIMENSION: NO`
