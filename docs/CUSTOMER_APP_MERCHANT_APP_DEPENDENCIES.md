# Customer App Merchant App Dependencies

Status: **BOUNDARY AUDIT**

## Customer V1 can function without Merchant App

Guest/customer catalog discovery, search, nearby, product/seller/shop comparison,
wishlist, saved locations, Cart V2 preparation, Auth/profile, chat reading/sending,
in-app notifications and account management are customer-side capabilities.
They can be piloted with stable backend data and an authorized operational
merchant/verifier process.

## Full ecosystem requires Merchant App

| Customer-visible outcome | Merchant-side dependency |
|---|---|
| QR completion | Authenticated merchant ownership, camera scan and confirmation UI |
| Verified transaction/review evidence | Correct merchant confirmation and immutable item snapshots |
| Current catalog/price/stock | Merchant catalog/listing operations and validation |
| Timely chat | Merchant inbox, notification and response workflow |
| Shop availability/details | Merchant or operations maintenance process |
| Scalable pilot support | Merchant onboarding, role approval, audit and incident handling |

Review responses, merchant statistics, campaigns and ads are future Merchant
scope and are not customer-core blockers today. Demo shops with
`owner_user_id = NULL` support customer discovery but cannot close merchant QR;
that limitation must not be mistaken for a client bug.

Merchant App work can begin after this closeout, but the first slice should
prioritize ownership/onboarding, catalog accuracy and QR confirmation—not broad
analytics or promotional engines.
