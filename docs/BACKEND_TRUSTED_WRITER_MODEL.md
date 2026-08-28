# Backend Trusted Writer Model

**State:** PROPOSED — NO WRITER SERVICE IMPLEMENTED

A trusted writer is a narrow server/operations capability for facts ordinary
customers or merchants must not author directly: canonical catalog approvals,
product lineage, category/banner/canonical media, policy decisions, purchase
correction, reward/reputation correction and operations audit.

## Request contract

- authenticated machine/operator and environment;
- human case/actor where a privileged decision is involved;
- explicit capability and exact resource scope;
- typed allowlisted command, expected revision and idempotency key;
- provenance/evidence and policy version;
- before/after preview for high-risk mutations;
- append-only audit and committed result reference;
- bounded response with no secret/raw evidence leakage.

No generic table editor, arbitrary SQL endpoint, bucket-wide upload/delete or
“admin=true” client flag. Batch work returns per-item results and stops/isolates
unsafe conflicts. Production use requires separate authorization and change
window. Whether the pilot needs a dedicated service or controlled operator
functions is implementation planning, not an owner product choice.

