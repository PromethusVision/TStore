import assert from 'node:assert/strict';
import { randomBytes, randomUUID } from 'node:crypto';
import { readFile, writeFile, unlink, realpath } from 'node:fs/promises';
import { resolve } from 'node:path';
import { readRun, credentials, runtimeEvidence, root, command } from './local.mjs';
import { localUrl, localRequest, requestJson } from './safety.mjs';
import { connect, migrate, seed } from './fixture.mjs';
import { migrationManifest, assertMigrationManifest, inspectCore, validateCore, compareCore, digest } from './pilot_contract.mjs';

// Usage: node pilot.mjs <new owned local run> <Flutter SDK directory>
// No hosted URLs, database credentials, project refs or activation options.
let db,run,credentialFile;
try {
  assert.equal(process.argv.length,4,'Provide exactly an owned run and Flutter SDK directory');
  run=await readRun(process.argv[2]);
  const flutter=await realpath(process.argv[3]);
  const dart=await realpath(resolve(flutter,'bin/cache/dart-sdk/bin',process.platform==='win32'?'dart.exe':'dart'));
  const snapshot=await realpath(resolve(flutter,'bin/cache/flutter_tools.snapshot'));
  const status=await credentials(run), services=await runtimeEvidence(run);
  const url=localUrl(status.DB_URL,'db');
  db=await connect({host:'127.0.0.1',port:Number(url.port),database:'postgres',user:'postgres',
    password:decodeURIComponent(url.password),ssl:false});
  const expected=await migrationManifest(root);
  const applied=await migrate(db,{coreOnly:true});
  assertMigrationManifest(applied,expected);
  const before=await inspectCore(db), contract=validateCore(before);
  const checks=[];
  async function check(name,fn) { await fn(); checks.push({name,result:'PASS'}); console.log('PASS '+name); }
  await check('exact base-core schema, owner grants, private Storage and approval OFF',async()=>{});
  // Detect malformed deployments without changing the persistent fixture.
  const mutations=[
    ['missing dashboard RPC','DROP FUNCTION public.merchant_operations_read_v1(uuid,integer,integer)'],
    ['anonymous owner RPC','GRANT EXECUTE ON FUNCTION public.merchant_catalog_categories_v1(uuid) TO PUBLIC'],
    ['disabled submission RLS','ALTER TABLE public.product_submissions DISABLE ROW LEVEL SECURITY'],
    ['public media bucket',"UPDATE storage.buckets SET public=true WHERE id='listing-media'"],
    ['missing upload policy','DROP POLICY listing_media_owned_upload ON storage.objects'],
    ['broadened upload policy',"ALTER POLICY listing_media_owned_upload ON storage.objects WITH CHECK (true)"],
    ['enabled catalog decisions','UPDATE public.catalog_media_config SET decisions_enabled=true'],
    ['missing single-owner uniqueness','DROP INDEX public.shops_owner_user_id_unique_idx'],
    ['client submission writes','GRANT UPDATE ON public.product_submissions TO authenticated'],
    ['disabled listing identity trigger','ALTER TABLE public.shop_products DISABLE TRIGGER catalog_listing_identity_guard'],
  ];
  for(const [name,sql] of mutations) await check('drift rejected: '+name,async()=>{
    await db.query('BEGIN');
    try {
      await db.query(sql);
      const changed=await inspectCore(db,{transaction:false});
      assert.throws(()=>compareCore(before,changed));
    } finally { await db.query('ROLLBACK'); }
    compareCore(before,await inspectCore(db));
  });
  await check('disabled Storage RLS rejected in snapshot (managed table ownership preserved)',async()=>{
    const changed=structuredClone(before);
    changed.tables.find(t=>t.name==='storage.objects').rls=false;
    assert.throws(()=>compareCore(before,changed));
  });
  const request=(path,actor,body,method)=>requestJson(status.API_URL,path,actor?.token,status.ANON_KEY,body,method);
  const logins=new Map();
  async function actor() {
    const login={email:randomUUID()+'@example.invalid',password:randomBytes(32).toString('base64url')};
    const created=await requestJson(status.API_URL,'/auth/v1/admin/users',status.SERVICE_ROLE_KEY,status.SERVICE_ROLE_KEY,
      {...login,email_confirm:true});
    assert.equal(created.ok,true);
    const session=await request('/auth/v1/token?grant_type=password',null,login);
    assert.equal(session.status,200);
    logins.set(created.data.id,login);
    return {id:created.data.id,token:session.data.access_token};
  }
  const f=await seed(db,await actor(),await actor(),await actor());
  const newcomer=await actor();
  await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[newcomer.id]);
  await db.query("NOTIFY pgrst,'reload schema'");
  let ready=false;
  for(let i=0;i<30;i++) {
    const r=await request('/rest/v1/rpc/merchant_catalog_categories_v1',f.merchant,{p_shop_id:f.shop});
    if(r.ok) {ready=true;break;}
    await new Promise(r=>setTimeout(r,200));
  }
  assert(ready,'Base-core PostgREST unavailable');
  await check('real Auth forged signature rejected',async()=>{
    const forged={...f.merchant,token:f.merchant.token.slice(0,-8)+'aaaaaaaa'};
    assert.equal((await request('/rest/v1/profiles',forged,undefined,'GET')).ok,false);
  });
  await check('customer cannot self-grant merchant role or create shop',async()=>{
    assert.equal((await request('/rest/v1/profiles?id=eq.'+f.customer.id,f.customer,{role:'merchant'},'PATCH')).ok,false);
    assert.equal((await request('/rest/v1/shops',f.customer,{owner_user_id:f.customer.id,name:'Forbidden'})).ok,false);
    assert.equal((await db.query('SELECT role FROM public.profiles WHERE id=$1',[f.customer.id])).rows[0].role,'customer');
  });
  await check('foreign owner RPC denied, catalog decisions remain gated',async()=>{
    for(const actor of [f.other,f.customer,null]) assert.equal((await request('/rest/v1/rpc/merchant_operations_read_v1',actor,{p_shop_id:f.shop})).ok,false);
    assert.equal((await request('/rest/v1/rpc/decide_catalog_submission_v1',f.merchant,
      {p_submission_id:randomUUID(),p_status:'approved',p_product_id:f.product,p_reason:'Forbidden'})).ok,false);
  });
  await check('foreign direct shop edit and role revocation cannot bypass owner policies',async()=>{
    const before=(await db.query('SELECT name FROM public.shops WHERE id=$1',[f.shop])).rows[0].name;
    await request('/rest/v1/shops?id=eq.'+f.shop,f.other,{name:'Forbidden'},'PATCH');
    assert.equal((await db.query('SELECT name FROM public.shops WHERE id=$1',[f.shop])).rows[0].name,before);
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[f.merchant.id]);
    try {
      assert.equal((await request('/rest/v1/rpc/merchant_operations_read_v1',f.merchant,{p_shop_id:f.shop})).ok,false);
      await request('/rest/v1/shops?id=eq.'+f.shop,f.merchant,{name:'Forbidden'},'PATCH');
      assert.equal((await db.query('SELECT name FROM public.shops WHERE id=$1',[f.shop])).rows[0].name,before);
    } finally { await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.merchant.id]); }
  });
  await check('real Storage rejects foreign token, forged object path and unsupported upload intent',async()=>{
    const listing=randomUUID();
    assert.equal((await request('/rest/v1/shop_products',f.merchant,{id:listing,shop_id:f.shop,product_id:f.product,price:10})).ok,true);
    const bytes=Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=','base64');
    const args={p_listing_id:listing,p_mime:'image/png',p_bytes:bytes.length};
    for(const invalid of [{...args,p_mime:'text/html'},{...args,p_bytes:8388609}]) {
      assert.equal((await request('/rest/v1/rpc/merchant_prepare_listing_image_v1',f.merchant,invalid)).ok,false);
    }
    const intent=await request('/rest/v1/rpc/merchant_prepare_listing_image_v1',f.merchant,args);
    assert.equal(intent.ok,true);
    const upload=(actor,path)=>localRequest(status.API_URL,'/storage/v1/object/listing-media/'+path,{method:'POST',
      headers:{apikey:status.ANON_KEY,Authorization:'Bearer '+actor.token,'Content-Type':'image/png','x-upsert':'false'},body:bytes});
    assert.equal((await upload(f.other,intent.data.object_path)).ok,false);
    assert.equal((await upload(f.merchant,'shops/'+f.shop+'/'+listing+'/'+randomUUID()+'.png')).ok,false);
    assert.equal((await db.query('SELECT count(*)::int n FROM storage.objects')).rows[0].n,0);
  });
  // Fixture rows only: no real provider, email or account provisioning.
  const notification=randomUUID(),foreignNotification=randomUUID();
  await db.query(`INSERT INTO public.notifications(id,user_id,title,body,type)
    VALUES($1,$2,'Yerel prova','Esnaf bildirimi','system'),($3,$4,'Yerel prova','Diğer hesap','system')`,
    [notification,newcomer.id,foreignNotification,f.other.id]);
  const nonce=randomBytes(24).toString('hex');
  credentialFile=resolve(run.dir,'pilot-client-fixture.json');
  await writeFile(credentialFile,JSON.stringify({kind:'merchant-pilot-base-core-local',project:run.project,nonce,
    url:status.API_URL,key:status.ANON_KEY,merchant:logins.get(newcomer.id),
    other:logins.get(f.other.id),customer:logins.get(f.customer.id),product:f.product,category:f.category,
    foreign_shop:f.otherShop,notification,foreign_notification:foreignNotification,
    submission_request_id:randomUUID(),cart_id:randomUUID()}),{flag:'wx',mode:0o600});
  await check('production Flutter repositories against real local Auth/PostgREST/Storage',async()=>{
    const output=await command(dart,[snapshot,'--no-version-check','--suppress-analytics','test','--no-pub',
      'tool/merchant_acceptance/pilot_repository_test.dart','--reporter','expanded'],root,300000,false,
      {MERCHANT_PILOT_LOCAL_FIXTURE:credentialFile,FLUTTER_ROOT:flutter});
    await writeFile(resolve(run.dir,'flutter-result.log'),output,{mode:0o600});
  });
  const client=JSON.parse(await readFile(resolve(run.dir,'pilot-client-result.json'),'utf8'));
  assert.equal(client.nonce,nonce); assert.equal(client.result,'PASS');
  assert(client.checks.length>=18);
  await check('repository journey leaves schema and all default-OFF gates unchanged',async()=>compareCore(before,await inspectCore(db)));
  await check('synthetic legacy purchase recorded once; submitted product remains unpublished',async()=>{
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions')).rows[0].n,1);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.product_submissions WHERE status=\'pending\'')).rows[0].n,1);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.product_submission_decisions')).rows[0].n,0);
  });
  const sourcePaths=['lib/features/merchant/runtime/merchant_runtime.dart','lib/features/merchant/data/supabase_merchant_repository.dart',
    'lib/features/merchant/data/supabase_catalog_media_repository.dart','lib/features/merchant/data/supabase_merchant_operations_repository.dart',
    'lib/features/notifications/data/repositories/notification_repository_impl.dart','lib/features/shop/data/repositories/shop_repository_impl.dart',
    'lib/features/shop/data/repositories/supabase_listing_hero_media_repository.dart','lib/features/cart/data/repositories/qr_session_repository_impl.dart',
    'tool/merchant_acceptance/pilot.mjs','tool/merchant_acceptance/pilot_contract.mjs','tool/merchant_acceptance/pilot_repository_test.dart',
    'tool/merchant_acceptance/fixture.mjs','tool/merchant_acceptance/local.mjs','tool/merchant_acceptance/safety.mjs',
    'tool/merchant_acceptance/docker-proxy.mjs','tool/merchant_acceptance/package-lock.json'];
  // Source hashes normalize checkout line endings; migration hashes above remain
  // the exact SQL bytes executed locally. Git autocrlf must not fake code drift.
  const sources=await Promise.all(sourcePaths.map(async path=>({path,
    sha256_lf:digest((await readFile(resolve(root,path),'utf8')).replace(/\r\n/g,'\n'))})));
  const evidence={result:'PASS',captured_at:new Date().toISOString(),profile:'base-core-development-track-local-only',
    baseline:'c801292bf1c22dac25982f95e4c58becb99b9835',contract,migrations:applied,sources,services,checks,
    client_checks:client.checks,remote_access:'NONE',production_writes:'NONE',provider:'NOT_CONFIGURED',
    realtime_delivery:'NOT_EXERCISED',physical_two_device:'OPEN',distribution:'NOT_AUTHORIZED'};
  await writeFile(resolve(run.dir,'pilot-schema.json'),JSON.stringify(before,null,2)+'\n');
  const schemaManifest={profile:evidence.profile,schema_sha256:contract.schema_sha256,
    migrations:applied,functions:before.functions.map(({definition,...fn})=>({...fn,definition_sha256:digest(definition)})),
    tables:before.tables,policies:before.policies.map(({qual,with_check,...p})=>({...p,expression_sha256:digest({qual,with_check})})),
    buckets:before.buckets,config:before.config,component_sha256:Object.fromEntries(Object.entries(before).map(([k,v])=>[k,digest(v)])),
    remote_authorized:false,physical_two_device:'OPEN'};
  await writeFile(resolve(root,'docs/data/merchant_pilot_backend_contract.json'),JSON.stringify(schemaManifest,null,2)+'\n');
  await writeFile(resolve(root,'docs/data/merchant_pilot_backend_acceptance.json'),JSON.stringify(evidence,null,2)+'\n');
  console.log(`PILOT_BASE_CORE_LOCAL_PASS: ${checks.length} server groups + ${client.checks.length} client journey groups; remote/physical gates OPEN.`);
} catch(error) {
  console.error('PILOT_BASE_CORE_LOCAL_FAILED: '+(error.code||error.name)+'; no remote fallback.');
  if(run) await writeFile(resolve(run.dir,'pilot-failure.txt'),error.stack+'\n'+(error.diagnostics??''),{mode:0o600});
  process.exitCode=1;
} finally {
  if(credentialFile) await unlink(credentialFile).catch(()=>{});
  if(db) await db.end();
}
