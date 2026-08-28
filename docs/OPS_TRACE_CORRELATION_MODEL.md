# Request, Case, and Trace Correlation Model

**State:** CONCEPTUAL — NO TRACING INFRASTRUCTURE

## Identifier layers

| ID | Purpose | Lifetime/scope |
|---|---|---|
| REQUEST_ID | One client/API request and retries | short, returned safely to client |
| TRACE_ID | Related internal calls for one operation | short operational window |
| IDEMPOTENCY_KEY | Deduplicate supported mutation | operation-specific; secret-safe |
| EVENT_ID | Immutable domain/audit event | durable where required |
| CASE_ID | Operational review history | durable under retention |
| INCIDENT_ID | Cross-case/system incident | durable under incident policy |
| TRANSACTION_ID | QR/verified purchase identity | canonical domain history |

One ID must not be overloaded for all roles.

## Propagation

Client may generate/request a safe correlation value; server validates/replaces it. Trusted services propagate bounded trace context, while authoritative domain IDs are server-issued. Logs, metrics, cases, and user-safe error responses may reference approved opaque IDs.

## Privacy/security

IDs must be unguessable enough for their purpose but are not authorization. Every lookup rechecks permission. Do not embed user email, phone, merchant name, location, timestamp meaning, or environment secret. Do not expose internal topology. Do not use raw session/token/QR as correlation.

## Operations use

Support can ask for a displayed request ID, then open a minimized case view. Operators link request → safe logs/events → subject only with capability. Incident responders can group events without dumping PII into tickets.

## Failure behavior

Missing trace context does not make an authorized mutation fail, but critical domain/audit events require their own immutable ID. Duplicate/replayed IDs are detected per scope.

`TRACE_INFRASTRUCTURE_CREATED: NO`

`CORRELATION_ID_IS_AUTHORIZATION: NO`
