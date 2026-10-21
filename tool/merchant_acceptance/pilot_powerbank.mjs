// Real services, fresh owned loopback fixture only. No hosted execution path.
import assert from 'node:assert/strict';
import {readFile,writeFile,mkdir,unlink,realpath} from 'node:fs/promises';
import {resolve,dirname} from 'node:path';
import {randomBytes,randomUUID} from 'node:crypto';
import {readRun,credentials,runtimeEvidence,root,command} from './local.mjs';
import {connect,migrate} from './fixture.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression,loadDelta,schemaPlan,projectRef,projectUrl,digest} from './pilot_preparation_contract.mjs';
import {loadRepair,repairPlan} from './pilot_launch_contract.mjs';
import {publicationSources,publicationTemplate,publicationObservationSql,loadPublication,publicationSchemaPlan,lf} from './pilot_publication_contract.mjs';
import {verifiedInstalledProfile,mirrorInstalledPublicationProfile,installedSchemaMd5,installedReceipt} from './pilot_installed_profile.mjs';
import {installedPublicationPlan} from './pilot_installed_contract.mjs';
import {fixtureBaselineCommit} from './pilot_ui_contract.mjs';
import {readIntegratedContracts,captureIntegratedSources} from './pilot_integrated_contract.mjs';
import {powerbankManifest,powerbankObservationSql,powerbankCategoryPlan,powerbankRollbackPlan,fullCategoryExpression,powerbankManifestPath} from './pilot_powerbank_contract.mjs';
import {databaseChecks,clientChecks} from './prepare_powerbank_pilot.mjs';

