# Backend Media Orphan Model

**State:** PRESERVES MINIMUM SEVEN-DAY PRINCIPLE — NO CLEANUP JOB

An orphan is an object not referenced by an active/retained media pointer after
failed attach, replacement or entity lifecycle. It is not automatically safe to
delete immediately.

## Recommended workflow

1. record object identity, upload/source time and intended owner reference;
2. after attachment failure or replacement, mark/derive unreferenced candidate;
3. keep it at least seven days for rollback and race reconciliation;
4. trusted cleanup rechecks all current/historical references and legal/policy hold;
5. delete exact object only, idempotently, with audit/metrics;
6. treat missing object as terminal success only after reference proof;
7. quarantine ambiguous ownership rather than broad prefix deletion.

No `LIKE`/folder-wide cleanup, client delete policy or database cascade directly
deletes Storage objects. Current canonical migrations install no cron/collector.
Longer retention, legal hold and future avatar/review cleanup remain
`OWNER_DECISION_REQUIRED`.
