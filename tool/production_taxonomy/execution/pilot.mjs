// Builds expected metadata from the UNCHANGED W52H SQL on an isolated real restore.
// This is not the Production executor and is not counted as either final rehearsal.
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { create, session, stop } from './local.mjs';
import { restore } from './restore.mjs';
import { baseline } from './baseline.mjs';
import { catalog, catalogHashes, ledger, ledgerSchema, legacyDataHashes } from './catalog.mjs';
import { integrity, legacyQueries } from '../real_contract_checks.mjs';
import { candidatePath, check, directory, payload, read, root, safeError } from './common.mjs';

let db;
try {
 await create(); const restored=await restore(); db=session();
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const sourceProof=await baseline(db); const before=await catalog(db);
 const contract={format:'w52jb-original-artifact-derived-contract-v1',ledger_schema:await ledgerSchema(db),ledger_baseline:await ledger(db),legacy_data:await legacyDataHashes(db),legacy_queries:{anon:await legacyQueries(db,'anon'),authenticated:await legacyQueries(db,'authenticated')},catalog_before:catalogHashes(before)};
 console.log(JSON.stringify({stage:'ACTUAL_RESTORED_LEDGER_SCHEMA',columns:contract.ledger_schema,rows:contract.ledger_baseline.length}));
 await db.exec("SET esnaftavar.w52h.execution_scope='local-rehearsal';");
 await db.exec(read(candidatePath));
 const after=await catalog(db); const counts=await integrity(db,true);
 contract.catalog_after=catalogHashes(after);
 contract.owned={relations:after.relations.filter(row=>!before.relations.some(b=>b.name===row.name)).map(({name,kind,owner})=>({name,kind,owner})),functions:after.functions.filter(row=>!before.functions.some(b=>b.name===row.name&&b.arguments===row.arguments)).map(({name,arguments:args,owner})=>({name,arguments:args,owner}))};
 check(contract.owned.relations.length>0&&contract.owned.functions.length>0,'OWNED_OBJECTS_REQUIRED');
 writeFileSync(resolve(root,directory,'contract.json'),JSON.stringify(contract,null,2)+'\n');
 const equivalent=payload(); delete equivalent.sql;
 writeFileSync(resolve(root,'docs/data/w52j_b_original_artifact_equivalence.json'),JSON.stringify({result:'PASS',restored,source_proof:sourceProof,counts,equivalence:equivalent,legacy_guard_only_used_for_original_sql_on_local_pilot:true,production_accessed:false},null,2)+'\n');
 console.log(JSON.stringify({result:'PASS',counts,owned_relations:contract.owned.relations.length,owned_functions:contract.owned.functions.length}));
} catch(error) {console.error(safeError(error));process.exitCode=1;}
finally {if(db) await db.close(); try {stop();} catch {}}
