# Shop Listing Lifecycle Model

Status: **OWNER REVIEW DRAFT**
Wave: 16, Work Package 29

The listing is the merchant-specific relation to one product/variant. Its lifecycle
does not change shared identity.

| State | Search/seller comparison | Cart/QR action | Meaning |
| --- | --- | --- | --- |
| `DRAFT` | Hidden | Blocked | Merchant is preparing or resolving identity. |
| `ACTIVE_AVAILABLE` | Visible | Allowed after fresh validation | Merchant offers item; stock may be known or unknown per explicit state. |
| `OUT_OF_STOCK` | Optional visible with label | Blocked | Active relationship, known zero stock. |
| `TEMPORARILY_UNAVAILABLE` | Optional visible with label | Blocked | Temporary operational pause. |
| `NEEDS_REVIEW` | Safe default hidden | Blocked | Identity/policy/content conflict. |
| `RETIRED` | Hidden | Blocked | Shop ended the offer; history retained. |
| `SHOP_INACTIVE` | Hidden | Blocked | Derived suppression from shop lifecycle. |

Price, availability, stock knowledge, shop SKU, local media and description can be
updated by the authorized merchant with audit history. Product/variant policy or
retirement can suppress a listing even when the merchant marks it active.

Cart V2 and QR must use listing identity and revalidate listing, shop and policy at
action time. A listing deletion/retirement never invalidates immutable verified
purchase snapshots. Reactivation preserves listing ID only when it is still the same
shop + product/variant relation; reassignment to another product creates correction
history and may require a new listing identity.
