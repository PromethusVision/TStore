// In-memory PostgreSQL only. Never imports a remote driver or production config.
// Run: node tool/engagement/schema.test.mjs <local-pglite-package-directory>
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { resolve } from 'node:path';
import assert from 'node:assert/strict';
const { PGlite } = await import(pathToFileURL(resolve(process.argv[2], 'dist/index.js')).href);
const db = new PGlite();
const schema = await readFile(new URL('../../supabase/proposals/0016_engagement_foundation.sql', import.meta.url), 'utf8');
await db.exec(`CREATE ROLE anon; CREATE ROLE authenticated; CREATE ROLE service_role BYPASSRLS;
CREATE SCHEMA auth; CREATE TABLE auth.users(id uuid PRIMARY KEY);
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS
$$ SELECT nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
GRANT USAGE ON SCHEMA auth TO authenticated, anon;
CREATE TABLE public.profiles(id uuid PRIMARY KEY REFERENCES auth.users(id), role text NOT NULL);
CREATE TABLE public.notifications(id uuid PRIMARY KEY);
CREATE TABLE public.banners(id uuid PRIMARY KEY, image_url text NOT NULL, title text, subtitle text);
GRANT INSERT, SELECT ON public.banners TO service_role;
INSERT INTO auth.users VALUES ('00000000-0000-0000-0000-000000000001'),
('00000000-0000-0000-0000-000000000002'),('00000000-0000-0000-0000-000000000003');
INSERT INTO public.profiles SELECT id, CASE WHEN id::text LIKE '%3' THEN 'merchant' ELSE 'customer' END FROM auth.users;
INSERT INTO public.notifications VALUES ('00000000-0000-0000-0000-000000000099');`);
await db.exec(schema);
let passed = 0;
const uid = n => `00000000-0000-0000-0000-${String(n).padStart(12,'0')}`;
const install = uid(10);
async function asUser(n, sql, { deny = false, role = 'authenticated' } = {}) {
  await db.exec('BEGIN');
  try {
    await db.exec(`SET LOCAL ROLE ${role}; SET LOCAL request.jwt.claim.sub = '${n ? uid(n) : ''}'`);
    if (deny) await assert.rejects(db.exec(sql)); else await db.exec(sql);
  } finally { await db.exec('ROLLBACK'); }
  passed++;
}
const register = (appRole = 'customer', token = 'fixture-token') =>
  `SELECT public.register_push_device_v1('${install}','${appRole}','${token}','android')`;
await asUser(1, register());
await asUser(3, register('merchant'));
await asUser(1, register('merchant'), {deny:true});
await asUser(3, register('customer'), {deny:true});
await asUser(null, register(), {deny:true,role:'anon'});
await asUser(null, register(), {deny:true});
await asUser(1, register('admin'), {deny:true});
await asUser(1, register('customer','has whitespace'), {deny:true});
await asUser(1, "SELECT * FROM public.push_devices", {deny:true});
await asUser(1, "INSERT INTO public.push_devices DEFAULT VALUES", {deny:true});
await asUser(1, "SELECT public._assert_push_identity_v1('customer')", {deny:true});
await db.exec(`INSERT INTO public.push_devices(installation_id,app_role,user_id,push_token,platform)
VALUES ('${install}','customer','${uid(1)}','fixture-token','android');
INSERT INTO public.notification_preferences(user_id,app_role) VALUES ('${uid(1)}','customer');`);
await asUser(2, register(), {deny:true}); // Cannot steal a known installation/token.
await db.exec(`BEGIN; SET LOCAL ROLE authenticated; SET LOCAL request.jwt.claim.sub = '${uid(2)}'`);
await assert.rejects(db.exec(`SELECT public.register_push_device_v1('${uid(11)}','customer','fixture-token','ios')`),
  (error) => error.message === 'push_device_unavailable' && !String(error.detail).includes('fixture-token'));
await db.exec('ROLLBACK'); passed++;
await asUser(1, register('customer','rotated-fixture-token'));
await asUser(2, `SELECT public.disable_push_device_v1('${install}','customer');
RESET ROLE; DO $$ BEGIN IF NOT (SELECT enabled FROM public.push_devices) THEN
RAISE EXCEPTION 'foreign disable'; END IF; END $$;`);
await asUser(1, `SELECT public.disable_push_device_v1('${install}','customer');
RESET ROLE; DO $$ BEGIN IF (SELECT enabled FROM public.push_devices) THEN
RAISE EXCEPTION 'not disabled'; END IF; END $$;`);
await asUser(1, "SELECT public.set_notification_preferences_v1('customer',false,false)");
await asUser(1, "SELECT public.set_notification_preferences_v1('merchant',true,true)", {deny:true});
await asUser(1, "UPDATE public.notification_preferences SET marketing_enabled=true", {deny:true});
await asUser(2, `DO $$ BEGIN IF (SELECT count(*) FROM public.notification_preferences) <> 0 THEN
RAISE EXCEPTION 'cross account read'; END IF; END $$;`);
await asUser(1, `DO $$ BEGIN IF (SELECT marketing_enabled FROM public.notification_preferences) THEN
RAISE EXCEPTION 'default opt in'; END IF; END $$;`);
await asUser(1, 'SELECT * FROM public.push_deliveries', {deny:true});
await asUser(1, 'INSERT INTO public.push_deliveries DEFAULT VALUES', {deny:true});
await asUser(null, 'SELECT * FROM public.push_devices', {deny:true,role:'anon'});
await asUser(null, 'SELECT * FROM public.notification_preferences', {deny:true,role:'anon'});
await asUser(1, `INSERT INTO public.banners(id,image_url,title,subtitle,content_version)
VALUES ('${uid(20)}','','',NULL,2)`, {deny:true,role:'service_role'});
const functions = await db.query(`SELECT proname,proconfig,proacl::text FROM pg_proc
WHERE pronamespace='public'::regnamespace AND proname IN ('_assert_push_identity_v1',
'register_push_device_v1','disable_push_device_v1','set_notification_preferences_v1')`);
assert.equal(functions.rows.length, 4);
for (const fn of functions.rows) {
  assert.deepEqual(fn.proconfig, ['search_path=pg_catalog']);
  assert.ok(!/[{,]=X\//.test(fn.proacl)); // No PUBLIC execute.
}
passed++;
await db.exec(`BEGIN; SET LOCAL ROLE service_role;
INSERT INTO public.push_deliveries(notification_id,installation_id,app_role)
VALUES ('${uid(99)}','${install}','customer');`);
await assert.rejects(db.exec(`INSERT INTO public.push_deliveries(notification_id,installation_id,app_role)
VALUES ('${uid(99)}','${install}','customer')`));
await db.exec('ROLLBACK'); passed++;
await db.close();
console.log(`LOCAL_POSTGRES_SCHEMA_RLS: ${passed} PASS; REMOTE_ACCESS: NO`);
