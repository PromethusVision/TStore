// Fresh owned loopback stack only. Never accepts hosted URLs or credentials.
import assert from 'node:assert/strict';
import {randomBytes,randomUUID,createHash} from 'node:crypto';
import {readFile,writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';
import {readRun,credentials,runtimeEvidence,root} from './local.mjs';
import {localUrl,localRequest,requestJson} from './safety.mjs';
import {connect,migrate,seed} from './fixture.mjs';

let run,db;
try {
  assert.equal(process.argv.length,3,'Provide exactly one fresh owned local run');
  run=await readRun(process.argv[2]);
  const status=await credentials(run),services=await runtimeEvidence(run);
  const url=localUrl(status.DB_URL,'db');
  db=await connect({host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',password:decodeURIComponent(url.password),ssl:false});
  const migrations=await migrate(db,{coreOnly:true});
  const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
  async function actor() {
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,{...login,email_confirm:true});
    assert(created.ok);
    const session=await request('/auth/v1/token?grant_type=password',null,login);assert(session.ok);
    return {id:created.data.id,token:session.data.access_token};
  }
  const f=await seed(db,await actor(),await actor(),await actor());
  // Upgrade rehearsal: preserve real pre-existing grouped hours and coordinates.
  await db.query(`UPDATE public.shops SET opening_hours='{"mon_sat":"09:00 - 18:00","sun":"Kapalı","note":"Legacy"}',latitude=41,longitude=29 WHERE id=$1`,[f.shop]);
  const before=(await db.query('SELECT * FROM public.shops ORDER BY id')).rows;
  const file='20261023003200_0032_shop_profile.sql';
  const sql=await readFile(resolve(root,'supabase/migrations',file),'utf8');
  await db.query(sql);
  migrations.push({file,sha256:createHash('sha256').update(sql).digest('hex')});
  const checks=[];
  async function check(name,fn) {await fn();checks.push({name,result:'PASS'});console.log('PASS '+name);}
  await check('additive upgrade preserves all existing shop fields',async()=>{
    const after=(await db.query('SELECT * FROM public.shops ORDER BY id')).rows;
    assert.deepEqual(after.map(({photo_path,...s})=>s),before);
    assert(after.every(s=>s.photo_path===null));
  });
  await check('new bucket private, size limited and supported image types only',async()=>{
    const b=(await db.query("SELECT * FROM storage.buckets WHERE id='shop-profile-media'")).rows[0];
    assert.equal(b.public,false);assert.equal(Number(b.file_size_limit),5242880);
    assert.deepEqual(b.allowed_mime_types,['image/jpeg','image/png','image/webp']);
  });
  let ready=false;
  for(let i=0;i<40;i++) {
    const r=await request('/rest/v1/shops?select=photo_path&id=eq.'+f.shop,f.merchant,undefined,'GET');
    if(r.ok){ready=true;break;}await new Promise(r=>setTimeout(r,200));
  }
  assert(ready,'PostgREST profile column unavailable');
  const png=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64');
  const path=()=>`shops/${f.shop}/${randomBytes(16).toString('hex')}.png`;
  const first=path(),second=path();
  const upload=(who,name,body=png,mime='image/png',upsert=false)=>localRequest(status.API_URL,'/storage/v1/object/shop-profile-media/'+name,
    {method:'POST',headers:{apikey:status.ANON_KEY,Authorization:'Bearer '+(who?.token||status.ANON_KEY),'Content-Type':mime,'x-upsert':String(upsert)},body});
  const sign=(who,name)=>request('/storage/v1/object/sign/shop-profile-media/'+name,who,{expiresIn:300});
  const patch=(who,body,filter='')=>request('/rest/v1/shops?id=eq.'+f.shop+filter,who,body,'PATCH');
  const shop=async()=>(await db.query('SELECT * FROM public.shops WHERE id=$1',[f.shop])).rows[0];
  await check('foreign merchant, customer and anonymous cannot upload',async()=>{
    for(const who of [f.other,f.customer,null]) assert.equal((await upload(who,path())).ok,false);
  });
  await check('malformed, unsupported and oversize uploads denied',async()=>{
    assert.equal((await upload(f.merchant,'shops/'+f.shop+'/bad.png')).ok,false);
    assert.equal((await upload(f.merchant,path(),Buffer.from('<html>'), 'text/html')).ok,false);
    assert.equal((await upload(f.merchant,path(),Buffer.alloc(5242881))).ok,false);
  });
  await check('owner can stage photo without publishing it',async()=>{
    assert.equal((await upload(f.merchant,first)).ok,true);
    assert.equal((await shop()).photo_path,null);
    assert.equal((await sign(f.merchant,first)).ok,true);
    for(const who of [f.customer,f.other,null]) assert.equal((await sign(who,first)).ok,false);
  });
  await check('staged bytes cannot be overwritten',async()=>{
    assert.equal((await upload(f.merchant,first,png,'image/png',true)).ok,false);
  });
  await check('missing and arbitrary external photo references rejected atomically',async()=>{
    for(const photo_path of [path(),'https://example.invalid/photo.png','shops/'+f.otherShop+'/a.png']) {
      assert.equal((await patch(f.merchant,{photo_path,name:'Must not persist'})).ok,false);
      assert.equal((await shop()).name,before.find(s=>s.id===f.shop).name);
    }
  });
  await check('invalid coordinate pairs/ranges rejected; valid pair and hours saved',async()=>{
    for(const coords of [{latitude:41,longitude:null},{latitude:null,longitude:29},{latitude:91,longitude:29},{latitude:41,longitude:181}]) {
      assert.equal((await patch(f.merchant,coords)).ok,false);
      assert.equal(Number((await shop()).latitude),41);
    }
    assert.equal((await patch(f.merchant,{latitude:40.99,longitude:28.88,opening_hours:{mon:'09:00–18:00',tue:'closed',wed:''}})).ok,true);
    assert.deepEqual((await shop()).opening_hours,{mon:'09:00–18:00',tue:'closed',wed:''});
  });
  await check('version-checked publication makes only current photo readable',async()=>{
    // Preserve PostgreSQL microseconds, just as Dart DateTime does. JS Date
    // truncates them and would incorrectly exercise a stale revision.
    const original=(await request('/rest/v1/shops?id=eq.'+f.shop,f.merchant,undefined,'GET')).data[0];
    const filter='&updated_at=eq.'+encodeURIComponent(original.updated_at);
    assert.equal((await patch(f.merchant,{photo_path:first},filter)).ok,true);
    assert.equal((await shop()).photo_path,first);
    for(const who of [f.customer,f.other,null]) assert.equal((await sign(who,first)).ok,true);
    assert.equal((await upload(f.merchant,second)).ok,true);
    assert.equal((await sign(f.customer,second)).ok,false);
    assert.equal((await patch(f.merchant,{photo_path:second},filter)).ok,true); // zero rows, stale revision
    assert.equal((await shop()).photo_path,first);
    assert.equal((await patch(f.merchant,{photo_path:second})).ok,true);
    assert.equal((await sign(f.customer,first)).ok,false);
    assert.equal((await sign(f.customer,second)).ok,true);
  });
  await check('foreign and customer writes leave shop unchanged',async()=>{
    for(const who of [f.other,f.customer,null]) await patch(who,{photo_path:null,name:'Forbidden',latitude:null,longitude:null});
    assert.equal((await shop()).photo_path,second);
    assert.notEqual((await shop()).name,'Forbidden');
  });
  await check('owner cannot reference another shops uploaded image',async()=>{
    const foreign=`shops/${f.otherShop}/${randomBytes(16).toString('hex')}.png`;
    assert.equal((await upload(f.other,foreign)).ok,true);
    assert.equal((await patch(f.merchant,{photo_path:foreign})).ok,false);
    assert.equal((await shop()).photo_path,second);
  });
  await check('revoked merchant role blocks uploads',async()=>{
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
    try {assert.equal((await upload(f.merchant,path())).ok,false);}
    finally {await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]);}
  });
  await check('deactivated shop hides photo and blocks staging',async()=>{
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[f.shop]);
    try {
      assert.equal((await upload(f.merchant,path())).ok,false);
      assert.equal((await sign(f.customer,second)).ok,false);
    } finally {await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[f.shop]);}
  });
  await check('explicit removal clears pair and photo; old objects stay private',async()=>{
    assert.equal((await patch(f.merchant,{photo_path:null,latitude:null,longitude:null})).ok,true);
    const s=await shop();assert.equal(s.photo_path,null);assert.equal(s.latitude,null);assert.equal(s.longitude,null);
    assert.equal((await sign(f.customer,second)).ok,false);
    const deleted=await request('/storage/v1/object/shop-profile-media',f.merchant,{prefixes:[second]},'DELETE');
    assert.equal((await db.query("SELECT count(*)::int n FROM storage.objects WHERE bucket_id='shop-profile-media' AND name=$1",[second])).rows[0].n,1);
    assert(deleted.status>=200); // Storage may report success with zero authorized deletions.
  });
  await check('optional catalog decisions remain off',async()=>{
    assert.equal((await db.query('SELECT decisions_enabled FROM public.catalog_media_config')).rows[0].decisions_enabled,false);
  });
  const evidence={result:'PASS',captured_at:new Date().toISOString(),profile:'shop-profile-local-only',migrations,services,checks,
    production_access:'NONE',hosted_access:'NONE',physical_photo_gps:'OPEN',old_apks:'PRESERVED'};
  await writeFile(resolve(run.dir,'shop-profile-result.json'),JSON.stringify(evidence,null,2)+'\n',{flag:'wx'});
  console.log(`SHOP_PROFILE_LOCAL_PASS: ${checks.length} groups; hosted and physical gates OPEN.`);
} catch(error) {
  console.error('SHOP_PROFILE_LOCAL_FAILED: '+(error.code||error.name)+'; no remote fallback.');
  if(run) await writeFile(resolve(run.dir,'shop-profile-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});
  process.exitCode=1;
} finally {if(db) await db.end();}
