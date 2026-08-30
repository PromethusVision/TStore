# Wave 38 Acceptance Activation Requirement

Date: 2026-08-30

## Classification

**C — BACKEND CONTRACT CHANGE REQUIRED**

## Why C

The current public RPCs intentionally filter out every staged/inactive node, so the 1,563-row candidate tree cannot be used for real Customer acceptance while public active remains zero. More importantly, activation by itself would still not satisfy the Wave 36 strict client contract:

- roots/children/breadcrumb do not carry the lifecycle, policy, professional-review, and leaf/container evidence required for fail-closed navigation;
- alias resolution cannot distinguish ambiguous, tombstone, unresolved, and absent outcomes;
- search does not return a server-owned path, node shape, alias context, or version;
- descendants and exact-leaf qualify IDs but there is no product-query RPC;
- no authoritative backend capability response proves `taxonomy-client-v1`, exact signatures, required response shapes, and semantic invariants.

The Flutter client must not reconstruct these server-owned truths, infer them from missing rows, or use privileged credentials.

## Exact prerequisite before Wave 38B

An additive backend-owned contract task must provide and verify all of the following in Development:

1. an authoritative capability response with client contract version, taxonomy data version, exact required features, and verified semantic evidence;
2. strict versioned node projections containing lifecycle, assignability, policy, professional-review, and authoritative leaf/container state;
3. versioned breadcrumb output with enough strict node data to validate the entire path;
4. explicit alias outcomes for `RESOLVED`, `AMBIGUOUS`, `TOMBSTONE`, and `UNRESOLVED` without exposing unsafe targets;
5. search results containing the matched strict node, server-owned path, alias context when applicable, and taxonomy version;
6. a defined product-listing scope contract, or an explicit declaration that exact/descendant RPCs only qualify category IDs and a separate repository owns product retrieval;
7. one safe acceptance visibility strategy:
   - a Development-only preview contract protected without service-role credentials in Flutter, **or**
   - a controlled pilot/public activation operation with rollback and smoke gates.

After the additive contract is deployed, its signatures, grants, RLS behavior, version semantics, and response shapes must be re-inventoried read-only. Only then may the capability proof be constructed and a Development-only acceptance build explicitly request canonical mode.

## Rejected shortcuts

- treating “RPC did not throw” as proof;
- converting an empty alias response into `UNRESOLVED`;
- deriving leaf/container or policy state client-side;
- N+1 recursive category reads;
- enabling canonical mode through an unverified Dart define;
- silently falling back to legacy after an explicit canonical request;
- embedding service-role/server credentials;
- activating staged rows within this task.

## Current acceptance status

Real 24-root Customer acceptance is **not ready**. Legacy remains the explicit default in Development and Production. The deployed RPC adapter is available for contract-level use and tests only; it is not connected as the canonical repository.
