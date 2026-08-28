# Release Observability Model

**State:** PROPOSED — NO TOOL SELECTED

Every signal should correlate to:

- app/version/build and immutable commit;
- artifact hash/signing identity where available;
- Development or Production environment;
- platform, OS and coarse device class;
- safe request/trace identifier;
- backend migration/schema compatibility marker;
- customer journey and outcome class without unnecessary PII.

## Signal families

Crash/ANR, handled error, startup, auth/session/callback, RPC/RLS failure class, search/nearby latency, cart/review outcome, QR issue/confirm/replay, notification/realtime and migration health are release signals. Test/demo/synthetic traffic is marked at source and excluded from commercial metrics.

Release dashboards compare the candidate with an established baseline and supported older clients. Absence of telemetry is an observability failure, not proof of health. Raw tokens, messages, exact location and sensitive payloads are prohibited.

OWNER_DECISION_REQUIRED: choose minimum V1 telemetry provider, retention and access roles after privacy/cost review.
