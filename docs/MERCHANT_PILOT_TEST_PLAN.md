# Merchant Pilot Test Plan

State: `PROPOSED — NO TEST EXECUTION IN THIS WAVE`

## Automated layers

1. Pure unit: state transitions, price/availability validation, stale revision, safe error mapping.
2. Cubit/view model: duplicate tap, in-flight operation, user/shop switch, background/resume, reconciliation.
3. Widget: login/empty/error/action states, listing edit, scanner permission, preview/confirm, history/support.
4. Repository/contract: exact request/response DTO, idempotency, safe logging.
5. Backend Development: RLS roles, RPC invariants, policy state, candidate lifecycle, append-only audit.
6. Concurrency: two real independent sessions confirm same QR; exactly one side effect.
7. Client/backend N/N-1 contract: old Customer App remains compatible during additive rollout.

## Critical negative matrix

- anon/customer/wrong merchant/wrong shop/suspended merchant.
- revoked membership during in-flight operation.
- negative/NaN/overflow price, stale revision, unknown availability.
- candidate auto-publish attempt, cross-shop listing ID, catalog policy hold.
- malformed/expired/used/wrong-shop QR; rapid double tap; replay; two concurrent confirms.
- network timeout after server success and after server failure.
- auth user switch, process kill, background/resume and permission denied forever.
- operator password request, manual DB shortcut and PII leakage in logs/errors.

## Release gates

- Analyzer/unit/widget/contract suites PASS.
- Development RLS/RPC/concurrency PASS.
- Clean install/upgrade and exact signed Android artifact smoke PASS.
- Two-device physical QR matrix PASS.
- Real GPS is Customer App gate; merchant camera/network/background are merchant gates.
- Production smoke is read/minimal authorized journey only and cannot replace Development tests.

Stress CSVs are conceptual coverage inventory; their `RESULT` remains `NOT_RUN` and must not be reported as executed runtime tests.
