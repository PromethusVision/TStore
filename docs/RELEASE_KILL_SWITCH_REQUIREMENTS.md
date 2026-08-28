# Release Kill Switch Requirements

State: PROPOSED — OWNER REVIEW REQUIRED

Kill switches provide rapid, audited containment for high-risk server-authoritative capabilities without pretending to remove an installed client.

## Candidate switches

- QR creation and merchant confirmation separately;
- sponsored-ad serving and campaign writes separately;
- reward accrual and redemption separately;
- canonical catalog/listing writes;
- reviews or chat writes when abuse or integrity requires it.

## Safety contract

Default and offline behavior must be explicit, reads and writes should be separable, scope may be global/environment/feature, and every change records actor, reason, incident, before/after, and expiry review. Client UI must present a safe temporary-unavailability state.

Switches cannot weaken RLS or grant privileges. Restore requires evidence that the trigger is resolved and verification of queued/retried operations.

OWNER_DECISION_REQUIRED: prioritize V1 switches and approve the operator/two-person control model.
