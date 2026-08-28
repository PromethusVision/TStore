# Deep-Link Acceptance Matrix

**State:** PROPOSED — REMOTE ALLOWLIST UNCHANGED

Production mobile callback contract is `com.esnaftavar.app://login-callback/`; Development retains its separate configured scheme. The exact artifact, platform registration and remote allowlist must be reviewed atomically for release.

| Launch state | Confirmation | Recovery | Malformed/expired |
|---|---|---|---|
| Cold guest | bootstrap then confirmation result/login | open password-update only after valid recovery context | safe invalid-link screen |
| Warm guest | single navigation; no duplicate listener | preserve one recovery flow | remain usable and return to clean login |
| Authenticated same user | refresh confirmed session/profile | require valid recovery state; prevent account confusion | no session damage |
| Authenticated other user | prevent cross-account application | force safe identity boundary | no data exposure |
| Background/resume | process once by URI/event identity | process once | no repeated dialog/navigation |

## Inputs

Test custom URI from browser/mail, encoded query/fragment, missing type/token, wrong host/scheme/path, duplicate click, old link after success and callback received before/after Supabase Auth event.

## Platform evidence

Unit/widget tests prove parsing and routing. Android intent filter and iOS URL scheme receive static tests. Final signed Android and TestFlight/iOS physical link handling remain release gates.

`DEEP_LINK_PHYSICAL_CURRENT_CANDIDATE: OPEN`
