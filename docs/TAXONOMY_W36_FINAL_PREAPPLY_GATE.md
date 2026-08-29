# Wave 36 — Final Taxonomy Pre-Apply Gate

**Date:** 2026-08-29

**State:** `PASS — FROZEN LOCAL PACKAGE / EXACT REHEARSAL / CLIENT WIRING; NO REMOTE AUTHORITY`

**Runtime state:** `LEGACY_RUNTIME DEFAULT / CANONICAL RUNTIME NOT ACTIVE`

This document reconciles the exact frozen Development bootstrap candidate, the
offline migration compiler/rehearsal tooling, and the backward-compatible
Customer App cutover seams. It does not authorize or perform a Development or
Production access/write, apply a migration, activate taxonomy, or enable the
canonical runtime.

## 1. Integrated evidence

| Source | Required HEAD | Integration merge | Result |
|---|---|---|---|
| Frozen bootstrap package | `d9c45a1c2acd94fe0bfa52b16772718142c0664a` | `8557ab027a4faf68a709eed4efc5acbba1b756b2` | PASS |
| Migration compiler / exact replay | `0c76416503c9aaa651e1b89e9e645709153a1fbd` | `08febcbf87f5be506b8b43de3bec345e37c46ce5` | PASS |
| Customer canonical cutover wiring | `981731836ed90d7457c9481ef0f48add8ed8cad0` | `e147f2e65059c080b88f96f53b953955617218ec` | PASS |

Integration base was
`origin/main@b3cc14ebed42ab66d689fe6688c2e75e23c43e68`. All sources
were merged in A → B → C order with normal `--no-ff` merges and no conflicts.

## 2. Frozen bootstrap package

The authoritative source and aggregate identity are:

- Source HEAD: `d9c45a1c2acd94fe0bfa52b16772718142c0664a`;
- package SHA-256:
  `095849525ad912cf07ef066bf95d4066e29e2fa478e048acdfab3c5ce1614406`;
- historical `968787...` value: superseded metadata only;
- individual committed Git-blob payload hashes: `6/6 PASS`;
- canonical nodes: `1,563`;
- L1/L2/L3/L4: `24 / 244 / 1,096 / 199`;
- terminal leaves: `1,245`;
- unique RFC 9562 UUIDv4: `1,563/1,563`;
- aliases / alias-target edges: `651 / 1,000`;
- split locators / split-target edges: `210 / 591`;
- public-active / pilot-active / policy leakage: `0 / 0 / 0`.

The six CSV payload Git blobs remain byte-identical to Source A. Payload bytes,
row order and category UUIDs were not regenerated, normalized or rewritten.
Exact verification must use the committed Git blobs or an exact raw-blob export;
a checkout-normalized copy is not an alternative package. Any future payload-byte
change requires a new explicit version, checksum and exact-artifact rehearsal.

The owner-final stable-ID contract remains unchanged: surviving semantic identity
preserves `categories.id`; genuinely new nodes use trusted UUIDv4; rename/move
preserves UUID; split uses explicit successor IDs; merge retains predecessor
history; retirement creates a tombstone; planning key, name, slug and path are not
runtime identity. Live Development had zero taxonomy rows at the last authorized
read-only preflight, so this frozen package contains newly allocated Development
candidate UUIDs. No UUID was allocated during this integration.

## 3. Migration tooling and exact local rehearsal

- compiler: deterministic and checksum-mandatory;
- exact package verification: PASS;
- exact artifact rehearsal: PASS;
- fresh rebuild / forward / rollback: `3/3 / 3/3 / 3/3 PASS`;
- idempotent second apply: `2/2 PASS`;
- failure matrix: `16/16 PASS`;
- postcheck: `3/3 PASS`;
- rehearsed artifact equals Development candidate: YES;
- integration replay artifact-set SHA-256:
  `75c122e34f38f38bc6a38534c6ea73e59acde630a450d44a1cb0da295a9289b7`;
- JIT precheck tooling: dry/offline and PASS;
- local apply: explicit `--local` required;
- remote/Production/Development/apply flags: fail-closed rejected;
- active `supabase/migrations` chain: unchanged;
- embedded credential, project token or remote mode: absent;
- rollback: scoped to the exact empty-Development bootstrap package state;
- ambiguous split: never mapped to an arbitrary first child.

