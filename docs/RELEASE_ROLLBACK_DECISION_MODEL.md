# Release Rollback Decision Model

**State:** PROPOSED — OWNER REVIEW REQUIRED

Mobile rollback is constrained: stores cannot instantly recall installed clients and may not permit republishing an older version/build. The decision therefore selects among containment, backend repair, rollout pause and a new hotfix.

## Decision order

1. confirm incident, affected artifact/environment and integrity risk;
2. pause staged rollout when possible;
3. disable only the unsafe feature through an approved kill switch;
4. preserve backward-compatible backend behavior or apply a tested forward fix;
5. publish a higher-build hotfix when client correction is required;
6. restore data only from an authorized, rehearsed plan.

Rollback is preferred only when it is tested, preserves newer data, supports clients still in the wild and is faster/safer than forward repair. Store propagation delay, offline clients, migration irreversibility and communication are explicit inputs.

OWNER_DECISION_REQUIRED: designate decision authority and acceptable containment versus service-unavailability tradeoff.
