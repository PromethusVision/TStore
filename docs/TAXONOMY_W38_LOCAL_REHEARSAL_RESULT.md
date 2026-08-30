# Wave 38B Local Rehearsal Result

Result: PASS

Execution mode: isolated local PGlite only. No Supabase endpoint, Development project, Production project, Auth, Storage, or Realtime was accessed.

## Baseline

Each cycle rebuilt active migrations 0001 through 0010 from repository SQL and reconstructed the exact ledger version/name pairs.

| Check | Expected | Result |
|---|---:|---:|
| Ledger | 10/10 | PASS |
| Nodes | 1563 | PASS |
| L1/L2/L3/L4 | 24/244/1096/199 | PASS |
| Leaves | 1245 | PASS |
| UUID uniqueness | 1563/1563 | PASS |
| Public active | 0 | PASS |
| Pilot active | 0 | PASS |
| Policy leakage | 0 | PASS |

The harness snapshots the complete canonical category identity/hierarchy/lifecycle/policy rows using a deterministic digest before apply. The same digest is required after preview and after rollback.

## Apply and rollback

- Fresh baseline reconstruction: 3/3 PASS
- Forward candidate apply: 3/3 PASS
- Idempotent second apply: 2/2 PASS
- Strict postcheck: 3/3 PASS
- Rollback: 3/3 PASS
- Frozen category digest preserved: PASS
- Existing v1 signature and behavior: 7/7 PASS

## Preview cycle

In every cycle, preview started OFF and preview root access failed with `W38_PREVIEW_DISABLED`. Direct config access and ordinary-user enablement were denied. The trusted local server role enabled preview, after which the strict contract returned:

- roots: 24;
- recursive children and descendants: PASS;
- L2/L3/L4 structural leaf navigation: PASS;
- authoritative exact-leaf product scopes: 0, matching zero assignable baseline nodes;
- four-level breadcrumb: PASS;
- canonical and alias search: PASS;
- alias states RESOLVED/AMBIGUOUS/TOMBSTONE/UNRESOLVED: PASS;
- policy and professional-review metadata: PASS.

The real authoritative L4 leaf `Lateks Balonlar` remained visible through structural breadcrumb preview while exact-leaf qualification returned zero because `is_assignable=false`. In an isolated transaction it was made assignable with normal policy metadata; exact-leaf returned exactly one row, then rollback restored the authoritative category digest. The trusted role then disabled preview. Preview access failed again. Public active roots and pilot active roots remained 0, and no category lifecycle row changed.

## Failure matrix

29/29 unique regression/failure cases passed:

1. missing lifecycle field;
2. missing policy field;
3. invalid level/hierarchy;
4. malformed alias state;
5. fixture taxonomy-version mismatch;
6. candidate checksum mismatch;
7. unsafe SECURITY DEFINER search path;
8. migration ledger mismatch;
9. unexpected public activation;
10. staged exact leaf with preview disabled returns zero;
11. preview requested while disabled;
12. exact-leaf preview requested while disabled;
13. anon config select;
14. authenticated config mutation;
15. ordinary client preview enablement;
16. client-contract mismatch;
17. taxonomy-data mismatch;
18. malformed UUID;
19. nonexistent UUID exact-leaf request returns zero;
20. real non-assignable leaf exact-leaf request returns zero while structural preview remains visible;
21. locally assignable container returns zero;
22. locally assignable `EXCLUDED` leaf returns zero;
23. locally assignable professional-review-pending leaf returns zero;
24. locally assignable retired leaf returns zero;
25. locally assignable eligible leaf returns exactly one;
26. ambiguous alias without target edges;
27. preview request after disable;
28. existing v1 RPC breakage;
29. rollback interruption.

All local category mutations used for cases 21–25 were transaction-bound and rolled back. The frozen taxonomy digest matched before and after every preview cycle.