let run,db,credentialFile,stage='arguments';
try {
  assert.equal(process.argv.length,4);
  run=await readRun(process.argv[2]);const flutter=await realpath(process.argv[3]);
  const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
  const snapshot=await realpath(resolve(flutter,'bin/cache/flutter_tools.snapshot'));
  const sources=await captureIntegratedSources(root),manifest=await powerbankManifest(root);
  await readIntegratedContracts(root); // historical SQL/client contracts, not stale UI qualification
  const historicalFiles=['docs/data/merchant_pilot_publication_acceptance.json','docs/data/merchant_pilot_installed_acceptance.json','docs/data/merchant_pilot_integrated_ui_acceptance.json','docs/data/merchant_pilot_integrated_repository_acceptance.json'];
  const historicalHashes=await Promise.all(historicalFiles.map(async path=>({path,sha256_lf:digest(lf(await readFile(resolve(root,path),'utf8')))})));
  const rawHistoricalHashes=await Promise.all(historicalFiles.map(async path=>digest(await readFile(resolve(root,path)))));
  const status=await credentials(run),services=await runtimeEvidence(run),url=localUrl(status.DB_URL,'db');
  const config={host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false};
  db=await connect(config);
  const target={project_ref:projectRef,project_url:projectUrl},checks=[],clients=[];
  const scalar=async sql=>(await db.query(sql)).rows[0].value;
  const schema=()=>scalar(`SELECT (${schemaExpression})::text value`);
  const taxonomy=()=>scalar(`SELECT (${fullCategoryExpression})::text value`);
  const token=value=>db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[value]);
  const apply=async p=>{await token(p.plan.sha256);await db.query(p.sql);};
  const observe=async sql=>{const r=await db.query(sql);return JSON.parse(r.find(x=>x.rows?.[0]?.observation_text).rows[0].observation_text);};
  const reject=async(sql,pattern)=>{try{await assert.rejects(db.query(sql),e=>pattern.test(e.message));}finally{await db.query('ROLLBACK');}};
  const check=async(name,fn)=>{stage=name;await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);};
  stage='reconstruct exact installed schema';
  const historical=resolve(run.dir,'powerbank-historical-schema');await mkdir(historical);
  for(const path of [...publicationSources,installedReceipt,'docs/data/merchant_pilot_publication_acceptance.json']){
    const content=await command('git',['show',fixtureBaselineCommit+':'+path]);
    await mkdir(dirname(resolve(historical,path)),{recursive:true});await writeFile(resolve(historical,path),content,{flag:'wx'});
  }
  await verifiedInstalledProfile(historical);
  await migrate(db,{coreOnly:true,baselineOnly:true});await mirrorHostedProfile(db);
  await apply(schemaPlan(target,await schema(),await loadDelta(root)));await mirrorPostAProfile(db);
  const receipt=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
  await apply(repairPlan(target,receipt,await loadRepair(root)));
  await apply(publicationSchemaPlan(target,await loadPublication(root)));
  await mirrorInstalledPublicationProfile(db,historical);
  assert.equal(digest(await schema(),'md5'),installedSchemaMd5);
  const before=await taxonomy(),o=await observe(powerbankObservationSql());
  const proposal=powerbankCategoryPlan(target,o,manifest);
  await check('existing approved branch cannot accept a powerbank before the additive leaf',async()=>{
    assert.equal(o.children,0);assert.equal(o.parent.is_assignable,false);
    assert.equal(await scalar(`SELECT public._catalog_category_allowed_v1('${manifest.parent_id}') value`),false);
  });
  await check('missing approval token leaves all categories unchanged',async()=>{await token('');await reject(proposal.sql,/POWERBANK_REVIEW_NOT_APPROVED/);assert.equal(await taxonomy(),before);});
  await token(proposal.plan.sha256);
  await check('permission drift is refused without normalizing the schema',async()=>{
    await db.query('BEGIN');await db.query('GRANT INSERT ON public.notifications TO authenticated');
    await reject(proposal.sql,/POWERBANK_SCHEMA_DRIFT/);assert.equal(digest(await schema(),'md5'),installedSchemaMd5);
  });
  await check('even unrelated category metadata drift prevents activation',async()=>{
    await db.query('BEGIN');await db.query("UPDATE public.categories SET sort_order=sort_order+1 WHERE id<>$1 AND id<>$2 AND level=1",[manifest.root_id,manifest.parent_id]);
    await reject(proposal.sql,/POWERBANK_DATA_DRIFT/);assert.equal(await taxonomy(),before);
  });
  await check('catalog and decision drift are independently refused',async()=>{
    await db.query('BEGIN');await db.query("INSERT INTO public.brands(name) VALUES('Local drift')");await reject(proposal.sql,/POWERBANK_DATA_DRIFT/);
    await db.query('BEGIN');await db.query('UPDATE public.catalog_media_config SET decisions_enabled=true');await reject(proposal.sql,/POWERBANK_DECISION_DRIFT/);
  });
  await check('concurrent category writer cannot race the reviewed snapshot',async()=>{
    const peer=await connect(config);try{await peer.query('BEGIN');await peer.query('LOCK TABLE public.categories IN SHARE ROW EXCLUSIVE MODE');await reject(proposal.sql,/lock timeout/);}finally{await peer.query('ROLLBACK');await peer.end();}
  });
  await check('late failure rolls back both new leaf and ancestor activation',async()=>{
    await reject(proposal.sql.replace(" IF NOT public._catalog_category_allowed_v1", " RAISE EXCEPTION 'LOCAL_LATE_FAILURE';\n IF NOT public._catalog_category_allowed_v1"),/LOCAL_LATE_FAILURE/);
    assert.equal(await taxonomy(),before);
  });
  await check('one leaf and two ancestors change while schema and historical rows remain intact',async()=>{
    await apply(proposal);assert.equal(digest(await schema(),'md5'),installedSchemaMd5);
    const rows=JSON.parse(await taxonomy()),prior=JSON.parse(before),modified=new Set([manifest.root_id,manifest.parent_id,manifest.node.id]);
    assert.equal(rows.length,1564);assert.deepEqual(rows.filter(x=>!modified.has(x.id)),prior.filter(x=>!modified.has(x.id)));
    assert.equal(rows.filter(x=>x.is_active).length,3);
    assert.equal(rows.filter(x=>x.is_active&&x.is_assignable).length,1);
  });
  await check('replay is rejected rather than allocating another identity',async()=>{await reject(proposal.sql,/POWERBANK_DATA_DRIFT/);assert.equal(await scalar('SELECT count(*)::int value FROM public.categories'),1564);});
  const after=await observe(powerbankObservationSql()),recovery=powerbankRollbackPlan(target,after,manifest),active=await taxonomy();
  await check('separate recovery retains new identity and cannot delete historic rows',async()=>{
    await token(recovery.plan.sha256);
    // Exercise the exact recovery body, then roll back this test transaction.
    await db.query(recovery.sql.replace(/COMMIT;\s*$/, ''));
    assert.equal(await scalar(`SELECT public._catalog_category_allowed_v1('${manifest.node.id}') value`),false);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.categories'),1564);
    await db.query('ROLLBACK');assert.equal(await taxonomy(),active);
  });
  stage='synthetic local accounts';
  const actors={};
  for(const role of ['merchant','other','customer']){
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});assert.equal(created.status,200);
    actors[role]={id:created.data.id,login};
  }
  await db.query("UPDATE public.profiles SET role='merchant' WHERE id=ANY($1::uuid[])",[[actors.merchant.id,actors.other.id]]);
  await db.query("NOTIFY pgrst,'reload schema'");
  const nonce=randomBytes(24).toString('hex'),product=randomUUID();
  credentialFile=resolve(run.dir,'powerbank-client-fixture.json');
  async function client(phase){
    stage='current Flutter repositories: '+phase;
    await writeFile(credentialFile,JSON.stringify({kind:'powerbank-local-client-v1',project:run.project,nonce,phase,url:status.API_URL,key:status.ANON_KEY,
      merchant:actors.merchant.login,customer:actors.customer.login,other:actors.other.login,category:manifest.node.id,request_id:randomUUID(),product}),{mode:0o600});
    const output=await command(dart,[snapshot,'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/pilot_powerbank_client_test.dart','--reporter','expanded'],root,300000,false,{FLUTTER_ROOT:flutter,MERCHANT_POWERBANK_LOCAL_FIXTURE:credentialFile});
    await writeFile(resolve(run.dir,'powerbank-'+phase+'.log'),output,{mode:0o600});
    const result=JSON.parse(await readFile(resolve(run.dir,'powerbank-client-'+phase+'.json'),'utf8'));
    assert.equal(result.result,'PASS');assert.equal(result.nonce,nonce);assert.equal(result.checks.length,phase==='submission'?3:4);
    clients.push({phase,checks:result.checks});return result;
  }
  const submitted=await client('submission');
  await check('real barcode-less submission creates one pending row and no product or identifier',async()=>{
    assert.equal(await scalar('SELECT count(*)::int value FROM public.product_submissions'),1);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.products'),0);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.product_identifiers'),0);
  });
  const brand=randomUUID();await db.query('INSERT INTO public.brands(id,name) VALUES($1,$2)',[brand,'Yerel Prova']);
  const publication={...publicationTemplate(),batch_id:randomUUID(),compatibility_review_ref:'local-powerbank-proof',items:[{submission_id:submitted.submission_id,product_id:product,brand_id:brand,create:true,kind:'physical_good',review_ref:'synthetic-local-powerbank'}]};
  await apply(installedPublicationPlan(target,publication,await observe(publicationObservationSql(publication))));
  await check('category recovery refuses after product publication',async()=>{await token(recovery.plan.sha256);await reject(recovery.sql,/POWERBANK_RECOVERY_DRIFT/);});
  await client('listing');
  await check('published price and stock survive actual client checks without enabling decisions or inventing purchases',async()=>{
    assert.equal(await scalar('SELECT count(*)::int value FROM public.shop_products'),1);
    const row=(await db.query('SELECT price::text,is_available,is_active FROM public.shop_products')).rows[0];assert.equal(Number(row.price),990);assert(row.is_active&&row.is_available);
    assert.equal(Number(await scalar('SELECT price value FROM public.products')),0);
    assert.equal(await scalar('SELECT count(*)::int value FROM public.verified_transactions'),0);
    assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);
    assert.equal(digest(await schema(),'md5'),installedSchemaMd5);assert.equal(await taxonomy(),active);
  });
  await check('historical proofs remain byte-identical and current sources stayed unchanged',async()=>{
    for(let i=0;i<historicalFiles.length;i++)assert.equal(digest(await readFile(resolve(root,historicalFiles[i]))),rawHistoricalHashes[i]);
    assert.deepEqual(await captureIntegratedSources(root),sources);
  });
  assert.deepEqual(checks,databaseChecks.map(name=>({name,result:'PASS'})));assert.deepEqual(clients,clientChecks);
  const evidence={kind:'merchant-pilot-powerbank-local-v1',result:'PASS',captured_at:new Date().toISOString(),remote_access:'NONE',production_writes:'NONE',distribution_ready:false,physical_two_device:'OPEN',
    run_id:run.project,nonce_sha256:digest(nonce),source_commit:(await command('git',['rev-parse','HEAD'])).trim(),
    installed_schema_md5:installedSchemaMd5,manifest_sha256_lf:digest(lf(await readFile(resolve(root,powerbankManifestPath),'utf8'))),sources,historical_proofs:historicalHashes,services,
    synthetic_accounts:true,real_catalog_written:false,verified_purchases:0,checks,client_checks:clients};
  await writeFile(resolve(run.dir,'powerbank-acceptance.json'),JSON.stringify(evidence,null,2)+'\n',{flag:'wx'});
  await writeFile(resolve(run.dir,'powerbank-category.local-review.sql'),proposal.sql,{flag:'wx'});
  console.log('POWERBANK_LOCAL_PASS: '+checks.length+' database groups, 7 current-client checkpoints; no hosted action.');
}catch(e){
  console.error('POWERBANK_LOCAL_FAILED at '+stage+'; no remote fallback.');
  if(run)await writeFile(resolve(run.dir,'powerbank-failure.txt'),e.stack+'\n'+(e.diagnostics??''),{mode:0o600});
  process.exitCode=1;
}finally{
  if(credentialFile)await unlink(credentialFile).catch(()=>{});
  if(db)await db.end().catch(()=>{});
}
