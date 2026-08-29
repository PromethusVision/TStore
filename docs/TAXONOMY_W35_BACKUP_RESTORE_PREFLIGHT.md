# Wave 35A — Development Backup / Restore Preflight

**State:** `NOT VERIFIED`

## What was observed read-only

On the exact `EsnaftaVar Development / tnipyxnvhgelwdpykyez` Dashboard:

- organization plan label was `Free`;
- the project was paused;
- the paused-state notice said database data, backups and Storage objects remain
  safe;
- it offered a `Download backups` action and stated data remains available for
  download even after the displayed resume deadline;
- the project can currently be resumed until 27 September 2027.

No backup was downloaded and no project state was changed.

## Capability classification

| Capability | Result | Reason |
|---|---|---|
| Backup/export entry point present | **OBSERVED** | Dashboard offers download while paused |
| Current backup inventory | **NOT VERIFIED** | Backup detail view disabled while paused |
| Manual logical backup restorable | **NOT VERIFIED** | No export/download or restore test executed |
| Point-in-time restore | **UNKNOWN** | Not shown/verified; Free-plan assumptions are not used |
| Disposable restore rehearsal | **NOT PERFORMED** | Explicitly outside Wave 35A |
| Pre-migration rollback point | **NOT READY** | No fresh artifact/hash/restore evidence |

The existence of a download button is not proof that an artifact is current,
complete or restorable. A future write window must not proceed until a fresh,
secure backup strategy and a disposable restore rehearsal are documented.

`BACKUP_RESTORE_PREFLIGHT: NOT_VERIFIED`

`BACKUP_EXECUTED: NO`

`RESTORE_EXECUTED: NO`