The integration rehearsal used an exact temporary raw-Git-blob export and local
PGlite only. Temporary normalized compiler inputs/artifacts were deleted and were
not committed or substituted for the frozen source package.

## 4. Customer App cutover preparation

- canonical DTO and strict lifecycle/policy mapping: PASS;
- canonical repository interface/implementation seam: PASS;
- capability seam: `LEGACY_RUNTIME / CANONICAL_V1_RUNTIME` PASS;
- current default: `LEGACY_RUNTIME`;
- current Supabase backend canonical field/RPC calls: zero;
- Home legacy behavior: preserved;
- canonical Home: exact 24 discoverable L1 roots when a future proof is enabled;
- recursive L2/L3/L4 container/leaf browsing and breadcrumb: prepared;
- `EXACT_LEAF / DESCENDANTS` product scopes: prepared;
- canonical server-search contract: prepared;
- inactive, retired and policy/professional-review blocked states: fail-closed;
- capability proof failure: error, with no silent legacy fallback;
- concrete remote adapter, `service_locator.dart` activation and final UI Kit:
  not implemented.

Canonical mode cannot be enabled by timeout, missing-column behavior, empty data,
project-name inference or a remote flag. It requires the exact versioned backend
contract proof and later explicit Development-only DI binding.

## 5. Remaining gates before any Development write

1. Product Owner explicit Development-write authorization scoped to
   `EsnaftaVar Development / tnipyxnvhgelwdpykyez`.
2. Authorized JIT verification of the exact Development target.
3. JIT confirmation that categories/products/shops/shop_products remain
   `0/0/0/0`.
4. JIT schema and migration-history drift check against the frozen contract.
5. Single-writer ownership and write-freeze confirmation.
6. Exact package source HEAD, individual payload hashes and aggregate SHA
   verification.
7. Exact migration artifact/compiler lineage verification.
8. Explicit Product Owner acknowledgement of the bounded empty-Development
   recreation risk.
9. Postcheck/rollback operator and exact commands ready before apply.

The package is ready for a separately authorized JIT read-only precheck and for
the Product Owner to make the bounded Development-write/recreation-risk decision.
No such decision is made here. Remote apply remains not ready until the decision,
fresh JIT evidence and operational readiness gates above all pass.

## 6. Professional and policy gates

Professional-review and policy gates do not block staged, inactive canonical
existence. They must remain fail-closed and block inappropriate assignability,
public visibility and pilot activation. Wave 36 does not approve, waive or
activate any policy-sensitive node.

## 7. Empty Development recreation risk

Development Free plan has no scheduled backup, PITR or verified native
restore-to-new-project path. The last authorized live evidence showed empty
application tables, so a future Product Owner may explicitly accept
`EMPTY_DEVELOPMENT_RECREATION` risk for this staged bootstrap only. This
integration does not accept that risk. It must never be generalized to
Production or to a future Development environment containing real data.

## 8. Validation and safety ledger

- frozen package raw Git-blob hashes / aggregate digest: PASS;
- exact local migration rehearsal: PASS;
- targeted taxonomy/Home tests: `48/48 PASS`;
- full Flutter suite: `1,267 PASS / 0 FAIL / 6 documented environment/live skips`;
- `flutter analyze --no-pub`: `0 issues`;
- Development access/write: NO / NO;
- Production access/write: NO / NO;
- migration apply or active-chain change: NO;
- taxonomy/canonical runtime activation: NO;
- Figma/final UI Kit change: NO.

`W36_FINAL_PREAPPLY_INTEGRATION: PASS`

`FROZEN_BOOTSTRAP_PACKAGE: PASS`

`EXACT_MIGRATION_REHEARSAL: PASS`

`CUSTOMER_CANONICAL_WIRING: PASS`

`LEGACY_RUNTIME_DEFAULT: PASS`

`READY_FOR_JIT_DEVELOPMENT_PRECHECK: YES`

`READY_FOR_DEVELOPMENT_WRITE_DECISION: YES`

`DEVELOPMENT_WRITE_AUTHORIZED: NO`

`READY_FOR_REMOTE_APPLY_NOW: NO`

`REMOTE_WRITE_PERFORMED: NO`

`PRODUCTION_TOUCHED: NO`

`CANONICAL_RUNTIME_ACTIVE: NO`
