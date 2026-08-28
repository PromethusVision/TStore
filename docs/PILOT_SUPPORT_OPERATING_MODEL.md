# EsnaftaVar Esenler Pilot — Support Operating Model

**State:** `LEAN MODEL — CHANNELS/SLA NOT OWNER FINAL`

## Support promise

Provide a small number of declared channels and hours, acknowledge critical safety
or account issues promptly within the staffed window, preserve evidence and route
cases to the correct authority. Do not promise 24/7 or instant resolution.

## Intake lanes

| Lane | Examples | First action |
|---|---|---|
| Customer | login, location, wrong listing, QR uncertainty, review/account issue | Safety/identity check, classify, preserve minimal evidence |
| Merchant | verification, catalog match, listing update, QR/verifier, account access | Verify actor/shop, avoid shared credentials, route capability |
| Trust/policy | prohibited item, false claim, harassment, privacy | Contain risky visibility and escalate by policy |
| Reliability | outage, crash, RPC, storage/realtime, release mismatch | Correlate environment/release and incident state |
| Security | role violation, token/QR exposure, suspicious access | Do not request secret; invoke incident route |

## Case minimum

Case ID, intake time/channel, actor type and permitted identifier, environment,
release, affected shop/listing/purchase IDs where allowed, category/severity,
privacy class, safe summary, evidence references, owner, next action, timestamps and
resolution/reopen state. Never capture passwords, auth tokens, raw QR, unnecessary
precise location, private chat content or unrelated identity documents.

## Customer support flow

`intake → self-help/safe triage → identity verification if needed → resolve or
escalate → explain outcome/limit → close → sample/reopen`

## Merchant support flow

`intake → exact-shop authority → catalog/QR/verification queue → evidence-based
action → merchant education → re-test → close/sample`

## One-person guardrails

- cap live shops/customers and declared hours;
- one queue, reason codes and daily review;
- separate root policy decisions from routine cases;
- named legal/privacy/security and release escalation routes;
- no high-risk mutation without traceable review;
- pause acquisition when aged cases or interruptions exceed capacity.

`SUPPORT_CHANNELS_ACTIVATED: NO`

`24_7_SUPPORT_PROMISED: NO`
