import { readFile, readdir } from 'node:fs/promises';
import { resolve } from 'node:path';
import { createHash, randomUUID } from 'node:crypto';
import assert from 'node:assert/strict';
import pg from 'pg';
import { root } from './local.mjs';

export async function connect(config) {
  const db = new pg.Client({ ...config, connectionTimeoutMillis: 5000, statement_timeout: 20000,
    query_timeout: 25000, application_name: 'ev-merchant-ab-acceptance' });
  await db.connect(); return db;
}
export async function migrate(db, { reviews = false, trustCampaigns = false } = {}) {
  assert.equal((await db.query("SELECT to_regclass('public.profiles') AS existing")).rows[0].existing, null, 'Fresh fixture required');
  assert.equal((await db.query('SELECT count(*)::int n FROM auth.users')).rows[0].n, 0, 'Existing Auth data forbidden');
  assert.equal((await db.query('SELECT count(*)::int n FROM storage.objects')).rows[0].n, 0, 'Existing Storage data forbidden');
  await db.query(`CREATE SCHEMA IF NOT EXISTS supabase_migrations;
    CREATE TABLE IF NOT EXISTS supabase_migrations.schema_migrations(version text PRIMARY KEY,name text,statements text[]);`);
  assert.equal((await db.query('SELECT count(*)::int n FROM supabase_migrations.schema_migrations')).rows[0].n, 0, 'Existing migration ledger forbidden');
  const historical = ['20260812010907','20260812011047','20260812011128','20260812013109',
    '20260812013220','20260812013308','20260812013403','20260814000820','20260815000900'];
  const selected = (await readdir(resolve(root, 'supabase/migrations'))).filter(f => {
    const ordinal = Number(f.match(/_(\d{4})_/)?.[1]);
    return ordinal <= 11 || [16,17,18].includes(ordinal) || ((reviews || trustCampaigns) && ordinal === 19) || (trustCampaigns && [20,21].includes(ordinal));
  }).sort();
  const manifest = [];
  for (const file of selected) {
    const sql = await readFile(resolve(root, 'supabase/migrations', file), 'utf8');
    // Execute exact tracked migration bytes: no crypto or SQL replacement.
    await db.query(sql);
    const ordinal = Number(file.match(/_(\d{4})_/)[1]);
    await db.query('INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES($1,$2,$3)',
      [historical[ordinal - 1] ?? file.split('_')[0], file.slice(15,-4), []]);
    manifest.push({ file, sha256: createHash('sha256').update(sql).digest('hex') });
  }
  return manifest;
}

export async function seed(db, merchant, other, customer) {
  // Synthetic publishing fixture only; never imports a Production activation executor.
  const leaf = (await db.query(`WITH RECURSIVE paths AS (
    SELECT id,parent_id,ARRAY[id] ancestry FROM public.categories WHERE parent_id IS NULL
    UNION ALL SELECT c.id,c.parent_id,p.ancestry||c.id FROM public.categories c JOIN paths p ON c.parent_id=p.id)
    SELECT p.id,p.ancestry FROM paths p WHERE NOT EXISTS(SELECT 1 FROM public.categories c WHERE c.parent_id=p.id)
    AND NOT EXISTS(SELECT 1 FROM public.categories c WHERE c.id=ANY(p.ancestry) AND c.policy_class='EXCLUDED') ORDER BY p.id LIMIT 1`)).rows[0];
  assert(leaf);
  await db.query("UPDATE public.categories SET is_active=true,lifecycle_state='active',policy_class='NORMAL',professional_review_status='not_required' WHERE id=ANY($1::uuid[])", [leaf.ancestry]);
  await db.query('UPDATE public.categories SET is_assignable=true WHERE id=$1', [leaf.id]);
  await db.query("UPDATE public.profiles SET role='merchant' WHERE id=ANY($1::uuid[])", [[merchant.id, other.id]]);
  const shop = randomUUID(), otherShop = randomUUID(), product = randomUUID();
  await db.query('INSERT INTO public.shops(id,owner_user_id,name) VALUES($1,$2,$3),($4,$5,$6)',
    [shop, merchant.id, 'Local Esnaf A', otherShop, other.id, 'Local Esnaf B']);
  await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,$3,$4)', [product, 'Local acceptance kalem', 8, leaf.id]);
  return { shop, otherShop, product, category: leaf.id, merchant, other, customer };
}

export async function sqlAs(config, actor, sql, params = [], { before, hold } = {}) {
  const db = await connect(config);
  try {
    await db.query('BEGIN');
    await db.query("SELECT set_config('request.jwt.claims',$1,true),set_config('request.jwt.claim.sub',$2,true),set_config('request.jwt.claim.role','authenticated',true)",
      [JSON.stringify(actor.claims), actor.id]);
    await db.query('SET LOCAL ROLE authenticated');
    if (before) await before(db);
    const result = await db.query(sql, params);
    if (hold) await hold(db);
    await db.query('COMMIT');
    return result;
  } catch (e) { await db.query('ROLLBACK'); throw e; } finally { await db.end(); }
}

export function rpc(config, actor, name, params = [], options) {
  assert(/^[a-z_0-9]+$/.test(name));
  return sqlAs(config, actor, `SELECT to_jsonb(public.${name}(${params.map((_,i) => '$'+(i+1)).join(',')})) result`,
    params.map(p => Array.isArray(p) && p.some(x => typeof x === 'object') ? JSON.stringify(p) : p), options).then(r => r.rows[0].result);
}

export async function nativeManagedSchema(db) {
  // Native proof ONLY: Auth/Storage schema stand-ins, never managed-service evidence.
  await db.query(`CREATE ROLE anon NOLOGIN; CREATE ROLE authenticated NOLOGIN; CREATE ROLE service_role NOLOGIN BYPASSRLS;
    CREATE SCHEMA auth; CREATE SCHEMA extensions; CREATE SCHEMA storage;
    CREATE TABLE auth.users(id uuid PRIMARY KEY,email text,raw_user_meta_data jsonb NOT NULL DEFAULT '{}');
    CREATE TABLE auth.sessions(id uuid PRIMARY KEY,user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,not_after timestamptz);
    CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
    CREATE FUNCTION auth.role() RETURNS text LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claim.role',true),'') $$;
    CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claims',true),'')::jsonb $$;
    CREATE TABLE storage.buckets(id text PRIMARY KEY,name text NOT NULL UNIQUE,public boolean DEFAULT false,file_size_limit bigint,allowed_mime_types text[]);
    CREATE TABLE storage.objects(id uuid PRIMARY KEY DEFAULT gen_random_uuid(),bucket_id text REFERENCES storage.buckets(id),name text,metadata jsonb,created_at timestamptz DEFAULT now(),UNIQUE(bucket_id,name));
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
    GRANT USAGE ON SCHEMA auth,storage TO anon,authenticated,service_role;
    GRANT INSERT,SELECT ON storage.objects TO authenticated; GRANT SELECT ON storage.objects TO anon;
    CREATE PUBLICATION supabase_realtime;`);
}
