# Catalog V1 versus Future Scope

Status: **OWNER REVIEW RECOMMENDATION — NOT FINAL ROADMAP**
Wave: 16, Work Package 41

## `MUST_HAVE_V1`

- stable opaque canonical product, optional/default variant and shop listing identity;
- enforced product/variant/listing field ownership;
- listing price, availability/stock knowledge, merchant SKU and timestamps;
- minimum product facts, primary stable taxonomy leaf and brand/maker/unbranded state;
- existing-first merchant search and candidate path with duplicate/policy gates;
- optional typed barcode/MPN assertions with check/provenance and no-barcode support;
- custom/unbranded and variable-measure base product + sell-unit support;
- search grouping as one product with nearby seller children;
- immutable QR product snapshot and current one-review-per-customer+product policy;
- lifecycle states sufficient to hide/block while retaining history;
- audit of identity-critical edits, permanent merge/split predecessor mapping;
- fail-closed behavior for policy-sensitive ambiguity.

## `SHOULD_HAVE`

- explicit multi-variant selection and sibling reuse tools;
- field-level provenance for brand/model/pack/identifier/taxonomy/media;
- explainable high-confidence matching suggestions and review console;
- canonical/variant/listing media separation and reviewed media promotion;
- comparable unit price, freshness windows and observed price history;
- merchant bundle candidates with fixed composition;
- alias-aware search and product-with-no-nearby-offer strategy;
- analytics continuity across merge/split and variant correction.

## `DEFER`

- unattended/ML auto-merge and broad external master-catalog synchronization;
- full lot/batch/expiry inventory and recall operations;
- promotions/payment/order/fulfillment engines;
- complex made-to-order quote, booking or service configuration;
- customer-facing complete price-history ledger;
- automatic merchant bundle promotion and substitution engine;
- full temporal product copies/semantic versions;
- advanced advertising optimization and gamification rewards;
- exhaustive regulated-product launch beyond explicit owner/legal allowlist.

Commercialization should wait for P0 identity, review/purchase, policy and listing
boundaries—not for deferred enterprise automation. This scope becomes actionable only
after the owner resolves the root decision register.
