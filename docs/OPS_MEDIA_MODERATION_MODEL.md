# Media Moderation Model

**State:** PROPOSED — APPLIES ONLY WHERE MEDIA FEATURES EXIST

## Covered media

Merchant listing/shop images, product candidate media, review media if later supported, profile/support attachments, ad creative, and operator screenshots if explicitly enabled. Current feature availability must be verified; this document does not create upload capability.

## Risk classes

- malware/polyglot/invalid MIME or oversized payload;
- illegal, unsafe, hateful, sexual, violent, or exploitative content;
- PII, identity documents, payment/auth secrets, faces/plates/location metadata;
- counterfeit/brand/rights infringement;
- misleading product, price, before/after, certification, or medical claims;
- copied/low-quality/spam images;
- manipulated evidence or wrong-product media.

## Controls

Validate file type by content, size/dimensions, storage path and ownership; strip unnecessary metadata; isolate scanning/processing; generate safe derivatives; rate limit; record provenance/hash; provide report/review; restrict public serving fail-closed when unsafe. Automated classifiers are assistive signals, not sole high-impact decisions.

## Operator view

Use safe thumbnails/derived media and warnings. Raw download needs higher capability and audit. Never place secrets or full documents in notes. Preserve evidence reference and decision history even if public availability is removed.

## Decisions

`ALLOW`, `LIMIT`, `REQUEST_REPLACEMENT`, `REMOVE_PUBLIC`, `POLICY_REVIEW`, `SECURITY_INCIDENT`. Restoration creates a new decision event.

`MEDIA_RUNTIME_CHANGED: NO`

`AUTOMATED_FINAL_MODERATION: NO`
