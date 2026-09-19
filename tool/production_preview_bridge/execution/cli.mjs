import {readFileSync} from 'node:fs';
import {isAbsolute,relative,sep,resolve} from 'node:path';
import {check,hash,root,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {validatePlan} from './authorization.mjs';
import {connect} from './production.mjs';
import {validateBackup} from '../../production_taxonomy/execution/common.mjs';
import {readPreflight,readPostflight,readRollbackValidation,deploy,rollback,revoke} from './engine.mjs';
export function parse(argv){
 const [operation,...rest]=argv;
 check(['preflight','deploy-0013','postflight','rollback-0013','validate-rollback','revoke-testers'].includes(operation),'BX_OPERATION_REQUIRED');
 const options={operation},allowed=['package-sha256','plan','plan-sha256','psql','psql-sha256','ca','ca-sha256','backup','backup-metadata'];
 for(let i=0;i<rest.length;i++){
  const flag=rest[i];if(flag==='--production-authorized'){check(!options.production_authorized,'BX_DUPLICATE_FLAG');options.production_authorized=true;continue;}
  const key=flag?.slice(2);check(flag?.startsWith('--')&&allowed.includes(key)&&rest[i+1]&&!rest[i+1].startsWith('--')&&!Object.hasOwn(options,key.replaceAll('-','_')),'BX_UNKNOWN_OR_DUPLICATE_OPTION');options[key.replaceAll('-','_')]=rest[++i];
 }
 return options;
}
function external(path){check(isAbsolute(path??''),'BX_PRIVATE_INPUT_ABSOLUTE');const rel=relative(root,resolve(path));check(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel),'BX_PRIVATE_INPUT_OUTSIDE_REPO');return readFileSync(path);}
let db;
try{
 const options=parse(process.argv.slice(2));
 verify(options.package_sha256); // Before password access, tool spawn or connection.
 let plan,backup;
 if(['preflight','postflight','deploy-0013','revoke-testers'].includes(options.operation)){
  const bytes=external(options.plan);check(hash(bytes)===options.plan_sha256,'BX_APPROVED_PLAN_HASH');plan=validatePlan(JSON.parse(bytes),Date.now(),options.operation==='revoke-testers');
 }
 if(options.operation==='deploy-0013')backup=validateBackup(JSON.parse(external(options.backup_metadata)),external(options.backup));
 db=connect(options);
 const ops={preflight:()=>readPreflight(db,options.package_sha256,plan),'postflight':()=>readPostflight(db,options.package_sha256,plan),'deploy-0013':()=>deploy(db,options.package_sha256,plan,backup),'rollback-0013':()=>rollback(db,options.package_sha256),'validate-rollback':()=>readRollbackValidation(db,options.package_sha256),'revoke-testers':()=>revoke(db,options.package_sha256,plan)};
 const result=await ops[options.operation]();
 console.log(JSON.stringify({operation:options.operation,result:result.result,transaction:result.transaction,package_sha256:options.package_sha256,public_activation:false,production_write_performed:['deploy-0013','rollback-0013','revoke-testers'].includes(options.operation)}));
}catch(error){console.error(safeError(error));process.exitCode=1;}
finally{delete process.env.PGPASSWORD;if(db)await db.close();}
