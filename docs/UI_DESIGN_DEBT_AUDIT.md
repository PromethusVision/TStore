# UI Design Debt Audit

> Static analysis scope: 131 Dart files under presentation views and widget
> directories at Wave 27 base. Counts are lexical indicators, not automatic bugs.

## Executive finding

The Customer App has a functioning but fragmented visual layer. The main risk is
not a single bad color; it is the coexistence of a cold global theme, a scoped Home
V1 palette, direct Material styling and large view-local components. A screen-wide
recolor would hide, not resolve, that fragmentation.

## Literal/style indicators

| Indicator | Occurrences | Files | Interpretation |
|---|---:|---:|---|
| `Color(0x...)` | 92 | 26 | Raw colors outside semantic tokens |
| `Colors.*` | 300 | 71 | Includes legitimate white/transparent but also uncontrolled semantics |
| `EdgeInsets...` | 381 | 81 | Spacing values are highly distributed |
| `SizedBox...` | 769 | 89 | Mixes layout gaps and fixed sizing |
| `BorderRadius.circular` | 301 | 60 | Radius decisions are local |
| `TextStyle` | 327 | 43 | Theme/type hierarchy bypassed frequently |
| `fontSize:` | 309 | 45 | Direct type sizing rather than semantic roles |
| `Border.all` | 132 | 50 | State and surface borders are locally defined |
| `InputDecoration` | 34 | 14 | Form variants do not share one contract |
| Elevated / Outlined / Text buttons | 21 / 39 / 73 | 14 / 18 / 26 | Button hierarchy varies by screen |
| `IconButton` | 60 | 37 | Touch target and tooltip audit required |
| Direct `Semantics(` / `Tooltip(` | 13 / 3 | 12 / 3 | Narrow lexical count; broader audit found 58 semantics/tooltip call sites |

These numbers must not be “fixed” by blind replacement. `Colors.transparent`,
image overlays and platform/status colors can be valid; each use must map to a
semantic role or documented exception.

## Highest raw-color burden

| File | Raw color indicators | Rollout treatment |
|---|---:|---|
| `privacy_and_permissions_view.dart` | 20 | Move after critical commerce screens; retain permission meaning |
| `vertical_product_card.dart` | 20 | Replace through canonical ProductCard, not one-off recolor |
| `purchases_view.dart` | 17 | Preserve verified-purchase meanings and filters |
| `shop_profile_view.dart` | 14 | Migrate actions and shop status by semantic role |
| `help_and_support_view.dart` | 13 | Defer until shared list/state primitives exist |
| `product_shimmer.dart` | 12 | Replace through skeleton tokens with reduced-motion support |
| `nearby_view.dart` | 10 | Coordinate color migration with location states |
| `rounded_image.dart` | 10 | Consolidate media surface/fallback roles |

## Highest layout/type literal burden

Combined EdgeInsets, SizedBox, radius, font-size and shadow indicators:

| File | Indicators | Main concern |
|---|---:|---|
| `purchases_view.dart` | 130 | Dense stateful composition |
| `cart_v2_view.dart` | 88 | Totals, quantity, confirmation and QR composition |
| `customer_saved_locations_view.dart` | 80 | Forms, permissions and status surfaces |
| `nearby_view.dart` | 70 | Narrow-screen/location behavior |
| `all_products_view.dart` | 69 | Search/list/grid/pagination density |
| `shop_profile_view.dart` | 59 | CTA hierarchy and multiple shop states |
| `chat_view.dart` | 58 | Keyboard, message and realtime states |
| `privacy_and_permissions_view.dart` | 55 | Legal/permission clarity |
| `product_reviews_view.dart` | 55 | Editor/eligibility/display hierarchy |
| `customer_notifications_view.dart` | 54 | Read/unread and action consistency |

## Theme fragmentation

| Layer | Current source | Risk |
|---|---|---|
| Global ThemeData | `TAppTheme`, `TColors`, widget themes | Cold blue/violet legacy palette and global behavior |
| Home visual island | `CustomerHomeV1Tokens` | Warm local-commerce direction, but scoped and not canonical Wave 14 mapping |
| Direct Material values | 71 files use `Colors.*` | Theme bypass and dark-mode surprises |
| Local Theme/InputDecoration | Feature/view code | Validation, focus and disabled states drift |
| Figma canonical tokens | Documentation/manifest | Not connected to Flutter runtime yet |

## Component duplication

- Product cards exist as core public widgets and private screen-specific versions.
- Shop/merchant identity is represented by `brand_*`, seller rows and private shop
  widgets with inconsistent naming.
- Loading, empty, error, retry and image fallback patterns recur with different
  spacing, iconography and action hierarchy.
- Cart V2 contains most visual pieces as private classes inside the view.
- Dialogs and sheets mix direct `showDialog`/`showModalBottomSheet` composition with
  reusable feature widgets.
- Button, field, tile, badge and status styles are partly themed and partly local.

## Typography debt

Poppins is globally declared, but 327 local `TextStyle` and 309 direct `fontSize`
assignments bypass a consistent hierarchy. Risks include:

- labels shrinking below accessible/readable sizes, notably current bottom-nav
  labels at 8.5 px and badges at 8 px;
- inconsistent weight used as the only hierarchy cue;
- fixed line counts cutting long Turkish product/shop/category labels;
- price, stock, distance and metadata competing for emphasis;
- dark-mode colors being selected locally rather than through text roles.

## Shape, elevation and density debt

The current UI has 301 local circular radii but only one literal `BoxShadow` in the
scanned presentation layer because other shadows are token/getter/theme based.
This does not imply elevation consistency: cards also rely on Material defaults,
borders and surface color. Final rollout should use three elevation roles at most
and avoid decorating every section as a card.

## Marketplace-template residue

Potential residue includes `brand_*` terminology, legacy promotional/sale widgets,
generic marketplace cards and old order/store views. These require classification,
not automatic deletion. The visual audit rejects shipping/payment/checkout/order
tracking patterns and treats price comparison, directions and physical availability
as primary local-commerce cues.

## Risk levels

| Level | Debt | Required response |
|---|---|---|
| P0 | Token conflict, bottom-nav/auth behavior, Cart V2, seller/shop CTA, readable touch/type | Resolve before critical rollout acceptance |
| P1 | Reusable cards, forms, states, dialogs, review/chat/notifications consistency | Resolve before full Customer visual freeze |
| P2 | Decorative polish, minor icon variation, lower-traffic legal/help refinements | May follow pilot if usability is intact |

## Root-fix order

1. Owner resolves brand-role and dark-mode gates.
2. Add semantic Flutter tokens without changing visuals.
3. Build behavior-neutral primitives and compatibility adapters.
4. Migrate Home and critical commerce screens one state slice at a time.
5. Expand to trust, communication and account surfaces.
6. Remove superseded raw styles only after screenshot and functional evidence.
