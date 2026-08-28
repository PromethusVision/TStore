# Operator Account Security Requirements

**State:** PROPOSED — NO AUTH/DEVICE CONFIGURATION

## Minimum controls

- unique operator account, separate from daily customer/merchant profile;
- phishing-resistant MFA/passkey preferred; at minimum strong MFA appropriate to risk;
- short-lived sessions and fresh re-auth for R3/R4 actions;
- server-authoritative role/capability and case scope;
- managed/approved device posture where feasible;
- secure browser/OS, screen lock, encryption, updates, malware protection;
- no shared accounts, saved plaintext credentials, personal messaging, or service-role access;
- session/device list and rapid revoke;
- login/role/break-glass anomaly alerts;
- field-level PII minimization and no local download by default;
- environment separation and prominent Production context;
- offboarding and periodic access review.

## Recovery

Operator recovery uses a separately protected process with two-person/owner verification where possible. Support cannot reset operator privilege based on email/phone claim alone. Recovery revokes old sessions and reviews recent privileged actions.

## Break-glass

Dedicated identity or explicitly elevated session, strongest available authentication, exact incident/case, short expiry, limited action set, alert, no routine use, and mandatory post-use review.

## Research anchor

OWASP authorization guidance recommends least privilege, deny by default, and validation on every request. Exact MFA provider/device policy awaits implementation/security owner.

`OPERATOR_MFA_RECOMMENDED: YES`

`SHARED_OPERATOR_ACCOUNT: PROHIBITED`
