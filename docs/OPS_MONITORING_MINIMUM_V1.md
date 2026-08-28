# Minimum V1 Monitoring

**State:** PROPOSED LEAN BASELINE — TOOLING NOT SELECTED

## Must-have pilot views

1. **Availability:** startup/config, Auth, core RPC, Storage and Realtime dependencies.
2. **Customer critical journeys:** login/session, discovery reads, cart mutation, QR create, review eligibility.
3. **Merchant critical journeys:** authorization, listing write/freshness, QR confirm.
4. **Security:** Auth/authorization failures, privileged actions, break-glass, rate/abuse anomalies.
5. **Data integrity:** QR idempotency, review duplicate contract, catalog/listing conflict, audit/event pipeline gaps.
6. **Operations:** P0/P1 open/age, verification/policy/QR queues, appeal/reopen and kill-switch state.
7. **Release:** version adoption, crash-free health, new error signatures, rollback indicator.

## Lean implementation principle

Start with existing provider/runtime logs, application-safe structured events, a small health dashboard, and a short actionable alert set. Do not buy enterprise SIEM/APM/ticketing solely because it is common. Add tools only when requirements exceed safe existing capabilities and vendor privacy/cost/export controls are accepted.

## Required metadata

Trusted timestamp, environment, release, operation, safe error class, anonymous request/trace correlation, feature-switch state, and source. Exclude tokens, secrets, passwords, raw QR, messages, precise location, documents, and review text.

## Operating rhythm

Daily pilot health review, release-window observation, weekly queue/false-positive review, and explicit P0/P1 on-call ownership are candidates—not contractual promises. Missing telemetry itself is visible.

## Exit criteria

Every critical failure has an owner, safe customer behavior, case/incident route, and reproducible evidence. Dashboards without action are deferred.

`MINIMUM_MONITORING_FINAL: NO`

`ENTERPRISE_TOOL_REQUIRED: NO`
