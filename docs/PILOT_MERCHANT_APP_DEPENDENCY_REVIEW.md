# EsnaftaVar Esenler Pilot — Merchant App Dependency Review

**State:** `CONTRARIAN DEPENDENCY REVIEW — OWNER DECISION REQUIRED`

## Finding

A fully finished Merchant App is not intrinsically required before a small
controlled pilot. Merchant capabilities are required; the delivery surface may be
a bounded, audited operating path while the Merchant App runtime is incomplete.

## Minimum capability path

Any temporary path must provide:

- authenticated operator and exact-shop authority;
- merchant/shop verification state;
- controlled catalog search and listing price/availability updates;
- provenance-bearing product candidate submission;
- exact-shop QR confirmation with server one-winner semantics;
- audit, support, pause/revoke and release-version visibility;
- no shared credentials, service-role exposure or direct database editing.

## Unacceptable shortcuts

- shared admin account or spreadsheet as authority;
- operator copying merchant passwords;
- direct Production SQL edits for routine onboarding;
- QR confirmation detached from exact shop;
- candidates auto-published to avoid moderation;
- support messages treated as authoritative listing updates without verification.

## Decision matrix

| Path | Pilot value | Main risk | Suitable condition |
|---|---|---|---|
| Wait for full Merchant App | Best self-service consistency | Delays learning and can overbuild | Broad/public pilot or high merchant count |
| Controlled minimum merchant tool/path | Faster narrow learning | Manual burden and temporary-process debt | Very lean cohort with strict caps/audit |
| Operator-only assisted path | Lowest merchant UI dependency | Bottleneck and authority confusion | Short bootstrap only; not steady state |

Agent recommendation: approve a controlled minimum path only for a capped cohort,
with migration/retirement criteria and no security invariant weakened. No path is
owner-selected here.

`FULL_MERCHANT_APP_REQUIRED_BEFORE_ANY_PILOT: NO`

`TEMPORARY_PATH_OWNER_APPROVED: NO`
