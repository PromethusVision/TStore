import assert from 'node:assert/strict';
import {readFile,writeFile,realpath,unlink} from 'node:fs/promises';
import {resolve} from 'node:path';
import {randomUUID,randomBytes} from 'node:crypto';
import {readRun,credentials,runtimeEvidence,root,command} from './local.mjs';
import {connect,migrate} from './fixture.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression,taxonomyExpression,loadDelta,schemaPlan,projectRef,projectUrl,digest} from './pilot_preparation_contract.mjs';
import {loadRepair,repairPlan,lf} from './pilot_launch_contract.mjs';
import {inspectCore,validateCore} from './pilot_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {cohortTemplate,observationSql,boundedCategories,roleProposal,catalogReview,accountReview,postCeSchemaMd5,cohortSources} from './pilot_cohort_contract.mjs';

let run,db,credentialFile,stage='arguments';
try{
 assert.equal(process.argv.length,4,'Provide new owned run and Flutter SDK directory only');
 run=await readRun(process.argv[2]);const flutter=await realpath(process.argv[3]);
 const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
 const flutterSnapshot=await realpath(resolve(flutter,'bin/cache/flutter_tools.snapshot'));
 const status=await credentials(run),services=await runtimeEvidence(run),url=localUrl(status.DB_URL,'db');
 const config={host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false};
 db=await connect(config);const target={project_ref:projectRef,project_url:projectUrl},checks=[];
 const scalar=async sql=>(await db.query(sql)).rows[0].value;
 const schemaNow=()=>scalar(`SELECT (${schemaExpression})::text value`);
 const taxonomyNow=()=>scalar(`SELECT (${taxonomyExpression})::text value`);
 const token=value=>db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[value]);
 const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
 async function check(name,fn){stage=name;await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);}
 async function reject(sql,message){try{await assert.rejects(db.query(sql),e=>e.message.includes(message));}finally{await db.query('ROLLBACK');}}
 async function observation(input){const result=await db.query(observationSql(input));return JSON.parse(result.find(r=>r.rows?.[0]?.observation_text)?.rows[0].observation_text);}
 const stateHash=()=>scalar(`SELECT md5(jsonb_build_object('profiles',(SELECT jsonb_agg(to_jsonb(p) ORDER BY id) FROM public.profiles p),'shops',(SELECT jsonb_agg(to_jsonb(s) ORDER BY id) FROM public.shops s),'taxonomy',${taxonomyExpression},'products',(SELECT jsonb_agg(to_jsonb(p) ORDER BY id) FROM public.products p))::text) value`);
 stage='reproduce exact installed Development structure';
 const migrations=await migrate(db,{coreOnly:true,baselineOnly:true});await mirrorHostedProfile(db);
 const upgrade=schemaPlan(target,await schemaNow(),await loadDelta(root));await token(upgrade.plan.sha256);await db.query(upgrade.sql);await mirrorPostAProfile(db);
 const previous=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
 const repair=repairPlan(target,previous,await loadRepair(root));await token(repair.plan.sha256);await db.query(repair.sql);
 const beforeSchema=await schemaNow(),taxonomy=await taxonomyNow();
 await check('exact post-C/E local structure, private Storage and decisions OFF',async()=>{assert.equal(digest(beforeSchema,'md5'),postCeSchemaMd5);validateCore(await inspectCore(db));});
 const actors=[],logins=new Map();
 for(let i=0;i<4;i++){
  const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
  const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});assert.equal(created.status,200);
  const signed=await request('/auth/v1/token?grant_type=password',null,login);assert.equal(signed.status,200);
  actors.push({id:created.data.id,token:signed.data.access_token});logins.set(created.data.id,login);
 }
 const [merchant,other,customer,newcomer]=actors;
 const input=cohortTemplate();input.accounts=[merchant,other,newcomer].map((a,i)=>({slot:'merchant-0'+(i+1),role:'merchant',user_id:a.id,identity_review_ref:'synthetic-local-review'}));
 input.accounts.push({slot:'customer-01',role:'customer',user_id:customer.id,identity_review_ref:'synthetic-local-review'});
 const eligible=categoryInventory(target,taxonomy).filter(x=>x.eligible);const leaves=[eligible[0].id,eligible.find(x=>x.path[0]!==eligible[0].path[0]).id];input.category_leaf_ids=leaves;
 input.products=[{slot:'product-01',merchant_slot:'merchant-03',kind:'physical_good',name:'Local acceptance kalem',brand:'',model:'',variant:'',gtin:'0000000000017',category_id:leaves[0],existing_product_id:null,evidence_ref:'synthetic-local-product'}];
 const empty=await observation(input);
 await check('empty actual catalog blocks new materialization without inventing a price',async()=>{const r=catalogReview(target,taxonomy,input,empty);assert.equal(r.items[0].status,'NEW_PRODUCT_MATERIALIZATION_BLOCKED');assert.equal(r.publication_sql_generated,false);assert.equal(await scalar('SELECT count(*)::int value FROM public.products'),0);});
 // Synthetic EXISTING catalog fixture only. This is not a materializer or a
 // remote proposal. No policy or review metadata is overridden for this fixture.
 const product=randomUUID(),category=leaves[0];
 await db.query('INSERT INTO public.products(id,name,price,category_id) VALUES($1,$2,8,$3)',[product,input.products[0].name,category]);
 await db.query("INSERT INTO public.product_identity(product_id,product_type,normalized_name) VALUES($1,'shared_catalog_product',public.catalog_normalize_v1($2))",[product,input.products[0].name]);
 await db.query('INSERT INTO public.product_identifiers(gtin,product_id) VALUES(public.catalog_gtin_v1($1),$2)',[input.products[0].gtin,product]);
 const before=await observation(input);input.products[0].existing_product_id=product;
 const b=boundedCategories(target,taxonomy,before,leaves),d=roleProposal(target,taxonomy,input,before),initialData=await stateHash();
 await check('existing product requires explicit identity selection and exposes latent category effects',async()=>{assert.equal(catalogReview(target,taxonomy,input,before).ready_for_listing_review,true);assert.deepEqual(b.plan.potentially_exposed_products,[product]);const shared=structuredClone(input);shared.products.push({...shared.products[0],slot:'product-02',merchant_slot:'merchant-01'});assert.equal(catalogReview(target,taxonomy,shared,before).ready_for_listing_review,true);const altered=structuredClone(input);altered.products[0].variant='wrong';assert.equal(catalogReview(target,taxonomy,altered,before).items[0].status,'CATALOG_IDENTITY_MISMATCH');altered.products[0].kind='service';assert.equal(catalogReview(target,taxonomy,altered,before).items[0].status,'SERVICES_OUT_OF_SCOPE');});
 await check('missing, wrong, old repair and cross-item approval tokens cannot mutate',async()=>{
  for(const candidate of [b,d])for(const value of ['',repair.plan.sha256,candidate===b?d.plan.sha256:b.plan.sha256]){await token(value);await reject(candidate.sql,'PILOT_REVIEW_NOT_APPROVED');assert.equal(await stateHash(),initialData);}
 });
 await check('schema permission drift rejects both candidates',async()=>{
  for(const candidate of [b,d]){await token(candidate.plan.sha256);await db.query('BEGIN');await db.query('GRANT INSERT ON public.notifications TO authenticated');await reject(candidate.sql,'PILOT_SCHEMA_DRIFT');assert.equal(await schemaNow(),beforeSchema);}
 });
 await check('unconfirmed, banned, changed profile, administrator and new shop drift reject roles',async()=>{
  await token(d.plan.sha256);
  for(const [sql,args] of [["UPDATE auth.users SET email_confirmed_at=NULL WHERE id=$1",[merchant.id]],
   ["UPDATE auth.users SET banned_until=now()+interval '1 day' WHERE id=$1",[merchant.id]],
   ["UPDATE public.profiles SET full_name='changed' WHERE id=$1",[merchant.id]],
   ["UPDATE public.profiles SET role='admin' WHERE id=$1",[merchant.id]],
   ["INSERT INTO public.shops(owner_user_id,name) VALUES($1,'Race shop')",[merchant.id]]]){
   await db.query('BEGIN');await db.query(sql,args);await reject(d.sql,'PILOT_ACCOUNT_DRIFT');assert.equal(await stateHash(),initialData);
  }
 });
 await check('category policy and hidden catalog drift abort activation',async()=>{
  await token(b.plan.sha256);
  for(const [sql,args] of [["UPDATE public.categories SET professional_review_status='pending' WHERE id=$1",[category]],
   ["UPDATE public.products SET name='changed catalog' WHERE id=$1",[product]]]){
   await db.query('BEGIN');await db.query(sql,args);await reject(b.sql,'PILOT_DATA_DRIFT');assert.equal(await stateHash(),initialData);
  }
 });
 await check('concurrent cohort writer rejects both plans before writes',async()=>{
  const peer=await connect(config);try{await peer.query('BEGIN');await peer.query("SELECT pg_advisory_xact_lock(hashtextextended($1,0))",['esnaftavar:'+projectRef+':pilot-cohort']);for(const candidate of [b,d]){await token(candidate.plan.sha256);await reject(candidate.sql,'PILOT_COMPETING_WRITER');}}
  finally{await peer.query('ROLLBACK');await peer.end();}assert.equal(await stateHash(),initialData);
 });
 await check('late failure rolls back all roles and all selected ancestors',async()=>{
  for(const candidate of [b,d]){await token(candidate.plan.sha256);const fault=candidate.sql.replace(/COMMIT;\n$/,'SELECT 1/0;\nCOMMIT;\n');assert.notEqual(fault,candidate.sql);await reject(fault,'division by zero');assert.equal(await stateHash(),initialData);}
 });
 await check('bounded category apply preserves every unselected node and review field',async()=>{
  await token(b.plan.sha256);await db.query(b.sql);const changes=new Map(b.plan.changes.map(c=>[c.id,c]));
  const after=JSON.parse(await taxonomyNow());for(const n of JSON.parse(taxonomy))assert.deepEqual(after.find(x=>x.id===n.id),changes.has(n.id)?{...n,...changes.get(n.id).to}:n);
  assert.equal(after.filter(n=>n.is_assignable).length,2);assert.equal((await observation(input)).catalog[0].public_eligible,true);
 });
 await check('category replay refuses changed taxonomy instead of broadening activation',async()=>{const current=await stateHash();await reject(b.sql,'PILOT_DATA_DRIFT');assert.equal(await stateHash(),current);});
 await check('exact existing-account role apply preserves Auth and non-role profile fields',async()=>{
  const oldAuth=await scalar("SELECT md5(jsonb_agg(to_jsonb(u) ORDER BY id)::text) value FROM auth.users u");
  const oldProfiles=await scalar("SELECT md5(jsonb_agg(to_jsonb(p)-'role'-'updated_at' ORDER BY id)::text) value FROM public.profiles p");
  await token(d.plan.sha256);await db.query(d.sql);
  assert.equal(await scalar("SELECT md5(jsonb_agg(to_jsonb(u) ORDER BY id)::text) value FROM auth.users u"),oldAuth);
  assert.equal(await scalar("SELECT md5(jsonb_agg(to_jsonb(p)-'role'-'updated_at' ORDER BY id)::text) value FROM public.profiles p"),oldProfiles);
  assert.equal(await scalar("SELECT count(*)::int value FROM public.profiles WHERE role='merchant'"),3);
  assert.equal((await db.query('SELECT role FROM public.profiles WHERE id=$1',[customer.id])).rows[0].role,'customer');
 });
 await check('role replay refuses stale profile state',async()=>{const current=await stateHash();await reject(d.sql,'PILOT_ACCOUNT_DRIFT');assert.equal(await stateHash(),current);});
 await check('real Auth clients cannot self-promote or assign administrator',async()=>{for(const actor of [customer,merchant])for(const role of ['merchant','admin']){if(actor===merchant&&role==='merchant')continue;assert(!(await request('/rest/v1/profiles?id=eq.'+actor.id,actor,{role},'PATCH')).ok);}assert(!(await request('/rest/v1/shops',customer,{owner_user_id:customer.id,name:'Forbidden'})).ok);});
 const shop=randomUUID(),otherShop=randomUUID();
 await check('onboarding uses authenticated owner flow; no operator shop reassignment',async()=>{
  assert((await request('/rest/v1/shops',merchant,{id:shop,owner_user_id:merchant.id,name:'Local Esnaf A'})).ok);
  assert((await request('/rest/v1/shops',other,{id:otherShop,owner_user_id:other.id,name:'Local Esnaf B'})).ok);
  assert(!(await request('/rest/v1/shops',merchant,{owner_user_id:other.id,name:'Forbidden'})).ok);
  assert(!(await request('/rest/v1/shops',merchant,{owner_user_id:merchant.id,name:'Second shop'})).ok);
 });
 await db.query("NOTIFY pgrst,'reload schema'");let ready=false;
 for(let i=0;i<30;i++){const r=await request('/rest/v1/rpc/merchant_catalog_categories_v1',merchant,{p_shop_id:shop});if(r.ok){ready=true;break;}await new Promise(r=>setTimeout(r,200));}assert(ready);
 await check('catalog and operations are exact-owner scoped through actual HTTP',async()=>{
  const r=await request('/rest/v1/rpc/merchant_catalog_search_v1',merchant,{p_shop_id:shop});assert(r.ok);assert(r.data.some(p=>p.id===product));
  for(const actor of [other,customer,null])assert(!(await request('/rest/v1/rpc/merchant_operations_read_v1',actor,{p_shop_id:shop})).ok);
  assert(!(await request('/rest/v1/shop_products',other,{shop_id:shop,product_id:product,price:12})).ok);
 });
 await check('actual GTIN uniqueness and normalisation retain existing identity',async()=>{
  await assert.rejects(db.query('INSERT INTO public.product_identifiers(gtin,product_id) VALUES(public.catalog_gtin_v1($1),$2)',[input.products[0].gtin,product]),e=>e.code==='23505');
  const lookup=await request('/rest/v1/rpc/merchant_catalog_lookup_v1',merchant,{p_shop_id:shop,p_gtin:input.products[0].gtin});assert(lookup.ok);assert.equal(lookup.data.exact,true);assert.equal(lookup.data.products[0].id,product);
  assert.equal(await scalar("SELECT public.catalog_normalize_v1('  İI KALEM  ') value"),'ii kalem');
 });
 const notification=randomUUID(),foreignNotification=randomUUID();
 await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Yerel prova','Katılım bildirimi','system'),($3,$4,'Yerel prova','Diğer hesap','system')",[notification,newcomer.id,foreignNotification,other.id]);
 const nonce=randomBytes(24).toString('hex');credentialFile=resolve(run.dir,'pilot-client-fixture.json');
 await writeFile(credentialFile,JSON.stringify({kind:'merchant-pilot-base-core-local',project:run.project,nonce,url:status.API_URL,key:status.ANON_KEY,merchant:logins.get(newcomer.id),other:logins.get(other.id),customer:logins.get(customer.id),product,category,foreign_shop:otherShop,notification,foreign_notification:foreignNotification,submission_request_id:randomUUID(),cart_id:randomUUID()}),{flag:'wx',mode:0o600});
 await check('real Flutter repositories complete onboarding/listing/photo/Customer/purchase journey',async()=>{
  const result=await command(dart,[flutterSnapshot,'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/pilot_repository_test.dart','--reporter','expanded'],root,300000,false,{MERCHANT_PILOT_LOCAL_FIXTURE:credentialFile,FLUTTER_ROOT:flutter});await writeFile(resolve(run.dir,'cohort-flutter.log'),result,{mode:0o600});
 });
 const client=JSON.parse(await readFile(resolve(run.dir,'pilot-client-result.json'),'utf8'));assert.equal(client.nonce,nonce);assert.equal(client.result,'PASS');assert.equal(client.checks.length,18);
 await check('catalog decisions remain OFF and new submissions stay unpublished',async()=>{
  assert.equal(await scalar('SELECT count(*)::int value FROM public.product_submissions WHERE status=\'pending\''),1);
  assert.equal(await scalar('SELECT count(*)::int value FROM public.product_submission_decisions'),0);
  const pending=await scalar('SELECT id value FROM public.product_submissions LIMIT 1');
  const response=await requestJson(status.API_URL,'/rest/v1/rpc/decide_catalog_submission_v1',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{p_submission_id:pending,p_status:'approved',p_product_id:product,p_reason:'Local denied probe'});assert(!response.ok);
 });
 await check('journey preserves installed schema, fourteen ledger entries and catalog boundary',async()=>{
  assert.equal(await schemaNow(),beforeSchema);assert.equal(await scalar('SELECT count(*)::int value FROM public.products'),1);assert.equal(await scalar('SELECT count(*)::int value FROM public.verified_transactions'),1);assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);
 });
 assert.equal(checks.length,20);
 const sources=await Promise.all(cohortSources.map(async path=>({path,sha256_lf:digest(lf(await readFile(resolve(root,path),'utf8')))})));
 const evidence={kind:'merchant-pilot-cohort-local-only-v1',result:'PASS',captured_at:new Date().toISOString(),post_ce_schema_md5:postCeSchemaMd5,
  input_scope:'Synthetic existing accounts and existing product only; no real participant/category decision',remote_access:'NONE',production_writes:'NONE',new_catalog_materialization:'NOT_IMPLEMENTED; blocked rather than fabricated',
  migrations,sources,services,checks,client_checks:client.checks,physical_two_device:'OPEN',distribution_ready:false};
 await writeFile(resolve(root,'docs/data/merchant_pilot_cohort_acceptance.json'),JSON.stringify(evidence,null,2)+'\n');
 console.log('PILOT_COHORT_LOCAL_PASS: 20 groups + 18 actual repository checkpoints; no remote writes.');
}catch(error){console.error('PILOT_COHORT_LOCAL_FAILED at '+stage+'; no remote fallback.');if(run)await writeFile(resolve(run.dir,'cohort-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});process.exitCode=1;}
finally{if(credentialFile)await unlink(credentialFile).catch(()=>{});if(db)await db.end().catch(()=>{});}
