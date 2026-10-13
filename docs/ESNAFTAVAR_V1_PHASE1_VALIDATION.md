# Phase 1 — validation and handoff

Status: local architecture/proposal validation; no runtime feature implemented.
Base: `33d0078380feebe1ca6051b72a37e3b536536ff9`.
Branch: `agent/trust-commerce-architecture`.

## Validation results

- New SQL proposal: **34 PASS**, **43 proposed tables**, in-memory PGlite 0.5.5.
- Existing proposal 0016: **28 PASS** schema/RLS checks, separate in-memory database.
- Existing shared push dispatcher: **20 PASS** mock-provider tests; no sends.
- `flutter analyze --no-pub`: **No issues found**.
- Full Flutter regression: **2282 PASS / 0 FAIL / existing 6 conditional skips**.
- Build: **NOT RUN — documentation/proposal-only diff; no application source or asset change**.
- Production/Development backend access: **NONE**. Writes: **NONE**.
- Migration applied: **NO**. Only isolated, in-memory design DDL was rehearsed.

PGlite reports PostgreSQL18.3/Wasm. This tests DDL shape, uniqueness, ownership
link constraints, append-only guards and default-deny privileges; it is not a
Production17.6 compatibility rehearsal or proof that future reward/RPC/Ads/badge
algorithms work. Those algorithms, economic balancing, aggregate return limits,
policy durations, rate limits and authorization RPCs are intentionally not
implemented in this phase. Slice-level PostgreSQL/environment compatibility,
RLS projections, business invariants and physical acceptance remain required.

The prototype's43 tables are candidate shapes across11 implementation slices,
not43 production migrations or an activated subsystem. Existing public tables
and rows were unchanged in the local fixture. All proposed tables use forced
RLS; no client or service-role grants/policies/operational RPC were added.

## Changes allowed for this task

- Canonical architecture/specification and dependency-ordered implementation plan.
- Local SQL prototype outside automatic migrations, with PGlite-only opt-in guard.
- Validation notes/reproducible local rehearsal below.
- **No Dart interface needed or added; no Flutter/UI/domain implementation changed.**

Existing applied migrations, dedicated0014 publication executor, proposal0016,
Customer/Merchant sources, pubspec/lockfile and app release identities remain
unchanged. Generated plugin files from local pub setup are normalized back to the
clean baseline before delivery. No main merge or remote deployment is authorized.

## Reproduce local validation

From the task checkout root, prepare the isolated test dependency (no app dependency):

```text
npm install --ignore-scripts --no-audit --no-fund --prefix .buildlog/phase1-sql @electric-sql/pglite@0.5.5
```

Save the following fenced JavaScript as `.buildlog/phase1-proposal-validation.mjs`,
then run the commands below. Its synthetic fixture is deliberately minimal, uses
memory-only PGlite, imports no remote driver and cannot connect to Supabase.

```text
node .buildlog/phase1-proposal-validation.mjs
node --test tool/engagement/push_delivery.test.mjs
node tool/engagement/schema.test.mjs .buildlog/phase1-sql/node_modules/@electric-sql/pglite
flutter analyze --no-pub
flutter test --no-pub --reporter expanded
```

Do not execute the proposal against a real database or modify its guard to do so.
Do not use generic Supabase db push. Author future migrations separately per slice.

## Rehearsal source

