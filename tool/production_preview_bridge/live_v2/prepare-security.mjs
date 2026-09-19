// Local-only expected contract preparation; no live transport import.
import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {Harness,container} from './local-harness.mjs';
import {check,root,stable,hash,literal,payload,project,version,name,safeError} from './common.mjs';
import {securityMetadata,snapshot} from '../execution/catalog.mjs';
import {semanticSecurity,reviewed} from '../execution/security-semantics.mjs';
const h=new Harness();
try{
 check(container==='w52kb-caprepare','CA_PREPARATION_CONTAINER');await h.bootstrap();
 // bootstrap closes its session to create the untouched database checkpoint.
 h.ctx.db=h.ctx.reconnect();const db=h.ctx.db;
 await db.exec("SET search_path=public,extensions; SET timezone='UTC'; SET datestyle='ISO';");
 const actual=await semanticSecurity(db,await securityMetadata(db)),expected=reviewed().semantic_security_before;
 check(stable(actual)===stable(expected),'CA_LOCAL_ORACLE_NOT_VERIFIED_LIVE_SEMANTICS');
 const before=await snapshot(db);
 await db.exec(`BEGIN; SELECT set_config('esnaftavar.w52kb.target_ref',${literal(project)},true);`);
 await db.exec(payload().sql);await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([payload().sql])}::text[]);`);
 const after=await snapshot(db);await db.exec('ROLLBACK;');
 writeFileSync(resolve(root,'tool/production_preview_bridge/execution/contract.json'),JSON.stringify({format:'w52k-ca-semantic-schema-security-v1',source:'Hash-pinned real pre-0012 archive; unchanged 0012; explicit reviewed six-property local platform reconstruction; semantic before matches every verified BZ live security object.',before,after},null,2)+'\n');
 console.log(JSON.stringify({result:'PASS',live_semantic_components:15,reconstruction:h.restore.reconstruction,container_sha256:hash(h.restore.isolation.container_id),production_accessed:false}));
}catch(e){console.error(safeError(e));process.exitCode=1;}finally{await h.close();}
