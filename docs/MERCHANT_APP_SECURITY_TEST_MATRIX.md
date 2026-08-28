# Merchant App Security Test Matrix

Status: **PROPOSED — REQUIRED BEFORE PILOT**
Wave: 17 / WP84

| Threat | Test |
|---|---|
| Role escalation | Staff attempts owner/manager/capability mutation via UI, API and direct table |
| Cross-shop access | Forge shop/org/listing IDs in reads and writes |
| Revoked membership | Reuse token/cache/deep link after revoke |
| QR fraud | Guess/tamper/expired/replay/wrong-shop/concurrent token |
| Canonical tampering | Listing editor sends protected product fields |
| Price tampering | Negative/extreme/precision/stale/bulk payload and replay |
| Candidate spam | Duplicate IDs, barcode conflicts, policy categories, rate burst |
| Customer leakage | Analytics/review/QR response probes and low-cohort inference |
| Media abuse | Path traversal, MIME spoof, oversized, cross-shop delete/read |
| Deep link | Untrusted route/context, stale session, cross-shop object |
| Admin secret | Client bundle/source/log scan and public grant audit |
| Security-definer | Search path, grants, caller scope and generic mutation rejection |

P0 tests must run against actual backend constraints/RLS/RPC in an isolated environment; mocked UI tests are insufficient.
