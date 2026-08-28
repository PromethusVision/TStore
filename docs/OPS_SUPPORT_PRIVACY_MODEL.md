# Support Privacy and Data-Minimization Model

**State:** PROPOSED — PRIVACY/LEGAL REVIEW REQUIRED

## Need-to-know views

| Case purpose | May need | Normally unnecessary |
|---|---|---|
| Auth/session | opaque account ID, status, safe event/reason, device/session summary | password, OTP, recovery token, full token, unrelated profile |
| Location | permission/state, coarse selected area, correlated error | continuous history, exact coordinates unless incident requires it |
| Merchant/shop | merchant/shop IDs, role/scope, verification state | unrelated customer activity, full raw documents |
| QR | transaction ID, actors/shops, timestamps/state, item snapshot | unrelated purchases, raw QR secret |
| Catalog/listing | product/listing IDs, provenance, current assertions | customer identity and private messages |
| Abuse/report | subject/content, protected reporter reference, evidence | reporter identity disclosed to subject |
| Privacy request | authenticated identity, request scope, systems/retention result | broad operator access to all data |

## Controls

- purpose and case-scoped access;
- field-level redaction and derived summaries;
- raw evidence behind a higher capability;
- access/export logging;
- no copy-paste into internal notes where references suffice;
- attachment MIME/malware/metadata controls if later supported;
- retention class and legal hold separated;
- environment and tenant boundaries;
- secure customer communication without internal notes/signals.

## Prohibitions

Never ask for passwords, OTPs, recovery/confirmation links, session tokens, private keys, service credentials, complete payment credentials, or unrelated identity documents. Never use production data in screenshots/training fixtures. Do not expose another party's report, contact, exact location, or private communication merely to explain a decision.

KVKK deletion/anonymization guidance requires data to become inaccessible and unusable when the processing purpose ends; exact basis and periods remain responsible-owner decisions.

`SUPPORT_DEFAULT_VIEW: MINIMIZED`

`PRIVACY_POLICY_FINALIZED: NO`
