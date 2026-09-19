import {readFileSync} from 'node:fs';
import {isAbsolute} from 'node:path';
import {spawnSync} from 'node:child_process';
import {check,hash,project} from './common.mjs';
import {PsqlSession,psqlFlags} from '../../production_taxonomy/execution/session.mjs';
export function connectionFactory(options){
 check(options.production_authorized===true,'EXPLICIT_LIVE_AUTHORIZATION_REQUIRED');
 check(isAbsolute(options.psql??'')&&isAbsolute(options.ca??''),'TRUSTED_TOOL_PATHS_REQUIRED');
 check(hash(readFileSync(options.psql))===options.psql_sha256&&hash(readFileSync(options.ca))===options.ca_sha256,'TOOL_OR_CA_HASH');
 let password=process.env.PGPASSWORD;delete process.env.PGPASSWORD;
 check(typeof password==='string'&&password.length>0,'OWNER_SESSION_PASSWORD_REQUIRED');
 const environment={...process.env};for(const key of Object.keys(environment))if(/^PG/i.test(key))delete environment[key];
 Object.assign(environment,{PGHOST:`db.${project}.supabase.co`,PGPORT:'5432',PGDATABASE:'postgres',PGUSER:'postgres',PGSSLMODE:'verify-full',PGSSLROOTCERT:options.ca,PGCONNECT_TIMEOUT:'15',PGAPPNAME:'w52k-by-preview-bridge',PGPASSFILE:'__w52kby_no_passfile__',PGOPTIONS:'-c default_transaction_read_only=on'});
 const tool=spawnSync(options.psql,['--version'],{encoding:'utf8',env:environment,windowsHide:true,timeout:10000});
 check(tool.status===0&&/^psql \(PostgreSQL\) 17\./.test(tool.stdout.trim()),'PSQL_17_REQUIRED');
 return {
  open(){check(password,'CREDENTIAL_STATE_DISPOSED');const childEnv={...environment,PGPASSWORD:password};try{return new PsqlSession(options.psql,psqlFlags,{verified:true,kind:'TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST',project_ref:project},childEnv);}finally{delete childEnv.PGPASSWORD;}},
  dispose(){password=null;delete process.env.PGPASSWORD;},
 };
}
