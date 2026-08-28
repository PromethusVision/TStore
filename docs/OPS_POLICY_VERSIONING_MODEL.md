# Policy Versioning Model

**State:** PROPOSED — NO POLICY ENGINE OR SCHEMA

## Identity

Each approved policy/ruleset eventually needs immutable opaque ID, semantic version/revision, state, effective interval, jurisdiction/scope, owner/approvers, source/evidence references, machine/human-readable rules, reason codes, migration/impact note, and predecessor/successor relationship.

Display name or document URL is not identity.

## States

`DRAFT`, `REVIEW`, `APPROVED_FUTURE`, `ACTIVE`, `SUPERSEDED`, `RETIRED`, `EMERGENCY_HOLD`. Operators apply only active approved versions; they cannot publish drafts.

## Decision binding

Every verification, listing/review moderation, product policy, QR/ad/reward enforcement, suspension, appeal, and automated rule decision records the exact policy version and relevant rule/reason. Serve-time systems use current active policy while historical audit preserves the applied version.

## Changes

- clarification with no semantic effect;
- prospective rule change;
- emergency restriction;
- relaxation;
- evidence requirement change;
- scope/jurisdiction change.

Each requires impact assessment and explicit effective behavior for existing subjects. Never rewrite old decisions as though new policy had applied.

## Rollback

Activate a superseding version; preserve faulty version and affected decisions. Rollback does not automatically reverse enforcement—cases/impact plan decide.

`POLICY_ENGINE_IMPLEMENTED: NO`

`POLICY_VERSION_FINAL: NO`
