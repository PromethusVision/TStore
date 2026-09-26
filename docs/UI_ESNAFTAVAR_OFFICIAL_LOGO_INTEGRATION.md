# Official Customer logo integration

Base: `d43ee49032ce786612ae10e11c96e8072ae33696`.
Branch: `ui/esnaftavar-official-logo-integration`.

## Authoritative asset

The Product Owner explicitly supplied
`<PRODUCT_OWNER_LOCAL>/Codex Görseli 9 Eyl 2026 05_10_47.png`.
The byte-for-byte repository copy is `assets/logos/esnaftavar-logo.png`.
The original file was not modified. Both copies have SHA-256:

`a87dc38bcd50dd2650c71257e664c744ad28982f8eddd452f50029c6fe25fb30`

The valid 2172 × 724 PNG has a 3:1 aspect ratio, 1,187,206 fully transparent
pixels, 381,260 partially transparent pixels, and 4,062 opaque pixels.
All four corners are transparent; there is no opaque background rectangle.
The logo remains legible at the reviewed Home sizes. No drawing, recoloring,
cropping, or replacement artwork was introduced. Existing `assets/logos/`
registration bundles the asset without a pubspec or dependency change.

## Home and native launch

Home's two existing header presentations now use `CustomerBrandLogo` in the
existing branding slot. The image scales down within the available width,
retains all original margins, and exposes one `EsnaftaVar` image semantic label.
It does not duplicate the wordmark as visible text. Greeting, notification
actions, authentication handling, and navigation remain unchanged.

Android and iOS native launch previously used the T-Store artwork. Their
existing generated splash resources now use the official artwork, centered on
white in both system appearances, consistent with the Customer light theme.
Normal launch size is 228 × 76 logical pixels. Android 12 uses a transparent
288 × 288 logical-pixel canvas with a centered 180 × 60 logo rectangle; its
entire rectangle fits within the platform's 192-pixel circular safe area.
No black/white variants were synthesized.

To reproduce native resources on Windows, with the project's Dart SDK on PATH:

```powershell
pwsh -File tool/generate_customer_splash.ps1
```

The script reads only the official repository asset, prepares ignored 4x inputs
under `build/branding/`, and invokes the existing `flutter_native_splash`
generator. It preserves base Android styles so API 28/29 attributes stay in the
existing version-qualified resources. Temporary inputs are not committed.
Native resource generation was rerun successfully with the preservation check.

Legacy logo files and launcher-icon configuration remain available for existing
historical/Merchant uses. Auth widgets and the Flutter launch gate are unchanged.
No legacy T-Store artwork remains in Home or the native Customer splash.

## Verification

- Targeted asset, Home widget, and Home layout tests: 35 passed.
- Home golden tests: 17 passed while updating 15 existing baselines. These
  comparisons include the changed branding, so baseline regeneration was
  necessary. No standalone screenshots or unrelated baselines were added.
- Visual review: current 390 px Home, 320 px header layout, and Android 12
  padded artwork. Tests cover 320/360/390/430 px headers at 100/130/200% text
  scale, 72 px constrained logo width, semantic label, source hash/PNG alpha,
  native density sizes, light/dark equivalence, and the Android 12 safe circle.
- `flutter analyze`: PASS, no issues.
- `flutter test --no-pub --reporter expanded`: PASS, 2,198 passed and six
  opt-in live tests skipped. No live-test opt-in was supplied.
- `git diff --check`: PASS. Scoped secret/PII scan: no findings in changed
  source/configuration/documentation or personal-path markers in the PNG.
- Native splash validation covers generated resources and their wiring;
  no physical-device or iOS simulator verification is claimed.

Backend, Supabase, Production, taxonomy, QR, reviews, verified purchases, Auth,
Merchant implementation, navigation rules, and migrations were not changed.
No Production access or write occurred. The two-device physical QR gate remains
**OPEN**.
