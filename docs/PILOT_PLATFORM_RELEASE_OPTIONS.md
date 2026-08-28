# EsnaftaVar Esenler Pilot — Android and iOS Options

**State:** `OPTIONS — NO PLATFORM SELECTED`

## Current architecture evidence

The Customer closeout and QA foundations classify Android static readiness more
favorably than iOS. iOS still lacks complete macOS dependency/signing/archive/
TestFlight/physical-device evidence. Neither platform has been commercially
released by this work.

| Option | Benefit | Exclusion/risk | Gate |
|---|---|---|---|
| Android-only controlled pilot | Fastest bounded path, one artifact/support matrix | Excludes iOS customers/merchants and may bias cohort | Owner accepts reach bias; all Android physical/store gates pass |
| Android first, iOS stabilization lane | Preserves pilot speed and explicit iOS plan | Two timelines and communication burden | iOS not falsely promised; separate readiness milestones |
| Dual-platform launch | Broad device inclusion | Larger QA, signing, store, support and release surface | Both exact artifacts independently pass every gate |
| Invite/manual field test before store visibility | Tightest control and feedback | Distribution friction and selection bias | Approved test track and participant process |

Google describes internal, closed and open Play tracks and recommends internal then
small closed testing before wider testing. The real account's current eligibility
and policy requirements must be checked at execution:
[Play Console testing guidance](https://support.google.com/googleplay/android-developer/answer/9845334).
Apple provides TestFlight for pre-release distribution, but the repo's iOS gaps
must be closed first: [Apple TestFlight](https://developer.apple.com/testflight/).

## Agent recommendation

Use Android-only for the first tightly controlled cohort if target-device research
shows acceptable coverage and the owner explicitly accepts exclusion bias. Run iOS
as a separate readiness lane, not a hidden launch blocker or unsupported promise.

`ANDROID_ONLY_SELECTED: NO`

`IOS_PILOT_READY: NO`
