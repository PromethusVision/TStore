import {mkdir,writeFile,readFile,realpath} from 'node:fs/promises';
import {resolve} from 'node:path';
import {randomUUID,randomBytes,createHash} from 'node:crypto';
import assert from 'node:assert/strict';
import {root,command} from './local.mjs';
import {inside} from './safety.mjs';
import {connect,migrate,seed,nativeManagedSchema} from './fixture.mjs';
import {notificationChecks} from './notification_checks.mjs';
import {developmentPushSql} from '../engagement/development_push_sql.mjs';

// Fresh task-owned, literal-loopback PostgreSQL only. No hosted inputs accepted.
let db,directory,binary,startAttempted=false;
try {
  assert.equal(process.platform,'win32');
  binary=await realpath(resolve(process.argv[2]));
  assert.match(await command(resolve(binary,'postgres.exe'),['--version']),/PostgreSQL\) 17\./);
  const base=resolve(root,'.buildlog/firebase-postgres');
  directory=resolve(base,`run-${randomUUID()}`);await mkdir(directory,{recursive:true});await inside(base,directory);
  const data=resolve(directory,'data'),password=randomBytes(32).toString('hex');
  await writeFile(resolve(directory,'password.txt'),password,{flag:'wx',mode:0o600});
  const config={host:'127.0.0.1',port:55449,database:'postgres',user:'postgres',password,ssl:false};
  await command(resolve(binary,'initdb.exe'),['-D',data,'-U','postgres','--encoding=UTF8','--locale=C',
    '--auth=scram-sha-256','--pwfile',resolve(directory,'password.txt')],directory,180000);
  startAttempted=true;
  await command(resolve(binary,'pg_ctl.exe'),['-D',data,'-l',resolve(directory,'server.log'),
    '-o','-h 127.0.0.1 -p 55449','-w','start'],directory,60000,true);
  db=await connect(config);
  assert.equal(await realpath((await db.query('SHOW data_directory')).rows[0].data_directory),await realpath(data));
  await nativeManagedSchema(db);await migrate(db,{coreOnly:true});
  assert.equal((await db.query("SELECT to_regprocedure('public._qr_auth_session_b()') AS guard")).rows[0].guard,null);
  const before=JSON.stringify((await db.query('SELECT * FROM public.banners ORDER BY id')).rows);
  const sql=await developmentPushSql();
  assert.equal((await readFile(resolve(root,'supabase/proposals/development_push_transport_v1.sql'),'utf8')).replaceAll('\r\n','\n'),sql);
  await db.query(sql);
  assert.equal(JSON.stringify((await db.query('SELECT * FROM public.banners ORDER BY id')).rows),before);
  assert.equal((await db.query("SELECT to_regprocedure('public._qr_auth_session_b()') AS guard")).rows[0].guard,null);
  assert.equal((await db.query('SELECT enabled FROM public.push_dispatch_config')).rows[0].enabled,false);
  await assert.rejects(db.query(sql));await db.query('ROLLBACK');
  async function actor(id=randomUUID()) {
    await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2) ON CONFLICT DO NOTHING',[id,`${id}@example.invalid`]);
    const sid=randomUUID();await db.query('INSERT INTO auth.sessions(id,user_id) VALUES($1,$2)',[sid,id]);
    return {id,claims:{sub:id,role:'authenticated',session_id:sid},installation:randomUUID()};
  }
  const fixture=await seed(db,await actor(),await actor(),await actor());fixture.session=id=>actor(id);
  const checks=await notificationChecks(db,config,fixture);
  const example=(await db.query('SELECT id FROM public.notifications LIMIT 1')).rows[0];
  assert(example);
  const selectBefore=(await db.query("SELECT has_table_privilege('service_role','public.notifications','SELECT') allowed")).rows[0].allowed;
  assert.equal(selectBefore,false);
  for(const role of ['anon','authenticated']) {
    assert.equal((await db.query("SELECT has_function_privilege($1,'public.read_push_notification_development_v1(uuid)','EXECUTE') allowed",[role])).rows[0].allowed,false);
  }
  await db.query('BEGIN');await db.query('SET LOCAL ROLE service_role');
  const metadata=(await db.query('SELECT public.read_push_notification_development_v1($1) value',[example.id])).rows[0].value;
  assert.deepEqual(Object.keys(metadata).sort(),['created_at','id','type','user_id']);
  assert.equal(metadata.id,example.id);await db.query('ROLLBACK');
  checks.push('service-only metadata RPC, no notification table SELECT or private content');
  const result={result:'PASS',scope:'Development base-core + standalone push transport, local PostgreSQL only',
    proposal_sha256_lf:createHash('sha256').update(sql).digest('hex'),
    remote_access:'NONE',provider_sends:'NONE',checks};
  await writeFile(resolve(directory,'result.json'),JSON.stringify(result,null,2)+'\n');
  await writeFile(resolve(root,'.buildlog/firebase-postgres-result.json'),JSON.stringify(result,null,2)+'\n');
  console.log(`DEVELOPMENT_PUSH_POSTGRES_PASS: ${checks.length} existing independent transport groups; no commerce activation.`);
} catch(error) {
  if(directory) await writeFile(resolve(directory,'failure.txt'),error.stack ?? error.name);
  console.error('DEVELOPMENT_PUSH_POSTGRES_FAIL');process.exitCode=1;
} finally {
  await db?.end();
  if(startAttempted && binary && directory) {
    try {await command(resolve(binary,'pg_ctl.exe'),['-D',resolve(directory,'data'),'-m','fast','-w','stop'],directory);}
    catch {console.error('OWNED_POSTGRES_STOP_NOT_CONFIRMED');process.exitCode=1;}
  }
}
