# Production Health Signal Model

**State:** PROPOSED — NO MONITORING INSTALLATION

## Signal families

| Family | Minimum signals | Avoid |
|---|---|---|
| AUTH | signup/login/refresh/callback/recovery error rate, latency, enumeration-safe outcome | emails, tokens, passwords |
| RPC/API | success/error/timeout by safe operation class and release | raw payload/PII |
| QR | create/confirm/pass/replay/wrong-shop/expiry/concurrency/latency | raw QR secret |
| REALTIME | connect/reconnect/channel errors, lag, duplicate suppression | message bodies |
| STORAGE | authorized resolve/upload/read failures, unsafe-path rejection | signed URLs/credentials |
| CRASH | crash-free sessions, fatal signature, release/device class | user text/location |
| LATENCY | p50/p95/p99 by core journey, timeout/fallback | high-cardinality user labels |
| CATALOG | candidate/listing write conflict/failure/freshness/queue age | merchant content copied to alerts |
| REVIEWS | eligibility/create/update/report errors | review text in metrics |
| ADS/REWARDS | only when enabled: eligibility/fallback/ledger integrity | nonexistent feature success metrics |
| OPERATIONS | queue age, P0/P1 volume, reopen/false-positive/appeal | operator productivity ranking |

## Health versus business metrics

Health answers whether authorized systems work correctly. Product/business conversion does not page operators by itself. A low QR count may be traffic; a high QR RPC failure rate is health.

## Slicing

Environment, release, operation, safe error class, feature state, region/coarse service boundary, and anonymous correlation. No customer/merchant ID as metric label.

## Integrity

Define source, denominator, freshness, missing-data state, owner, and threshold hypothesis. “No data” is not automatically healthy. Client telemetry cannot override server truth.

`PRODUCTION_MONITORING_IMPLEMENTED: NO`

`SENSITIVE_METRIC_LABELS_ALLOWED: NO`
