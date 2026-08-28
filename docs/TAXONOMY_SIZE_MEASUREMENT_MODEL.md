# EsnaftaVar Size & Measurement Model

**State:** `PROVISIONAL ARCHITECTURE — NO RUNTIME MODEL`  
**Purpose:** Prevent one generic `size` field from mixing labels, physical measures,
capacity and compatibility.

## Measurement kinds

| Kind | Answers | Representation | Example | Must not be confused with |
|---|---|---|---|---|
| `SIZE_LABEL` | Which governed size label/system? | value + system + audience/profile | `EU 42`, `M`, `3–6 ay` | measured body/product dimension |
| `DIMENSION` | What are named physical axes? | axis/value/unit/context tuple | width 60 cm, height 80 cm | packaging dimension, screen diagonal |
| `CAPACITY` | How much can it hold/process/store? | value + domain unit + basis | 128 GB, 7 kg wash load | product weight or liquid amount |
| `WEIGHT` | What is its mass? | numeric mass + net/gross context | net 750 g | weight class or load capacity |
| `VOLUME` | What liquid volume is supplied/held? | numeric metric volume | 500 ml | cubic external dimensions |
| `DIAMETER` | What circle/cylinder measure? | numeric length + measurement point | pan 28 cm, case 40 mm | ring size label |
| `LENGTH` | What single linear measure? | numeric length + context | cable 2 m, chain 45 cm | 3-axis dimensions |
| `FIT` | How is intended fit described? | controlled enum + profile | slim, regular, wide | compatibility result |
| `COMPATIBILITY` | Does it work/fit with an entity/system? | versioned relation + result | filter compatible with model X | equal dimensions alone |

## General measurement record

A future implementation should conceptually retain:

- facet concept ID and measurement kind;
- decimal value or lower/upper bounds;
- unit and unit-family ID;
- axis/measurement point (width, bridge, inner diameter, folded length, etc.);
- object context (product, package, usable interior, display diagonal);
- size-system/table version when a label or conversion is used;
- source, confidence, approximation flag and normalized/display values.

This is an architecture requirement, not a proposed Production table.

## Domain audit

### Clothing size

- `SIZE_LABEL`: XXS–..., numeric local/EU labels; system and target profile required.
- `DIMENSION`: chest, waist, hip, inseam, garment length with body-vs-garment context.
- `FIT`: slim/regular/relaxed/oversize/petite/tall.
- A display conversion table is advisory; label equality is never inferred across
  brands without an explicit chart/source.

### Shoe size

- `SIZE_LABEL`: EU/UK/US/CM system and audience; `EU 42` is not bare `42`.
- `DIMENSION`: foot length, internal length and width are different measurement points.
- `FIT`: narrow/regular/wide and last/shape where governed.
- Approximate system conversion must carry table version and must not assert fit.

### Baby size

- Apparel label, age range, child length, weight range and product dimensions are
  separate facts. `3–6 ay` does not guarantee fit from age alone.
- Child-restraint and carrier products use verified height/weight/age operating
  ranges and safety standards; those are not apparel sizes.

### Ring size

- `SIZE_LABEL`: declared TR/EU/US system.
- `DIAMETER` and circumference: exact measured physical alternatives with method.
- Conversion requires a governed table and rounding disclosure. Stone/carat and band
  width are not ring size.

### Watch case size

- Case diameter, thickness, lug width and strap length are independent dimensions.
- Strap compatibility needs lug/interface relation, not diameter equality.
- `40 mm` must name its measurement point; `men/women` is not size.

### Optical frame dimensions

- Lens width, bridge width, temple length, frame width and lens height use named axes.
- Contact-lens base curve/diameter and prescription measurements are typed medical
  attributes, not frame size labels.
- Pupillary distance is sensitive prescription/fit data; taxonomy design does not
  authorize collection or storage.

### Furniture dimensions

- Product assembled dimensions, folded dimensions, package dimensions, seat height,
  usable internal dimensions and load capacity are distinct.
- Axis order is explicit. `200×160` cannot be assumed width×length without profile.
- Doorway/room fit is a future compatibility calculation; it must not round measures
  to make a pass.

### Appliance dimensions

- Product, required installation niche, clearance and package dimensions are distinct.
- Capacity (litres, place settings, wash kg) is not a physical dimension.
- Built-in/solo/under-counter is installation type; actual fit uses tolerances and
  installation instructions.

### Screen size

- Display diagonal is `SCREEN_SIZE`, conventionally shown in inches and optionally
  metric; panel width/height are physical dimensions.
- Resolution, aspect ratio, bezel and mounting standard are separate.
- Diagonal alone never proves stand/wall-mount/accessory compatibility.

### Storage capacity

- Digital `GB/TB` capacity is not liquid/general capacity and not memory (RAM).
- Declared decimal and binary representations must not silently switch.
- Usable capacity may differ from marketed capacity and requires explicit context.

### Liquid volume and food weight

- Net quantity uses mass or volume as printed; drained weight, multipack total and
  per-piece amount remain explicit.
- A density-based conversion between volume and weight is forbidden unless product-
  specific, sourced and needed; it is never a generic normalization rule.
- Random-weight goods need unit-of-sale/listing price contract outside taxonomy.

### Tool dimensions

- Tool overall size, blade/disc diameter, shank size, drive size, chuck capacity,
  fastener/thread size and working range are different facets.
- Compatibility uses exact standard/interface/platform plus dimensions; similar
  nominal size is insufficient.

## Ranges, tolerances and precision

- Store declared precision; do not add false decimals.
- Range endpoints, inclusivity and `approximate` state are explicit.
- Manufacturing tolerance is separate from display rounding.
- Compatibility calculations use unrounded normalized values and applicable
  tolerances; filter display may use readable scaled units.
- Unitless values are rejected when the profile requires a unit.

## Unknown and not applicable

`UNKNOWN` means the measurement applies but is not known. `NOT_APPLICABLE` means the
profile excludes it. Neither becomes zero. A missing dimension or size never produces
`compatible`; the compatibility result remains `unknown`.

## Category/facet guardrail

`Büyük beden`, `42 numara`, `15,6 inç`, `128 GB`, `1 litre`, `28 cm`, `ATX`,
`205/55 R16` and `3–6 ay` are never automatically category nodes. A separately
approved product-type distinction may still coexist with these typed measurements.

## Owner decisions still required

1. authoritative conversion-table owners and revision policy;
2. which leaf profiles make body/customer measurements mandatory or prohibited;
3. acceptable precision/tolerance sources for fit-critical domains;
4. display conventions for storage capacity and non-SI trade measurements;
5. privacy boundary for prescription/body measurements.

`SIZE_MEASUREMENT_KINDS: 9`

`GENERIC_SIZE_FIELD: FORBIDDEN`

`MISSING_VALUE_IMPLIES_COMPATIBLE: NO`
