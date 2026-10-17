import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { SUPABASE_LEDGER_CONTRACT } from '../taxonomy_migration/lib.mjs';

// Offline preparation only. This module has no connection, HTTP, credential or
// remote execution API. A review token prevents accidental execution; it is NOT
// proof of human authorization or server identity. The future operator must
// verify the exact target and obtain separate approval for each changed system.
export const projectRef = 'tnipyxnvhgelwdpykyez';
export const projectUrl = `https://${projectRef}.supabase.co`;
export const baselineLedger = [
  ...SUPABASE_LEDGER_CONTRACT.map(({version,name})=>({version,name})),
  {version:'20260829001000',name:'0010_canonical_taxonomy_v1_staged_bootstrap'},
  {version:'20260830001100',name:'0011_canonical_taxonomy_contract_v2'},
];
export const delta = [
  {file:'20261013001600_0016_catalog_listing_media.sql',sha256_lf:'e4eb68ffb47594f411a263361b43d026483fe45c76fb95f0421edaf78c3786cb'},
  {file:'20261014001700_0017_merchant_daily_operations.sql',sha256_lf:'c677c9cd696292e278a5bc6754e1e7f0cbccb62f9854932614ae860c37d40e3d'},
];
export const digest = (value,algorithm='sha256')=>createHash(algorithm).update(value).digest('hex');
const uuidPattern=/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
export const quote = value=>"'"+String(value).replaceAll("'","''")+"'";
export function checkTarget(target) {
  assert.deepEqual(target,{project_ref:projectRef,project_url:projectUrl},'Exact Development target required');
}

// Deliberately excludes application rows, secrets, Auth users and Storage objects.
// Definitions are represented by hashes, not source/credentials. PostgreSQL's
// canonical jsonb text supplies a portable database-side drift fingerprint.
export const schemaExpression = `jsonb_build_object(
 'ledger',(SELECT coalesce(jsonb_agg(jsonb_build_object('version',version,'name',name) ORDER BY version),'[]') FROM supabase_migrations.schema_migrations),
 'tables',(SELECT jsonb_agg(jsonb_build_object('name',n.nspname||'.'||c.relname,'rls',c.relrowsecurity,'force',c.relforcerowsecurity) ORDER BY n.nspname,c.relname) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.relkind='r' AND (n.nspname='public' OR (n.nspname='storage' AND c.relname='objects'))),
 'columns',(SELECT jsonb_agg(to_jsonb(x) ORDER BY table_name,ordinal_position) FROM (SELECT table_name,column_name,ordinal_position,data_type,udt_name,is_nullable,column_default FROM information_schema.columns WHERE table_schema='public') x),
 'functions',(SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'definition_md5',md5(pg_get_functiondef(p.oid)),'definer',p.prosecdef,'settings',p.proconfig,'anon',has_function_privilege('anon',p.oid,'EXECUTE'),'authenticated',has_function_privilege('authenticated',p.oid,'EXECUTE'),'service_role',has_function_privilege('service_role',p.oid,'EXECUTE')) ORDER BY p.oid::regprocedure::text) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public' AND p.prokind='f' AND NOT EXISTS(SELECT 1 FROM pg_depend d WHERE d.classid='pg_proc'::regclass AND d.objid=p.oid AND d.deptype='e')),
 'policies',(SELECT jsonb_agg(to_jsonb(x) ORDER BY schemaname,tablename,policyname) FROM (SELECT schemaname,tablename,policyname,permissive,roles,cmd,qual,with_check FROM pg_policies WHERE schemaname IN ('public','storage')) x),
 'indexes',(SELECT jsonb_agg(to_jsonb(x) ORDER BY tablename,indexname) FROM (SELECT tablename,indexname,indexdef FROM pg_indexes WHERE schemaname='public') x),
 'constraints',(SELECT jsonb_agg(jsonb_build_object('table',c.conrelid::regclass::text,'name',c.conname,'definition',pg_get_constraintdef(c.oid)) ORDER BY c.conrelid::regclass::text,c.conname) FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public'),
 'triggers',(SELECT jsonb_agg(jsonb_build_object('table',c.relname,'name',t.tgname,'enabled',t.tgenabled,'definition',pg_get_triggerdef(t.oid)) ORDER BY c.relname,t.tgname) FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND NOT t.tgisinternal),
 'grants',(SELECT jsonb_agg(to_jsonb(x) ORDER BY table_name,column_name,grantee,privilege_type) FROM (SELECT table_name,column_name,grantee,privilege_type,is_grantable FROM information_schema.column_privileges WHERE table_schema='public' AND grantee IN ('PUBLIC','anon','authenticated','service_role')) x),
 'table_privileges',(SELECT jsonb_agg(jsonb_build_object('table',c.relname,'role',r.role,'privilege',v.privilege,'allowed',has_table_privilege(r.role,c.oid,v.privilege)) ORDER BY c.relname,r.role,v.privilege) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace CROSS JOIN (VALUES ('anon'),('authenticated'),('service_role')) r(role) CROSS JOIN (VALUES ('SELECT'),('INSERT'),('UPDATE'),('DELETE'),('TRUNCATE'),('REFERENCES'),('TRIGGER'),('MAINTAIN')) v(privilege) WHERE n.nspname='public' AND c.relkind='r'),
 'postgres_public_defaults',(SELECT coalesce(jsonb_agg(jsonb_build_object('kind',d.defaclobjtype,'acl',d.defaclacl::text) ORDER BY d.defaclobjtype),'[]') FROM pg_default_acl d JOIN pg_namespace n ON n.oid=d.defaclnamespace WHERE n.nspname='public' AND pg_get_userbyid(d.defaclrole)='postgres'),
 'public_event_triggers',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',e.evtname,'event',e.evtevent,'enabled',e.evtenabled,'function',e.evtfoid::regprocedure::text,'tags',e.evttags) ORDER BY e.evtname),'[]') FROM pg_event_trigger e JOIN pg_proc p ON p.oid=e.evtfoid JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='public'),
 'buckets',(SELECT coalesce(jsonb_agg(jsonb_build_object('id',id,'public',public,'file_size_limit',file_size_limit,'allowed_mime_types',allowed_mime_types) ORDER BY id),'[]') FROM storage.buckets))`;
