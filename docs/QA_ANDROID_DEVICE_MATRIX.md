# Android Device Matrix

**State:** PROPOSED — LEAN RISK-BASED SET

Current build uses `compileSdk/targetSdk 36`, production package `com.esnaftavar.app`, Development suffix `.dev`, and Flutter's effective `minSdk`. Resolve the actual min SDK from the release toolchain before execution.

## Minimum release set

| Tier | Device/API intent | Screen | Focus |
|---|---|---|---|
| Minimum supported | effective min API emulator/device | small phone | startup, TLS, Auth, storage, layout |
| Permission transition | representative API where permission behavior differs | phone | location/camera denied/forever/settings |
| Recent baseline | target-1/current stable API | 360–430 dp phone | full smoke, background, deep links |
| Current target | API 36 emulator/device when available | phone | manifest/target behavior |
| Tablet | recent API, 7–11 inch | tablet | grids, dialogs, navigation, rotation |
| OEM physical | one Samsung-class and one other common Android device as available | phone | process/background/camera/manufacturer variance |

## Matrix modifiers

Test low storage/memory only where reproducible; light/dark theme if supported; Turkish keyboard/autofill; Wi‑Fi/mobile switch; install/upgrade; camera qualities for QR. Do not multiply every modifier across every device—pair risks deliberately.

## Store acceptance

At least one internal-track install of the exact signed AAB-derived package and one direct signed APK smoke if APK distribution is retained. Signer/package/version/hash must match release records.

`OWNER_DECISION_REQUIRED: SUPPORTED_ANDROID_API_FLOOR_AND_PHYSICAL_POOL`
