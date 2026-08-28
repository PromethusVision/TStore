# EsnaftaVar Observability and Analytics Separation

**State:** `PROPOSED FOUNDATION`

Product analytics asks how the product is used and which outcomes occur.
Observability asks whether software is healthy and why it is failing. They may
share correlation/release/environment dimensions, but not purpose, access,
retention or authority.

Examples:

- low verified-purchase volume may be business traffic, not an outage;
- high QR validation server-error rate is health, while expired/wrong-shop reasons
  may be normal product/security outcomes;
- product view count is analytics; image/RPC latency and crash-free starts are
  health;
- audit/security events are restricted evidence, not engagement metrics.

Do not send unrestricted business payload/PII into logs/traces. Do not use sampled
diagnostic traces as a business denominator. An observability alert may open an
incident; it cannot alter purchases, rewards, reputation or ad billing.

`PRODUCT_ANALYTICS_EQUALS_PRODUCTION_HEALTH: NO`
