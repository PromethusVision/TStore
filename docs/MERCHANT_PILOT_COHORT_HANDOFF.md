# Merchant pilot — category, catalog and account preparation, J6

17 October 2026. **LOCAL PREPARATION PASS; no remote access or writes.**
Base main: `8031bad31a0d8e8fae5cb9bc0b37e5c8a6a6b01b` (integrated J5).
Branch: `agent/merchant-pilot-cohort-preparation`.

The owner requested a comprehensive next preparation package, prohibited
Production access and required approval before test-server changes. The owner
also confirmed that real participants/products are not yet selected and asked
for preparation and local rehearsal. No real identities, products or category
decisions were invented. Main merge remains Integration Agent's responsibility.

## Delivered architecture

The existing modular application, shared catalog/listings, Auth/profile roles,
taxonomy, notifications and five Merchant tabs remain unchanged. There is no new
runtime service, dependency, migration, public endpoint, Admin UI or Customer UI.

- `pilot_cohort_contract.mjs` validates exact intake and a minimized read-only
  observation. It builds separate B category and D existing-account role review
  candidates, and evaluates catalog matching without creating products.
- `prepare_pilot_cohort.mjs` generates an offline hashed review bundle, bound to
  the current successful local proof and 38 source files. It accepts no connection,
  token or apply flag. All output is under ignored task scratch with no overwrite
  or redirected output. Actual account IDs must stay out of Git.
- `pilot_cohort.mjs` recreates the installed post-C/E structure on a new owned
  loopback stack. It tests real Auth/PostgREST/Storage and reuses the existing
  actual Flutter repository journey. Synthetic fixture values never become a
  suggested real catalog, participant list or category selection.

The default generated bundle contains intake, category inventory, read-only
observation SQL, readiness and manifest files. It contains **no mutation SQL**,
Auth account creation, catalog seed, email action or replay of installed A/C/E.
Current missing facts remain explicit; `distribution_ready` stays false.

## B — exact category proposal

Only explicit leaf UUIDs and necessary ancestors may be proposed. Existing
NORMAL/not_required eligibility is preserved; no policy or professional-review
override, global activation or sector exclusion is added. The proposal binds
the full post-C/E schema, taxonomy and catalog row hashes. It lists existing
active products that activation could expose, so category approval is not
presented as a harmless visual-only change.

The candidate uses a distinct review token, transaction/advisory/table locks and
bounded timeouts. Unknown schema, taxonomy or catalog changes refuse execution;
unselected nodes and all review metadata are checked after the update. Failed
operations roll back; an old plan cannot replay against activated ancestry.

This tool targets the first activation from the captured staged taxonomy.
Existing active ancestry needs a new reviewed baseline/workflow; the tool does
not silently extend a completed initial plan to later cohorts.

## D — identities and roles

Accounts are not created by SQL or with invented passwords. A real participant
must use the secure signup interface or a separately approved admin flow. No
invite, confirmation override, password reset or email send is implemented here.

Role preparation requires paired merchant/customer slots, explicit existing Auth
UUIDs, an independent identity-review reference and a fresh observation containing
exactly those accounts. It checks profile/Auth association, confirmed email,
matching email, account status and existing shop authority. Passwords, tokens,
names, email addresses and private contact fields are not intake fields.

The only proposed role mutation is an individually reviewed customer → merchant
change for an existing identity without a shop. Existing admins, owned shops,
unconfirmed/banned/deleted/anonymous accounts and conflicting customer selections
remain separate review cases. No admin promotion, automatic demotion or shop
creation/transfer is generated. Already-merchant identities without a shop need
no role write. Real onboarding remains the authenticated owner's existing flow.

The role transaction locks selected Auth/profile rows and shop ownership,
rechecks the exact snapshot, changes only selected roles and checks all other
profile fields. Token, account, schema, authority or concurrent-writer drift
fails closed. Review references and tokens are not human authorization or server
identity; explicit owner approval and independent target checks remain mandatory.

## Catalog audit and unresolved publication contract

The installed catalog is still empty according to the J5 hosted receipt. J6 did
not make a fresh hosted observation. Category activation alone cannot make a real
product appear. The existing `merchant_submit_product_v1` creates pending
submissions; `decide_catalog_submission_v1` is OFF and only approves an already
legitimately materialized product (migration0016, around line218).

Migration0001 requires `products.price`; the legacy Customer horizontal card
still renders `product.price` (`lib/core/common/widgets/horizontal_product_card.dart`,
around line145). Canonical §4 explicitly requires an approved compatibility
contract rather than an arbitrary central price. Therefore this preparation
does **not** set a fake zero/reference price, activate decisions or silently
materialize new products. This is a remaining implementation gate, not a claim
that catalog population is finished.

