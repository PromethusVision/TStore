# W52K-D — Physical canonical Production smoke

**Result: PASS for the functional physical smoke.** Seller-card separation and shop-logo follow-ups remain open. Product imagery remains a placeholder. Public canonical activation remains **OFF**.

## Scope and frozen artifact

- Production: `mefhfvrgkwciubeajjeb`; no Development access.
- POCO X7 Pro (`2412DPC0AG`), Android 16 / SDK 36, authorized physical ADB device.
- Package `com.esnaftavar.app`, version `1.0.0+2`; built from main `6f765ef9fd22bdd5749f0fbe0eb99d2640091c37` with the W52K-C version increment.
- APK SHA-256: `97017d652781c50c2bcb331b442109bdb8d53b1b46f0b8c016f43de04eed581c`.
- Signing certificate SHA-256: `3B83D98AB8D32E0F3B9930FA837636E0E9E13219784FFCA39CEF8CAE82A6669B`.
- The exact frozen APK was upgraded with data-preserving replacement. Device readback hash and certificate matched. No uninstall, data clear, rebuild or re-sign.
- Evidence branch base: `1f6bb7b92c360888c9cdecfc7e9f4535d07c3be0`. Only this document and its JSON validation are in scope for commit.

## Tester authorization and server checks

Existing Auth identity was verified against the Production Auth server without recording identity or credentials. The old, expired entry was verified to belong to that exact subject and removed using the reviewed standalone removal function. The existing sealed Stage B granted one exact subject for **7,200 seconds**. Stage A, bridge deployment/modification, backup and migration were not run.

- Lease expiry: **2026-09-22T00:55:23.149Z** (22 September, 03:55:23 Turkey time). Let it expire naturally; no second extension.
- Sealed package: `e87a1a2b0a7eb19c0b11640c95eb617f5f1fce6fd207d0a28d900c63f6f4f2a7`, 39 verified inputs; 16 offline orchestration checks passed.
- Capability response: single-item JSON array, authorized exact subject, public activation OFF. All 10 preview RPCs returned HTTP 200 for tester and HTTP 401 for anonymous.
- 24 roots; real L2/L3/L4 and breadcrumb HTTP checks passed. Search, alias and exact product scope passed: 14 eligible products and 6 policy-gated products out of 20 mappings.
- Parent and child temporary DB password cleanup confirmed by local receipts and owner output.
- An initial connection attempt stopped before any write (`W52JB_PSQL_FAILED`). DNS/TCP checks passed and the subsequent owner-run attempt completed. The first connection failure was not further classified.

## Physical evidence and provenance

| Flow | Result | Evidence |
|---|---|---|
| Launch, Home, light presentation | PASS | Agent: installed package, UI hierarchy, sanitized image and logs |
| Home category limit | PASS — 8 real canonical roots | Agent: all eight cards/icons visible and readable |
| All Categories | PASS — 24/24 | Agent: exact names matched frozen taxonomy; all icons visible and readable |
| L2 → L3 → L4 and breadcrumb | PASS | Product Owner physical checklist |
| Product listing and details | PASS | Product Owner physical checklist; product image is a placeholder |
| Seller comparison | PASS functionally | Product Owner checklist; visual separation follow-up remains open |
| Shop details | PASS | Product Owner physical checklist |
| Search and back navigation | PASS | Product Owner physical checklist |
| Crash, ANR, endless loading, unauthorized preview error | None observed/reported | Owner checklist plus sanitized logs and Android exit history |

At the Product Owner request, the remaining phone navigation was completed as one manual checklist rather than separate screenshot steps. The agent did not independently witness or capture those later screens. The prescribed path was **Gıda & İçecek → Yağ & Sirke → Yemeklik Yağlar → Bitkisel Sıvı Yağlar**, opening **Ayçiçek Yağı 1 L**, inspecting sellers/shop, returning through the route, and searching **USB**.

The application remained running. 3369 application log lines were examined from the current launch; there were zero Flutter error-priority lines and no matched crash, ANR, uncaught exception, Supabase or preview authorization errors. Android exit history contained no current-test exit entry. Historical entries were excluded. Raw logs were not stored.

## Owner observations and open follow-ups

