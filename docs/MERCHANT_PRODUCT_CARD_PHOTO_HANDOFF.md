# Merchant upload → Customer card photo repair

Task branch: `agent/merchant-product-card-photo`

Base: `6c4795464f6afdb2f794222873a879e534d87642` (integrated shop profile package).
Integration Agent owns main merge. This package performs no hosted access/write.

## Reproduced problem

The owner sees an uploaded listing photo in Customer Details, but a sample image
on product cards. Home/discovery read central product images, and the active shop
composition reads only legacy listing images before falling back to the catalog.
Neither resolves published managed media through the existing listing-media port.
The defect was reproduced before the repair in Home and the visible active shop
card; a managed photo with an empty legacy image list was absent from the card.
Local logs: `.buildlog/card-reproduced-corrected.log` (Home) and
`.buildlog/shop-card-reproduced.log` (visible shop card).

## Changes and boundaries

- Shared `ProductCardImage` and coalescing `ProductCardMediaLoader` reuse
  `ListingHeroMediaRepository`, existing listing reads and seller ranking.
- Home, catalog/search/category, wishlist/history, shared vertical/horizontal
  cards, shop cards and cart thumbnails now use eligible published listing media.
  Shop/cart candidates are limited to their exact listing. General discovery uses
  the existing default nearest ranking when a preferred/cached location is known.
- Reuse loaded listing batches; other visible requests coalesce, with at most 100
  product IDs per listing read. Existing media/signing batches remain unchanged.
  No additional GPS request, dependency, catalog image write or new cache service.
- Primary/remaining photos and permitted seller fallbacks retain server order.
  Empty/error/timeout results show the existing placeholder. Managed failures
  cannot resurrect obsolete legacy or stock catalog images. Replaced requests
  clear previous photos and ignore late replies, including after disposal.
- The default Customer shop header now uses the already implemented shop-photo
  widget; the previous package had connected the legacy composition only.
- Preserve current card geometry/actions. Golden fixture photos are explicitly
  attached to synthetic eligible listings. Historical golden files are unchanged;
  the only new golden proves actual loaded card photo pixels and semantics.
- Canonical §4.22 and implementation slices record this repair under existing
  FROZEN photo rules. No pricing, purchase, eligibility or feature-flag changes.

## Verification

- Full Flutter regression: **3676 PASS, 0 FAIL, 6 existing conditional SKIP**
  (`.buildlog/card-full-final.log`). No new skipped or weakened tests.
- Existing visual/screen fixtures: **102 PASS**, without changing old golden
  images (`.buildlog/card-visual-recheck.log`); covers narrow layouts, enlarged
  text, loading/error states and actions. New media tests cover batch boundaries,
  eligibility, ordering, exact-listing isolation, stale responses and disposal.
- Customer + Merchant Android development debug compile rehearsal: **PASS**.
  Configuration/compatibility checks: **135 PASS, 0 FAIL, 0 SKIP**. APK manifest,
  certificate, version, payload markers and unchanged build sources verified.
  `.buildlog/pilot-device/card-photo-final/pair.json` records
  `COMPILE_REHEARSAL_PASS_NOT_DISTRIBUTABLE`; synthetic client inputs only.
- Source snapshot SHA-256:
  `63e36670c4e5243ab18344d3bf5fcc876edee10836425babdb7096b2af5e3548`.
  Customer APK SHA-256:
  `1a531c1fbeb6992e22f8ee87ade8361b747daccf3381e3a2ca95eaad5969d645`.
  Merchant APK SHA-256:
  `10c1ec8cd073e064cedb017ed8eb1ede9fb72c0aa096771aa9c42e8727bdf103`.
- Added-line/new-file secret and personal-account scan: **PASS**.
  Evidence is task-local under `.buildlog/`; build inputs/APKs are not Git artifacts.
- `flutter analyze --no-pub`: **PASS, no issues**
  (`.buildlog/card-analyze-final.log`). Formatting and `git diff --check`: **PASS**.

## Integration and manual gates

Shared areas: service locator, Customer card compositions, shop/cart image widgets,
canonical and implementation-slices documents. No routing, authentication,
notification, dependency or SQL/migration changes.

No Production or hosted Development access/write; no migration applied. The earlier
0032 shop profile deployment/approval gate is independent of this existing-media
card repair. Previously delivered APKs remain intact. Compile rehearsals are not
installable pilot delivery candidates and do not establish field acceptance.

After integration and an approved device package, one physical check remains:
confirm the uploaded photo appears on Customer Home/shop card/Details/cart, with
the shop and cart retaining the selected merchant's photo. The owner need not be
at the phones to integrate this tested repair. Pilot opening is not declared.
