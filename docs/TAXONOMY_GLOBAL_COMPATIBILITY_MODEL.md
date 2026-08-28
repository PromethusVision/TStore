# EsnaftaVar Global Compatibility & Fitment Model

**State:** `PROVISIONAL GLOBAL ARCHITECTURE`  
**Canonical inputs:** owner-final Phone & Accessories and Computer Components
compatibility principles  
**Runtime/configurator:** Not implemented

## Contract

Compatibility answers **what does this product work with?** It is not a category,
search synonym, merchant claim, physical fit label or listing permission. A product
still has exactly one primary canonical leaf.

Only four conceptual results are allowed:

| Result | Meaning | Minimum evidence |
|---|---|---|
| `compatible` | Every applicable hard constraint passed for the declared target and rule version | normalized product/target facts plus authoritative or verified rule |
| `incompatible` | At least one applicable hard constraint explicitly failed | named failing constraint and compared values |
| `conditional` | Compatibility depends on an unresolved/optional condition or adapter | named condition and how to satisfy/verify it |
| `unknown` | Evidence is absent, stale, ambiguous or no rule applies | no negative or positive inference |

Missing data is always `unknown`, never `compatible`.

## Conceptual entities and relationships

| Relationship | Source product | Target entity | Typical constraints | Example domains |
|---|---|---|---|---|
| `PRODUCT ↔ DEVICE_FAMILY` | accessory/supply | governed device family | family, generation, power/interface | phone, camera, appliance |
| `PRODUCT ↔ MODEL` | case, part, filter, consumable | exact model/model family | model ID, revision, market variant | phone, printer, appliance |
| `PRODUCT ↔ VEHICLE` | part/accessory/fluid | vehicle configuration | make/model/year/body/engine/trim | automotive, motorcycle |
| `PRODUCT ↔ SOCKET` | CPU/cooler/RAM ecosystem item | socket/memory platform | socket plus chipset/BIOS/thermal rules | computer components |
| `PRODUCT ↔ INTERFACE` | card/cable/device | interface standard/version | connector, protocol, lanes, direction, power | electronics, computer, music |
| `PRODUCT ↔ ACCESSORY_SYSTEM` | battery, mount, cartridge, seat accessory | governed ecosystem | mechanical key, electrical profile, revision | tools, appliances, baby, audio |

An entity reference has stable conceptual identity separate from display name,
brand label and search alias. Manufacturer compatibility lists and rule versions
remain sourceable; a label rename cannot silently change fitment.

## Evaluation record

A future compatibility decision conceptually records:

- source product/variant identity and target entity identity;
- relation type and direction;
- applicable constraint set and rule version;
- normalized facts used, with source/evidence time;
- result (`compatible`, `incompatible`, `conditional`, `unknown`);
- failed or pending constraints;
- confidence/evidence class and review state;
- effective/expiry dates when manufacturer data changes.

This list is not a DB schema proposal.

## Hard, conditional and advisory constraints

- `HARD`: failure means `incompatible` (wrong socket, physical oversize, voltage
  outside allowed range, explicitly unsupported model).
- `CONDITIONAL`: requires another fact or adapter (firmware/BIOS version, bracket,
  power budget, region-specific revision).
- `ADVISORY`: affects performance or experience, not basic operation (recommended
  wattage, preferred cable length). Advisory failure cannot become incompatible.
- A marketing claim or title token is not a constraint source.

## Domain profiles

### Phone accessories

Exact phone/model compatibility is required for cases, protectors, model-specific
charging accessories, styluses and spare parts. Generic charger/cable/powerbank stays
in the owner-final general power/connection domain and uses protocol, connector,
voltage/current/power constraints. `MagSafe`, `Qi` or a connector name alone does not
prove exact-model compatibility. Spare parts additionally require part/revision,
provenance and safety evidence.

### Computer components

CPU↔motherboard requires exact socket plus chipset/BIOS support; socket match alone
may be `conditional`. RAM uses memory type/form/ECC/support/capacity constraints.
GPU/cards use interface, slot/lane, dimensions, case/bracket and power budget. Cooler
fit considers socket, clearance and thermal requirement. PSU/case/motherboard use
form factor, connectors and dimensions. Missing rule data stays `unknown`.