export const taxonomyExpression = `(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM
 (SELECT id,parent_id,name,level,is_active,lifecycle_state,is_assignable,policy_class,professional_review_status,taxonomy_version
 FROM public.categories) x)`;
export const readOnlySql = select=>`BEGIN READ ONLY;\nSET LOCAL statement_timeout='15s';\nSET LOCAL lock_timeout='2s';\n${select};\nROLLBACK;\n`;
export const snapshotSql = readOnlySql(`SELECT (${schemaExpression})::text AS schema_text, (${taxonomyExpression})::text AS taxonomy_text`);

export function validateBaseline(schemaText) {
  const schema=JSON.parse(schemaText);
  assert.deepEqual(schema.ledger,baselineLedger,'Historical ledger drift; never repair automatically');
  for(const name of ['profiles','shops','shop_products','notifications','products','categories','taxonomy_contract_config']) {
    assert.equal(schema.tables.find(t=>t.name==='public.'+name)?.rls,true,'Required RLS: '+name);
  }
  assert.equal(schema.tables.find(t=>t.name==='storage.objects')?.rls,true);
  for(const name of ['product_identity','product_identifiers','product_submissions','product_submission_decisions','listing_images','catalog_media_config','canonical_categories','qr_protocol_config','review_protocol_config','push_devices','commerce_ledger_accounts']) {
    assert(!schema.tables.some(t=>t.name==='public.'+name),'Unexpected deployed/extended object: '+name);
  }
  assert(!schema.buckets.some(b=>b.id==='listing-media'),'Existing listing bucket requires review');
  for(const name of ['prevent_profile_role_client_escalation']) assert(schema.triggers.some(t=>t.name===name && t.enabled==='O'),'Missing role guard');
  assert(schema.indexes.some(i=>i.indexname==='shops_owner_user_id_unique_idx' && i.indexdef.includes('UNIQUE')));
  assert(schema.constraints.some(c=>c.name==='shop_products_shop_product_key' && c.definition==='UNIQUE (shop_id, product_id)'));
  for(const name of ['profiles_insert_own','profiles_update_own','shops_owner_create_role_gated','shops_owner_update_role_gated','shop_products_owner_create_role_gated','shop_products_owner_update_role_gated','notifications_select_own','notifications_update_own']) {
    assert(schema.policies.some(p=>p.policyname===name),'Missing baseline policy: '+name);
  }
  return schema;
}

