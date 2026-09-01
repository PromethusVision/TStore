# W39 Shared Component Ownership

## Authoritative Final UI foundation

Wave 39 establishes one reusable Flutter design-system foundation for the
Customer App. Later screens consume or explicitly extend this system; they do not
create a competing token/theme/component family.

For Flutter runtime implementation, this Wave 39 foundation supersedes the older
Wave 14 Figma token proposal where values differ. Historical Figma evidence remains
reference-only and was not modified by this integration.

### Foundation ownership

| Area | Authoritative source | Contract |
| --- | --- | --- |
| Semantic colors | `EsnaftaVarColors`, `EsnaftaVarDiscoveryColors` | Primary `#146C6E`, accent `#B54732`, light-only semantic surfaces and states |
| Typography | `EsnaftaVarTheme.light` | Poppins-only Customer UI type ramp |
| Layout | `EsnaftaVarSpacing`, `EsnaftaVarRadii` | Shared spacing and radius scale |
| Interaction | `EsnaftaVarIconSizes`, `EsnaftaVarTouchTargets` | Central icon sizes; `44 px` minimum and `48 px` preferred touch target |
| Depth/borders | `EsnaftaVarElevation`, theme borders/dividers | Shared elevation, outline and separation language |
| App theme | `TAppTheme.lightTheme -> EsnaftaVarTheme.light` | Final Customer pilot theme; dark mode deferred |

### Shared primitive ownership

| Component | Shared responsibility |
| --- | --- |
| `EsnaftaVarScaffold` | Customer light theme, background and safe composition |
| `EsnaftaVarSectionHeader` | Section hierarchy and accessible trailing action |
| `EsnaftaVarStateCard` | Loading/empty/error/supporting state presentation |
| `EsnaftaVarSurfaceIconButton` | Consistent surface icon action and touch target |
| `RewardProgressSlot` | Feature-OFF/default-safe Reward placement |
| `RewardProgressCard` | Owner-final five-task presentation states and semantics |

These tokens and components are the authoritative Final UI foundation. Future
screen work must reuse them. A screen-local duplicate is not an acceptable way to
avoid a shared-component change.

## Change control

- The active screen's single UI Agent owns any necessary shared-component change
  for that wave.
- A shared change must be explicit in scope, justified by a real cross-screen
  requirement and regression-tested against existing Home consumers.
- The Integration Agent reviews shared-hotspot impact before main integration.
- Visual prototype approval does not waive responsive, state, accessibility,
  functional navigation or full-suite gates.
- Common primitives are not reinvented per screen, and a second design-token or
  theme system is not introduced.

## Preserved boundaries

- Pilot theme is light-only.
- Reward is presentation-only and runtime-default OFF.
- Reward mission rules, amount/economics, payout, redemption, wallet, coupon,
  expiry, fraud and funding remain deferred.
- Backend, taxonomy content/runtime activation and Figma source are outside this
  foundation's ownership.

## Next screen

The next single-UI-Agent stream is `Category / Recursive Browse Final UI`. Its
first deliverable is one `390 px` prototype for Product Owner visual approval;
full implementation follows only after that gate.

`W39_SHARED_UI_FOUNDATION: AUTHORITATIVE`

`SHARED_COMPONENT_OWNER_MODEL: SINGLE_UI_AGENT`

`NEXT_UI_STREAM: CATEGORY_RECURSIVE_BROWSE`
