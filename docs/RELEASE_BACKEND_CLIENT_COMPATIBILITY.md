# Backend / Client Compatibility

State: PROPOSED — OWNER REVIEW REQUIRED

Mobile clients remain in the wild across versions. Backend evolution should therefore be expand–migrate–contract, with the contract phase delayed until supported clients no longer depend on old behavior.

## Contract rules

- add optional fields before making them required;
- preserve old RPC signatures or introduce versioned successors;
- make clients tolerant of additive response fields and known enum fallback;
- maintain authorization and invariant behavior across versions;
- reject unsafe old-client writes explicitly, not through ambiguous errors;
- test current, previous-supported, and candidate clients against the candidate backend.

Telemetry may inform compatibility but cannot silently redefine policy. Schema migration success alone does not prove client compatibility.

OWNER_DECISION_REQUIRED: define the supported-version window and contract deprecation notice process.