### Automotive and motorcycle fitment

Use a structured vehicle target: vehicle type, manufacturer, model family, model
year/range, body/chassis, engine/powertrain and market/trim only when materially
required. OEM/MPN equivalence is evidence, not a category. Fluids require governed
specification/approval and system capacity; size resemblance cannot prove fit.
Universal claims remain unverified until explicit constraint scope passes.

### Appliance replacement accessories

Filters, bags, trays, seals and other consumables reference exact model/model family,
part number/revision, dimensions/interface and sometimes installation position.
Matching brand is insufficient. A replacement accessory may remain `conditional`
when a serial-number range or production revision is unknown.

### Tool batteries

Battery↔tool/charger relationships use accessory-system identity, nominal voltage,
electrical/mechanical key, battery chemistry/protocol and generation. Same voltage
does not prove compatibility; visual fit and vendor prose are not authoritative.

### Printer consumables

Cartridge/toner/drum↔printer uses exact model family, consumable role, region/revision,
color/channel and firmware constraints. Yield is a product facet, not compatibility.
`For printer` free text cannot replace model relation.

### Camera accessories

Lens/accessory fit uses mount/system identity, sensor coverage, mechanical clearance,
electronic feature support and adapter conditions. Camera bags remain in the carrying
domain and use dimension/device-family fit rather than camera-category duplication.

### Musical equipment

Audio/instrument accessories use interface direction/type, signal level, impedance,
power/phantom requirements, connector, mounting/thread and instrument dimensions.
`Pedal`, `stand`, `monitor` and `adapter` require domain context. Connector match alone
does not prove safe signal/electrical compatibility.

### Baby products

Compatibility applies to child-restraint vehicle/anchor systems, stroller/car-seat
accessory systems, bottle/pump/storage interfaces and bed accessory fit. Safety
standard, child range and manufacturer instructions are hard gates; a visual or
dimension-only match cannot override safety evidence.

## Compatibility vs physical fit

Physical dimensions are inputs, not the final result. `FIT` describes how a product
sits on a wearer/body; `DIMENSION` measures it; `COMPATIBILITY` evaluates a declared
target using all required constraints. A 15.6-inch bag, 40-mm strap or 18-V battery
can be dimensionally similar yet incompatible.

## Evidence hierarchy

1. applicable standard/authority or manufacturer model/part matrix;
2. verified structured canonical product data;
3. approved technical distributor data with provenance;
4. merchant declaration pending verification;
5. title/search text — discovery only, never sufficient for `compatible`.

Conflicting higher-priority evidence produces review/`unknown` or explicit
`conditional`; it is not resolved by majority vote.

## Search and merchant safeguards

- Compatibility tokens may retrieve candidates but cannot manufacture a positive
  compatibility result.
- Merchant may select known target entities and submit evidence; merchant cannot
  directly set derived result/confidence.
- UI must disclose `conditional` requirement and distinguish `unknown` from
  incompatible.
- Deprecated/merged model aliases resolve to stable target identity with history.
- No broad `works with all` or empty-target fallback is allowed.

## Policy boundary

Compatibility does not prove safety, legal listing eligibility, installation right,
medical suitability, authenticity or warranty. Battery, vehicle-safety, medical,
child-restraint, mains/gas and protected-material products still require policy
metadata/owner review.

## Owner decisions still required

1. authoritative target registries and evidence owners per domain;
2. manufacturer vs distributor vs merchant evidence acceptance;
3. expiry/revalidation cadence and recall handling;
4. threshold for showing inferred/conditional results to customers;
5. liability copy and escalation for safety-critical fitment;
6. future rule-engine/runtime data model.

`COMPATIBILITY_RELATION_TYPES: 6`

`COMPATIBILITY_STATES: 4`

`COMPATIBILITY_MODEL: PASS`

`CONFIGURATOR_IMPLEMENTED: NO`
