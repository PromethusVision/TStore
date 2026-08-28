# Backend Shared Domain Contract

**State:** PROPOSED CROSS-APP CONTRACT

Customer and Merchant Apps may safely share stable domain identities and read-safe
semantics—not repositories, credentials or broad authorization.

## Shared concepts

- canonical product, optional variant, shop and listing IDs;
- listing price/availability units and freshness semantics;
- QR session status and client-safe terminal errors;
- verified purchase and immutable item snapshot identity;
- visible review/rating projection;
- notification action types and API/error/capability versions;
- environment/release/correlation identifiers without secrets.

## App-specific boundaries

Customer owns private profile/location/wishlist/cart/review actions. Merchant owns
authorized shop/listing operations and QR confirmation. Operations owns restricted
correction/policy actions. Shared DTO definitions do not grant a caller access to
all fields; each surface uses purpose-specific projections.

No shared service-role client, global mutable cache across users or one generic
“user role” authorization helper. Contract packages may share enums/value objects
only after unknown-version behavior and backward compatibility are proven.

