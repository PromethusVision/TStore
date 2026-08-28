# Backend Account Deletion Contract

**State:** PRESERVES CURRENT SELF-DELETE; FUTURE RETENTION OPEN

Current `delete_current_customer_account` is the canonical authenticated customer
path. It must remain exact-subject, server-authoritative and transactional for
deletable customer-owned rows; admin cleanup is a separately authorized exception.

## Domain effects

| Data | Recommended treatment |
|---|---|
| Profile, saved locations, addresses, wishlist, active cart | delete/minimize under current contract |
| Auth identities/sessions | revoke/delete through supported Auth management path |
| Legal consent | retain/minimize only for approved compliance purpose/version |
| Verified purchases/items | preserve immutable commercial/trust evidence with customer pseudonymization where allowed |
| Reviews/ratings | define delete/anonymize/retain-visible policy without fabricating author/evidence |
| Chat/notifications | delete or pseudonymize under bounded retention; preserve another party's lawful conversation context only as approved |
| Audit/security/ops case | retain restricted minimum when required; not customer analytics |
| Rewards/reputation | append account closure/forfeit/transfer correction; never edit ledger history silently |
| Storage | exact referenced-object workflow and retention; no broad prefix delete |

Deletion must preview dependencies, be idempotent, block new sessions/mutations and
reconcile partial external Auth/Storage effects. Exact historical retention,
pseudonymization and user-visible explanations are `OWNER_DECISION_REQUIRED` with
legal/privacy review. This design authorizes no deletion implementation.
