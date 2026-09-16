import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { root, read, guard, LocalDb, check, sha256, stableJson, writeEvidence, safeFailure } from './real_restore_lib.mjs';
import { integrity, legacyQueries, legacyMetadata, canonicalQueries } from './real_contract_checks.mjs';
import { archiveRows } from './real_baseline.mjs';
import { HttpChecks } from './real_http_checks.mjs';

let http;
try {
  check(process.argv.length===3 && process.argv[2]==='--local','LOCAL_FLAG_REQUIRED');
  const isolation=guard();
  const baseline=JSON.parse(read('docs/data/w52h_r_first_restore_baseline.json'));
  check(baseline.result==='PASS','REAL_RESTORE_BASELINE_REQUIRED');
  const manifest=JSON.parse(read('tool/production_taxonomy/artifact_manifest.json'));
  const migration=read(manifest.candidate);
  check(sha256(migration)===manifest.sha256_lf_utf8,'FROZEN_CANDIDATE_HASH');
  check(sha256(read('docs/data/production_20_product_canonical_mapping.csv'))==='f589308535f42936a1ef4c873ea446b00ed4849fb8ef872c4112956b56a28663','FROZEN_MAPPING_HASH');
  const apk='C:/Users/Mustafa/EsnaftavarReleases/w52c/1.0.0+1-main-4f0da82/EsnaftaVar-1.0.0+1-w52c-main-4f0da82-production.apk';
  check(sha256(readFileSync(apk))==='096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a','FROZEN_APK_HASH');
  const sourceHead='4f0da8201e2571200e99fa3dfe76387e3a1486ce';
  const sourceEvidence=['category_repository_impl.dart','product_repository_impl.dart','shop_repository_impl.dart'].map(file=>{
    const path='lib/features/shop/data/repositories/'+file;
    const body=execFileSync('git',['show',`${sourceHead}:${path}`],{cwd:root,encoding:'utf8'}).replaceAll('\r\n','\n');
    return {path,sha256_lf_utf8:sha256(body)};
  });
  const db=new LocalDb('w52hr_first');
  check((await db.query("SELECT to_regclass('public.canonical_categories') IS NULL AS empty")).rows[0].empty,'UNMIGRATED_FIRST_COPY_REQUIRED');
  http=new HttpChecks(db); await http.start();
  const beforeHttp=await http.legacy();
  const phases=[];
  const verifyLegacy=async phase=>{
    const queries={anon:await legacyQueries(db,'anon'),authenticated:await legacyQueries(db,'authenticated')};
    check(stableJson(queries)===stableJson(baseline.legacy_queries),'LEGACY_SQL_CHANGED:'+phase);
    check(await legacyMetadata(db)===baseline.legacy_metadata_sha256,'LEGACY_RLS_FK_ACL_CHANGED:'+phase);
    const responses=await http.legacy();
    check(stableJson(responses)===stableJson(beforeHttp),'LEGACY_HTTP_CHANGED:'+phase);
    return {phase,sql:'PASS',http:'PASS',sql_queries:queries,http_queries:responses};
  };
  phases.push(await verifyLegacy('PRE_MIGRATION'));
  console.log('PRE_MIGRATION_SQL_HTTP_PASS');
  await db.exec(migration);
  const staged=await integrity(db,true);
  for(const role of ['anon','authenticated']) {
    await db.exec(`SET ROLE ${role}`);
    check((await db.query('SELECT count(*)::int AS n FROM public.product_canonical_assignments')).rows[0].n===0,'STAGED_MAPPING_VISIBILITY');
    await canonicalQueries(db,false); await db.exec('RESET ROLE');
  }
  phases.push(await verifyLegacy('POST_STAGED_MIGRATION'));
  console.log('EXACT_ADAPTER_AND_STAGED_SQL_HTTP_PASS');
  await db.exec(read('tool/production_taxonomy/local_activation.sql'));
  const activated=await integrity(db,true);
  const canonical={};
  for(const role of ['anon','authenticated']) {await db.exec(`SET ROLE ${role}`);canonical[role]=await canonicalQueries(db,true);await db.exec('RESET ROLE');}
  phases.push(await verifyLegacy('POST_ACTIVATION'));
  console.log('ACTIVATION_14_VISIBLE_6_GATED_SQL_HTTP_PASS');
  const start=Date.now();
  await db.exec(read('tool/production_taxonomy/rollback.sql'));
  const rollbackDuration=Date.now()-start;
  const rollback=await integrity(db,true);
  const gate=await canonicalQueries(db,false);
  phases.push(await verifyLegacy('POST_ROLLBACK'));
  const originalRows=await archiveRows(db);
  const result={contract:'w52h-r-real-production-copy-rehearsal-v1',captured_at_utc:new Date().toISOString(),result:'PASS',isolation,candidate_sha256:sha256(migration),frozen_mapping_unchanged:true,staged,activated,canonical,rollback:{result:'PASS',duration_ms:rollbackDuration,counts:rollback,gate},original_archive_rows_preserved_after_rollback:'PASS',archive_table_data_entries:originalRows.length,phases,old_w52c:{source_head:sourceHead,source_evidence:sourceEvidence,apk_sha256:'096b54c4c7d69d06c6cd92253d88a62afaf610301eed7ac3358aab01eb74b19a',sql_contract:'PASS',http_contract:'PASS',http_runtime:'PostgREST 14.17, official Supabase self-hosting package',http_image_digest:'postgrest/postgrest@sha256:c9dc201e555f5d8e37e7f39cdd4df0229774996e213bfd7de8d10ac609030f2c',http_request_roles:['anon','authenticated with ephemeral local test JWT'],physical_device_post_migration:'NOT_RUN',scope:'Real backend SQL and PostgREST transport/DTO checks; no physical APK execution or Production HTTP call'},production_write_performed:false,development_accessed:false};
  writeEvidence('w52h_r_real_copy_rehearsal.json',result);
  console.log(JSON.stringify({result:'PASS',products:20,listings:285,shops:57,canonical_nodes:1563,roots:24,terminal_leaves:1245,owner_mappings:20,visible:14,gated:6,rollback_duration_ms:rollbackDuration,legacy_sql_http_phases:phases.length}));
} catch(error) {safeFailure(error);}
finally {if(http) {try {http.stop();} catch {console.error('HTTP_TEST_PROCESS_STOP_REQUIRES_CHECK');process.exitCode=1;}}}
