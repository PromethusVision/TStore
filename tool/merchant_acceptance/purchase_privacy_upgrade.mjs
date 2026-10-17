import assert from 'node:assert/strict';
import { readFile, writeFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { createHash } from 'node:crypto';
import { readRun, credentials, root } from './local.mjs';
import { localUrl } from './safety.mjs';
import { connect } from './fixture.mjs';
import { purchaseProjectionChecks } from './purchase_projection_checks.mjs';

// Explicitly authorized local upgrade rehearsal for an existing owned fixture.
// Never use a supplied connection string, remote host, or unknown data directory.
export async function rehearsePurchasePrivacyUpgrade(db) {
  assert.equal((await db.query("SELECT count(*)::int n FROM supabase_migrations.schema_migrations WHERE name LIKE '0025_%'")).rows[0].n, 1);
  const payloads = async () => (await db.query('SELECT id,public._purchase_read_b(id) p FROM public.verified_transactions ORDER BY id')).rows;
  const tables = ['verified_transactions','verified_transaction_items','purchase_terms','purchase_returns',
    'purchase_return_items','ledger_journals','ledger_postings'];
  const snapshot = async () => {
    const out = {};
    for (const table of tables) {
      const rows = (await db.query('SELECT to_jsonb(t) v FROM public.'+table+' t ORDER BY to_jsonb(t)::text')).rows;
      out[table] = {rows: rows.length, sha256:createHash('sha256').update(JSON.stringify(rows)).digest('hex')};
    }
    return out;
  };
  const before = await payloads(), original = await snapshot();
  assert(before.length > 0);
  assert(before.every(r => 'customer_user_id' in r.p && 'confirmed_by_user_id' in r.p),
    'Expected the documented pre-0030 projection; do not adopt unknown fixtures');
  const file = '20261017003000_0030_purchase_evidence_privacy.sql';
  const sql = await readFile(resolve(root,'supabase/migrations',file),'utf8');
  await db.query(sql);
  await db.query('INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES($1,$2,$3)',
    [file.split('_')[0],file.slice(15,-4),[]]);
  const after = await payloads();
  assert.equal(after.length,before.length);
  for (let i=0;i<before.length;i++) {
    const expected = {...before[i].p};
    delete expected.customer_user_id; delete expected.confirmed_by_user_id;
    assert.equal(after[i].id,before[i].id); assert.deepEqual(after[i].p,expected);
  }
  assert.deepEqual(await snapshot(),original);
  const checks = await purchaseProjectionChecks(db);
  const evidence = {result:'PASS',captured_at:new Date().toISOString(),
    evidence_class:'owned-local-populated-postgresql-upgrade',baseline_identifiers_reproduced:true,
    purchase_payloads_compared:before.length,only_removed_fields:['customer_user_id','confirmed_by_user_id'],
    immutable_tables_unchanged:original,migration:{file,sha256:createHash('sha256').update(sql).digest('hex')},
    checks,remote_access:'NONE',physical_two_device:'OPEN'};
  await writeFile(resolve(root,'docs/data/merchant_purchase_privacy_upgrade.json'),JSON.stringify(evidence,null,2)+'\n');
  console.log('LOCAL_PURCHASE_PRIVACY_UPGRADE_PASS: '+before.length+' purchase payloads; only two fields removed.');
  return evidence;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  let db;
  try {
    const run = await readRun(process.argv[2]);
    const status = await credentials(run);
    const url = localUrl(status.DB_URL, 'db');
    db = await connect({host:'127.0.0.1',port:Number(url.port),database:'postgres',
      user:'postgres',password:decodeURIComponent(url.password),ssl:false});
    await rehearsePurchasePrivacyUpgrade(db);
  } catch (error) {
    console.error('LOCAL_PURCHASE_PRIVACY_UPGRADE_FAILED: '+(error.code || error.name));
    // Never print transport credentials or raw payloads.
    process.exitCode = 1;
  } finally { if(db) await db.end(); }
}
