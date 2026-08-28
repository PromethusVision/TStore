# EsnaftaVar Crash Reporting Requirements

**State:** `PROPOSED — NO SDK INSTALLED`

Minimum capabilities: Flutter fatal and nonfatal capture, async/framework error
coverage, Android/iOS/Web applicability as required, symbolication, release/build/
environment grouping, issue deduplication, alerting, export/deletion controls,
sampling/quotas and test-event verification.

Privacy controls must run before transport: scrub tokens, URLs/query strings,
headers, raw QR, customer contact, private messages/reviews, search text, precise
location, form/local-state payloads and screenshots. Use anonymous installation/
event correlation only if approved; customer user ID is off by default.

Breadcrumbs are allowlisted bounded technical actions, not a full behavioral
journey. Production and Development projects/environments are separated. Release
artifacts upload matching symbols without embedding service secrets in the app.
Operators document provider region/subprocessors, retention, access and deletion.

Tool selection and consent/legal basis remain open.

`CRASH_REPORTING_IMPLEMENTED: NO`
