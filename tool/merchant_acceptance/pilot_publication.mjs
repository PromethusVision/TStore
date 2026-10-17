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
import {loadRepair,repairPlan} from './pilot_launch_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {cohortTemplate,observationSql,boundedCategories,roleProposal,postCeSchemaMd5} from './pilot_cohort_contract.mjs';
import {publicationSources,publicationTemplate,loadPublication,publicationSchemaPlan,publicationPlan,publicationObservationSql,postPublicationCohortPlans,lf} from './pilot_publication_contract.mjs';
let run,db,credentialFile,stage='arguments';
try{
 assert.equal(process.argv.length,4);run=await readRun(process.argv[2]);const flutter=await realpath(process.argv[3]);
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
 async function observe(sql){const results=await db.query(sql);return JSON.parse(results.find(r=>r.rows?.[0]?.observation_text)?.rows[0].observation_text);}
 const migrations=await migrate(db,{coreOnly:true,baselineOnly:true});await mirrorHostedProfile(db);
 const upgrade=schemaPlan(target,await schemaNow(),await loadDelta(root));await token(upgrade.plan.sha256);await db.query(upgrade.sql);await mirrorPostAProfile(db);
 const previous=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
 const repair=repairPlan(target,previous,await loadRepair(root));await token(repair.plan.sha256);await db.query(repair.sql);
 await check('exact installed post-C/E structure is reproduced without remote access',async()=>assert.equal(digest(await schemaNow(),'md5'),postCeSchemaMd5));
 const actors=[],logins=new Map();
 for(let i=0;i<5;i++){
  const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
  const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});assert.equal(created.status,200);
  const signed=await request('/auth/v1/token?grant_type=password',null,login);assert.equal(signed.status,200);
  actors.push({id:created.data.id,token:signed.data.access_token});logins.set(created.data.id,login);
 }
 const [merchant,other,customer,newcomer]=actors;
 const intake=cohortTemplate();intake.accounts=[merchant,other,newcomer].map((a,i)=>({slot:'merchant-0'+(i+1),role:'merchant',user_id:a.id,identity_review_ref:'synthetic-local-review'}));
 intake.accounts.push({slot:'customer-01',role:'customer',user_id:customer.id,identity_review_ref:'synthetic-local-review'});
 const taxonomy=await taxonomyNow(),category=categoryInventory(target,taxonomy).find(x=>x.eligible).id;intake.category_leaf_ids=[category];
 const initial=await observe(observationSql(intake));const categories=boundedCategories(target,taxonomy,initial,[category]),roles=roleProposal(target,taxonomy,intake,initial);
 await token(categories.plan.sha256);await db.query(categories.sql);await token(roles.plan.sha256);await db.query(roles.sql);
 const shop=randomUUID(),otherShop=randomUUID();
 for(const [actor,id] of [[merchant,shop],[other,otherShop]])assert((await request('/rest/v1/shops',actor,{id,owner_user_id:actor.id,name:'Local publication shop'})).ok);
 const source=await loadPublication(root),installation=publicationSchemaPlan(target,source);
 await check('schema installation refuses wrong and missing approval tokens',async()=>{for(const t of ['',repair.plan.sha256]){await token(t);await reject(installation.sql,'PUBLICATION_REVIEW_NOT_APPROVED');}assert.equal(digest(await schemaNow(),'md5'),postCeSchemaMd5);});
 await check('failed schema transaction leaves no new object or ledger entry',async()=>{await token(installation.plan.sha256);await reject(installation.sql.replace(/COMMIT;\s*$/, ()=>"DO $fail$ BEGIN RAISE EXCEPTION 'LOCAL_INJECTED_FAILURE'; END $fail$; COMMIT;"),'LOCAL_INJECTED_FAILURE');assert.equal(digest(await schemaNow(),'md5'),postCeSchemaMd5);});
 await check('schema installs privately with existing decisions switch OFF',async()=>{await db.query(installation.sql);assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);assert.equal(await scalar('SELECT count(*)::int value FROM supabase_migrations.schema_migrations'),15);});
 const installedSchema=await schemaNow(),installedMd5=digest(installedSchema,'md5');
 await check('schema replay and unexpected permission drift are refused',async()=>{await reject(installation.sql,'PUBLICATION_SCHEMA_DRIFT');await db.query('BEGIN');await db.query('GRANT INSERT ON public.notifications TO authenticated');await reject(installation.sql,'PUBLICATION_SCHEMA_DRIFT');assert.equal(await schemaNow(),installedSchema);});
 const follow=cohortTemplate();follow.accounts=[{slot:'merchant-01',role:'merchant',user_id:actors[4].id,identity_review_ref:'local-next-cohort'},{slot:'customer-01',role:'customer',user_id:customer.id,identity_review_ref:'local-next-cohort'}];
 const inventory=categoryInventory(target,taxonomy);const firstRoot=inventory.find(x=>x.id===category).path[0];follow.category_leaf_ids=[inventory.find(x=>x.eligible&&x.path[0]!==firstRoot).id];
 const nextTaxonomy=await taxonomyNow(),nextObservation=await observe(observationSql(follow));
 const nextPlans=postPublicationCohortPlans(target,nextTaxonomy,follow,nextObservation,installedMd5);
 await check('post-install cohort proposals require the exact new schema and distinct approval',async()=>{assert.throws(()=>postPublicationCohortPlans(target,nextTaxonomy,follow,{...nextObservation,schema_md5:postCeSchemaMd5},installedMd5));for(const p of Object.values(nextPlans)){assert(p);await token(installation.plan.sha256);await reject(p.sql,'PILOT_REVIEW_NOT_APPROVED');assert.equal(p.plan.baseline_schema_md5,installedMd5);}});
 await check('existing category and account preparation still works after publication schema',async()=>{for(const p of Object.values(nextPlans)){await token(p.plan.sha256);await db.query(p.sql);}assert.equal((await db.query('SELECT role FROM public.profiles WHERE id=$1',[actors[4].id])).rows[0].role,'merchant');assert.equal((await db.query('SELECT public._catalog_category_allowed_v1($1) allowed',[follow.category_leaf_ids[0]])).rows[0].allowed,true);assert.equal(await schemaNow(),installedSchema);});
 // A legacy product is deliberately retained to prove no backfill/repricing.
 const legacy=randomUUID();await db.query("INSERT INTO public.products(id,name,price,sale_price,stock,category_id) VALUES($1,'Legacy fixture',49,40,3,$2)",[legacy,category]);
 await db.query("INSERT INTO public.product_identity(product_id,product_type,normalized_name) VALUES($1,'shared_catalog_product','legacy fixture')",[legacy]);
 await db.query("NOTIFY pgrst,'reload schema'");let ready=false;
 for(let i=0;i<30;i++){if((await request('/rest/v1/rpc/merchant_catalog_categories_v1',merchant,{p_shop_id:shop})).ok){ready=true;break;}await new Promise(r=>setTimeout(r,200));}assert(ready);
 const draft={name:"Local acceptance $publish$ ' kalem",brand:'Local Brand',model:'P1',variant:'Blue',gtin:'0000000000017',canonical_category_id:category,product_type:'shared_catalog_product'};
 async function submit(actor,shopId,changes={}){const r=await request('/rest/v1/rpc/merchant_submit_product_v1',actor,{p_shop_id:shopId,p_request_id:randomUUID(),p_draft:{...draft,...changes}});assert(r.ok);assert(r.data.submission);return r.data.submission.id;}
 const first=await submit(merchant,shop),second=await submit(other,otherShop),product=randomUUID(),brand=randomUUID();
 const input={...publicationTemplate(),batch_id:randomUUID(),compatibility_review_ref:'local-compatible-client-proof',items:[
  {submission_id:first,product_id:product,brand_id:brand,create:true,kind:'physical_good',review_ref:'local-physical-review'},
  {submission_id:second,product_id:product,brand_id:brand,create:false,kind:'physical_good',review_ref:'local-physical-review'}]};
 const observation=await observe(publicationObservationSql(input)),candidate=publicationPlan(target,input,observation,installedMd5);
 const stateHash=()=>scalar(`SELECT md5(jsonb_build_object('products',(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM public.products x),'brands',(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM public.brands x),'identity',(SELECT jsonb_agg(to_jsonb(x) ORDER BY product_id) FROM public.product_identity x),'gtin',(SELECT jsonb_agg(to_jsonb(x) ORDER BY gtin) FROM public.product_identifiers x),'submissions',(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM public.product_submissions x),'decisions',(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM public.product_submission_decisions x),'receipts',(SELECT jsonb_agg(to_jsonb(x) ORDER BY id) FROM public.catalog_publication_batches x))::text) value`);
 const before=await stateHash();
 await check('anon, customer, merchant and service role cannot invoke private publication',async()=>{
  for(const role of ['anon','authenticated','service_role']){assert.equal(await scalar(`SELECT has_function_privilege('${role}','public._publish_catalog_submission_v1(uuid,uuid,uuid,boolean,text)','EXECUTE') value`),false);for(const privilege of ['SELECT','INSERT','UPDATE','DELETE'])assert.equal(await scalar(`SELECT has_table_privilege('${role}','public.catalog_publication_batches','${privilege}') value`),false);}
  for(const actor of [null,customer,merchant,{token:status.SERVICE_ROLE_KEY}])assert(!(await request('/rest/v1/rpc/_publish_catalog_submission_v1',actor,{p_submission:first,p_product:product,p_brand:brand,p_create:true,p_review:'forbidden'})).ok);
  assert.equal(await stateHash(),before);
 });
 await check('publication requires its own exact token, never the schema or cohort token',async()=>{for(const t of ['',installation.plan.sha256,categories.plan.sha256]){await token(t);await reject(candidate.sql,'PUBLICATION_REVIEW_NOT_APPROVED');assert.equal(await stateHash(),before);}});
 await check('permission drift blocks a reviewed publication',async()=>{await token(candidate.plan.sha256);await db.query('BEGIN');await db.query('GRANT INSERT ON public.notifications TO authenticated');await reject(candidate.sql,'PUBLICATION_SCHEMA_DRIFT');assert.equal(await schemaNow(),installedSchema);});
 await check('category, submission, catalog and owner drift abort without partial rows',async()=>{
  for(const [sql,args] of [["UPDATE public.categories SET is_active=false WHERE id=$1",[category]],
   ["UPDATE public.product_submissions SET variant='changed' WHERE id=$1",[first]],
   ["UPDATE public.products SET price=50 WHERE id=$1",[legacy]],
   ["UPDATE public.shops SET is_active=false WHERE id=$1",[shop]],
   ["UPDATE public.profiles SET role='customer' WHERE id=$1",[merchant.id]],
   ["UPDATE auth.users SET banned_until=now()+interval '1 day' WHERE id=$1",[merchant.id]],
   ["UPDATE auth.users SET email_confirmed_at=NULL WHERE id=$1",[merchant.id]]]){
    await db.query('BEGIN');await db.query(sql,args);await reject(candidate.sql,'PUBLICATION_DATA_DRIFT');assert.equal(await stateHash(),before);
  }
 });
 await check('competing batch is refused and the first batch remains untouched',async()=>{const peer=await connect(config);try{await peer.query('BEGIN');await peer.query("SELECT pg_advisory_xact_lock(hashtextextended('esnaftavar:pilot-catalog-publication',0))");await reject(candidate.sql,'PUBLICATION_COMPETING_WRITER');assert.equal(await stateHash(),before);}finally{await peer.query('ROLLBACK');await peer.end();}});
 await check('concurrent Auth change cannot race the publication authority check',async()=>{const peer=await connect(config);try{await peer.query('BEGIN');await peer.query('UPDATE auth.users SET banned_until=now()+interval \'1 day\' WHERE id=$1',[merchant.id]);await reject(candidate.sql,'lock timeout');assert.equal(await stateHash(),before);}finally{await peer.query('ROLLBACK');await peer.end();}});
 async function invalidBatch(change,error){const changed=structuredClone(input);changed.batch_id=randomUUID();change(changed);const p=publicationPlan(target,changed,observation,installedMd5);await token(p.plan.sha256);await reject(p.sql,error);assert.equal(await stateHash(),before);}
 await check('different target for the same GTIN rolls back first product, brand and decision',async()=>invalidBatch(x=>{x.items[1].create=true;x.items[1].product_id=randomUUID();},'PUBLICATION_GTIN_CONFLICT'));
 await check('wrong explicit existing identity cannot be approved',async()=>invalidBatch(x=>{x.items[0].create=false;x.items[0].product_id=legacy;},'PUBLICATION_EXISTING_IDENTITY_MISMATCH'));
 await check('missing brand and occupied product UUID are rejected',async()=>{await invalidBatch(x=>x.items[0].brand_id=null,'PUBLICATION_BRAND_REQUIRED');await invalidBatch(x=>x.items[0].product_id=legacy,'PUBLICATION_PRODUCT_EXISTS');});
 await check('two reviewed submissions publish one shared identity atomically; hostile text stays data',async()=>{await token(candidate.plan.sha256);await db.query(candidate.sql);assert.equal(await scalar('SELECT count(*)::int value FROM public.products'),2);assert.equal(await scalar('SELECT count(*)::int value FROM public.product_submission_decisions'),2);assert.equal(await scalar('SELECT count(*)::int value FROM public.shop_products'),0);const p=(await db.query('SELECT * FROM public.products WHERE id=$1',[product])).rows[0];assert.equal(p.name,draft.name);assert.equal(Number(p.price),0);assert.equal(p.sale_price,null);assert.deepEqual(p.attributes,{_catalog_price_contract:'listing_only_v1'});});
 await check('lost acknowledgement is resolved by durable read-only receipt; replay cannot duplicate',async()=>{const h=await stateHash();await reject(candidate.sql,'PUBLICATION_ALREADY_APPLIED_CHECK_RECEIPT');const rows=await db.query(candidate.receipt);assert.equal(rows.find(r=>r.rows?.[0]?.plan_sha256)?.rows[0].plan_sha256,candidate.plan.sha256);assert.equal(await stateHash(),h);});
 await check('publication receipt is append-only',async()=>{for(const sql of ['UPDATE public.catalog_publication_batches SET created_at=now()','DELETE FROM public.catalog_publication_batches'])await assert.rejects(db.query(sql),e=>e.message==='PUBLICATION_RECEIPT_IMMUTABLE');});
 await check('tagged price, discount, stock and metadata removal cannot become legacy truth',async()=>{for(const change of ["price=25","sale_price=0","stock=1","attributes=NULL","attributes='{}'","attributes='{\"_catalog_price_contract\":null}'"]){await assert.rejects(db.query('UPDATE public.products SET '+change+' WHERE id=$1',[product]),e=>e.message.startsWith('CATALOG_PRICE_CONTRACT_'));}const old=(await db.query('SELECT price,sale_price,stock,attributes FROM public.products WHERE id=$1',[legacy])).rows[0];assert.deepEqual(old,{price:'49.00',sale_price:'40.00',stock:3,attributes:null});});
 await check('actual HTTP lookup preserves GTIN identity and price metadata for both shops',async()=>{for(const [a,s] of [[merchant,shop],[other,otherShop]]){const r=await request('/rest/v1/rpc/merchant_catalog_lookup_v1',a,{p_shop_id:s,p_gtin:draft.gtin});assert(r.ok&&r.data.exact);assert.equal(r.data.products[0].id,product);assert.equal(r.data.products[0].attributes._catalog_price_contract,'listing_only_v1');}const rows=await request('/rest/v1/products?id=eq.'+product,customer,undefined,'GET');assert(rows.ok);assert.equal(rows.data[0].attributes._catalog_price_contract,'listing_only_v1');});
 // Unique identity ownership remains enforced even through the private operator.
 const uniqueFirst=await submit(merchant,shop,{name:'Unique fixture',brand:'',model:'',variant:'',gtin:null,product_type:'merchant_unique_product'});
 const uniqueSecond=await submit(other,otherShop,{name:'Unique fixture',brand:'',model:'',variant:'',gtin:null,product_type:'merchant_unique_product'});
 const uniqueId=randomUUID();const unique={...input,batch_id:randomUUID(),items:[{...input.items[0],submission_id:uniqueFirst,product_id:uniqueId,brand_id:null},{...input.items[1],submission_id:uniqueSecond,product_id:uniqueId,brand_id:null}]};
 let up=publicationPlan(target,unique,await observe(publicationObservationSql(unique)),installedMd5);
 await check('unique product cannot be appropriated by a second shop; entire batch rolls back',async()=>{const h=await stateHash();await token(up.plan.sha256);await reject(up.sql,'PUBLICATION_EXISTING_IDENTITY_MISMATCH');assert.equal(await stateHash(),h);});
 unique.items.pop();up=publicationPlan(target,unique,await observe(publicationObservationSql(unique)),installedMd5);await token(up.plan.sha256);await db.query(up.sql);
 await check('unique product publication retains origin and other-shop listing denial',async()=>{const r=await request('/rest/v1/rpc/merchant_catalog_search_v1',other,{p_shop_id:otherShop});assert(r.ok&&!r.data.some(p=>p.id===uniqueId));assert(!(await request('/rest/v1/shop_products',other,{shop_id:otherShop,product_id:uniqueId,price:99})).ok);});
 const similar=await submit(merchant,shop,{gtin:null});
 const same={...input,batch_id:randomUUID(),items:[{...input.items[0],submission_id:similar,product_id:randomUUID()}]};
 await check('unbarcoded similarity requires explicit existing identity instead of duplicate creation',async()=>{const h=await stateHash();const p=publicationPlan(target,same,await observe(publicationObservationSql(same)),installedMd5);await token(p.plan.sha256);await reject(p.sql,'PUBLICATION_EXISTING_SELECTION_REQUIRED');assert.equal(await stateHash(),h);same.items[0].create=false;same.items[0].product_id=product;const selected=publicationPlan(target,same,await observe(publicationObservationSql(same)),installedMd5);await token(selected.plan.sha256);await db.query(selected.sql);assert.equal((await db.query('SELECT approved_product_id FROM public.product_submissions WHERE id=$1',[similar])).rows[0].approved_product_id,product);});
 const brandCandidate=await submit(merchant,shop,{name:'Local second pen',gtin:null});
 const brandInput={...input,batch_id:randomUUID(),items:[{...input.items[0],submission_id:brandCandidate,product_id:randomUUID(),brand_id:randomUUID()}]};
 await check('new brand UUID cannot duplicate an already named brand',async()=>{const h=await stateHash();const p=publicationPlan(target,brandInput,await observe(publicationObservationSql(brandInput)),installedMd5);await token(p.plan.sha256);await reject(p.sql,'PUBLICATION_BRAND_SELECTION_REQUIRED');assert.equal(await stateHash(),h);});
 const legacyCandidate=await submit(merchant,shop,{name:'Legacy fixture',brand:'',model:'',variant:'',gtin:null});
 const legacyInput={...input,batch_id:randomUUID(),items:[{...input.items[0],submission_id:legacyCandidate,product_id:legacy,brand_id:null,create:false}]};
 await check('explicit legacy product approval preserves old price, stock and untagged semantics',async()=>{const before=(await db.query('SELECT to_jsonb(p) value FROM public.products p WHERE id=$1',[legacy])).rows[0].value;const p=publicationPlan(target,legacyInput,await observe(publicationObservationSql(legacyInput)),installedMd5);await token(p.plan.sha256);await db.query(p.sql);assert.deepEqual((await db.query('SELECT to_jsonb(p) value FROM public.products p WHERE id=$1',[legacy])).rows[0].value,before);});
 const notification=randomUUID(),foreignNotification=randomUUID();await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Yerel prova','Katılım bildirimi','system'),($3,$4,'Yerel prova','Diğer hesap','system')",[notification,newcomer.id,foreignNotification,other.id]);
 const nonce=randomBytes(24).toString('hex');credentialFile=resolve(run.dir,'pilot-client-fixture.json');
 await writeFile(credentialFile,JSON.stringify({kind:'merchant-pilot-base-core-local',project:run.project,nonce,url:status.API_URL,key:status.ANON_KEY,merchant:logins.get(newcomer.id),other:logins.get(other.id),customer:logins.get(customer.id),product,category,foreign_shop:otherShop,notification,foreign_notification:foreignNotification,submission_request_id:randomUUID(),cart_id:randomUUID()}),{flag:'wx',mode:0o600});
 await check('newly published tagged product passes actual Flutter listing/media/fresh-session/QR journey',async()=>{const result=await command(dart,[flutterSnapshot,'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/pilot_repository_test.dart','--reporter','expanded'],root,300000,false,{MERCHANT_PILOT_LOCAL_FIXTURE:credentialFile,FLUTTER_ROOT:flutter});await writeFile(resolve(run.dir,'publication-flutter.log'),result,{mode:0o600});});
 const client=JSON.parse(await readFile(resolve(run.dir,'pilot-client-result.json'),'utf8'));assert.equal(client.nonce,nonce);assert.equal(client.result,'PASS');assert.equal(client.checks.length,18);
 await check('listing price and purchase snapshots stay independent of tagged catalog zero',async()=>{assert.equal(await scalar('SELECT count(*)::int value FROM public.verified_transactions'),1);const prices=(await db.query('SELECT price FROM public.shop_products WHERE product_id=$1',[product])).rows;assert(prices.length&&prices.every(x=>Number(x.price)>0));assert.equal(Number((await db.query('SELECT price FROM public.products WHERE id=$1',[product])).rows[0].price),0);});
 await check('legacy decision API remains disabled; installation and taxonomy stay unchanged',async()=>{const r=await requestJson(status.API_URL,'/rest/v1/rpc/decide_catalog_submission_v1',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{p_submission_id:uniqueSecond,p_status:'approved',p_product_id:uniqueId,p_reason:'Denied'});assert(!r.ok);assert.equal(await schemaNow(),installedSchema);assert.equal(digest(await taxonomyNow(),'md5'),observation.taxonomy_md5);assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);});
 const sources=await Promise.all(publicationSources.map(async path=>({path,sha256_lf:digest(lf(await readFile(resolve(root,path),'utf8')))})));
 const evidence={kind:'merchant-pilot-publication-local-only-v1',result:'PASS',captured_at:new Date().toISOString(),baseline_schema_md5:postCeSchemaMd5,installed_schema_md5:installedMd5,
  input_scope:'Synthetic local physical-product submissions only; no real cohort selected',remote_access:'NONE',production_writes:'NONE',migrations,sources,services,checks,client_checks:client.checks,physical_two_device:'OPEN',distribution_ready:false};
 await writeFile(resolve(root,'docs/data/merchant_pilot_publication_acceptance.json'),JSON.stringify(evidence,null,2)+'\n');
 console.log('PILOT_PUBLICATION_LOCAL_PASS: '+checks.length+' groups + 18 actual repository checkpoints.');
}catch(error){console.error('PILOT_PUBLICATION_LOCAL_FAILED at '+stage+'; no remote fallback.');if(run)await writeFile(resolve(run.dir,'publication-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});process.exitCode=1;}
finally{if(credentialFile)await unlink(credentialFile).catch(()=>{});if(db)await db.end().catch(()=>{});}
