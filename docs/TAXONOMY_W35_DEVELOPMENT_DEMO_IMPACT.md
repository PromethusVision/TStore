# Wave 35A — Development Demo Impact

**State:** `STATIC CONTRACT KNOWN — LIVE DEMO STATE UNKNOWN`

## Static demo contract

The tracked Esenler demo artifacts define deterministic fixture totals:

- 4 legacy demo categories: `Kırtasiye`, `Elektronik`, `Gıda`, `Ayakkabı`;
- 20 products;
- 57 shops;
- 285 shop-product listings;
- deterministic UUIDv5 identities in a demo namespace;
- product demo markers and exact-ID cleanup behavior.

Those demo UUIDs are fixture identities. They are not automatically canonical
taxonomy UUIDs and must not be promoted merely because a label resembles a
Canonical V1 node.

## Live Development result

| Measure | Result |
|---|---|
| Current demo category count | UNKNOWN |
| Current demo product count | UNKNOWN |
| Current demo shop/listing count | UNKNOWN |
| Static UUIDs equal live UUIDs | NOT VERIFIED |
| User-generated dependencies on demo entities | UNKNOWN |
| Safe cleanup eligibility | NOT ESTABLISHED |

The exact Development project was paused, so no live category/product/listing or
dependency row was read.

## Migration effect

If the tracked demo rows are present, the safe direction is to preserve product,
shop and listing UUIDs, classify each product to one reviewed canonical leaf,
and retire legacy category rows only after dependency checks. The four demo
category UUIDs should be preserved only if a reviewed semantic-identity match is
proven under the Product Owner stable-ID rule; name equality alone is not proof.

The existing cleanup script must not be run blindly after carts, favorites,
reviews, QR or verified-purchase history exists. Demo retirement can be delayed;
it is not required merely to begin additive schema work. Whether retirement is
safe or necessary now remains a live-data question.

`DEMO_RETIREMENT_REQUIRED_IMMEDIATELY: UNKNOWN`

`DEMO_CLEANUP_EXECUTED: NO`

`DEMO_DATA_MUTATED: NO`
