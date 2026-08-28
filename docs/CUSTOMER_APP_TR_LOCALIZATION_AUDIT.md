# Customer App Turkish Localization Audit

Status: PASS FOR FUNCTIONAL COPY

- Active customer loading, empty, error, retry, permission, Auth, Cart, QR, review, notification, chat, purchase, and settings surfaces use Turkish customer-facing text.
- Raw Supabase/Postgrest/Auth exception text is mapped or hidden at active UI boundaries.
- Terms are functionally consistent: mağaza, ürün, satıcı, sepet, favori, konum, bildirim, mesaj, doğrulanmış alışveriş.
- “Featured” is rendered as discovery behavior rather than English/sponsored advertising copy.
- No active obvious English error/button leakage or broken Turkish encoding was found by source scan and existing widget assertions.

Class/type names, enum names, test descriptions, third-party error categories, and legacy isolated source identifiers are developer artifacts, not customer copy. Final tone, capitalization, microcopy, and taxonomy labels are deferred to owner-final taxonomy/UI rollout.

`TR_LOCALIZATION_AUDIT: PASS`  
`TECHNICAL_ERROR_LEAK_FOUND: NO`  
`FINAL_COPYWRITING: DEFERRED`
