# Backend Verified Purchase Contract

**State:** PRESERVED CANONICAL PRODUCT RIGHT

A verified purchase is immutable evidence that the trusted QR confirmation
contract committed for one customer and shop. It is not online checkout, payment,
invoice, guaranteed product quality or ad causality.

## Required identity and snapshot

- stable transaction, customer, shop and source QR session IDs;
- trusted confirmation time and verifier membership/shop context;
- immutable item IDs;
- canonical product ID, variant ID when known, listing ID and listing revision;
- product/listing display snapshot sufficient for history;
- confirmed quantity, unit/basis, unit price and line amount;
- contract/policy version and integrity state.

Current `verified_transactions` and `verified_transaction_items` remain the active
entities. Migration `0009` product evidence is mandatory for review eligibility.
Mutable names, listing activity and future product lineage must not erase the
original snapshot.

Consumers independently decide review, reward, reputation, analytics and ad
attribution outcomes. One purchase event cannot be manufactured by any consumer.

