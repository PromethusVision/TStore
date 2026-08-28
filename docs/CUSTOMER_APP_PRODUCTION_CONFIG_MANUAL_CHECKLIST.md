# Customer App Production Config Manual Checklist

Status: **MANUAL — NOT EXECUTED IN WAVE 16**  
Production ref expected by release documents: `mefhfvrgkwciubeajjeb`

Wave 16 performed no Production or Development access. This checklist must be
executed by an authorized operator immediately before go/no-go; never paste
secret values into the report.

| Area | Human/browser check | Evidence to retain without secrets | Gate |
|---|---|---|---|
| Project identity | Dashboard name/ref is exact Production; Development ref is excluded | Name/ref screenshot or timestamped operator record | REQUIRED |
| Client config | Release secret store supplies exact Production URL and client-safe publishable/anon key only | Preflight PASS and key-class result, no value | REQUIRED |
| Auth providers | Email provider and intended confirmation policy match release decision | Enabled/state record | REQUIRED |
| Auth redirects | Site URL and allowlist include canonical `com.esnaftavar.app://login-callback/`; no unintended legacy callback | Masked settings evidence | REQUIRED |
| SMTP | Custom sender/domain and deliverability are healthy; no secret display | Provider state and delivery timestamp | REQUIRED |
| RLS | RLS enabled on all customer tables; own-row/cross-user/anon behavior matches canonical policy | Read-only policy inventory plus controlled test result | REQUIRED |
| Role guard | Normal client cannot promote customer to merchant/admin | Controlled negative result | REQUIRED |
| Review RPCs | Frozen submit/update/delete/eligibility contract and grants are present | Function/grant comparison | REQUIRED |
| QR RPCs | Token expiry, merchant ownership, replay and concurrency contract matches canonical migrations | Contract version plus physical acceptance | REQUIRED |
| Realtime | Only intended tables are in publication; clients unsubscribe on lifecycle/session changes | Publication inventory | REQUIRED IF USED |
| Storage | Only canonical active buckets/policies exist; MIME/size/public state match contract | Bucket/policy inventory, object counts | REQUIRED |
| Backup/PITR | Backup schedule/retention and a recent restore proof meet owner policy | Timestamp and restore drill reference | REQUIRED |
| Migration ledger | Canonical applied version and schema agree, with no unexplained drift | Read-only ledger/schema comparison | REQUIRED |
| Business baseline | Demo/real row counts are understood before release; no disposable Auth fixtures remain | Aggregate counts only | REQUIRED |
| Rate/abuse controls | Auth email and public endpoints have intended rate limits | Config state, no secret | RECOMMENDED |
| Monitoring | Owner has accepted absence or selected privacy-compliant crash/incident monitoring | Decision record | OWNER_DECISION |

Any identity mismatch, unexpected user/data, broad grant, schema drift or secret
classification failure is fail-closed. Do not remediate Production under this
checklist; stop and open a separately authorized task.
