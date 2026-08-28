# Backend Rate-Limit Requirements

**State:** CONCEPTUAL — NO LIMITER IMPLEMENTATION

Rate limits complement authorization/idempotency; they do not define business
uniqueness or turn an unauthorized call into an allowed one.

| Surface | Risk | Candidate dimensions | Response posture |
|---|---|---|---|
| Auth/signup/recovery | credential/enumeration/email abuse | IP/device/account/provider | generic outcome, progressive delay |
| QR issue/preview/confirm | token guessing/replay/collusion | user, membership, shop, session, network | tight per-session/shop plus anomaly signal |
| Review/rating | spam/retry | customer, product/shop, source evidence | uniqueness first, bounded mutation rate |
| Chat | spam/harassment/resource abuse | sender, recipient/shop, account age | message/byte window and block/report policy |
| Product candidate/import | catalog flooding | organization, shop, membership, batch | queue quota and per-row limits |
| Ads/campaign | mutation/report scraping/budget abuse | organization, shop, campaign | revision/idempotency plus command/read quotas |
| Sensitive merchant/ops mutation | brute force/high impact | actor, capability, resource, case | very low rate, fresh auth, alert |
| Public search/nearby/media | mass scraping/cost | network/session/query shape | page/radius cap and adaptive throttling |

Distributed/account-rotation abuse needs aggregate detection, but device/IP data is
privacy-sensitive. Accessibility, shared networks, retry storms and emergency
operations require safe exceptions. Exact thresholds and customer messaging are
`OWNER_DECISION_REQUIRED` only where they materially change product access.