export async function loadDelta(root) {
  return Promise.all(delta.map(async item=>{
    const raw=await readFile(resolve(root,'supabase/migrations',item.file));
    const sql=raw.toString('utf8').replaceAll('\r\n','\n');
    assert.equal(digest(sql),item.sha256_lf,'Reviewed migration source changed');
    const begin=sql.indexOf('\nBEGIN;\n');
    assert(begin>=0 && sql.trimEnd().endsWith('\nCOMMIT;'),'Unexpected transaction envelope');
    // Only the two pinned outer envelopes are removed to make the reviewed
    // pair and its ledger inserts atomic. Every statement in each body is kept.
    const body=sql.slice(begin+8,sql.lastIndexOf('\nCOMMIT;'));
    assert.equal(sql.slice(0,begin+8)+body+sql.slice(sql.lastIndexOf('\nCOMMIT;')),sql);
    return {...item,sha256_bytes:digest(raw),body,sql,version:item.file.slice(0,14),name:item.file.slice(15,-4)};
  }));
}

function envelope(plan,body,{timeout='120s'}={}) {
  return `-- REVIEW CANDIDATE ONLY: ${projectRef}; separate Product Owner approval required.\n`+
    `-- Token is an accidental-execution guard, not authorization or target verification.\nBEGIN;\nSET LOCAL lock_timeout='5s';\nSET LOCAL statement_timeout='${timeout}';\n`+
    `DO $pilot_guard$ BEGIN\n IF current_setting('esnaftavar.pilot_review_token',true) IS DISTINCT FROM ${quote(plan.sha256)} THEN RAISE EXCEPTION 'PILOT_REVIEW_NOT_APPROVED'; END IF;\n IF NOT pg_try_advisory_xact_lock(hashtextextended('esnaftavar:${projectRef}:pilot-preparation',0)) THEN RAISE EXCEPTION 'PILOT_COMPETING_WRITER'; END IF;\nEND $pilot_guard$;\n`+body+'\nCOMMIT;\n';
}
function seal(manifest) { return {...manifest,sha256:digest(JSON.stringify(manifest))}; }
export function schemaPlan(target,schemaText,sources) {
  checkTarget(target); validateBaseline(schemaText);
  assert.deepEqual(sources.map(({file,sha256_lf})=>({file,sha256_lf})),delta);
  for(const s of sources) {
    assert.equal(digest(s.sql),s.sha256_lf);
    assert.equal(s.body,s.sql.slice(s.sql.indexOf('\nBEGIN;\n')+8,s.sql.lastIndexOf('\nCOMMIT;')),'Migration body changed');
    assert.equal(s.version,s.file.slice(0,14)); assert.equal(s.name,s.file.slice(15,-4));
  }
  const manifest={contract:'merchant-pilot-schema-review-v1',target,
    baseline_md5:digest(schemaText,'md5'),baseline_sha256:digest(schemaText),
    migrations:sources.map(({body,sql,...m})=>m),remote_authorized:false,
    capabilities:'base-core-only; catalog decisions and downstream features remain OFF',
    effect:'Two new migration ledger entries, catalog identity backfill, six tables, private media bucket and existing versioned RPCs; no taxonomy or Auth setting changes',
    rollback:'Transaction failure rolls back both migrations and ledger entries. After commit preserve evidence; stop distribution and prepare a separately reviewed forward correction. Never auto-drop or delete.'};
  const plan=seal(manifest);
  const preflight=readOnlySql(`SELECT md5((${schemaExpression})::text)=${quote(plan.baseline_md5)} AS baseline_matches, md5((${schemaExpression})::text) AS observed_md5, (SELECT count(*) FROM public.products) AS identity_backfill_rows`);
  const before=`LOCK TABLE public.products,public.brands,public.shops,public.shop_products,supabase_migrations.schema_migrations,storage.buckets IN SHARE ROW EXCLUSIVE MODE;\nDO $pilot_baseline$ BEGIN\n IF md5((${schemaExpression})::text)<>${quote(plan.baseline_md5)} THEN RAISE EXCEPTION 'PILOT_BASELINE_DRIFT'; END IF;\nEND $pilot_baseline$;\n`;
  const sql=envelope(plan,before+sources.map(s=>s.body+`\nINSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${quote(s.version)},${quote(s.name)},ARRAY[${quote(s.sql)}]);\n`).join('\n')+
    `DO $pilot_post$ BEGIN IF (SELECT count(*) FROM public.product_identity)<>(SELECT count(*) FROM public.products) OR (SELECT decisions_enabled FROM public.catalog_media_config) IS DISTINCT FROM false THEN RAISE EXCEPTION 'PILOT_POSTCHECK_FAILED'; END IF; END $pilot_post$;\nNOTIFY pgrst,'reload schema';`);
  return {plan,preflight,sql};
}

