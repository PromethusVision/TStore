# D+F — Merchant trust and Campaign Lite

Baseline: integrated C, `d013b761`. Task branch:
`agent/merchant-trust-campaigns-df`. Integration belongs to the Integration Agent.
This is a local implementation and acceptance delivery, not a Production release.

## What ships

Merchant trust summary, exact badge eligibility/progress, persistent explanations,
award/correction history, and Customer purchase/review milestones. Merchant
campaign list/create/edit/product-image selection/preview/publish/pause with
announcement, price and percentage types. The Customer profile/shop receive small
shared additions; accepted layouts and Merchant five-tab navigation remain intact.

No reward/coupon economics, Ads, new push architecture, provider setup or new QR
system. B's quote-only purchase and cart/listing prices are unchanged.

## Schema and activation boundaries

Apply only in dependency order after the appropriate existing environment chain:
`0016 → 0017 → 0018 → 0019 → 0020_trust_badges → 0021_merchant_campaign_lite
→ 0022_campaign_required_amount`.
The shared migrations are additive. Historical migrations were not edited.
The local harness's Development taxonomy fixture is not a Production migration
sequence; never replay its 0010/0011 bootstrap over Production's 0012/0013/0015.

All flags default OFF. Client entrypoints use `TRUST_COMMERCE_V1_ENABLED`.
Server D requires both badge enablement and C lifecycle readiness. C's negotiated
client path uses `REVIEWS_V2_ENABLED`; do not advertise D readiness with C disabled.
Server F has a separate enablement flag and a separately OFF monetary-publication
flag. Price/percentage drafts and preview work before that publication flag opens.

Remote authorization is still required for schema application, flags, official
geography import/assignment approval, worker deployment and backfill scheduling.
Actual-sale/offer reconciliation must be reviewed before monetary publication.
Privacy/retention, lawful offer copy, real Firebase/APNs and physical two-device QR
acceptance remain separate release gates. Local geography fixtures are synthetic.

## Worker and backfill

`process_badge_refresh_v1(100)` is trusted-operator-only, not a mobile/service-role
RPC. Run bounded batches every minute, even without a purchase or screen read.
Due rolling-window projections and queued events share this worker; live reads
derive current eligibility immediately. A paused worker cannot grant grace.

After an approved first enablement, keyset-page through
`enqueue_badge_backfill_v1(after_uuid, 200)` until `next_after` is null, and drain
the worker in bounded batches. Do not install an unbounded startup backfill or
run it synchronously from mobile requests. Monitor backlog, worker failures and
time since last successful tick; data/retention policy is a release input.

The repository provides a loopback-only operator runner:

```text
node tool/merchant_acceptance/badge_worker.mjs <owned-local-run> --once
node tool/merchant_acceptance/badge_worker.mjs <owned-local-run> --watch
```

It accepts only the acceptance harness's owned local stack and checks its runtime
and port bindings. No remote-host override or credentials are embedded. Stopping
the worker or turning flags OFF preserves immutable history; it is not a schema
rollback or a reason to delete evidence.

## Reproduce acceptance

```text
cd tool/merchant_acceptance
npm ci --ignore-scripts --no-audit --no-fund
cd ../..
node tool/merchant_acceptance/native.mjs <portable-PostgreSQL-17-bin> --trust-campaigns
node tool/merchant_acceptance/local.mjs prepare
node tool/merchant_acceptance/local.mjs start <printed-owned-run>
node tool/merchant_acceptance/acceptance.mjs <same-owned-run> --trust-campaigns
node tool/merchant_acceptance/badge_worker.mjs <same-owned-run> --once
node tool/merchant_acceptance/local.mjs stop <same-owned-run>
flutter analyze --no-pub
flutter test --no-pub
```

