# Backend Demo Data Compatibility

**State:** STATIC AUDIT — DEMO DATA NOT MODIFIED

`esenler_demo_v1` contains deterministic 4 categories, 20 canonical products, 57
ownerless shops and 285 listings across 19 neighborhoods. IDs are UUIDv5 under a
fixed namespace; products carry explicit demo marker and shops use `[DEMO]` names.

## Future-model compatibility

- products map to canonical product with no variant evidence; do not fabricate
  variants;
- `shop_products` remain listing identities with deterministic price and available
  state; product stock is compatibility-only demo data;
- `owner_user_id = NULL` means no organization/membership/merchant authority;
- no Auth/profile, review, QR/purchase, rating, chat, notification, reward, ad or
  reputation evidence exists from the seed;
- synthetic coordinates are `NEIGHBORHOOD_CENTER`, not exact addresses;
- featured means demo discovery only, never sponsored/paid;
- future migrations preserve deterministic IDs/markers and keep demo environment/
  dimension explicit.

Organization/variant backfills must leave these rows null/unresolved unless a new
owner-authorized demo artifact supplies evidence. Existing cleanup is exact-ID and
must not run after user dependencies without fresh impact analysis.