export function categoryPlan(target,taxonomyText,leafIds) {
  checkTarget(target); assert(Array.isArray(leafIds) && leafIds.length>0,'Choose explicit pilot leaves first');
  assert(leafIds.every(id=>typeof id==='string' && uuidPattern.test(id)),'Category UUID required');
  assert.equal(new Set(leafIds).size,leafIds.length,'Duplicate leaf');
  const nodes=JSON.parse(taxonomyText), byId=new Map(nodes.map(n=>[n.id,n]));
  assert.equal(byId.size,nodes.length,'Duplicate taxonomy identity');
  const selected=new Map();
  for(const id of leafIds) {
    assert(byId.has(id),'Unknown leaf'); assert(!nodes.some(n=>n.parent_id===id),'Exact leaf required');
    let current=byId.get(id); const seen=new Set();
    while(current) {
      assert(!seen.has(current.id),'Taxonomy cycle'); seen.add(current.id);
      assert.equal(current.policy_class,'NORMAL','No policy override');
      assert.equal(current.professional_review_status,'not_required','Review-gated category not eligible for this bounded pack');
      assert.equal(current.taxonomy_version,'canonical-v1.0.0');
      assert.equal(current.is_active,false,'Existing activation requires separate review');
      assert.equal(current.lifecycle_state,'staged'); assert.equal(current.is_assignable,false);
      selected.set(current.id,current);
      if(current.parent_id===null) { assert.equal(current.level,1); break; }
      const parent=byId.get(current.parent_id); assert(parent && parent.level===current.level-1,'Missing or invalid ancestor'); current=parent;
    }
  }
  const changed=[...selected.values()].sort((a,b)=>a.id.localeCompare(b.id));
  const leaves=[...leafIds].sort();
  const plan=seal({contract:'merchant-pilot-category-review-v1',target,remote_authorized:false,
    taxonomy_md5:digest(taxonomyText,'md5'),leaves,
    changes:changed.map(n=>({id:n.id,name:n.name,from:{is_active:false,lifecycle_state:'staged',is_assignable:false},to:{is_active:true,lifecycle_state:'active',is_assignable:leaves.includes(n.id)}})),
    invariant:'No policy, professional review, identity, parent, price or unrelated-category changes'});
  const ids=changed.map(n=>quote(n.id)+'::uuid').join(','), leafSql=leaves.map(id=>quote(id)+'::uuid').join(',');
  const sql=envelope(plan,`LOCK TABLE public.categories IN SHARE ROW EXCLUSIVE MODE;\nDO $category_pre$ BEGIN\n IF md5((${taxonomyExpression})::text)<>${quote(plan.taxonomy_md5)} THEN RAISE EXCEPTION 'PILOT_TAXONOMY_DRIFT'; END IF;\n IF to_regprocedure('public.merchant_catalog_categories_v1(uuid)') IS NULL THEN RAISE EXCEPTION 'PILOT_SCHEMA_REQUIRED'; END IF;\nEND $category_pre$;\nUPDATE public.categories SET is_active=true,lifecycle_state='active',is_assignable=(id=ANY(ARRAY[${leafSql}])) WHERE id=ANY(ARRAY[${ids}]);\nDO $category_post$ BEGIN\n IF EXISTS(SELECT 1 FROM unnest(ARRAY[${leafSql}]) id WHERE NOT public._catalog_category_allowed_v1(id)) THEN RAISE EXCEPTION 'PILOT_CATEGORY_POSTCHECK'; END IF;\nEND $category_post$;`);
  return {plan,sql};
}

