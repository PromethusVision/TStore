# Reward Identity Model

Status: **PROPOSED — OWNER REVIEW REQUIRED**
Wave: 18 / Workstream K

| Identity | Reward purpose | Stability rule |
|---|---|---|
| Customer | Entitlement owner | Account merge/deletion handled explicitly |
| Merchant organization | Program/funding candidate | Not merchant sector or ad account |
| Shop/branch | Earn/redeem location scope | Rename/move preserves stable ID |
| Verified transaction/item | Strong source event | Immutable server-authoritative evidence |
| Canonical product | Durable product continuity/policy | Merge/split lineage, no mutable name key |
| Variant | Material configuration when rule needs it | Optional and snapshot-backed |
| Shop listing | Local offer snapshot/context | Retirement cannot erase earned history |
| Reward program/rule version | Economic promise | Immutable effective terms per earn event |
| Ledger event | Entitlement history | Unique, append-only and linked |

## Boundaries

Merchant SKU, barcode, taxonomy path/name, display name, ad click and QR token are not reward identity. A raw QR token never reaches the reward ledger; verified transaction identity does.

## Corrections

Catalog rename/move preserves product ID. Merge uses predecessor lineage without re-award. Split never copies progress to every child; ambiguous history remains snapshot-bound until owner-approved mapping.
