# Data Purpose and Minimization Audit

**State:** PILOT RECOMMENDATION — NO FINAL LEGAL BASIS

## Purpose tests

Every candidate field must pass all six tests: a named current feature needs it;
the purpose is specific; a coarser/aggregate alternative is insufficient; access is
identified; expiry/deletion is implementable; secondary use is separately approved.
“May help later,” “all apps collect it” and “fraud prevention” without a threat/use
case fail the test.

## Pilot collection posture

| Data/use | Pilot posture | Reason |
|---|---|---|
| Account e-mail | collect for Auth | necessary for current account/confirmation/recovery flow |
| Optional profile fields | collect only when displayed/used | avoid speculative enrichment |
| Precise location | process transiently for a requested nearby action | service purpose does not justify history |
| Saved location | explicit private feature only | separate from analytics and merchant reporting |
| Raw search history | do not retain | controlled IDs/outcome classes cover pilot quality |
| Product/surface events | minimum allowlist if approved | no arbitrary metadata/free text |
| QR secret/payload | never logs/analytics | replay and account risk |
| Verified purchase snapshot | minimum server-authoritative evidence | review integrity; not a fiscal record |
| Chat body | service storage only; no analytics | private content |
| Review text | public review plus restricted moderation evidence | customer controls and UGC rules apply |
| Support documents | request only for a defined case rule | high misuse/retention risk |
| Merchant verification document | exact requirement only | avoid full identity dossier by default |
| Ad behavioral profile | do not create | contextual pilot is lower-risk and sufficient |
| Merchant customer-level ad export | prohibit | aggregate reporting is sufficient |
| Reward purchase profile | no V1 economic reward | avoid sensitive/economic processing before decisions |
| Crash report | sanitized build/device/stack/correlation | exclude tokens, body, e-mail, exact location |

## Secondary-use firewall

- Security evidence is not marketing data.
- Support/chat content is not analytics training input by default.
- Nearby location is not an ad movement profile.
- Verified purchase evidence is not audited revenue or automatic reward eligibility.
- Merchant verification data is not customer-facing content.
- An account deletion exception is not permission to use retained data for product
  analytics.

## Deletion proof

For every collected class, a future implementation must test active records,
indexes/caches, Storage, exports, processors and backup restoration behavior. A
successful UI response without downstream reconciliation is not proof of deletion.

`PILOT_OPTIONAL_PROFILING: OFF_RECOMMENDED`
