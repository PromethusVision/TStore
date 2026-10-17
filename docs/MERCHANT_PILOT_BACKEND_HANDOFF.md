# Merchant J1 — base-core pilot backend rehearsal

Baseline: `c801292bf1c22dac25982f95e4c58becb99b9835` (integrated J0 security correction).
Task branch: `agent/merchant-pilot-backend-readiness`.
Product authority: canonical §4.4–4.5 and implementation slices J0/J1.

The previously accepted suites enabled later commerce capabilities. They did not
prove the exact default-OFF pilot composition against the smallest supported
Development backend using the actual application repositories. J1 closes that
local evidence gap. It changes test tooling and documentation, not app behavior,
Customer screens, signing, dependencies, database permissions or migration bytes.

## Architecture and screen-to-contract inventory

The existing five Merchant tabs and shared service composition remain in place.
There is no new Auth, notification, storage or product system.

| Existing surface / data path | Backend dependency | J1 evidence |
|---|---|---|
| Login / role / onboarding / shop form | Shared Auth, `profiles`, `shops`, one owner index | Real password login, authoritative role, shop creation, stale revision and Customer/foreign owner denial |
| Dashboard | Listing counts + `merchant_operations_read_v1` | Available/unavailable/inactive counts, pending submission and photo task lifecycle |
| Product list / catalog / price and stock editor | `products`, `brands`, `shop_products`, owner RLS and immutable identity trigger | Nested DTOs, exact price, boolean availability, duplicate insertion, stale overwrite and fresh login |
| New product request / status | Catalog categories/lookup/submit RPCs, `product_submissions` | Explicit request retry produces one pending request; approval remains OFF |
| Listing photos / unfinished uploads | Intent/publish/retire RPCs, private `listing-media`, Storage policies | Real SDK upload, foreign/path/type/size denial, pending task, retirement |
| Existing Customer seller and hero read | `ShopRepositoryImpl`, `SupabaseListingHeroMediaRepository` | Correct listing DTO and signed image bytes; inactive/retired content disappears |
| Merchant QR and matching Customer QR | Existing legacy RPCs and immutable verified purchase tables | Real create/preview/confirm; repeat confirmation rejected; one purchase |
| Existing inbox / settings composition | Existing `notifications` table and shared repository | Own read/count/mark/delete; other account retained; later service bindings stay absent |
| Account recovery / callbacks / physical scanner / push | Existing J0 and later device/provider gates | No new acceptance claim in J1 |

The Flutter test only replaces the service holder with a forwarding facade, so
separate synthetic clients can coexist. All Auth, repository, RPC, DTO, Storage
and Customer media operations use their real implementations and local services.
This is a data-layer journey, not an installed Android/device or UI end-to-end run.

## Exact fixture and manifest

`pilot_contract.mjs` lists thirteen paths explicitly: unchanged Development
0001–0011 + **migration**0016 catalog/listing media +0017 operations. Existing
synthetic historical ledger IDs and safe-category seeding are reused from the
acceptance harness; they are not an assertion about hosted migration history.
No new migration/proposal is required by these findings.

The separately gated **proposal**0016 engagement foundation and0029 dispatch are
absent. Production0012/0013, special publication executor0014 and0015 must never be
inferred from directory numbering or this Development list. Claims0018+ and other
later capabilities are absent from this minimal fixture. Their previous local
acceptance and frozen rules remain valid; the final pilot feature set is undecided.

- [Exact contract](data/merchant_pilot_backend_contract.json): signatures,
  effective caller grants, function hashes, RLS, policy hashes, private bucket
  limits, OFF catalog-decision config and full metadata component fingerprints.
- [Real core acceptance](data/merchant_pilot_backend_acceptance.json): migration
  bytes, LF-normalized application/tool source hashes, service image identities,
  loopback bindings and dated behavioral evidence. Migration hashes deliberately
  retain the exact executed SQL bytes. Cross-platform source verification uses
  UTF-8 with CRLF converted to LF before SHA-256 (`sha256_lf`).
- [Unchanged A+B route](data/merchant_pilot_ab_compatibility.json): separate fresh
  stack proving the default `migrate()` behavior still supports the original suite.
  Earlier A/B handoff evidence was preserved rather than overwritten.

