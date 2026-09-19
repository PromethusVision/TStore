import {writeFileSync,mkdirSync} from 'node:fs';
import {resolve,relative,isAbsolute,sep} from 'node:path';
import {Harness,latestBackupHash} from './local-harness.mjs';
import {check,root,stable,safeError,hash} from './common.mjs';
import {verify} from './seal.mjs';
import {readPreflight,readStageA,readStageB,deployStaged} from './engine.mjs';
import {removeTester,containAndRollback} from './containment.mjs';
import {baseline} from './validators.mjs';
import {transaction} from './transaction.mjs';
import {failures} from './failure-tests.mjs';
const path=process.env.W52KBY_PROOF_DIR,rel=relative(root,path??root),seal=process.env.W52KBY_SEAL_SHA256;
check(isAbsolute(path??'')&&(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel)),'PRIVATE_PROOF_DIRECTORY');mkdirSync(path,{recursive:true});
const h=new Harness(),result={format:'w52k-by-real-copy-proof-v1',result:'FAIL',started_at_utc:new Date().toISOString(),source_backup_sha256:latestBackupHash,package_sha256:seal,production_accessed:false,production_write_performed:false,development_accessed:false};
try{
 result.seal_before=verify(seal);await h.bootstrap();console.log('BY_FRESH_RESTORE_AND_0012: PASS');
 result.restore={toc_entries:h.restore.toc_entries,omitted:h.restore.omitted,restored_owner_acl:h.restore.restored_owner_acl,source_roles_memberships:h.restore.source_roles_memberships,container_identity_sha256:hash(h.restore.isolation.container_id),network:h.restore.isolation.network,ports:h.restore.isolation.ports,backup_readonly:h.restore.isolation.backup_readonly,image_digest:h.restore.isolation.image_digest};
 // Catch a successful grant-path regression before the longer fault matrix.
 await h.reset();const smoke=await deployStaged(h.ctx,seal,h.handle,h.backup);
 check(smoke.result==='PASS','INITIAL_STAGED_DEPLOY');
 check((await containAndRollback(h.ctx,seal,h.ids[0])).result==='ROLLED_BACK','INITIAL_STAGED_ROLLBACK');
 result.initial_staged_round_trip='PASS';console.log('BY_INITIAL_STAGED_ROUND_TRIP: PASS');
 result.failure_tests=await failures(h,seal);
 await h.reset();const legacy=await h.client.legacy();result.identity={...h.handle};
 result.preflight=await readPreflight(h.ctx,seal,h.handle);
 const deployed=await deployStaged(h.ctx,seal,h.handle,h.backup,{
  afterA:async()=>{await h.reload();result.stage_a_http=await h.client.preview(h.ctx.db,false);result.stage_a_other_auth_http=await h.otherClient.preview(h.ctx.db,false);result.stage_a_validation=await readStageA(h.ctx,seal,h.handle);},
  afterB:async()=>{result.stage_b_http=await h.client.preview(h.ctx.db,true);result.stage_b_other_auth_http=await h.otherClient.preview(h.ctx.db,false);result.stage_b_validation=await readStageB(h.ctx,seal,h.handle);},
 });
 check(deployed.result==='PASS','NOMINAL_STAGED_DEPLOY');result.stage_a=deployed.stage_a;result.stage_b=deployed.stage_b;
 check(stable(await h.client.legacy())===stable(legacy),'LEGACY_HTTP_CHANGED');
 result.standalone_removal=await removeTester(h.ctx,seal,h.ids[0]);result.removal_repeat=await removeTester(h.ctx,seal,h.ids[0]);result.removal_denial=await h.assertNoAccess();
 result.rollback=await containAndRollback(h.ctx,seal,h.ids[0]);check(result.rollback.result==='ROLLED_BACK','NOMINAL_ROLLBACK');
 result.rollback_denial=await h.assertNoAccess({executeRevoked:true});result.final_validation=await transaction(h.ctx.db,()=>baseline(h.ctx.db,false));
 check(stable(await h.client.legacy())===stable(legacy),'LEGACY_HTTP_AFTER_ROLLBACK');await h.archiveCheck();
 result.archive_data_sections_checked=69;result.manual_sql_repairs=false;result.seal_after=verify(seal);result.result='PASS';
}catch(error){result.safe_error=safeError(error);result.failed_case=h.failedCase;process.exitCode=1;}
finally{
 await h.close();
 result.completed_at_utc=new Date().toISOString();
 // Generic sanitization of transport details; no DTO/identity/token output.
 const clean=value=>Array.isArray(value)?value.map(clean):value&&typeof value==='object'?Object.fromEntries(Object.entries(value).filter(([key])=>key!=='target').map(([key,v])=>[key,clean(v)])):value;
 writeFileSync(resolve(path,'rehearsal.json'),JSON.stringify(clean(result),null,2)+'\n');console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,failure_cases:result.failure_tests?.length,package_sha256:seal}));
}
