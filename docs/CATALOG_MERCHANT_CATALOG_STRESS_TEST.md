# Merchant Catalog Stress Test

Status: **SYNTHETIC ARCHITECTURE EVIDENCE — NO MERCHANT OR RUNTIME DATA**
Wave: 16, Work Package 36

The matrix covers 100 synthetic merchants. Every row represents an exact 5–20-listing conceptual catalog; reuse, candidate, barcode, custom, variable-measure and merchant-SKU paths are counted explicitly.

| Merchant | Archetype | L1 mix | Listings | Existing product reuse | Existing variant reuse | New variant candidate | New product candidate | Custom | Barcode / no barcode | Variable measure | Merchant SKU | Result | Finding |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: | --- | --- |
| M-001 | Neighborhood mixed retailer | Gıda & İçecek + Ev & Yaşam | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 0 | 5 | POLICY_REVIEW | Policy-sensitive candidate fails closed |
| M-002 | Specialist packaged retailer | Giyim & Moda + Züccaciye & Mutfak | 12 | 10 | 3 | 1 | 1 | 0 | 6 / 6 | 0 | 12 | PASS | Existing-first flow resolves safely |
| M-003 | Local maker | Ayakkabı + Yapı, Hırdavat & Tesisat | 19 | 16 | 4 | 1 | 2 | 1 | 9 / 10 | 0 | 19 | PASS | Existing-first flow resolves safely |
| M-004 | Fresh/variable-measure shop | Çanta & Aksesuar + Otomotiv & Motosiklet | 10 | 8 | 2 | 1 | 1 | 0 | 5 / 5 | 1 | 10 | PASS | Existing-first flow resolves safely |
| M-005 | Technical parts shop | Elektronik + Kozmetik & Kişisel Bakım | 17 | 14 | 3 | 2 | 1 | 0 | 8 / 9 | 0 | 17 | PASS | Existing-first flow resolves safely |
| M-006 | Neighborhood mixed retailer | Bilgisayar & Tablet + Anne & Bebek | 8 | 6 | 4 | 1 | 1 | 0 | 4 / 4 | 0 | 8 | PASS | Existing-first flow resolves safely |
| M-007 | Specialist packaged retailer | Beyaz Eşya & Ev Aletleri + Oyuncak & Hobi | 15 | 13 | 2 | 1 | 1 | 0 | 7 / 8 | 0 | 15 | PASS | Existing-first flow resolves safely |
| M-008 | Local maker | Ev & Yaşam + Müzik & Enstrüman | 6 | 3 | 3 | 1 | 2 | 1 | 3 / 3 | 0 | 6 | PASS | Existing-first flow resolves safely |
| M-009 | Fresh/variable-measure shop | Züccaciye & Mutfak + Spor & Outdoor | 13 | 10 | 4 | 2 | 1 | 0 | 6 / 7 | 1 | 13 | PASS | Existing-first flow resolves safely |
| M-010 | Technical parts shop | Yapı, Hırdavat & Tesisat + Kitap | 20 | 18 | 2 | 1 | 1 | 0 | 10 / 10 | 0 | 20 | PASS | Existing-first flow resolves safely |
| M-011 | Neighborhood mixed retailer | Otomotiv & Motosiklet + Kırtasiye & Ofis | 11 | 9 | 3 | 1 | 1 | 0 | 5 / 6 | 0 | 11 | PASS | Existing-first flow resolves safely |
| M-012 | Specialist packaged retailer | Kozmetik & Kişisel Bakım + Evcil Hayvan Ürünleri | 18 | 16 | 4 | 1 | 1 | 0 | 9 / 9 | 0 | 18 | PASS | Existing-first flow resolves safely |
| M-013 | Local maker | Anne & Bebek + Gözlük & Optik | 9 | 5 | 2 | 2 | 2 | 1 | 4 / 5 | 0 | 9 | PASS | Existing-first flow resolves safely |
| M-014 | Fresh/variable-measure shop | Oyuncak & Hobi + Saat & Takı | 16 | 14 | 3 | 1 | 1 | 0 | 8 / 8 | 1 | 16 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-015 | Technical parts shop | Müzik & Enstrüman + Sağlık & Medikal | 7 | 5 | 4 | 1 | 1 | 0 | 3 / 4 | 0 | 7 | PASS | Existing-first flow resolves safely |
| M-016 | Neighborhood mixed retailer | Spor & Outdoor + Çiçek & Bahçe | 14 | 12 | 2 | 1 | 1 | 0 | 7 / 7 | 0 | 14 | PASS | Existing-first flow resolves safely |
| M-017 | Specialist packaged retailer | Kitap + Hediyelik & Parti | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 0 | 5 | PASS | Existing-first flow resolves safely |
| M-018 | Local maker | Kırtasiye & Ofis + Gıda & İçecek | 12 | 9 | 4 | 1 | 2 | 1 | 6 / 6 | 0 | 12 | VARIABLE_MEASURE_REVIEW | Sell unit/increment confirmation required |
| M-019 | Fresh/variable-measure shop | Evcil Hayvan Ürünleri + Giyim & Moda | 19 | 17 | 2 | 1 | 1 | 0 | 9 / 10 | 1 | 19 | PASS | Existing-first flow resolves safely |
| M-020 | Technical parts shop | Gözlük & Optik + Ayakkabı | 10 | 8 | 3 | 1 | 1 | 0 | 5 / 5 | 0 | 10 | PASS | Existing-first flow resolves safely |
| M-021 | Neighborhood mixed retailer | Saat & Takı + Çanta & Aksesuar | 17 | 14 | 4 | 2 | 1 | 0 | 8 / 9 | 0 | 17 | PASS | Existing-first flow resolves safely |
| M-022 | Specialist packaged retailer | Sağlık & Medikal + Elektronik | 8 | 6 | 2 | 1 | 1 | 0 | 4 / 4 | 0 | 8 | PASS | Existing-first flow resolves safely |
| M-023 | Local maker | Çiçek & Bahçe + Bilgisayar & Tablet | 15 | 12 | 3 | 1 | 2 | 1 | 7 / 8 | 0 | 15 | PASS | Existing-first flow resolves safely |
| M-024 | Fresh/variable-measure shop | Hediyelik & Parti + Beyaz Eşya & Ev Aletleri | 6 | 4 | 4 | 1 | 1 | 0 | 3 / 3 | 1 | 6 | PASS | Existing-first flow resolves safely |
| M-025 | Technical parts shop | Gıda & İçecek + Ev & Yaşam | 13 | 10 | 2 | 2 | 1 | 0 | 6 / 7 | 0 | 13 | PASS | Existing-first flow resolves safely |
| M-026 | Neighborhood mixed retailer | Giyim & Moda + Züccaciye & Mutfak | 20 | 18 | 3 | 1 | 1 | 0 | 10 / 10 | 0 | 20 | POLICY_REVIEW | Policy-sensitive candidate fails closed |
| M-027 | Specialist packaged retailer | Ayakkabı + Yapı, Hırdavat & Tesisat | 11 | 9 | 4 | 1 | 1 | 0 | 5 / 6 | 0 | 11 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-028 | Local maker | Çanta & Aksesuar + Otomotiv & Motosiklet | 18 | 15 | 2 | 1 | 2 | 1 | 9 / 9 | 0 | 18 | PASS | Existing-first flow resolves safely |
| M-029 | Fresh/variable-measure shop | Elektronik + Kozmetik & Kişisel Bakım | 9 | 6 | 3 | 2 | 1 | 0 | 4 / 5 | 1 | 9 | PASS | Existing-first flow resolves safely |
| M-030 | Technical parts shop | Bilgisayar & Tablet + Anne & Bebek | 16 | 14 | 4 | 1 | 1 | 0 | 8 / 8 | 0 | 16 | PASS | Existing-first flow resolves safely |
| M-031 | Neighborhood mixed retailer | Beyaz Eşya & Ev Aletleri + Oyuncak & Hobi | 7 | 5 | 2 | 1 | 1 | 0 | 3 / 4 | 0 | 7 | PASS | Existing-first flow resolves safely |
| M-032 | Specialist packaged retailer | Ev & Yaşam + Müzik & Enstrüman | 14 | 12 | 3 | 1 | 1 | 0 | 7 / 7 | 0 | 14 | PASS | Existing-first flow resolves safely |
| M-033 | Local maker | Züccaciye & Mutfak + Spor & Outdoor | 5 | 1 | 1 | 2 | 2 | 1 | 2 / 3 | 0 | 5 | PASS | Existing-first flow resolves safely |
| M-034 | Fresh/variable-measure shop | Yapı, Hırdavat & Tesisat + Kitap | 12 | 10 | 2 | 1 | 1 | 0 | 6 / 6 | 1 | 12 | PASS | Existing-first flow resolves safely |
| M-035 | Technical parts shop | Otomotiv & Motosiklet + Kırtasiye & Ofis | 19 | 17 | 3 | 1 | 1 | 0 | 9 / 10 | 0 | 19 | VARIABLE_MEASURE_REVIEW | Sell unit/increment confirmation required |
| M-036 | Neighborhood mixed retailer | Kozmetik & Kişisel Bakım + Evcil Hayvan Ürünleri | 10 | 8 | 4 | 1 | 1 | 0 | 5 / 5 | 0 | 10 | PASS | Existing-first flow resolves safely |
| M-037 | Specialist packaged retailer | Anne & Bebek + Gözlük & Optik | 17 | 14 | 2 | 2 | 1 | 0 | 8 / 9 | 0 | 17 | PASS | Existing-first flow resolves safely |
| M-038 | Local maker | Oyuncak & Hobi + Saat & Takı | 8 | 5 | 3 | 1 | 2 | 1 | 4 / 4 | 0 | 8 | PASS | Existing-first flow resolves safely |
| M-039 | Fresh/variable-measure shop | Müzik & Enstrüman + Sağlık & Medikal | 15 | 13 | 4 | 1 | 1 | 0 | 7 / 8 | 1 | 15 | PASS | Existing-first flow resolves safely |
| M-040 | Technical parts shop | Spor & Outdoor + Çiçek & Bahçe | 6 | 4 | 2 | 1 | 1 | 0 | 3 / 3 | 0 | 6 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-041 | Neighborhood mixed retailer | Kitap + Hediyelik & Parti | 13 | 10 | 3 | 2 | 1 | 0 | 6 / 7 | 0 | 13 | PASS | Existing-first flow resolves safely |
| M-042 | Specialist packaged retailer | Kırtasiye & Ofis + Gıda & İçecek | 20 | 18 | 4 | 1 | 1 | 0 | 10 / 10 | 0 | 20 | PASS | Existing-first flow resolves safely |
| M-043 | Local maker | Evcil Hayvan Ürünleri + Giyim & Moda | 11 | 8 | 2 | 1 | 2 | 1 | 5 / 6 | 0 | 11 | PASS | Existing-first flow resolves safely |
| M-044 | Fresh/variable-measure shop | Gözlük & Optik + Ayakkabı | 18 | 16 | 3 | 1 | 1 | 0 | 9 / 9 | 1 | 18 | PASS | Existing-first flow resolves safely |
| M-045 | Technical parts shop | Saat & Takı + Çanta & Aksesuar | 9 | 6 | 4 | 2 | 1 | 0 | 4 / 5 | 0 | 9 | PASS | Existing-first flow resolves safely |
| M-046 | Neighborhood mixed retailer | Sağlık & Medikal + Elektronik | 16 | 14 | 2 | 1 | 1 | 0 | 8 / 8 | 0 | 16 | PASS | Existing-first flow resolves safely |
| M-047 | Specialist packaged retailer | Çiçek & Bahçe + Bilgisayar & Tablet | 7 | 5 | 3 | 1 | 1 | 0 | 3 / 4 | 0 | 7 | PASS | Existing-first flow resolves safely |
| M-048 | Local maker | Hediyelik & Parti + Beyaz Eşya & Ev Aletleri | 14 | 11 | 4 | 1 | 2 | 1 | 7 / 7 | 0 | 14 | PASS | Existing-first flow resolves safely |
| M-049 | Fresh/variable-measure shop | Gıda & İçecek + Ev & Yaşam | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 1 | 5 | PASS | Existing-first flow resolves safely |
| M-050 | Technical parts shop | Giyim & Moda + Züccaciye & Mutfak | 12 | 10 | 3 | 1 | 1 | 0 | 6 / 6 | 0 | 12 | PASS | Existing-first flow resolves safely |
| M-051 | Neighborhood mixed retailer | Ayakkabı + Yapı, Hırdavat & Tesisat | 19 | 17 | 4 | 1 | 1 | 0 | 9 / 10 | 0 | 19 | POLICY_REVIEW | Policy-sensitive candidate fails closed |
| M-052 | Specialist packaged retailer | Çanta & Aksesuar + Otomotiv & Motosiklet | 10 | 8 | 2 | 1 | 1 | 0 | 5 / 5 | 0 | 10 | VARIABLE_MEASURE_REVIEW | Sell unit/increment confirmation required |
| M-053 | Local maker | Elektronik + Kozmetik & Kişisel Bakım | 17 | 13 | 3 | 2 | 2 | 1 | 8 / 9 | 0 | 17 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-054 | Fresh/variable-measure shop | Bilgisayar & Tablet + Anne & Bebek | 8 | 6 | 4 | 1 | 1 | 0 | 4 / 4 | 1 | 8 | PASS | Existing-first flow resolves safely |
| M-055 | Technical parts shop | Beyaz Eşya & Ev Aletleri + Oyuncak & Hobi | 15 | 13 | 2 | 1 | 1 | 0 | 7 / 8 | 0 | 15 | PASS | Existing-first flow resolves safely |
| M-056 | Neighborhood mixed retailer | Ev & Yaşam + Müzik & Enstrüman | 6 | 4 | 3 | 1 | 1 | 0 | 3 / 3 | 0 | 6 | PASS | Existing-first flow resolves safely |
| M-057 | Specialist packaged retailer | Züccaciye & Mutfak + Spor & Outdoor | 13 | 10 | 4 | 2 | 1 | 0 | 6 / 7 | 0 | 13 | PASS | Existing-first flow resolves safely |
| M-058 | Local maker | Yapı, Hırdavat & Tesisat + Kitap | 20 | 17 | 2 | 1 | 2 | 1 | 10 / 10 | 0 | 20 | PASS | Existing-first flow resolves safely |
| M-059 | Fresh/variable-measure shop | Otomotiv & Motosiklet + Kırtasiye & Ofis | 11 | 9 | 3 | 1 | 1 | 0 | 5 / 6 | 1 | 11 | PASS | Existing-first flow resolves safely |
| M-060 | Technical parts shop | Kozmetik & Kişisel Bakım + Evcil Hayvan Ürünleri | 18 | 16 | 4 | 1 | 1 | 0 | 9 / 9 | 0 | 18 | PASS | Existing-first flow resolves safely |
| M-061 | Neighborhood mixed retailer | Anne & Bebek + Gözlük & Optik | 9 | 6 | 2 | 2 | 1 | 0 | 4 / 5 | 0 | 9 | PASS | Existing-first flow resolves safely |
| M-062 | Specialist packaged retailer | Oyuncak & Hobi + Saat & Takı | 16 | 14 | 3 | 1 | 1 | 0 | 8 / 8 | 0 | 16 | PASS | Existing-first flow resolves safely |
| M-063 | Local maker | Müzik & Enstrüman + Sağlık & Medikal | 7 | 4 | 4 | 1 | 2 | 1 | 3 / 4 | 0 | 7 | PASS | Existing-first flow resolves safely |
| M-064 | Fresh/variable-measure shop | Spor & Outdoor + Çiçek & Bahçe | 14 | 12 | 2 | 1 | 1 | 0 | 7 / 7 | 1 | 14 | PASS | Existing-first flow resolves safely |
| M-065 | Technical parts shop | Kitap + Hediyelik & Parti | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 0 | 5 | PASS | Existing-first flow resolves safely |
| M-066 | Neighborhood mixed retailer | Kırtasiye & Ofis + Gıda & İçecek | 12 | 10 | 4 | 1 | 1 | 0 | 6 / 6 | 0 | 12 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-067 | Specialist packaged retailer | Evcil Hayvan Ürünleri + Giyim & Moda | 19 | 17 | 2 | 1 | 1 | 0 | 9 / 10 | 0 | 19 | PASS | Existing-first flow resolves safely |
| M-068 | Local maker | Gözlük & Optik + Ayakkabı | 10 | 7 | 3 | 1 | 2 | 1 | 5 / 5 | 0 | 10 | PASS | Existing-first flow resolves safely |
| M-069 | Fresh/variable-measure shop | Saat & Takı + Çanta & Aksesuar | 17 | 14 | 4 | 2 | 1 | 0 | 8 / 9 | 1 | 17 | VARIABLE_MEASURE_REVIEW | Sell unit/increment confirmation required |
| M-070 | Technical parts shop | Sağlık & Medikal + Elektronik | 8 | 6 | 2 | 1 | 1 | 0 | 4 / 4 | 0 | 8 | PASS | Existing-first flow resolves safely |
| M-071 | Neighborhood mixed retailer | Çiçek & Bahçe + Bilgisayar & Tablet | 15 | 13 | 3 | 1 | 1 | 0 | 7 / 8 | 0 | 15 | PASS | Existing-first flow resolves safely |
| M-072 | Specialist packaged retailer | Hediyelik & Parti + Beyaz Eşya & Ev Aletleri | 6 | 4 | 4 | 1 | 1 | 0 | 3 / 3 | 0 | 6 | PASS | Existing-first flow resolves safely |
| M-073 | Local maker | Gıda & İçecek + Ev & Yaşam | 13 | 9 | 2 | 2 | 2 | 1 | 6 / 7 | 0 | 13 | PASS | Existing-first flow resolves safely |
| M-074 | Fresh/variable-measure shop | Giyim & Moda + Züccaciye & Mutfak | 20 | 18 | 3 | 1 | 1 | 0 | 10 / 10 | 1 | 20 | PASS | Existing-first flow resolves safely |
| M-075 | Technical parts shop | Ayakkabı + Yapı, Hırdavat & Tesisat | 11 | 9 | 4 | 1 | 1 | 0 | 5 / 6 | 0 | 11 | PASS | Existing-first flow resolves safely |
| M-076 | Neighborhood mixed retailer | Çanta & Aksesuar + Otomotiv & Motosiklet | 18 | 16 | 2 | 1 | 1 | 0 | 9 / 9 | 0 | 18 | POLICY_REVIEW | Policy-sensitive candidate fails closed |
| M-077 | Specialist packaged retailer | Elektronik + Kozmetik & Kişisel Bakım | 9 | 6 | 3 | 2 | 1 | 0 | 4 / 5 | 0 | 9 | PASS | Existing-first flow resolves safely |
| M-078 | Local maker | Bilgisayar & Tablet + Anne & Bebek | 16 | 13 | 4 | 1 | 2 | 1 | 8 / 8 | 0 | 16 | PASS | Existing-first flow resolves safely |
| M-079 | Fresh/variable-measure shop | Beyaz Eşya & Ev Aletleri + Oyuncak & Hobi | 7 | 5 | 2 | 1 | 1 | 0 | 3 / 4 | 1 | 7 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-080 | Technical parts shop | Ev & Yaşam + Müzik & Enstrüman | 14 | 12 | 3 | 1 | 1 | 0 | 7 / 7 | 0 | 14 | PASS | Existing-first flow resolves safely |
| M-081 | Neighborhood mixed retailer | Züccaciye & Mutfak + Spor & Outdoor | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 0 | 5 | PASS | Existing-first flow resolves safely |
| M-082 | Specialist packaged retailer | Yapı, Hırdavat & Tesisat + Kitap | 12 | 10 | 2 | 1 | 1 | 0 | 6 / 6 | 0 | 12 | PASS | Existing-first flow resolves safely |
| M-083 | Local maker | Otomotiv & Motosiklet + Kırtasiye & Ofis | 19 | 16 | 3 | 1 | 2 | 1 | 9 / 10 | 0 | 19 | PASS | Existing-first flow resolves safely |
| M-084 | Fresh/variable-measure shop | Kozmetik & Kişisel Bakım + Evcil Hayvan Ürünleri | 10 | 8 | 4 | 1 | 1 | 0 | 5 / 5 | 1 | 10 | PASS | Existing-first flow resolves safely |
| M-085 | Technical parts shop | Anne & Bebek + Gözlük & Optik | 17 | 14 | 2 | 2 | 1 | 0 | 8 / 9 | 0 | 17 | PASS | Existing-first flow resolves safely |
| M-086 | Neighborhood mixed retailer | Oyuncak & Hobi + Saat & Takı | 8 | 6 | 3 | 1 | 1 | 0 | 4 / 4 | 0 | 8 | VARIABLE_MEASURE_REVIEW | Sell unit/increment confirmation required |
| M-087 | Specialist packaged retailer | Müzik & Enstrüman + Sağlık & Medikal | 15 | 13 | 4 | 1 | 1 | 0 | 7 / 8 | 0 | 15 | PASS | Existing-first flow resolves safely |
| M-088 | Local maker | Spor & Outdoor + Çiçek & Bahçe | 6 | 3 | 2 | 1 | 2 | 1 | 3 / 3 | 0 | 6 | PASS | Existing-first flow resolves safely |
| M-089 | Fresh/variable-measure shop | Kitap + Hediyelik & Parti | 13 | 10 | 3 | 2 | 1 | 0 | 6 / 7 | 1 | 13 | PASS | Existing-first flow resolves safely |
| M-090 | Technical parts shop | Kırtasiye & Ofis + Gıda & İçecek | 20 | 18 | 4 | 1 | 1 | 0 | 10 / 10 | 0 | 20 | PASS | Existing-first flow resolves safely |
| M-091 | Neighborhood mixed retailer | Evcil Hayvan Ürünleri + Giyim & Moda | 11 | 9 | 2 | 1 | 1 | 0 | 5 / 6 | 0 | 11 | PASS | Existing-first flow resolves safely |
| M-092 | Specialist packaged retailer | Gözlük & Optik + Ayakkabı | 18 | 16 | 3 | 1 | 1 | 0 | 9 / 9 | 0 | 18 | DUPLICATE_REVIEW | Generic title and missing identifier need review |
| M-093 | Local maker | Saat & Takı + Çanta & Aksesuar | 9 | 5 | 4 | 2 | 2 | 1 | 4 / 5 | 0 | 9 | PASS | Existing-first flow resolves safely |
| M-094 | Fresh/variable-measure shop | Sağlık & Medikal + Elektronik | 16 | 14 | 2 | 1 | 1 | 0 | 8 / 8 | 1 | 16 | PASS | Existing-first flow resolves safely |
| M-095 | Technical parts shop | Çiçek & Bahçe + Bilgisayar & Tablet | 7 | 5 | 3 | 1 | 1 | 0 | 3 / 4 | 0 | 7 | PASS | Existing-first flow resolves safely |
| M-096 | Neighborhood mixed retailer | Hediyelik & Parti + Beyaz Eşya & Ev Aletleri | 14 | 12 | 4 | 1 | 1 | 0 | 7 / 7 | 0 | 14 | PASS | Existing-first flow resolves safely |
| M-097 | Specialist packaged retailer | Gıda & İçecek + Ev & Yaşam | 5 | 2 | 2 | 2 | 1 | 0 | 2 / 3 | 0 | 5 | PASS | Existing-first flow resolves safely |
| M-098 | Local maker | Giyim & Moda + Züccaciye & Mutfak | 12 | 9 | 3 | 1 | 2 | 1 | 6 / 6 | 0 | 12 | PASS | Existing-first flow resolves safely |
| M-099 | Fresh/variable-measure shop | Ayakkabı + Yapı, Hırdavat & Tesisat | 19 | 17 | 4 | 1 | 1 | 0 | 9 / 10 | 1 | 19 | PASS | Existing-first flow resolves safely |
| M-100 | Technical parts shop | Çanta & Aksesuar + Otomotiv & Motosiklet | 10 | 8 | 2 | 1 | 1 | 0 | 5 / 5 | 0 | 10 | PASS | Existing-first flow resolves safely |

## Reconciliation

- Merchants: **100**.
- Conceptual listings: **1246**; minimum **5**, maximum **20** per merchant.
- Every listing receives a merchant-scoped SKU; it is never treated as globally unique.
- Result counts: `POLICY_REVIEW` 4, `PASS` 84, `DUPLICATE_REVIEW` 7, `VARIABLE_MEASURE_REVIEW` 5.
- Review outcomes are intentional safety gates, not missing rows or runtime failures.
