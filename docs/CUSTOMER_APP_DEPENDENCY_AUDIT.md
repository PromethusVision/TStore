# Customer App Dependency Health Audit

Status: PASS WITH PLANNED UPGRADE BACKLOG

Command: `flutter pub outdated --no-dev-dependencies` on 2026-08-28. The command succeeded; no lockfile or manifest was changed.

## Result

- 68 direct/transitive packages are locked below an upgradable version.
- 7 direct constraints are older than a resolvable version.
- Current high-impact direct versions include Supabase Flutter 2.12.0, app_links 6.4.1, mobile_scanner 7.2.0, geolocator 14.0.2, permission_handler 12.0.1, Dio 5.9.0, and logger 2.6.2.
- Supabase Flutter resolves to 2.17.2 within the present major range, but Auth/deep-link/realtime behavior makes this a dedicated compatibility upgrade, not a casual lock refresh.
- Available major-line changes include app_links 7, geocoding 5, permission_handler 13, shimmer 4, and smooth_page_indicator 3. These require platform/API/regression review.
- Several small compatible updates exist (for example carousel, geolocator, get_it, shared_preferences, URL launcher platforms).

`pub outdated` is version-health evidence, not a vulnerability scanner. No concrete advisory was established by this command, and the audit does not claim vulnerability-free dependencies.

## Recommendation

After feature freeze, run small grouped upgrades: (1) Auth/Supabase/app-links, (2) location/permissions, (3) camera/media, (4) UI-only packages. Each group requires targeted physical/static tests and lockfile review. Do not mass-upgrade during closeout.

`DEPENDENCY_AUDIT: PASS`
`MASS_UPGRADE_PERFORMED: NO`
`DEDICATED_UPGRADE_BACKLOG: YES`
