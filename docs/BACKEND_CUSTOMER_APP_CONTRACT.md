# Backend Customer App Contract

**State:** CURRENT BEHAVIOR PRESERVATION CONTRACT

## Active customer surfaces

- environment-separated Supabase bootstrap with no production fallback;
- Auth/profile/legal consent and protected role;
- public categories/products/banners/shops/listings/media;
- private addresses/saved locations/wishlist/Cart V2;
- QR issue/status and customer-visible verified purchases;
- verified-evidence review and shop rating RPCs;
- in-app chat/notifications plus authorized Realtime;
- canonical account self-deletion.

## Compatibility rules

Stable table/RPC meaning, IDs, active filters, review/QR rights, media fallback,
client-safe errors and RLS remain intact while merchant/future domains are added.
New organization/membership/variant fields are optional to old customers. Merchant
authorization must not broaden customer reads. Ads/reward/reputation are additive
and cannot change purchase/review evidence.

The backend may optimize a read behind a compatible projection/RPC only after result
ordering, filtering, pagination and error equivalence tests. A security requirement
may require upgrade, but never a silent weaker fallback. Legacy orders stay clearly
separate from verified physical-purchase truth.

