# iOS Device Matrix

**State:** PROPOSED — WINDOWS STATIC ONLY IN WAVE 22

Repository settings currently declare iOS deployment target 12.0 and device family iPhone/iPad, with bundle `com.esnaftavar.app`. Final supported OS policy must be reconciled with current Flutter/plugin/App Store support before release; this document does not change it.

## Minimum acceptance set

| Tier | Device | Focus |
|---|---|---|
| Minimum supported simulator/device | oldest owner-approved iOS | launch, Auth, storage, layout, permission copy |
| Recent iPhone | current/recent iOS, standard size | full smoke, callback, background, network |
| Small iPhone | smallest supported viewport | forms, keyboard, text scale, dialogs |
| Large iPhone | large viewport | grids, sheets and media |
| iPad | supported iPad family | navigation/layout/orientation |
| Physical signed | at least one current iPhone via TestFlight | camera, GPS, deep links, install/upgrade |

## Apple-only gates

Archive/signing identity, entitlements, provisioning, TestFlight processing, universal/custom link behavior and notification permission require macOS/Xcode/App Store Connect. Simulator cannot prove camera quality, push delivery or distribution signing.

`IOS_PHYSICAL_ACCEPTANCE: OPEN`

`OWNER_DECISION_REQUIRED: IOS_SUPPORT_FLOOR_AND_IPAD_SCOPE`
