# Backend Client Backward Compatibility

**State:** PROPOSED — CUSTOMER AND MERCHANT VERSIONS MAY OVERLAP

During rollout, current Customer App and one or more future Merchant App versions
may call the backend simultaneously.

## Contract

- keep existing table/RPC names, required fields and safe error semantics until
  supported clients have migrated;
- additive response fields are optional to old decoders; do not change a field's
  meaning/type in place;
- new required request fields need a new RPC/version or server-derived default that
  does not invent business truth;
- security fixes never fall back to a weaker client claim; provide a server-side
  compatibility bridge or require upgrade;
- enum additions use explicit unknown handling/version negotiation;
- pagination/order and timestamps remain deterministic;
- old clients cannot write new organization/variant/revision ownership fields;
- environment and minimum-supported-version policies are explicit.

Test N/N-1 overlap, old customer with new schema, new merchant with old customer,
offline/retry after deployment and rollback. Forced upgrade is reserved for an
incompatible security/data-integrity requirement and needs an owner release decision.

