# Merchant shop profile completion — J18

Branch: `agent/merchant-shop-profile-v1`

Base: `223ea5adf98e6f168a33c8b4fa082017c61f4ae4`

Authority: Product Owner approved the three-item implementation package on
2026-10-23. Canonical §4.21 and implementation slice J18 define its scope.
Main integration belongs to Integration Agent. No hosted access/write occurred.

## Delivered behavior

1. **Photo:** existing shops can stage one optional gallery photo, replace it or
   remove its reference. Input is capped at 5 MB, decoded/resized to at most
   1,024 pixels and re-encoded to PNG without camera/GPS metadata. Only an
   authorized active shop owner can upload to that shop's immutable namespace.
   The existing version-checked shop save publishes the reference. Uncertain
   saves use existing authoritative recovery; failed uploads do not replace the
   current photo. Onboarding first saves the shop, then allows photo selection.
   The existing Customer profile avatar displays the saved photo, with its old
   initials fallback on missing/unavailable images. No Customer redesign.
2. **Hours:** seven daily selectors offer time range, Closed and Unspecified;
   Monday can be copied to weekdays. One interval per day; an earlier closing
   time is labeled next-day, equal times are rejected. Existing free text and
   grouped keys survive untouched days. Customer profile/Nearby labels use the
   shared formatter. The old Customer owner form also preserves daily values
   during unrelated edits; explicit weekday edits replace the daily weekday
   overrides. Two failing regressions reproduced the original data-loss and
   ignored-weekday-edit cases before that compatibility fix.
3. **Location:** existing latitude/longitude fields are populated only after an
   explicit one-shot phone request, visible coordinates/accuracy/map preview and
   owner confirmation. Stale fixes, invalid coordinates and accuracy worse than
   100 m are rejected; existing values survive errors. No cached Customer
   position, reverse geocoding, background tracking, map SDK or paid API is added.
   Customer's existing direction action opens a route to the coordinate pair;
   address-only records retain their address fallback (not an exact-point claim).

No dependencies were added. Session continuation, ownership, optimistic version
checks and uncertain-save review are reused. Notification/Auth/economic systems,
feature defaults and delivered APKs remain unchanged. Shared touch points are
ShopEntity/ShopModel, the hours formatter and existing Customer shop surfaces.
The iOS permission descriptions were updated; iOS compilation/device acceptance
was not performed on Windows.

## Validation

- Full Flutter regression: **3,655 PASS / 0 FAIL / 6 existing conditional SKIP**.
- Local Auth/PostgREST/Storage: **15 PASS groups**, exact additive migration on a
  fresh populated base-core fixture. See
  [local evidence](data/merchant_shop_profile_local_acceptance.json).
- Source/manifest/permission compatibility before paired build: **135 PASS**.
- Customer `development` and Merchant `merchantPilot` arm64 debug builds: PASS.
  The final pair is an explicitly non-distributable compile rehearsal using
  synthetic public inputs, not an installed or hosted acceptance claim.
  Task-local records: `.buildlog/pilot-device/shop-profile-final/`.
- Narrow 320 px / 200% text checks, hours golden inspection, image decode and
  metadata removal, failed upload, stale/session-changed GPS/gallery completion,
  normal-session refresh, closed/unspecified and lost-save reconciliation covered.
- `flutter analyze --no-pub`: PASS, no issues. `git diff --check` and the scoped
  secret/PII scan: PASS. The evidence migration hash matches the delivered SQL.
  All task-owned local service stacks were stopped; their data/logs were retained.

Build hashes:

| Application | SHA-256 |
| --- | --- |
| Customer development | `fc4528130160f0e4a27a29c0c8eff9eccae49074af1c40f4d41f2a1c60ad32bd` |
| Merchant pilot | `ccc73b01b74d2e23199fbd667044fff5a0ec7e46710e7e56501e12a5495b1bf7` |

Earlier failed test runs were retained in ignored task logs. The failures were
the new migration inventory/preflight requirement, tests assuming the shorter
form or old search URL, a malformed synthetic PNG fixture, and the two reproduced
legacy-editor compatibility cases. No skip, weakened assertion or historical
qualification overwrite was used to obtain PASS.

## Concrete hosted Development proposal — NOT APPLIED

After Integration PASS and separate Product Owner approval, apply only
`20261023003200_0032_shop_profile.sql` to the existing approved Development
project, after read-only baseline/ownership/Storage and existing-name checks.
Do not apply the entire migration directory to that project.

The transaction adds `shops.photo_path`, its client column grants, one private
`shop-profile-media` bucket (JPEG/PNG/WebP, 5 MB), owned upload/read and current
active-photo read policies, and a guard validating uploaded references and
complete newly edited coordinate pairs. It does not rewrite existing shops or
hours, create accounts/products, change roles, activate flags or touch Production.
It requires canonical shops/profiles and managed Storage/Auth, and fails closed
if the column or bucket already exists unexpectedly. Old migrations are intact.

**Deployment order:** integrate code → approve and verify this Development-only
migration → produce a clean reviewed device candidate → install/update phones.
The new form sends the photo column; installing it on an unupgraded server would
cause saves to fail. Do not distribute the compile-rehearsal APKs.

Rollback starts with restoring the previous approved app candidate; preserve
the additive column, coordinates and objects. There is no automatic destructive
down migration. Any permission rollback or stored-object cleanup is a separately
reviewed operation, not part of this approval proposal. Unpublished/replaced
objects remain owner-only and are not deleted by clients.

Photo removal stops new authorized public reads/signing for the old reference.
The app requests 300-second signed URLs; this is not an immediate revocation or
erasure guarantee for already issued URLs, CDN caches or downloaded copies.
Expiry and caching are separate provider behaviors, as documented by
[Supabase Storage](https://supabase.com/docs/guides/storage/serving/downloads) and
[Smart CDN](https://supabase.com/docs/guides/storage/cdn/smart-cdn).

## Remaining manual gates (when the owner returns)

1. On an approved updated Merchant phone, select/save/change/remove a photo;
   refresh the corresponding Customer shop profile and check the result.
2. At the physical shop entrance, grant location permission, inspect/confirm the
   point, save it, then verify Customer's direction action reaches that entrance.

Daily hours are automated locally; include their saved display during the same
brief phone check. Earlier basic two-device QR acceptance remains historical
evidence; this package neither repeats it nor closes the remaining QR matrix,
provider, participant/distribution or pilot-opening gates.
