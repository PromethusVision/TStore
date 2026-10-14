// Ephemeral PostgreSQL only. Crypto helpers below are explicitly test substitutes.
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { createCatalogFixture } from '../catalog_media/local_fixture.mjs';
const { db, uid }=await createCatalogFixture(process.argv[2]);
let checks=0;
async function check(name,fn){await fn();console.log(`PASS ${++checks} ${name}`);}
async function call(n,sql,params=[],{sid=n+100,role='authenticated'}={}) {
  await db.exec('BEGIN');
  try {
    await db.query("SELECT set_config('request.jwt.claim.sub',$1,true),set_config('request.jwt.claim.role',$2,true),set_config('request.jwt.claims',$3,true)",
      [n?uid(n):'',role,JSON.stringify({sub:n?uid(n):null,role,session_id:sid?uid(sid):null})]);
    await db.exec(`SET LOCAL ROLE ${role}`);
    const r=await db.query(sql,params);await db.exec('COMMIT');return r.rows[0]?.result;
  } finally {await db.exec('ROLLBACK');}
}
const rpc=(n,name,params=[],opts={})=>call(n,`SELECT to_jsonb(public.${name}(${params.map((_,i)=>'$'+(i+1)).join(',')})) result`,params,opts);
const device=uid(201);
const claim=(q,request=1000,opts={})=>rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(request),q.session_token,null],opts);
const complete=(c,opts={})=>rpc(1,'complete_existing_qr_v2',[c.claim_id,device],opts);
let cartCounter=400;
async function fresh(qty=3,legacy=false) {
  // Cancel only fixture user's existing active carts before a new scenario.
  await db.exec(`UPDATE public.carts SET status='cancelled' WHERE user_id='${uid(3)}' AND status='active'`);
  const id=uid(++cartCounter);
  await db.query('INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[id,uid(3),uid(10)]);
  await db.query('INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,$3)',[id,uid(30),qty]);
  return rpc(3,legacy?'create_qr_session':'create_qr_session_v2',[id]);
}
try {
  await db.exec(`CREATE TABLE auth.sessions(id uuid PRIMARY KEY,user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,not_after timestamptz);
    CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$ SELECT nullif(current_setting('request.jwt.claims',true),'')::jsonb $$;
    CREATE FUNCTION extensions.hmac(data bytea,key bytea,kind text) RETURNS bytea LANGUAGE sql IMMUTABLE AS $$ SELECT decode(md5(encode(key,'hex')||encode(data,'hex')),'hex') $$;
    CREATE FUNCTION extensions.digest(data bytea,kind text) RETURNS bytea LANGUAGE sql IMMUTABLE AS $$ SELECT decode(md5(encode(data,'hex')),'hex') $$;`);
  for(const n of [1,2,3])await db.query('INSERT INTO auth.sessions(id,user_id) VALUES($1,$2)',[uid(100+n),uid(n)]);
  await db.exec(await readFile('supabase/migrations/20261014001700_0017_merchant_daily_operations.sql','utf8'));
  await db.exec(await readFile('supabase/migrations/20261015001800_0018_qr_claim_purchase_returns.sql','utf8'));
  await check('flag OFF and legacy QR still works',async()=>{
    assert.equal((await rpc(1,'qr_capabilities_v2')).enabled,false);
    await assert.rejects(fresh());
    const q=await fresh(3,true);
    const v=await rpc(1,'get_qr_session_for_verification',[q.session_token]);assert.equal(v.status,'active');
    const done=await rpc(1,'confirm_qr_session',[q.session_token]);assert.equal(done.status,'used');
    const row=(await db.query('SELECT id FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id])).rows[0];
    assert.equal((await rpc(3,'read_purchase_evidence_v2',[row.id])).terms_classification,'legacy_unclassified');
    await assert.rejects(rpc(1,'record_purchase_return_v2',[row.id,uid(800),[], 'test',device,null]));
  });
  await db.exec('UPDATE public.qr_protocol_config SET enabled=true');
  await check('same session code, idempotent create, immutable claim and two deadlines',async()=>{
    const q=await fresh();assert.match(q.manual_code,/^\d{6}$/);
    assert.equal((await rpc(3,'create_qr_session_v2',[q.cart_id])).manual_code,q.manual_code);
    const c=await claim(q);assert.equal(c.status,'claimed');
    assert.equal((await claim(q)).claim_id,c.claim_id);
    const byCode=await rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(1001),null,q.manual_code]);
    assert.equal(byCode.claim_id,c.claim_id);
    assert.equal(byCode.completion_expires_at,c.completion_expires_at);
    await db.query("UPDATE public.qr_sessions SET expires_at=clock_timestamp()-interval '1 second' WHERE id=$1",[q.id]);
    for(const name of ['get_qr_session_for_verification','confirm_qr_session'])await assert.rejects(rpc(1,name,[q.session_token]),/QR_V2_REQUIRED/);
    await assert.rejects(rpc(3,'create_qr_session',[q.cart_id]),/QR_V2_REQUIRED/);
    const done=await complete(c);assert.equal(done.status,'used');assert.ok(done.purchase_id);
    assert.equal((await complete(c)).purchase_id,done.purchase_id);
    assert.equal((await rpc(1,'reconcile_claim_v2',[c.claim_id,device])).purchase_id,done.purchase_id);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.commerce_events WHERE purchase_id=$1',[done.purchase_id])).rows[0].n,1);
    const purchase=await rpc(3,'read_purchase_evidence_v2',[done.purchase_id]);
    assert.equal(purchase.final_sale_minor,3600);assert.equal(purchase.return_policy_version,'unspecified');
    assert.ok(purchase.items[0].product_id);assert.equal(purchase.returns.length,0);
  });
  await check('private tables/internal bodies inaccessible to clients',async()=>{
    for(const t of ['qr_protocol_config','qr_session_protocols','qr_claims','merchant_device_sessions','purchase_terms','commerce_events','purchase_returns'])
      await assert.rejects(call(1,`SELECT * FROM public.${t}`));
    await assert.rejects(rpc(1,'_confirm_qr_session_legacy_b',['x']));
    await assert.rejects(rpc(1,'qr_capabilities_v2',[],{role:'service_role'}));
    await assert.rejects(rpc(null,'qr_capabilities_v2',[],{role:'anon',sid:null}));
  });
  const clearLimits=()=>db.exec('TRUNCATE public.qr_attempt_limits');
  await check('missing, spoofed, expired and revoked Auth sessions fail closed',async()=>{
    const q=await fresh();
    for(const sid of [null,999,102])await assert.rejects(claim(q,1100,{sid}));
    await db.query("UPDATE auth.sessions SET not_after=clock_timestamp()-interval '1 second' WHERE id=$1",[uid(101)]);
    await assert.rejects(claim(q,1100));
    await db.query('UPDATE auth.sessions SET not_after=NULL WHERE id=$1',[uid(101)]);
    const c=await claim(q,1100);assert.equal(c.status,'claimed');
    await rpc(1,'revoke_merchant_device_session_v2',[uid(101)]);
    await assert.rejects(complete(c));
    await assert.rejects(rpc(1,'reconcile_claim_v2',[c.claim_id,device]));
    // Fixture repair only; no public un-revoke path exists.
    await db.exec('UPDATE public.merchant_device_sessions SET revoked_at=NULL');
    await rpc(1,'cancel_claim_v2',[c.claim_id,device]);
  });
  await clearLimits();
  await check('shop ownership and role suspension rechecked at completion',async()=>{
    const q=await fresh(),c=await claim(q,1200);
    await assert.rejects(rpc(2,'claim_existing_qr_v2',[uid(10),uid(202),uid(1201),q.session_token,null]));
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[uid(10)]);
    await assert.rejects(complete(c));
    await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[uid(10)]);
    await db.query("UPDATE public.profiles SET role='customer' WHERE id=$1",[uid(1)]);
    await assert.rejects(complete(c));
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[uid(1)]);
    assert.equal((await rpc(1,'cancel_claim_v2',[c.claim_id,device])).status,'cancelled');
  });
  await clearLimits();
  await check('two-session cap cannot be bypassed by installation IDs; second device cannot steal claim',async()=>{
    for(const id of [104,105])await db.query('INSERT INTO auth.sessions(id,user_id) VALUES($1,$2)',[uid(id),uid(1)]);
    const q=await fresh(),c=await claim(q,1300);
    await assert.rejects(rpc(1,'claim_existing_qr_v2',[uid(10),uid(299),uid(1301),q.session_token,null]));
    const other=await rpc(1,'claim_existing_qr_v2',[uid(10),uid(204),uid(1302),q.session_token,null],{sid:104});
    assert.equal(other.error,'QR_CLAIMED_ELSEWHERE');
    await assert.rejects(rpc(1,'reconcile_claim_v2',[c.claim_id,uid(204)],{sid:104}));
    await assert.rejects(rpc(1,'claim_existing_qr_v2',[uid(10),uid(205),uid(1303),q.session_token,null],{sid:105}),/limit/);
    await db.query('DELETE FROM auth.sessions WHERE id=$1',[uid(104)]);
    const replacement=await rpc(1,'claim_existing_qr_v2',[uid(10),uid(205),uid(1304),q.session_token,null],{sid:105});
    assert.equal(replacement.error,'QR_CLAIMED_ELSEWHERE');
    await db.query('DELETE FROM auth.sessions WHERE id=$1',[uid(105)]);
    await rpc(1,'cancel_claim_v2',[c.claim_id,device]);
  });
  await clearLimits();
  await check('invalid guesses consume committed attempt quota',async()=>{
    for(let i=0;i<5;i++)assert.equal((await rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(1400+i),null,'999999'])).error,'QR_UNAVAILABLE');
    assert.equal((await rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(1406),null,'999999'])).error,'QR_RATE_LIMITED');
    assert.equal((await db.query("SELECT attempts FROM public.qr_attempt_limits WHERE scope=$1",['session:'+uid(101)])).rows[0].attempts,6);
  });
  await clearLimits();
  await check('expired initial scan cannot claim and completion never extends on retry',async()=>{
    const q=await fresh();
    await db.query("UPDATE public.qr_sessions SET expires_at=clock_timestamp()-interval '1 second' WHERE id=$1",[q.id]);
    assert.equal((await claim(q,1500)).error,'QR_EXPIRED');
    const next=await fresh(),c=await claim(next,1501);
    await db.query("UPDATE public.qr_claims SET claimed_at=clock_timestamp()-interval '11 minutes',completion_expires_at=clock_timestamp()-interval '1 second' WHERE id=$1",[c.claim_id]);
    assert.equal((await complete(c)).status,'expired');
    assert.equal((await db.query('SELECT count(*)::int n FROM public.verified_transactions WHERE source_qr_session_id=$1',[next.id])).rows[0].n,0);
  });
  await clearLimits();
  await check('cart and price changes fail closed, before and after claim',async()=>{
    let q=await fresh();
    await db.query('UPDATE public.shop_products SET price=13 WHERE id=$1',[uid(30)]);
    assert.equal((await claim(q,1600)).error,'QR_QUOTE_CHANGED');
    q=await fresh();const c=await claim(q,1601);
    await db.query('UPDATE public.cart_items_v2 SET quantity=2 WHERE cart_id=$1',[q.cart_id]);
    assert.equal((await complete(c)).status,'cancelled');
    q=await fresh();const c2=await claim(q,1602);
    await db.query('UPDATE public.shop_products SET price=12 WHERE id=$1',[uid(30)]);
    assert.equal((await complete(c2)).status,'cancelled');
  });
  await clearLimits();
  await check('disabled flag keeps claimed attempt reconcilable without legacy protocol switch',async()=>{
    const q=await fresh(),c=await claim(q,1700);
    await db.exec('UPDATE public.qr_protocol_config SET enabled=false');
    assert.equal((await rpc(3,'create_qr_session_v2',[q.cart_id])).status,'claimed');
    assert.equal((await rpc(1,'recover_merchant_claim_v2',[uid(10),device])).claim_id,c.claim_id);
    assert.equal((await complete(c)).status,'used');
    await assert.rejects(rpc(1,'confirm_qr_session',[q.session_token]),/QR_V2_REQUIRED/);
    await db.exec('UPDATE public.qr_protocol_config SET enabled=true');
  });
  await clearLimits();
  let purchase;
  await check('returns are idempotent, bounded, exact and leave original evidence intact',async()=>{
    const q=await fresh(),c=await claim(q,1800),done=await complete(c);
    purchase=await rpc(3,'read_purchase_evidence_v2',[done.purchase_id]);
    const item=purchase.items[0].id;
    const args=[purchase.id,uid(1801),[{purchase_item_id:item,quantity:2}],'Ürün iadesi',device,null];
    const returned=await rpc(1,'record_purchase_return_v2',args);
    assert.equal(returned.items[0].returned_quantity,2);assert.equal(returned.returns[0].refund_executed,false);
    assert.equal((await rpc(1,'record_purchase_return_v2',args)).returns.length,1);
    await assert.rejects(rpc(1,'record_purchase_return_v2',[purchase.id,uid(1801),[{purchase_item_id:item,quantity:1}],'Ürün iadesi',device,null]),/mismatch/);
    await assert.rejects(rpc(1,'record_purchase_return_v2',[purchase.id,uid(1802),[{purchase_item_id:item,quantity:2}],'fazla',device,null]),/exceeds/);
    await assert.rejects(rpc(2,'record_purchase_return_v2',[purchase.id,uid(1803),[{purchase_item_id:item,quantity:1}],'yabancı',uid(202),null]));
    await assert.rejects(rpc(1,'record_purchase_return_v2',[purchase.id,uid(1804),[{purchase_item_id:item,quantity:1},{purchase_item_id:item,quantity:1}],'tekrar',device,null]),/Duplicate/);
    await rpc(1,'record_purchase_return_v2',[purchase.id,uid(1805),[{purchase_item_id:item,quantity:1}],'kalan',device,null]);
    const after=await rpc(3,'read_purchase_evidence_v2',[purchase.id]);
    assert.equal(after.items[0].returned_quantity,3);assert.equal(after.items[0].quantity,3);assert.equal(after.final_sale_minor,3600);
    assert.equal(after.invalidated,false);
    await assert.rejects(rpc(2,'read_purchase_evidence_v2',[purchase.id]));
  });
  await check('commercial records cannot be rewritten even by accidental privileged UPDATE/DELETE',async()=>{
    for(const table of ['verified_transactions','verified_transaction_items','purchase_terms','purchase_returns','purchase_return_items','commerce_events']) {
      await assert.rejects(db.exec(`DELETE FROM public.${table}`),/append-only/);
    }
    await assert.rejects(db.exec('UPDATE public.purchase_terms SET final_sale_minor=0'),/append-only/);
  });
  await check('v2 raw header/item RLS loses merchant access after suspension; customer still sees own evidence',async()=>{
    const count=n=>call(n,'SELECT count(*)::int result FROM public.verified_transactions WHERE id=$1',[purchase.id]);
    assert.equal(await count(1),1);
    await db.query('UPDATE public.shops SET is_active=false WHERE id=$1',[uid(10)]);
    assert.equal(await count(1),0);assert.equal(await count(3),1);
    assert.equal(await call(1,'SELECT count(*)::int result FROM public.verified_transaction_items WHERE verified_transaction_id=$1',[purchase.id]),0);
    await db.query('UPDATE public.shops SET is_active=true WHERE id=$1',[uid(10)]);
    await assert.rejects(rpc(2,'list_merchant_purchases_v2',[uid(10),0,20]));
    for(const args of [[uid(10),-1,20],[uid(10),0,51],[uid(10),null,20]])await assert.rejects(rpc(1,'list_merchant_purchases_v2',args));
  });
  await clearLimits();
  await check('request replay cannot change credential; open claim recovered instead of a second active claim',async()=>{
    const q=await fresh(),c=await claim(q,1850);
    await assert.rejects(rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(1850),'other-token',null]),/mismatch/);
    const other=await rpc(1,'claim_existing_qr_v2',[uid(10),device,uid(1851),'other-token',null]);
    assert.equal(other.error,'QR_OTHER_CLAIM_OPEN');
    assert.equal((await rpc(1,'recover_merchant_claim_v2',[uid(10),device])).claim_id,c.claim_id);
    await rpc(1,'cancel_claim_v2',[c.claim_id,device]);
  });
  await clearLimits();
  await check('legacy active QR is not upgraded mid-flight and minor-unit precision is enforced',async()=>{
    const q=await fresh(3,true);await assert.rejects(rpc(3,'create_qr_session_v2',[q.cart_id]),/QR_LEGACY_IN_PROGRESS/);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.qr_session_protocols WHERE qr_session_id=$1',[q.id])).rows[0].n,0);
    await db.query('UPDATE public.shop_products SET price=12.001 WHERE id=$1',[uid(30)]);
    await assert.rejects(fresh(),/exact minor units/);
    await db.query('UPDATE public.shop_products SET price=12 WHERE id=$1',[uid(30)]);
  });
  await check('admin-only corrections and invalidation append evidence without deleting genuine experience',async()=>{
    const p=await rpc(1,'read_purchase_evidence_v2',[purchase.id]), r=p.returns[0];
    await assert.rejects(rpc(1,'invalidate_purchase_v2',[purchase.id,uid(1900),'test']));
    await assert.rejects(rpc(1,'record_purchase_return_v2',[purchase.id,uid(1901),[{purchase_item_id:p.items[0].id,quantity:2}],'Düzeltme',device,r.id]));
    await db.query('INSERT INTO auth.users(id,email) VALUES($1,$2)',[uid(4),'admin@example.invalid']);
    await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[uid(4)]);
    await db.query('INSERT INTO auth.sessions(id,user_id) VALUES($1,$2)',[uid(104),uid(4)]);
    const corrected=await rpc(4,'record_purchase_return_v2',[purchase.id,uid(1902),[{purchase_item_id:p.items[0].id,quantity:2}],'Yanlış adet kaydı',uid(204),r.id]);
    assert.equal(corrected.items[0].returned_quantity,1);assert.equal(corrected.returns.length,3);
    await assert.rejects(rpc(4,'record_purchase_return_v2',[purchase.id,uid(1903),[{purchase_item_id:p.items[0].id,quantity:2}],'tekrar',uid(204),r.id]));
    const id=await rpc(4,'invalidate_purchase_v2',[purchase.id,uid(1904),'Sahte işlem incelemesi']);
    assert.equal(await rpc(4,'invalidate_purchase_v2',[purchase.id,uid(1904),'Sahte işlem incelemesi']),id);
    assert.equal((await rpc(3,'read_purchase_evidence_v2',[purchase.id])).invalidated,true);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.commerce_events WHERE purchase_id=$1',[purchase.id])).rows[0].n,5);
  });
  await check('customer deletion preserves purchase/terms/returns and removes disposable QR without FK blockage',async()=>{
    await rpc(3,'delete_current_customer_account');
    assert.equal((await db.query('SELECT count(*)::int n FROM public.purchase_terms WHERE purchase_id=$1',[purchase.id])).rows[0].n,1);
    assert.equal((await rpc(1,'read_purchase_evidence_v2',[purchase.id])).returns.length,3);
    assert.equal((await db.query('SELECT count(*)::int n FROM public.qr_sessions WHERE user_id=$1',[uid(3)])).rows[0].n,0);
  });
  console.log(`PASS ${checks} Slice B grouped checks (ephemeral SQL, crypto substitute; not Storage/device E2E)`);
} catch(e) {console.error(e.message,e.where??'');process.exitCode=1;} finally {await db.close();}
