import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {connect,rpc,sqlAs} from './fixture.mjs';
import {contended} from './postgres_checks.mjs';

export async function ledgerChecks(db,config,f) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const query=async(sql,args=[])=> (await db.query(sql,args)).rows[0];
  const scalar=async(sql,args=[])=>Object.values(await query(sql,args))[0];
  const party=(kind,ref=null,shop=null)=>scalar('SELECT public.ensure_ledger_party_v1($1,$2,$3)',[kind,ref,shop]);
  const account=(owner,code)=>scalar('SELECT public.ensure_ledger_account_v1($1,$2)',[owner,code]);
  const policy=await scalar('SELECT policy_id FROM public.commerce_ledger_config');
  const source=(kind,owner,amount,extra={})=>scalar('SELECT public.record_commerce_source_v1($1,$2,$3,$4,$5,$6,$7,$8,$9)',[
    kind,extra.id??randomUUID(),owner,amount,extra.policy??policy,extra.evidence??randomUUID(),extra.related??null,extra.accrual??null,extra.reason??'']);
  const lines=(...pairs)=>pairs.map(([account_id,amount])=>({account_id,amount_minor:String(amount)}));
  const post=(id,entries)=>scalar('SELECT public.post_balanced_journal_v1($1,$2)',[id,JSON.stringify(entries)]);
  const balance=id=>scalar('SELECT public._ledger_balance_h0($1)::text',[id]);
  async function transaction(sql,args,options={}) {
    const c=await connect(config);
    try { await c.query(options.repeatable?'BEGIN ISOLATION LEVEL REPEATABLE READ':'BEGIN');
      if(options.before) await options.before(c);
      const result=await c.query(sql,args);if(options.hold) await options.hold(c);
      await c.query('COMMIT');return result.rows[0]?.value;
    } catch(e) {await c.query('ROLLBACK');throw e;} finally {await c.end();}
  }
  const concurrentPost=(id,entries,options)=>transaction('SELECT public.post_balanced_journal_v1($1,$2) value',[id,JSON.stringify(entries)],options);
  const platform=await party('platform'),merchant=await party('merchant',f.shop),other=await party('merchant',f.otherShop),customer=await party('customer',f.customer.id);
  const clearing=await account(platform,'platform_clearing'),service=await account(platform,'platform_service'),offsetControl=await account(platform,'platform_offset_control');
  const reserve=await account(merchant,'merchant_reserve'),pending=await account(merchant,'merchant_coupon_pending'),available=await account(merchant,'merchant_coupon_available');
  const unused=await account(merchant,'merchant_unused_pending'),unusedAvailable=await account(merchant,'merchant_unused_available');
  const reserve2=await account(other,'merchant_reserve'),unused2=await account(other,'merchant_unused_pending'),available2=await account(other,'merchant_unused_available');
  const customerPending=await account(customer,'customer_pending'),customerCoupon=await account(customer,'customer_coupon'),offset=await account(customer,'customer_future_offset');
  await check('H0 default OFF, frozen V1 policy and no preloaded funds or activation',async()=>{
    const caps=await rpc(config,f.customer,'commerce_ledger_capabilities_v1');assert.equal(caps.enabled,false);
    for(const key of ['funding_enabled','rewards_enabled','settlement_enabled']) assert.equal(caps[key],false);
    const p=await query('SELECT * FROM public.commerce_policy_versions WHERE id=$1',[policy]);
    assert.deepEqual([p.eligible_minimum_minor,p.contribution_minor,p.coupon_minor,p.package_fund_minor,p.package_fee_minor,p.reserve_cap_minor],['50000','5000','25000','500000','75000','100000']);
    assert.deepEqual([p.cycle_purchases,p.package_slots,p.package_seconds,p.reservation_seconds,p.minimum_maturity_seconds,p.coupon_expiry_seconds],[5,100,7776000,1800,86400,null]);
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_postings'),0);
    const id=await source('unused_package_fund',merchant,1);await assert.rejects(post(id,lines([clearing,-1],[unused,1])),/LEDGER_DISABLED/);
    assert.equal((await rpc(config,f.merchant,'read_my_commerce_accounts_v1',[f.shop])).enabled,false);
  });
  await check('H0 mobile, anonymous and service roles cannot post, inspect raw accounting or mutate policy',async()=>{
    const tables=['commerce_policy_versions','commerce_ledger_config','ledger_parties','ledger_accounts','ledger_account_locks','ledger_sources','ledger_journals','ledger_postings','ledger_consumer_receipts'];
    for(const role of ['anon','authenticated','service_role']) {
      for(const table of tables) await assert.rejects(transaction(`SET LOCAL ROLE ${role}; SELECT * FROM public.${table}`,[]),e=>e.code==='42501');
      for(const name of ['ensure_ledger_party_v1','ensure_ledger_account_v1','record_commerce_source_v1','post_balanced_journal_v1','reverse_commerce_journal_v1','consume_commerce_event_v1']) {
        assert.equal(await scalar('SELECT has_function_privilege($1,p.oid,\'EXECUTE\') FROM pg_proc p WHERE p.pronamespace=\'public\'::regnamespace AND proname=$2',[role,name]),false);
      }
    }
    await assert.rejects(rpc(config,f.merchant,'post_balanced_journal_v1',[randomUUID(),'[]']),e=>e.code==='42501');
    await assert.rejects(rpc(config,f.other,'read_my_commerce_accounts_v1',[f.shop]),e=>e.code==='42501');
  });
  await db.query('UPDATE public.commerce_ledger_config SET enabled=true');
  await check('H0 immutable policy and exact account identity/currency constraints',async()=>{
    await assert.rejects(db.query('UPDATE public.commerce_policy_versions SET reserve_cap_minor=0'),/append-only/);
    await assert.rejects(account(merchant,'customer_coupon'),/LEDGER_ACCOUNT_TYPE/);
    await assert.rejects(db.query("INSERT INTO public.ledger_accounts(party_id,code,currency) VALUES($1,'merchant_reserve','USD')",[other]),e=>e.code==='23514');
    assert.equal(await party('merchant',f.shop),merchant);assert.equal(await account(merchant,'merchant_reserve'),reserve);
    const packageId=randomUUID();await party('package',packageId,f.shop);
    await assert.rejects(party('package',packageId,f.otherShop),/LEDGER_PARTY_CONFLICT/);
    await assert.rejects(db.query('UPDATE public.ledger_parties SET shop_id=$1 WHERE id=$2',[f.otherShop,merchant]),/LEDGER_IMMUTABLE/);
  });
  await check('H0 typed sources reject missing/null/zero/negative amounts and changed evidence replays',async()=>{
    for(const value of [null,0,-1]) await assert.rejects(source('unused_package_fund',merchant,value),/LEDGER_INVALID_ARGUMENT/);
    const key=randomUUID(),evidence=randomUUID();
    const id=await source('unused_package_fund',merchant,1,{id:key,evidence});
    assert.equal(await source('unused_package_fund',merchant,1,{id:key,evidence}),id);
    await assert.rejects(source('unused_package_fund',merchant,2,{id:key,evidence}),/LEDGER_SOURCE_CONFLICT/);
    await assert.rejects(source('unused_package_fund',merchant,1,{id:key}),/LEDGER_SOURCE_CONFLICT/);
    await assert.rejects(source('admin_reversal',merchant,1),/LEDGER_INVALID_ARGUMENT/);
  });
  await check('H0 journal validation rejects nulls, numeric JSON, duplicate accounts, overflow and unbalanced entries atomically',async()=>{
    const id=await source('unused_package_fund',merchant,100);
    const before=await scalar('SELECT count(*)::int FROM public.ledger_journals');
    const bad=[null,{},[],[{}],lines([clearing,-100],[unused,99]),lines([clearing,-100],[clearing,100]),
      ...['0','1.0','1e2','+100','01'].map(value=>lines([clearing,-100],[unused,value])),
      [{account_id:clearing,amount_minor:-100},{account_id:unused,amount_minor:100}],
      [{account_id:clearing,amount_minor:null},{account_id:unused,amount_minor:'100'}],
      [{account_id:clearing},{account_id:unused,amount_minor:'100'}],
      lines([clearing,'-9223372036854775808'],[unused,'9223372036854775808']),
      lines([randomUUID(),-100],[unused,100])];
    for(const value of bad) await assert.rejects(post(id,value),e=>['22023','22003'].includes(e.code));
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_journals'),before);
    assert.equal(await balance(unused),'0');
    await transaction('SELECT public.post_balanced_journal_v1($1,$2)',[id,JSON.stringify(lines([clearing,-100],[unused,100]))]);
  });
  let couponJournal;
  await check('H0 real concurrent source replay posts once; changed posting replay fails',async()=>{
    const id=await source('coupon_redemption',merchant,150000),entries=lines([clearing,-150000],[reserve,100000],[pending,50000]);
    const results=await contended(db,o=>concurrentPost(id,entries,o),o=>concurrentPost(id,[...entries].reverse(),o));
    assert(results.every(r=>r.status==='fulfilled'));assert.equal(results[0].value,results[1].value);couponJournal=results[0].value;
    assert.equal(await balance(reserve),'100000');assert.equal(await balance(pending),'50000');
    await assert.rejects(post(id,lines([clearing,-150000],[reserve,99999],[pending,50001])),/LEDGER_REQUEST_CONFLICT/);
  });
  await check('H0 unused package funds cannot refill reserve or bypass pending source segregation',async()=>{
    const id=await source('unused_package_fund',merchant,50000);
    await assert.rejects(post(id,lines([clearing,-50000],[reserve,50000])),/LEDGER_RESERVE_SOURCE/);
    await assert.rejects(post(id,lines([clearing,-50000],[unusedAvailable,50000])),/LEDGER_SOURCE_ALLOCATION/);
    await post(id,lines([clearing,-50000],[unused,50000]));assert.equal(await balance(reserve),'100000');
    const foreign=await source('unused_package_fund',merchant,50000);
    await assert.rejects(post(foreign,lines([clearing,-50000],[unused2,50000])),/LEDGER_SOURCE_PARTY/);
  });
  await check('H0 release retains source pool; service debt uses reserve before other available funds',async()=>{
    const release=await source('receivable_release',merchant,50000);
    await assert.rejects(post(release,lines([pending,-50000],[unusedAvailable,50000])),/LEDGER_RELEASE_ALLOCATION/);
    await post(release,lines([pending,-50000],[available,50000]));
    const releaseUnused=await source('receivable_release',merchant,50000);
    await post(releaseUnused,lines([unused,-50000],[unusedAvailable,50000]));
    const bad=await source('platform_service',merchant,10000);
    await assert.rejects(post(bad,lines([available,-10000],[service,10000])),/LEDGER_RESERVE_ALLOCATION/);
    const debt=await source('platform_service',merchant,150000);
    await post(debt,lines([reserve,-100000],[available,-50000],[service,150000]));
    assert.equal(await balance(reserve),'0');assert.equal(await balance(available),'0');assert.equal(await balance(unusedAvailable),'50000');
    const refill=await source('coupon_redemption',merchant,40000);await post(refill,lines([clearing,-40000],[reserve,40000]));
    assert.equal(await balance(reserve),'40000');
    await assert.rejects(scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[couponJournal,randomUUID(),'Local correction']),/LEDGER_OVERDRAFT/);
  });
  await check('H0 competing service debits cannot overdraw the same available balance',async()=>{
    await post(await source('unused_package_fund',other,100000),lines([clearing,-100000],[unused2,100000]));
    await post(await source('receivable_release',other,100000),lines([unused2,-100000],[available2,100000]));
    const a=await source('platform_service',other,75000),b=await source('platform_service',other,75000),entries=lines([available2,-75000],[service,75000]);
    const results=await contended(db,o=>concurrentPost(a,entries,o),o=>concurrentPost(b,entries,o));
    assert.equal(results.filter(r=>r.status==='fulfilled').length,1);assert.match(results.find(r=>r.status==='rejected').reason.message,/LEDGER_OVERDRAFT/);
    assert.equal(await balance(available2),'25000');
  });
  await check('H0 omitted reserve still locks against a concurrent coupon refill',async()=>{
    const credit=await source('coupon_redemption',other,20000),debt=await source('platform_service',other,10000);
    const results=await contended(db,o=>concurrentPost(credit,lines([clearing,-20000],[reserve2,20000]),o),
      o=>concurrentPost(debt,lines([available2,-10000],[service,10000]),o));
    assert.equal(results[0].status,'fulfilled');assert.match(results[1].reason.message,/LEDGER_RESERVE_ALLOCATION/);
    assert.equal(await balance(reserve2),'20000');assert.equal(await balance(available2),'25000');
  });
  await check('H0 repeatable-read stale balance snapshots serialize or fail safely',async()=>{
    const a=await source('platform_service',other,15000),b=await source('platform_service',other,15000),entries=lines([reserve2,-15000],[service,15000]);
    const results=await contended(db,o=>concurrentPost(a,entries,o),o=>concurrentPost(b,entries,{...o,repeatable:true,before:async c=>{await c.query('SELECT count(*) FROM public.ledger_postings');await o.before(c);}}));
    assert.equal(results[0].status,'fulfilled');assert.equal(results[1].status,'rejected');assert.equal(results[1].reason.code,'40001');
    assert.equal(await balance(reserve2),'5000');
  });
  await check('H0 exact compensating reversals preserve history and reject double reversal',async()=>{
    const id=await source('unused_package_fund',merchant,10000),journal=await post(id,lines([clearing,-10000],[unused,10000])),key=randomUUID();
    const undo=await scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[journal,key,'Local test reversal']);
    assert.equal(await scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[journal,key,'Local test reversal']),undo);
    await assert.rejects(scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[journal,randomUUID(),'Second reversal']),e=>['23505','22023'].includes(e.code));
    await assert.rejects(scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[undo,randomUUID(),'Reverse reversal']),/LEDGER_REVERSAL_CONFLICT/);
    assert.equal(await balance(unused),'100');
  });
  await check('H0 future offsets are bounded non-cash obligations; recovery consumes future pending accrual once',async()=>{
    const original=await post(await source('reward_issue',customer,1000),lines([clearing,-1000],[customerCoupon,1000]));
    await assert.rejects(post(await source('offset_created',customer,1,{related:original,reason:'Unspent value cannot become a future obligation'}),lines([offsetControl,-1],[offset,1])),/LEDGER_OFFSET_LIMIT/);
    await post(await source('coupon_redemption',merchant,500),lines([customerCoupon,-500],[reserve,500]));
    const obligation=await post(await source('offset_created',customer,500,{related:original,reason:'Synthetic confirmed abuse allocation'}),lines([offsetControl,-500],[offset,500]));
    await assert.rejects(post(await source('offset_created',customer,501,{related:original,reason:'Over-allocation'}),lines([offsetControl,-501],[offset,501])),/LEDGER_OFFSET_LIMIT/);
    // Replenishing the pool must not make the original full reversal available
    // again after its spent part has already become an offset obligation.
    await post(await source('reward_issue',customer,500),lines([clearing,-500],[customerCoupon,500]));
    await assert.rejects(scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[original,randomUUID(),'Double recovery']),/LEDGER_REVERSAL_CONFLICT/);
    const accrued=await post(await source('reward_issue',customer,300),lines([clearing,-300],[customerPending,300]));
    const recovery=await source('offset_recovered',customer,100,{related:obligation,accrual:accrued,reason:'Synthetic future accrual'});
    const entries=lines([offset,-100],[customerPending,-100],[offsetControl,100],[clearing,100]);
    const id=await post(recovery,entries);assert.equal(await post(recovery,[...entries].reverse()),id);
    assert.equal(await balance(offset),'400');assert.equal(await balance(customerPending),'200');
    await assert.rejects(post(await source('offset_recovered',customer,300,{related:obligation,accrual:accrued,reason:'Reuse accrual'}),
      lines([offset,-300],[customerPending,-300],[offsetControl,300],[clearing,300])),/LEDGER_OVERDRAFT|LEDGER_OFFSET_LIMIT/);
  });
  await check('H0 immutable rows, sealed posting sets and unbalanced direct inserts cannot commit',async()=>{
    for(const table of ['ledger_sources','ledger_journals','ledger_postings','ledger_accounts']) await assert.rejects(db.query(`DELETE FROM public.${table}`),/append-only/);
    const id=await source('unused_package_fund',merchant,1);
    await assert.rejects(transaction("INSERT INTO public.ledger_journals(source_id,posting_count,postings_hash) VALUES($1,2,extensions.digest('x','sha256'))",[id]),/LEDGER_UNBALANCED_OR_UNSEALED/);
    await assert.rejects(db.query('INSERT INTO public.ledger_postings(journal_id,account_id,amount_minor) VALUES($1,$2,1),($1,$3,-1)',[couponJournal,unused,unusedAvailable]),/LEDGER_UNBALANCED_OR_UNSEALED/);
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_journals WHERE source_id=$1',[id]),0);
  });
  await check('H0 owner read minimizes identity and account erasure unlinks retained accounting',async()=>{
    const own=await rpc(config,f.merchant,'read_my_commerce_accounts_v1',[f.shop]);assert.equal(own.enabled,true);
    assert(own.accounts.every(a=>typeof a.amount_minor==='string'));assert(!JSON.stringify(own).includes(merchant));assert.equal(own.settlement_enabled,false);
    const victim=await f.session(),key=await party('customer',victim.id),a=await account(key,'customer_pending');
    await post(await source('reward_issue',key,100),lines([clearing,-100],[a,100]));
    await db.query('DELETE FROM auth.users WHERE id=$1',[victim.id]);assert.equal(await scalar('SELECT user_id FROM public.ledger_parties WHERE id=$1',[key]),null);
    assert.equal(await balance(a),'100');await assert.rejects(rpc(config,victim,'read_my_commerce_accounts_v1'),e=>e.code==='28000');
    await assert.rejects(db.query('UPDATE public.ledger_parties SET user_id=$1 WHERE id=$2',[f.customer.id,key]),/LEDGER_IMMUTABLE/);
  });
  await check('H0 a service reversal cannot overfill reserve after intervening coupon replenishment',async()=>{
    const current=BigInt(await balance(reserve));
    const paid=await post(await source('platform_service',merchant,500),lines([reserve,-500],[service,500]));
    const refill=100000n-current+500n;
    await post(await source('coupon_redemption',merchant,refill.toString()),lines([clearing,-refill],[reserve,refill]));
    await assert.rejects(scalar('SELECT public.reverse_commerce_journal_v1($1,$2,$3)',[paid,randomUUID(),'Reserve already replenished']),/LEDGER_RESERVE_CAP/);
    assert.equal(await balance(reserve),'100000');
  });
  await check('H0 funding separates frozen package fund and fee; reward sources cannot mint merchant accounts',async()=>{
    const packageOwner=await party('package',randomUUID(),f.shop),fund=await account(packageOwner,'package_free');
    const funding=await source('package_funding',packageOwner,575000);
    await assert.rejects(post(funding,lines([clearing,-575000],[fund,575000])),/LEDGER_FUNDING_ALLOCATION/);
    await assert.rejects(post(funding,lines([clearing,-575000],[fund,500001],[service,74999])),/LEDGER_FUNDING_ALLOCATION/);
    await post(funding,lines([clearing,-575000],[fund,500000],[service,75000]));assert.equal(await balance(fund),'500000');
    const reward=await source('reward_issue',customer,5000);
    await assert.rejects(post(reward,lines([fund,-5000],[unused,5000])),/LEDGER_REWARD_ALLOCATION/);
    await post(reward,lines([fund,-5000],[customerPending,5000]));assert.equal(await balance(fund),'495000');
    const returned=await source('return',customer,1);
    await assert.rejects(post(returned,lines([customerPending,-1],[fund,1])),/LEDGER_RETURN_POLICY_PENDING/);
  });
  await check('H0 source plus failed journal rolls back as one caller transaction',async()=>{
    const key=randomUUID();
    await assert.rejects(transaction(`SELECT public.post_balanced_journal_v1(
      public.record_commerce_source_v1('unused_package_fund',$1,$2,10,$3,$4),$5)`,
      [key,merchant,policy,randomUUID(),JSON.stringify(lines([clearing,-10],[unused,9]))]),/LEDGER_UNBALANCED/);
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_sources WHERE source_id=$1',[key]),0);
  });
  await check('H0 one consumer/event records one effect; wrong evidence and changed replay roll back',async()=>{
    const listing=f.listing??randomUUID();
    if(!f.listing) await sqlAs(config,f.merchant,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,12)',[listing,f.shop,f.product]);
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[f.customer.id]);
    const cart=randomUUID();await sqlAs(config,f.customer,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[cart,f.customer.id,f.shop]);
    await sqlAs(config,f.customer,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,1)',[cart,listing]);
    await db.query('UPDATE public.qr_protocol_config SET enabled=true');
    const qr=await rpc(config,f.customer,'create_qr_session_v2',[cart]);
    const claim=await rpc(config,f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),qr.session_token,null]);
    await rpc(config,f.merchant,'complete_existing_qr_v2',[claim.claim_id,f.merchant.installation]);
    const event=await scalar('SELECT e.id FROM public.commerce_events e JOIN public.verified_transactions p ON p.id=e.purchase_id WHERE p.source_qr_session_id=$1 AND e.event_kind=\'purchase_confirmed\'',[qr.id]);
    assert(event);
    const id=await source('unused_package_fund',merchant,10,{evidence:event}),entries=lines([clearing,-10],[unused,10]);
    const consume=options=>transaction('SELECT public.consume_commerce_event_v1($1,$2,$3,$4) value',['h0-test',event,id,JSON.stringify(entries)],options);
    const results=await contended(db,consume,consume);assert(results.every(r=>r.status==='fulfilled'));assert.equal(results[0].value,results[1].value);
    assert.equal(await scalar("SELECT count(*)::int FROM public.ledger_consumer_receipts WHERE consumer='h0-test' AND event_id=$1",[event]),1);
    const wrong=await source('unused_package_fund',merchant,10);
    await assert.rejects(scalar('SELECT public.consume_commerce_event_v1($1,$2,$3,$4)',['h0-test',event,wrong,JSON.stringify(entries)]),/LEDGER_EVENT_SOURCE/);
    const changed=await source('unused_package_fund',merchant,10,{evidence:event});
    await assert.rejects(scalar('SELECT public.consume_commerce_event_v1($1,$2,$3,$4)',['h0-test',event,changed,JSON.stringify(entries)]),/LEDGER_CONSUMER_CONFLICT/);
    assert.equal(await scalar('SELECT count(*)::int FROM public.ledger_journals WHERE source_id=$1',[changed]),0);
  });
  await check('H0 disabled gate retains exact prior receipts but cannot append new financial effects',async()=>{
    const id=await source('unused_package_fund',merchant,1),entries=lines([clearing,-1],[unused,1]),journal=await post(id,entries);
    await db.query('UPDATE public.commerce_ledger_config SET enabled=false');assert.equal(await post(id,entries),journal);
    await assert.rejects(post(await source('unused_package_fund',merchant,1),entries),/LEDGER_DISABLED/);
    assert.equal((await rpc(config,f.merchant,'read_my_commerce_accounts_v1',[f.shop])).accounts.length,0);
    await db.query('UPDATE public.commerce_ledger_config SET enabled=true');
  });
  // Existing shared managed-HTTP acceptance expects claimed QR v2 ready afterward.
  await db.query('UPDATE public.qr_protocol_config SET enabled=true');
  return checks;
}

