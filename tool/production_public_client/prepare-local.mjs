// Generate the additive function oracle from an intact real archive, not from
// live metadata or a hand-edited schema. The new SQL is always rolled back.
import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {support,originalArchive} from './local-support.mjs';
import {check,root,directory,payload,hash,stable,literal,project,safeError,functionQuery,functions} from './common.mjs';
import {apply0012,readPostflight} from '../production_taxonomy/execution/engine.mjs';
import {baseline as bridgeBaseline} from '../production_preview_bridge/execution/validators.mjs';
import {payload as bridgePayload,version as bridgeVersion,name as bridgeName} from '../production_preview_bridge/execution/common.mjs';
import {transaction} from '../production_preview_bridge/live_v2/transaction.mjs';
import {snapshot,canonicalData} from '../production_preview_bridge/execution/catalog.mjs';
const s=await support();let db;
const result={format:'w52lb-facade-oracle-preparation-v1',result:'FAIL',source_backup_sha256:originalArchive,production_accessed:false,production_write_performed:false};
try{
 check(s.container==='w52kb-lbprepare','ORACLE_CONTAINER');await s.create();result.restore=await s.restore({reconcileSecurity:true});db=s.session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 await s.baseline(db);await apply0012(db,s.freshBackup());await readPostflight(db);
 await transaction(db,async()=>{await bridgeBaseline(db,false);const b=bridgePayload();await db.exec(b.sql);await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(bridgeVersion)},${literal(bridgeName)},${literal([b.sql])}::text[]);`);return bridgeBaseline(db,true);},{write:true,coreLocks:true});
 const beforeSchema=await snapshot(db),beforeData=await canonicalData(db);
 await db.exec(`BEGIN; SELECT set_config('esnaftavar.w52lb.target_ref',${literal(project)},true);`);
 try{
  await db.exec(payload());
  const rows=(await db.query(functionQuery)).rows.filter(r=>functions.includes(r.name));check(rows.length===4,'FOUR_FUNCTIONS');
  check(stable(await canonicalData(db))===stable(beforeData),'FACADE_CHANGED_DATA');
  const oracle={format:'w52lb-source-derived-function-oracle-v1',source_backup_sha256:originalArchive,source_payload_sha256:hash(payload()),function_rows_sha256:hash(stable(rows)),functions:rows.map(r=>({name:r.name,arguments:r.arguments,sha256:hash(stable(r))}))};
  writeFileSync(resolve(root,directory,'function-oracle.json'),JSON.stringify(oracle,null,2)+'\n');
 }finally{if(!db.closed)await db.exec('ROLLBACK;');}
 check(stable(await snapshot(db))===stable(beforeSchema),'ORACLE_ROLLBACK');result.result='PASS';
}catch(e){result.safe_error=safeError(e);process.exitCode=1;}
finally{
 if(db)try{await db.close();}catch{}try{s.stop();}catch{}
 if(result.restore?.isolation)delete result.restore.isolation.container_id;
 writeFileSync(resolve(s.path,'preparation.json'),JSON.stringify(result,null,2)+'\n');console.log(JSON.stringify({result:result.result,safe_error:result.safe_error,production_accessed:false}));
}