export function authPlan(target,before) {
  checkTarget(target);
  assert.deepEqual(Object.keys(before).sort(),['confirm_email','redirect_urls','site_url','smtp_enabled']);
  assert.equal(typeof before.site_url,'string'); assert.equal(typeof before.confirm_email,'boolean'); assert.equal(typeof before.smtp_enabled,'boolean');
  assert(Array.isArray(before.redirect_urls) && before.redirect_urls.every(u=>typeof u==='string'));
  const required=['com.esnaftavar.app.merchant.pilot://login-callback/','io.supabase.tstore://login-callback/']
    .flatMap(url=>[url,url+'?auth_action=password_recovery']);
  return seal({contract:'merchant-pilot-auth-review-v1',target,remote_authorized:false,before,
    proposed:{...before,redirect_urls:[...new Set([...before.redirect_urls,...required])]},
    additions:required.filter(u=>!before.redirect_urls.includes(u)),
    separate_gates:['Site URL choice affects Customer and Merchant','Confirm email change requires shared Auth review','SMTP provider/secrets and real mail acceptance','Physical cold/warm callback and account isolation'],
    rollback:'Restore the exact previous redirect list only after reviewing concurrent additions. Do not replace settings from a stale snapshot.'});
}

// A cohort plan carries roles/IDs only. Real personal details and credentials
// belong in a separately authorized private operational record, never Git.
export function cohortPlan(target,slots) {
  checkTarget(target); assert(Array.isArray(slots) && slots.length>0,'Cohort not selected');
  const names=new Set(),users=new Set();
  for(const slot of slots) {
    assert.deepEqual(Object.keys(slot).sort(),['role','slot','user_id']);
    assert(/^(merchant|customer)-[0-9]{2,4}$/.test(slot.slot));
    assert(['merchant','customer'].includes(slot.role) && slot.slot.startsWith(slot.role+'-'));
    assert(!names.has(slot.slot)); names.add(slot.slot);
    assert(slot.user_id===null || (typeof slot.user_id==='string' && uuidPattern.test(slot.user_id)));
    if(slot.user_id!==null) { assert(!users.has(slot.user_id),'One identity cannot occupy two roles'); users.add(slot.user_id); }
  }
  return seal({contract:'merchant-pilot-cohort-review-v1',target,slots,remote_authorized:false,
    ready_for_provision_approval:slots.every(s=>s.user_id!==null),
    requirements:['Explicit identity/role approval; no email or password in this file','Verified Auth identity and exact current profile role read before promotion','One owner/shop contract; merchant creates shop through existing onboarding','No admin role; no self-grant; never reassign an existing shop','No automatic invite/reset email or account deletion rollback']});
}
