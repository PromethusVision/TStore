# QR Release Acceptance

State: PROPOSED — OWNER REVIEW REQUIRED

QR verified purchase is server-authoritative and requires layered evidence.

## Release gates

- unit/client state and error handling;
- RPC authorization, immutable price snapshot, idempotency, and transaction invariants;
- real concurrent merchant confirmations;
- replay, wrong merchant, customer confirmation, expiry, and user-switch rejection;
- two independent customer/merchant sessions;
- two physical devices using the exact signed artifact and real camera;
- lifecycle, poor network, duplicate tap, and safe recovery.

Fixtures are uniquely prefixed, synthetic, Development-only, and cleaned. A mocked camera or single-process live harness cannot satisfy the two-device gate. Production smoke must not create destructive or misleading commerce history.

Current physical two-device acceptance remains OPEN and must not be marked PASS from repository evidence.

OWNER_DECISION_REQUIRED: assign physical devices/testers and authorized Development fixture window.
