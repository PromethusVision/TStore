# Merchant Pilot Operator Boundary

State: `PROPOSED — LEAST PRIVILEGE`

| İşlem | Merchant | Operator | Server | Manuel DB |
|---|---:|---:|---:|---:|
| Auth/session | Kendi hesabı | Hayır | Doğrular | Yasak |
| Shop evidence review | Belge sunar | Case inceler | State uygular | Yasak |
| Owner/capability grant | Talep/kanıt | Karar sürecini yürütür | Yetkili komut + audit | Yasak |
| Basic profile/listing draft | Evet | Assisted hazırlayabilir | Validate/audit | Yasak |
| Price/availability attestation | Evet | Yalnız kayıtlı yardım | Authoritative write | Yasak |
| Catalog candidate approve | Hayır | Catalog reviewer | State machine | Yasak |
| QR scan/confirm | Evet | Hayır | Atomik doğrular | Yasak |
| Verified history correction | Case açar | Evidence/decision | Append-only correction | Yasak |
| Suspension/revoke | Görür/itiraz | Authorized ops | Enforce/audit | Yasak |

## Operatör destek sınırı

Support veriyi açıklayabilir, request'i tekrar deneyebilir ve case'e evidence ekleyebilir. Yetki veremez, RLS aşamaz, doğrulanmış geçmişi keyfi değiştiremez veya merchant adına müşteri deneyimi üretmez.

Tek kişinin pilotta support + verification rolünü üstlenmesi mümkünse her high-risk işlem reason/evidence/before-after ile loglanmalı, düzenli örneklem incelemesi ve geri alma/correction yolu bulunmalıdır. Bu birleşik rol kalıcı yetki tasarımı değildir.

