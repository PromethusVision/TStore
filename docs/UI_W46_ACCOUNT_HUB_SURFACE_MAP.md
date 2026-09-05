# W46 Account Hub — authoritative surface map

Base: `origin/main@6cc5d1607da96415f788d5324006bc89fe85d554` after `git fetch origin --prune`. This exactly matches the requested minimum; no newer commits required overlap review. Clean fresh branch: `astra-ui/w46-account-hub-final-ui`. Previous W45B branch state was not carried forward.

Authority: AGENTS, Astra execution protocol, calibration log, W45 post-calibration inventory, Wave 2 recommendation, Final UI rollout and W39 ownership. Current user instructions preserve this conversation and forbid all Figma access, including the inventory's LIGHT references.

| Unit | Reachable surface | Entry and preserved contract |
| --- | --- | --- |
| FS-22 | Settings / account hub | NavigationMenuCubit customer tab; guest header signs in and returns; protected menu destinations require a current customer; public Help and Privacy remain public; unread refresh remains intact. |
| FS-23 | Profile details | Authenticated header or Hesap Bilgilerim; real name, email, optional phone; no invented personal fields. |
| FS-24 | Saved locations | Protected hub and Help entry, plus existing Home, Nearby and product-seller handoffs; loading/error/retry/empty/list, add, delete and Ana Konum Yap. |
| FS-25 | Privacy and permissions | Public hub entry; read and refresh permission status only, no GPS request; existing informational/legal copy unchanged. |
| FS-26 | Help and support | Public hub entry; three existing protected callbacks, expandable FAQ and selectable support email. |
| MD-06 | Edit profile bottom sheet | Profile button; editable name/optional phone, immutable email, existing validation, duplicate-submit lock, updating/error/success return and AuthCubit profile sync. |
| MD-07 | Account deletion confirmation | Profile danger section; typed SİL, cancel, busy lock/back protection, error, existing deletion callback and successful local cleanup/navigation. |
| MD-08 | Add saved location sheet | List/empty action; required name/address description plus explicitly captured GPS coordinates, capture/save progress and existing failures. **No edit surface exists.** |
| MD-09 | Delete saved location dialog | Each location's delete button; cancel/confirm, duplicate resolution guard, existing repository removal and feedback. |

Total: **5 screens + 4 sheets/dialogs = 9 units (7 B, 2 C), nominal historical 44 hours**. This estimate is not a wall-clock promise.

## Actual capability boundaries

- Saved location Cubit/repository expose get/add/set-default/delete; no edit/update contract or reachable edit action. The W45 “add/edit” label resolves to add only. Do not invent editing, geocoding, coordinates, distance or address validation.
- Selection is the existing `setDefaultLocation` / “Ana Konum Yap” action; first added location becomes default and removing the default preserves current fallback behavior. Existing Home/Nearby handoff is regression-tested, not redesigned.
- `AppSettingsSection` signs out directly. There is no logout confirmation to convert. Preserve session check, cart/wishlist clearing, home tab and navigation reset.
- No class named `AuthGuard` exists in current lib. Its actual equivalents remain unchanged: `NavigationMenu._handleDestinationSelected` gates customer tabs (index >= 2); SettingsView checks the current customer and uses return-to-caller login; `CustomerSessionListener` handles session changes and cleanup. Guest/expired/stale account render states remain supported and tested.
- KVKK and Terms reuse Auth's integrated legal views without content or presentation duplication.
- Notifications, chat, purchases, ratings, coupons and recent history retain navigation entries only. Their destination UI is excluded. Legacy address/profile helper views remain inactive; no route activation.

## Edit ownership and verification

Changes are restricted to the five personalization views, their account-only presentation widgets, account tests/evidence and W46 docs. Existing core Final UI components/theme and Auth form composition are reused. No changes to shared core primitives, routes, global state, cubits, repositories, domain models, SDK/dependencies, backend, auth configuration, taxonomy, Shop, Cart or Nearby implementation.

Baseline from integrated main: **1637 pass, 0 fail, 6 pre-existing skips**. Run scoped baseline and checkpoint tests, responsive 320/390/430 at 100%/130%, keyboard and long Turkish content, functional state/guard tests, representative goldens, then one final analyzer and full suite. No assertion weakening, new skips or test loss. All runtime calls in verification use local mocks/fakes; no Production or remote Development writes.
