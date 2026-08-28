# EsnaftaVar Customer App Event Registry

**State:** `CANDIDATE MINIMUM REGISTRY — NOT FINAL`

Collect only events that answer an approved operational or product question.
Screen taps, scrolls and widget lifecycle noise are excluded by default.

| Area | Candidate event | Authority | Minimum safe context | Default use |
|---|---|---|---|---|
| App | `app_started` | Client observed | release, platform, environment, outcome | Health/adoption |
| Auth | `authentication_completed` / `authentication_failed` | Server derived/client observed | method class, bounded reason | Health; not credential logging |
| Search | `search_submitted`, `search_results_presented`, `search_result_opened` | Client reported/observed | query surrogate or governed class, result count bucket, entity ID | Discovery quality |
| Category | `category_opened` | Client reported | stable taxonomy ID/version | Discovery |
| Product | `product_viewed`, `seller_comparison_opened` | Client observed/reported | product/listing/shop IDs where applicable | Interest |
| Shop | `shop_opened`, `directions_requested` | Client reported | shop ID, coarse source | Local intent |
| Wishlist | `wishlist_item_added`, `wishlist_item_removed` | Server authoritative if persisted | product ID | Soft intent |
| Cart V2 | `cart_item_added`, `cart_item_removed` | Server authoritative if persisted, else client reported | listing/product, quantity band | Soft intent; not checkout |
| Review | `review_created`, `review_updated`, `review_deleted` | Server authoritative | review/product/shop, eligibility reference | Trust/review metrics |
| Location | `location_permission_result`, `coarse_location_context_used` | Client observed | permission/result/coarse cell only if approved | Feature health |
| Chat | `conversation_opened`, `message_delivery_failed` | Mixed | conversation surrogate, bounded reason | Health only; no content |
| Notification | `notification_opened`, `notification_marked_read` | Mixed | notification type and opaque ID | Delivery/engagement |

QR and verified purchase events use the dedicated QR model rather than generic
customer telemetry. Search raw query, precise location, chat content and
notification body are excluded. Guest and authenticated identity remain separate;
no retroactive linking without an approved purpose/consent contract.

Every candidate needs an owner, question, retention, privacy basis, quality rule
and removal path before implementation.

`CUSTOMER_EVENT_REGISTRY_FINALIZED: NO`
