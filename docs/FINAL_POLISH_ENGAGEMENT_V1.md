# Final polish + engagement foundation V1

Authoritative start: `556e17dccd7287947444f013b54449db821737c3`.
Branch: `codex/final-polish-engagement-v1`.

## Implemented

- Seller offers alternate restrained white, pale mint and warm neutral surfaces.
  Existing best-price accents, seller ordering and business logic remain intact.
- Customer Home: official unchanged logo → “Kargo bekleme, EsnaftaVar” → search
  → public Ödül Sayacı → independent campaign carousel → categories → existing
  remaining content. The canonical category contract and eight-root Home limit
  are preserved.
- Five approved campaigns, remote V2 composition support, local icon/gradient
  fallback, safe destinations, lifecycle/manual-focus pause and reduced motion.
  Old stock-image rows are excluded from active Home.
- Reward shell defaults to `0 / 5` for guests and authenticated customers. Guest
  taps reuse login; authenticated taps open Reward Center. Progress, remaining
  steps, eligible merchants, up to three logo/initial bubbles plus count, future
  details and history use truthful empty/coming-soon content.
- `RewardRepository.watchProgress`, `RewardProgress`, `RewardProgressEvent` and
  `RewardEligibleMerchant` are insertion points for future approved rules.
  `PendingRewardRepository` is the real current implementation. No monetary
  promise, fabricated eligibility or production event was introduced.
- Progress changes animate for 800 ms, with brief increment/pulse feedback;
  completion uses a two-second native particle effect. Initial snapshots and
  repeated values do not replay rewards. Reduced motion shows the final value
  immediately. Tests inject transitions; production does not simulate progress.
- A static low-contrast shopping motif surrounds the official logo/slogan for
  approximately two seconds on cold framework startup. Auth subtree recreation
  does not repeat the delay; completion does not navigate over deep links.
  Native Android/iOS launch files are unchanged.
- Existing onboarding now presents the three approved pages with X/skip,
  swipe, accessible indicators and final CTA. The existing completion key is
  retained; completion/skip persists. An unseen install gets onboarding even if
  an auth session was restored. Existing seen installs do not repeat it. Tests
  inject timing/storage; no production reset control was exposed.
- Existing notification records, repositories and Realtime flow are extended by
  common role-aware push ports, secure device registration, preferences, server
  delivery interface and destination routing. Provider and undeployed backend
  paths fail closed. See [push foundation](PUSH_NOTIFICATION_FOUNDATION_V1.md).

The verified-purchase/history implementation was inspected for onboarding copy:
it retains verification records and review eligibility; it does not execute
refunds. The copy describes a reference record, not a refund service. QR and
verified-purchase implementation files were not edited.

## Remaining external work

- Firebase Android/iOS application config, APNs setup, provider adapter, trusted
  server store/queue, authorized schema deployment and physical push acceptance.
- Final optional campaign artwork can replace the current compositions later.
- Reward economics, eligibility and earned history require separate product
  rules/backend work. They are intentionally outside this UI-shell batch.

These do not block integration of the fail-closed foundation or a later signed
`1.0.0+4` build. They do block claiming real mobile push or reward earning.
No Production/Development access, remote write, campaign upload, main merge or
signed APK/AAB build was performed. QR two-device gate remains **OPEN** and
private-preview cleanup remains a separate task.

## Validation

Targeted seller, Home, campaign, reward, startup/onboarding and notification tests
cover success, defaults, guest routing, empty/error states, delayed responses,
account/role changes, opt-out persistence and duplicate actions. Widths 320/390/430
and large text are covered; startup/onboarding and Home have reviewed golden
renders. Existing golden changes correspond only to intended UI changes.

Server delivery: **20 PASS** with mocked transport; local PostgreSQL schema/RLS:
**28 PASS** using synthetic identities and PGlite 0.5.5. No remote driver or
production configuration is loaded by the schema harness.

Final verification: `flutter analyze --no-pub` reported **zero issues**.
`flutter test --no-pub --concurrency=8 --reporter json` completed with
**2243 PASS / 0 FAIL / 6 SKIP**, a net increase of 45 passing tests over the stated
2198 baseline. The six pre-existing optional live tests remained disabled;
no new skip was added. The first regression run identified obsolete reward
visibility assertions, startup timers in old test harnesses and intended golden
differences. Assertions were updated to verify the approved shell's empty earning
state, explicit timing was tested, and rendered differences were reviewed before
updating images. No assertion was suppressed to obtain a pass.

`git diff --check` and changed-file secret/personal-path scans passed. Android,
iOS, dependency/lock files, official logo, deployed migrations, cart/QR and
verified-purchase implementation paths have no diff from the authoritative start.
Temporary test logs and failure comparison images remain outside the repository.

## Integration touchpoints

Shared changes include navigation, reward service registration, Home composition,
onboarding launch gate and the existing notification entity/inbox. No dependency
or lockfile change; deployed migrations 0012/0013/0014/0015 and canonical data are
unchanged. The additive SQL is a **proposal**, not a scheduled migration.

Campaign details and future local-offer rules:
[Home campaign targeting](HOME_CAMPAIGN_TARGETING_V1.md).

