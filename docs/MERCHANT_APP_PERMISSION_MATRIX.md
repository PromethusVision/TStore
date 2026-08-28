# Merchant App Permission Matrix

Status: **PROPOSED — OWNER REVIEW REQUIRED**  
Wave: 17 / WP08

`✓` varsayılan öneri, `S` explicit shop scope, `—` izin yok, `F` future engine.

| Operation | OWNER | MANAGER | QR_VERIFIER | CATALOG_EDITOR |
|---|---:|---:|---:|---:|
| View assigned shop | ✓ | S | S | S |
| Scan/validate QR | ✓ | S | S | — |
| Confirm purchase | ✓ | S | S | — |
| View QR audit summary | ✓ | S | Own/S | — |
| Search canonical catalog | ✓ | S | — | S |
| Create/edit listing | ✓ | S | — | S |
| Edit price | ✓ | S | — | S |
| Edit availability | ✓ | S | — | S |
| Submit product candidate | ✓ | S | — | S |
| View operational metrics | ✓ | S | — | Optional/S |
| View reviews | ✓ | S | — | — |
| Respond to review | Future decision | Future decision | — | — |
| Edit shop public profile | ✓ | S | — | — |
| Change shop location/status | ✓ | S with guard | — | — |
| Invite/revoke staff | ✓ | Optional/S | — | — |
| Change roles/capabilities | ✓ with safeguards | — | — | — |
| Manage future ads | F | F/S | — | — |

## Mandatory enforcement

- Every mutation checks authenticated user, active membership, organization, target shop and named capability.
- Row ownership is not inferred from a client-supplied merchant/shop id.
- Cross-shop reads are denied unless membership explicitly covers both.
- QR confirmation also validates token-bound shop; permission alone cannot override wrong shop.
- Suspended merchant/shop or policy block supersedes role permission.

## Owner decisions

- Exact manager defaults and whether analytics is visible to catalog staff.
- Whether staff may see customer-authored review content.
- Whether location/status changes need step-up authentication or owner approval.

