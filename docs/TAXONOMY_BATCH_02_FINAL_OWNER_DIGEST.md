# Taxonomy Batch 02 — Final Owner Digest

**State: CANDIDATE FOR PRODUCT OWNER FINALIZATION**

This digest contains owner-relevant L2 deltas, high-impact L3/L4 choices and open professional gates. It does not make an owner selection or authorize runtime work.

## 1. L2 delta versus prior proposals

| L1 | Old L2 | Candidate L2 | Change |
|---|---:|---:|---|
| Ayakkabı | 8 | 8 | 7 unchanged; 1 rename |
| Çanta & Aksesuar | 10 | 10 | All 10 unchanged |
| Beyaz Eşya & Ev Aletleri | 10 | 10 | All 10 unchanged |
| Anne & Bebek | 9 | 9 | All 9 unchanged |
| Oyuncak & Hobi | 11 | 11 | All 11 unchanged |
| Müzik & Enstrüman | 10 | 10 | All 10 unchanged |
| Spor & Outdoor | 10 | 10 | 9 unchanged; 1 rename |
| Hediyelik & Parti | 9 | 9 | All 9 unchanged |
| **Total** | **77** | **77** | **75 unchanged; 2 renames** |

Proposed renames:

1. `İş & Güvenlik Ayakkabıları → İş & Profesyonel Ayakkabılar` so certified protection-first footwear has one PPE owner while ordinary professional footwear remains discoverable in Ayakkabı.
2. `Balıkçılık & Avcılık → Balıkçılık` so ordinary fishing remains available without silently enabling hunting/weapon-like capability.

Both require Product Owner approval.

## 2. Candidate size

| L1 | L2 | L3 | L4 | Assignable leaf |
|---|---:|---:|---:|---:|
| Ayakkabı | 8 | 38 | 5 | 41 |
| Çanta & Aksesuar | 10 | 45 | 0 | 45 |
| Beyaz Eşya & Ev Aletleri | 10 | 51 | 23 | 66 |
| Anne & Bebek | 9 | 42 | 17 | 53 |
| Oyuncak & Hobi | 11 | 50 | 8 | 55 |
| Müzik & Enstrüman | 10 | 52 | 31 | 72 |
| Spor & Outdoor | 10 | 55 | 34 | 77 |
| Hediyelik & Parti | 9 | 40 | 4 | 42 |
| **Total** | **77** | **373** | **122** | **451** |

Machine candidate: 572 rows, maximum L4, no L5, duplicate path 0, production ID 0.

## 3. High-impact choices by domain

### Ayakkabı

- Technical sport/trekking shoes stay in Ayakkabı; equipment stays in Spor & Outdoor.
- Baby shoes stay in Ayakkabı; baby clothing/care does not leak in.
- Ordinary professional footwear stays here; certified protection-first footwear follows the occupational PPE owner.

### Çanta & Aksesuar

- Standalone baby, instrument, camera and laptop bags stay here.
- Inseparable host-product modules follow the host; integrated hydration/bicycle/safety carriers route to Spor & Outdoor.
- Weapon-carrying products have no normal leaf.

### Beyaz Eşya & Ev Aletleri

- Finished appliances stay here even when connected; smart connectivity is a facet.
- Finished hot-water devices stay here; pipes, valves, wiring and installation labor do not.
- User-changeable filters/attachments are separated from professional internal repair parts.

### Anne & Bebek

- Baby-specific formula/food is proposed here for discovery but remains food/regulatory gated.
- Clothing, footwear, toys, connected monitors and medical devices keep their own L1 owners.
- Child-restraint safety and used-product policy remain professional gates.

### Oyuncak & Hobi

- Preschool toys remain a controlled schema-bearing age exception.
- Toy drone versus camera drone uses primary imaging purpose; toy instrument versus real instrument uses tune/performance capability.
- Consoles remain Elektronik; weapon-like and dangerous products remain fail closed.

### Müzik & Enstrüman

- Traditional Turkish instruments use an exact one-owner registry rather than duplicate structural leaves.
- Production/studio signal-chain equipment is separated from general consumer audio.
- Standalone instrument bags stay in Çanta & Aksesuar.

### Spor & Outdoor

- Technical garments and footwear stay with Giyim/Ayakkabı; equipment stays here.
- Sport-specific hard protection stays here; occupational PPE and medical orthoses do not.
- Ordinary fishing is designed; hunting and weapon-like capability is not silently enabled.

### Hediyelik & Parti

- Gift intent, recipient and personalization never move an ordinary product from its base L1.
- Only intrinsically commemorative/souvenir objects enter `Hatıra & Hediyelik Objeler`.
- Pirotechnics and pressurized gas have no candidate leaf.

## 4. Owner decisions required

1. **Bulk tree decision:** approve all eight exact candidate trees, reject them, or return exact exception paths.
2. **L2 wording/scope:** approve or reject the two proposed renames.
3. **Child domain:** confirm baby-specific food ownership and standalone/integrated baby-bag boundary.
4. **Carrying products:** confirm standalone instrument bags and integrated technical sports carriers.
5. **Local music/toy structure:** confirm the traditional-instrument registry and preschool-toy exception.
6. **Gift identity:** confirm the intrinsic-keepsake test and base-product ownership rule.
7. **Sensitive capability:** confirm the candidate remains fail closed for hunting, weapon-like recreation, pyrotechnics and pressurized party gas.

Suggested answer format: approve the batch, then list only exceptions by exact path. No option is preselected by this document.

## 5. Professional and policy gates that remain open

| Domain | Required review |
|---|---|
| Ayakkabı | PPE/safety claims, child safety, chemicals and medical-orthosis boundary |
| Çanta & Aksesuar | child/small-part safety, material claims and high-risk carriers |
| Beyaz Eşya & Ev Aletleri | electrical, gas, heat, pressure, installation and health claims |
| Anne & Bebek | formula/food, sleep, feeding, child restraint, hygiene and used safety products |
| Oyuncak & Hobi | toy safety, chemistry, radio/flight, reward mechanics and weapon-like products |
| Müzik & Enstrüman | protected materials, electrical/stage and wireless-frequency products |
| Spor & Outdoor | projectile, diving, climbing, water/winter safety, fuel and fishing products |
| Hediyelik & Parti | food contact, flame/choking, IP/personalization and hazardous products |

Professional review is a publication/capability gate, not permission to alter the owner-final L1 list or skip owner approval.

## 6. Bulk-finalization readiness

All eight domains are structurally bulk-reviewable. There are no duplicate paths, no L5, no generated stable IDs and no unresolved structural P0 blocker. The two L2 renames and seven owner decisions are visible rather than silently applied as final.

`READY_FOR_BULK_OWNER_FINALIZATION: YES`

`OWNER_FINALIZATION_PERFORMED: NO`

`RUNTIME_IMPLEMENTATION: NO`