Read-only inspection captures no account/content rows. It runs in a read-only
transaction. Ten deliberate database changes run inside rollback-only local
transactions, each followed by exact original fingerprint verification. Storage
RLS-disabled rejection is a separately labeled snapshot mutation: managed Storage
table ownership forbids disabling it as the normal local postgres role. We did
not take ownership or weaken that protection to manufacture a database test.
The local fingerprint is a review baseline, not a remote scanner or automatic
compatibility verdict for an extended schema or different managed service version.

## Validation

- **20 local server/runner groups PASS**, including ten actual rollback mutation
  groups and the separately labeled Storage RLS snapshot check.
- The above twenty include **one real Flutter journey with 18 named checkpoints**.
  Do not add 18 to 20 as independent test cases. Those checkpoints cover the table
  above, use real Auth/PostgREST/Storage, and leave gates/schema unchanged.
- **923 adjacent Flutter tests PASS**, plus the one explicit live repository test.
  Merchant unit/widget, notifications, cart and shop suites were selected.
- **8 Node safety/manifest tests PASS** (6 existing +2 added).
- **21 existing A+B managed groups PASS** on another fresh stack, including real
  independent-connection contention and server-session revocation cases.
- `flutter analyze --no-pub`: **PASS**, no issues. Diff/secret/source-hash checks
  are required before delivery. No new APK or full-suite rerun is necessary for
  this tooling-only change; J0 artifacts and prior full-suite proof are unchanged.

Initial harness development exposed two incorrect test assumptions, both resolved
before the final fresh run: legacy v1 repeat confirmation rejects an already-used
QR (it does not use v2 completion semantics), and managed Storage ownership does
not permit direct RLS disabling. Neither warranted modifying existing business or
security behavior. Final passing evidence does not include those failed attempts.

## Reproduce locally

Use Node22+, the pinned `tool/merchant_acceptance/package-lock.json`, local Docker
and the existing Flutter SDK. Resolve Flutter dependencies before the runner.
The explicit test is outside `test/`, so normal Flutter tests never connect.

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs tool/merchant_acceptance/pilot_contract.test.mjs
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-owned-run>
node tool/merchant_acceptance/pilot.mjs <same-owned-run> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-owned-run>
```

The runner refuses non-owned/occupied/populated fixtures through the existing
safety checks, never accepts a hosted URL, bypasses proxies and never follows HTTP
redirects. It passes synthetic client credentials through one ignored run file,
with no service-role key, and removes it in `finally`. A nonce binds the Flutter
receipt to that run. Failed runs do not overwrite dated passing evidence; inspect
the current exit status and hashes rather than treating an old file as fresh proof.
Private failure logs must not be committed. Stop only the exact owned stack and
retain its data; no reset, volume deletion, global prune or remote fallback.

Docker's default address pool filled during this task. After examining host routes
and existing networks, two failed-attempt fixtures used private task-labeled
bridges. All this task's stacks were stopped and its empty bridges removed after
validation, while local volumes/logs were retained. Other tasks were untouched.

For the independent A+B regression, use `acceptance.mjs <another-fresh-owned-run>`
with the same prepare/start/stop sequence. Its enabling of claims in that isolated
test is not pilot capability activation. See the harness README for details.

## Integration, rollback and remaining gates

Only the Integration Agent merges to main. Shared conflict areas are the two
canonical/slice documents and `tool/merchant_acceptance/fixture.mjs`; runtime,
global state, dependency files and historical migrations are unchanged. Removing
this task's tools/docs reverses this delivery; no remote schema rollback is needed.

The next useful step is an **explicitly authorized, read-only review of the named
nonproduction backend**, comparing actual migration history, grants, Storage,
taxonomy and selected Customer/Merchant versions. Prepare a reviewed exact delta
from that evidence; generic `db push` is not authorized. Remote apply/provisioning
requires its own explicit authority, even when the target is nonproduction.

Before cohort distribution, three critical gates remain:

1. Authorized backend/configuration and real account/shop setup, including exact
   Auth redirect and real password-reset mail acceptance.
2. Exact signed artifacts on actual Customer + Merchant devices: camera/manual QR,
   cold/warm recovery and account isolation. Physical QR acceptance stays OPEN.
3. Final feature selection, operator pause/support readiness and Product Owner
   release approval. Realtime/device push/provider delivery remain unverified here.

Production access/writes: **NONE**. Remote migration apply: **NO**. Local unchanged
SQL rehearsal: **YES**. Provider configured/sent: **NO**. Main merge/push: **NO**.
