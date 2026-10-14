// Ephemeral PostgreSQL only. No remote drivers, URLs, secrets, or configuration.
// node tool/catalog_media/schema.test.mjs <local-pglite-package-directory>
import { readFile, readdir } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
export async function createCatalogFixture(pglitePath) {
const { PGlite } = await import(pathToFileURL(resolve(pglitePath, 'dist/index.js')).href);
const db = new PGlite();

const uid = n => `00000000-0000-4000-8000-${String(n).padStart(12,'0')}`;

async function asUser(n,sql, {deny=false,role='authenticated',params=[]}={}) {
 await db.exec('BEGIN');
 try {
  await db.exec(`SET LOCAL ROLE ${role}; SET LOCAL request.jwt.claim.sub='${n ? uid(n) : ''}'; SET LOCAL request.jwt.claim.role='${role}'`);
  if(deny) { await assert.rejects(db.query(sql,params)); return; }
  const result=await db.query(sql,params); await db.exec('COMMIT'); return result.rows;
 } finally { await db.exec('ROLLBACK'); }
}
await db.exec(`
  CREATE ROLE anon NOLOGIN;
  CREATE ROLE authenticated NOLOGIN; CREATE ROLE service_role NOLOGIN BYPASSRLS;

  CREATE SCHEMA auth;
  CREATE SCHEMA extensions;
  CREATE SCHEMA storage;

  CREATE TABLE auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT,
    raw_user_meta_data JSONB NOT NULL DEFAULT '{}'::JSONB
  );

  CREATE FUNCTION auth.uid()
  RETURNS UUID
  LANGUAGE sql
  STABLE
  AS $$
    SELECT NULLIF(current_setting('request.jwt.claim.sub', true), '')::UUID
  $$;

  CREATE FUNCTION auth.role()
  RETURNS TEXT
  LANGUAGE sql
  STABLE
  AS $$
    SELECT NULLIF(current_setting('request.jwt.claim.role', true), '')
  $$;

  -- PGlite does not bundle pgcrypto. Supabase does. This deterministic stub
  -- exercises the canonical function bodies without weakening production SQL.
  CREATE FUNCTION extensions.gen_random_bytes(byte_count INTEGER)
  RETURNS BYTEA
  LANGUAGE sql
  VOLATILE
  AS $$
    SELECT decode(
      substring(
        replace(gen_random_uuid()::TEXT, '-', '') ||
        replace(gen_random_uuid()::TEXT, '-', '')
        FROM 1 FOR byte_count * 2
      ),
      'hex'
    )
  $$;

  CREATE TABLE storage.buckets (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    public BOOLEAN NOT NULL DEFAULT false,
    file_size_limit BIGINT,
    allowed_mime_types TEXT[]
  );

  CREATE TABLE storage.objects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    bucket_id TEXT NOT NULL REFERENCES storage.buckets(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    metadata JSONB, created_at TIMESTAMPTZ NOT NULL DEFAULT now(), UNIQUE(bucket_id,name)
  );
  ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

  CREATE PUBLICATION supabase_realtime;
`);

await db.exec(`CREATE SCHEMA supabase_migrations; CREATE TABLE supabase_migrations.schema_migrations(version text PRIMARY KEY,name text,statements text[]);
GRANT USAGE ON SCHEMA auth,storage TO anon,authenticated,service_role;
GRANT INSERT,SELECT ON storage.objects TO authenticated; GRANT SELECT ON storage.objects TO anon;`);
const files=(await readdir('supabase/migrations')).filter(n=>n.endsWith('.sql')).sort();
// Frozen Development ledger IDs referenced by unchanged 0010/0011.
const legacyVersions=['20260812010907','20260812011047','20260812011128','20260812013109','20260812013220','20260812013308','20260812013403','20260814000820','20260815000900'];
for(const file of files.filter(n=>Number(n.match(/_(\d{4})_/)[1])<=11)) {
 const sql=(await readFile('supabase/migrations/'+file,'utf8')).replace('CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;','-- local pgcrypto stub');
 try { await db.exec(sql); } catch(e) { throw new Error(file+': '+e.message); }
 const ordinal=Number(file.match(/_(\d{4})_/)[1]);
 await db.query('INSERT INTO supabase_migrations.schema_migrations VALUES($1,$2,$3)',[legacyVersions[ordinal-1]??file.split('_')[0],file.slice(15,-4),[]]);
}
// Synthetic local publisher fixture. No activation executor is imported/run.
const leaf=(await db.query(`WITH RECURSIVE paths AS (
 SELECT id,parent_id,ARRAY[id] ancestry,policy_class,professional_review_status,is_assignable FROM public.categories WHERE parent_id IS NULL
 UNION ALL SELECT c.id,c.parent_id,p.ancestry||c.id,c.policy_class,c.professional_review_status,c.is_assignable FROM public.categories c JOIN paths p ON c.parent_id=p.id)
SELECT p.id,p.ancestry FROM paths p WHERE NOT EXISTS(SELECT 1 FROM public.categories c WHERE c.parent_id=p.id)
AND NOT EXISTS(SELECT 1 FROM public.categories c WHERE c.id=ANY(p.ancestry) AND c.policy_class='EXCLUDED') ORDER BY p.id LIMIT 1`)).rows[0];
assert.ok(leaf);
await db.query("UPDATE public.categories SET is_active=true,lifecycle_state='active',policy_class='NORMAL',professional_review_status='not_required' WHERE id=ANY($1::uuid[])",[leaf.ancestry]);
await db.query('UPDATE public.categories SET is_assignable=true WHERE id=$1',[leaf.id]);
const category=leaf.id;
for(const n of [1,2,3])await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)',[uid(n),`user${n}@example.invalid`]);
await db.exec(`UPDATE public.profiles SET role='merchant' WHERE id IN ('${uid(1)}','${uid(2)}');
INSERT INTO public.shops(id,owner_user_id,name) VALUES('${uid(10)}','${uid(1)}','Esnaf A'),('${uid(11)}','${uid(2)}','Esnaf B');`);
await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,$3,$4)',[uid(20),'Test kalem',8,category]);
await db.exec(`INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES('${uid(30)}','${uid(10)}','${uid(20)}',12),('${uid(31)}','${uid(11)}','${uid(20)}',14)`);
const migration=await readFile('supabase/migrations/20261013001600_0016_catalog_listing_media.sql','utf8');
await db.exec(migration);
await db.exec(`INSERT INTO public.product_identifiers(gtin,product_id) VALUES('04006381333931','${uid(20)}')`);

return { db, uid, asUser, category, leaf };
}
