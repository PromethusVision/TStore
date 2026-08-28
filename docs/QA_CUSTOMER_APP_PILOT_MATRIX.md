# Customer App Pilot Matrix

**State:** PROPOSED — NO ACCEPTANCE EXECUTED

| Domain | Automated must | Physical/manual must | Pilot gate |
|---|---|---|---|
| Auth | signup/login/recovery/session/user-switch tests | real email/callback on signed artifact | BLOCKING |
| Home/discovery | loading/error/stale/duplicate navigation | representative device visual/use | BLOCKING |
| Search | Turkish text, cancel/stale/filter contracts | poor network/device input | BLOCKING |
| Location | permission states and fallback | real GPS, denied forever, service toggle | BLOCKING |
| Product/seller/shop | mapping, availability, ownership reads | exact artifact journey | BLOCKING |
| Cart/wishlist | account isolation, stale listing, retries | lifecycle/network recovery | BLOCKING |
| Reviews | eligibility, one-active, RLS/RPC | verified-purchase journey | BLOCKING |
| QR | unit/RPC/concurrency/negative matrix | real two-device camera flow | BLOCKING |
| Chat/notifications | auth/realtime/token/deep-link contracts | only if enabled in pilot | CONDITIONAL |
| Install/deep links | static/widget/config contracts | clean/upgrade, cold/warm callbacks | BLOCKING |

All accounts/data are synthetic outside minimal authorized Production smoke.

OWNER_DECISION_REQUIRED: confirm whether chat/notifications are enabled in the first pilot and supported platforms.