1. **Locked milk/egg leaves — expected under the current configuration.** The live child query returned HTTP 200 and six leaves: Süt, Yoğurt, Peynir, Ayran & Kefir, Tereyağı & Krema, Yumurta. All have `is_assignable=false`, `policy_class=REGULATED`, `professional_review_status=pending`. The frozen qualification table also marks them `POLICY_BLOCKED`. The client disables such leaves and displays a lock. This explains the configured behavior; it does not establish a legal requirement or settle whether the category classification should be retained. No gates were changed.
2. **W52KD-UI1: seller-card separation.** Owner reports adjacent seller cards are harder to distinguish than cards elsewhere. Functional comparison passed. Improve surface/border/spacing separation in a separate visual polish task; open and not fixed here.
3. **W52KD-UI2: shop logos on seller cards.** Owner requests shop logos. Carry this into seller-card visual polish with a consistent fallback when a logo is absent; open and not implemented here.
4. **Product image placeholder.** Owner confirmed the placeholder; do not interpret product-details PASS as proof of a real product photograph.

Source anchors: `docs/TAXONOMY_W36_ACTIVATION_QUALIFICATION.csv`, `lib/features/shop/domain/taxonomy/taxonomy_category_hierarchy.dart`, `lib/features/shop/domain/taxonomy/taxonomy_category_navigation.dart`, `lib/features/shop/presentation/views/taxonomy_browse_view.dart`.

## Final Production integrity

- Read-only postcheck: **PASS**, observed 2026-09-21T23:12:52.340Z.
- Products **20/20**, listings **285/285**, shops **57/57**, canonical nodes **1563/1563**; 24 roots, 1,245 terminal leaves and 20 exact owner mappings.
- Bridge ACTIVE, public activation OFF, canonical data staged, legacy SQL/HTTP PASS, ledger/schema/security PASS, 0012 unchanged.
- Counts and content fingerprints matched for all **32 public tables**. All legacy HTTP pre/post response hashes matched. This compares snapshots, not a full audit log of transient activity.
- Only the explicitly authorized exact tester allowlist was changed. No cart, wishlist, review, QR, checkout, payment, profile or storage mutation flow was run. Auth login was explicitly authorized.
- No application source changes, APK/AAB publication, Production taxonomy/product/listing/shop writes, or main merge.

## Privacy and disposition

Evidence contains no publishable-key value, password, signing secret, token, tester UID/email, device serial or absolute local user path. Login was owner-operated without screenshots. The personal Home greeting suppressed that screenshot; the owner scrolled it away before a safe image was collected. Images remain local and only their hashes are referenced in the JSON inventory.

Ready for Customer V1 taxonomy closeout and a **separate public activation decision**. This is not activation approval, does not clear all category policies, and does not close the seller-card visual follow-ups.

## TASK_RESULT

```text
W52K_D_PHYSICAL_CANONICAL_SMOKE: PASS
DEVICE_CONNECTED: PASS
DEVICE_MODEL: POCO X7 Pro (2412DPC0AG)
ANDROID_VERSION: 16
SDK: 36
FROZEN_APK_SHA256: PASS
APK_INSTALLED: PASS
VERSION_NAME: 1.0.0
VERSION_CODE: 2
TESTER_SESSION_VALID: PASS
TESTER_ALLOWLIST_RENEWED: YES
ALLOWLIST_TTL: 7200 seconds (2 hours)
SERVER_AUTHORIZED_PREVIEW: PASS
PUBLIC_CANONICAL_ACTIVATION: OFF
APP_LAUNCH: PASS
HOME: PASS
HOME_UP_TO_8_CANONICAL_CATEGORIES: PASS
ALL_CATEGORIES_24: PASS
RECURSIVE_L2: PASS
RECURSIVE_L3: PASS
RECURSIVE_L4: PASS
BREADCRUMB: PASS
PRODUCT_LISTING: PASS
PRODUCT_DETAILS: PASS
SELLER_COMPARISON: PASS
SHOP_DETAILS: PASS
SEARCH: PASS
BACK_NAVIGATION: PASS
CRASH: NO
ANR: NO
UNAUTHORIZED_PREVIEW_ERROR: NO
PRODUCTION_PRODUCTS: 20/20
PRODUCTION_LISTINGS: 285/285
PRODUCTION_SHOPS: 57/57
CANONICAL_NODES: 1563/1563
UNEXPECTED_PRODUCTION_WRITE: NO
MUTATION_FLOWS_RUN: NO
READY_FOR_CUSTOMER_V1_TAXONOMY_CLOSEOUT: YES
READY_FOR_PUBLIC_CANONICAL_ACTIVATION_DECISION: YES
```
