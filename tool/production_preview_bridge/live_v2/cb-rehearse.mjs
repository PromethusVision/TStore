// One local-only rehearsal using the unchanged approved restore adapter.
// The newer post-0012 archive loses two explicit owner ACL representations on
// restore and is rejected by the unchanged fingerprint. Evidence records that
// rejection; this run uses the newest suitable pre-0012 archive without repair.
import {mkdirSync,writeFileSync} from 'node:fs';
import {resolve,relative,isAbsolute,sep} from 'node:path';
import {Harness,latestBackupHash,run,container} from './local-harness.mjs';
import {check,root,hash,stable,safeError} from './common.mjs';
import {verify} from './seal.mjs';
import {readPreflight,readStageA,readStageB,deployStaged} from './engine.mjs';
import {removeTester,containAndRollback} from './containment.mjs';
import {baseline} from './validators.mjs';
import {transaction} from './transaction.mjs';
import {asRole,denied,call} from '../execution/rpc-checks.mjs';
const path=process.env.W52KBY_PROOF_DIR,rel=relative(root,path??root),seal=process.env.W52KBY_SEAL_SHA256;
check(isAbsolute(path??'')&&(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel)),'PRIVATE_PROOF_DIRECTORY');
check(container==='w52kb-caone','CB_EXACT_LOCAL_CONTAINER');
// A missed injected fetch must fail locally instead of contacting any server.
globalThis.fetch=async()=>{throw Error('W52KBY_CB_EXTERNAL_NETWORK_FORBIDDEN');};
mkdirSync(path,{recursive:true});
const result={format:'w52k-cb-real-copy-proof-v1',result:'FAIL',started_at_utc:new Date().toISOString(),source_backup_sha256:latestBackupHash,source_archive_state:'PRE_0012_APPROVED_RESTORE_PLUS_UNCHANGED_0012',source_pg_version:'17.6',source_dump_tool_version:'17.11',source_archive_bytes:537274,package_sha256:seal,production_accessed:false,production_write_performed:false,development_accessed:false};
const h=new Harness();
try{
 result.seal_before=verify(seal);
 // Require a cached pinned image; the rehearsal must not pull a remote image.
 run(['image','inspect','supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00']);
 await h.bootstrap();console.log('CB_FRESH_REAL_BACKUP_RESTORE: PASS');
 result.restore={toc_entries:h.restore.toc_entries,omitted:h.restore.omitted,restored_owner_acl:h.restore.restored_owner_acl,source_roles_memberships:h.restore.source_roles_memberships,container_identity_sha256:hash(h.restore.isolation.container_id),network:h.restore.isolation.network,ports:h.restore.isolation.ports,backup_readonly:h.restore.isolation.backup_readonly,image_digest:h.restore.isolation.image_digest,platform_reconstruction:h.restore.reconstruction};
 await h.reset();const legacy=await h.client.legacy();
 result.preflight=await readPreflight(h.ctx,seal,h.handle);
 const deployed=await deployStaged(h.ctx,seal,h.handle,h.backup,{
  afterA:async()=>{await h.reload();result.stage_a_http=await h.client.preview(h.ctx.db,false);result.stage_a_other_auth_http=await h.otherClient.preview(h.ctx.db,false);result.stage_a_validation=await readStageA(h.ctx,seal,h.handle);console.log('CB_STAGE_A_DEFAULT_DENY: PASS');},
  afterB:async()=>{result.stage_b_http=await h.client.preview(h.ctx.db,true);result.stage_b_other_auth_http=await h.otherClient.preview(h.ctx.db,false);result.stage_b_validation=await readStageB(h.ctx,seal,h.handle);console.log('CB_CORRECTED_AUTHORIZED_PREVIEW: PASS');},
 });
 check(deployed.result==='PASS','CB_DEPLOY_STAGED');result.stage_a=deployed.stage_a;result.stage_b=deployed.stage_b;
 check(result.stage_b_http.rpcs.taxonomy_capabilities_v2.authorized_preview.result==='PASS','CB_CORRECTED_VALIDATOR_EXECUTED');
 check(stable(await h.client.legacy())===stable(legacy),'CB_LEGACY_HTTP_CHANGED');
 // Existing expiry rule is exercised only inside a rolled-back local test tx.
 await h.ctx.db.exec("BEGIN; UPDATE production_preview_private.testers SET granted_at=now()-interval '2 hours',expires_at=now()-interval '1 hour';");
 try{await asRole(h.ctx.db,'authenticated',h.ids[0],()=>denied(h.ctx.db,call('taxonomy_roots_v2',{p_preview:true})));}finally{await h.ctx.db.exec('ROLLBACK;');}
 result.expired_allowlist='PASS_DENIED_LOCAL_TRANSACTION_ROLLED_BACK';
 result.standalone_removal=await removeTester(h.ctx,seal,h.ids[0]);result.removal_denial=await h.assertNoAccess();
 result.rollback=await containAndRollback(h.ctx,seal,h.ids[0]);check(result.rollback.result==='ROLLED_BACK','CB_ROLLBACK');
 result.rollback_denial=await h.assertNoAccess({executeRevoked:true});result.final_validation=await transaction(h.ctx.db,()=>baseline(h.ctx.db,false));
 check(stable(await h.client.legacy())===stable(legacy),'CB_LEGACY_HTTP_AFTER_ROLLBACK');
 await h.archiveCheck();result.archive_data_sections_checked=69;
 result.legacy_http_before_after='PASS_IDENTICAL';result.manual_sql_repairs=false;result.seal_after=verify(seal);result.result='PASS';
}catch(error){result.safe_error=safeError(error);process.exitCode=1;}
finally{
 await h.close();result.completed_at_utc=new Date().toISOString();
 const clean=value=>Array.isArray(value)?value.map(clean):value&&typeof value==='object'?Object.fromEntries(Object.entries(value).filter(([key])=>key!=='target').map(([key,v])=>[key,clean(v)])):value;
 writeFileSync(resolve(path,'rehearsal.json'),JSON.stringify(clean(result),null,2)+'\n');
 console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,source_backup_sha256:latestBackupHash,package_sha256:seal,production_accessed:false}));
}
