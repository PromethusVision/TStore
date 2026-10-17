# Merchant pilot — approved C/E test application, J5

17 October 2026. **PASS — C and E applied to Development only.**
Integrated main: `e7efc4d64a18fab7ec2e88fc57dc05a33b3669f0`.
Reviewed J4 source: `11c3a651a717d966ea321aa507aaa30372797fc3`.
Evidence branch: `agent/merchant-pilot-test-ce`.

The Product Owner explicitly authorized C callbacks and E notification text
repair after reporting Integration PASS. Git ancestry and the unchanged relevant
integrated sources were verified. The authenticated dashboard independently
identified **EsnaftaVar Development / `tnipyxnvhgelwdpykyez`** before both actions.
No Production access or write occurred. Main integration belongs to Integration
Agent; merging this evidence must not execute A or E again.

## C — completed configuration change

A fresh URL Configuration read showed an empty redirect list and Site URL
`http://localhost:3000`. One save added exactly:

```text
com.esnaftavar.app.merchant.pilot://login-callback/
com.esnaftavar.app.merchant.pilot://login-callback/?auth_action=password_recovery
io.supabase.tstore://login-callback/
io.supabase.tstore://login-callback/?auth_action=password_recovery
```

The page was reloaded: all four persisted and Site URL remained unchanged.
No wildcard, additional destination or unrelated Auth setting was added/edited.
SMTP, email confirmation and templates were not edited; they were not freshly
re-read in this task. The prior complete Auth plan identity remains
`70aa95a39563af8cc4951643e84dc74c886fdd49eabf31b1906a39b4036fcd35`;
the fresh comparison independently covers its URL subset only.
This is configuration acceptance, not real email delivery, PKCE or device proof.

## E — completed atomic correction

The J4 source-bound review bundle was regenerated from the integrated source.
All bundle hashes passed. Fresh read-only preflight matched the exact post-A
schema and found no other active DDL or advisory locks. The transaction itself
also acquired its reviewed lock and rechecked the baseline.

| Identity | Value |
|---|---|
| Approved plan SHA-256 | `9545ccd2900ca25e01546ff5068e57e4d3e84c23110fb235c65fabf541df5890` |
| Candidate SQL LF SHA-256 | `458ad3e7da553308bd6151cb93406d0ab002142acf68cad46ed1bf87d5021860` |
| Submitted SQL LF SHA-256 | `0bd7b2f7bb2646a28b730069feb69ff9a0925d5a1116435a8ab2067403c6b996` |
| Source SQL LF SHA-256 | `529836466b799df8c59ecbfa688e7f54f8d495c271c20663213be08bff0b3f96` |
| Before full schema MD5 | `6b26d924c04ad9aa568f15bfcf3279bf` |
| After full schema MD5 | `78f248b24aa67f7befcc7ccdb9ec97bd` |
| New ledger entry | `20261017003200 / 0032_pilot_notification_text_repair` |

Only the transaction-local review-token line was inserted after the outer BEGIN.
Removing that line reproduces the exact candidate. Editor text was copied back
and compared before execution. The candidate was submitted **once**, without a
saved SQL snippet, generic migration push, replay or credential export. The UI
reported `Success. No rows returned.` Independent read-only checks then verified
the committed result against the existing local proof.

The two existing functions now contain the canonical six Turkish literals:
“Bir kullanıcı”, “Yeni mesajın var”, “%s sana yeni bir mesaj gönderdi.”, “Mağaza”,
“Alışverişin onaylandı” and “%s alışverişini onayladı.”
Recipient rules, action metadata and the shared notification system are preserved.
No notification was sent to test the repair and no historical row was rewritten.

## Hosted postchecks

| Check | Result |
|---|---|
| Full schema | Exact local-proved after MD5 |
| Chat function MD5 | `99dd8841f5092b10634f25109e99f3b3` |
| Purchase function MD5 | `c1f3e83146c67dc68b74d34dd692e311` |
| Function authority | Same OIDs, postgres owners, ACLs, settings and all captured metadata |
| Prior migration history | All 13 entries, names, statement counts and stored source hashes unchanged |
| Added migration history | Exactly one entry; one statement; approved source LF SHA-256 |
| Public tables / RLS | 35 tables, zero without RLS; unchanged |
| Taxonomy MD5 | `d53b64debde1b8c79909acf7997472d0`; unchanged |
| Catalog decisions | OFF; unchanged |
| Products / identities | 0 / 0; unchanged |
| Notification rows | 0 before and after; aggregate fingerprint unchanged |

The hosted notification table was empty, so this is not new proof of preserving
populated history. J4's integrated 18-group local rehearsal supplies that behavior
and UTF-8 output tests. No hosted accounts, merchant roles, products, categories,
user journeys, push-provider setup or physical acceptance were created/performed.

Evidence: [sanitized receipt](data/merchant_pilot_test_ce_installation.json) and
[repeatable read-only check](data/merchant_pilot_test_ce.readonly.sql).
The latter uses BEGIN READ ONLY / ROLLBACK and returns metadata/counts/hashes only,
not user rows, credentials or executable function definitions. Run only against
the authorized Development target; never relax expected hashes after unexplained
drift. SQL LF SHA-256:
`ca2b35527d4cd95f85a2a84e06b7abfd9a34207bdf9dbc3c22d88d11794de8d2`.

## Validation and integration boundaries

- **46 distinct Node checks PASS.** Initial run: 45 PASS and one loopback HTTP
  EACCES caused by the sandbox. The four-test safety file passed outside that
  restriction; no test or implementation was changed to obtain PASS.
- Receipt validation checks the exact current repair source/candidate/submitted
  wrapper, before/after schema, functions/authority, all old ledger hashes, the
  single new ledger entry, URL subset and unchanged gates/history fingerprints.
- Git changes are documentation/evidence only. App/runtime code, dependencies,
  historical migrations, proposal and runner sources remain unchanged. Flutter
  analyzer/builds were not rerun; J4's 144 Flutter tests and clean analyzer remain
  prior integrated evidence, not new hosted behavioral acceptance.
- Review the six-file evidence diff; do not reapply the old A/E bundle. Any later
  issue requires preserving evidence and a separately reviewed forward correction.
  Do not drop objects, remove migration history or reset callbacks automatically.

## Remaining pilot work

B category leaves and D account/catalog provisioning remain unselected and
unapproved. Real recovery email, device callbacks, Customer–Merchant physical QR,
provider integration, signed distribution, support readiness and final Product
Owner pilot opening remain separate gates. C/E PASS does not close J or certify
the application for pilot distribution.

Suggested next package: select a small initial merchant cohort and its real
physical products, prepare an exact category/catalog/account proposal, then ask
for bounded B/D approval. Continue broad-sector intake without presenting haircuts,
appointments or other undefined services as stocked products.
