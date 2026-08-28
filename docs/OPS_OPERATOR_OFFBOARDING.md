# Operator Offboarding and Role Removal

**State:** PROPOSED — NO IAM ACTION

## Triggers

Employment/contract end, role transfer, extended leave, compromised account/device, policy breach, access no longer needed, or organization/vendor change.

## Sequence

1. Confirm exact operator identity and effective time through authorized process.
2. Suspend privileged access immediately for security trigger; otherwise schedule coordinated removal.
3. Revoke active sessions, roles/capabilities, break-glass eligibility, API/vendor/ticketing groups, devices, export/download access, and physical credentials.
4. Reassign open cases/queues and preserve handoff notes.
5. Rotate shared external credentials only if legacy exposure existed; shared accounts are prohibited.
6. Preserve immutable operator/audit/case identity.
7. Review recent high-risk actions and exports where risk warrants.
8. Verify access removal across environments/tools; record residual exceptions.
9. Close with approver and reconciliation evidence.

## Role change

Narrow old access before granting new where possible. Temporary grants expire automatically. Offboarding does not delete operator profile/history or reattribute actions.

## Security/privacy

Do not announce unnecessary employment details. Lost-device or hostile offboarding becomes an incident. Operator cannot offboard self or erase evidence.

`OFFBOARDING_IMPLEMENTED: NO`

`AUDIT_AUTHOR_REWRITTEN: NO`
