# Wave 38C-R — Corrected 0011 Pre-Apply Freeze Gate

## Freeze Identity

- Source HEAD: `e0c10075b6f29d53a819cf1b241810f14ed1a0ea`
- Candidate: `20260830001100_0011_canonical_taxonomy_contract_v2.sql`
- Candidate SHA-256:
  `63552485c8b86cbc6bab3fe24dcd3b0783063464020c4ece00241c42f10f2bb5`
- Artifact-set SHA-256:
  `781dd6351bc0daa7709725fbd4deb509fad63de8bda8e3d24e77be2a1049bda7`
- Rollback SHA-256:
  `fdc79ff3586fe61c8336c68026fd564ebeaec6cb6e890bc93f28778499d9000d`
- Portable LF/CRLF reproduction: **PASS**

The former candidate
`c4961f36f28dcc047d44716ae2de76c5c1828b592078e49293307064959e9353`
is **SUPERSEDED — CONTRACT BUG**. It permitted a structural leaf with
`is_assignable = false` to qualify for product-scope `exact_leaf`; it must not be
restored, approved, or applied.

## Independent Exact-Leaf Gate

The canonical baseline through `0010` was reconstructed locally. With trusted
local preview enabled, the integration probe selected a real structural leaf from
database truth rather than hard-coding the Agent fixture:

- ID: `00084e98-e0ba-494a-8c19-8fa57272abd3`
- Path: `Bilgisayar & Tablet > Klavye, Mouse & Çevre Birimleri`
- Level: `2`
- `has_children`: `false`
- `is_assignable`: `false`
- Policy class: `NORMAL`
- Professional review: `not_required`
- `taxonomy_exact_leaf_v2` product-scope result: `0`
- Structural breadcrumb result: `2` nodes
- Structural search result: `1` matching node

Therefore **STRUCTURAL_PREVIEW != PRODUCT_ASSIGNABILITY**. The corrected RPC
enforces server-side visibility, structural leaf, assignability, eligible policy,
and eligible professional-review state.

## Positive Fixture and Preservation

Inside a local transaction only, the same valid structural leaf was temporarily
made assignable with eligible policy/review state. `taxonomy_exact_leaf_v2`
returned exactly that one node. The transaction was rolled back and the canonical
state was rechecked:

- Nodes: `1563`
- L1/L2/L3/L4: `24 / 244 / 1096 / 199`
- Structural leaves: `1245`
- Unique UUIDs: `1563`
- Real assignable nodes: `0`
- Canonical digest unchanged:
  `042fa87359aad87250be46fc939d7dd0476505199fd43a96fa86b5b1fcc90a04`
- `0010`, canonical payload, and UUID manifest changed: **NO**

## Contract and Rehearsal Result

- Strict v2 contract: `7` data RPCs + `taxonomy_capabilities_v2` = `8/8 PASS`
- Capability product scope:
  `exact-leaf-visible-assignable-policy-eligible`
- `product_scope_requires_assignable`: `true`
- `product_scope_policy_fail_closed`: `true`
- Client/taxonomy/RPC versions:
  `taxonomy-client-v1` / `canonical-v1.0.0` / `taxonomy-rpc-v2`
- Generation: `2`
- v1 backward compatibility: `7/7 PASS`
- Baseline / forward / rollback: `3/3 / 3/3 / 3/3 PASS`
- Idempotency / postcheck: `2/2 / 3/3 PASS`
- Failure/regression matrix: `29/29 PASS`
- Preview OFF / trusted local ON / OFF: `PASS`; ON roots `24`
- Alias states: `4/4 PASS`
- Client compatibility: `MATCH 10`, `ADAPTER_UPDATE_REQUIRED 2`,
  `BACKEND_BLOCKER 0`

The two bounded client changes remain separate work: bind all seven strict reads
atomically to the v2 RPC family with client version/preview parameters, and bind
capability/runtime selection to `taxonomy_capabilities_v2` plus the strict DTO
path. They are not implemented by this freeze.

## Preview Security and Remote State

- Preview default: `OFF`
- Preview enable authority: trusted `service_role`/server operator only
- Ordinary anon/authenticated config read or mutation: `DENIED`
- Trusted preview semantics: Development-wide controlled metadata preview, not a
  private per-user preview
- Service-role secret in client/source artifact: `NO`
- Current Development ledger: `10/10` (preserved evidence; not queried here)
- `0011` remotely applied: `NO`
- Preview remotely enabled: `NO`
- Canonical Customer runtime: `OFF`
- Development accessed during integration: `NO`
- Production accessed/touched: `NO`
- Remote write: `NO`

## Authorization Gate

`DEVELOPMENT_WRITE_AUTHORITY_FOR_CORRECTED_0011: NOT_YET_GRANTED`

The corrected artifact is locally reviewed and frozen with backend blocker `0`.
Any Development apply requires a fresh Product Owner authorization naming the
corrected candidate SHA, followed by a fresh JIT target/ledger/drift/single-writer
gate. This document does not authorize remote access, apply, preview enablement,
runtime activation, or Production work.
