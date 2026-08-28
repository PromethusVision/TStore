# Fuzz Test Review

**State:** PROPOSED — DEFENSIVE ONLY

## Candidate parsers and boundaries

- custom/universal deep-link URIs and query parameters;
- QR payload/token parsing before server verification;
- Turkish/Unicode search text and normalization;
- form, barcode, pagination and numeric boundary validation;
- JSON/RPC serialization with missing, extra, wrong-type and oversized values.

Assert bounded runtime/memory, no crash, no token/PII logging, deterministic rejection and no authorization bypass. Preserve minimized seeds as regression fixtures.

Run locally or in isolated CI against pure parsers/fakes. No offensive live fuzzing, remote load, brute force or Production targeting is authorized.

Recommendation: small parser-focused fuzz/property suites later; physical and server contract gates have higher pilot priority.

OWNER_DECISION_REQUIRED: none unless external security tooling/budget is proposed.
