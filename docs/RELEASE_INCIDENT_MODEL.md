# Release Incident Model

**State:** PROPOSED — OWNER REVIEW REQUIRED

## Incident classes

- bad client binary, signing/package/version mistake;
- backend/client incompatibility or migration defect;
- confirmation/recovery/deep-link failure;
- auth/session outage or role boundary regression;
- QR creation/confirmation/integrity failure;
- crash/ANR or severe performance regression;
- search/location/cart/review outage;
- data integrity, privacy or security event.

## Severity

- **P0:** active security/privacy breach, broad lockout, irreversible data/integrity damage or unsafe commerce evidence.
- **P1:** critical journey unavailable or materially wrong for a significant cohort with no safe workaround.
- **P2:** bounded degradation with safe workaround and no integrity loss.
- **P3:** minor/cosmetic/diagnostic defect.

Flow: detect → validate artifact/environment → contain/pause → assign authority → communicate → recover → verify → postmortem where meaningful. Severity may increase with evidence.

OWNER_DECISION_REQUIRED: align release incident authority with the Operations incident model before Production launch.
