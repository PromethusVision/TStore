# W49 Post-purchase, trust and messaging scope

Status: COMPLETE — 8/8 inventory units and all contained active surfaces PASS.
Ledger created before runtime edits; final acceptance recorded on 2026-09-05.

Base: `origin/main@cd1d566c36a669fc9b6cabeaee9a114979ae7fb7` (fetch verified).
Worker: `astra-ui/w49-post-purchase-trust-messaging-final-ui`.
Read-only visual contracts: W47/C1 `dfaa5d4c07319d2dc282bf7969fbc35f58a77067`
and visual sweep 3B `733b444445564a5d0efe263efdb5555ade7cf2de`.
All eight supplied visual references have been inspected. No Figma access.

## Exact denominator

Five full screens and three existing editor/confirmation units: **8 W46 inventory
units**. Their historical row estimates total 67 nominal hours; the requested
70–90 hour coherent package additionally includes cross-domain and final regression
work, not invented screens. States and nested compositions do not increase this
denominator. Approved Purchases C1 moves its existing creation placeholder out of
the third tab into an action sheet: four modal compositions after implementation,
still eight inventory units. Completion requires every child listed below.

| ID | Classification | Active surface and contained states/actions | Entry / implementation evidence | Status |
| --- | --- | --- | --- | --- |
| FS-30 | IN_SCOPE | Purchases: history, QR target/retry/missing target, items/amount/date, shop handoff, rating action, loading/empty/error/refresh; refund history placeholder and creation placeholder/action sheet | `settings_view.dart`, `cart_v2_view.dart`, notification destination → `purchases_view.dart` | PASS |
| FS-31 | IN_SCOPE | Shop rating history, rated purchases only, rating date fallback/sort, related purchase facts, loading/empty/error/refresh and empty CTA to Purchases | Account → `customer_ratings_view.dart` | PASS |
| MD-05 | IN_SCOPE | Shop rating sheet: 1–5 selection, no selection, submitting, failure/retry, success/close and history refresh | Unrated purchase → `_PurchaseShopRatingSheet` in `purchases_view.dart` | PASS |
| FS-32 | IN_SCOPE | Product review summary/distribution, own/other cards, verified server projection, guest/eligible/ineligible/previously deleted states, loading/empty/error/refresh | Product details/description → `product_reviews_view.dart` | PASS |
| MD-17 | IN_SCOPE | Review create/edit sheet: stars, optional title/comment, validation, keyboard, submitting/error/save | Review eligibility/card → `_ReviewEditorSheet` | PASS |
| MD-18 | IN_SCOPE | Review delete confirmation, cancel/delete, delete progress/failure | Own review → confirmation in `product_reviews_view.dart` | PASS |
| FS-33 | IN_SCOPE | Inbox: merchant identity, preview/time, unread/read where present, loading/empty/error/refresh and conversation handoff | Account/notification fallback → `conversations_view.dart` | PASS |
| FS-34 | IN_SCOPE | Conversation: merchant identity, incoming/outgoing bubbles, dates, actual send/read, composer/limit, pagination/scroll, draft, loading/empty/error and send failure | Shop/profile/seller, pending product intent, inbox, notification → `chat_view.dart` | PASS |

## Adjacent classifications

| Classification | Surfaces | Treatment |
| --- | --- | --- |
| ALREADY_FINAL | Account Hub, Auth/Startup, Product Details/description review entry, Shop Profile chat entry, Cart/QR purchase handoff, Home | Preserve final presentation and existing routing; verify relevant handoffs only |
| RESERVED_OTHER_AGENT | Wishlist, Recently Viewed, Notifications, Coupons, other customer library utilities; location/cart secondary modals | No implementation changes; Notifications may continue to route to this domain |
| RESERVED_OTHER_AGENT | Global ST02/ST03 state families, core UI/theme, central navigation/providers/listeners, common test harness | Local domain states use existing primitives; no global closeout claim |
| INACTIVE_LEGACY | Legacy order/shipping/detail/refund code without active Customer entry; legacy Address/Store/Orders; MD-10 merchant-login compatibility path | Excluded from active Customer denominator; no new route or behavior |
| NOT_CUSTOMER_RUNTIME | Merchant transaction/rating management, backend/RPC/migrations, realtime infrastructure | Read contracts when needed; no writes or rule changes |

## Preserved business truth

- Purchases are merchant-confirmed physical QR purchases. Purchase items expose
  `shopProductId`, name, quantity and monetary fields, not canonical product ID or
  product image. There is no current purchase detail route or direct purchase →
  product-review route. Do not manufacture either.
- Refund history and creation are reachable preparation placeholders, with no
  refund submission contract. Two peer tabs only; creation becomes an action and
  retains its existing return-to-purchases behavior.
- Shop ratings use the source QR session, bounds 1–5 and existing submission
  enforcement. Already-rated purchases have no edit/update action. History stays
  filtered to rated purchases and sorted by rating date, falling back to confirmation.
- Product eligibility stays server-authoritative: merchant-confirmed immutable
  evidence, customer + canonical product uniqueness, indefinite edit, preserved
  evidence on delete/recreate, no extra rights for repeat purchases or quantity.
  The review-list RPC projection is preserved; the stored legacy boolean alone is
  not authority. No review image feature.
- Messaging preserves receiver user IDs, subscriptions, lifecycle/read guards,
  pagination, grapheme limit, draft and send behavior. No invented merchant-header
  navigation, attachments, online/typing indicators or order semantics.

## Validation and checkpoint plan

1. Scope + Purchases; 2. Shop Ratings; 3. Product Reviews; 4. Messaging;
5. responsive/visual evidence and cross-domain checks; 6. final regression/report.
Targeted tests after each domain. One final analyzer and full Flutter suite against
the 1841 passing / 0 failing / 6 existing gated skips base. No new skips or weaker
assertions. Major screens at 320/390/430 and 130%, long Turkish content, 44/48 px
controls and keyboard-safe sheets. Actual runtime visual evidence for the eight
approved surfaces plus useful stress examples. Diff, secret/PII and ownership review
before task-branch checkpoints; no main merge/push.

## Final acceptance

All 8 scoped inventory units were attempted and completed (100%); no unit was
removed from the denominator. Five full screens, three existing modal units and
one refund action-sheet composition are active. Local loading/empty/error,
eligibility, mutation and messaging states remain contained in their parent units.

69 new tests; 253 combined domain tests; full suite 1910 PASS / 0 FAIL / 6 unchanged
gated skips; full analyzer clean. 22 new actual-runtime goldens, all visually
inspected; the 198 existing goldens are unchanged. Source/test acceptance revision:
`1f294fdfd2e41456cc82bb0053c703a24025121a`. See
[W49 result](UI_W49_POST_PURCHASE_TRUST_MESSAGING_RESULT.md) for the checkpoint,
cross-domain, test and safety evidence. No shared component or business-rule edits.
