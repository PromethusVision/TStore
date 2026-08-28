# Operations Logging Requirements

**State:** PROPOSED — NO LOG PIPELINE CHANGE

## Log events, not sensitive payloads

Log authentication/session lifecycle outcome, authorization denial, privileged operations, case/verification/policy/catalog/moderation transitions, QR state changes, kill-switch/config changes, errors/timeouts, security anomalies, and audit/export access.

## Structured envelope

- trusted timestamp, environment, service/release;
- event type/version and severity;
- anonymous request/trace/correlation ID;
- actor/subject opaque IDs only when required and access-controlled;
- operation/resource class;
- result and safe error/reason code;
- policy/config revision;
- latency/retry/idempotency state;
- case/incident reference for privileged action.

## Never log

Passwords, OTPs, recovery/confirmation links, access/refresh/session tokens, service-role/private keys, raw QR values, signed URLs, full headers/cookies, payment credentials, identity documents, precise location, private chat, review/support free text, or whole request/response payloads. Hashing a low-entropy identifier may still be identifying and requires review.

## Security and integrity

Encode untrusted text to prevent log injection; limit operator access; protect transport/storage; record log pipeline failure; define retention; make clock/source clear; audit searches/exports; prevent ordinary operator alteration. Correlation uses opaque IDs or safe session-derived references, never raw session ID.

[OWASP Logging guidance](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html) identifies administrative, authorization, session, error, and high-risk events while warning against sensitive data in logs.

`LOGGING_IMPLEMENTED: NO`

`RAW_SECRET_LOGGING: PROHIBITED`
