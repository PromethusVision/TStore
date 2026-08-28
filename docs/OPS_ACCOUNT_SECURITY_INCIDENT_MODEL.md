# Account Security Incident Model

**State:** PROPOSED — NO AUTH/INFRASTRUCTURE CHANGE

## Incident classes

| Class | Examples | Immediate concern |
|---|---|---|
| ACCOUNT_TAKEOVER | stolen credential/session, recovery abuse | unauthorized actions/data |
| TOKEN_COMPROMISE | leaked session/refresh/callback/service token | revoke/contain without logging token |
| STAFF_MISUSE | unauthorized operator/merchant staff access | scope, evidence, access removal |
| PRIVILEGE_ESCALATION | client metadata/self-role change/cross-shop access | server authorization integrity |
| SOCIAL_ENGINEERING | support deceived into reset/role/data disclosure | identity proof and action reversal |
| LOST_DEVICE | customer/merchant/operator device loss | session/capability revocation |
| CREDENTIAL_STUFFING | burst login attempts | account protection/rate controls |
| INSIDER/BREAK_GLASS_ABUSE | privileged action outside purpose | immediate containment/audit |

## Response

Create incident/case → protect evidence → revoke/limit affected sessions/capabilities through future authoritative controls → protect linked accounts/shops/actions → investigate event lineage → recover identity with canonical Auth → review roles/devices → notify/escalate under approved privacy/security policy → postmortem.

## Safety

Do not ask for password, OTP, recovery/confirmation link, token, or secret. Do not reveal whether another account exists. Preserve legitimate history; reverse unauthorized actions via dedicated workflows. Ordinary support cannot grant merchant/operator ownership.

## Evidence

Opaque account/operator IDs, Auth/security event references, session hashes/correlation, affected actions/resources, timestamps, known device context under approved policy, communications, containment and recovery events. No raw tokens.

`ACCOUNT_INCIDENT_PLAYBOOK_FINAL: NO`

`PASSWORD_COLLECTION: PROHIBITED`
