import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {check,json,directory,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {connectionFactory} from './production.mjs';
import {readState,deploy,rollback,reconcile} from './engine.mjs';
import {artifactGate} from './artifact.mjs';
export function parse(argv){
 const [operation,...args]=argv;check(json(directory+'/runtime-manifest.json').operations.includes(operation),'OPERATION_REQUIRED');
 const options={operation};
 const fields=['seal-sha256','sql-sha256','project-ref','psql','psql-sha256','ca','ca-sha256','pg-dump','pg-dump-sha256','pg-restore','pg-restore-sha256','backup','backup-metadata','apk','aab'];
 for(let i=0;i<args.length;i++){
  const arg=args[i],key=arg?.slice(2).replaceAll('-','_');
  check(arg?.startsWith('--')&&!Object.hasOwn(options,key),'UNKNOWN_OR_DUPLICATE_OPTION');
  if(arg==='--production-authorized'){options.production_authorized=true;continue;}
  check(fields.includes(arg.slice(2))&&args[i+1]&&!args[i+1].startsWith('--'),'UNKNOWN_OR_DUPLICATE_OPTION');options[key]=args[++i];
 }
 check(options.production_authorized===true,'EXPLICIT_LIVE_AUTHORIZATION_REQUIRED');return options;
}
export async function run(argv){
 let options,factory,db;const result={result:'STOPPED_BEFORE_WRITE',production_write_attempted:false,public_activation_performed:false};
 try{
  options=parse(argv);verify(options.seal_sha256);if(['preflight','activate'].includes(options.operation))artifactGate(options);factory=connectionFactory(options);db=factory.open();
  if(options.operation==='preflight')await readState(db,options);
  else if(options.operation==='postflight')await readState(db,options,true);
  else if(options.operation==='activate')await deploy(db,options,()=>factory.backup());
  else await rollback(db,options);
  result.result='PASS';result.operation=options.operation;result.public_activation_performed=options.operation==='activate';
 }catch(e){
  result.safe_error=safeError(e);
  if(options?.operation==='activate'&&options.write_attempted)result.public_activation_performed='UNKNOWN_PENDING_RECONCILIATION';
  if(options?.write_attempted){
   result.result='STOPPED_REQUIRES_RECONCILIATION';
   if(options.operation==='activate'&&factory){
    try{if(db)await db.close();db=null;result.reconciliation=await reconcile(factory,options);result.result=result.reconciliation.result;if(result.result==='ROLLED_BACK_0014_ONLY'){result.public_activation_performed=true;result.public_enabled_final=false;}else if(result.result==='BASELINE_NO_WRITE'){result.public_enabled_final=false;}}catch{result.result='STOPPED_REQUIRES_REVIEW';}
   }
  }
 }finally{
  try{if(db)await db.close();}finally{factory?.dispose();delete process.env.PGPASSWORD;result.production_write_attempted=options?.write_attempted===true;result.child_pgpassword_cleared=true;}
 }
 return result;
}
if(process.argv[1]&&import.meta.url===pathToFileURL(resolve(process.argv[1])).href){
 const result=await run(process.argv.slice(2));console.log(JSON.stringify(result));if(result.result!=='PASS')process.exitCode=1;
}
