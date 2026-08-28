# Catalog Owner Root Decisions

Status: **DECISION QUEUE — NO OWNER CHOICE RECORDED**
Wave: 16, Work Package 39

Recommendations are architecture advice only. Every row remains open until the
Product Owner (and legal/policy owner where indicated) explicitly decides.

| QUESTION | OPTIONS | RECOMMENDATION | WHY | AFFECTED SYSTEMS | P0/P1/P2 |
| --- | --- | --- | --- | --- | --- |
| What is the V1 canonical identity unit? | Family / sellable trade item / listing | Stable product family plus optional buyable variant; listing separate | Supports shared discovery without duplicating shops | Catalog, search, review, QR | P0 |
| Is an implicit default variant allowed? | Always explicit / optional implicit | Allow one implicit default for single-configuration products; stable variant ID before multi-variant expansion | Reduces V1 burden without losing boundary | Catalog, cart, migration | P0 |
| Which domain facts force variant versus different product? | One global rule / domain registry | Owner-approved domain identity dimensions with pack/edition hard rules | Colour, formulation and fitment differ by domain | Catalog, dedup, merchant | P0 |
| Can GTIN exact match auto-link? | Always / never / allowlist | Only validated compatible GTIN plus no hard conflict under versioned allowlist | Barcode is strong but fallible | Dedup, merchant, scanner future | P0 |
| Can no-barcode records auto-link? | Never / multi-signal threshold | Permit high-confidence reuse for non-packaged goods; no automatic merge until measured | Handmade/local goods must work | Dedup, custom catalog | P1 |
| What happens to two reviews by one customer after merge? | Keep newest / keep oldest / choose/aggregate/quarantine | Preserve both history; expose one only under explicit collision policy | Current uniqueness must not delete content | Reviews, aggregates, audit | P0 |
| Does split lineage confer review eligibility? | Always / never / proof-based | Only deterministic immutable snapshot mapping; ambiguous predecessor needs explicit transition policy | Prevents guessed verified status | QR, reviews, migration | P0 |
| May low-risk merchant candidates activate immediately? | All review / allowlist / all active | Allowlisted low-risk candidate with duplicate/policy gates; otherwise non-discoverable review | Balances merchant speed and catalog safety | Merchant app, moderation | P0 |
| Are made-to-order/configurable goods V1 physical products? | Exclude / base+options / every configuration | Support repeatable base + controlled physical options; defer service/quote behavior | Local merchants need coverage without booking scope leak | Catalog, merchant, policy | P0 |
| What variable-measure sell semantics are required V1? | Fixed packs only / unit price + increment / full batches | Base product + listing unit/minimum/increment and purchase quantity; defer batch inventory | Food/fabric/cable are core local cases | Listing, cart, QR, price | P0 |
| Which policy classes may appear at launch? | Normal only / partial regulated / broad | `NORMAL` plus explicitly approved allowlist; all ambiguous regulated items fail closed | Policy must not be inferred by taxonomy | Policy, search, merchant | P0 POLICY-SENSITIVE |
| Can discontinued variants sell residual stock? | Never / time-bounded / merchant-controlled | Owner/policy-controlled time-bounded residual listing, prohibited where policy blocks | Separates lifecycle from safe availability | Variant, listing, policy | P1 POLICY-SENSITIVE |
| Does a factory multipack become variant or product? | Always product / always variant / domain rule | Sellable pack identity under product family; exact persistence can vary by schema later | Preserves GTIN/unit comparison and simple discovery | Catalog, dedup, price | P1 |
| Can merchant-created bundles become canonical? | Never / immediate / reviewed promotion | Merchant-scoped first; promote only repeatable fixed composition with evidence | Avoids global catalog pollution | Bundle, merchant, search | P1 |
| Can shop media become canonical media? | Never / automatic / reviewed | Reviewed promotion with rights and exact identity evidence | Shop photo is useful but merchant-scoped | Media, moderation | P1 |
| How much price history is V1? | Current only / prior snapshot / full ledger | Current + observed timestamp; retain change audit, defer customer-facing full history | Avoids unsupported discount claims | Listing, customer, analytics | P1 |
| Should products with no nearby offer appear? | Always / never / context-dependent | Owner-defined discovery mode; default nearby-offer-first with explicit no-offer state | Core promise is nearby physical availability | Search, customer app | P1 |
| What revision/version surface is required? | Full temporal copies / monotonic revision / none | Monotonic revision + assertions/audit; no customer semantic version | Supports concurrency without enterprise overhead | APIs, index, audit | P2 |
| How long retain stale identifier/name aliases? | Forever active / effective intervals / delete | Permanent history with typed/effective ranking; never destructive reuse | Deep links and migration continuity | Search, dedup, analytics | P2 |

Priority summary: P0 **10**, P1 **7**, P2 **2**. Two rows are explicitly
policy-sensitive; legal/product authority is required in addition to technical review.
