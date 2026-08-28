# EsnaftaVar Verified Purchase Metric Semantics

**State:** `CANONICAL INTERPRETATION GUARDRAIL — METRIC OPTIONS NOT FINAL`

A verified purchase count is the number of distinct, server-authoritative
`verified_purchase_created` facts that passed the platform's in-person QR
confirmation contract in the stated scope/window.

It means:

- the QR token and merchant/shop authorization checks succeeded;
- replay-safe server logic created one durable platform fact;
- the fact may support existing review eligibility and future governed consumers.

It does **not** mean:

- online checkout or order completion;
- payment authorization, settlement, refund state or invoice;
- audited merchant revenue, profit, tax or accounting completeness;
- advertisement causality;
- every physical purchase at the merchant was captured.

Deduplicate by authoritative verified-purchase ID, not scan, notification,
delivery attempt or item row. Corrections/cancellations, if a future product
contract introduces them, require explicit reversal/status events and restated
metric rules. Event-time product/listing/shop snapshots remain preserved; current
catalog rollups are separately labelled.

Metric labels should say “Doğrulanmış fiziksel alışveriş” rather than “satış” or
“ciro”. Freshness, window, environment and QR coverage limitations accompany the
number.

`VERIFIED_PURCHASE_EQUALS_PAYMENT: NO`

