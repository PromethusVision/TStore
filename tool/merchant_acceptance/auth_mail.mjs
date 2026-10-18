import assert from 'node:assert/strict';
import {readFile,writeFile,unlink,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {randomBytes,createHash} from 'node:crypto';
import {readRun,credentials,runtimeEvidence,root,command} from './local.mjs';
import {localUrl,requestJson} from './safety.mjs';
import {connect,migrate} from './fixture.mjs';
import {mirrorHostedProfile} from './pilot_hosted_profile.mjs';
import {mirrorPostAProfile} from './pilot_launch_profile.mjs';
import {schemaExpression,loadDelta,schemaPlan,projectRef,projectUrl,digest} from './pilot_preparation_contract.mjs';
import {loadRepair,repairPlan} from './pilot_launch_contract.mjs';
import {loadPublication,publicationSchemaPlan} from './pilot_publication_contract.mjs';
import {mirrorInstalledPublicationProfile,installedSchemaMd5} from './pilot_installed_profile.mjs';
import {installLocalMail} from './auth_mail_local.mjs';
import {verifyMailProof} from './auth_mail_contract.mjs';

async function sourceSnapshot(){
 const tracked=(await command('git',['ls-files','lib','pubspec.yaml','pubspec.lock','tool/merchant_acceptance'],root)).trim().split(/\r?\n/);
 const paths=[...new Set([...tracked,'tool/merchant_acceptance/auth_mail.mjs','tool/merchant_acceptance/auth_mail_local.mjs','tool/merchant_acceptance/auth_mail_test.dart','tool/merchant_acceptance/auth_mail_contract.mjs','tool/merchant_acceptance/auth_mail_contract.test.mjs','supabase/templates/pilot/confirmation.html','supabase/templates/pilot/recovery.html'])].sort();
 return Promise.all(paths.map(async path=>({path,sha256_lf:createHash('sha256').update((await readFile(resolve(root,path),'utf8')).replace(/\r\n/g,'\n')).digest('hex')})));
}

let run,db,mail,fixture,stage='arguments';
try{
 assert.equal(process.argv.length,4);run=await readRun(process.argv[2]);const flutter=await realpath(process.argv[3]);
 const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
 const status=await credentials(run),dbUrl=localUrl(status.DB_URL,'db');
 db=await connect({host:'127.0.0.1',port:Number(dbUrl.port),database:'postgres',user:'postgres',password:decodeURIComponent(dbUrl.password),ssl:false});
 stage='fresh exact installed public profile';
 const migrations=await migrate(db,{coreOnly:true,baselineOnly:true});await mirrorHostedProfile(db);
 const target={project_ref:projectRef,project_url:projectUrl};
 const schemaNow=async()=>(await db.query(`SELECT (${schemaExpression})::text value`)).rows[0].value;
 const execute=async p=>{await db.query("SELECT set_config('esnaftavar.pilot_review_token',$1,false)",[p.plan.sha256]);await db.query(p.sql);};
 await execute(schemaPlan(target,await schemaNow(),await loadDelta(root)));await mirrorPostAProfile(db);
 await execute(repairPlan(target,JSON.parse(await readFile(resolve(root,'docs/data/merchant_pilot_test_installation.json'),'utf8')),await loadRepair(root)));
 await execute(publicationSchemaPlan(target,await loadPublication(root)));await mirrorInstalledPublicationProfile(db);
 assert.equal(digest(await schemaNow(),'md5'),installedSchemaMd5);
 stage='owned SMTP capture and Auth configuration';mail=await installLocalMail(run,db);
 let ready=false;for(let i=0;i<40;i++){
  const r=await requestJson(status.API_URL,'/auth/v1/settings',null,status.ANON_KEY,undefined,'GET').catch(()=>null);
  if(r?.ok&&r.data.mailer_autoconfirm===false){ready=true;break;}await new Promise(r=>setTimeout(r,500));
 }assert(ready,'Local confirmation profile not ready');
 const accounts={};
 for(const role of ['merchant','other','customer']){
  const email=`${role}-${randomBytes(6).toString('hex')}@fixture.invalid`,password=randomBytes(20).toString('hex');
  const r=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.ANON_KEY,{email,password,email_confirm:true});
  assert(r.ok);accounts[role]={email,password,id:r.data.id};
 }
 await db.query("UPDATE public.profiles SET role='merchant' WHERE id=ANY($1::uuid[])",[[accounts.merchant.id,accounts.other.id]]);
 const shop=(await db.query("INSERT INTO public.shops(owner_user_id,name) VALUES($1,'Synthetic mail rehearsal') RETURNING id",[accounts.merchant.id])).rows[0].id;
 await db.query("NOTIFY pgrst,'reload schema'");
 stage='real Flutter Auth / SMTP / callback scenarios';
 const sources=await sourceSnapshot();
 const nonce=randomBytes(24).toString('hex');fixture=resolve(run.dir,'auth-mail-fixture.json');
 await writeFile(fixture,JSON.stringify({kind:'merchant-auth-mail-local-v1',project:run.project,nonce,url:status.API_URL,key:status.ANON_KEY,accounts,shop}),{flag:'wx',mode:0o600});
 const output=await command(dart,[resolve(flutter,'bin/cache/flutter_tools.snapshot'),'--no-version-check','--suppress-analytics','test','--no-pub','tool/merchant_acceptance/auth_mail_test.dart','--reporter','expanded'],root,300000,false,{MERCHANT_AUTH_MAIL_FIXTURE:fixture,FLUTTER_ROOT:flutter});
 await writeFile(resolve(run.dir,'auth-mail-flutter.log'),output,{mode:0o600});
 const client=JSON.parse(await readFile(resolve(run.dir,'auth-mail-result.json'),'utf8'));assert.equal(client.nonce,nonce);assert.equal(client.result,'PASS');assert(client.checks.length>=15);
 stage='authority, public schema and source evidence';
 assert.equal(digest(await schemaNow(),'md5'),installedSchemaMd5);
 assert.equal((await db.query('SELECT count(*)::int n FROM public.products')).rows[0].n,0);
 assert.equal((await db.query('SELECT decisions_enabled FROM public.catalog_media_config')).rows[0].decisions_enabled,false);
 const roles=(await db.query('SELECT id,role FROM public.profiles WHERE id=ANY($1::uuid[])',[Object.values(accounts).map(a=>a.id)])).rows;
 for(const [name,a]of Object.entries(accounts))assert.equal(roles.find(r=>r.id===a.id).role,name==='customer'?'customer':'merchant');
 assert.deepEqual(await sourceSnapshot(),sources,'Sources changed during the real service rehearsal');
 const proof={kind:'merchant-auth-mail-local-v1',result:'PASS',captured_at:new Date().toISOString(),source_base:(await command('git',['rev-parse','HEAD'],root)).trim(),
  remote_access:'NONE',production_access:'NONE',external_email_sent:false,installed_public_schema_md5:installedSchemaMd5,
  auth_profile:'Local confirmation enabled, local high rate limits; NOT hosted Auth parity',mail:mail.evidence,services:await runtimeEvidence(run),migrations,sources,
  checks:client.checks,final_checks:['Public schema unchanged','Catalog remains empty / decisions OFF','Roles unchanged by password recovery'],
  open_gates:['SMTP provider and DNS approval','Hosted templates/settings approval','Real delivery and physical app-link acceptance','Pilot distribution and two-device QR']};
 await writeFile(resolve(root,'docs/data/merchant_pilot_auth_mail_validation.json'),JSON.stringify(proof,null,2)+'\n');
 await verifyMailProof();
 console.log(`AUTH_MAIL_LOCAL_PASS: ${client.checks.length} real-client checkpoints; no external mail or hosted access.`);
}catch(e){
 console.error('AUTH_MAIL_LOCAL_FAILED at '+stage+'; no remote fallback.');
 if(run)await writeFile(resolve(run.dir,'auth-mail-failure.txt'),e.stack+'\n'+(e.diagnostics??''),{mode:0o600});process.exitCode=1;
}finally{
 if(fixture)await unlink(fixture).catch(()=>{});
 if(mail)await mail.cleanup();
 if(db)await db.end();
}
