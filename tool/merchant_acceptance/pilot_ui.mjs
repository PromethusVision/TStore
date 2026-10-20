// New, owned loopback fixture only. Historical installation proofs are inputs,
// never rewritten. This runner cannot accept a hosted connection or a real user.
import assert from 'node:assert/strict';
import {readFile,writeFile,realpath,unlink,mkdir} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {randomUUID,randomBytes} from 'node:crypto';
import {readRun,credentials,runtimeEvidence,root,command} from './local.mjs';
import {connect,migrate} from './fixture.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression,taxonomyExpression,loadDelta,schemaPlan,projectRef,projectUrl,digest} from './pilot_preparation_contract.mjs';
import {loadRepair,repairPlan} from './pilot_launch_contract.mjs';
import {categoryInventory} from './prepare_pilot.mjs';
import {cohortTemplate,observationSql} from './pilot_cohort_contract.mjs';
import {publicationTemplate,publicationObservationSql,loadPublication,publicationSchemaPlan,publicationSources} from './pilot_publication_contract.mjs';
import {verifiedInstalledProfile,mirrorInstalledPublicationProfile,installedSchemaMd5,installedReceipt} from './pilot_installed_profile.mjs';
import {installedCohortPlans,installedPublicationPlan} from './pilot_installed_contract.mjs';
import {validateUiResult,captureUiSources,verifyUiProof,uiProofPath,fixtureBaselineCommit,databaseChecks} from './pilot_ui_contract.mjs';
import {readHistoricalContracts,validateRepositoryResult,repositoryProofPath,historicalReadinessSha} from './pilot_current_contract.mjs';

