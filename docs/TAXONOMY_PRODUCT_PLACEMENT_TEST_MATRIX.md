# Global Taxonomy Representative Product Placement Matrix — Summary

## Status

**STRESS-TEST EVIDENCE — NO OWNER FINALIZATION / NO RUNTIME**

The machine-reviewable evidence is `TAXONOMY_PRODUCT_PLACEMENT_TEST_MATRIX.csv`.

## Coverage

| Metric | Actual | Required | Result |
|---|---:|---:|---|
| Proposed L1 tested | 22 | 22 | PASS |
| Proposed L2 tested | 224 | 224 | PASS |
| Representative physical scenarios | 672 | >=672 | PASS |
| Scenarios per L2 | 3 | >=3 | PASS |
| Unique TEST_ID | 672 | 672 | PASS |

## Result distribution

| Result | Count | Meaning in this phase |
|---|---:|---|
| CLEAR | 475 | Unambiguous proposed L1/L2 placement. |
| AMBIGUOUS | 0 | Recorded for downstream edge/root audit. |
| MISSING_HOME | 0 | Recorded for downstream edge/root audit. |
| FACET_CONFUSION | 0 | Recorded for downstream edge/root audit. |
| SERVICE_LEAKAGE | 0 | Recorded for downstream edge/root audit. |
| POLICY_BLOCKED | 0 | Recorded for downstream edge/root audit. |
| NEEDS_FUTURE_L3_L4 | 197 | Recorded for downstream edge/root audit. |

`NEEDS_FUTURE_L3_L4` does not reject the proposed L2. It records that the broad L2 is a likely container and a later owner-reviewed leaf is needed before final assignment.

## Per-L1 coverage

| L1 | L2 | Scenarios | Clear | Future L3/L4 needed |
|---|---:|---:|---:|---:|
| Gıda & İçecek | 14 | 42 | 30 | 12 |
| Giyim & Moda | 10 | 30 | 20 | 10 |
| Ev & Yaşam | 10 | 30 | 22 | 8 |
| Züccaciye & Mutfak | 11 | 33 | 22 | 11 |
| Yapı, Hırdavat & Tesisat | 14 | 42 | 28 | 14 |
| Kozmetik & Kişisel Bakım | 11 | 33 | 24 | 9 |
| Ayakkabı | 8 | 24 | 16 | 8 |
| Çanta & Aksesuar | 10 | 30 | 21 | 9 |
| Beyaz Eşya & Ev Aletleri | 10 | 30 | 20 | 10 |
| Anne & Bebek | 9 | 27 | 18 | 9 |
| Oyuncak & Hobi | 11 | 33 | 22 | 11 |
| Müzik & Enstrüman | 10 | 30 | 23 | 7 |
| Spor & Outdoor | 10 | 30 | 23 | 7 |
| Hediyelik & Parti | 9 | 27 | 19 | 8 |
| Otomotiv & Motosiklet | 11 | 33 | 22 | 11 |
| Kitap | 10 | 30 | 20 | 10 |
| Çiçek & Bahçe | 11 | 33 | 26 | 7 |
| Sağlık & Medikal | 9 | 27 | 18 | 9 |
| Gözlük & Optik | 7 | 21 | 19 | 2 |
| Evcil Hayvan Ürünleri | 7 | 21 | 14 | 7 |
| Kırtasiye & Ofis | 11 | 33 | 22 | 11 |
| Saat & Takı | 11 | 33 | 26 | 7 |

## Interpretation

- Phase 2 deliberately uses representative, non-brand physical product families.
- Known cross-domain hard cases are not hidden here; they are expanded in the separate 150+ edge-case matrix.
- A `CLEAR` result validates proposed L1/L2 direction, not owner-final taxonomy status.
- Facets and policy flags remain separate from category ownership.
- Existing owner-final Electronics/Computer and two pilot L3/L4 contracts are used as boundary references, never rewritten.

## Validation

- CSV parse: PASS.
- Required columns: 11/11 PASS.
- TEST_ID duplicate: 0.
- Missing L2 coverage: 0.
- Brand/model-as-category: 0.
- Source proposal mutation: NO.
- Owner finalization: NO.

`REPRESENTATIVE_PRODUCT_COVERAGE: PASS`

`REPRESENTATIVE_SCENARIOS: 672`

`PROPOSED_L2_TESTED: 224/224`
