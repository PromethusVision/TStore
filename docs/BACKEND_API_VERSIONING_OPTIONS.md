# Backend API Versioning Options

**State:** PROPOSED — VERSION SEMANTICS, NOT EVERYTHING

## Options

1. **Additive evolution in current contract — preferred default:** optional response
   fields, preserved meanings and server-derived safe defaults.
2. **Versioned RPC/function:** use when required input, authorization, transaction,
   response meaning or error behavior materially changes.
3. **Capability/revision parameter:** use for optional feature negotiation and
   optimistic concurrency, not as hidden endpoint versioning.
4. **Parallel API namespace:** reserve for broad incompatible platform boundary;
   high operational and retirement cost.

Schema migration version, policy version, event version, entity revision and app
release are distinct. Never use a client-supplied older version to bypass current
security/policy. Define supported overlap, deprecation telemetry, removal criteria
and unsupported-client error before introducing a new version.

QR/review current RPCs should evolve additively where possible; merchant organization
and variant commands may justify new versioned surfaces. Exact version set is a
technical design decision following caller inventory.

