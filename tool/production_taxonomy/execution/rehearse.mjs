import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { create, session, stop, run, container, freshBackup } from './local.mjs';
import { restore } from './restore.mjs';
import { baseline } from './baseline.mjs';
import { HttpChecks } from './http.mjs';
import { apply0012, rollback0012, readPreflight, readPostflight } from './engine.mjs';
import { check, hash, json, root, safeError, stable } from './common.mjs';
import { verifyBundle } from './seal.mjs';

let db,http;
try {
 const stage=process.argv[2]; check(['first','second'].includes(stage),'REHEARSAL_STAGE');
 const bundle=hash(stable(json('tool/production_taxonomy/execution/bundle.json'))); verifyBundle(bundle);
 await create(); const restored=await restore(); db=session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const before=await baseline(db);
 // Existing local PostgREST binary only; no download and no outbound network.
 const archive=run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);
 run(['cp','-',`${container}:/tmp`],archive);
 http=new HttpChecks(db); await http.start(); const httpBefore=await http.legacy();
 const backup=freshBackup(); const preflight=await readPreflight(db,backup);
 console.log(JSON.stringify({stage,step:'PREFLIGHT_PASS'}));
 const applied=await apply0012(db,backup); const postflight=await readPostflight(db);
 const httpAfter=await http.legacy(); check(stable(httpBefore)===stable(httpAfter),'HTTP_CHANGED_AFTER_APPLY');
 console.log(JSON.stringify({stage,step:'APPLY_LEDGER_POSTFLIGHT_PASS'}));
 const rollback=await rollback0012(db); const rolledBack=await readPreflight(db,backup);
 const after=await baseline(db); const httpRollback=await http.legacy();
 check(stable(httpBefore)===stable(httpRollback),'HTTP_CHANGED_AFTER_ROLLBACK');
 check(stable(before)===stable(after),'FULL_BASELINE_CHANGED_AFTER_ROLLBACK');
 const result={format:'w52jb-real-copy-execution-proof-v1',result:'PASS',stage,captured_at_utc:new Date().toISOString(),bundle_sha256:bundle,restored,baseline:before,preflight,applied,postflight,http:{before:httpBefore,after_apply:httpAfter,after_rollback:httpRollback,exact_match:'PASS'},rollback,rolled_back_preflight:rolledBack,full_69_table_baseline_after_rollback:'PASS',manual_sql_repairs:0,production_accessed:false,production_write_performed:false};
 writeFileSync(resolve(root,`docs/data/w52j_b_${stage}_rehearsal.json`),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({stage,result:'PASS',counts:postflight.counts,rollback:rollback.result,bundle_sha256:bundle}));
} catch(error) { console.error(safeError(error));process.exitCode=1; }
finally {if(http)try{http.stop();}catch{} if(db)await db.close();try{stop();}catch{}}
