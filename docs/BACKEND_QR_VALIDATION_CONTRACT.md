# Backend QR Validation Contract

**State:** SERVER-AUTHORITATIVE — NO CLIENT TRUST

Validation runs on trusted server state. A scanner result is only an input.

## Required checks

1. authenticated caller and active merchant membership/capability;
2. exact shop scope and active merchant/shop lifecycle;
3. token format/hash lookup without logging raw value;
4. active session state and trusted-server expiry;
5. issued shop equals confirming shop;
6. session/customer/item snapshot integrity;
7. existing terminal outcome/idempotency result;
8. policy/security block and expected contract version.

Failures return bounded reason classes such as malformed, expired, cancelled,
wrong shop, already used, unauthorized or unavailable. They do not reveal whether
a guessed token belongs to another customer/shop. A client-side green screen,
clock or cached status never makes validation pass.

Validation alone does not consume a token. Any preview must be customer-data
minimal and remain subject to authorization at confirmation time.

