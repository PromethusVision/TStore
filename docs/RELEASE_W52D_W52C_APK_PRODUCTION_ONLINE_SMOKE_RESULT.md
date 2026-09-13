# ASTRA W52D — Exact W52C APK Production online smoke

Result: **completed with failed acceptance gates**. The corrected W52C APK is installed and reads Production successfully. The previous category/data loading failure was not reproduced. The required recursive category flow is unavailable in this frozen Production configuration, and dark-mode contrast problems affect product/review/shop read surfaces. The full W52D gate is therefore **FAIL**; neither subsequent readiness flag is granted.

## Scope and artifact

- Date: 2026-09-13; device work 19:32–19:52 UTC (22:32–22:52 Europe/Istanbul).
- Branch: `astra-release/w52d-production-online-smoke`.
- Binary source: `4f0da8201e2571200e99fa3dfe76387e3a1486ce`.
- Evidence branch base: `efc8ed155987507babfed64c19bdff1d4092955d`; its difference from the binary source is W52C documentation only.
- Artifact: `<release-root>/w52c/1.0.0+1-main-4f0da82/EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.apk`.
- APK SHA-256: `096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a`.
- Package/version: `com.esnaftavar.app`, `1.0.0`, version code `1`.
- Certificate SHA-256: `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- Signature verification: PASS, one expected signer, APK Signature Scheme v2 verified, not debuggable.
- Previous W51E APK: **SUPERSEDED**. It was inspected only for replacement compatibility and was not launched for this smoke.
- No rebuild, resigning, source change, migration, or store upload.

## Installation and device

Before device access, the local APK hash, signature, certificate, package and version were verified against the supplied frozen values. The physical target was exactly one authorized POCO X7 Pro, Android 16, SDK 36. No serial is included here.

The previously installed package had the same signing certificate and version code. A compatible replacement using `install --no-incremental -r` returned **Success** at 19:33:18 UTC. Installed APK readback and signature verification matched the exact W52C hash and certificate. Final installed hash verification at 19:52:08 UTC matched again.

Existing app data was preserved. No uninstall, clear-data command or downgrade was performed. The device had an active, validated default network and airplane mode was off. Network settings were unchanged.

The user confirmed guest use with no signed-in account. Only the target package was force-stopped and launched. An initial foreground check needed an Android 16 window-dump parser adjustment; the corrected check confirmed the app was already running. A later screen lock was resolved by the user. These were observation interruptions, not app crashes.

ADB screen input was rejected with `SecurityException` / `INJECT_EVENTS`. The user chose manual navigation instead of changing security settings. Subsequent taps and scrolling were performed by the user, followed by direct ADB screenshot inspection and filtered app-log checks. No input-security setting was changed. Scroll gestures are user-assisted evidence; reached screens were independently inspected.

## Production target and request evidence

- Project: `mefhfvrgkwciubeajjeb`; dashboard displayed **Healthy**.
- Contacted host: **`mefhfvrgkwciubeajjeb.supabase.co`**.
- All three native ABI payloads in the exact APK contained only the expected Production project URL. The installed APK hash matched that inspected binary.
- `lib/main_production.dart` initializes Production explicitly and uses `TaxonomyDependencyConfiguration.legacy(appEnvironment)`.
- At 22:37:51 device/dashboard time, the Production API Gateway recorded a successful app-client `GET /rest/v1/products`. Its inspected request detail showed the expected Production hostname, HTTP **200**, and a Dart client classification, correlated with the target app launch. No fresh PC data API query was issued during this W52D launch window.
- The same launch window showed HTTP **200** reads for `/rest/v1/shops`, `/rest/v1/banners`, and subsequently `/rest/v1/shop_products`.
- Category navigation windows showed HTTP **200** reads for `/rest/v1/products` and `/rest/v1/shop_products`; later product/seller/shop windows showed additional successful shop-product reads.
- Runtime target PASS is based on the exact installed binary, its Production-only URL, successful phone data loading, and the correlated server-side request. App logcat did not print a hostname; no hostname claim is attributed to logcat.
- No Development project was contacted or inspected.

The earlier W52C direct category read (HTTP 200, four active rows) remains historical W52C evidence. W52D does not present that PC result as a new phone row count or a new direct read.

## Navigation results

| Surface | Result | Observed evidence and limits |
| --- | --- | --- |
| Online launch | PASS | Target app foreground, guest Home rendered, no config/init failure. |
| Home | PASS | Three root category entries visible, search input, location-selection prompt and bottom navigation rendered. Previous category/data error absent. Guest location was not represented as a selected user location. |
| Category | PASS | Electronics and Stationery each opened a populated five-product list. |
| Recursive browse | **FAIL** | Home category taps entered product listing directly. The required category → subcategory chain was not exposed by the frozen legacy Production routing. This is a runtime capability/configuration gap, not a demonstrated RLS or schema error. |
| Product listing | PASS | Electronics showed five products and available merchant price minima; user scrolled. Stationery showed five products with the truthful “view shop price” fallback where no numeric offer was displayed. No sort control was exposed in the tested legacy list/search surfaces, so sort was not run. |
| Product details | **FAIL for full acceptance; data read PASS** | Adapter and cable names, descriptions and merchant price ranges loaded. Demo image placeholders rendered. Some stock/review text had very low contrast in the current system dark mode. Brand and an explicit seller-count label were not established by the observed detail surface; no claim is made that those criteria passed. |
| Seller comparison | PASS, legacy inline surface | Multiple seller cards displayed different prices, in-stock availability, demo shop/locality information and shop links. The user scrolled through the inline offers. A separate dedicated comparison route was not exposed/tested. No add-to-cart action. |
| Reviews read surface | PASS for data; visual issue recorded | Adapter reviews opened with rating 0.0 and zero reviews, an honest empty state, and a guest sign-in prompt. No sign-in or review submission. Heading/count/prompt contrast was poor. |
| Shop details | **FAIL for readability; data read PASS** | Shop identity, demo disclaimer, demo address, missing-hours fallback and multiple priced products loaded. Identity/address text was too faint on the light background in system dark mode. Directions/chat/favorite actions were not used. |
| Search | PASS | One query, `usb`, returned two products. Inline results → full results (2 products, 0 categories, 0 shops) → cable product details was verified. |
| Back navigation | PASS | User returned from reviews/shop/product/listing to Home and then opened another category and search. Reached destinations were inspected. |

Images were demo placeholders, not evidence that real catalog photography loaded. No production data was edited to improve these results. The synthetic catalog and demo shop disclaimer were visible; no real-user personal information is included in this document.

## Root-cause classification of failed gates

1. **APP_RUNTIME / capability configuration:** Production bootstrap selects the legacy taxonomy configuration. `HomeCategories._openCategory` routes a legacy category directly to `SubCategoryView`; canonical recursive destination construction is used only when a canonical node is supplied. Both inspected category paths behaved accordingly. The frozen APK cannot receive a recursive-browse PASS for the requested chain.
2. **APP_RUNTIME / theme mismatch:** the device reported `systemComputedNightMode=true`. `TStore` follows `ThemeMode.system`; `TAppTheme.darkTheme` supplies light text. The shop profile uses inherited heading/address text styles on fixed light brand surfaces. This source evidence explains the observed nearly white shop identity/address text. Product/review surfaces showed related contrast symptoms. The theme was not toggled, and no fix was applied.

The corrected Production key is functioning in this APK. Successful API reads and populated screens do not support classifying these two failures as KEY, DNS, RLS or SCHEMA failures. No exhaustive RLS/schema audit was performed.

## Read-only contract and write observation

Source read-contract review covered the executed guest discovery paths:

- Category repository: active categories via SELECT, ordered by `sort_order`; parent/subcategory methods are also SELECTs.
- Product repository: SELECTs with category/brand joins; search uses name/description matching and a result limit.
- Shop/offer reads: SELECTs over shops and shop-products with public product/shop joins. Mutation methods in the same repositories were not invoked by the test actions.
- Recent search queries and recently viewed product bookkeeping are local SharedPreferences operations, not server-side history writes.
- Reviews read uses `get_product_reviews`; the checked SQL body constructs the response from SELECTs. An HTTP POST to this RPC would be a read, not a review mutation. The guest eligibility path returns locally without requesting an authenticated mutation.

Production API Gateway observations included successful GET reads. A filter covering PUT, POST, PATCH and DELETE showed no entries in the selected observation window. The dashboard itself warned that log refresh can be delayed; this is **no unexpected write observed**, not a complete packet capture or a proof that every request was indexed. Source contracts and the performed actions provide the complementary safety evidence. Read RPCs are classified by their contract, not by POST alone. Health GET/HEAD entries from monitoring are not attributed to app Auth mutations.

No unexpected Production write was observed. No Auth, Storage, Cart, Wishlist, Review, QR, Profile, Address, Chat or notification mutation was performed as part of this task. No cleanup was attempted.

## Stability and evidence handling

- Final app-specific log scan covered the launch window and 2,182 log lines without storing raw logs.
- No FATAL EXCEPTION, ANR, native fatal signal, restart loop, Supabase configuration/init failure, PostgrestException, permission-denied classification or database error code was observed.
- Two generic “Error” occurrences belonged to `ActivityThread` / `MiuiPreloadClassImpl` tags; they were not presented as Supabase errors.
- App process remained present at inspected checkpoints. Android exit history contained no entry in the smoke launch interval; the latest retained entries predated W52D launch.
- No new automated tests, analyzer run or build was required for this evidence-only change. Runtime/source files were not edited. Earlier W52C build/test results are not claimed as newly rerun W52D tests.
- Working screenshots and sanitized device summaries remained in ignored local evidence storage. They are not included in the repository commit.
- This document uses generic local paths and contains no actual publishable key, signing password, private key, service-role/server secret, Auth token, device serial, request headers or personal-user data. APK/AAB files are excluded.

Cart V2 mutation, Wishlist mutation, Review mutation, QR verification, Profile edit, Address edit, Chat send, notification mutation and all Auth submissions: **NOT_RUN_BY_DESIGN**.

## Final flags

```text
W52C_EXACT_APK_VERIFIED: PASS
W52C_APK_INSTALL: PASS
PRODUCTION_TARGET_RUNTIME_VERIFIED: PASS
ONLINE_LAUNCH: PASS
HOME_PRODUCTION_SMOKE: PASS
CATEGORY_PRODUCTION_SMOKE: PASS
RECURSIVE_BROWSE_PRODUCTION_SMOKE: FAIL
PRODUCT_LISTING_PRODUCTION_SMOKE: PASS
PRODUCT_DETAILS_PRODUCTION_SMOKE: FAIL
SELLER_COMPARISON_PRODUCTION_SMOKE: PASS
SHOP_DETAILS_PRODUCTION_SMOKE: FAIL
SEARCH_PRODUCTION_SMOKE: PASS
BACK_NAVIGATION: PASS
CRASH_ANR_GATE: PASS
UNEXPECTED_PRODUCTION_WRITE: NO
AUTH_MUTATION_PERFORMED: NO
CART_MUTATION_PERFORMED: NO
WISHLIST_MUTATION_PERFORMED: NO
REVIEW_MUTATION_PERFORMED: NO
QR_MUTATION_PERFORMED: NO
REBUILD_PERFORMED: NO
DEVICE_DATA_CLEARED: NO
APP_UNINSTALLED: NO
STORE_UPLOAD_PERFORMED: NO
READY_FOR_PHYSICAL_TWO_DEVICE_QR_GATE: NO
READY_FOR_CUSTOMER_TECHNICAL_RC_DECISION: NO
```

The exact W52C APK remains installed. The failed recursive/readability gates require a separately authorized follow-up; this diagnostic did not patch, migrate, rebuild, merge main, or upload to a store.
