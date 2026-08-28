# UI Token Migration Plan

## Goal

Create one semantic Flutter token boundary that can express the approved warm
EsnaftaVar system while preserving every current feature behavior. This document
does not select unresolved brand roles or implement tokens.

## Current sources

| Source | Strength | Limitation |
|---|---|---|
| `TColors`, `TSizes`, `TAppTheme` | Global runtime reach | Legacy cold palette and broad generic names |
| `CustomerHomeV1Tokens` | Warm local-commerce proof in runtime | Home-scoped; palette differs from Wave 14 canonical docs |
| Figma token manifest/document | Semantic roles, Poppins, contrast evidence | Not wired to Flutter; primarily light-mode |
| Local literal styles | Precisely fit current screen | Duplicated, difficult to audit and theme |

## Proposed Flutter architecture

Use immutable semantic Theme extensions rather than importing Figma names directly
throughout screens:

```text
ThemeData
├── EsnaftaVarColorTokens
├── EsnaftaVarSpaceTokens
├── EsnaftaVarRadiusTokens
├── EsnaftaVarTypeTokens
├── EsnaftaVarElevationTokens
└── EsnaftaVarMotionTokens
```

Screens consume roles such as `surfaceBase`, `textPrimary`, `actionPrimary`,
`stockUnavailable` and `verifiedPurchase`; they do not consume raw hex values.
Existing `TColors`/`TSizes` remain as compatibility inputs during migration and
are removed only when reference counts reach zero.

## Required semantic color roles

| Group | Roles | Notes |
|---|---|---|
| Brand | primary, onPrimary, primarySoft, accent, onAccent, accentSoft | Teal/terracotta ordering needs owner approval |
| Surface | background, surface, surfaceAlt, elevated, overlay | Warm cream direction; product images remain neutral |
| Text | primary, secondary, muted, disabled, inverse | Contrast verified for each surface/mode |
| Border | subtle, default, strong, focus | Focus cannot rely on color alone |
| State | success, warning, error, info plus soft/on colors | Message meaning preserved |
| Commerce | price, stockAvailable, stockLow, unavailable | No “sale” semantics without real data |
| Trust/future | verifiedPurchase, sponsored, merchantBadge | Future slots remain inactive unless authoritative |

## Dimensions and typography

- Spacing: 4, 8, 12, 16, 20, 24, 32, 40, 48.
- Radius: 8, 12, 16 and pill; retain larger legacy radii only as explicit hero
  exceptions.
- Touch target: minimum 44, preferred 48.
- Typography: Poppins semantic roles from caption/body/label through heading,
  display and price roles. Avoid direct `fontSize` in feature screens.
- Elevation: xs/sm/md only; prefer border/surface grouping over excess shadows.
- Motion: short/standard durations, reduced-motion fallback and no motion as the
  only feedback.

## Migration stages

### Stage 0 — decision gates

- Approve primary/accent semantic ordering.
- Decide launch dark-mode policy.
- Approve critical-screen visual direction and unresolved C1 items.

### Stage 1 — parity token plumbing

- Introduce semantic extensions populated with current values.
- Add token-contract tests and theme lookup tests.
- Do not visibly recolor screens.
- Record allowed exceptional literals such as transparent overlays.

### Stage 2 — global primitives

- Map text roles, button styles, fields, dividers, focus and disabled states.
- Replace raw sizes inside new canonical components only.
- Keep old widgets behind adapters until migrated call sites pass.

### Stage 3 — Home and navigation

- Map `CustomerHomeV1Tokens` to approved semantic roles.
- Preserve bottom-nav destination, unread/cart badges and guest continuation.
- Validate 320/360/390/430 widths and 1.0/1.3/2.0 text scale.

### Stage 4 — critical commerce screens

- Migrate listing, product details, seller comparison, shop and Cart V2.
- Use canonical components and state recipes.
- Preserve dynamic taxonomy, auth, search, cart, QR, review and navigation logic.

### Stage 5 — trust/account/communication

- Reviews, purchases, chat, notifications, settings, profile and location.
- Remove screen-local state and form styles only after parity tests.

### Stage 6 — cleanup and freeze

- Verify no unsupported raw brand/status colors remain.
- Freeze semantic tokens and component APIs for the release candidate.
- Delete compatibility aliases only in a separate reviewed cleanup.

## Mapping rules

| Current pattern | Migration rule |
|---|---|
| `CustomerHomeV1Tokens.petrol/coral/...` | Map by semantic purpose after owner role decision; never search/replace by color |
| `TColors.primary` | Map call site to action/brand/focus role; generic primary is insufficient |
| `Colors.white/black` | Map to surface/on-color/inverse unless truly absolute media contrast |
| `TSizes.*` | Map to spacing/touch/component semantic role |
| local `TextStyle` | Prefer Theme text role plus minimal semantic override |
| local radius/shadow | Map to component recipe, not nearest numeric token blindly |

## Dark-mode gate

Because `ThemeMode.system` is active, every token used in a migrated screen must
have a validated dark value, or the product must explicitly choose a temporary
light-only policy. Mixing a polished light system with the legacy dark theme is a
release blocker for “final visual” status.

## Automated contract tests for implementation phase

- all semantic roles resolve in every supported mode;
- primary text/action/status contrast meets agreed thresholds;
- no component accesses an absent Theme extension;
- token manifests contain no duplicate semantic name;
- deprecated legacy token usage declines monotonically by wave;
- no feature imports raw Figma JSON at runtime;
- golden fixtures are deterministic across supported text scale and locale.

## Rollback strategy

Migrate by component/screen flag or compatibility adapter so a failed visual wave
can restore the old presentation without reverting feature logic. Do not maintain
two full design systems indefinitely; each wave has an explicit adapter-removal
follow-up after acceptance.
