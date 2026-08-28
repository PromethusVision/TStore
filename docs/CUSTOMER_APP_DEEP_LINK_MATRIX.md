# Customer App Deep-link Matrix

Status: PASS FOR AUTH CALLBACK CONTRACT; iOS PHYSICAL ACCEPTANCE OPEN

Canonical mobile callback: `com.esnaftavar.app://login-callback/` in Production. Development has a distinct scheme. Email confirmation and password recovery share the callback transport but are discriminated by validated Auth intent/state.

| Scenario | Cold start | Warm app | Guest | Authenticated | Result |
| --- | --- | --- | --- | --- | --- |
| Signup email confirmation with session | initial URI handled before app use | stream callback | profile refresh then Home | profile refresh then Home | PASS |
| Confirmation without session | initial callback retained until navigator | listener callback | Login with success feedback | Login/session state authoritative | PASS |
| Password recovery | verified startup status opens update view | `passwordRecovery` event opens once | identity-bound update view | recovery route owns temporary session | PASS |
| Ordinary login callback | exact PKCE code exchange only | exact stream URI | Auth state resumes requested flow | same-user refresh | PASS |
| Expired/invalid recovery | safe invalid-recovery screen | safe error route once | return to clean Login | no stale success | PASS |
| Malformed link/wrong host/path/empty code | ignored/rejected | ignored/rejected | no navigation | no navigation | PASS |
| Duplicate callback | sequence/open guards | sequence/open guards | one navigation | one navigation | PASS |

The callback contract validates environment-specific scheme, host, root path, query shape, and Auth action. Browser URL sanitization avoids leaving one-time codes visible on supported web flows. No general product/shop content-deep-link system is active.

Prior signed Android physical confirmation/recovery passed. iOS cold/warm physical callback behavior remains `PHYSICAL_TEST_REQUIRED`.

`DEEP_LINK_MATRIX: PASS`  
`ANDROID_AUTH_CALLBACK: PASS`  
`IOS_AUTH_CALLBACK_PHYSICAL: BLOCKED`