let run,db,credentialFile,stage='arguments';
try {
  assert(process.argv.length===4||(process.argv.length===5&&process.argv[4]==='repositories'));
  const repositories=process.argv[4]==='repositories';
  run=await readRun(process.argv[2]);
  const flutter=await realpath(process.argv[3]);
  const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
  const snapshot=await realpath(resolve(flutter,'bin/cache/flutter_tools.snapshot'));
  const sources=await captureUiSources(root);
  const historicalContracts=await readHistoricalContracts(root);
  const status=await credentials(run),services=await runtimeEvidence(run);
  const url=localUrl(status.DB_URL,'db');
  db=await connect({host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false});
  const scalar=async sql=>(await db.query(sql)).rows[0].value;
  const schema=()=>scalar(`SELECT (${schemaExpression})::text value`);
  const token=value=>db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[value]);
  const apply=async plan=>{await token(plan.plan.sha256);await db.query(plan.sql);};
  const observe=async sql=>{
    const rows=await db.query(sql);
    return JSON.parse(rows.find(r=>r.rows?.[0]?.observation_text).rows[0].observation_text);
  };
  const target={project_ref:projectRef,project_url:projectUrl};
  // target identifies the reviewed contract; all executions use db at 127.0.0.1.
  stage='fresh installed-profile fixture';
  // J7/J8 proofs bind historical clients. Verify their exact original sources
  // in a private snapshot instead of changing old hashes or weakening gates.
  // Only the schema fixture uses it; Flutter below executes CURRENT app code.
  const historical=resolve(run.dir,'ui-installed-proof');
  await mkdir(historical);
  for(const path of [...publicationSources,installedReceipt,'docs/data/merchant_pilot_publication_acceptance.json']){
    const content=await command('git',['show',fixtureBaselineCommit+':'+path]);
    await mkdir(dirname(resolve(historical,path)),{recursive:true});
    await writeFile(resolve(historical,path),content,{flag:'wx'});
  }
  await verifiedInstalledProfile(historical);
  const migrations=await migrate(db,{coreOnly:true,baselineOnly:true});
  await mirrorHostedProfile(db);
  await apply(schemaPlan(target,await schema(),await loadDelta(root)));
  await mirrorPostAProfile(db);
  const prior=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
  await apply(repairPlan(target,prior,await loadRepair(root)));
  await apply(publicationSchemaPlan(target,await loadPublication(root)));
  await mirrorInstalledPublicationProfile(db,historical);
  assert.equal(digest(await schema(),'md5'),installedSchemaMd5);
  console.log('PASS exact installed schema mirrored in owned loopback services');

  stage='synthetic identities and reviewed catalog fixture';
  const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
  const actors=[];
  for(let i=0;i<4;i++){
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});
    assert.equal(created.status,200);
    const signed=await request('/auth/v1/token?grant_type=password',null,login);
    assert.equal(signed.status,200);
    actors.push({id:created.data.id,token:signed.data.access_token,login});
  }
  const [publisher,other,merchant,customer]=actors;
  const taxonomy=await scalar(`SELECT (${taxonomyExpression})::text value`);
  const category=categoryInventory(target,taxonomy).find(x=>x.eligible).id;
  const intake=cohortTemplate();
  intake.accounts=[publisher,other,merchant].map((actor,i)=>({slot:'merchant-0'+(i+1),role:'merchant',user_id:actor.id,identity_review_ref:'synthetic-local-ui-review'}));
  intake.accounts.push({slot:'customer-01',role:'customer',user_id:customer.id,identity_review_ref:'synthetic-local-ui-review'});
  intake.category_leaf_ids=[category];
  const plans=installedCohortPlans(target,taxonomy,intake,await observe(observationSql(intake)));
  for(const plan of Object.values(plans))await apply(plan);
  const shop=randomUUID(),foreignShop=randomUUID();
  for(const [actor,id] of [[publisher,shop],[other,foreignShop]])
    assert((await request('/rest/v1/shops',actor,{id,owner_user_id:actor.id,name:'Sentetik hazırlık mağazası'})).ok);
  await db.query("NOTIFY pgrst,'reload schema'");
  let ready=false;
  for(let i=0;i<30;i++){
    if((await request('/rest/v1/rpc/merchant_catalog_categories_v1',publisher,{p_shop_id:shop})).ok){ready=true;break;}
    await new Promise(r=>setTimeout(r,200));
  }
  assert(ready,'Local REST schema did not become ready');
  const product=randomUUID(),productName=repositories?'Local acceptance current pen':'Yerel ekran provası kalem';
  const submitted=await request('/rest/v1/rpc/merchant_submit_product_v1',publisher,{
    p_shop_id:shop,p_request_id:randomUUID(),p_draft:{name:productName,brand:'',model:'UI',variant:'Mavi',gtin:'0000000000017',canonical_category_id:category,product_type:'shared_catalog_product'}});
  assert(submitted.ok);
  const publication={...publicationTemplate(),batch_id:randomUUID(),compatibility_review_ref:'local-screen-proof',items:[{
    submission_id:submitted.data.submission.id,product_id:product,brand_id:null,create:true,kind:'physical_good',review_ref:'synthetic-local-ui-review'}]};
  await apply(installedPublicationPlan(target,publication,await observe(publicationObservationSql(publication))));
  const notification=randomUUID(),foreignNotification=randomUUID();
  await db.query("INSERT INTO public.notifications(id,user_id,title,body,type) VALUES($1,$2,'Yerel katılım bildirimi','Ekran provası','system'),($3,$4,'Başka esnafın bildirimi','Görünmemeli','system')",
    [notification,merchant.id,foreignNotification,other.id]);
  const nonce=randomBytes(24).toString('hex');
  credentialFile=resolve(run.dir,repositories?'pilot-client-fixture.json':'pilot-ui-fixture.json');
  await writeFile(credentialFile,JSON.stringify({kind:repositories?'merchant-pilot-base-core-local':'merchant-pilot-ui-local-v1',project:run.project,nonce,url:status.API_URL,key:status.ANON_KEY,
    merchant:merchant.login,customer:customer.login,other:other.login,product,product_name:productName,category,foreign_shop:foreignShop,notification,foreign_notification:foreignNotification,
    submission_request_id:randomUUID(),cart_id:randomUUID()}),{flag:'wx',mode:0o600});
  console.log('PASS synthetic local identities, physical catalog and private inbox fixture');

  stage=repositories?'actual current repositories':'actual Merchant screens';
  const file=repositories?'pilot_repository_test.dart':'pilot_ui_test.dart';
  const variable=repositories?'MERCHANT_PILOT_LOCAL_FIXTURE':'MERCHANT_PILOT_UI_FIXTURE';
  const output=await command(dart,[snapshot,'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/'+file,'--reporter','expanded'],root,600000,false,
    {[variable]:credentialFile,FLUTTER_ROOT:flutter});
  await writeFile(resolve(run.dir,repositories?'pilot-current-repositories.log':'pilot-ui-flutter.log'),output,{mode:0o600});
  const result=JSON.parse(await readFile(resolve(run.dir,repositories?'pilot-client-result.json':'pilot-ui-result.json'),'utf8'));
  const checks=repositories?validateRepositoryResult(result,nonce,historicalContracts.proof.client_checks):validateUiResult(result,nonce);
  stage='independent final database checks';
  assert.equal(digest(await schema(),'md5'),installedSchemaMd5);
  assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);
  assert.equal(await scalar('SELECT count(*)::int value FROM public.shop_products'),1);
  const listing=(await db.query('SELECT price,is_available,is_active FROM public.shop_products')).rows[0];
  assert.equal(Number(listing.price),234.56);assert.equal(listing.is_available,true);assert.equal(listing.is_active,true);
  assert.equal(Number(await scalar('SELECT price value FROM public.products')),0);
  assert.equal(await scalar('SELECT count(*)::int value FROM public.verified_transactions'),repositories?1:0);
  assert.equal((await db.query('SELECT is_read FROM public.notifications WHERE id=$1',[foreignNotification])).rows[0].is_read,false);
  assert.equal((await db.query('SELECT name FROM public.shops WHERE id=$1',[foreignShop])).rows[0].name,'Sentetik hazırlık mağazası');
  assert.deepEqual(await captureUiSources(root),sources,'Sources changed during screen rehearsal');
  const evidence={kind:repositories?'merchant-pilot-current-repositories-local-v1':'merchant-pilot-ui-local-only-v1',result:'PASS',captured_at:new Date().toISOString(),installed_schema_md5:installedSchemaMd5,
    fixture_baseline_commit:fixtureBaselineCommit,remote_access:'NONE',production_writes:'NONE',input_scope:'Synthetic identities and one physical product in owned loopback services',
    hardware_seams:repositories?['No widgets or hardware; actual current repositories and SDK over guarded loopback HTTP']:['Gallery picker supplies one local PNG; real camera/gallery permissions are not accepted',
      'Fresh in-memory SharedPreferences adapter supplies device storage for the real push cleanup coordinator; disk persistence is not accepted',
      'Widget Image.network retains test binding; Storage bytes and Customer signed URL are independently downloaded through guarded HTTP'],
    fault_injection:repositories?'NONE':'Two successful local PATCH responses are consumed then intentionally withheld; database state and one-write counts are verified',
    physical_two_device:'OPEN',distribution_ready:false,services,migrations,sources,checks,
    ...(repositories?{historical_readiness_sha256_lf:historicalReadinessSha,renewed_sources:historicalContracts.renewed}:{}),
    database_postchecks:repositories?databaseChecks.map(x=>x==='no verified sale invented'?'one synthetic legacy QR purchase; physical acceptance OPEN':x):databaseChecks};
  await writeFile(resolve(root,repositories?repositoryProofPath:uiProofPath),JSON.stringify(evidence,null,2)+'\n');
  if(!repositories)await verifyUiProof(root);
  console.log((repositories?'PILOT_CURRENT_REPOSITORIES_PASS: ':'PILOT_UI_LOCAL_PASS: ')+checks.length+' client checkpoints + 6 independent database checks.');
} catch(error) {
  console.error('PILOT_UI_LOCAL_FAILED at '+stage+'; no remote fallback.');
  if(run)await writeFile(resolve(run.dir,'pilot-ui-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});
  process.exitCode=1;
} finally {
  if(credentialFile)await unlink(credentialFile).catch(()=>{});
  if(db)await db.end().catch(()=>{});
}
