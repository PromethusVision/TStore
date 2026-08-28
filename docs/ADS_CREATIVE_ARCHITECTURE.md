# Sponsored Creative Architecture

**State:** PROPOSED — NO FINAL UI, MEDIA PIPELINE OR RUNTIME

## Creative forms

| Form | Source | V1 posture | Main risk |
|---|---|---|---|
| Native sponsored product/listing card | Existing listing/product/shop truth | **RECOMMENDED** | Disclosure loss in card variants |
| Sponsored seller row | Existing exact seller listing | OWNER DECISION / PILOT | Paid top row may be mistaken for best/nearest |
| Merchant/shop card | Shop profile truth | FUTURE | Implied endorsement; branch/location ambiguity |
| Banner campaign | Separate reviewed creative | DEFER | Duplication, unsafe claims, asset/moderation burden |

## V1 native creative

The ad composes canonical/shared product facts with current listing/shop facts; it
does not duplicate them into merchant-authored ad content:

- canonical product/variant name and governed media;
- listing price and availability timestamp;
- shop identity and real distance;
- merchant-provided approved local description only where necessary;
- persistent `Sponsorlu` label and why/report controls;
- immutable served snapshot/revision references.

## Truth-source ownership

- Product identity/media: governed catalog.
- Price/stock/shop SKU: listing.
- Shop name/location: shop identity.
- Sponsored state/disclosure: ad system.
- Badge/reputation: server-authoritative reputation system.
- Taxonomy/sector: targeting context, not creative claim.

## Creative review triggers

Custom text/media, price/discount claim, regulated product, merchant badge claim,
shop relocation, target identity change or policy update may require re-review.
Ordinary price refresh from the listing should not create a contradictory cached ad.

## Prohibited behavior

- copying price/stock into stale campaign fields;
- hiding `Sponsorlu` in image or overlay;
- claiming “nearest”, “cheapest”, “verified” or “recommended” because of spend;
- promoting a category without an eligible listing;
- merchant-editable review/verification badge;
- banner click resolving to a different product/shop than advertised.

`ADS_V1_CREATIVE: NATIVE_SPONSORED_LISTING_CARD`

`TRADITIONAL_BANNER_REQUIRED_V1: NO`

`CREATIVE_UI_FINALIZED: NO`
