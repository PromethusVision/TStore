# Backend Audit Trail Contract

**State:** PROPOSED APPEND-ONLY CONCEPT — NO STORAGE IMPLEMENTATION

## Minimum envelope

- immutable audit ID and trusted occurred/recorded times;
- actor type/opaque ID, effective membership/operator capability and assurance;
- action, domain subject and environment;
- case/request/correlation and idempotency references;
- stable reason code and policy/contract version;
- authorized before/after or predecessor/successor delta;
- result including denial/failure class;
- approval/separation-of-duty and reversal/superseding references.

Audit is required for merchant membership/ownership changes, catalog candidate and
merge/split, purchase correction, review moderation, campaign/budget, reward/
reputation correction, policy changes, PII access/export and break-glass.

Do not record passwords, tokens, raw QR, signed links, private messages/review text,
full documents, precise unnecessary location or unrestricted request bodies.
Ordinary operators cannot edit/delete audit; correction appends a superseding
event. Access/export is itself audited.

Audit evidence is not analytics engagement data and does not grant domain
authority. Retention/access tiers remain `OWNER_DECISION_REQUIRED`.

