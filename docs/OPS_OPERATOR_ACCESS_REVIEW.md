# Operator Access Review

**State:** PROPOSED — NO IAM IMPLEMENTATION

## Review cadence triggers

Periodic risk-tier review plus role change, extended inactivity, contractor change, incident, manager/owner change, new sensitive capability, break-glass use, or policy/tool migration. Exact interval is owner/security decision.

## Review inventory

Operator profile/status, Auth identity, roles/capabilities/scopes, queue assignments, Production/Development access, admin/ticket/vendor groups, MFA/device assurance, break-glass eligibility/use, recent high-risk actions/denials, exports/PII reveals, unresolved conflicts, expiry/temporary grants, and offboarding status.

## Decisions

`KEEP`, `NARROW`, `REMOVE`, `SUSPEND_PENDING_REVIEW`, `REQUIRE_REAUTH/MFA`, `TRAINING_REQUIRED`, or `ESCALATE_INCIDENT`. “Used recently” does not prove need; “never used” supports removal.

## Controls

Reviewer should not approve own broad access where an alternative exists. Every change is effective-dated and audited. Removed access revokes sessions/tokens and vendor memberships. Historical audit retains operator reference.

## Evidence

Current job/purpose, approved capability need, case/queue scope, training/assurance, temporary expiry, and review decision. Do not inspect irrelevant employee behavior or rank productivity.

`ACCESS_REVIEW_INTERVAL_FINAL: NO`

`PERMANENT_UNUSED_PRIVILEGE: NOT_ALLOWED`
