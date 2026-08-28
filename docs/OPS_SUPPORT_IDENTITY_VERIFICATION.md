# Customer Support Identity Verification

**State:** PROPOSED — NO AUTH FLOW CHANGE

## Principle

Support proves control of the canonical account through existing/future secure Auth channels. Knowledge of personal facts is weak evidence and never substitutes for authentication.

## Assurance ladder

| Request | Candidate assurance |
|---|---|
| General information/no account data | none |
| View own case/status | authenticated session or secure case access |
| Profile correction/non-sensitive support | authenticated session + current session checks |
| Account recovery/contact change/data request | canonical Auth recovery/recent re-auth + risk review |
| Security incident or conflicting identity | specialized incident flow; temporary containment |
| Merchant/operator privilege request | not customer support; dedicated higher-assurance workflow |

## Never request

Password, OTP, recovery/confirmation link, access/refresh token, QR secret, full card credential, remote desktop control, or answers copied from another user's data. Do not use mother's maiden name or other reusable “security questions.”

## Channel handling

In-app authenticated case is preferred. Email/web form may intake but does not prove control; send the user to a trusted canonical route without revealing account existence. A displayed request/case ID helps correlation, not authentication.

## Recovery safety

No operator sets a password or manually confirms email. Rate limits, enumeration-safe messages, session revocation, expected-user identity checks, and suspicious recovery escalation remain server-authoritative.

`SUPPORT_PASSWORD_REQUEST: PROHIBITED`

`ACCOUNT_EXISTENCE_LEAK: PROHIBITED`
