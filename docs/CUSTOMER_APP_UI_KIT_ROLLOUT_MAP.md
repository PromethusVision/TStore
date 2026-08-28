# Customer App UI-Kit Rollout Map

Status: **PREPARATION ONLY — NO VISUAL CHANGE**
Wave: **16 — Customer App Commercialization Closeout**

The current UI kit is explicitly non-final. Functional defects and cosmetic
replacement work are kept separate.

| Screen / component | Current functional state | Rollout classification | Future UI-kit dependency |
|---|---|---|---|
| Startup/config failure | PASS | ALREADY_ACCEPTABLE | Final error illustration/copy tokens only |
| Login/signup/verify/recovery | PASS | NEEDS_FIGMA_DECISION | Form fields, legal-consent layout, success/error feedback, focus/keyboard states |
| AuthGuard/login-return flow | PASS | NEEDS_FIGMA_DECISION | Canonical guarded-action sheet/page and return affordance |
| Home | PASS | NEEDS_FIGMA_DECISION | Header, discovery sections, product/category cards, skeleton and empty/error compositions |
| Category/listing | PASS | NEEDS_FIGMA_DECISION | Filter/sort controls, cards, pagination/footer states |
| Search overlay/results | PASS | NEEDS_FIGMA_DECISION | Recent searches, suggestion rows, no-result and partial-error states |
| Nearby/location | PASS_LOCAL | NEEDS_FIGMA_DECISION | Permission explanation, status banners, distance presentation |
| Product Details | PASS | NEEDS_FIGMA_DECISION | Gallery, price hierarchy, seller/review sections, sticky actions |
| Seller Comparison | PASS | NEEDS_FIGMA_DECISION | Price/seller row hierarchy and availability states |
| Shop Details | PASS | NEEDS_FIGMA_DECISION | Shop identity, products and contact/action presentation |
| Wishlist | PASS | COSMETIC_ONLY | Empty/error/list cards |
| Cart V2 | PASS | NEEDS_FIGMA_DECISION | Conflict confirmation, quantity controls, QR entry and totals |
| QR session sheet | PASS_LOCAL | FUNCTIONAL_BLOCKER_EXTERNAL | Visual polish is deferred; physical camera/two-device gate is the blocker |
| Profile/settings | PASS | NEEDS_FIGMA_DECISION | Account actions, privacy/permissions and destructive-action hierarchy |
| Saved locations | PASS | NEEDS_FIGMA_DECISION | List/editor and permission feedback |
| Reviews | PASS | NEEDS_FIGMA_DECISION | Aggregate, eligibility, composer and verified badge |
| Notifications | PASS | COSMETIC_ONLY | Read/unread states and empty list |
| Chat/conversations | PASS | NEEDS_FIGMA_DECISION | Thread bubbles, product context and draft-resume notice |
| Bottom navigation/badges | PASS | NEEDS_FIGMA_DECISION | Final icons, selected states, safe-area and badge tokens |

## Rollout order

1. Foundations: color, typography, spacing, radius, elevation, motion and
   accessibility tokens.
2. Shared primitives: form field, button, card, list row, state panel, dialog,
   skeleton, badge and image fallback.
3. Revenue journey: Home → listing/search → Product Details → seller/shop →
   Cart V2 → QR.
4. Trust journey: Auth/Profile → reviews → notifications/chat/settings.
5. Cross-device golden, text-scale, semantics and physical acceptance.

No current cosmetic variance was treated as a functional failure. The only
UI-adjacent release blocker is physical proof that QR and platform callbacks
remain usable on the final artifacts.
