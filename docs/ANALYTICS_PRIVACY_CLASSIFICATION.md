# EsnaftaVar Analytics Privacy Classification

**State:** `PROPOSED — POLICY/LEGAL REVIEW REQUIRED`

| Class | Purpose | Default collection posture | Example |
|---|---|---|---|
| `ESSENTIAL_OPERATIONAL` | Deliver and verify requested product function | Minimum necessary, purpose-bound | RPC outcome, notification delivery state |
| `SECURITY` | Detect/prevent abuse and protect systems | Restricted, evidence-based | QR replay rejection, role denial |
| `PRODUCT_ANALYTICS` | Improve discovery and product experience | Owner/privacy approval; consent where required | Aggregated product/search use |
| `AD_MEASUREMENT` | Measure sponsored exposure/interaction | Separate purpose and consent/policy gate | Qualified impression candidate |
| `PERSONALIZATION` | Adapt experience for a person | Explicit purpose/choice and deletion controls | Future recommendations |
| `OPTIONAL` | Nonessential research/experiments | Off until explicit opt-in/approval | Extended diagnostic study |

Classification is per field/use, not merely per event. Mixed-purpose payloads are
split so essential service is not conditioned on optional tracking. Every class
declares legal/policy basis, access, retention, geography, deletion/export and
processor/tooling before implementation.

Security and audit data cannot be repurposed for marketing. Ad measurement cannot
silently use product analytics consent. This document is architecture, not legal
advice or a final consent policy.

`PRIVACY_POLICY_FINALIZED: NO`
