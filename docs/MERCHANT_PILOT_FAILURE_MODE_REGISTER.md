# Merchant Pilot Failure Mode Register

State: `DESIGN REVIEW`

| ID | Failure | Severity | Prevention/detection | Response |
|---|---|---|---|---|
| MPF-001 | Customer gains merchant control | P0 | Server membership/capability tests | Disable writes, security incident |
| MPF-002 | Merchant confirms other shop QR | P0 | Exact-shop RPC + concurrency tests | Reject/audit/fraud case |
| MPF-003 | Replay creates second purchase | P0 | Unique consume + atomic transaction | Reject; incident if invariant breaks |
| MPF-004 | Timeout causes duplicate retry | P0 | Idempotency + status reconciliation | Show authoritative result |
| MPF-005 | Operator manually creates verified history | P0 | No routine DB path, audit/SoD | Security/ops incident |
| MPF-006 | Stale price shown as current | P1 | Freshness timestamp/unknown projection | Notify/pause listing |
| MPF-007 | Regulated item auto-activates | P0 | Policy hold/fail closed | Deactivate, specialist review |
| MPF-008 | Shared merchant password spreads | P1 | Single-owner cohort/device policy | Revoke sessions, defer shop |
| MPF-009 | Candidate becomes canonical automatically | P1 | Review state machine | Withdraw/correct provenance |
| MPF-010 | Customer PII appears in merchant history/log | P0 | Projection/schema/log tests | Contain/privacy incident |
| MPF-011 | Background app confirms stale preview | P1 | Resume revalidation | Reject/reload |
| MPF-012 | Concurrent listing edit silently wins | P1 | Revision conflict | Refresh/reapply |
| MPF-013 | Assisted listing lacks merchant attestation | P1 | Required evidence/source | Hold/unpublish |
| MPF-014 | Support grants authority | P0 | Role separation/capability | Revoke/audit/incident |
| MPF-015 | Badge/ads/reward contaminates trust | P2 | Surface separation | Remove projection, review claims |
| MPF-016 | No backup support during checkout | P1 | Named escalation/pause | Pause QR cohort |
| MPF-017 | App uses wrong environment | P0 | Artifact/environment identity | Stop pilot/revoke artifact |
| MPF-018 | Old client incompatible with migration | P1 | N/N-1 contract tests | Feature disable/hotfix |
| MPF-019 | Merchant sees chart as audited revenue | P1 | Wording/tests | Correct UI/communication |
| MPF-020 | Camera/device fleet incompatible | P1 | Physical matrix | Replace/defer shop/device |

