import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';

// This is a Development-track LOCAL rehearsal, never a remote apply plan.
// Explicit paths distinguish migration 0016 from the separately gated proposal.
export const coreMigrations = Object.freeze([
  '20260812000100_0001_core_auth_catalog.sql',
  '20260812000200_0002_shops.sql',
  '20260812000300_0003_carts_v2.sql',
  '20260812000400_0004_qr_verified_purchases.sql',
  '20260812000500_0005_verified_shop_ratings.sql',
  '20260812000600_0006_chat_notifications_account.sql',
  '20260812000700_0007_storage_realtime.sql',
  '20260814000800_0008_fix_profile_role_guard.sql',
  '20260815000900_0009_verified_product_reviews_storage.sql',
  '20260829001000_0010_canonical_taxonomy_v1_staged_bootstrap.sql',
  '20260830001100_0011_canonical_taxonomy_contract_v2.sql',
  '20261013001600_0016_catalog_listing_media.sql',
  '20261014001700_0017_merchant_daily_operations.sql',
]);
export const ownerRpcs = Object.freeze([
  'merchant_catalog_categories_v1(uuid)',
  'merchant_catalog_lookup_v1(uuid,text,text)',
  'merchant_catalog_search_v1(uuid,text,integer,integer)',
  'merchant_submit_product_v1(uuid,uuid,jsonb)',
  'merchant_listing_media_v1(uuid)',
  'merchant_prepare_listing_image_v1(uuid,text,integer)',
  'merchant_change_listing_images_v1(uuid,text,uuid,uuid[])',
  'merchant_operations_read_v1(uuid,integer,integer)',
]);
export const digest = value => createHash('sha256').update(typeof value === 'string' || Buffer.isBuffer(value) ? value : JSON.stringify(value)).digest('hex');

export async function migrationManifest(root) {
  return Promise.all(coreMigrations.map(async file => ({file,
    sha256: digest(await readFile(resolve(root,'supabase/migrations',file)))})));
}
export function assertMigrationManifest(actual, expected) {
  assert.deepEqual(actual, expected, 'Exact base-core migration bytes/order required');
}

// The caller must already have established the existing runner's owned LOCAL
// container, port, empty-baseline and configuration checks. This module never
// opens a connection, accepts a URL, deploys or reads account/content rows.
export async function inspectCore(db, { transaction = true } = {}) {
  // transaction=false is used only inside rollback-only local mutation tests.
  if(transaction) await db.query('BEGIN READ ONLY');
  try {
    const functions = (await db.query(`SELECT p.oid::regprocedure::text signature,
      pg_get_functiondef(p.oid) definition, p.prosecdef security_definer,
      coalesce(p.proconfig,'{}') settings,
      has_function_privilege('anon',p.oid,'EXECUTE') anon,
      has_function_privilege('authenticated',p.oid,'EXECUTE') authenticated,
      has_function_privilege('service_role',p.oid,'EXECUTE') service_role
      FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
      WHERE n.nspname='public' AND p.prokind='f' ORDER BY 1`)).rows;
    const tables = (await db.query(`SELECT CASE WHEN n.nspname='storage' THEN 'storage.'||c.relname ELSE c.relname END name,c.relrowsecurity rls,
      c.relforcerowsecurity force_rls FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
      WHERE (n.nspname='public' OR (n.nspname='storage' AND c.relname='objects')) AND c.relkind='r' ORDER BY 1`)).rows;
    const columns = (await db.query(`SELECT table_name,column_name,data_type,udt_name,
      is_nullable,column_default FROM information_schema.columns WHERE table_schema='public'
      ORDER BY table_name,ordinal_position`)).rows;
    const policies = (await db.query(`SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check
      FROM pg_policies WHERE schemaname IN ('public','storage') ORDER BY 1,2,3`)).rows;
    const indexes = (await db.query(`SELECT tablename,indexname,indexdef FROM pg_indexes
      WHERE schemaname='public' ORDER BY 1,2`)).rows;
    const constraints = (await db.query(`SELECT c.conrelid::regclass::text relation,c.conname name,
      pg_get_constraintdef(c.oid) definition FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace
      WHERE n.nspname='public' ORDER BY 1,2`)).rows;
    const triggers = (await db.query(`SELECT c.relname relation,t.tgname name,t.tgenabled enabled,
      pg_get_triggerdef(t.oid) definition FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid
      JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT t.tgisinternal ORDER BY 1,2`)).rows;
    const grants = (await db.query(`SELECT table_name,column_name,grantee,privilege_type,is_grantable
      FROM information_schema.column_privileges WHERE table_schema='public'
      AND grantee IN ('PUBLIC','anon','authenticated','service_role') ORDER BY 1,2,3,4`)).rows;
    const buckets = (await db.query(`SELECT id,public,file_size_limit,allowed_mime_types
      FROM storage.buckets WHERE id='listing-media' ORDER BY id`)).rows;
    const config = (await db.query('SELECT * FROM public.catalog_media_config ORDER BY singleton')).rows;
    const ledger = (await db.query('SELECT version,name FROM supabase_migrations.schema_migrations ORDER BY version')).rows;
    if(transaction) await db.query('COMMIT');
    return { functions,tables,columns,policies,indexes,constraints,triggers,grants,buckets,config,ledger };
  } catch(error) { if(transaction) await db.query('ROLLBACK'); throw error; }
}

