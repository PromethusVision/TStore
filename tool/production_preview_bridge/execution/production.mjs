// Future authorized transport only. Merely importing this module never connects.
import {readFileSync} from 'node:fs';
import {isAbsolute} from 'node:path';
import {spawnSync} from 'node:child_process';
import {check,hash,project} from './common.mjs';
import {PsqlSession,psqlFlags} from '../../production_taxonomy/execution/session.mjs';
export const endpoint={host:`db.${project}.supabase.co`,port:5432,database:'postgres',username:'postgres'};
export function connect(options){
 check(options.production_authorized===true,'BX_LIVE_AUTHORIZATION_REQUIRED');
 check(isAbsolute(options.psql??'')&&isAbsolute(options.ca??''),'BX_TRUSTED_TOOL_PATHS');
 check(hash(readFileSync(options.psql))===options.psql_sha256&&hash(readFileSync(options.ca))===options.ca_sha256,'BX_TOOL_OR_CA_HASH');
 const environment={...process.env};
 for(const key of Object.keys(environment))if(/^PG/i.test(key))delete environment[key];
 check(typeof process.env.PGPASSWORD==='string'&&process.env.PGPASSWORD.length>0,'BX_OWNER_SESSION_PASSWORD_REQUIRED');
 environment.PGPASSWORD=process.env.PGPASSWORD;
 // Clear the executor's inherited copy immediately; the owner must clear theirs.
 delete process.env.PGPASSWORD;
 Object.assign(environment,{PGHOST:endpoint.host,PGPORT:String(endpoint.port),PGDATABASE:endpoint.database,PGUSER:endpoint.username,PGSSLMODE:'verify-full',PGSSLROOTCERT:options.ca,PGCONNECT_TIMEOUT:'15',PGAPPNAME:'w52k-bx-preview-bridge',PGPASSFILE:'__w52kbx_no_passfile__',PGOPTIONS:'-c default_transaction_read_only=on'});
 const tool=spawnSync(options.psql,['--version'],{encoding:'utf8',windowsHide:true,env:{...environment,PGPASSWORD:''},timeout:10000});
 check(tool.status===0&&/^psql \(PostgreSQL\) 17\./.test(tool.stdout.trim()),'BX_PSQL_17_REQUIRED');
 try{return new PsqlSession(options.psql,psqlFlags,{verified:true,kind:'TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST',project_ref:project,host:endpoint.host,port:endpoint.port},environment);}
 finally{delete environment.PGPASSWORD;}
}
