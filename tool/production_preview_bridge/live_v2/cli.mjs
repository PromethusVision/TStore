import {readFileSync} from 'node:fs';
import {isAbsolute,relative,resolve,sep} from 'node:path';
import {check,hash,root,project,safeError,stable,uuid,operationSucceeded} from './common.mjs';
import {verify} from './seal.mjs';
import {readExistingSession,resolveIdentity,recoverySubject,subject,disposeIdentity,origin} from './identity.mjs';
import {connectionFactory} from './production.mjs';
import {validateBackup} from '../../production_taxonomy/execution/common.mjs';
import {settings} from './validators.mjs';
import {readPreflight,readStageA,readStageB,stageA,stageB,deployStaged} from './engine.mjs';
import {removeTester,containAndRollback} from './containment.mjs';
import {httpClient} from './http.mjs';
function parse(){
 const [operation,...args]=process.argv.slice(2);check(settings().operations.includes(operation),'OPERATION_REQUIRED');
 const options={operation},fields=['seal-sha256','session-cache','client-config','psql','psql-sha256','ca','ca-sha256','backup','backup-metadata','lease-seconds'];
 for(let i=0;i<args.length;i++){
  const name=args[i];if(name==='--production-authorized'||name==='--recovery-stdin'){const key=name.slice(2).replaceAll('-','_');check(!options[key],'DUPLICATE_OPTION');options[key]=true;continue;}
  const key=name?.slice(2).replaceAll('-','_');check(name?.startsWith('--')&&fields.includes(name.slice(2))&&!Object.hasOwn(options,key)&&args[i+1]&&!args[i+1].startsWith('--'),'UNKNOWN_OR_DUPLICATE_OPTION');options[key]=args[++i];
 }return options;
}
function external(path){check(isAbsolute(path??''),'EXTERNAL_INPUT_REQUIRED');const rel=relative(root,resolve(path));check(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel),'INPUT_MUST_STAY_OUTSIDE_REPO');return readFileSync(path);}
let ctx,factory,handle,options;
try{
 options=parse();verify(options.seal_sha256);check(options.production_authorized===true,'EXPLICIT_LIVE_AUTHORIZATION_REQUIRED');
 const removal=['remove-tester','rollback-bridge'].includes(options.operation);let uid,client,backup;
 if(removal){
  if(options.recovery_stdin){const input=JSON.parse(readFileSync(0,'utf8'));check(Object.keys(input).sort().join(',')==='project_ref,user_id'&&input.project_ref===project&&uuid(input.user_id),'EXACT_RECOVERY_SUBJECT_REQUIRED');uid=input.user_id;}
  else uid=recoverySubject(readExistingSession(options.session_cache));
 }else{
  check(!options.recovery_stdin,'RECOVERY_INPUT_CANNOT_AUTHORIZE');
  const config=JSON.parse(external(options.client_config).toString('utf8').replace(/^\uFEFF/,''));check(config.SUPABASE_PRODUCTION_URL.replace(/\/$/,'')===origin&&config.PRODUCTION_PROJECT_REF===project,'CLIENT_PROJECT_MISMATCH');
  handle=await resolveIdentity(readExistingSession(options.session_cache),config.SUPABASE_PRODUCTION_ANON_KEY);uid=subject(handle);client=httpClient(config.SUPABASE_PRODUCTION_ANON_KEY,handle);
 }
 if(['stage-a','deploy-staged'].includes(options.operation))backup=validateBackup(JSON.parse(external(options.backup_metadata)),external(options.backup));
 factory=connectionFactory(options);ctx={db:factory.open(),reconnect:()=>factory.open(),bridgeWriteAttempted:false};
 const seconds=options.lease_seconds===undefined?undefined:Number(options.lease_seconds);
 let result;
 if(removal)result=options.operation==='remove-tester'?await removeTester(ctx,options.seal_sha256,uid):await containAndRollback(ctx,options.seal_sha256,uid);
 else{
  const before=await client.legacy();
  if(options.operation==='preflight')result=await readPreflight(ctx,options.seal_sha256,handle);
  if(options.operation==='stage-a'){result=await stageA(ctx,options.seal_sha256,handle,backup);await readStageA(ctx,options.seal_sha256,handle);await client.preview(ctx.db,false);}
  if(options.operation==='validate-a'){result=await readStageA(ctx,options.seal_sha256,handle);await client.preview(ctx.db,false);}
  if(options.operation==='stage-b'){await client.preview(ctx.db,false);result=await stageB(ctx,options.seal_sha256,handle,seconds);await client.preview(ctx.db,true);}
  if(options.operation==='postflight'){result=await readStageB(ctx,options.seal_sha256,handle);await client.preview(ctx.db,true);}
  if(options.operation==='deploy-staged')result=await deployStaged(ctx,options.seal_sha256,handle,backup,{seconds,afterA:()=>client.preview(ctx.db,false),afterB:()=>client.preview(ctx.db,true)});
  check(stable(await client.legacy())===stable(before),'LEGACY_HTTP_CHANGED');
 }
 console.log(JSON.stringify({operation:options.operation,result:result.result,transaction:result.transaction,containment:result.containment?.result,bridge_removed:result.bridge_removed,core_health:result.core_health,preview_access_disabled:result.preview_access_disabled}));
 if(!operationSucceeded(options.operation,result.result))process.exitCode=1;
}catch(error){
 let containment;
 // A later error must not strand a previously committed Stage A/B. Recovery
 // uses the verified in-memory identity even if its session just expired.
 if(ctx&&handle&&(ctx.bridgeWriteAttempted||['stage-b','validate-a','postflight'].includes(options.operation)))try{containment=await containAndRollback(ctx,options.seal_sha256,subject(handle,{containment:true}));}catch{}
 console.error(JSON.stringify({result:containment?.result??'STOPPED_BEFORE_WRITE',safe_error:safeError(error),preview_access_disabled:containment?.preview_access_disabled}));process.exitCode=1;
}finally{if(handle)disposeIdentity(handle);if(ctx?.db)await ctx.db.close();factory?.dispose();delete process.env.PGPASSWORD;}