The native D/F run also executes C's 17 real SQL regression groups with the new
event triggers installed. Native Auth/Storage schema stand-ins are never reported
as real managed-service proof. Managed acceptance uses actual local Auth sessions,
JWT/HTTP authorization, Storage uploads/signing/bytes and independent DB sessions.
Prepared runs are single use; retain failed runs and create a new owned fixture.
Do not reset, prune or remove unrelated Docker data.

Sanitized results with exact migration SHA256s:
[native](data/merchant_df_native_acceptance.json) and
[managed](data/merchant_df_managed_acceptance.json).
Visual fixtures cover 320px/1.3 text scale and 390px/1.0: trust, campaign list,
editor and Customer offers. `main_trust_commerce_preview.dart` is an explicit
memory-only sample-data host; never treat that preview as backend/device proof.

## Verified delivery — 2026-10-15

- Full Flutter regression: **2,400 passed, six opt-in live tests skipped**.
  New coverage includes six repository tests and nine widget cases, with eight
  golden images at the two sizes above. Existing migration contracts also pass.
- `flutter analyze --no-pub`: **no issues**. The explicit local preview web build
  passes. Browser checks cover dashboard, trust details/explanations, campaigns,
  editor/preview and Customer offers; the final browser console has no warnings
  or errors. These checks do not replace physical mobile acceptance.
- Native PostgreSQL: **33 passing scenario groups**, including C's 17 regression
  groups and D/F's 16 groups. Real local managed services: **25 passing groups**,
  including JWT authorization, Storage bytes and concurrent database sessions.
- Both sanitized reports match all **18 migration SHA256s** in their tested
  dependency chain. Historical migration files remain unchanged.
- The initial D/F owned local badge worker's once-run passed (seven targets processed,
  no additional transitions). All task-owned database stacks were stopped with
  their data retained; the temporary browser and preview server were closed.
- Before commit, `origin/main` still resolves to baseline `d013b761`; no main
  merge or remote database operation was performed.

## Integration review focus

Integration rejected `ea799206` because SQL CHECK treats UNKNOWN as accepted:
0021's type-specific amount constraint admitted a missing or JSON-null required
price/percentage. The prior 32/23 acceptance groups omitted this negative case;
their passing result did not prove this invariant. Integrate the corrected branch
tip, including 0022; `ea799206` alone remains unsuitable for integration.

0022 adds a validated, named CHECK with explicit non-null requirements and an
`IS TRUE` boundary. No previous migration bytes or immutable revisions changed.
The existing mutation exception handler returns `CAMPAIGN_INVALID_ARGUMENT`
and atomically rolls back campaign/revision/receipt writes. If an environment
already contains a malformed revision, migration validation fails atomically;
stop and review that history rather than inventing an amount or deleting it.

The new regression was first run against 0021 and failed with “Missing expected
rejection” for a price draft without `price_minor`. With 0022, both SQL and real
HTTP paths reject all 26 malformed amount shapes on create and edit (52 rejected
commands per path), preserve state, and accept six valid shapes/boundaries.
Direct privileged inserts also reject NULL required amounts. Corrected retries
and successful exact replays are covered. The sanitized reports above supersede
the initial acceptance reports. No UI code changed for this correction.

Correction verification also reran the full Flutter suite (**2,400 PASS / six
existing SKIP**) and analyzer (**no issues**). Both real application entrypoints
compile for web: `lib/main_development.dart` and
`lib/main_merchant_development.dart`, with `TRUST_COMMERCE_V1_ENABLED=true` and
`REVIEWS_V2_ENABLED=true`. These were compilation-only local outputs, with no
remote credentials, execution, feature activation or deployment.

Shared touchpoints: service locator registration behind an OFF flag, optional
MerchantServices port, dashboard sections, Customer profile/shop extensions,
append-only migration chain and migration inventory test. No routing replacement,
dependency/lockfile change or notification bootstrap mutation.

Review canonical §7.1–7.2 before rollout. Locally validated gates do not imply main
merge authorization or remote feature activation. The only remaining physical
acceptance is the already separate device/provider/QR release phase.
