// W52J-C: latest real archive, source ICU locale, unchanged migration, isolated only.
import { writeFileSync } from 'node:fs';
import { isAbsolute, resolve } from 'node:path';
import { create, session, stop, run, container, freshBackup, guard, latestBackupHash, dump } from './local.mjs';
import { readFileSync } from 'node:fs';
import { restore } from './restore.mjs';
import { baseline } from './baseline.mjs';
import { HttpChecks } from './http.mjs';
import { apply0012, rollback0012, readPreflight, readPostflight } from './engine.mjs';
import { check, hash, json, payload, safeError, stable } from './common.mjs';
import { verifyBundle } from './seal.mjs';

let db,http;
try {
 const stage=process.argv[2];check(['first','second'].includes(stage),'FINGERPRINT_REHEARSAL_STAGE');
 check(isAbsolute(process.env.W52JC_PROOF_DIR??''),'PRIVATE_PROOF_DIRECTORY');
 check(hash(readFileSync(dump))===latestBackupHash,'LATEST_REAL_BACKUP_REQUIRED');
 const bundle=hash(stable(json('tool/production_taxonomy/execution/bundle.json')));verifyBundle(bundle);
 await create();const restored=await restore();db=session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const locale=(await db.query("SELECT datlocprovider::text AS provider,datlocale,datcollversion,pg_database_collation_actual_version(oid) AS actual_version FROM pg_database WHERE datname=current_database()")).rows[0];
 check(locale.provider==='i'&&locale.datlocale==='en-US'&&locale.datcollversion==='153.121'&&locale.actual_version==='153.121','EXACT_LIVE_ICU_ENVIRONMENT');
 const before=await baseline(db);
 const archive=run(['cp','w52hr-pg176-proof:/tmp/postgrest','-'],undefined,true);run(['cp','-',`${container}:/tmp`],archive);
 http=new HttpChecks(db);await http.start();const httpBefore=await http.legacy();
 const backup=freshBackup(),preflight=await readPreflight(db,backup);
 console.log(`${stage}: UPDATED_READONLY_PREFLIGHT_PASS`);
 const applied=await apply0012(db,backup),postflight=await readPostflight(db);
 check(applied.readonly_preflight.transaction==='READ_ONLY_COMPLETED','READONLY_GATE_BEFORE_WRITE');
 const policy=(await db.query("SELECT count(*) FILTER(WHERE q.qualification='LEAF_ASSIGNABLE_CANDIDATE')::int AS eligible,count(*) FILTER(WHERE q.qualification<>'LEAF_ASSIGNABLE_CANDIDATE')::int AS gated FROM public.product_canonical_assignments a JOIN public.canonical_category_qualification q ON q.category_id=a.canonical_category_id")).rows[0];
 check(policy.eligible===14&&policy.gated===6,'STAGED_POLICY_COUNTS');
 const breadcrumbs=(await db.query("WITH RECURSIVE tree AS (SELECT id,parent_id,level,ARRAY[name]::text[] AS names FROM public.canonical_categories WHERE parent_id IS NULL UNION ALL SELECT c.id,c.parent_id,c.level,t.names||c.name FROM public.canonical_categories c JOIN tree t ON c.parent_id=t.id) SELECT count(*)::int AS mapped,count(*) FILTER(WHERE a.canonical_path=array_to_string(t.names,' > ') AND cardinality(t.names)=t.level)::int AS valid FROM public.product_canonical_assignments a JOIN tree t ON t.id=a.canonical_category_id")).rows[0];
 check(breadcrumbs.mapped===20&&breadcrumbs.valid===20,'STAGED_BREADCRUMBS');
 const httpAfter=await http.legacy();check(stable(httpBefore)===stable(httpAfter),'LEGACY_HTTP_CHANGED');
 console.log(`${stage}: ATOMIC_APPLY_LEDGER_POSTFLIGHT_PASS`);
 const rollback=await rollback0012(db),afterPreflight=await readPreflight(db,backup),after=await baseline(db);
 check(stable(before)===stable(after),'FULL_ARCHIVE_STATE_AFTER_ROLLBACK');
 const httpRollback=await http.legacy();check(stable(httpBefore)===stable(httpRollback),'HTTP_AFTER_ROLLBACK');
 let deliberateMismatch={result:'NOT_RUN_SECOND_COPY'};
 if(stage==='first'){
  guard();
  await db.exec('ALTER TABLE public.categories ADD CONSTRAINT w52jc_fingerprint_probe CHECK (sort_order >= -2147483648) NOT VALID;');
  const exec=db.exec.bind(db);let enteredReadWrite=false,payloadSent=false,errorCode;
  db.exec=async sql=>{if(sql.includes('READ COMMITTED READ WRITE'))enteredReadWrite=true;if(sql===payload().sql)payloadSent=true;return exec(sql);};
  try{await apply0012(db,backup);}catch(error){errorCode=safeError(error);}finally{db.exec=exec;}
  check(errorCode==='W52JB_SCHEMA_FINGERPRINT_BASELINE_CONSTRAINTS'&&!enteredReadWrite&&!payloadSent,'MISMATCH_MUST_STOP_BEFORE_WRITE');
  await db.exec('ALTER TABLE public.categories DROP CONSTRAINT w52jc_fingerprint_probe;');
  await readPreflight(db,backup);
  deliberateMismatch={result:'PASS',error_code:errorCode,read_write_transaction_entered:false,payload_sent:false,local_test_constraint_removed:true};
 }
 const result={result:'PASS',stage,captured_at_utc:new Date().toISOString(),bundle_sha256:bundle,source_backup_sha256:latestBackupHash,source_locale:locale,restored_toc_entries:restored.toc_entries,omitted_restore_entries:restored.omitted,all_69_archive_table_data:'PASS',preflight,applied,postflight,canonical_staged:{policy,breadcrumbs},http:{before:httpBefore,after:httpAfter,rollback:httpRollback,exact_match:'PASS'},rollback,post_rollback_preflight:afterPreflight,deliberate_fingerprint_mismatch:deliberateMismatch,production_accessed:false,production_write_performed:false,manual_live_repairs:0};
 writeFileSync(resolve(process.env.W52JC_PROOF_DIR,`${stage}-rehearsal.json`),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify({stage,result:'PASS',deliberate_mismatch:deliberateMismatch.result,counts:postflight.counts}));
}catch(error){console.error(safeError(error));process.exitCode=1;}
finally{if(http)try{http.stop();}catch{} if(db)try{await db.close();}catch{} try{stop();}catch{}}
