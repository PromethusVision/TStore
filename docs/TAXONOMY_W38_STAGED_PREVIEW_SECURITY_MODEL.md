# Wave 38B Staged Preview Security Model

Status: LOCAL DESIGN AND REHEARSAL — REMOTE PREVIEW NOT ENABLED

## Security objective

Permit a future separately authorized Development acceptance session to read staged canonical taxonomy through strict RPCs without making any node public, pilot-active, commercially assignable, or generally available. Migration deployment alone must expose nothing new.

## Architecture

The candidate introduces one singleton server table, `taxonomy_contract_config`, with preview support and an explicit `preview_enabled` flag. Its default is `false`. Read RPCs accept an explicit `p_preview` boolean and call a common contract guard.

Visibility is:

- non-preview: only `lifecycle_state='active' AND is_active=true`;
- preview: staged nodes are additionally readable only while server preview is enabled.

Preview changes visibility in the strict response path only. It does not update category or alias lifecycle rows.

Preview visibility alone never grants product scope. `taxonomy_exact_leaf_v2` separately enforces structural leaf status, `is_assignable=true`, policy eligibility, and professional-review eligibility. Thus the unchanged staged baseline can be navigated while its 1,245 non-assignable leaves remain unqualified for product assignment.

## Control path

`taxonomy_set_preview_v2(enabled, taxonomy_version)` is the only candidate control function. Execute is granted to `service_role` and denied to `PUBLIC`, `anon`, and `authenticated`. No service-role material is returned or embedded in SQL, fixtures, documentation, or Flutter.

A future remote sequence requires separate authorization:

1. apply reviewed backend migration to the exact Development project;
2. confirm preview remains OFF;
3. obtain Product Owner authorization for a bounded acceptance window;
4. use trusted server-side operations—not the mobile app—to enable preview;
5. configure a Development-only client run to request preview;
6. verify capability versions, preview enabled, and 24 roots;
7. perform acceptance;
8. disable preview and prove roots are unavailable again.

None of these remote actions occurred in Wave 38B.

## Least privilege

- `taxonomy_contract_config` has RLS enabled.
- Direct table privileges are revoked from `PUBLIC`, `anon`, and `authenticated`.
- Ordinary users cannot call the setter.
- Public read endpoints are `SECURITY DEFINER` only to reach protected staged data through bounded queries.
- Every `SECURITY DEFINER` function fixes `search_path` to `pg_catalog, public`.
- Inputs are typed and length/version validated.
- There is no dynamic SQL.
- No endpoint returns config secrets or service-role material.

## Threat analysis

| Threat | Control | Local evidence |
|---|---|---|
| Deployment accidentally publishes taxonomy | preview defaults false; baseline guard requires 0 public/pilot active | 3/3 postchecks |
| App turns preview on | setter not executable by anon/authenticated | denied in failure matrix |
| Direct config inspection/mutation | table grants revoked and RLS enabled | anon select and authenticated update denied |
| Client lies about compatibility | exact client/data versions checked server-side | both mismatch cases denied |
| Ambiguous alias guessed | graph invariant and explicit state | corrupted graph denied |
| Preview waives policy | policy and professional-review metadata preserved; assignability unchanged | policy fixture checks |
| SECURITY DEFINER hijack | fixed search path, typed queries, no dynamic SQL | static validator |
| Remote environment coupling | no project ref or credential in generic SQL | secret/environment scan |

## Production-safe default

Applying the candidate with no follow-up action leaves preview OFF, canonical runtime OFF, public active roots 0, pilot active roots 0, and all existing v1 behavior intact. A Production apply or preview enablement is not authorized by this design.
