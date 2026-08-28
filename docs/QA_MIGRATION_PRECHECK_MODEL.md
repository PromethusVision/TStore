# Migration Precheck Model

State: PROPOSED — OWNER REVIEW REQUIRED

Before any authorized remote migration:

- verify exact project reference/environment and operator identity;
- record migration commit, checksums, ordering, and already-applied versions;
- confirm backup/recovery point and tested restore access;
- inventory affected tables, policies, RPCs, triggers, indexes, clients, and jobs;
- estimate locks/runtime from representative synthetic scale;
- validate free capacity, active incidents, monitoring, and maintenance communication;
- run local and Development acceptance;
- define abort criteria, postchecks, and accountable approvers.

Any environment mismatch, checksum drift, unknown schema state, missing recovery path, or unaccepted destructive operation is fail-closed. Secrets are never printed into evidence.

OWNER_DECISION_REQUIRED: define backup verification owner and change-window authority.