export async function ledgerHttpChecks({db,request,rpc,session,f}) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const merchant=await session(f.merchant.id),other=await session(f.other.id),customer=await session(f.customer.id);
  await check('HTTP H0 capabilities remain accounting-only; private reads require exact owner/customer',async()=>{
    const caps=await rpc('commerce_ledger_capabilities_v1',null,{});assert.equal(caps.enabled,true);assert.equal(caps.funding_enabled,false);assert.equal(caps.rewards_enabled,false);assert.equal(caps.settlement_enabled,false);
    const own=await rpc('read_my_commerce_accounts_v1',merchant,{p_shop_id:f.shop});assert(own.accounts.length>0);assert.equal(own.shop_id,f.shop);
    assert.equal((await request('/rest/v1/rpc/read_my_commerce_accounts_v1',other,{p_shop_id:f.shop})).ok,false);
    const personal=await rpc('read_my_commerce_accounts_v1',customer,{});assert(personal.accounts.every(a=>a.code.startsWith('customer_')));
    assert.equal((await request('/rest/v1/rpc/read_my_commerce_accounts_v1',null,{})).ok,false);
  });
  await check('HTTP H0 raw records and privileged mutations are inaccessible',async()=>{
    for(const table of ['commerce_policy_versions','ledger_parties','ledger_accounts','ledger_sources','ledger_journals','ledger_postings','ledger_consumer_receipts'])
      assert.equal((await request(`/rest/v1/${table}?select=*`,merchant,undefined,'GET')).ok,false);
    const result=await request('/rest/v1/rpc/post_balanced_journal_v1',merchant,{p_source:randomUUID(),p_postings:[]});assert.equal(result.ok,false);
  });
  await check('HTTP H0 revoked sessions lose account access and fresh sessions see exact integer strings',async()=>{
    assert.equal((await request('/auth/v1/logout?scope=local',merchant,undefined)).ok,true);
    const denied=await request('/rest/v1/rpc/read_my_commerce_accounts_v1',merchant,{p_shop_id:f.shop});assert.equal(denied.ok,false);assert.equal(denied.data.code,'28000');
    const page=await rpc('read_my_commerce_accounts_v1',await session(f.merchant.id),{p_shop_id:f.shop});
    for(const a of page.accounts) assert.match(a.amount_minor,/^[0-9]+$/);
    await db.query('UPDATE public.commerce_ledger_config SET enabled=false');
    assert.equal((await rpc('read_my_commerce_accounts_v1',customer,{})).enabled,false);
  });
  return checks;
}
