// Local contract capture only; never an option in the live executor.
import {writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {bootstrap,guard,stop,container} from './local-support.mjs';
import {root,directory,payload,literal,version,name,project,safeError,check} from './common.mjs';
import {snapshot} from './catalog.mjs';
let db;
try{
 check(container==='w52kb-bxprepare','BX_PREPARATION_CONTAINER');
 check(process.argv.length===2,'BX_PREPARATION_ARGUMENT');({db}=await bootstrap());guard();
 const before=await snapshot(db);
 await db.exec(`BEGIN; SELECT set_config('esnaftavar.w52kb.target_ref',${literal(project)},true);`);
 await db.exec(payload().sql);
 await db.exec(`INSERT INTO supabase_migrations.schema_migrations(version,name,statements) VALUES(${literal(version)},${literal(name)},${literal([payload().sql])}::text[]);`);
 const after=await snapshot(db);await db.exec('ROLLBACK;');
 writeFileSync(resolve(root,directory,'contract.json'),JSON.stringify({format:'w52k-bx-schema-security-v1',source:'Newest real pre-0012 archive; exact reviewed 0012 reconstituted locally',before,after},null,2)+'\n');
 console.log('LOCAL_CONTRACT_PREPARATION: PASS');
}catch(error){console.error(safeError(error));process.exitCode=1;}
finally{if(db)await db.close();try{stop();}catch{}}
