# Social Engineering Threat Model

**State:** PROPOSED — SECURITY REVIEW REQUIRED

## Threats

- attacker poses as customer/merchant/owner/operator/vendor/authority;
- urgency, authority, sympathy, threat, or payment pressure;
- requests password/OTP/recovery link/token/QR/role/PII/export;
- callback-number or email spoofing;
- fake identity/merchant documents and support screenshots;
- malicious links/attachments or remote-access request;
- staff collusion, pretexting, vishing, phishing, SIM-swap/account takeover;
- exploiting public shop/account facts as “proof”;
- asking operator to bypass policy “just this once.”

## Controls

Trusted inbound channels do not equal authenticated identity. Return sensitive requests to canonical in-app/Auth flows; independently verify organization/shop/capability; never use contact details supplied in the same suspicious request for callback; inspect domain/source; validate documents through approved sources; require case/reason/re-auth; prohibit shared secrets; use two-person review for role/ownership/export/permanent action; preserve evidence and escalate.

## Operator response

Stop action, avoid confirming account existence/data, capture safe metadata, report phishing/security case, revoke/contain affected access if credible, communicate through trusted channel, and document decision. Do not engage attacker with detection details.

## Training scenarios

Lost phone, “owner abroad,” regulator/police urgency, executive override, merchant staff firing, customer deletion request, vendor maintenance, fake GitHub/Supabase alert, QR refund, and operator password reset.

`PASSWORD_OR_OTP_AS_SUPPORT_PROOF: NO`

`SOCIAL_PRESSURE_BYPASS: PROHIBITED`
