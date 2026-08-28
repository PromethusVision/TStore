# Backend Security Contrarian Review

**Result:** BALANCED — FAIL CLOSED AT TRUST BOUNDARIES

## Risks of under-security

- trusting client profile role or hidden UI enables merchant/admin escalation;
- direct owner IDs without active membership leak cross-shop mutations;
- permissive security-definer RPCs create IDOR/service-role-equivalent behavior;
- analytics/client events can forge purchase, review, reward or reputation evidence;
- Realtime publication without row authorization leaks data after user switch;
- QR preview/consume without exact-shop/one-winner checks enables replay;
- broad public reads leak PII, location, drafts or operational security evidence.

## Risks of unnecessary complexity

- dozens of roles produce untestable privilege combinations;
- a universal privileged API increases blast radius compared with scoped commands;
- universal event sourcing/outbox adds new credentials, retries and failure modes;
- encrypting or retaining every field without a data-class purpose harms operations;
- automated moderation before evidence volume may create opaque false positives;
- forcing all reads through RPCs obscures simple RLS and complicates caching.

## Balanced position

Use least-privilege RLS, a small capability model, scoped transactional commands,
idempotency/revisions, focused audit and data classification. Keep public reads
simple. Defer infrastructure and automation until measurable threats/scale justify
them. P0 trust boundaries fail closed; low-risk availability failures degrade
safely and remain observable.

