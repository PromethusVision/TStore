# Support Channel Options

**State:** OPTIONS — NO TOOL OR PAID SUBSCRIPTION DECISION

| Channel | Strengths | Risks/limits | Proposed posture |
|---|---|---|---|
| In-app | Authenticated context, structured object IDs, privacy notice, status tracking | Requires product work and available session | Preferred future primary |
| Email | Familiar, asynchronous, low setup | Spoofing, unstructured PII/attachments, thread leakage | Pilot fallback with secure verification |
| WhatsApp / business support | Familiar and fast for local merchants | Personal-number risk, weak case structure, data export/retention/vendor terms | Do not make primary by default; owner/privacy/tool review |
| Web form | Structured, works without app, can capture case type | Spam, identity verification, attachment risk | Useful public intake with rate limits |
| Phone | Accessible for urgent/complex cases | Weak evidence/audit, social engineering, staffing | Deferred/escalation-only candidate |
| External ticketing | Mature queues/email integration | Cost, vendor/data residency, permissions, lock-in | Evaluate only after volume/requirements |
| Minimal internal console | Exact authorization/case model | Build/security/maintenance cost | Needed eventually for privileged actions |

## Recommended lean pilot

Use structured in-app or web-form intake where available, a dedicated support email for fallback, and an internal case register with strict access. Do not accept passwords, OTPs, recovery links, full identity documents, or arbitrary database-change requests through any channel.

WhatsApp can be evaluated for merchant convenience only after business account ownership, consent/notice, retention/export, operator access, lost-device, and vendor-processing questions are closed. Do not use personal operator accounts.

## Selection evidence

Measure volume, case complexity, authentication success, response targets, attachment need, accessibility, privacy/security risk, integration effort, exportability, and cost. Channel choice does not change action authorization.

`PAID_SUPPORT_TOOL_SELECTED: NO`

`WHATSAPP_PRIMARY_CHANNEL: NOT_DECIDED`
