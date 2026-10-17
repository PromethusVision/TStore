import assert from 'node:assert/strict';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {randomUUID,randomBytes} from 'node:crypto';
import {readRun,credentials,runtimeEvidence,root} from './local.mjs';
import {connect,migrate} from './fixture.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression,taxonomyExpression,loadDelta,schemaPlan,projectRef,projectUrl,digest} from './pilot_preparation_contract.mjs';
import {inspectCore,validateCore} from './pilot_contract.mjs';
import {loadRepair,repairPlan,functionMetadataExpression,installedSchemaMd5,repairVersion,lf,repairFile,intakeTemplate,assessIntake} from './pilot_launch_contract.mjs';

// One NEW owned literal-loopback stack only. Never accept a hosted URL/key.
let run,db,stage='arguments';
try {
  assert.equal(process.argv.length,3,'Usage: pilot_launch.mjs <new-owned-local-run>');
  run=await readRun(process.argv[2]);
  const status=await credentials(run),services=await runtimeEvidence(run),url=localUrl(status.DB_URL,'db');
  const config={host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false};
  db=await connect(config);
  const scalar=async sql=>(await db.query(sql)).rows[0].value;
  const schemaNow=()=>scalar(`SELECT (${schemaExpression})::text value`);
  const metadataNow=()=>scalar(`SELECT ${functionMetadataExpression} value`);
  const taxonomyNow=()=>scalar(`SELECT (${taxonomyExpression})::text value`);
  const checks=[];
  async function check(name,action){stage=name;await action();checks.push({name,result:'PASS'});console.log('PASS '+name);}
  async function reject(sql,message){try{await assert.rejects(db.query(sql),e=>e.message.includes(message));}finally{await db.query('ROLLBACK');}}
  const token=value=>db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[value]);
  const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
  const target={project_ref:projectRef,project_url:projectUrl};
  stage='fresh Development mirror and already-installed A';
  await migrate(db,{coreOnly:true,baselineOnly:true});await mirrorHostedProfile(db);
  const upgrade=schemaPlan(target,await schemaNow(),await loadDelta(root));
  await token(upgrade.plan.sha256);await db.query(upgrade.sql);
  const postProfile=await mirrorPostAProfile(db);
  assert.equal(digest(await schemaNow(),'md5'),installedSchemaMd5,'J3 hosted post-schema must match exactly');
  const source=await loadRepair(root);
  const receipt=JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8'));
  const repair=repairPlan(target,receipt,source);
  const beforeSchema=await schemaNow(),beforeMetadata=await metadataNow(),beforeTaxonomy=await taxonomyNow();
  await check('local post-A mirror matches actual J3 installed fingerprint',async()=>validateCore(await inspectCore(db)));

  const actors=[];
  for(let i=0;i<4;i++){
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});
    assert.equal(created.status,200);
    const signed=await request('/auth/v1/token?grant_type=password',null,login);assert.equal(signed.status,200);
    actors.push({id:created.data.id,token:signed.data.access_token});
  }
  const [merchant,customer,blank,foreign]=actors,shop=randomUUID();
  await db.query("UPDATE public.profiles SET role='merchant',full_name='Başka Profil Adı' WHERE id=$1",[merchant.id]);
  await db.query("UPDATE public.profiles SET full_name='Çağla İğde' WHERE id=$1",[customer.id]);
  await db.query("UPDATE public.profiles SET full_name='   ' WHERE id=$1",[blank.id]);
  await db.query("INSERT INTO public.shops(id,owner_user_id,name) VALUES($1,$2,'İstanbul Berber')",[shop,merchant.id]);
  async function chat(sender,receiver){
    const id=randomUUID();const response=await request('/rest/v1/chat_messages',sender,{id,sender_id:sender.id,receiver_id:receiver.id,content:'Yerel doğrulama'});
    assert(response.ok,'Real chat insert must succeed');return id;
  }
  async function purchase(name,who=customer){
    const id=randomUUID();
    await db.query(`INSERT INTO public.verified_transactions(id,source_qr_session_id,customer_user_id,shop_id,shop_name,confirmed_by_user_id,item_count,total_amount,confirmed_at)
      VALUES($1,$2,$3,$4,$5,$6,1,1,clock_timestamp())`,[id,randomUUID(),who.id,shop,name,merchant.id]);return id;
  }
  const notices=async user=>(await db.query('SELECT * FROM public.notifications WHERE user_id=$1 ORDER BY created_at,id',[user.id])).rows;
  await check('pre-fix real chat and synthetic purchase triggers reproduce both corrupt notification types',async()=>{
    await chat(blank,customer);await purchase('');
    const n=await notices(customer);assert(n.some(x=>x.title==='Yeni mesajÄ±n var'));assert(n.some(x=>x.title==='AlÄ±ÅŸveriÅŸin onaylandÄ±'));
  });
  const dataHash=()=>scalar(`SELECT md5(jsonb_build_object('notifications',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.notifications t),'chat',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.chat_messages t),'transactions',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.verified_transactions t),'profiles',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.profiles t),'shops',(SELECT jsonb_agg(to_jsonb(t) ORDER BY id) FROM public.shops t))::text) value`);
  const oldData=await dataHash(),oldNotices=await notices(customer);
  await check('missing, wrong and old A tokens reject E without changes',async()=>{
    for(const value of ['', 'wrong',upgrade.plan.sha256]){await token(value);await reject(repair.sql,'PILOT_REVIEW_NOT_APPROVED');assert.equal(await schemaNow(),beforeSchema);assert.equal(await dataHash(),oldData);}
  });await token(repair.plan.sha256);
  await check('drift in RLS, functions, grants, defaults or ledger blocks repair',async()=>{
    for(const sql of ["ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY","GRANT INSERT ON public.notifications TO authenticated",
      "ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT INSERT ON TABLES TO PUBLIC",
      "INSERT INTO supabase_migrations.schema_migrations(version,name) VALUES('99999999999999','local-drift')",
      "ALTER FUNCTION public.create_chat_message_notification() SET search_path=public"]){
      await db.query('BEGIN');await db.query(sql);assert.notEqual(await schemaNow(),beforeSchema);
      await reject(repair.sql,'PILOT_BASELINE_DRIFT');assert.equal(await schemaNow(),beforeSchema);
    }
  });
  await check('competing repair is refused before any function replacement',async()=>{
    const other=await connect(config);try{await other.query('BEGIN');await other.query("SELECT pg_advisory_xact_lock(hashtextextended($1,0))",['esnaftavar:'+projectRef+':pilot-notification-text']);await reject(repair.sql,'PILOT_COMPETING_WRITER');}
    finally{await other.query('ROLLBACK');await other.end();}assert.equal(await schemaNow(),beforeSchema);
  });
  await check('late failure rolls back both functions and the new ledger row',async()=>{
    const fault=repair.sql.replace(/COMMIT;\n$/,'SELECT 1/0;\nCOMMIT;\n');assert.notEqual(fault,repair.sql);
    await reject(fault,'division by zero');assert.equal(await schemaNow(),beforeSchema);assert.deepEqual(await metadataNow(),beforeMetadata);assert.equal(await dataHash(),oldData);
  });
  await check('Windows editor CRLF input preserves exact corrected bodies and ledger text',async()=>{
    const windows=repair.sql.replaceAll('\n','\r\n').replace(/COMMIT;\r\n$/,'ROLLBACK;\r\n');
    await db.query(windows);assert.equal(await schemaNow(),beforeSchema);assert.equal(await dataHash(),oldData);
  });
  await check('unrelated trigger mutation is detected and rolled back',async()=>{
    const fault=repair.sql.replace(' s := '," EXECUTE 'ALTER TABLE public.chat_messages DISABLE TRIGGER create_chat_message_notification_after_insert';\n s := ");assert.notEqual(fault,repair.sql);
    await reject(fault,'PILOT_UNRELATED_SCHEMA_CHANGE');assert.equal(await schemaNow(),beforeSchema);
  });
  await check('function-owner mutation is detected and rolled back',async()=>{
    // The candidate never grants this permission. Fault injection temporarily
    // supplies CREATE so PostgreSQL permits the owner change being tested, then
    // removes it before the metadata guard; the whole transaction rolls back.
    const fault=repair.sql.replace(' IF (SELECT jsonb_agg'," EXECUTE 'GRANT CREATE ON SCHEMA public TO service_role';\n EXECUTE 'ALTER FUNCTION public.create_chat_message_notification() OWNER TO service_role';\n EXECUTE 'REVOKE CREATE ON SCHEMA public FROM service_role';\n IF (SELECT jsonb_agg");assert.notEqual(fault,repair.sql);
    await reject(fault,'PILOT_FUNCTION_AUTHORITY_CHANGED');assert.equal(await schemaNow(),beforeSchema);assert.deepEqual(await metadataNow(),beforeMetadata);
  });
  await check('exact forward repair preserves existing rows, OIDs, owners and ACLs',async()=>{
    await db.query(repair.sql);assert.equal(await dataHash(),oldData);assert.deepEqual(await metadataNow(),beforeMetadata);
    assert.deepEqual(await notices(customer),oldNotices);
    const entry=(await db.query('SELECT version,name,statements FROM supabase_migrations.schema_migrations WHERE version=$1',[repairVersion])).rows[0];
    assert.deepEqual(entry,{version:repairVersion,name:repair.plan.ledger.name,statements:[source.sql]});
    assert.equal(await scalar('SELECT count(*)::int value FROM supabase_migrations.schema_migrations'),14);
  });
  const afterSchema=await schemaNow();
  await check('replay refuses an already corrected schema and preserves history',async()=>{await reject(repair.sql,'PILOT_BASELINE_DRIFT');assert.equal(await schemaNow(),afterSchema);assert.equal(await dataHash(),oldData);});
  await check('merchant chat prefers shop name and delivers canonical UTF-8 content',async()=>{
    await chat(merchant,customer);const n=(await notices(customer)).at(-1);
    assert.equal(n.title,'Yeni mesajın var');assert.equal(n.body,'İstanbul Berber sana yeni bir mesaj gönderdi.');
    assert.deepEqual(n.data,{action_type:'chat_detail',action_id:merchant.id,action_name:'İstanbul Berber'});
  });
  await check('profile and empty-name fallbacks preserve recipients and action metadata',async()=>{
    for(const [sender,name] of [[customer,'Çağla İğde'],[blank,'Bir kullanıcı']]){
      await chat(sender,merchant);const n=(await notices(merchant)).at(-1);
      assert.equal(n.body,name+' sana yeni bir mesaj gönderdi.');assert.equal(n.title,'Yeni mesajın var');assert.equal(n.data.action_name,name);assert.equal(n.data.action_id,sender.id);
    }
  });
  await check('self-chat does not create a duplicate notification',async()=>{
    const before=(await notices(customer)).length;await chat(customer,customer);assert.equal((await notices(customer)).length,before);
  });
  await check('purchase notifications preserve snapshot shop names and blank fallback',async()=>{
    for(const [name,expected] of [['Öz İğde Market','Öz İğde Market'],['   ','Mağaza']]){
      const id=await purchase(name);const n=(await notices(customer)).at(-1);
      assert.equal(n.title,'Alışverişin onaylandı');assert.equal(n.body,expected+' alışverişini onayladı.');
      assert.deepEqual(n.data,{action_type:'order_detail',action_id:id,action_name:expected});
    }
  });
  await check('actual Auth inbox denies foreign reads and client-generated notifications',async()=>{
    const foreignRead=await request('/rest/v1/notifications?user_id=eq.'+customer.id,foreign,undefined,'GET');assert(foreignRead.ok);assert.deepEqual(foreignRead.data,[]);
    const anonymous=await request('/rest/v1/notifications',null,undefined,'GET');assert(!anonymous.ok);
    const forged=await request('/rest/v1/notifications',customer,{user_id:customer.id,title:'forged',body:'forged',type:'system'});assert(!forged.ok);
    const own=await request('/rest/v1/notifications?user_id=eq.'+customer.id,customer,undefined,'GET');assert(own.ok);assert.equal(own.data.length,(await notices(customer)).length);
    assert(own.data.some(n=>n.title==='Alışverişin onaylandı'));
  });
  await check('inbox mark-read and delete remain owner scoped with immutable content',async()=>{
    const row=(await notices(customer)).at(-1);
    assert(!(await request('/rest/v1/notifications?id=eq.'+row.id,customer,{title:'tampered'},'PATCH')).ok);
    assert((await request('/rest/v1/notifications?id=eq.'+row.id,foreign,{is_read:true},'PATCH')).ok);
    assert.equal((await notices(customer)).find(n=>n.id===row.id).is_read,false);
    assert((await request('/rest/v1/notifications?id=eq.'+row.id,customer,{is_read:true},'PATCH')).ok);
    assert.equal((await notices(customer)).find(n=>n.id===row.id).is_read,true);
    assert((await request('/rest/v1/notifications?id=eq.'+row.id,foreign,undefined,'DELETE')).ok);
    assert((await notices(customer)).some(n=>n.id===row.id));
    assert((await request('/rest/v1/notifications?id=eq.'+row.id,customer,undefined,'DELETE')).ok);
    assert(!(await notices(customer)).some(n=>n.id===row.id));
  });
  await check('no taxonomy, catalog, downstream feature or second notification system is enabled',async()=>{
    assert.equal(await taxonomyNow(),beforeTaxonomy);assert.equal(await scalar('SELECT count(*)::int value FROM public.products'),0);
    assert.equal(await scalar('SELECT decisions_enabled value FROM public.catalog_media_config'),false);
    validateCore(await inspectCore(db));assert.equal(await schemaNow(),afterSchema);
    const report=assessIntake(target,beforeTaxonomy,intakeTemplate());assert.equal(report.distribution_ready,false);assert.equal(report.category_selection,'NOT_SELECTED');
  });
  const sourcePaths=['tool/merchant_acceptance/pilot_launch_contract.mjs','tool/merchant_acceptance/pilot_launch.mjs','tool/merchant_acceptance/prepare_pilot_launch.mjs',repairFile,'tool/merchant_acceptance/pilot_hosted_profile.mjs','tool/merchant_acceptance/pilot_preparation_contract.mjs','tool/merchant_acceptance/fixture.mjs','tool/merchant_acceptance/local.mjs','tool/merchant_acceptance/safety.mjs','tool/merchant_acceptance/docker-proxy.mjs','tool/merchant_acceptance/pilot_launch_profile.mjs','docs/data/merchant_pilot_post_a_observation.json'];
  const sources=await Promise.all(sourcePaths.map(async path=>({path,sha256_lf:digest(lf(await readFile(resolve(root,path),'utf8')))})));
  await writeFile(resolve(root,'docs/data/merchant_pilot_launch_acceptance.json'),JSON.stringify({result:'PASS',captured_at:new Date().toISOString(),baseline_commit:'ad42c92d558624d693f0b831a5b4ed8d7a7a5d22',scope:'OWNED LOCAL mirrored post-A fixture; not hosted acceptance',services,sources,checks,postProfile,repair_plan:repair.plan,before_schema_md5:installedSchemaMd5,after_schema_md5:digest(afterSchema,'md5'),before_taxonomy_md5:digest(beforeTaxonomy,'md5'),after_taxonomy_md5:digest(await taxonomyNow(),'md5'),old_rows_preserved_at_upgrade:true,remote_writes:'NONE',production_access:'NONE',email_sent:'NONE',provider_configured:false,physical_acceptance:'OPEN'},null,2)+'\n');
  console.log('PILOT_LAUNCH_LOCAL_PASS: '+checks.length+' groups; E and C still need separate remote approval.');
} catch(error){console.error('PILOT_LAUNCH_FAILED at '+stage+'; no remote fallback.');if(db)await db.query('ROLLBACK').catch(()=>{});if(run)await writeFile(resolve(run.dir,'launch-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});process.exitCode=1;}
finally{if(db)await db.end();}
