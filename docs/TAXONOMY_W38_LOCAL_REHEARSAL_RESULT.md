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
- L2/L3/L4 exact-leaf coverage: PASS;
- four-level breadcrumb: PASS;
- canonical and alias search: PASS;
- alias states RESOLVED/AMBIGUOUS/TOMBSTONE/UNRESOLVED: PASS;
- policy and professional-review metadata: PASS.

The trusted role then disabled preview. Preview access failed again. Public active roots and pilot active roots remained 0, and no category lifecycle row changed.

## Failure matrix

20/20 unique cases passed fail-closed:

1. missing lifecycle field;
2. missing policy field;
3. invalid level/hierarchy;
4. malformed alias state;
5. fixture taxonomy-version mismatch;
6. candidate checksum mismatch;
7. unsafe SECURITY DEFINER search path;
8. migration ledger mismatch;
9. unexpected public activation;
10. preview requested while disabled;
11. anon config select;
12. authenticated config mutation;
13. ordinary client preview enablement;
14. client-contract mismatch;
15. taxonomy-data mismatch;
16. malformed UUID;
17. ambiguous alias without target edges;
18. preview request after disable;
19. existing v1 RPC breakage;
20. rollback interruption.

Valid nonexistent UUID behavior was also exercised by endpoint postchecks: no guessed category is returned.
