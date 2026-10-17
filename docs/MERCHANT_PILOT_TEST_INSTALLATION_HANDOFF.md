# Merchant pilot — approved test installation, J3

17 October 2026. **PASS — item A installed on Development only.**
Base main: `e839a25a365efb2709c3c10d12bc973b18360e5c` (J2 integration).
Source reviewed and integrated: `3e145b2da10b64808b50c4751713c0f732d698cf`.
Documentation branch: `agent/merchant-pilot-test-install`. Main merge belongs to
Integration Agent; merging this receipt must not rerun the installation.

## Authorization and actual action

The Product Owner explicitly approved the two missing database components in
[review-packet item A](MERCHANT_PILOT_APPROVAL_PACKET.md), conditional on Integration
PASS, then confirmed PASS. Git ancestry and an empty integrated-source diff were
verified. Target was independently verified in the signed-in Supabase dashboard:
**EsnaftaVar Development / `tnipyxnvhgelwdpykyez`**. Production was never accessed.

Only the following unchanged migrations were installed, with their two new ledger
entries, in one reviewed atomic transaction:

| Source | LF SHA-256 |
|---|---|
| `20261013001600_0016_catalog_listing_media.sql` | `e4eb68ffb47594f411a263361b43d026483fe45c76fb95f0421edaf78c3786cb` |
| `20261014001700_0017_merchant_daily_operations.sql` | `c677c9cd696292e278a5bc6754e1e7f0cbccb62f9854932614ae860c37d40e3d` |

- Approved plan: `8bf0303b5c3c2ea48663b73eb15c83e922617474ce9e83362ad82dff54a0348a`.
- Exact candidate: `f78649db633330708fdc4732fda6431c7f615291a8e17884e27730a46a1a5087`.
- Submitted SQL: `33a9447253f802b0c488f2e1c5f8053423e683f054541d635757f2f6c59ebf96`.
- The sole execution wrapper addition was a transaction-local review token after
  the outer BEGIN. Removing that line reproduces the exact reviewed candidate.
  Editor text was copied back and checked before execution; no stored snippet,
  credential export, generic migration push or historical ledger repair was used.

The UI reported `Success. No rows returned.` The apply was executed **once**.
Independent read-only postchecks confirmed its committed effects. Six new tables,
the private listing-media bucket and the related functions/policies are present.
No category activation, Auth setting save, account/role provisioning, catalog
population, notification repair or downstream feature enablement was performed.

## Hosted verification

| Check | Result |
|---|---|
| Fresh preflight | PASS; exact baseline `d4cb86def9cc856135f09ab83588b83c`, products 0 |
| Concurrent preparation | No other active DDL or matching advisory lock observed; transaction also acquired its lock and rechecked baseline |
| Migration history | 13 entries: original eleven unchanged, exactly the two approved additions |
| Stored migration source | Both single-statement ledger hashes match approved LF SHA-256 values |
| Public tables / RLS | 35 / 35; six expected A tables added |
| Required client functions | Eight owner-only Merchant RPCs plus matching Customer media projection; existing contract checks PASS |
| Photo Storage | Private `listing-media`, 8 MiB limit, JPEG/PNG/WebP |
| Catalog configuration | Six photos maximum; decisions disabled |
| Original schema and permissions | Filtered original metadata projection retains exact baseline MD5 |
| Taxonomy | Exact unchanged MD5 `d53b64debde1b8c79909acf7997472d0`; activation remains closed |
| Products / identities | 0 / 0; installation did not populate the catalog |
| Full observed post-schema | MD5 `6b26d924c04ad9aa568f15bfcf3279bf` |

The original-object projection includes captured tables/columns, functions and
their definitions/permissions, policies, constraints, indexes, triggers, client
column/table grants, existing buckets, postgres/public defaults and managed RLS
event triggers. It excludes newly approved object identities before comparing
with the preflight baseline. It is structural preservation evidence, not a row
backup or proof that no unrelated external actor changed application content.
The six pre-existing corrupted Turkish notification literals were preserved.

Evidence: [sanitized receipt](data/merchant_pilot_test_installation.json) and
[read-only verification SQL](data/merchant_pilot_test_installation.readonly.sql).
The SQL contains no credentials or user rows and runs in BEGIN READ ONLY / ROLLBACK.
Run it only against the authorized Development project; compare results to the
receipt rather than substituting a new expected fingerprint after unexplained drift.
Its compact core snapshot uses the existing `validateCore` checker; the checker's
legacy `BASE_CORE_LOCAL_CONTRACT_PASS` label is not remote behavioral acceptance.

Two observation issues were resolved without repeating the write: the first large
read-only result stalled browser rendering, so the page was reloaded; the first
compact query used a reserved CTE name and failed with 42601 before reading data.
The corrected compact query passed. Neither issue changed the installed schema.

## Accepted intake decision and remaining gates

Canonical §4.7 records the owner's acceptance of broad-sector applications and
gradual small cohorts in Esenler, including barber/salon candidates. Physical
goods require their own eligible categories and existing review rules. Services,
appointments, service prices and slots remain TBD; services must not be disguised
as stocked products. Participants, first cohort size and actual category leaves
are still undecided. No FROZEN rule or Customer screen changed.

Items B–E remain separate approval gates: exact category activation, additive Auth
callbacks, real accounts/catalog provisioning, and a rehearsed forward repair of
the two notification functions. Production, provider setup, real recovery mail,
physical two-device QR, signed distribution and final pilot acceptance remain open.
Do not rerun A: the ledger/baseline guard now correctly rejects the old candidate.
If a later issue arises, preserve evidence and propose a forward correction;
do not automatically drop tables, clear media or rewrite migration history.

## Validation scope

This task changes documentation/evidence only in Git; application code, migration
sources and dependencies are unchanged. Hosted structural checks above are new
evidence. The existing 29 Node checks were rerun: 28 initially passed; one local
HTTP test hit sandbox EACCES on 127.0.0.1. Its four-test safety file then passed
outside that network restriction, leaving all 29 distinct checks PASS. Receipt,
source/ledger hashes, read-only SQL hash and exact execution-wrapper validation
also passed, as did diff/secret checks. Normalize CRLF to LF for the stored
verification SQL SHA-256 when reproducing on a Windows checkout.
J2's 18 managed local groups / 18 nested Flutter checkpoints remain prior
integrated behavioral evidence, not hosted user journeys.
Flutter analyzer/builds and full Flutter tests need no rerun for these receipt-only
changes; no new APK or physical acceptance claim is made.
