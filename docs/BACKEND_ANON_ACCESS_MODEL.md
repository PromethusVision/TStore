# Backend Anonymous Access Model

**State:** PROPOSED — PRESERVE PUBLIC DISCOVERY

Anonymous users may browse a deliberate public projection of active categories,
products, shops, listings, visible reviews, banners and canonical public media.
They cannot access profiles, exact customer location, carts, wishlist, QR,
purchases, chat, notifications, membership, private merchant operations or audit.

## Rules

- public projection excludes owner/contact/private policy fields;
- active product alone is insufficient when shop/listing/policy is blocked;
- aggregate counts apply privacy thresholds where inference risk exists;
- unknown row IDs return the same safe absence as unauthorized private rows;
- public Storage access follows canonical bucket/path rules, not table bypass;
- rate limits and abuse controls complement but never replace RLS;
- anonymous analytics does not create a durable customer identity by default.

Search and discovery should remain useful without signup. Exact public review
author display and coarse-location policy are `OWNER_DECISION_REQUIRED`; minimize
identification while preserving review usefulness.

