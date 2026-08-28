# Operations Permission Matrix

**State:** CONCEPTUAL — NO RLS OR AUTHORIZATION IMPLEMENTATION

Legend: `A` allowed within assigned scope; `P` propose/escalate only; `2P` high-risk second review candidate; `—` denied.

| Action | SUPPORT | MODERATOR | MERCHANT_VERIFICATION | CATALOG_REVIEWER | POLICY_REVIEWER | BREAK_GLASS |
|---|:---:|:---:|:---:|:---:|:---:|:---:|
| View assigned customer case | A | A | P | P | P | A |
| View minimized merchant/shop | A | A | A | A | A | A |
| Verify ordinary merchant | P | — | A | — | P | A |
| Verify regulated merchant | — | — | P | — | A/2P | A |
| Suspend merchant | P | P | P | — | A/2P | A |
| Review catalog candidate | P | — | — | A | P | A |
| Merge canonical product | — | — | — | 2P | P | A/2P |
| Split canonical product | — | — | — | 2P | 2P | A/2P |
| Review reported review | P | A | — | — | P | A |
| Review listing/media | P | A | P | P | P | A |
| Review ad campaign | P | A | P | — | A | A |
| Review QR/reward fraud | P | A | P | — | P | A |
| Reverse operational mistake | P | P | P | P | P | A/2P |
| View case audit trail | A | A | A | A | A | A |
| Search broad audit history | — | P | P | P | P | A |
| Change policy status under approved ruleset | — | P | P | — | A/2P | A |
| Create/change root policy | — | — | — | — | P | — |
| Grant operator role/capability | — | — | — | — | — | A/2P |
| Export PII/evidence | — | P | P | P | P | A/2P |

## Enforcement requirements

- “View” is field-level and purpose-bound, not full-record access.
- `P` never mutates authoritative state.
- `2P` requires a distinct approver when an independent operator exists; one-person pilot uses delayed retrospective review and cannot self-erase evidence.
- Break-glass is short-lived, re-authenticated, reasoned, alerted, and reviewed.
- Root product/policy choices remain Product Owner/legal decisions and are not operator permissions.
- Every server call rechecks operator, capability, case, subject scope, lifecycle, and policy version.

`PERMISSION_MATRIX_FINAL: NO`

`CLIENT_SIDE_AUTHORITY: NO`