## Consolidated result

```text
FINAL_POLISH_ENGAGEMENT_V1: PASS
AUTHORITATIVE_START_MAIN: 556e17dccd7287947444f013b54449db821737c3
BRANCH: codex/final-polish-engagement-v1
SELLER_CARD_VISUAL_SEPARATION: PASS
HOME_BRAND_SLOGAN: PASS
HOME_FINAL_HIERARCHY: PASS
OLD_TSTORE_HOME_BANNER_ASSETS_ACTIVE: NO
CAMPAIGN_CAROUSEL: PASS
CAMPAIGN_REMOTE_ARCHITECTURE: PASS
CAMPAIGN_REMOTE_WRITE_PERFORMED: NO
BANNER_1: PASS
BANNER_2: PASS
BANNER_3: PASS
BANNER_4: PASS
BANNER_5: PASS
REWARD_COUNTER_SHELL: PASS
REWARD_CENTER: PASS
GUEST_REWARD_STATE: PASS
MERCHANT_LOGO_BUBBLES: PASS
REWARD_PROGRESS_ANIMATION: PASS
REWARD_COMPLETION_CELEBRATION: PASS
REAL_REWARD_ECONOMICS_IMPLEMENTED: NO
BRANDED_APP_SPLASH_2S: PASS
ONBOARDING_FIRST_RUN_ONLY: PASS
ONBOARDING_PAGE_1: PASS
ONBOARDING_PAGE_2: PASS
ONBOARDING_PAGE_3: PASS
EXISTING_NOTIFICATION_ARCHITECTURE_REUSED: YES
CUSTOMER_PUSH_FOUNDATION: PASS
MERCHANT_PUSH_FOUNDATION: PASS
NOTIFICATION_PREFERENCES: PASS
NOTIFICATION_DEEP_LINK_ROUTER: PASS
FCM_TARGET_ARCHITECTURE: PASS
PUSH_PROVIDER_EXTERNAL_CONFIG: PENDING
PRODUCTION_ACCESSED: NO
PRODUCTION_WRITE_PERFORMED: NO
QR_CHANGED: NO
QR_TWO_DEVICE_PHYSICAL_GATE: OPEN
PRIVATE_PREVIEW_CLEANUP: NOT_PERFORMED
FLUTTER_ANALYZE: PASS
FULL_FLUTTER: 2243 PASS / 0 FAIL / 6 SKIP
GIT_DIFF_CHECK: PASS
SECRET_PII_SCAN: PASS
BINARY_AFFECTING_DELTA: YES
FINAL_SIGNED_BUILD_CREATED: NO
READY_FOR_INTEGRATION: YES
READY_FOR_FINAL_1_0_0_PLUS_4_BUILD_AFTER_INTEGRATION: YES
BLOCKERS: Live push requires Firebase/APNs configuration, provider/store integration,
         separately authorized schema/server deployment and physical acceptance.
```

The push PASS fields describe the tested foundation, not live delivery. Optional
final campaign artwork is replaceable; reward economics remain an explicit
separate scope rather than an integration blocker.

## Integration review

Integration branch: `integration/final-polish-engagement-v1`.
Starting main: `556e17dccd7287947444f013b54449db821737c3`.
Reviewed source: `29f2067a873081d72224e314c7bdba21624a129f`, exactly seven
commits ahead of the starting main, with no commits behind and no merge conflict.

Local integration validation: 174 targeted Flutter tests passed; analyzer had
zero issues; the full suite passed **2243 tests, 0 failures and the same six
pre-existing optional/live skips**. Mocked push delivery passed **20 tests**;
in-memory PGlite 0.5.5 schema/RLS validation passed **28 checks**. No remote
database or provider was used by those engagement tests.

All 32 changed golden images were compared against the starting main where a
baseline existed. Integration found that the new 320-pixel Home golden captured
the first frame before the official logo decoded. Its test now awaits the image
and asserts a decoded image is present. Only that golden was regenerated; its
additional pixel differences are confined to the logo rectangle. The corrected
Home suite passed all nine tests. No application code was changed to fix this
test capture issue.

The seven-commit history scan covered 93 distinct file versions, including PNG
metadata. Matches were synthetic test email addresses and an unchanged mock
publishable-key string in a widget test; no real secret or personal data was
found. Whitespace validation passed.

Every source commit preserves deployed 0012/0013/0015 migrations, the existing
0014 activation/rollback package, taxonomy and QR behavior. The sole SQL addition
remains under `supabase/proposals/`; its only executable consumer is the local
in-memory test harness. No migration ledger records it as applied.

The source's no-main-merge statement above describes the worker's execution.
This integration merges that reviewed batch. Version remains **1.0.0+3**; binary
inputs change, so the existing signed build is not equivalent to the integrated
source. A separately authorized **1.0.0+4** signed build is the next build step.
No APK/AAB was built here, and Production was neither accessed nor written.

Live FCM/APNs delivery remains **PENDING**, the Production campaign backend is
**NOT DEPLOYED**, and real reward earning/economics is **NOT_IMPLEMENTED**.
The QR two-device physical gate remains **OPEN** and private-preview cleanup
remains **NOT_PERFORMED**.