export function validateCore(snapshot) {
  for(const signature of ownerRpcs) {
    const fn=snapshot.functions.find(f=>f.signature===signature);
    assert(fn, 'Missing required RPC: '+signature);
    assert.equal(fn.authenticated,true,signature);
    assert.equal(fn.anon,false,signature);
    assert.equal(fn.service_role,false,signature);
    assert.equal(fn.security_definer,true,signature);
    assert(fn.settings.includes('search_path=pg_catalog, public'),signature);
  }
  for(const name of ['profiles','shops','shop_products','notifications','product_identity',
    'product_identifiers','product_submissions','product_submission_decisions','listing_images','catalog_media_config','storage.objects']) {
    assert.equal(snapshot.tables.find(t=>t.name===name)?.rls,true,'RLS required: '+name);
  }
  const customer=snapshot.functions.find(f=>f.signature==='catalog_listing_media_read_v1(uuid[])');
  assert(customer?.anon && customer.authenticated,'Customer media projection required');
  assert.equal(snapshot.buckets.length,1);
  assert.equal(snapshot.buckets[0].public,false,'Listing bucket must remain private');
  assert.equal(Number(snapshot.buckets[0].file_size_limit),8388608);
  assert.deepEqual([...snapshot.buckets[0].allowed_mime_types].sort(),['image/jpeg','image/png','image/webp']);
  assert.equal(snapshot.config.length,1);
  assert.equal(snapshot.config[0].decisions_enabled,false,'Approval stays OFF');
  assert.equal(snapshot.config[0].max_listing_photos,6);
  assert.equal(snapshot.config[0].max_photo_bytes,8388608);
  for(const name of ['listing_media_owned_upload','listing_media_safe_read','catalog_submissions_owned',
    'catalog_decisions_owned','listing_images_owned_or_published']) assert(snapshot.policies.some(p=>p.policyname===name),name);
  assert(snapshot.indexes.some(i=>i.indexname==='shops_owner_user_id_unique_idx' && i.indexdef.includes('UNIQUE')));
  assert(snapshot.constraints.some(c=>c.name==='shop_products_shop_product_key' && c.definition==='UNIQUE (shop_id, product_id)'));
  assert(snapshot.triggers.some(t=>t.name==='catalog_listing_identity_guard' && t.enabled==='O'));
  for(const table of ['product_submissions','product_submission_decisions','listing_images','catalog_media_config']) {
    assert(!snapshot.grants.some(g=>g.table_name===table && ['PUBLIC','anon','authenticated'].includes(g.grantee)
      && g.privilege_type!=='SELECT'),'Unexpected client write grant: '+table);
  }
  // An extended server needs a separately reviewed manifest, not this minimal profile.
  for(const name of ['qr_protocol_config','review_protocol_config','push_devices','commerce_ledger_accounts']) {
    assert(!snapshot.tables.some(t=>t.name===name),'Outside base-core profile: '+name);
  }
  return { result:'BASE_CORE_LOCAL_CONTRACT_PASS',schema_sha256:digest(snapshot),
    required_owner_rpcs:ownerRpcs,remote_authorized:false,distribution_ready:false };
}

export function compareCore(expected, actual) {
  validateCore(actual);
  assert.equal(digest(actual),digest(expected),'Schema/grant/policy/Storage/ledger drift: review required');
}