```javascript
// Test-only, ignored scratch artifact. In-memory PGlite; no remote driver/config.
import { PGlite } from './phase1-sql/node_modules/@electric-sql/pglite/dist/index.js';
import { readFile, writeFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
const sql = await readFile(new URL('../supabase/proposals/trust_commerce_phase1_v1.sql', import.meta.url), 'utf8');
const db = new PGlite();
let passed = 0;
const checks = [];
const uid = n => `00000000-0000-4000-8000-${String(n).padStart(12,'0')}`;
async function check(name, fn) { await fn(); checks.push(name); passed++; }
async function deny(statement, code) {
  await db.exec('BEGIN');
  try {
    await assert.rejects(db.exec(statement), error => !code || error.code === code);
  } finally { await db.exec('ROLLBACK'); }
}
await db.exec(`
CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;
CREATE TABLE public.products(id uuid PRIMARY KEY, marker text);
CREATE TABLE public.shop_products(id uuid PRIMARY KEY);
CREATE TABLE public.verified_transactions(id uuid PRIMARY KEY);
CREATE TABLE public.verified_transaction_items(id uuid PRIMARY KEY);
INSERT INTO public.products VALUES ('${uid(1)}','unchanged'),('${uid(2)}','unchanged');
INSERT INTO public.shop_products VALUES ('${uid(3)}');
INSERT INTO public.verified_transactions VALUES ('${uid(4)}'),('${uid(5)}'),('${uid(6)}');
INSERT INTO public.verified_transaction_items VALUES ('${uid(7)}'),('${uid(8)}'),('${uid(9)}');
`);
const baselineTables = (await db.query("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename")).rows;
await check('proposal fails without local opt-in and leaves no schema', async () => {
  await assert.rejects(db.exec(sql), e => e.code === '42501');
  await db.exec('ROLLBACK');
  assert.equal((await db.query("SELECT to_regnamespace('phase1_design') AS s")).rows[0].s, null);
});
await db.exec("SET esnaftavar.phase1.local_rehearsal='local_rehearsal_only'");
await check('entire proposed DDL parses and commits locally', () => db.exec(sql));
await check('existing public table list and rows unchanged', async () => {
  assert.deepEqual((await db.query("SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename")).rows, baselineTables);
  assert.deepEqual((await db.query('SELECT marker FROM public.products')).rows.map(r => r.marker), ['unchanged','unchanged']);
});
await check('every proposed table has forced RLS', async () => {
  const rows = (await db.query("SELECT relname,relrowsecurity,relforcerowsecurity FROM pg_class WHERE relnamespace='phase1_design'::regnamespace AND relkind='r'")).rows;
  assert.ok(rows.length > 30);
  assert.ok(rows.every(r => r.relrowsecurity && r.relforcerowsecurity));
});
await check('no application/service role gets schema/table privileges', async () => {
  for (const role of ['anon','authenticated','service_role']) {
    assert.equal((await db.query(`SELECT has_schema_privilege('${role}','phase1_design','USAGE') AS allowed`)).rows[0].allowed, false);
    assert.equal((await db.query(`SELECT has_table_privilege('${role}','phase1_design.ledger_postings','INSERT') AS allowed`)).rows[0].allowed, false);
  }
});
await check('default-deny RLS remains effective even if test temporarily grants access', async () => {
  await db.exec('BEGIN');
  try {
    await db.exec('GRANT USAGE ON SCHEMA phase1_design TO authenticated; GRANT SELECT,INSERT ON phase1_design.product_submissions TO authenticated; SET LOCAL ROLE authenticated');
    assert.equal((await db.query('SELECT count(*)::integer AS n FROM phase1_design.product_submissions')).rows[0].n, 0);
    await assert.rejects(db.exec(`INSERT INTO phase1_design.product_submissions(shop_id,submitted_by,identity_payload,intended_type,request_key) VALUES('${uid(10)}','${uid(11)}','{}','shared_catalog_product','deny')`), e => e.code === '42501');
  } finally { await db.exec('ROLLBACK'); }
});
await db.exec(`INSERT INTO phase1_design.policy_versions(id,policy_key,version,rules,rules_hash,effective_at)
VALUES('${uid(12)}','test-policy',1,'{}','test-only','2026-10-13T00:00:00Z')`);
await check('published policy is immutable, including owner update/delete', async () => {
  await deny("UPDATE phase1_design.policy_versions SET version=2", '55000');
  await deny("DELETE FROM phase1_design.policy_versions", '55000');
});
await db.exec(`INSERT INTO phase1_design.commerce_events(aggregate_kind,aggregate_id,event_kind,source_key,schema_version,payload)
VALUES('purchase','${uid(4)}','verified_purchase','event-1',1,'{}')`);
await check('event source idempotency prevents duplicates', () =>
  deny(`INSERT INTO phase1_design.commerce_events(aggregate_kind,aggregate_id,event_kind,source_key,schema_version,payload) VALUES('purchase','${uid(4)}','verified_purchase','event-1',1,'{}')`, '23505'));
await check('commerce event update/delete cannot overwrite history', async () => {
  await deny("UPDATE phase1_design.commerce_events SET payload='{}'", '55000');
  await deny('DELETE FROM phase1_design.commerce_events', '55000');
});
await db.exec(`INSERT INTO phase1_design.product_identifiers(product_id,scheme,normalized_value,validated_at) VALUES('${uid(1)}','gtin','00000000000001',now())`);
await check('same normalized GTIN cannot identify two products', () =>
  deny(`INSERT INTO phase1_design.product_identifiers(product_id,scheme,normalized_value,validated_at) VALUES('${uid(2)}','gtin','00000000000001',now())`, '23505'));
await check('merchant-unique type requires an origin shop', () =>
  deny(`INSERT INTO phase1_design.product_identity_meta(product_id,product_type,normalized_name,normalization_version) VALUES('${uid(1)}','merchant_unique_product','sample',1)`, '23514'));
await db.exec(`INSERT INTO phase1_design.listing_images(listing_id,bucket_id,object_key,sort_order,is_primary,publication_state,uploaded_by) VALUES('${uid(3)}','test-bucket','owned/a',0,true,'published','${uid(11)}')`);
await check('one primary published image per listing', () =>
  deny(`INSERT INTO phase1_design.listing_images(listing_id,bucket_id,object_key,sort_order,is_primary,publication_state,uploaded_by) VALUES('${uid(3)}','test-bucket','owned/b',1,true,'published','${uid(11)}')`, '23505'));
await check('unit pack quantity must be positive', () =>
  deny(`INSERT INTO phase1_design.listing_unit_metadata VALUES('${uid(3)}','pack',0,NULL,now())`, '23514'));
const terms = (purchase, sale, coupon) => `INSERT INTO phase1_design.purchase_terms(purchase_id,final_sale_minor,ev_coupon_minor,voluntary_return_seconds,policy_version_id,allocation_snapshot,finalizing_user_id,finalizing_auth_session_id,finalizing_installation_id,claim_id) VALUES('${uid(purchase)}',${sale},${coupon},86400,'${uid(12)}','{}','${uid(11)}','${uid(13)}','${uid(14)}','${uid(15)}')`;
await db.exec(terms(4,75000,25000));
await check('net customer payment excludes EsnaftaVar coupon exactly', async () => {
  assert.equal(Number((await db.query("SELECT customer_payment_minor FROM phase1_design.purchase_terms")).rows[0].customer_payment_minor), 50000);
});
await check('coupon cannot exceed final sale', () => deny(terms(5,50000,60000), '23514'));
await check('purchase terms never update in place', () => deny('UPDATE phase1_design.purchase_terms SET final_sale_minor=1', '55000'));
await db.exec(`INSERT INTO phase1_design.qr_claims(id,qr_session_id,shop_id,merchant_user_id,auth_session_id,installation_id,claimed_at,completion_expires_at,request_key) VALUES('${uid(15)}','${uid(16)}','${uid(10)}','${uid(11)}','${uid(13)}','${uid(14)}',now(),now()+interval '10 minutes','claim-1')`);
await check('one claim per existing QR source', () =>
  deny(`INSERT INTO phase1_design.qr_claims(qr_session_id,shop_id,merchant_user_id,auth_session_id,installation_id,claimed_at,completion_expires_at,request_key) VALUES('${uid(16)}','${uid(10)}','${uid(11)}','${uid(13)}','${uid(14)}',now(),now()+interval '10 minutes','claim-2')`, '23505'));
await check('manual alias has no plaintext code field', async () => {
  const cols = (await db.query("SELECT column_name FROM information_schema.columns WHERE table_schema='phase1_design' AND table_name='qr_manual_aliases'")).rows.map(r => r.column_name);
  assert.ok(cols.includes('code_digest')); assert.ok(!cols.includes('code'));
});
await db.exec(`INSERT INTO phase1_design.review_entitlements(id,purchase_id,evidence_item_id,customer_user_id,product_id,shop_id) VALUES('${uid(17)}','${uid(4)}','${uid(7)}','${uid(11)}','${uid(1)}','${uid(10)}')`);
await check('one entitlement per distinct product in purchase', () =>
  deny(`INSERT INTO phase1_design.review_entitlements(purchase_id,evidence_item_id,customer_user_id,product_id,shop_id) VALUES('${uid(4)}','${uid(8)}','${uid(11)}','${uid(1)}','${uid(10)}')`, '23505'));
await db.exec(`INSERT INTO phase1_design.review_lifecycle(review_id,customer_user_id,product_id,visibility,edit_until) VALUES('${uid(18)}','${uid(11)}','${uid(1)}','public',now()+interval '24 hours');
INSERT INTO phase1_design.review_revisions(id,review_id,customer_user_id,product_id,entitlement_id,rating,request_key) VALUES('${uid(19)}','${uid(18)}','${uid(11)}','${uid(1)}','${uid(17)}',5,'review-1')`);
await check('one public root per user/product', () =>
  deny(`INSERT INTO phase1_design.review_lifecycle(review_id,customer_user_id,product_id,visibility,edit_until) VALUES('${uid(20)}','${uid(11)}','${uid(1)}','public',now())`, '23505'));
await check('rating revision cannot bind another customer/product entitlement', () =>
  deny(`INSERT INTO phase1_design.review_revisions(review_id,customer_user_id,product_id,entitlement_id,rating,request_key) VALUES('${uid(18)}','${uid(11)}','${uid(2)}','${uid(17)}',5,'foreign-review')`, '23503'));
await check('review history cannot be erased or edited', async () => {
  await deny('UPDATE phase1_design.review_revisions SET rating=1', '55000');
  await deny('DELETE FROM phase1_design.review_revisions', '55000');
});
const service = (purchase, key, friendliness='5', communication='4', cleanliness='5') =>
  `INSERT INTO phase1_design.service_evaluations(purchase_id,customer_user_id,shop_id,friendliness,communication,cleanliness,request_key) VALUES('${uid(purchase)}','${uid(11)}','${uid(10)}',${friendliness},${communication},${cleanliness},'${key}')`;
await check('all three merchant service criteria are required and 1-5', async () => {
  await deny(service(4,'service-null','5','NULL'), '23502');
  await deny(service(4,'service-invalid','6'), '23514');
});
await db.exec(service(4,'service-1'));
await check('only one merchant service evaluation per purchase', () => deny(service(4,'service-2'), '23505'));
await db.exec(`INSERT INTO phase1_design.merchant_review_replies(review_id,origin_revision_id,replying_shop_id,replying_user_id,reply_text) VALUES('${uid(18)}','${uid(19)}','${uid(10)}','${uid(11)}','sample reply')`);
await check('one merchant reply per stable review root', () =>
  deny(`INSERT INTO phase1_design.merchant_review_replies(review_id,origin_revision_id,replying_shop_id,replying_user_id,reply_text) VALUES('${uid(18)}','${uid(19)}','${uid(10)}','${uid(11)}','another reply')`, '23505'));
await check('moderation requires nonblank reason', () =>
  deny(`INSERT INTO phase1_design.moderation_events(subject_kind,subject_id,action,actor_user_id,reason,request_key) VALUES('review','${uid(18)}','hide','${uid(11)}',' ','moderate-1')`, '23514'));
await db.exec(`INSERT INTO phase1_design.ledger_accounts(id,owner_kind,owner_id,account_code,currency) VALUES('${uid(21)}','platform','${uid(22)}','test','TRY');
INSERT INTO phase1_design.ledger_journals(id,source_kind,source_id,source_class,request_key,policy_version_id) VALUES('${uid(23)}','test','${uid(24)}','package_funding','journal-1','${uid(12)}')`);
await check('zero posting rejected; posted economic row immutable', async () => {
  await deny(`INSERT INTO phase1_design.ledger_postings(journal_id,account_id,amount_minor) VALUES('${uid(23)}','${uid(21)}',0)`, '23514');
  await db.exec(`INSERT INTO phase1_design.ledger_postings(journal_id,account_id,amount_minor) VALUES('${uid(23)}','${uid(21)}',5000)`);
  await deny('UPDATE phase1_design.ledger_postings SET amount_minor=10000','55000');
});
const pkg = (id, shop, state='active') => `INSERT INTO phase1_design.referral_packages(id,shop_id,policy_version_id,slot_count,fund_minor,service_fee_minor,activated_at,expires_at,state,funding_journal_id) VALUES('${uid(id)}','${uid(shop)}','${uid(12)}',100,500000,75000,now(),now()+interval '90 days','${state}','${uid(23)}')`;
await db.exec(pkg(25,10));
await check('one active referral package per shop', () => deny(pkg(26,10),'23505'));
const reservation = (id,state) => `INSERT INTO phase1_design.reward_reservations(id,customer_user_id,cart_id,cart_revision,package_id,checkout_attempt_id,state,reserved_at,expires_at,hold_expires_at,claim_id) VALUES('${uid(id)}','${uid(11)}','${uid(27)}','revision-1','${uid(25)}','${uid(28)}','${state}',now(),now()+interval '30 minutes',now()+interval '10 minutes','${uid(15)}')`;
await db.exec(reservation(29,'reserved'));
await check('reserved and checkout hold share one user capacity constraint', () => deny(reservation(30,'checkout_hold'),'23505'));
await db.exec(`INSERT INTO phase1_design.reward_contributions(id,purchase_id,customer_user_id,package_id,event_kind,amount_minor,policy_version_id,matures_at,source_key) VALUES('${uid(31)}','${uid(4)}','${uid(11)}','${uid(25)}','grant',5000,'${uid(12)}',now()+interval '24 hours','grant-1')`);
await check('one reward grant per purchase and immutable chronology', async () => {
  await deny(`INSERT INTO phase1_design.reward_contributions(purchase_id,customer_user_id,package_id,event_kind,amount_minor,policy_version_id,matures_at,source_key) VALUES('${uid(4)}','${uid(11)}','${uid(25)}','grant',5000,'${uid(12)}',now()+interval '24 hours','grant-2')`, '23505');
  await deny('UPDATE phase1_design.reward_contributions SET package_id=package_id','55000');
});
await check('coupon shape supports no-expiration V1', async () => {
  await db.exec(`INSERT INTO phase1_design.reward_coupon_issues(customer_user_id,allocation_key,face_value_minor,policy_version_id,issued_at,expires_at) VALUES('${uid(11)}','allocation-1',25000,'${uid(12)}',now(),NULL)`);
  assert.equal((await db.query('SELECT expires_at FROM phase1_design.reward_coupon_issues')).rows[0].expires_at, null);
});
await check('marketing campaign cannot reach the same user twice', async () => {
  const insert = `INSERT INTO phase1_design.marketing_recipient_claims(customer_user_id,bucket,campaign_id,state,claimed_at) VALUES('${uid(11)}','platform_general','${uid(32)}','claimed',now())`;
  await db.exec(insert); await deny(insert,'23505');
});
await check('offer types enforce structured price/percentage fields', () =>
  deny(`INSERT INTO phase1_design.merchant_offers(shop_id,title,offer_type,scope,starts_at,ends_at) VALUES('${uid(10)}','sample','percentage','shop',now(),now()+interval '1 day')`,'23514'));
await check('no operational RPC or public/auth/storage alteration introduced', async () => {
  assert.deepEqual((await db.query("SELECT proname FROM pg_proc WHERE pronamespace='phase1_design'::regnamespace")).rows.map(r => r.proname), ['reject_audit_mutation']);
  assert.equal((await db.query("SELECT count(*)::integer AS n FROM pg_policies WHERE schemaname='phase1_design'")).rows[0].n, 0);
});
const tables = (await db.query("SELECT count(*)::integer AS n FROM pg_tables WHERE schemaname='phase1_design'")).rows[0].n;
const result = {status:'PASS', checks:passed, proposed_tables:tables,
  engine:(await db.query('SELECT version() AS version')).rows[0].version,
  production_access:'NONE', remote_access:'NONE', migration_applied:false,
  caveat:'DDL/constraints/default-deny rehearsal only, not implementation of financial/RPC/QR/Ads/badge algorithms.',
  check_names:checks};
await writeFile(new URL('./phase1-proposal-result.json',import.meta.url),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({status:result.status, checks:passed, proposed_tables:tables}));
await db.close();

```

## Remaining handoff gates

Implementation questions O1–O10 are in the canonical specification. Legal/KVKK,
service billing/settlement, area dataset, session provenance and provider inputs
are explicit later rollout gates. No Product Owner answer or external policy is
inferred from these local passes. Every implementation slice must preserve current
behavior until its authorized capability activation.
