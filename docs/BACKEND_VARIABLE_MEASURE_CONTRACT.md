# Backend Variable Measure Contract

**State:** PROPOSED — NO MEASUREMENT/PAYMENT IMPLEMENTATION

Variable-measure products may be sold by kilogram, gram, litre, millilitre, metre
or another approved unit. Canonical product describes the product; listing owns
sell unit, price basis, minimum and increment.

## Rules

- unit is a controlled identifier, not localized free text;
- quantity uses sufficient decimal precision and positive bounded values;
- price records basis (`per kg`, `per metre`, etc.);
- cart validates minimum/increment but remains an intent, not final weighing;
- verified purchase item snapshots actual confirmed quantity, unit, unit price and
  line amount;
- conversion/rounding rule is versioned and deterministic;
- quantity does not multiply review rights.

Supported units, scale/rounding and whether QR confirmation may correct the final
quantity are `OWNER_DECISION_REQUIRED`.

