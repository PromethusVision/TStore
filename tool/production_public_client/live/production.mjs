// Import has no side effect or network connection. Called only by explicit CLI.
import {readFileSync,realpathSync,existsSync,openSync,closeSync,writeFileSync} from 'node:fs';
import {isAbsolute,relative,resolve,dirname,sep} from 'node:path';
import {spawnSync} from 'node:child_process';
import {check,hash,root,project} from './common.mjs';
import {PsqlSession,psqlFlags} from '../../production_taxonomy/execution/session.mjs';

export function externalPath(path,{newFile=false}={}){
 check(isAbsolute(path??''),'EXTERNAL_ABSOLUTE_PATH_REQUIRED');
 const actual=newFile?resolve(realpathSync(dirname(path)),path.slice(dirname(path).length+1)):realpathSync(path);
 const rel=relative(realpathSync(root),actual);check(rel==='..'||rel.startsWith('..'+sep)||isAbsolute(rel),'EXTERNAL_PATH_REQUIRED');
 for(let p=dirname(actual);;p=dirname(p)){check(!existsSync(resolve(p,'.git')),'INPUT_INSIDE_GIT_CHECKOUT');if(dirname(p)===p)break;}
 if(newFile)check(!existsSync(actual),'BACKUP_OVERWRITE_FORBIDDEN');
 return actual;
}
export function connectionFactory(options){
 let password=process.env.PGPASSWORD;delete process.env.PGPASSWORD;
 try{
  check(options.production_authorized===true,'EXPLICIT_LIVE_AUTHORIZATION_REQUIRED');
  check(options.project_ref===project,'TARGET_IDENTITY');
  const psql=externalPath(options.psql),ca=externalPath(options.ca);
  check(hash(readFileSync(psql))===options.psql_sha256&&hash(readFileSync(ca))===options.ca_sha256,'TOOL_OR_CA_HASH');
  check(typeof password==='string'&&password.length>0,'OWNER_SESSION_PASSWORD_REQUIRED');
  const environment=Object.fromEntries(Object.entries(process.env).filter(([key])=>!/^PG/i.test(key)));
  Object.assign(environment,{PGHOST:`db.${project}.supabase.co`,PGPORT:'5432',PGDATABASE:'postgres',PGUSER:'postgres',PGSSLMODE:'verify-full',PGSSLROOTCERT:ca,PGCONNECT_TIMEOUT:'15',PGAPPNAME:'w52lc-0015-public-read-facade',PGPASSFILE:'__w52lc_no_passfile__',PGOPTIONS:'-c default_transaction_read_only=on'});
  const run=(tool,args,needsPassword=true)=>{
   const env={...environment,...(needsPassword?{PGPASSWORD:password}:{})};
   try{const r=spawnSync(tool,args,{encoding:'utf8',env,windowsHide:true,maxBuffer:16*1024*1024,timeout:240000});check(!r.error&&r.status===0,'DATABASE_TOOL_FAILED');return r.stdout;}finally{delete env.PGPASSWORD;}
  };
  check(/^psql \(PostgreSQL\) 17\./.test(run(psql,['--version'],false).trim()),'PSQL_17_REQUIRED');
  return {
   open(){check(password,'CREDENTIAL_DISPOSED');const env={...environment,PGPASSWORD:password};try{return new PsqlSession(psql,psqlFlags,{verified:true,kind:'TLS_VERIFY_FULL_EXACT_PRODUCTION_HOST',project_ref:project,hostname:environment.PGHOST,sslmode:'verify-full',database:'postgres',username:'postgres',port:5432},env);}finally{delete env.PGPASSWORD;}},
   async backup(){
    check(password,'CREDENTIAL_DISPOSED');
    const dump=externalPath(options.pg_dump),restore=externalPath(options.pg_restore);
    check(hash(readFileSync(dump))===options.pg_dump_sha256&&hash(readFileSync(restore))===options.pg_restore_sha256,'BACKUP_TOOL_HASH');
    const dumpVersion=run(dump,['--version'],false).trim(),restoreVersion=run(restore,['--version'],false).trim();
    check(/^pg_dump \(PostgreSQL\) 17\./.test(dumpVersion)&&/^pg_restore \(PostgreSQL\) 17\./.test(restoreVersion),'BACKUP_TOOLS_17_REQUIRED');
    const archive=externalPath(options.backup,{newFile:true}),metadataPath=externalPath(options.backup_metadata,{newFile:true});
    check(archive!==metadataPath,'BACKUP_PATH_COLLISION');closeSync(openSync(archive,'wx',0o600));
    run(dump,['--format=custom','--file',archive,'--no-password']);
    const bytes=readFileSync(archive),toc=run(restore,['--list',archive],false);
    check(/Format: CUSTOM/.test(toc)&&/TABLE DATA public products/.test(toc)&&/FUNCTION public production_taxonomy_runtime_v1/.test(toc),'BACKUP_TOC_IDENTITY');
    const metadata={project_ref:project,database:'postgres',source_pg_version:'17.6',format:'CUSTOM',tool_version:dumpVersion.match(/17\.\d+/)[0],completed_at_utc:new Date().toISOString(),sha256:hash(bytes),size_bytes:bytes.length};
    writeFileSync(metadataPath,JSON.stringify(metadata,null,2)+'\n',{flag:'wx',mode:0o600});return {metadata,bytes,tocVerified:true};
   },
   dispose(){password=null;delete process.env.PGPASSWORD;},
  };
 }catch(e){password=null;delete process.env.PGPASSWORD;throw e;}
}
