import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {rpc,sqlAs,connect} from './fixture.mjs';
import {contended} from './postgres_checks.mjs';

export async function rewardChecks(db,config,f) {
  const checks=[],check=async(name,fn)=>{await fn();checks.push({name,result:'PASS'});console.log(`PASS ${name}`);};
  const scalar=async(sql,args=[])=>Object.values((await db.query(sql,args)).rows[0])[0];
  const call=(actor,name,args=[],options)=>rpc(config,actor,name,args,options);
  const state=()=>call(f.customer,'read_reward_state_v1');
  const overview=()=>call(f.merchant,'read_merchant_reward_v1',[f.shop]);
  const activate=(args)=>scalar('SELECT public.activate_referral_package_v1($1,$2,$3,$4,$5)',args);
  const funding=[f.shop,randomUUID(),randomUUID(),randomUUID(),'575000'];
  let pack;
  f.listing=randomUUID();
  await sqlAs(config,f.merchant,'INSERT INTO public.shop_products(id,shop_id,product_id,price) VALUES($1,$2,$3,500)',[f.listing,f.shop,f.product]);
  async function cart(qty=1,customer=f.customer) {
    await db.query("UPDATE public.carts SET status='cancelled' WHERE user_id=$1 AND status='active'",[customer.id]);
    await db.query('DELETE FROM public.qr_attempt_limits');
    const id=randomUUID();
    await sqlAs(config,customer,'INSERT INTO public.carts(id,user_id,shop_id) VALUES($1,$2,$3)',[id,customer.id,f.shop]);
    await sqlAs(config,customer,'INSERT INTO public.cart_items_v2(cart_id,shop_product_id,quantity) VALUES($1,$2,$3)',[id,f.listing,qty]);
    return id;
  }
  async function purchase(qty=1,customer=f.customer) {
    const id=await cart(qty,customer),q=await call(customer,'create_reward_qr_v1',[id]);
    const c=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    assert.equal(c.status,'claimed',JSON.stringify(c));
    const done=await call(f.merchant,'complete_reward_qr_v1',[c.claim_id,f.merchant.installation,String(qty*50000)]);
    assert.equal(done.status,'used');return done;
  }
  // Test-only time travel in this fresh, owned fixture. No product clock override.
  async function matureFixture() {
    await db.query(`BEGIN; ALTER TABLE public.reward_contributions DISABLE TRIGGER reward_immutable;
      UPDATE public.reward_contributions SET earned_at=earned_at-interval '2 days',matures_at=matures_at-interval '2 days';
      ALTER TABLE public.reward_contributions ENABLE TRIGGER reward_immutable; COMMIT`);
  }
  await check('E default OFF retains canonical policy and exposes no payment/redemption authority',async()=>{
    const caps=await call(f.customer,'reward_capabilities_v1');
    assert.equal(caps.enabled,false);assert.equal(caps.goal,5);assert.equal(caps.package_slots,100);
    assert.deepEqual([caps.minimum_minor,caps.contribution_minor,caps.coupon_minor,caps.package_fund_minor,caps.package_fee_minor],['50000','5000','25000','500000','75000']);
    for(const field of ['package_purchase_enabled','redemption_enabled','settlement_enabled'])assert.equal(caps[field],false);
    await assert.rejects(activate(funding),/REWARD_DISABLED/);
    assert.equal((await state()).pending_count,0);
    await assert.rejects(call(f.other,'read_merchant_reward_v1',[f.shop]),e=>e.code==='42501');
    await assert.rejects(call(f.merchant,'activate_referral_package_v1',funding),e=>e.code==='42501');
  });
  await db.query('UPDATE public.reward_program_config SET enabled=true; UPDATE public.commerce_ledger_config SET enabled=true; UPDATE public.qr_protocol_config SET enabled=true');
  await check('E trusted funding validates exact amount, one active package and immutable 90-day terms',async()=>{
    for(const value of [null,'','0','574999','575001','-1','575000.0']) await assert.rejects(activate([...funding.slice(0,4),value]));
    assert.equal(await scalar('SELECT count(*)::int FROM public.referral_packages WHERE shop_id=$1',[f.shop]),0);
    pack=await activate(funding);assert.equal(await activate(funding),pack);
    await assert.rejects(activate([f.shop,randomUUID(),randomUUID(),randomUUID(),'575000']),/REWARD_PACKAGE_ACTIVE/);
    await assert.rejects(activate([...funding.slice(0,4),'575001']),/REWARD_FUNDING_CONFLICT/);
    assert.equal(await scalar('SELECT extract(epoch from expires_at-activated_at)::int FROM public.referral_packages WHERE id=$1',[pack]),7776000);
    assert.deepEqual((await overview()).packages[0].capacity,{free:100,held:0,consumed:0,expired:0});
    assert.equal((await overview()).forced_acceptance,true);
    await assert.rejects(call(f.merchant,'set_merchant_reward_preference_v1',[f.shop,false,0]),/REWARD_ACCEPTANCE_LOCKED/);
    await assert.rejects(db.query('UPDATE public.referral_packages SET expires_at=expires_at+interval \'1 day\''),/append-only/);
  });
  let reservedCart,firstReservation;
  await check('E contended reservation replay keeps one slot, one attempt and the original deadline',async()=>{
    reservedCart=await cart();
    const results=await contended(db,o=>call(f.customer,'ensure_reward_reservation_v1',[reservedCart,false],o),o=>call(f.customer,'ensure_reward_reservation_v1',[reservedCart,false],o));
    assert(results.every(r=>r.status==='fulfilled'));firstReservation=results[0].value;
    assert.equal(firstReservation.status,'reserved');assert.equal(results[1].value.attempt_id,firstReservation.attempt_id);
    assert.equal(results[1].value.expires_at,firstReservation.expires_at);
    await sqlAs(config,f.customer,'UPDATE public.cart_items_v2 SET quantity=2 WHERE cart_id=$1',[reservedCart]);
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[reservedCart,false])).expires_at,firstReservation.expires_at);
    assert.deepEqual((await overview()).packages[0].capacity,{free:99,held:1,consumed:0,expired:0});
  });
  let firstPurchase;
  await check('E QR uses one identity; legacy completion and altered actual sale cannot bypass consent',async()=>{
    const q=await call(f.customer,'create_reward_qr_v1',[reservedCart]);
    assert.equal((await call(f.customer,'create_reward_qr_v1',[reservedCart])).id,q.id);
    const claim=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    assert.equal(claim.status,'claimed',JSON.stringify(claim));assert.equal(claim.reward_confirmation_required,true);
    assert.equal(claim.reward_sale_minor,'100000');
    await assert.rejects(call(f.merchant,'complete_existing_qr_v2',[claim.claim_id,f.merchant.installation]),/REWARD_CONFIRMATION_REQUIRED/);
    await assert.rejects(call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'99999']),/REWARD_SALE_MISMATCH/);
    const results=await contended(db,o=>call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'100000'],o),o=>call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'100000'],o));
    assert(results.every(r=>r.status==='fulfilled'),JSON.stringify(results));firstPurchase=results[0].value;
    assert.equal(firstPurchase.status,'used');assert.equal(results[1].value.purchase_id,firstPurchase.purchase_id);
    assert.equal((await state()).pending_count,1);assert.equal((await state()).pending_minor,'5000');
    assert.deepEqual((await overview()).packages[0].capacity,{free:99,held:0,consumed:1,expired:0});
  });
  await check('E five same-shop purchases lock 250 TL until all five mature; issuance is replay-safe',async()=>{
    for(let i=0;i<4;i++)await purchase();
    let s=await state();assert.equal(s.pending_count,5);assert.equal(s.coupon_minor,'0');assert.equal(s.coupons.length,0);
    await matureFixture();
    const issued=await contended(db,o=>call(f.customer,'read_reward_state_v1',[],o),o=>call(f.customer,'read_reward_state_v1',[],o));
    assert(issued.every(r=>r.status==='fulfilled'));assert.equal(issued[0].value.coupons[0].id,issued[1].value.coupons[0].id);
    s=issued[0].value;assert.equal(s.pending_count,0);assert.equal(s.coupon_minor,'25000');assert.equal(s.coupons.length,1);assert.equal(s.coupons[0].expires_at,null);
    assert.equal((await state()).coupons[0].id,s.coupons[0].id);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_coupon_sources WHERE coupon_id=$1',[s.coupons[0].id]),5);
  });
  await check('E genuine pre-maturity threshold loss restores one slot/fund without moving issued sources',async()=>{
    const p=await purchase(),evidence=await call(f.merchant,'read_purchase_evidence_v2',[p.purchase_id]);
    await call(f.merchant,'record_purchase_return_v2',[p.purchase_id,randomUUID(),[{purchase_item_id:evidence.items[0].id,quantity:1}],'Local genuine return',f.merchant.installation,null]);
    const s=await state();assert.equal(s.pending_count,0);assert.equal(s.pending_minor,'0');assert.equal(s.coupon_minor,'25000');
    assert.deepEqual((await overview()).packages[0].capacity,{free:95,held:0,consumed:5,expired:0});
  });
  await check('E audited invalidation removes only unspent source value; immutable coupon allocation remains',async()=>{
    await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[f.other.id]);
    await call(f.other,'invalidate_purchase_v2',[firstPurchase.purchase_id,randomUUID(),'Local administrative invalidation']);
    const s=await state();assert.equal(s.coupon_minor,'20000');assert.equal(s.coupons[0].remaining_minor,'20000');
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_coupon_sources WHERE coupon_id=$1',[s.coupons[0].id]),5);
    assert.deepEqual((await overview()).packages[0].capacity,{free:96,held:0,consumed:4,expired:0});
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.other.id]);
  });
  await check('E raw business records and operator functions deny anon, authenticated and service-role access',async()=>{
    const tables=['reward_program_config','reward_runtime_lock','reward_shop_preferences','reward_funding_attestations','referral_packages','reward_attempts',
      'reward_reservations','reward_qr_contracts','reward_sale_attestations','reward_contributions','reward_coupons','reward_coupon_sources','reward_contribution_events','reward_capacity_events'];
    for(const role of ['anon','authenticated','service_role']) {
      for(const table of tables) assert.equal(await scalar("SELECT has_table_privilege($1,'public.'||$2,'SELECT') OR has_table_privilege($1,'public.'||$2,'INSERT') OR has_table_privilege($1,'public.'||$2,'UPDATE') OR has_table_privilege($1,'public.'||$2,'DELETE')",[role,table]),false);
      for(const name of ['activate_referral_package_v1','_reward_post_e','_reward_transfer_e','_reward_mature_e','_post_balanced_journal_before_e','_complete_existing_qr_before_e']) {
        assert.equal(await scalar("SELECT has_function_privilege($1,p.oid,'EXECUTE') FROM pg_proc p WHERE p.pronamespace='public'::regnamespace AND p.proname=$2",[role,name]),false);
      }
    }
    await assert.rejects(call(f.other,'set_merchant_reward_preference_v1',[f.shop,true,0]),e=>e.code==='42501');
    await assert.rejects(call(f.merchant,'read_reward_state_v1'),e=>e.code==='42501');
  });
  await check('E below-threshold release and same-attempt reacquisition never reset thirty minutes',async()=>{
    const id=await cart(),r=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    await db.query('UPDATE public.shop_products SET price=499 WHERE id=$1',[f.listing]);
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,false])).status,'below_threshold');
    await db.query('UPDATE public.shop_products SET price=500 WHERE id=$1',[f.listing]);
    const again=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);
    assert.equal(again.attempt_id,r.attempt_id);assert.equal(again.expires_at,r.expires_at);
    assert.equal(await scalar('SELECT extract(epoch from expires_at-created_at)::int FROM public.reward_attempts WHERE id=$1',[r.attempt_id]),1800);
    await assert.rejects(call(f.other,'ensure_reward_reservation_v1',[id,false]),e=>e.code==='42501');
    await db.query(`BEGIN; ALTER TABLE public.reward_attempts DISABLE TRIGGER reward_immutable;
      UPDATE public.reward_attempts SET created_at=created_at-interval '31 minutes',expires_at=expires_at-interval '31 minutes' WHERE id=$1;
      ALTER TABLE public.reward_attempts ENABLE TRIGGER reward_immutable; COMMIT`.replace(' WHERE id=$1',' WHERE id=\''+r.attempt_id+'\''));
    await db.query("UPDATE public.reward_reservations SET deadline=deadline-interval '31 minutes' WHERE attempt_id=$1",[r.attempt_id]);
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,false])).status,'attempt_expired');
    assert.equal((await call(f.customer,'ensure_reward_reservation_v1',[id,false])).attempt_id,r.attempt_id);
    const next=await call(f.customer,'ensure_reward_reservation_v1',[id,true]);assert.equal(next.status,'reserved');assert.notEqual(next.attempt_id,r.attempt_id);
    await db.query("UPDATE public.carts SET status='cancelled' WHERE id=$1",[id]);await scalar('SELECT public._reward_reconcile_e()');
  });
  await check('E finalization rolls purchase, attestation, contribution and capacity back together on ledger failure',async()=>{
    const id=await cart(),q=await call(f.customer,'create_reward_qr_v1',[id]);
    const claim=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    await db.query('UPDATE public.commerce_ledger_config SET enabled=false');
    await assert.rejects(call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'50000']),/LEDGER_DISABLED/);
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id]),0);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_sale_attestations WHERE qr_ref=$1',[q.id]),0);
    assert.equal((await call(f.merchant,'reconcile_claim_v2',[claim.claim_id,f.merchant.installation])).status,'claimed');
    await db.query('UPDATE public.commerce_ledger_config SET enabled=true');
    assert.equal((await call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'50000'])).status,'used');
  });
  await check('E an ordinary post-maturity return keeps its earned contribution even before coupon materialization',async()=>{
    const p=await purchase();await matureFixture();
    const before=await state(),e=await call(f.merchant,'read_purchase_evidence_v2',[p.purchase_id]);
    await call(f.merchant,'record_purchase_return_v2',[p.purchase_id,randomUUID(),[{purchase_item_id:e.items[0].id,quantity:1}],'Local post-maturity return',f.merchant.installation,null]);
    const after=await state();assert.equal(after.pending_count,before.pending_count);assert.equal(after.coupon_minor,before.coupon_minor);
    assert.equal(after.history.find(h=>h.purchase_id===p.purchase_id).valid,true);
  });
  await check('E administrative correction restores original chronology and never awards a duplicate contribution',async()=>{
    const p=await purchase(),e=await call(f.merchant,'read_purchase_evidence_v2',[p.purchase_id]);
    const original=await scalar('SELECT earned_at::text FROM public.reward_contributions WHERE purchase_id=$1',[p.purchase_id]);
    const items=[{purchase_item_id:e.items[0].id,quantity:1}];
    const returned=await call(f.merchant,'record_purchase_return_v2',[p.purchase_id,randomUUID(),items,'Local return',f.merchant.installation,null]);
    await db.query("UPDATE public.profiles SET role='admin' WHERE id=$1",[f.other.id]);
    const request=randomUUID();const args=[p.purchase_id,request,items,'Local return correction',f.other.installation,returned.returns[0].id];
    await call(f.other,'record_purchase_return_v2',args);await call(f.other,'record_purchase_return_v2',args);
    assert.equal(await scalar('SELECT earned_at::text FROM public.reward_contributions WHERE purchase_id=$1',[p.purchase_id]),original);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_contribution_events WHERE purchase_id=$1',[p.purchase_id]),3);
    assert.equal((await state()).history.find(h=>h.purchase_id===p.purchase_id).valid,true);
    await db.query("UPDATE public.profiles SET role='merchant' WHERE id=$1",[f.other.id]);
  });
  await check('E chronological issuance waits for the earliest five-source group and snapshots longer return policy',async()=>{
    const customer=await f.actor();
    await db.query('INSERT INTO public.reward_shop_preferences(shop_id,voluntary_return_seconds) VALUES($1,259200) ON CONFLICT(shop_id) DO UPDATE SET voluntary_return_seconds=259200,revision=public.reward_shop_preferences.revision+1',[f.shop]);
    const first=await purchase(1,customer);
    await db.query('UPDATE public.reward_shop_preferences SET voluntary_return_seconds=86400,revision=revision+1 WHERE shop_id=$1',[f.shop]);
    for(let i=0;i<5;i++)await purchase(1,customer);
    assert.equal(await scalar('SELECT extract(epoch from matures_at-earned_at)::int FROM public.reward_contributions WHERE purchase_id=$1',[first.purchase_id]),259200);
    await matureFixture();
    let s=await call(customer,'read_reward_state_v1');assert.equal(s.pending_count,6);assert.equal(s.coupons.length,0);
    await db.query(`BEGIN; ALTER TABLE public.reward_contributions DISABLE TRIGGER reward_immutable;
      UPDATE public.reward_contributions SET earned_at=earned_at-interval '2 days',matures_at=matures_at-interval '2 days' WHERE purchase_id='${first.purchase_id}';
      ALTER TABLE public.reward_contributions ENABLE TRIGGER reward_immutable; COMMIT`);
    s=await call(customer,'read_reward_state_v1');assert.equal(s.coupons.length,1);assert.equal(s.pending_count,1);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_coupon_sources WHERE coupon_id=$1 AND purchase_id=$2',[s.coupons[0].id,first.purchase_id]),1);
  });
  await check('E last-slot contention never oversells the hundred-slot package across independent customers',async()=>{
    const initial=(await overview()).packages[0].capacity;
    const holders=[];
    for(let offset=0;offset<initial.free-1;offset+=8) {
      await Promise.all(Array.from({length:Math.min(8,initial.free-1-offset)},async()=>{
        const actor=await f.actor(),id=await cart(1,actor);holders.push(id);
        assert.equal((await call(actor,'ensure_reward_reservation_v1',[id,false])).status,'reserved');
      }));
    }
    const a=await f.actor(),b=await f.actor(),ca=await cart(1,a),cb=await cart(1,b);holders.push(ca,cb);
    const outcomes=await contended(db,o=>call(a,'ensure_reward_reservation_v1',[ca,false],o),o=>call(b,'ensure_reward_reservation_v1',[cb,false],o));
    assert(outcomes.every(r=>r.status==='fulfilled'));assert.deepEqual(outcomes.map(r=>r.value.status).sort(),['no_capacity','reserved']);
    const capacity=(await overview()).packages[0].capacity;
    assert.equal(capacity.free,0);assert.equal(capacity.held+capacity.consumed+capacity.expired,100);
    const withoutCapacity=outcomes[0].value.status==='no_capacity'?a:b;
    const noReward=await purchase(1,withoutCapacity);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_contributions WHERE purchase_id=$1',[noReward.purchase_id]),0);
    await db.query("UPDATE public.carts SET status='cancelled' WHERE id=ANY($1::uuid[])",[holders]);await scalar('SELECT public._reward_reconcile_e()');
    assert.equal((await overview()).packages[0].capacity.free,initial.free);
  });
  await check('E expired package refunds only unused fund; an existing checkout hold may finish on the old package',async()=>{
    const id=await cart(),q=await call(f.customer,'create_reward_qr_v1',[id]);
    const claim=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    const before=(await overview()).packages[0].capacity;
    const merchantParty=await scalar("SELECT id FROM public.ledger_parties WHERE kind='merchant' AND shop_id=$1",[f.shop]);
    const unusedAccount=await scalar("SELECT public.ensure_ledger_account_v1($1,'merchant_unused_pending')",[merchantParty]);
    const unusedBefore=BigInt(await scalar('SELECT public._ledger_balance_h0($1)::text',[unusedAccount]));
    await db.query(`BEGIN; ALTER TABLE public.referral_packages DISABLE TRIGGER reward_immutable;
      UPDATE public.referral_packages SET activated_at=activated_at-interval '91 days',expires_at=expires_at-interval '91 days' WHERE id='${pack}';
      ALTER TABLE public.referral_packages ENABLE TRIGGER reward_immutable; COMMIT`);
    await scalar('SELECT public._reward_reconcile_e()');
    const expired=await overview();assert.equal(expired.forced_acceptance,true);assert.equal(expired.packages[0].capacity.free,0);assert.equal(expired.packages[0].capacity.held,1);
    assert.equal(BigInt(await scalar('SELECT public._ledger_balance_h0($1)::text',[unusedAccount]))-unusedBefore,BigInt(before.free)*5000n);
    const done=await call(f.merchant,'complete_reward_qr_v1',[claim.claim_id,f.merchant.installation,'50000']);assert.equal(done.status,'used');
    assert.equal(await scalar('SELECT package_id FROM public.reward_contributions WHERE purchase_id=$1',[done.purchase_id]),pack);
    const closed=await overview();assert.equal(closed.forced_acceptance,false);
    const preference=await call(f.merchant,'set_merchant_reward_preference_v1',[f.shop,false,closed.preference_revision]);assert.equal(preference.effective_acceptance,false);
    const next=await activate([f.shop,randomUUID(),randomUUID(),randomUUID(),'575000']);assert.notEqual(next,pack);
    assert.equal((await overview()).packages.find(p=>p.id===next).capacity.free,100);
  });
  await check('E reserve-first funding consumes existing source pools before accepting the exact external remainder',async()=>{
    const owner=await scalar("SELECT public.ensure_ledger_party_v1('merchant',$1)",[f.otherShop]);
    const platform=await scalar("SELECT public.ensure_ledger_party_v1('platform')");
    const account=code=>scalar('SELECT public.ensure_ledger_account_v1($1,$2)',[owner,code]);
    const reserve=await account('merchant_reserve'),pending=await account('merchant_coupon_pending'),available=await account('merchant_coupon_available');
    const unused=await account('merchant_unused_pending'),unusedAvailable=await account('merchant_unused_available');
    const clearing=await scalar("SELECT public.ensure_ledger_account_v1($1,'platform_clearing')",[platform]);
    const policy=await scalar('SELECT policy_id FROM public.commerce_ledger_config');
    async function post(kind,amount,pairs) {
      const source=await scalar('SELECT public.record_commerce_source_v1($1,$2,$3,$4,$5,$6)',[kind,randomUUID(),owner,amount,policy,randomUUID()]);
      return scalar('SELECT public.post_balanced_journal_v1($1,$2)',[source,JSON.stringify(pairs.map(([account_id,n])=>({account_id,amount_minor:String(n)})))]);
    }
    await post('coupon_redemption',300000,[[clearing,-300000],[reserve,100000],[pending,200000]]);
    await post('receivable_release',200000,[[pending,-200000],[available,200000]]);
    await post('unused_package_fund',50000,[[clearing,-50000],[unused,50000]]);
    await post('receivable_release',50000,[[unused,-50000],[unusedAvailable,50000]]);
    const args=[f.otherShop,randomUUID(),randomUUID(),randomUUID(),'225000'];
    await assert.rejects(activate([...args.slice(0,4),'575000']),/REWARD_FUNDING_AMOUNT/);
    const id=await activate(args);assert.equal(await activate(args),id);
    for(const a of [reserve,available,unusedAvailable])assert.equal(await scalar('SELECT public._ledger_balance_h0($1)::text',[a]),'0');
    assert.equal(await scalar('SELECT external_paid_minor::text FROM public.reward_funding_attestations WHERE id=$1',[args[1]]),'225000');
    assert.equal((await call(f.other,'read_merchant_reward_v1',[f.otherShop])).packages[0].capacity.free,100);
  });
  await check('E stale repeatable-read reward epoch aborts instead of accepting an obsolete projection',async()=>{
    const stale=await connect(config);
    try {
      await stale.query('BEGIN ISOLATION LEVEL REPEATABLE READ');
      await stale.query('SELECT epoch FROM public.reward_runtime_lock');
      await scalar('SELECT public._reward_lock_e()');
      await assert.rejects(stale.query('SELECT public._reward_lock_e()'),e=>e.code==='40001');
    } finally {await stale.query('ROLLBACK');await stale.end();}
  });
  await check('E lowered checkout cart releases its hold and stale QR cannot create a contribution',async()=>{
    const id=await cart(),q=await call(f.customer,'create_reward_qr_v1',[id]);
    await db.query('UPDATE public.shop_products SET price=499 WHERE id=$1',[f.listing]);
    const result=await call(f.customer,'ensure_reward_reservation_v1',[id,false]);assert.equal(result.status,'below_threshold');
    assert.equal(await scalar("SELECT count(*)::int FROM public.reward_reservations WHERE qr_ref=$1 AND state='checkout_hold'",[q.id]),0);
    const c=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    assert.notEqual(c.status,'claimed');
    assert.equal(await scalar('SELECT count(*)::int FROM public.verified_transactions WHERE source_qr_session_id=$1',[q.id]),0);
    await db.query('UPDATE public.shop_products SET price=500 WHERE id=$1',[f.listing]);
  });
  await check('E gate-off blocks new enrollment while honoring already-attested in-flight purchase terms',async()=>{
    const id=await cart(),q=await call(f.customer,'create_reward_qr_v1',[id]);
    const c=await call(f.merchant,'claim_existing_qr_v2',[f.shop,f.merchant.installation,randomUUID(),q.session_token,null]);
    await db.query('UPDATE public.reward_program_config SET enabled=false');
    const done=await call(f.merchant,'complete_reward_qr_v1',[c.claim_id,f.merchant.installation,'50000']);
    assert.equal(done.status,'used');
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_contributions WHERE purchase_id=$1',[done.purchase_id]),1);
    const other=await f.actor(),next=await cart(1,other);
    await assert.rejects(call(other,'create_reward_qr_v1',[next]),/REWARD_DISABLED/);
    await db.query('UPDATE public.reward_program_config SET enabled=true');
  });
  await check('E generic H0 posting cannot redeem or rewrite tracked reward value outside its business kernel',async()=>{
    const party=await scalar("SELECT id FROM public.ledger_parties WHERE kind='customer' AND user_id=$1",[f.customer.id]);
    const account=await scalar("SELECT public.ensure_ledger_account_v1($1,'customer_coupon')",[party]);
    const source=await scalar('SELECT id FROM public.ledger_sources WHERE party_id=$1 LIMIT 1',[party]);
    await assert.rejects(scalar('SELECT public.post_balanced_journal_v1($1,$2)',[source,JSON.stringify([{account_id:account,amount_minor:'-1'}])]),/REWARD_KERNEL_REQUIRED/);
  });
  await check('E account erasure unlinks retained monetary history and releases outstanding reservation',async()=>{
    const victim=await f.actor(),done=await purchase(1,victim),id=await cart(1,victim);
    await call(victim,'ensure_reward_reservation_v1',[id,false]);
    const party=await scalar("SELECT id FROM public.ledger_parties WHERE kind='customer' AND user_id=$1",[victim.id]);
    await db.query('DELETE FROM auth.users WHERE id=$1',[victim.id]);await scalar('SELECT public._reward_reconcile_e()');
    assert.equal(await scalar('SELECT user_id FROM public.ledger_parties WHERE id=$1',[party]),null);
    assert.equal(await scalar('SELECT count(*)::int FROM public.reward_contributions WHERE purchase_id=$1',[done.purchase_id]),1);
    assert.equal(await scalar("SELECT count(*)::int FROM public.reward_reservations WHERE customer_party=$1 AND state IN ('reserved','checkout_hold')",[party]),0);
    await assert.rejects(call(victim,'read_reward_state_v1'),e=>e.code==='28000');
  });
  await check('E expired checkout release refunds its additional fifty TL exactly once, never the service fee',async()=>{
    const id=await cart(),q=await call(f.customer,'create_reward_qr_v1',[id]);
    const r=(await db.query("SELECT package_id,id FROM public.reward_reservations WHERE qr_ref=$1 AND state='checkout_hold'",[q.id])).rows[0];
    const owner=await scalar("SELECT id FROM public.ledger_parties WHERE kind='merchant' AND shop_id=$1",[f.shop]);
    const unused=await scalar("SELECT public.ensure_ledger_account_v1($1,'merchant_unused_pending')",[owner]);
    await db.query("BEGIN; ALTER TABLE public.referral_packages DISABLE TRIGGER reward_immutable");
    await db.query("UPDATE public.referral_packages SET activated_at=activated_at-interval '91 days',expires_at=expires_at-interval '91 days' WHERE id=$1",[r.package_id]);
    await db.query('ALTER TABLE public.referral_packages ENABLE TRIGGER reward_immutable; COMMIT');
    await scalar('SELECT public._reward_reconcile_e()');
    const before=BigInt(await scalar('SELECT public._ledger_balance_h0($1)::text',[unused]));
    await db.query("UPDATE public.reward_reservations SET deadline=clock_timestamp()-interval '1 second' WHERE id=$1",[r.id]);
    await scalar('SELECT public._reward_reconcile_e()');await scalar('SELECT public._reward_reconcile_e()');
    assert.equal(BigInt(await scalar('SELECT public._ledger_balance_h0($1)::text',[unused]))-before,5000n);
    const capacity=await scalar('SELECT public._reward_capacity_e($1)',[r.package_id]);
    assert.equal(capacity.held,0);assert.equal(capacity.free,0);assert.equal(capacity.consumed+capacity.expired,100);
  });
  return checks;
}
