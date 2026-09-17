// Rehearsal-only transport. Network-disabled local Docker, never a remote endpoint.
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { check, hash, json, originalBackupHash, project, stable, validateBackup } from './common.mjs';
import { PsqlSession, psqlFlags } from './session.mjs';

export const source = json('docs/data/w52h_r_source_restore_metadata.json');
export const container = process.env.W52JB_CONTAINER;
export const docker = process.env.W52JB_DOCKER;
export const dump = process.env.W52JB_DUMP;
export const imageDigest = 'supabase/postgres@sha256:f371b5f3f2ac0a05703f33d6e6134515fb2498cab708fb948a0aeb7481467c00';
export function run(args, input, binary = false) {
  check(docker && /^w52jb-(pilot|first|second|failure)-[a-z0-9]+$/.test(container ?? ''), 'LOCAL_PARAMETERS');
  const result = spawnSync(docker, ['--context','desktop-linux',...args], {input,encoding:binary?null:'utf8',windowsHide:true,maxBuffer:64*1024*1024,timeout:240000});
  if (result.error || result.status !== 0) {
    const tag=String(result.stderr ?? '').match(/W52(?:JB|H)_[A-Z0-9_]+/)?.[0];
    throw new Error(tag ?? 'W52JB_LOCAL_COMMAND_FAILED');
  }
  return result.stdout;
}
export function sql(database, input) {
  check(['postgres','template1'].includes(database), 'LOCAL_DATABASE_ALLOWLIST');
  return run(['exec','-i',container,'psql','-h','/tmp','-U','supabase_admin','-d',database,...psqlFlags],input);
}
export function guard() {
  const context=JSON.parse(run(['context','inspect','desktop-linux']))[0];
  check(context.Endpoints.docker.Host==='npipe:////./pipe/dockerDesktopLinuxEngine','LOCAL_DOCKER_ENDPOINT');
  const state=JSON.parse(run(['inspect',container]))[0];
  check(state.State.Running && state.HostConfig.NetworkMode==='none' && !state.HostConfig.Privileged && Object.keys(state.HostConfig.PortBindings||{}).length===0 && Object.keys(state.NetworkSettings.Ports||{}).length===0,'LOCAL_NETWORK_ISOLATION');
  check(state.Config.Labels['esnaftavar.task']==='w52j-b','LOCAL_TASK_CONTAINER');
  check(JSON.parse(run(['image','inspect',state.Image]))[0].RepoDigests.includes(imageDigest),'PINNED_IMAGE');
  check(state.Mounts.length===1 && state.Mounts[0].Destination==='/backup/production.dump' && !state.Mounts[0].RW,'READONLY_BACKUP_MOUNT');
  const norm=p=>p.replaceAll('\\','/').toLowerCase();
  check(norm(state.Mounts[0].Source)===norm(dump) && hash(readFileSync(dump))===originalBackupHash,'ORIGINAL_BACKUP');
  check(sql('postgres','SHOW server_version;').trim()==='17.6' && sql('postgres','SHOW listen_addresses;').trim()==='','LOCAL_POSTGRES_IDENTITY');
  return {kind:'ISOLATED_REAL_BACKUP_RESTORE',project_ref:project,verified:true,container_id:state.Id,image_digest:imageDigest,network:'none',ports:[],backup_readonly:true};
}
export function session() {
  const transport=guard();
  const db=new PsqlSession(docker,['--context','desktop-linux','exec','-i',container,'psql','-h','/tmp','-U','postgres','-d','postgres',...psqlFlags],transport);
  db.name='postgres'; return db;
}
export async function create() {
  check(hash(readFileSync(dump))===originalBackupHash,'ORIGINAL_BACKUP_HASH');
  const context=JSON.parse(run(['context','inspect','desktop-linux']))[0];
  check(context.Endpoints.docker.Host==='npipe:////./pipe/dockerDesktopLinuxEngine','LOCAL_DOCKER_ENDPOINT');
  const cmd='set -eu\ninitdb --username=supabase_admin --auth-local=trust --auth-host=reject --encoding=UTF8 --locale=C.UTF-8 -D /tmp/w52jb-pgdata > /tmp/w52jb-initdb.log\nexec postgres -D /tmp/w52jb-pgdata -c listen_addresses= -c unix_socket_directories=/tmp -c shared_preload_libraries=pg_stat_statements -c log_statement=none -c log_min_error_statement=panic -c log_error_verbosity=terse';
  run(['run','-d','--name',container,'--network','none','--label','esnaftavar.task=w52j-b','--user','postgres','--mount',`type=bind,source=${dump},target=/backup/production.dump,readonly`,'--entrypoint','sh',imageDigest,'-c',cmd]);
  let ready=false;
  for(let i=0;i<60;i++) { try { sql('postgres','SELECT 1;');ready=true;break; } catch { await new Promise(r=>setTimeout(r,500)); } }
  check(ready,'LOCAL_POSTGRES_READY'); return guard();
}
export function freshBackup() {
  guard();
  run(['exec',container,'pg_dump','-h','/tmp','-U','supabase_admin','-d','postgres','-Fc','-f','/tmp/w52jb-prewrite.dump']);
  const bytes=run(['exec',container,'cat','/tmp/w52jb-prewrite.dump'],undefined,true);
  return validateBackup({project_ref:project,database:'postgres',source_pg_version:'17.6',format:'CUSTOM',tool_version:'17.6',completed_at_utc:new Date().toISOString(),sha256:hash(bytes),size_bytes:bytes.length},bytes);
}
export function stop() { guard(); run(['stop',container]); }
export const stableJson=stable;
export const sha256=hash;
