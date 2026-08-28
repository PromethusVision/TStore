# Customer App Physical Acceptance Plan

Status: **PLAN — UNEXECUTED IN WAVE 16**
Wave: **16 — Customer App Commercialization Closeout**

Prior-wave physical results are useful evidence, but the current release
candidate must be rechecked where stated. A local/widget PASS is not promoted to
a physical PASS.

| Test | PRECONDITION | DEVICE COUNT | STEPS | EXPECTED | CURRENT STATUS | BLOCKER |
|---|---|---:|---|---|---|---|
| Android signed install/upgrade | Canonical keystore available outside Git; final Production APK/AAB built | 1 Android | Verify signer/package; upgrade without uninstall/clear-data; launch | Install succeeds, data retained, correct Production identity, no crash | PRIOR PASS; CURRENT CANDIDATE OPEN | Final artifact + device |
| Android auth confirmation | Disposable authorized account, real inbox, callback allowlist | 1 Android | Signup; open confirmation mail; observe app | App opens, session/profile refreshes, visible success feedback | PRIOR B6 PASS; CURRENT CANDIDATE OPEN | Authorized fixture/email |
| Android password recovery | Confirmed disposable account and real inbox | 1 Android | Request recovery; open link; set password; prove fresh login | App opens update UI; new password authenticates | PRIOR B6 PASS; CURRENT CANDIDATE OPEN | Authorized fixture/email |
| Two-device QR success | Customer and merchant/verifier principals, owned shop/product/cart | 2 physical | Render QR on customer; scan by merchant; confirm | One verified transaction/item; customer state refreshes | OPEN | Merchant fixture and two devices |
| QR camera permission | Same QR setup | 1 verifier | Deny, retry, allow camera; scan | Clear permission recovery; real QR readable; no crash | OPEN | Physical camera/device |
| QR wrong merchant | Two merchant contexts and customer QR | 2–3 | Scan customer token using wrong merchant | Confirmation rejected; no transaction | OPEN | Authorized live fixtures |
| QR replay/concurrency | Active token and two verifier attempts | 2–3 | Confirm once/replay; confirm concurrently | At most one transaction, replay rejected | OPEN | Coordinated devices/live contract |
| Physical GPS | Location services and permission controls | 1 Android + 1 iOS when available | Allow/deny/deny forever/settings-return; move indoors/outdoors as practical | No crash, coordinates acquired when allowed, list remains usable otherwise | Android PRIOR PASS; CURRENT RECHECK | Device/GPS |
| Network switching | Installed final candidate | 1 per platform | Browse on Wi‑Fi; disable; retry; switch cellular/Wi‑Fi; background/resume | Safe offline states, recovery, no duplicate navigation/writes | OPEN | Physical network controls |
| Android deep-link routing | Final signed candidate installed | 1 Android | Open canonical custom URI from browser/mail | Correct screen, no dead end | PRIOR PASS; CURRENT RECHECK | Final artifact |
| iOS archive/install | Apple signing and current supported iPhone | 1 iOS | Archive/TestFlight/install/launch | Correct bundle, launch, permissions, no crash | BLOCKED | macOS/Xcode/signing/device |
| iOS auth deep links | Installed iOS candidate + authorized fixture | 1 iOS | Open confirmation/recovery callback | Correct app route and completed lifecycle | BLOCKED | iOS release environment |
| App background/resume | Active location/auth/QR views | 1 per platform | Background during operation; resume | State refreshes once, timers/subscriptions remain valid | PARTIAL LOCAL ONLY | Physical devices |
| Push notification delivery | Implemented push provider and permission contract | 1–2 | Not applicable to current V1 | Must not be claimed | FUTURE_FEATURE | Push is not implemented |

Exact coordinates, personal emails, tokens and credentials must not be recorded
in acceptance output. Test fixtures require explicit authorization and exact
cleanup.
