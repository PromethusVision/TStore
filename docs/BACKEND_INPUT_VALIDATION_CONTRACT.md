# Backend Input Validation Contract

**State:** PROPOSED SERVER CONTRACT

Clients validate for usability; the server validates for authority and integrity.

## Universal checks

- expected type, required/optional/null semantics and exact allowed keys;
- Unicode normalization and whitespace rules without corrupting display text;
- byte/character/item/depth/page/radius/quantity/amount bounds;
- finite decimal/coordinate/time values, explicit units/currency/time zone;
- controlled enum/state/version and no unknown fallback;
- opaque ID syntax followed by authorized existence lookup;
- canonical product/variant/listing/shop relationship;
- URL/path/MIME rules and no active content where images are expected;
- idempotency key scope/length and normalized request hash;
- owner/actor fields derived server-side;
- current lifecycle, capability, revision and policy.

Reject duplicate JSON keys, unexpected free-form metadata for authoritative events,
unsafe wildcard/filter/sort expressions and dynamic SQL identifiers. Error output
identifies a safe field/reason class, not internal constraint/row data. Validation
changes are versioned and backward-compatible or explicitly gated.
