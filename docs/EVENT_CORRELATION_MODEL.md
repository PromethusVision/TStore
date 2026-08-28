# EsnaftaVar Event Correlation Model

**State:** `PROPOSED`

| Identifier | Scope | Example |
|---|---|---|
| `correlation_id` | One bounded workflow/journey | QR issue→scan→validation→purchase |
| `request_id` | One API/RPC request | Merchant confirmation request |
| `trace_id` | Optional diagnostic request chain | Client→edge→database, if tooling supports it |
| `idempotency_key` | Logical command outcome | Repeated QR confirm |
| `transaction_id` | Durable business transaction | Verified purchase |
| `case_id` / `incident_id` | Operations/security investigation | Abuse review or outage |

Campaign interaction may carry an ad-interaction correlation, but attribution uses
a separately versioned candidate record. Support cases reference evidence/event
IDs rather than copying private payloads.

IDs are opaque, non-secret and unguessable enough for their exposure. A correlation
does not prove causality or shared identity. Do not reuse a customer ID, token, QR
value, email or session credential as correlation. Correlation retention and
visibility follow the most restrictive linked privacy class.

`CORRELATION_EQUALS_CAUSATION: NO`

