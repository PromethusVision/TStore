// Isolated source-oracle preparation and newest-archive suitability check.
import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {support,newestArchive,originalArchive} from './local-support.mjs';
import {check,root,directory,body,hash,stable,literal,project,safeError} from './common.mjs';
import {apply0012,readPostflight} from '../production_taxonomy/execution/engine.mjs';
import {baseline as bridgeBaseline} from '../production_preview_bridge/execution/validators.mjs';
import {payload as bridgePayload,version as bridgeVersion,name as bridgeName} from '../production_preview_bridge/execution/common.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';
import {structuralData,policy,preservedData} from './policy.mjs';
import {publicContract} from './compatibility.mjs';
import {catalog} from '../production_preview_bridge/execution/catalog.mjs';
const newest=process.argv.includes('--newest'),s=await support({newest});
let db;
const result={format:'w52la-local-preparation-v1',result:'FAIL',source_backup_sha256:newest?newestArchive:originalArchive,production_accessed:false,production_write_performed:false,development_accessed:false};
try{
 s.run(['image','inspect',s.imageDigest]);await s.create();result.restore=await s.restore({reconcileSecurity:true});db=s.session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const archive=await s.archiveRows(db);result.archive_data_sections=archive.length;
 if(newest){
  // No applying 0012 again and no ACL repair to force a fingerprint match.
  try{await readPostflight(db);result.suitability='PASS';}catch(e){
   result.suitability='FAIL';result.safe_error=safeError(e);
   result.owner_acl_metadata=(await catalog(db)).relations.filter(r=>['canonical_categories','canonical_category_qualification'].includes(r.name));
  }
  result.result='PASS_SUITABILITY_CHECK_COMPLETED';
 }else{
  await s.baseline(db);await apply0012(db,s.freshBackup());await readPostflight(db);
  await transaction(db,async()=>{
   await bridgeBaseline(db,false);const b=bridgePayload();await db.exec(b.sql);
   await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(bridgeVersion)},${literal(bridgeName)},${literal([b.sql])}::text[]);`);
   await bridgeBaseline(db,true);return {result:'PASS'};
  },{write:true,coreLocks:true});
  const staged=await structuralData(db),preserved=await preservedData(db);await policy(db,false);
  await db.exec(`BEGIN; SELECT set_config('esnaftavar.w52la.target_ref',${literal(project)},true);`);
  try{
   await db.exec(body(false));result.policy=await policy(db,true);result.canonical=await publicContract(db,true);
   const active=await structuralData(db);check(stable(await preservedData(db))===stable(preserved),'ORACLE_UNREVIEWED_MUTATION');
   const oracle={format:'w52la-immutable-source-derived-states-v1',source_backup_sha256:originalArchive,derivation:'Full original archive restore; unchanged approved 0012 and 0013 payloads; reviewed public-state SQL inside a rolled-back isolated transaction',excluded_cross_install_fields:['created_at','updated_at','applied_at'],staged,active};
   writeFileSync(resolve(root,directory,'state-oracle.json'),JSON.stringify(oracle,null,2)+'\n');
  }finally{await db.exec('ROLLBACK;');}
  check(stable(await structuralData(db))===stable(staged),'ORACLE_ROLLBACK');result.result='PASS';
 }
}catch(e){result.safe_error=safeError(e);process.exitCode=1;}
finally{
 if(db)await db.close();try{s.stop();}catch{}
 if(result.restore?.isolation){const i=result.restore.isolation;delete i.container_id;delete i.project_ref;}
 writeFileSync(resolve(s.path,'preparation.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({result:result.result,suitability:result.suitability,safe_error:result.safe_error,production_accessed:false}));
}
