# Backend Dual-Write Risk Review

**State:** RECOMMEND AVOID BY DEFAULT

Dual-write creates split-brain risk when one write succeeds, the other fails, two
writers disagree, retries repeat one side or rollback changes only one schema.

## Candidate transitions

| Transition | Recommendation |
|---|---|
| legacy shop owner → membership | backfill + server authorization bridge; avoid clients writing both |
| product price/stock → listing authority | select one write authority, shadow/read-compare compatibility fields |
| listing → search projection | event/outbox-derived projection, not synchronous dual source |
| review/aggregate | keep authoritative review mutation with deterministic aggregate, not independent client writes |
| domain fact → analytics | asynchronous derived event; analytics never write back |

If unavoidable, one server transaction/command owns both writes, stores one
idempotent outcome, detects mismatch, exposes reconciliation and has a time-bounded
retirement criterion. Two independent client requests are prohibited. Trigger
mirroring is not automatically safer and can hide recursion/lock/failure behavior.

No current transition is proven to require long-lived dual-write.
