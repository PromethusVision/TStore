# Merchant Support Identity Verification

**State:** PROPOSED — NO MERCHANT AUTH/RLS CHANGE

Merchant support must verify both account control and authority over the organization/shop/capability in question.

## Checks

1. canonical authenticated user/session;
2. active merchant organization membership;
3. current role/capability;
4. exact shop/branch scope;
5. entity lifecycle and security holds;
6. fresh re-auth/higher assurance for ownership, staff, payout/ads, exports, or verification evidence;
7. case/purpose binding.

Business name, tax/registration detail, shop address, caller ID, public social profile, or knowledge of internal facts does not alone authenticate.

## Sensitive requests

Ownership transfer, lost owner account, staff-role changes, shop control dispute, verification document access, broad export, QR security, and account takeover route to specialized high-assurance cases. Temporary containment may precede recovery; support cannot grant owner status.

## Channels

Prefer authenticated merchant app/web. Email/phone/WhatsApp intake must return to a trusted canonical verification route. Never ask for password, OTP, Auth callback/recovery link, session token, QR secret, service key, or another staff member's private data.

## Audit

Record operator, merchant/org/shop, requested action, assurance method/class (not secret), decision, session/capability checks, reason, and any escalation.

`MERCHANT_KNOWLEDGE_EQUALS_AUTHORITY: NO`

`SUPPORT_ROLE_GRANT: PROHIBITED`
