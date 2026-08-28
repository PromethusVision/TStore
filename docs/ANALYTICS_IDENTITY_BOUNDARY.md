# EsnaftaVar Anonymous and Authenticated Analytics Identity Boundary

**State:** `PROPOSED PRIVACY BOUNDARY`

Guest discovery works without authenticated identity. Guest analytics, if
approved, uses an environment-scoped, rotating pseudonymous identifier or no
identifier beyond explicit event correlation. It does not contain email, phone,
device advertising ID or stable hardware fingerprint.

Authenticated events include customer identity only where the metric/business
purpose genuinely requires it (for example a server-authoritative persisted
wishlist transition). Dashboards prefer aggregated subject counts and restrict
raw access.

Default rules:

- no retroactive merge of pre-login guest history into the customer profile;
- no cross-device identity graph;
- logout/account deletion rotates client analytics identity and invokes the
  approved retention/deletion policy;
- merchant/customer/operator identities and roles never share an analytics key;
- Development/demo/test/Production identities cannot join;
- advertising identity and product analytics identity remain separate purposes.

Any longitudinal customer retention or attribution model requires explicit owner,
privacy/legal, consent and deletion decisions.

`GUEST_ACCOUNT_RETROACTIVE_LINK_DEFAULT: NO`

