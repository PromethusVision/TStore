# Bug Severity Model

**State:** PROPOSED — OWNER REVIEW REQUIRED

Severity describes customer/system impact; priority may additionally consider reach, workaround and release timing.

- **P0:** active security/privacy compromise, irreversible/corrupt data, broad account lockout, unsafe role escalation, false verified-purchase evidence or Production release integrity failure. Immediate contain/escalate; release NO-GO.
- **P1:** critical commercial journey unavailable/wrong for a significant cohort, reproducible crash loop, auth/QR/cart/review blocker, signed artifact/config failure, or migration invariant breach without active P0 damage. Release-blocking.
- **P2:** bounded functional degradation with safe workaround, limited device/network issue, material accessibility/localization problem or noncritical data inconsistency. Fix or explicitly accept before release.
- **P3:** minor cosmetic/usability/diagnostic issue with no integrity, security or critical-journey impact.

Evidence may raise or lower severity; customer count alone cannot downgrade severe integrity risk.

OWNER_DECISION_REQUIRED: approve P2 release-acceptance authority and P0/P1 notification chain.
