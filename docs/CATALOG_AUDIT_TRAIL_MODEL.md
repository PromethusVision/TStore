# Catalog Audit Trail Model

Status: **OWNER REVIEW DRAFT — CONCEPTUAL IMMUTABLE HISTORY**
Wave: 16, Work Package 31

The audit trail explains how current catalog truth was projected and preserves the
meaning of historical customer and merchant events.

## Event envelope

- immutable event ID and occurred/recorded timestamps;
- entity type and opaque entity ID;
- action (`CREATE_ASSERTION`, `RESOLVE_FIELD`, `REASSIGN_TAXONOMY`, `MERGE`, `SPLIT`,
  `RETIRE`, `POLICY_CHANGE`, `LISTING_CORRECTION`, `ALIAS_ADD`);
- actor type/reference and authorization context;
- before/after or predecessor/successor mapping;
- evidence/provenance references, confidence and reason code;
- ruleset/catalog projection version;
- impact counts and linked review/decision ticket;
- reversal/superseding event reference.

## Critical uses

| Change | Audit requirement |
| --- | --- |
| Merge | All predecessor IDs, survivor, listing/review collisions, aliases and evidence. |
| Split | Every successor mapping, unresolved historical references and no-default redirect. |
| Taxonomy reassignment | Old/new stable leaf IDs, placement rule and effective time. |
| Policy change | Jurisdiction, authority/evidence, effective interval and current display impact. |
| Product correction | Exact field assertions replaced; identity unchanged or explicit successor. |

Audit data is append-only to ordinary actors and access-controlled. It does not need
to duplicate large media or unnecessary PII: reference immutable evidence hashes and
minimal actor identity. Search indexes and aggregates are rebuildable projections;
the audit log and verified purchase snapshots are not.
