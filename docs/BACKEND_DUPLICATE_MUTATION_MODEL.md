# Backend Duplicate Mutation Model

**State:** PROPOSED DEFENSE IN DEPTH

Duplicates arise from double taps, two devices/staff, mobile reconnect, timeout,
queue redelivery, job retry or malicious replay. Protection uses all applicable
layers:

1. client in-flight guard for UX;
2. server idempotency key scoped to caller/operation;
3. expected resource revision;
4. database business uniqueness/conditional transition;
5. atomic stored outcome;
6. consumer event deduplication;
7. reconciliation and anomaly monitoring.

Returning the original committed result is not a second success side effect.
Conflicting payload under a reused key is a security/data-quality event. Where no
new mutation occurs, do not emit another purchase, notification, reward, review,
ad billing or reputation event.

Every future mutation specification must state its duplicate identity, retention,
concurrent-race winner and loser response. “Frontend disables the button” is never
a complete answer.
