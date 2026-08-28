# Forced Update Review

State: PROPOSED — OWNER REVIEW REQUIRED

Forced update is a last-resort safety control, not a routine adoption tool. It can strand users with limited connectivity, unsupported stores, accessibility needs, or an unavailable new build.

## Use only when

- a known security flaw cannot be contained server-side;
- an old client can corrupt data or violate a hard invariant;
- a backend contract is irreconcilably unsafe;
- a legal/policy block is confirmed by authorized review.

Prefer staged rollout, backward compatibility, advisory update, and kill switches. Before blocking, verify the replacement on each platform, store availability by region, upgrade path, support message, outage behavior, and an audited escape route.

Recommendation: V1 defaults to non-blocking prompts. A hard block requires incident evidence and two explicit approvals where staffing permits.

OWNER_DECISION_REQUIRED: define hard-block authority and one-person-pilot compensating control.
