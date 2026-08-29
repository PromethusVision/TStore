# Wave 35A — Development Environment Read-Only Preflight

**Date:** 2026-08-29

**Requested target:** `EsnaftaVar Development`

**Expected ref:** `tnipyxnvhgelwdpykyez`

**State:** `PARTIAL — TARGET VERIFIED; LIVE DATABASE PROFILE BLOCKED`

## Identity gate

Before any database query, an authenticated Supabase Dashboard page was opened
directly for the expected ref. Two independent visible signals agreed:

- page title: `EsnaftaVar Development | Musaki bilisim | Supabase`;
- project URL/ref: `/dashboard/project/tnipyxnvhgelwdpykyez`.

The forbidden Production ref was not opened, queried or used for comparison.
The Dashboard's `main / Production` label describes the selected Supabase branch
type inside **EsnaftaVar Development**; it is not the separate EsnaftaVar
Production project. The project name and ref remain the controlling identity
signals.

## Live availability result

The verified Development project was paused at inspection time. The Dashboard
reported:

- `Project "EsnaftaVar Development" is paused`;
- SQL Editor, Table Editor, database metadata sections and migrations view were
  disabled;
- data, backups and Storage objects remain safe;
- the project can be resumed from the Dashboard until 27 September 2027;
- an export/download-backups path is presented.

Resuming the project changes remote project state. Wave 35A authorizes remote
reads only, so the project was **not** resumed. No SQL statement or business RPC
was executed.

## Evidence available now

| Item | Result | Evidence boundary |
|---|---|---|
| Exact Development name/ref | **PASS** | Authenticated targeted Dashboard |
| Environment mismatch risk | **Controlled** | Exact name and ref both matched before remote inspection |
| Project operational state | **PAUSED** | Authenticated Dashboard |
| Current Postgres/server version | **UNKNOWN** | SQL/catalog access disabled |
| Current migration ledger | **NOT VERIFIED** | Migrations view disabled |
| Current schema and drift | **NOT VERIFIED** | Database metadata disabled |
| Current table/category/product counts | **NOT VERIFIED** | No SQL access |
| Historical repository evidence | `0001–0009`, 23 public tables, 23/23 RLS | Not fresh live evidence |

Current-main documentation records that canonical `0001–0009` was previously
applied to Development and that earlier postflights observed 23 public tables
with RLS. Those records are useful history, but they do not replace the fresh
live profile requested by this wave.

## Remote safety ledger

- Development management reads: **YES** — targeted identity, pause and backup
  availability pages only.
- Development database reads: **NO** — unavailable while paused.
- Development writes: **NO**.
- Project resume: **NO**.
- Backup download/restore: **NO**.
- Production access: **NO**.
- Secret/key/token/password exposure: **NO**.

## Required continuation gate

A separately authorized operator must resume the Development project. After it
is running, rerun this same branch/task as read-only and collect the exact
ledger, schema, category, product and dependency profile before any Development
write authorization is considered.

`DEVELOPMENT_TARGET_VERIFIED: PASS`

`LIVE_DATABASE_ACCESS: BLOCKED_PROJECT_PAUSED`

`REMOTE_WRITES_PERFORMED: NO`

`PRODUCTION_ACCESSED: NO`
