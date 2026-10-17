import assert from 'node:assert/strict';
import {randomBytes,randomUUID} from 'node:crypto';
import {readFile,writeFile,mkdir,unlink,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {readRun,credentials,runtimeEvidence,root,command} from './local.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {connect,migrate} from './fixture.mjs';
import {inspectCore,validateCore,compareCore} from './pilot_contract.mjs';
import {projectRef,projectUrl,baselineLedger,snapshotSql,schemaExpression,taxonomyExpression,loadDelta,schemaPlan,categoryPlan,authPlan,cohortPlan,digest} from './pilot_preparation_contract.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';

// This runner accepts only the existing owned loopback stack. It cannot connect
// to the target named in the review artifacts, provision real people or send mail.
let db,run,credentialFile,stage='arguments';
try {
  assert.equal(process.argv.length,4,'Use a NEW owned local run and Flutter SDK path');
  run=await readRun(process.argv[2]);
  const flutter=await realpath(process.argv[3]);
  const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
  const flutterSnapshot=await realpath(resolve(flutter,'bin/cache/flutter_tools.snapshot'));
  const status=await credentials(run),services=await runtimeEvidence(run);
  const url=localUrl(status.DB_URL,'db');
  const config={host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false};
  db=await connect(config);
  stage='baseline';
  const applied=await migrate(db,{coreOnly:true,baselineOnly:true});
  stage='hosted metadata mirror';
  const hostedProfile=await mirrorHostedProfile(db);
  const queryResults=await db.query(snapshotSql);
  const captured=queryResults.find(r=>r.rows?.[0]?.schema_text)?.rows[0];assert(captured);
  const target={project_ref:projectRef,project_url:projectUrl};
  const schema= schemaPlan(target,captured.schema_text,await loadDelta(root));
  const checks=[];
  async function check(name,action) {stage=name;await action();checks.push({name,result:'PASS'});console.log('PASS '+name);}
  const scalar=async sql=>(await db.query(sql)).rows[0].value;
  const schemaNow=()=>scalar(`SELECT (${schemaExpression})::text value`);
  const taxonomyNow=()=>scalar(`SELECT (${taxonomyExpression})::text value`);
  async function token(value) { await db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[value]); }
  async function reject(sql,code) {
    try { await assert.rejects(db.query(sql),e=>e.message.includes(code)); }
    finally { await db.query('ROLLBACK'); }
  }
  const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
  const logins=new Map();
  async function actor() {
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});
    assert.equal(created.status,200);
    const session=await request('/auth/v1/token?grant_type=password',null,login);assert.equal(session.status,200);
    logins.set(created.data.id,login);return {id:created.data.id,token:session.data.access_token};
  }
  const merchant=await actor(),other=await actor(),customer=await actor(),newcomer=await actor();
  const product=randomUUID(),legacyProduct=randomUUID(),shop=randomUUID(),otherShop=randomUUID();
  await db.query("UPDATE public.profiles SET role='merchant' WHERE id=ANY($1::uuid[])",[[merchant.id,other.id,newcomer.id]]);
  await db.query('INSERT INTO public.shops(id,owner_user_id,name) VALUES($1,$2,$3),($4,$5,$6)',[shop,merchant.id,'Local existing merchant',otherShop,other.id,'Local other merchant']);
  await db.query('INSERT INTO public.products(id,name,price) VALUES($1,$2,8),($3,$4,12)',[product,'Local acceptance kalem',legacyProduct,'Legacy unclassified product']);
  const listing=randomUUID();await db.query('INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,9)',[listing,shop,legacyProduct]);
  const dataHash=()=>scalar(`SELECT md5(jsonb_build_object('profiles',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.profiles t),'shops',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.shops t),'products',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.products t),'listings',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.shop_products t))::text) value`);
  const oldData=await dataHash();
  await check('populated historical Development baseline matches reviewed schema',async()=>assert.equal(await schemaNow(),captured.schema_text));
  await check('missing or wrong per-stage review token rejects all writes',async()=>{
    for(const value of ['', 'not-approved']) {await token(value);await reject(schema.sql,'PILOT_REVIEW_NOT_APPROVED');assert.equal(await schemaNow(),captured.schema_text);}
  });
  await token(schema.plan.sha256);
  await check('unexpected ledger blocks apply without history repair',async()=>{
    await db.query("INSERT INTO supabase_migrations.schema_migrations(version,name) VALUES('99999999999999','synthetic-drift')");
    try {await reject(schema.sql,'PILOT_BASELINE_DRIFT');} finally {await db.query("DELETE FROM supabase_migrations.schema_migrations WHERE version='99999999999999'");}
    assert.equal(await schemaNow(),captured.schema_text);
  });
  await check('RLS and function permission drift block apply',async()=>{
    for(const [change,restore] of [['ALTER TABLE public.shops DISABLE ROW LEVEL SECURITY','ALTER TABLE public.shops ENABLE ROW LEVEL SECURITY'],['GRANT EXECUTE ON FUNCTION public.confirm_qr_session(text) TO anon','REVOKE EXECUTE ON FUNCTION public.confirm_qr_session(text) FROM anon']]) {
      await db.query(change);try {await reject(schema.sql,'PILOT_BASELINE_DRIFT');} finally {await db.query(restore);}assert.equal(await schemaNow(),captured.schema_text);
    }
  });
  await check('table-wide and future-object permission drift block apply',async()=>{
    const canTruncate=await scalar("SELECT has_table_privilege('anon','public.shops','TRUNCATE') value");
    for(const change of [canTruncate?'REVOKE TRUNCATE ON public.shops FROM anon':'GRANT TRUNCATE ON public.shops TO anon','ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT INSERT ON TABLES TO PUBLIC']) {
      await db.query('BEGIN');await db.query(change);
      assert.notEqual(await schemaNow(),captured.schema_text,'Drift test must alter the captured privilege');
      await reject(schema.sql,'PILOT_BASELINE_DRIFT');assert.equal(await schemaNow(),captured.schema_text);
    }
  });
  await check('competing preparation transaction refuses a second writer',async()=>{
    const competitor=await connect(config);try {
      await competitor.query('BEGIN');await competitor.query("SELECT pg_advisory_xact_lock(hashtextextended($1,0))",['esnaftavar:'+projectRef+':pilot-preparation']);
      await reject(schema.sql,'PILOT_COMPETING_WRITER');
    } finally {await competitor.query('ROLLBACK');await competitor.end();}
  });
  await check('late failure rolls back both migrations, bucket and ledger entries',async()=>{
    const fault=schema.sql.replace("NOTIFY pgrst,'reload schema';","SELECT 1/0;\nNOTIFY pgrst,'reload schema';");
    assert.notEqual(fault,schema.sql);await reject(fault,'division by zero');
    assert.equal(await schemaNow(),captured.schema_text);assert.equal(await dataHash(),oldData);
  });
  await check('reviewed two-migration upgrade commits atomically on populated baseline',async()=>{
    await db.query(schema.sql);assert.equal(await dataHash(),oldData);
    const ledger=(await db.query('SELECT version,name FROM supabase_migrations.schema_migrations ORDER BY version')).rows;
    assert.deepEqual(ledger.slice(0,11),baselineLedger);assert.equal(ledger.length,13);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.product_identity'),2);
    validateCore(await inspectCore(db));
  });
  const afterSchema=await inspectCore(db);
  await check('replay is rejected rather than silently applying or repairing',async()=>{
    await reject(schema.sql,'PILOT_BASELINE_DRIFT');compareCore(afterSchema,await inspectCore(db));
  });
  await check('schema upgrade alone neither activates taxonomy nor publishes a catalog',async()=>{
    assert.equal(await taxonomyNow(),captured.taxonomy_text);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.products WHERE public._catalog_product_public_v1(id)'),0);
  });
  const nodes=JSON.parse(captured.taxonomy_text);
  // Synthetic local scope only. Never export this selection as a PO decision.
  let categories;
  for(const node of nodes) { try {categories=categoryPlan(target,captured.taxonomy_text,[node.id]);break;} catch {} }
  assert(categories,'A fully NORMAL/not_required leaf must exist in the unchanged taxonomy');
  await check('schema approval does not authorize category activation',async()=>{
    await reject(categories.sql,'PILOT_REVIEW_NOT_APPROVED');assert.equal(await taxonomyNow(),captured.taxonomy_text);
  });
  await token(categories.plan.sha256);
  await check('stale category metadata is rejected before activation',async()=>{
    const selected=categories.plan.leaves[0];const before=(await db.query('SELECT name FROM public.categories WHERE id=$1',[selected])).rows[0].name;
    await db.query('UPDATE public.categories SET name=$1 WHERE id=$2',[before+' changed',selected]);
    try {await reject(categories.sql,'PILOT_TAXONOMY_DRIFT');} finally {await db.query('UPDATE public.categories SET name=$1 WHERE id=$2',[before,selected]);}
    assert.equal(await taxonomyNow(),captured.taxonomy_text);
  });
  await check('category failure rolls back the entire selected ancestry',async()=>{
    const fault=categories.sql.replace('DO $category_post$ BEGIN','SELECT 1/0;\nDO $category_post$ BEGIN');
    await reject(fault,'division by zero');assert.equal(await taxonomyNow(),captured.taxonomy_text);
  });
  await check('bounded activation preserves every unselected node and policy field',async()=>{
    await db.query(categories.sql);
    const after=JSON.parse(await taxonomyNow()),changes=new Map(categories.plan.changes.map(c=>[c.id,c]));
    for(const before of nodes) assert.deepEqual(after.find(n=>n.id===before.id),changes.has(before.id)?{...before,...changes.get(before.id).to}:before);
    assert.equal(after.filter(n=>n.is_assignable).length,1);
  });
  await check('category replay refuses stale preconditions without broadening scope',async()=>{
    const before=await taxonomyNow();await reject(categories.sql,'PILOT_TAXONOMY_DRIFT');assert.equal(await taxonomyNow(),before);
  });
  const category=categories.plan.leaves[0];
  // Existing synthetic product only. Catalog operations are not a cohort seed
  // authorization and no policy/review status is modified to make it eligible.
  await db.query('UPDATE public.products SET category_id=$1 WHERE id=$2',[category,product]);
  await db.query("NOTIFY pgrst,'reload schema'");
  let ready=false;
  for(let i=0;i<30;i++) {const r=await request('/rest/v1/rpc/merchant_catalog_categories_v1',merchant,{p_shop_id:shop});if(r.ok){ready=true;break;}await new Promise(r=>setTimeout(r,200));}
  assert(ready);
  await check('real Auth cannot self-grant roles and foreign owners cannot read operations',async()=>{
    assert.equal((await request('/rest/v1/profiles?id=eq.'+customer.id,customer,{role:'merchant'},'PATCH')).ok,false);
    for(const who of [customer,other,null]) assert.equal((await request('/rest/v1/rpc/merchant_operations_read_v1',who,{p_shop_id:shop})).ok,false);
  });
  const notification=randomUUID(),foreignNotification=randomUUID();
  await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Yerel prova','Hazırlık bildirimi','system'),($3,$4,'Yerel prova','Diğer hesap','system')",[notification,newcomer.id,foreignNotification,other.id]);
  const nonce=randomBytes(24).toString('hex');credentialFile=resolve(run.dir,'pilot-client-fixture.json');
  await writeFile(credentialFile,JSON.stringify({kind:'merchant-pilot-base-core-local',project:run.project,nonce,url:status.API_URL,key:status.ANON_KEY,
    merchant:logins.get(newcomer.id),other:logins.get(other.id),customer:logins.get(customer.id),product,category,foreign_shop:otherShop,notification,foreign_notification:foreignNotification,submission_request_id:randomUUID(),cart_id:randomUUID()}),{flag:'wx',mode:0o600});
  await check('actual Flutter repositories work after reviewed upgrade and bounded category activation',async()=>{
    const output=await command(dart,[flutterSnapshot,'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/pilot_repository_test.dart','--reporter','expanded'],root,300000,false,{MERCHANT_PILOT_LOCAL_FIXTURE:credentialFile,FLUTTER_ROOT:flutter});
    await writeFile(resolve(run.dir,'preparation-flutter.log'),output,{mode:0o600});
  });
  const client=JSON.parse(await readFile(resolve(run.dir,'pilot-client-result.json'),'utf8'));assert.equal(client.nonce,nonce);assert.equal(client.result,'PASS');assert.equal(client.checks.length,18);
  await check('runtime journey preserves reviewed schema and default-OFF gates',async()=>compareCore(afterSchema,await inspectCore(db)));
  const auth=authPlan(target,{site_url:'http://localhost:3000',redirect_urls:[],confirm_email:false,smtp_enabled:false});
  const cohort=cohortPlan(target,[{slot:'merchant-01',role:'merchant',user_id:null},{slot:'merchant-02',role:'merchant',user_id:null},{slot:'customer-01',role:'customer',user_id:null}]);
  const review=resolve(run.dir,'review');await mkdir(review);
  for(const [name,value] of Object.entries({'schema.plan.json':JSON.stringify(schema.plan,null,2),'schema.preflight.sql':schema.preflight,'schema.review.sql':schema.sql,'synthetic-category.plan.json':JSON.stringify(categories.plan,null,2),'synthetic-category.review.sql':categories.sql,'auth.plan.json':JSON.stringify(auth,null,2),'cohort.example.json':JSON.stringify(cohort,null,2)})) await writeFile(resolve(review,name),value+'\n',{flag:'wx'});
  const baseline={kind:'merchant-pilot-local-baseline-v1',target,remote_observed:false,schema_text:captured.schema_text,taxonomy_text:captured.taxonomy_text};
  await writeFile(resolve(root,'docs/data/merchant_pilot_preparation_baseline.json'),JSON.stringify(baseline,null,2)+'\n');
  const sourcePaths=['tool/merchant_acceptance/pilot_preparation_contract.mjs','tool/merchant_acceptance/pilot_preparation.mjs','tool/merchant_acceptance/pilot_hosted_profile.mjs','tool/merchant_acceptance/pilot_repository_test.dart','tool/merchant_acceptance/fixture.mjs'];
  const sources=await Promise.all(sourcePaths.map(async path=>({path,sha256_lf:digest((await readFile(resolve(root,path),'utf8')).replaceAll('\r\n','\n'))})));
  const evidence={result:'PASS',captured_at:new Date().toISOString(),baseline_commit:'55cee012db9c068e177fad4396ee22c91afcf8d6',services,baseline_migrations:applied,sources,
    checks,client_checks:client.checks,schema_plan:schema.plan,synthetic_category_plan:categories.plan,
    category_scope:'LOCAL SYNTHETIC ONLY; not a Product Owner cohort/category decision',auth_plan:auth,
    hosted_profile:hostedProfile,production_access:'NONE',remote_apply:'NOT_AUTHORIZED',remote_baseline_match:'MATCHES_CAPTURED_METADATA_ONLY',real_provisioning:'NOT_AUTHORIZED',real_email:'NOT_SENT',physical_two_device:'OPEN',distribution:'NOT_AUTHORIZED'};
  await writeFile(resolve(root,'docs/data/merchant_pilot_preparation_acceptance.json'),JSON.stringify(evidence,null,2)+'\n');
  console.log(`PILOT_PREPARATION_LOCAL_PASS: ${checks.length} groups, including one real Flutter journey with ${client.checks.length} checkpoints. Remote approval remains OPEN.`);
} catch(error) {
  console.error('PILOT_PREPARATION_FAILED at '+stage+'; no remote fallback.');
  if(db) await db.query('ROLLBACK').catch(()=>{});
  if(run) await writeFile(resolve(run.dir,'preparation-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});
  process.exitCode=1;
} finally {if(credentialFile) await unlink(credentialFile).catch(()=>{});if(db) await db.end();}
