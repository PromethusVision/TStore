# Customer App Build Output Audit

Status: **PASS — SYNTHETIC COMPILE OUTPUT ONLY**  
Wave: **16 — Customer App Commercialization Closeout**

## Output

| Metric | Value |
|---|---:|
| Artifact type | Flutter Web release directory |
| Entrypoint | `lib/main_production.dart` |
| Config class | Tracked synthetic compile contract; deployment authorization NO |
| Build command | Standard release, icon tree shaking enabled |
| Build time | 41.1 seconds |
| File count | 146 |
| Total uncompressed bytes | 89,608,619 bytes (~85.46 MiB) |
| `main.dart.js` | 3,947,069 bytes (~3.76 MiB) |
| `main.dart.js` SHA-256 | `15853B34EF2DAE7127E2FDB082E2CA15E094F7FB78E01ED5724F9CD35E702F29` |

The output lives in ignored `build/wave16-web/`; it is not committed and must
not be deployed.

## Compiler observations

- Wasm dry run succeeded; the current output remains the normal JavaScript web
  build because Wasm rollout was not part of this closeout.
- `FlutterIconsax.ttf` tree-shook from 670,228 to 8,064 bytes (98.8%).
- `MaterialIcons-Regular.otf` tree-shook from 1,645,184 to 26,984 bytes (98.4%).
- `CupertinoIcons.ttf` tree-shook from 257,628 to 1,472 bytes (99.4%).
- No icon tree-shaking workaround was used and no compilation warning blocked
  the artifact.

## Size finding

The largest shipped asset is a review placeholder/profile image at 12,794,173
bytes. Several banners and onboarding GIFs are also multi-megabyte. This is
`CUST-ASSET-001` (`P2`, `ACCEPTED_RISK`) for a dedicated asset optimization and
visual-QA task. It is not modified here because re-encoding may change visual
quality and final UI-kit choices; no premature build-size optimization was
performed.

## Scope boundary

This compile proves source compatibility, Production-entrypoint selection and
standard icon tree shaking. It does **not** prove live Production startup, Auth,
RLS, web hosting, CDN/cache headers, browser compatibility, signed Android/iOS
packaging or store acceptance.
