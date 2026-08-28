# Customer App Shop Details Audit

Status: PASS FOR CUSTOMER DISCOVERY

## Functional review

- Shop details preserve the selected shop identity and render real name, description, address, phone, coordinates, rating, and product listings when supplied.
- Product rows preserve product/listing price and navigate to the correct Product Details view.
- Missing product identity disables invalid navigation; rapid duplicate taps are suppressed.
- Empty inventory remains a valid shop state.
- Invalid coordinates fall back to address-based map launch where possible.
- Missing/unusable phone/map data hides or safely fails the action with a customer-readable message.
- Chat requires customer authentication and retains the correct shop context; cancellation clears pending context.
- Narrow-width and large-text interaction surfaces have widget coverage.

Inactive-shop filtering occurs before customer navigation in Nearby/search/seller sources. The details view cannot by itself authorize merchant operations; backend RLS remains authoritative.

## Commercial limitation

The Production demo dataset has no shop owner accounts. Customer discovery, shop detail, inventory, price comparison, directions, and contact are valid. Merchant ownership, QR confirmation, and verified purchase through those demo shops are unavailable by design.

`SHOP_DETAILS_AUDIT: PASS`  
`CUSTOMER_DISCOVERY_READY: YES`  
`MERCHANT_OWNERSHIP_READY: NO`
