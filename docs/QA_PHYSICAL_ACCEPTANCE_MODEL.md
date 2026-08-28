# Physical Acceptance Model

**State:** PROPOSED — MANUAL/DEVICE EVIDENCE REQUIRED

## What physical acceptance owns

Native permission dialogs/settings return, camera focus/QR read, real GPS, email/browser deep links, background/process resume, network handover, keyboard/autofill, notification delivery, signed install/upgrade and platform store artifact behavior.

## Evidence record

Record candidate hash, app/build, device model, OS, install path, environment, actor fixture class, steps, observed result, timestamp, tester and cleanup status. Do not record personal email, exact location, token, raw QR or secret.

## Gate tiers

| Tier | Use |
|---|---|
| Developer spot | changed native behavior on one available device |
| Release matrix | minimum Android/iOS/device scenarios for exact candidate |
| Two-device journey | Customer + Merchant/verifier QR and cross-app consistency |
| Store-distributed smoke | internal track/TestFlight exact artifact install/upgrade |

## Current open gates

Customer App core local evidence is strong, but current-candidate physical two-device QR remains open. iOS signed archive/TestFlight and current physical callback are not available from Windows. These cannot be certified by widget/emulator results.

`PHYSICAL_ACCEPTANCE_PERFORMED_W22: NO`
