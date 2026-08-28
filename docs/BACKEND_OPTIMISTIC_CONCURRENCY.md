# Backend Optimistic Concurrency

**State:** PROPOSED

Mutable merchant and operator-managed resources should carry a monotonic revision
or equivalent compare-and-swap token. Mutation includes `expected_revision`; the
server commits only if it still matches and returns the new revision.

## Candidates

- listing price/availability/content;
- shop profile/hours;
- membership capability/scope;
- campaign settings and target revisions;
- review updates;
- ops case assignment/decision;
- product candidate and catalog correction workflow.

Conflicts return current safe projection plus bounded changed-field information
when authorized. Clients refresh and ask for intentional merge; they do not retry
blindly with the newer revision. Append-only ledgers/events use identity and
idempotency instead of “last write wins.”

Current tables without revision remain valid; adding revision is a separately
tested migration, not implied here.
