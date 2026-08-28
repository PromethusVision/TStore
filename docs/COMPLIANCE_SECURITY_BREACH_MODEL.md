# Personal Data Security and Breach Model

**State:** POLICY FOUNDATION — NO INCIDENT DETERMINATION

## Prevention minimum

- data-flow and asset inventory; least-privilege access and role review;
- MFA/re-authentication for privileged operators when implemented;
- secrets outside source/logs; allowlisted telemetry and structured redaction;
- production/test isolation and synthetic fixtures;
- dependency, provider and processor security review;
- encryption in transit and appropriate storage protection;
- session revocation, rate limits and server-authoritative authorization;
- access/export/privileged-action auditing;
- backup recovery tests that preserve deletion and incident controls;
- staff training and a reportable security channel.

## Suspected-breach lifecycle

1. **Detect and open an incident clock.** Preserve minimum volatile evidence.
2. **Contain without destroying evidence.** Revoke credentials/sessions and isolate
   affected capability where proportionate.
3. **Classify data/subjects/scale/recipient and ongoing risk.** Do not wait for
   perfect certainty to escalate.
4. **Notify the designated privacy/legal/security roles.** Counsel decides whether
   the event meets notification criteria.
5. **Prepare Board and affected-person communications if required.** Track the
   KVKK Board's 72-hour interpretation; document reasons for any delay.
6. **Recover and monitor.** Confirm unauthorized access is closed and credentials
   rotated through safe secret mechanisms.
7. **Post-incident correction.** Root cause, affected systems, notices, rights,
   retention, tests and vendor actions; no blame-oriented record.

## Severity signals

P0 candidates include active token/credential compromise, broad export, exact
location exposure, identity/verification documents, private chat, special-category
data or inability to contain. P1 includes bounded confirmed disclosure or prolonged
privileged misuse. P2/P3 diagnostic events remain documented but are not falsely
reported as breaches.

## Communication safeguards

Do not include raw tokens, full documents, unnecessary victim identities, exploit
details that amplify harm or speculative facts. Preserve accurate timelines and
state clearly what is known, unknown, contained and available to affected people.

`BREACH_NOTIFICATION_PLAYBOOK_IMPLEMENTED: NO`

