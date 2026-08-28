# Backend Idempotency Architecture

**State:** PROPOSED GLOBAL CONTRACT

Idempotency identifies one logical mutation within caller/tenant/resource/operation
scope. It does not replace authorization, optimistic revision or entity uniqueness.

## Stored outcome concept

Store key fingerprint, normalized request hash, subject/scope, operation version,
status, committed result reference and retention. Same key/same payload returns the
original terminal result. Same key/different payload rejects conflict and audits.

## Required domains

- QR issue/confirm and purchase creation;
- listing create/revision/import;
- membership invite/grant/revoke;
- review mutation;
- product candidate/merge/split;
- future campaign financial operations;
- reward ledger and reputation evidence ingestion;
- event consumers with at-least-once delivery.

Authorization is rechecked on retry before new work. A revoked caller may receive
a safe acknowledgement of an already committed outcome without gaining its
private payload. Irreversible ledger uniqueness survives arbitrary transport
retry; expiry of a convenience key cannot permit duplication.
