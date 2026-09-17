// Offline package checks. No database, DNS, HTTP or Production transport calls.
import { readdirSync, readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { candidatePath, check, directory, hash, json, payload, read, root, safeError, stable } from './common.mjs';
import { measuredBundle, verifyBundle } from './seal.mjs';

try {
 const bundle=hash(stable(json(`${directory}/bundle.json`)));verifyBundle(bundle);
 const generated=payload();check(generated.reconstructed_source_sha256===generated.source_sha256,'REVERSE_EQUIVALENCE');
 const owned=new Set(json(`${directory}/contract.json`).owned.relations.map(r=>r.name));
 const mutations=[...generated.sql.matchAll(/^\s*(?:INSERT INTO|UPDATE|DELETE FROM|ALTER TABLE|CREATE TABLE(?: IF NOT EXISTS)?)\s+public\.([a-z_]+)/gm)].map(m=>m[1]);
 check(mutations.length>10&&mutations.every(name=>owned.has(name)),'STATIC_SQL_MUTATION_ALLOWLIST');
 check(!/^\s*(?:COMMIT|ROLLBACK);/m.test(generated.sql),'PAYLOAD_NO_TRANSACTION_ESCAPE');
 check(!/supabase_migrations\.schema_migrations\s*\(/.test(generated.sql),'PAYLOAD_NO_LEDGER_WRITE');
 const engine=read(`${directory}/engine.mjs`);
 check(engine.indexOf('await postflight(db, false)')<engine.indexOf('INSERT INTO supabase_migrations.schema_migrations'),'LEDGER_AFTER_VALIDATION');
 check(engine.includes(' RESTRICT;')&&!/DROP\s+[^\n]*\sCASCADE/i.test(engine),'ROLLBACK_RESTRICT_ONLY');
 const validators=read(`${directory}/validators.mjs`);
 check(!/\b(?:INSERT INTO|UPDATE public\.|DELETE FROM|CREATE TABLE|ALTER TABLE)\b/i.test(validators),'VALIDATORS_NO_MUTATION');
 const files=readdirSync(resolve(root,directory)).filter(n=>n.endsWith('.mjs')).map(n=>`${directory}/${n}`);
 for(const file of files){const result=spawnSync(process.execPath,['--check',resolve(root,file)],{encoding:'utf8',windowsHide:true});check(result.status===0,'NODE_SYNTAX');}
 const evidence=readdirSync(resolve(root,'docs/data')).filter(n=>n.startsWith('w52j_b_')&&n.endsWith('.json')).map(n=>`docs/data/${n}`);
 const scan=[...files,`${directory}/contract.json`,`${directory}/bundle.json`,...evidence];
 const doc='docs/RELEASE_W52J_B_PRODUCTION_EXECUTION_PACKAGE.md';
 try{readFileSync(resolve(root,doc));scan.push(doc);}catch{}
 const forbidden=[/\b(?:sb_secret_|sb_publishable_|ghp_|github_pat_)[A-Za-z0-9_-]+/,/\beyJ[A-Za-z0-9_-]{12,}\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/,/-----BEGIN [A-Z ]*PRIVATE KEY-----/,/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/,/postgres(?:ql)?:\/\/[^\s'"<>]+@/,/[A-Z]:[\\/](?:Users|Esnaftavar)[\\/]/i];
 for(const path of scan){const contents=read(path);check(!contents.includes('\uFFFD'),'ENCODING');for(const pattern of forbidden)check(!pattern.test(contents),'SECRET_PII_LOCAL_PATH_SCAN');}
 const result={result:'PASS',bundle_sha256:bundle,payload_sha256:generated.sha256,original_0012_unchanged:true,semantic_reverse_reconstruction:'PASS',sql_static_mutation_targets:[...new Set(mutations)].sort(),sql_static_validation:'PASS',node_syntax_files:files.length,ledger_atomic_placement:'PASS',rollback_no_cascade:'PASS',read_only_validators:'PASS',secret_pii_absolute_user_path_scan:'PASS',scanned_files:scan.length,production_accessed:false};
 if(process.argv.includes('--complete')){
  const first=json('docs/data/w52j_b_first_rehearsal.json'),second=json('docs/data/w52j_b_second_rehearsal.json'),failures=json('docs/data/w52j_b_failure_injection.json');
  for(const proof of [first,second,failures])check(proof.result==='PASS'&&proof.bundle_sha256===bundle,'SAME_FINAL_PACKAGE_PROOF');
  check(first.restored.isolation.container_id!==second.restored.isolation.container_id,'TWO_FRESH_CLUSTERS');
  check(failures.cases>=8&&failures.results.every(r=>r.result==='PASS'),'FAILURE_SUITE');
  result.final_proof='PASS';result.failure_cases=failures.cases;
 }
 writeFileSync(resolve(root,'docs/data/w52j_b_static_validation.json'),JSON.stringify(result,null,2)+'\n');
 console.log(JSON.stringify(result));
}catch(error){console.error(safeError(error));process.exitCode=1;}