The completed catalog reviewer validates physical-product evidence, exact leaf
selection, supported/checksummed GTIN, normalized identity and explicit existing
product selection. An exact GTIN gives a suggestion, not automatic consent.
Inactive/mismatched or merchant-unique identities are not treated as freely shared.
Conflicting duplicate GTINs and duplicate listings for one merchant need review;
different merchants may select the same consistent shared product. Text similarity
is advisory. Human evidence review remains necessary to detect mislabeled content.
Services, appointments and service pricing remain outside the current contract.

**Recommended next engineering package:** define and rehearse the controlled
new-product materialization and legacy-price/read contract before proposing a
real catalog write. Reuse submissions/identity/GTIN/category contracts, preserve
merchant listing price authority and Customer layouts, prove publication and
listing atomicity/replay/conflict/rollback behavior, then present explicit product
rows and the activation scope for approval. Do not solve this with direct ad hoc
INSERTs, a blanket decision switch or a new parallel product catalog.

## Validation

- **70 Node tests PASS:** existing46 plus18 cohort contract and6 offline bundle
  checks. Private/unknown fields, path escapes, overwrite, incomplete or stale
  proof, wrong target, malformed identities, missing observation and unintended
  mutation generation are rejected.
- **20 managed local groups PASS:** exact installed structure; empty-catalog gate;
  identity matching/shared reuse; wrong/old/cross-item token; schema drift; Auth,
  role and ownership drift; taxonomy/catalog drift; concurrent writer; late-error
  rollback; bounded activation; category replay; exact role update; role replay;
  client privilege escalation; onboarding; owner isolation; GTIN uniqueness;
  real repository journey; disabled decisions; preserved schema/catalog boundary.
- **18 nested actual Flutter repository checkpoints PASS** in one integration
  test: onboarding, access, listing/price/availability, media, Customer reads,
  submissions, notifications and synthetic legacy QR purchase. These do not prove
  physical two-device, camera, real email or provider delivery.
- Node syntax checks and diff/secret checks pass. Flutter runtime/test sources
  are unchanged; full analyzer, full Flutter suite and APK builds were not rerun.
  No application UI/rendering change was made.

Two fresh local rehearsals passed. Final source-bound evidence is
[merchant_pilot_cohort_acceptance.json](data/merchant_pilot_cohort_acceptance.json).
The second stack initially could not start after the Docker network pool filled;
only this task's first stopped, label-verified empty network was removed. Startup
then succeeded. Both stacks were stopped; fixture data retained. No foreign
Docker resources were removed and no hosted fallback was attempted.

## Reproduction and operational handoff

Run Node safety tests while the owned API port is free:

```powershell
node --test tool/merchant_acceptance/safety.test.mjs tool/merchant_acceptance/docker-proxy.test.mjs tool/merchant_acceptance/pilot_contract.test.mjs tool/merchant_acceptance/pilot_preparation.test.mjs tool/merchant_acceptance/prepare_pilot.test.mjs tool/merchant_acceptance/pilot_launch.test.mjs tool/merchant_acceptance/prepare_pilot_launch.test.mjs tool/merchant_acceptance/pilot_cohort.test.mjs tool/merchant_acceptance/prepare_pilot_cohort.test.mjs
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <new-owned-run>
node tool/merchant_acceptance/pilot_cohort.mjs <same-run> <Flutter-SDK-directory>
node tool/merchant_acceptance/local.mjs stop <same-run>
node tool/merchant_acceptance/prepare_pilot_cohort.mjs <new-output-name>
```

Optional private input is `.buildlog/pilot-cohort-input/<name>.json`; optional
read-only output is `<name>.observation.json` in that same directory. The CLI takes
only the plain name as its second argument. Parse the returned `observation_text`
JSON from the generated read-only query. Never commit those actual account IDs.
Only a current, complete observation can produce exact separate B/role-D review
candidates; they still contain no approval token assignment and never apply.

Bounds of50 selected leaves,20 account slots,100 product drafts and500 observed
catalog rows limit this preparation tool. They are not new product/business caps.
A supplied observation is not guaranteed fresh: recheck the target and exact
preconditions immediately before any separately authorized action.

Current review bundle: `.buildlog/pilot-cohort-review/esenler-first-cohort-review`.
No exact real B/D write is ready for approval until participants/products and
their observations exist. [Turkish intake guide](MERCHANT_PILOT_INTAKE_GUIDE.md)
explains the necessary facts without requesting secrets. Production, new catalog
publication, mail/device/provider acceptance, signed distribution and final pilot
opening remain gated. Integration merges source/evidence only, never activates B/D.
