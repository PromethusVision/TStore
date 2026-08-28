# Web Build Role

**State:** COMPILE CONTRACT — NOT COMMERCIAL WEB PRODUCT

The repository's synthetic Production web build is useful because Dart tree shaking, imports, generated plugin wiring and production entrypoint/config validation exercise code paths without mobile signing. It must remain explicitly non-deployable.

## May prove

- release-mode Dart compilation;
- production entrypoint dependency graph;
- icon/font tree-shaking compatibility;
- missing/invalid config fails closed under compile-contract inputs;
- some platform-independent source errors.

## Cannot prove

- Android/iOS manifest, signing, permissions, camera, GPS or deep links;
- a customer-approved commercial web application;
- browser security headers, hosting origin, OAuth callback or web responsive acceptance;
- Production connectivity or deployment authorization.

## Gate usage

Use as a low-cost release compile check, especially on non-macOS runners. Store output briefly or discard; never promote it to a web hosting target without a separate product/security/release decision.

`COMMERCIAL_WEB_APP: NOT_IN_SCOPE`
